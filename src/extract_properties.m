function [alpha,vect]=extract_properties(gamma1,ann_dir,q);

[total,dummy]=size(gamma1);
alpha=zeros(1,total,'single');
vect=zeros(3,total,'single');

%ann_dir='/lmb/home/nmasse/bin/ann_1.1.2/bin/';

if total>=20

	save(['DotAlphaData',num2str(q),'.txt'],'gamma1','-ascii');

	command=[ann_dir,'ann_sample -d 3 -e 0.01 -max 999999 -nn 20 -df DotAlphaData',num2str(q),'.txt -qf DotAlphaData',num2str(q),'.txt >DotAlphaOutput',num2str(q),'.txt'];

	system(command);

	[f1 f2 f3]=textread(['DotAlphaOutput',num2str(q),'.txt'],'%s %s %s');

	m1=length(f2);
	t=zeros(1,m1,'single');

	for i=1:m1
		t(i)=single(f2{i}(1));
	end

% 73 is the numeric value of 'I'
	ind=find(t==73);

	gamma1=gamma1';

	for k=1:total

		indNN=[];
		for j=1:20
			indNN=[indNN 1+str2num(f2{ind(k)+j})];
		end

%indNN= find(sum((repmat(gamma1(:,k),1,total)-gamma1).^2)<=10^2);
		nn=length(indNN);

		center_mass=sum(gamma1(:, indNN),2)/nn;

		inertia=sum((gamma1([1 2 3 1 2 3 1 2 3], indNN)'-repmat(center_mass([1 2 3 1 2 3 1 2 3],1)',nn,1))...
			.*(gamma1([1 1 1 2 2 2 3 3 3], indNN)'-repmat(center_mass([1 1 1 2 2 2 3 3 3],1)',nn,1)));
		[v1,d1]=eig(reshape(inertia,3,3));

		[d1,ind1]=sort(diag(d1),'descend');
		alpha(k)=(d1(1)-d1(2))/sum(d1);
		vect(:,k)=v1(:,ind1(1));


	end


	delete(['DotAlphaOutput',num2str(q),'.txt']);
	delete(['DotAlphaData',num2str(q),'.txt'])

end
