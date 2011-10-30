function [alpha,vect]=extract_properties(coords,k);
%EXTRACT_PROPERTIES Calculate tangent vector and local moment of inertia
% for each dot calculate tangent vecor an asscoiated score reflecting whether the 
% local geometry is one-dimensional using the local moment of inertia.
%
% INPUTS:
%   coords:  x,y,z coordinates of dots in image (Nx3)
%   k:       number of nearest neighbours for moment of inertia (default 20)
%
% OUTPUT:
%   alpha:      The difference between the first and second eigenvalues of the moment of inertia, divided 
%               by the sum of all 3 eigenvalues. alpha=1  -> one-dimenionsal, alpha=0 -> isotropic.
%   vect:       Tangent vector associated with each dot in image.

if nargin < 2
    k = 20;
end

dots_in_image = size(coords,1);
alpha=zeros(1,dots_in_image,'single');
vect=zeros(3,dots_in_image,'single');


if dots_in_image >= k
    
    coords=coords'; % convert to 3xN
    ptrtree=BuildGLTree3D(coords);
    [indNN, dummy]=KNNSearch3D(coords,coords,ptrtree,k+1);
    
    for i = 1:dots_in_image
        
        center_mass=sum(coords(:, indNN(i,2:k+1)),2)/k;
        
        inertia=sum((coords([1 2 3 1 2 3 1 2 3], indNN(i,2:k+1))'-repmat(center_mass([1 2 3 1 2 3 1 2 3],1)',k,1))...
            .*(coords([1 1 1 2 2 2 3 3 3], indNN(i,2:k+1))'-repmat(center_mass([1 1 1 2 2 2 3 3 3],1)',k,1)));
        [v,d]=eig(reshape(inertia,3,3));
        
        [d,ind]=sort(diag(d),'descend');
        alpha(i)=(d(1)-d(2))/sum(d);
        vect(:,i)=v(:,ind(1));
        
    end
    DeleteGLTree3D(ptrtree);
end

