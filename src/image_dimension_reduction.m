function [dots,dim,Prob,lam,coords]=image_dimension_reduction(file_name,min_points_per_region,no_iterations)
%
% (Further) enhance tubular structure in dot collections
%
% This implements the algorithm described in "Optimal Manifold Representation 
% of Data: An Information Theoretic Approach", Denis Chigirev and William Bialek. 
% This function reduces higher dimensional data onto a 1D manifold.
% In other words, it attempts to captures tubular structure in dot collections
%
% INPUTS:
%   file_name:              File name of the segementd image (saved as a *tubed.mat file).
%   min_points_per_region:  Sets containing less than min_points_per_region coordinates will
%                           be discarded. Defaults to 200 (including when
%                           passed []).
%   no_iterations:          Number of iteration to run the EM algorithm.
%                           Defaults to 45 (including when passed []).



if nargin < 4 || isempty(no_iterations)
	no_iterations=45;
end

if nargin < 3 || isempty(min_points_per_region)
	min_points_per_region = 200;
end

load(file_name)

% find all label values
labels=0:max(L(:));
% Calculate histogram of 3D label volume
labelhist = hist(L(:),labels);
% keep non-zero regions that have at least min_points_per_region
connectedRegions=labels(labels>0 & labelhist>min_points_per_region);

dots=cell(1,length(connectedRegions));
dim=cell(1,length(connectedRegions));
Prob=cell(1,length(connectedRegions));
lam=cell(1,length(connectedRegions));
coords=cell(1,length(connectedRegions));

tic;
for z1=1:length(connectedRegions);

	% find indices of points in current region
	indX=find(L==connectedRegions(z1));

	% Convert indices to coords (using standard matlab axis permutation)
	xcoords=ind2coord(size(L),indX,voxdims,[2 1 3]);

	% Swap commented line to make a movie
	moviefile='';
%	moviefile=[file_name,'-',num2str(z1),'.avi'];
	disp(['Starting dimension reduction for ',file_name]);
	[gamma,P,lambda,dimension] = chigirev_dim_reduction(xcoords,no_iterations,moviefile);

	dots{z1}=gamma;
	Prob{z1}=P;
	coords{z1}=xcoords;
	lam{z1}=lambda;
	dim{z1}=dimension;

end
end

