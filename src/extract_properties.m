function [alpha,vect]=extract_properties(gamma1,ptrtree);

[total,dummy]=size(gamma1);
alpha=zeros(1,total,'single');
vect=zeros(3,total,'single');


if total>=20

gamma1=gamma1';
[indNN,distances]=KNNSearch3D(gamma1,gamma1,ptrtree,21);



for k=1:total

  
nn=20;

  center_mass=sum(gamma1(:, indNN(k,2:21)),2)/nn;

        inertia=sum((gamma1([1 2 3 1 2 3 1 2 3], indNN(k,2:21))'-repmat(center_mass([1 2 3 1 2 3 1 2 3],1)',nn,1))...
            .*(gamma1([1 1 1 2 2 2 3 3 3], indNN(k,2:21))'-repmat(center_mass([1 1 1 2 2 2 3 3 3],1)',nn,1)));
        [v1,d1]=eig(reshape(inertia,3,3));

        [d1,ind1]=sort(diag(d1),'descend');
        alpha(k)=(d1(1)-d1(2))/sum(d1);
        vect(:,k)=v1(:,ind1(1));


end

end

