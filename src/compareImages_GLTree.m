function [ind_first_image,ind_second_image]=compareImages_GLTree(coords1,coords2,vect1,vect2,ptrtree,feature);


% compareImages_GLTree.m
%
% This function determines whether dots from the first image match a dot
% from the second image. Depending on feature, this function will compare
% the distance between dots or the angle between their tangent vectors:
%
% INPUTS:
%   coords1:            x,y,z coordinates of all dots in the first image
%   coords2:            x,y,z coordinates of all dots in the second image
%   vect1:              Tangent vectors of all dots in the first image
%   vect2:              Tangent vectors of all dots in the second image
%   prtree:             Pointer created by BuildGLTree3D.m on the coordinates of second image.
%   feature:            'cell_body' or 'projection' If feature = 'cell_body', function will only compare dot locations.
%                       If feature =  'projection', function will only compare dot locations and tangent vectors.
% OUTPUTS:
%   ind_first_image:    Index of all dots in first image that matched a dot in the second image.
%   ind_second_image:   Index of all dots in second image that matched a dot in the first image.

if ~exist('feature','var') || isempty(feature)
    error('You must specify a  neuronal feature')
end

if nargin < 5
    error('You must input a pointer to the second image');
end

% Distance and angle criteria used to determine whether two dots match
distance_threshold = 5; % in microns
angle_threshold = 20; % in degrees

[NNG1,distances] = KNNSearch3D(double(coords2),double(coords1),ptrtree,1);

if strcmp(feature,'cell_body')
    ind1 = find(distances<20);       
elseif strcmp(feature,'projection')   
    ind = find(distances<distance_threshold);
    dot_prod = abs(vect1(1,ind).*vect2(1,NNG1(ind))+vect1(2,ind).*vect2(2,NNG1(ind))+vect1(3,ind).*vect2(3,NNG1(ind)));
    ind1 = ind(dot_prod>cosd(angle_threshold));
    NNG1 = NNG1(ind1);
end

%TODO: Consider using gregxform with _warping_ registration of 
% horizontally flipped template to template
% this will be slightly different from simply mirroring across
% the mid sagittal plane because IS2 is not complete mirror-symmetric

% flip first image
coords1(1,:) = 315.13-coords1(1,:);
if strcmp(feature,'projection')  
    vect1(1,:) = -vect1(1,:);
end

[NNG2,distances] = KNNSearch3D(double(coords2),double(coords1),ptrtree,1);

if strcmp(feature,'cell_body')  
    ind2 = find(distances<20);
elseif strcmp(feature,'projection')  
    ind = find(distances<distance_threshold);
    dot_prod = abs(vect1(1,ind).*vect2(1,NNG2(ind))+vect1(2,ind).*vect2(2,NNG2(ind))+vect1(3,ind).*vect2(3,NNG2(ind)));
    ind2 = ind(dot_prod>cosd(angle_threshold));
    NNG2 = NNG2(ind2);
end

[ind_first_image,ia,ib] = union(ind1',ind2');
ind_second_image = [NNG1(ia)' NNG2(ib)'];
