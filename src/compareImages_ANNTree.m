function [ind_union]=compareImages_ANNTree(query,template,anntree,distance_thresh,angle_thresh)
% COMPAREIMAGES_ANNTREE Compare point sets derived from images by position and vector similarity
%
% Usage:
%   [ind_union]=compareImages_ANNTree(query,template,anntree,[distance_thresh],[angle_thresh])
%
% Input:
%   query, template - point set properties (inc posiition and tangent vector)
%   anntree         - kd tree associated with the structure template
%   distance_thresh - max distance to consider as match [5]
%   angle_thresh    - max angle to consider as match [20 degrees]
%
% Output:
%   ind_unionindices of matching points from query

if nargin<3
	anntree = [];
end

if nargin<4
	distance_thresh = 5;
end
% ANN returns squared distance, so square threshold
distance_thresh=distance_thresh^2;

if nargin<5
	angle_thresh = 20;
end

% ANN options
% knn = 1, eps = 0 (exact), asm = 0 (no self matches);
if isempty(anntree)
	[NNG,distances] = ann_meta_wrapper(template.gamma2,1,query.gamma2);
else
	[NNG,distances] = ksearch(anntree,query.gamma2,1,0,0);
end

ind=find(distances<distance_thresh);

dot_prod=abs(query.vect2(1,ind).*template.vect2(1,NNG(ind))+...
	query.vect2(2,ind).*template.vect2(2,NNG(ind))+...
	query.vect2(3,ind).*template.vect2(3,NNG(ind)));

ind1=ind(dot_prod>cosd(angle_thresh));

% Flip horizontally (ie across YZ plane)
% TODO Generalise this and maybe carry out completely separate comparisons
% of flipped and non=flipped points
query.gamma2(2,:)=315.13-query.gamma2(2,:);
query.vect2(1,:)=-query.vect2(1,:);

if isempty(anntree)
	[NNG,distances] = ann_meta_wrapper(template.gamma2,1,query.gamma2);
else
	[NNG,distances] = ksearch(anntree,query.gamma2,1,0,0);
end

ind=find(distances<distance_thresh);

dot_prod=abs(query.vect2(1,ind).*template.vect2(1,NNG(ind))+...
	query.vect2(2,ind).*template.vect2(2,NNG(ind))+...
	query.vect2(3,ind).*template.vect2(3,NNG(ind)));

ind2=ind(dot_prod>cosd(angle_thresh));

ind_union=union(ind1,ind2);
