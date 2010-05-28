function [dots,dim,Prob,lam,coords]=image_dimension_reduction(file_name,min_points_per_region,no_iterations)
% Attempts to captures tubular structure in dot collections
%
% Input: matlab file containing 1 or more sets of connected dots
% 
% This implements the algorithm described in
% Optimal Manifold Representation of Data: An Information Theoretic Approach
% Denis Chigirev and William Bialek
% which attempts to reduce higher dimensional data onto a 1D manifold
% For our images this means trying to reduce dot clouds to compact
% representations of tubular structures
%
% min_points_per_region defaults to 200 points
% no_iterations defaults to 45 iterations

if nargin < 3
	no_iterations=45;
end

if nargin < 2
	min_points_per_region = 200;
end

makemovie=false;

load(file_name)

% find all label values
labels=0:max(L(:));
% Calculate histogram of 3D label volume
labelhist = hist(L(:),labels);
% keep non-zero regions that have at least min_points_per_region
connectedRegions=labels(labels>0 & labelhist>min_points_per_region);

dots={};
dim={};
Prob={};
lam={};
coords={};

maxDim=1.2;

tic;
for z1=1:length(connectedRegions);
	
	% Make a mask of points in current region
	x=zeros(size(L),'single');
	% set random stream to default state to get same numbers
	s=RandStream.getDefaultStream;
	reset(s);
	% only take one point in 100 for large numbers
	if(sum(L(:)==connectedRegions(z1))>500000)
		x(L==connectedRegions(z1) & randi(100,size(x))==10)=1;
	else
		x(L==connectedRegions(z1))=1;
	end

	% find indices of those points
	indX=find(x>0);
	% Normalise x by number of points (so sum(x)=1)
	x=x/length(indX);

	% Convert indices to coords
	xcoords=zeros(3,length(indX),'single');
	[xcoords(1,:) xcoords(2,:) xcoords(3,:)]=ind2sub(size(x),indX);
	gamma=xcoords;

	% K is the number of points of the low dimensional manifold
	% x is the original data (should be between 0 and 1)
	% epsilon is the resolution
	% lamba determines the tradeoff F(M,Pm) = D + lambda*I

	[n,K]=size(xcoords);

	P=ones(1,K,'single')/K;

	lambda=2;
	dimension=3*ones(1,K,'single');

	moveInd=1:K;
    
    % Movie code
    % Create a new figure, and position it
    if(makemovie)
        fig1 = figure;
        winsize = get(fig1,'Position');
        winsize(1:2) = [0 0];
        mov = avifile([file_name,'-',num2str(z1),'.avi'],'fps',25,'quality',100);
        set(fig1,'NextPlot','replacechildren');
    end
	
	for z=1:no_iterations
		toc;
		disp([file_name,' iteration ',num2str(z),' out of ',num2str(no_iterations)])
		% number of nearest neighbours to consider - in general the
		% interaction between points falls off very rapidly due to a
		% negative exponential.  Therefore it makes sense only to consider
		% a few close neighbours and set the interaction of all other
		% points to 0.
		kpoints=min([K max([75 ceil(1.5*K^(1/3))])]);

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
					linfit=[ones(19,1) log(sqrt(nndist(2:20,i)))] \ log2to20;
					% set dimensionality of this point to gradient
					dimension(i)=linfit(2);
				else
					dimension(i)=0;
				end
			end
			% Vectorised calculation of moveInd
			moveInd=find(dimension>maxDim & nndist(20,:)<=100);
		end

		gammaNew=zeros(n,K,'single');
		Pnew=zeros(1,K,'single');
	
		x(indX)=x(indX)/sum(x(indX));

		Px=zeros(1,kpoints,'single');
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
				x(indX(u))=0;
				Px=zeros(1,kpoints,'single');
			end
			% Add to Pnew the xth fraction of Px
			Pnew(nnidxsForThisPoint)=Pnew(nnidxsForThisPoint)+x(indX(u))*Px;
			% add to every point in gammaNew a fraction of 
			% the original coords of current point * Px weight
			for i1=1:n
				gammaNew(i1,nnidxsForThisPoint)=gammaNew(i1,nnidxsForThisPoint)...
					+((xcoords(i1,u)*x(indX(u)))*Px);
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
        if makemovie
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
    if makemovie
        mov=close(mov);
    end

	dots{z1}=gamma;
	Prob{z1}=P;
	coords{z1}=xcoords;
	lam{z1}=lambda;
	dim{z1}=dimension;

end
