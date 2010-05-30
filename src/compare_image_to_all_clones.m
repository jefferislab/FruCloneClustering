function score=compare_image_to_all_clones(brain_name)


matchedPoints_dir='~/Projects/imageProcessing/imageProperties/';
load clone_classifier

test_image_ind=find(strcmp(imageList,brain_name));

m=length(x);

score=zeros(m,40);

for i=1:m

	disp([num2str(i),'. Comparing brain to clone ',x{i}.clone]);


	template_images_ind=[];

	for j=1:length(x{i}.images)

		template_images_ind=[template_images_ind find(strcmp(imageList,x{i}.images{j}))];

	end


	score(i,:)=classify_image(x{i}.s,template_images_ind,imageList,test_image_ind,matchedPoints_dir);

end
