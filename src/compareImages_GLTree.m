function [ind_union,matched_dots]=compareImages_GLTree(coords1,coords2,vect1,vect2,ptrtree,feature);

% if feature = 1, function will only compare dot locations
% if feature = 2, function will only compare dot locations and tangent
% vector

if nargin < 4
    error('You must specify a feature (1 or 2)');
end

[NNG1,distances]=KNNSearch3D(double(coords2),double(coords1),ptrtree,1);


if feature == 1
    ind1 = find(distances<20);
       
elseif feature == 2
    
    ind=find(distances<5);
    dot_prod=abs(vect1(1,ind).*vect2(1,NNG1(ind))+vect1(2,ind).*vect2(2,NNG1(ind))+vect1(3,ind).*vect2(3,NNG1(ind)));
    ind1=ind(dot_prod>cosd(20));
    NNG1=NNG1(ind1);

end

%TODO: Consider using gregxform with _warping_ registration of 
% horizontally flipped template to template
% this will be slightly different from simply mirroring across
% the mid sagittal plane because IS2 is not complete mirror-symmetric

% flip first image
coords1(1,:)=315.13-coords1(1,:);
if feature == 2
    vect1(1,:)=-vect1(1,:);
end

[NNG2,distances]=KNNSearch3D(double(coords2),double(coords1),ptrtree,1);


if feature == 1
    ind2 = find(distances<20);
   
elseif feature == 2
    
    ind=find(distances<5);
    dot_prod=abs(vect1(1,ind).*vect2(1,NNG2(ind))+vect1(2,ind).*vect2(2,NNG2(ind))+vect1(3,ind).*vect2(3,NNG2(ind)));
    ind2=ind(dot_prod>cosd(20));
    NNG2=NNG2(ind2);
end


[ind_union,ia,ib]=union(ind1',ind2');
matched_dots=[NNG1(ia)' NNG2(ib)'];
