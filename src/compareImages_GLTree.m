function [ind_union]=compareImages_GLTree(p,p1,ptrtree);


% Output will have the same length as p.gamma2
% the pointer ptrtree is asscoiated with the structure p1



[NNG,distances]=NNSearch3DFEX(p1.gamma2',p.gamma2',ptrtree);


ind=find(distances<5);


dot_prod=abs(p.vect2(1,ind).*p1.vect2(1,NNG(ind))+p.vect2(2,ind).*p1.vect2(2,NNG(ind))+p.vect2(3,ind).*p1.vect2(3,NNG(ind)));


ind1=ind(find(dot_prod>cosd(20)));


p.gamma2(2,:)=315.13-p.gamma2(2,:);
p.vect2(1,:)=-p.vect2(1,:);

[NNG,distances]=NNSearch3DFEX(p1.gamma2',p.gamma2',ptrtree);


ind=find(distances<5);


dot_prod=abs(p.vect2(1,ind).*p1.vect2(1,NNG(ind))+p.vect2(2,ind).*p1.vect2(2,NNG(ind))+p.vect2(3,ind).*p1.vect2(3,NNG(ind)));


ind2=ind(find(dot_prod>cosd(20)));

ind_union=union(ind1,ind2);


