function [alpha,vect]=extract_properties(points,k)
% extract_properties_gj - find principal eigenvector and dimensionality of points
%
% Usage: [alpha,vect]=extract_properties_gj(points,[k])
%
% Input:
%   points - (d)x(N) matrix of d-dimensional vectors representing N points
%   k - number of nearest neighbours to use for tangents, default = 20
%
% Output:
%   alpha - dimensionality
%   vect - principal eigenvector or tangent vector
%
% alpha=1 -> one-dimenionsal, alpha=0 -> isotropic). Calculated from the moment of inertia.
%
% depends on ann_meta_wrapper function which provides access to
% Arya and Mount's ANN nearest neighbour library via different
% platform specific wrappers

if nargin < 2
	k = 20;
end

[dummy npoints]=size(points);
alpha=zeros(1,npoints,'single');
vect=zeros(3,npoints,'single');

if npoints<k
	warning ('too few points to extract properties');
	return
end

% find k nearest neighbours for each point
[nnidx, nndist] = ann_meta_wrapper(points,k);

% iterate over each point
for i=1:npoints
	% nearest neighbours for this point
	indNN=nnidx(:,i)';

	center_mass=sum(points(:, indNN),2)/k;

	inertia=sum((points([1 2 3 1 2 3 1 2 3], indNN)'-repmat(center_mass([1 2 3 1 2 3 1 2 3],1)',k,1))...
		.*(points([1 1 1 2 2 2 3 3 3], indNN)'-repmat(center_mass([1 1 1 2 2 2 3 3 3],1)',k,1)));
	[v1,d1]=eig(reshape(inertia,3,3));

	[d1,ind1]=sort(diag(d1),'descend');
	alpha(i)=(d1(1)-d1(2))/sum(d1);
	vect(:,i)=v1(:,ind1(1));
end
