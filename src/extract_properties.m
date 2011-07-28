function [alpha,vect]=extract_properties(coords,ptrtree);
% 
% extract_properties.m
%
% Function that calculates a tangent vector for each dot and an asscoiated score reflecting whether the 
% local geometry is one-dimensional using the local moment of inertia.
%
% INPUTS:   
%   coords:     x,y,z coordinates of dots in image
%   ptrtree:    Pointer created by BuildGLTree3D.m on the coordinates of the image.
%
% OUTPUT:   
%   alpha:      The difference between the first and second eigenvalues of the moment of inertia, divided 
%               by the sum of all 3 eigenvalues. alpha=1  -> one-dimenionsal, alpha=0 -> isotropic.
%   vect:       Tangent vector associated with each dot in image.


% The nearest number of dots used to calculate the moment of inertia
num_dots = 20;

dots_in_image = size(coords,1);
alpha=zeros(1,dots_in_image,'single');
vect=zeros(3,dots_in_image,'single');

if dots_in_image >= num_dots
    
    coords=coords';
    [indNN, dummy]=KNNSearch3D(coords,coords,ptrtree,num_dots+1);
    
    for k = 1:dots_in_image
        
        center_mass=sum(coords(:, indNN(k,2:num_dots+1)),2)/num_dots;
        
        inertia=sum((coords([1 2 3 1 2 3 1 2 3], indNN(k,2:21))'-repmat(center_mass([1 2 3 1 2 3 1 2 3],1)',num_dots,1))...
            .*(coords([1 1 1 2 2 2 3 3 3], indNN(k,2:21))'-repmat(center_mass([1 1 1 2 2 2 3 3 3],1)',num_dots,1)));
        [v,d]=eig(reshape(inertia,3,3));
        
        [d,ind]=sort(diag(d),'descend');
        alpha(k)=(d(1)-d(2))/sum(d);
        vect(:,k)=v(:,ind(1));
        
        
    end  
end

