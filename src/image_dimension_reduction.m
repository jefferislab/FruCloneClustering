function [dots,dim,Prob,lam,coords]=image_dimension_redcution(file_name)


load(file_name)

n=find(file_name=='_',1,'first');
name=file_name(1:n-1);

s=zeros(1,NUM,'single');
        
for j=1:NUM
    ind=find(L==j);
    s(j)=length(ind);
end

connectedRegions=find(s>200);


dots={};
dim={};
Prob={};
lam={};
coords={};

maxDim=1.2;

x1=x;

for z1=1:length(connectedRegions);

    x=zeros(size(L),'single');
    ind=find(L==connectedRegions(z1));

  
   x(ind)=1;
    [n1 n2 n3]=size(x);


    indX=find(x>0);
    m=length(indX);

    xcoords=zeros(3,length(indX),'single');
    [xcoords(1,:) xcoords(2,:) xcoords(3,:)]=ind2sub([n1,n2,n3],indX);

    x=x/sum(x(indX));

    K=length(indX);

gamma=xcoords;

    K=length(indX);

% this is an implementation of the algorithm in
% Optimal Manifold Representation of Data: An Information Theoretic Approach
% Denis Chigirev and William Bialek
% K is the number of points of the low dimensional manifold
% x is the original data (should be between 0 and 1)
% epsilon is the resolution
% lamba determines the tradeoff F(M,Pm) = D + lambda*I

[n,m]=size(xcoords);

K=length(gamma(1,:));

P=ones(1,K,'single')/K;

lambda=2*ones(1,K,'single');
dimension=3*ones(1,K,'single');

no_iterations=45;

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
            lambda(i)=lambda(i)+0;
            moveInd=[moveInd i];


end
           end
 end



    gammaNew=zeros(n,K,'single');
 Pnew=zeros(1,K,'single');

   dist=zeros(1,K,'single');

     Px=zeros(1,K,'single');

  m1=1;

  x(indX)=x(indX)/sum(x(indX));



    for i=1:m



        u=i;
        m1=1;


         dist=sum((repmat(xcoords(:,u),1,K)-gamma).^2);

      Px=P.*exp(-dist./(2*lambda.^2));


        Px=Px/sum(Px);



      if ~(Px(1)>=0 & Px(1)<=1)

        x(indX(u))=0;
        Px=zeros(1,K,'single');
      end

        Pnew=Pnew+x(indX(u))'*Px;



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




