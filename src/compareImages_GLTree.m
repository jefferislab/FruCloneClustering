function [ind_union,matched_dots]=compareImages_GLTree(p,p1,ptrtree);


% Output will have the same length as p.gamma2
% the pointer ptrtree is asscoiated with the structure p1



[NNG1,distances]=KNNSearch3D(double(p1.gamma2),double(p.gamma2),ptrtree,1);


ind=find(distances<5);

dot_prod=abs(p.vect2(1,ind).*p1.vect2(1,NNG1(ind))+p.vect2(2,ind).*p1.vect2(2,NNG1(ind))+p.vect2(3,ind).*p1.vect2(3,NNG1(ind)));

ind1=ind(find(dot_prod>cosd(20)));
NNG1=NNG1(ind1);


p.gamma2(1,:)=315.13-p.gamma2(1,:);
p.vect2(1,:)=-p.vect2(1,:);

[NNG2,distances]=KNNSearch3D(double(p1.gamma2),double(p.gamma2),ptrtree,1);


ind=find(distances<5);


dot_prod=abs(p.vect2(1,ind).*p1.vect2(1,NNG2(ind))+p.vect2(2,ind).*p1.vect2(2,NNG2(ind))+p.vect2(3,ind).*p1.vect2(3,NNG2(ind)));
ind2=ind(find(dot_prod>cosd(20)));

NNG2=NNG2(ind2);


[ind_union,ia,ib]=union(ind1',ind2');
matched_dots=[NNG1(ia)' NNG2(ib)'];



