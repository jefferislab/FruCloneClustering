function [dots,dim,Prob,lam,coords]=image_dimension_reduction(file_name,min_points_per_region,no_iterations)
% This implements the algorithm described in
% Optimal Manifold Representation of Data: An Information Theoretic Approach
% Denis Chigirev and William Bialek
% which attempts to reduce higher dimensional data onto a 1D manifold
% For our images this means trying to reduce dot clouds to compact
% representations of tubular structures
%
% min_points_per_region defaults to 200 points

if nargin < 3
	no_iterations=45;
end

if nargin < 2
	min_points_per_region = 200;
end


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

for z1=1:length(connectedRegions);

	% Make a mask of points in current region
	x=zeros(size(L),'single');
	% set random stream to default state to get same numbers
	s=RandStream.getDefaultStream;
	reset(s);
	% only take one point in 100
	x(L==connectedRegions(z1) & randi(100,size(x))==10)=1;
	%x(L==connectedRegions(z1))=1;

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

	lambda=2*ones(1,K,'single');
	dimension=3*ones(1,K,'single');

	moveInd=[1:K];

	for z=1:no_iterations

		disp([file_name,' iteration ',num2str(z),' out of ',num2str(no_iterations)])

		if z>5
			moveInd=[];
			for i=1:K
				indNN= find(sum((repmat(gamma(:,i),1,K)-gamma).^2)<=10^2);
				if length(indNN)>=20
					minDist=sort(sum((repmat(gamma(:,i),1,length(indNN))-gamma(:,indNN)).^2),'ascend');
					p1=polyfit(log([sqrt(minDist(2:20)) ]),log([2:20]),1);
					dimension(i)=p1(1);
				else
					dimension(i)=0;
				end

				if dimension(i)>maxDim
					% TODO: Ask Nick what this is doing?!  Looks like there
					% is no change in lambda
					lambda(i)=lambda(i)+0;
					moveInd=[moveInd i];
				end
			end
		end

		gammaNew=zeros(n,K,'single');
		Pnew=zeros(1,K,'single');

		dist=zeros(1,K,'single');

		Px=zeros(1,K,'single');

		x(indX)=x(indX)/sum(x(indX));

		% Precompute since it is unchanged inside the loop
		lambda22=2*lambda.^2;
		% compute all against all distance
		% xcoords rows, against gamma cols
		di2=ipdm(xcoords',gamma').^2;
		% Iterate over all points in current region
		for u=1:K
			% Calculate distance between this point and all points in gamma
			% NB this is distance squared in units of pixels
			% TODO repmat here is probably suboptimal
			dist=di2(u,:);
			% -ve exponential of distance/space constant
			Px=P.*exp(-dist./lambda22);
			% normalise so weight of all points is 0
			Px=Px/sum(Px);

			% If first item in Px has gone out of range
			% then zero corresponding point in mask
			if ~(Px(1)>=0 && Px(1)<=1)
				x(indX(u))=0;
				Px=zeros(1,K,'single');
			end
			% Add to Pnew the xth fraction of Px
			Pnew=Pnew+x(indX(u))'*Px;
			% add to every point in gammaNew a fraction of
			% the original coords of current point * Px weight
			for i1=1:n
				gammaNew(i1,:)=gammaNew(i1,:)+((xcoords(i1,u).*x(indX(u))')*Px);
			end

		end

		Pnew=Pnew+10^(-30);
		Pnew=Pnew/sum(Pnew);

		for i1=1:n
			gammaNew(i1,:)=gammaNew(i1,:)./Pnew;
		end

		P(moveInd)=Pnew(moveInd);
		gamma(:,moveInd)=gammaNew(:,moveInd);

	end

	dots{z1}=gamma;
	Prob{z1}=P;
	coords{z1}=xcoords;
	lam{z1}=lambda;
	dim{z1}=dimension;

end