function [gamma,P,lambda,dimension] = chigirev_dim_reduction(xcoords,no_iterations,moviefile)
% CHIGIREV_DIM_REDUCTION Compute Optimal Manifold Representation of points
%
% Usage:
% [gamma,P,lambda,dimension] = ...
%     chigirev_dim_reduction(pts,no_iterations,[makemovie])
%
% Input:
% pts           -  d x N matrix of d-dimensional vectors representing N points
% no_iterations - 
% moviefile     - optional - file to write a movie for each iteration
%
% This implements the algorithm described in
% Optimal Manifold Representation of Data: An Information Theoretic Approach
% Denis Chigirev and William Bialek
% which attempts to reduce higher dimensional data onto a 1D manifold

	% K is the number of points of the low dimensional manifold
	% xx is the original data (should be between 0 and 1)
	% lamba determines the tradeoff F(M,Pm) = D + lambda*I
	% gamma will be new manifold positions
	xcoords=single(xcoords);
	gamma=xcoords;
	[n,K]=size(xcoords);

	P=ones(1,K,'single')/K;
	
	% a mask on the points in xcoords
	xx=ones(1,K,'single')/K;
	
	lambda=2;
	dimension=3*ones(1,K,'single');

	maxDim=1.2; % points with local dimensionality < maxDim will be fixed

	moveInd=1:K;

	% Movie code
	if nargin<3
		moviefile=''; % no movie will be made
	elseif n~=3
		error('movie can only be made for 3d data');
	end
	% Create a new figure, and position it
	if ~isempty(moviefile)
		fig1 = figure;
		winsize = get(fig1,'Position');
		winsize(1:2) = [0 0];
		mov = avifile(moviefile,'fps',25,'quality',100);
		set(fig1,'NextPlot','replacechildren');
	end

	for z=1:no_iterations
		toc;
		disp(['iteration ',num2str(z),' out of ',num2str(no_iterations)])
		% number of nearest neighbours to consider - in general the
		% interaction between points falls off very rapidly due to a
		% negative exponential.  Therefore it makes sense only to consider
		% a few close neighbours and set the interaction of all other
		% points to 0.
		% kpoints=min([K max([75 ceil(1.5*K^(1/3))])]);
		kpoints=min([K 75]);

		% Must have at least 20 points
		if z>5 && K>=20
			[nnidx, nndist] = ann_meta_wrapper(gamma,20);
			log2to20=log(2:20)';
			for i=1:K
				if nndist(20,i)<=100
					% Nick: I just wanted to double check this is the right
					% way around ie nearest neighbour distances (x axis)
					% against log2 to log20 on y axis
					% try a very simple solution
					numzeros=sum(nndist(2:20,i)==0);
					if numzeros>0
						% some points are right on top of this one so let's say 
						dimension(i)=0;
						% also this can cause serious instability in fit below
						% which in octave can result in an infinite loop
					else
						linfit=[ones(19,1) log(sqrt(nndist(2:20,i)))] \ log2to20;
						% set dimensionality of this point to gradient
						dimension(i)=linfit(2);
					end
				else
					dimension(i)=0;
				end
			end
			% Vectorised calculation of moveInd
			moveInd=find(dimension>maxDim & nndist(20,:)<=100);
		end

		gammaNew=zeros(n,K,'single');
		Pnew=zeros(1,K,'single');

		xx=xx/sum(xx);

		disp(['kpoints: ',num2str(kpoints),' moveInd: ',num2str(length(moveInd))]);

		% find kpoints nearest neighbours from gamma for each xcoord
		[nnidx, nndist] = ann_meta_wrapper(gamma,kpoints,xcoords);

		% Precompute since it is unchanged inside the loop
		negexpdist=exp( -nndist / (2*lambda^2) );
		% Iterate over all points in current region
		for u=1:K
			nnidxsForThisPoint=nnidx(:,u);

			% -ve exponential of distance/space constant
			Px=P(nnidxsForThisPoint).*negexpdist(:,u)';
			% normalise so weight of all points is 1
			Px=Px/sum(Px);

			% If first item in Px has gone out of range
			% then zero corresponding point in mask
			if ~(Px(1)>=0 && Px(1)<=1)
				xx(u)=0;
				Px=zeros(1,kpoints,'single');
			end
			% Add to Pnew the xth fraction of Px
			Pnew(nnidxsForThisPoint)=Pnew(nnidxsForThisPoint)+xx(u)*Px;
			% add to every point in gammaNew a fraction of
			% the original coords of current point * Px weight
			for i1=1:n
				gammaNew(i1,nnidxsForThisPoint)=gammaNew(i1,nnidxsForThisPoint)...
					+((xcoords(i1,u)*xx(u))*Px);
			end

		end

		Pnew=Pnew+10^(-30);
		Pnew=Pnew/sum(Pnew);

		for i1=1:n
			gammaNew(i1,:)=gammaNew(i1,:)./Pnew;
		end

		P(moveInd)=Pnew(moveInd);
		gamma(:,moveInd)=gammaNew(:,moveInd);

		% Movie code
		if ~isempty(moviefile)
			fixedPoints=setdiff(1:K,moveInd);
			plot3(gamma(1,moveInd),gamma(2,moveInd),gamma(3,moveInd),'.',...
				gamma(1,fixedPoints),gamma(2,fixedPoints),gamma(3,fixedPoints),'.');
			if z==1
				V = axis;
			else
				axis(V);
			end
			F = getframe;
			mov = addframe(mov,F);
		end
	end
	% Movie code
	if ~isempty(moviefile)
		mov=close(mov);
	end
end
