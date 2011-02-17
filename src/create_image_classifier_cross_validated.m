function create_image_classifier_cross_validated(clone_file,matchedPoints_dir);

% INPUTS: clone_file: file name of the .tab file from FileMaker containing
%         the clone iforrmation
%         matchedPoints_dir: directory of the XXXmatchedPOints.mat files
%         secondary = 0 or 1
%         calibrate = 0 or 1
% When secondary = 0, the mutual information per dot is calculated based on
% whether the image contains the clone or does not. When secondary = 1, the
% function computes a confusion matrix, and calculates a secondary mutual
% information per dot based on whether the image contained the clone or
% contained a possible confused clone.
% When calibrate = 1, the scripts determines the optimal mutual information
% level for each clone; might be a bit slow.


save_name='clone_classifier_Jan_6.mat'

x={};


clone_file='/Users/nmasse/Projects/imageProcessing/cloneProperties/all-clones.tab';
clone_file='E:\imageProcessing\src\all-clones.tab';

matchedPoints_dir='E:\imageProcessing\matched_points\';

image_properties_male='e:\imageProcessing\image_properties_male\';

h=dir([matchedPoints_dir,'*matchedPoints.mat']); % matched points are 1um resolution
load([matchedPoints_dir h(1).name],'imageList');

clone=collect_clone_information(clone_file);



% To save time, we only use classified clones.
ind_classified=[];
for i=1:length(clone)
    if any(find(clone{i}.cloneName=='-')) & ~strcmp(clone{i}.cloneName,'P-Single') & ~strcmp(clone{i}.cloneName,'SG-single');
        ind_classified=[ind_classified i];
    elseif strcmp(clone{i}.cloneName,'AMMC') | strcmp(clone{i}.cloneName,'Mb')
         ind_classified=[ind_classified i];
    end
end

clone=clone(ind_classified);



cloneIndex={};
cloneIndexSize=zeros(1,length(clone));


for i=1:length(clone)
        
        classification_score=zeros(length(imageList),40,'single');
        clone_index=zeros(1,length(imageList),'single');
       
        %for each clone, determine the index of which images containing the
        %clone have a matching XXXmatchedPoints.mat file. This index list
        %is given by cloneIndex
        
        count=0;
        
        cloneIndex{i}=[];
        
        for j=1:length(clone{i}.image)
    
        i1=find(strcmp(clone{i}.image{j},imageList));
        
        if ~isempty(i1)
            
            count=count+1;
            
            cloneIndex{i}(count)= i1;
            
        end
        
        end
        
        if ~isempty(cloneIndex{i})
        
        cloneIndex{i}=unique(cloneIndex{i});
        cloneIndexSize(i)=length(cloneIndex{i});
        
        end
        
end

ind=find(cloneIndexSize>=3);

clone=clone(ind);
cloneIndex=cloneIndex(ind);
cloneIndexSize=cloneIndexSize(ind);


for i=1:length(clone)
   
    
    disp(['Calculating mutual information for clone number ',num2str(i),' ',clone{i}.cloneName]);
          
    indIN=cloneIndex{i};
    indOUT=setdiff(1:length(imageList),cloneIndex{i});

   [x{i}.s]=build_MI_structure(matchedPoints_dir,imageList(indIN),imageList(indOUT));
   
   x{i}.clone=clone{i}.cloneName;
   x{i}.images=imageList(indIN);
      
   u=setdiff(1:length(imageList),cloneIndex{i});
   score_no_clone=classify_image(x{i}.s,indIN,imageList,u,matchedPoints_dir,1);
   
    for j=1:length(indIN)
       
       h=dir([image_properties_male,imageList{indIN(j)},'*_properties.mat']);
       load([image_properties_male h(1).name]);
%        hold off;
%        plot3(p.gamma3(1,:),p.gamma3(2,:),p.gamma3(3,:),'k.');
        informative_points=find(x{i}.s{j}.MI>.000);
%        hold on;
%        plot3(p.gamma3(1,informative_points),p.gamma3(2,informative_points),p.gamma3(3,informative_points),'r.');
       x{i}.s{j}.MI=x{i}.s{j}.MI(informative_points);
       x{i}.s{j}.coords=p.gamma3(:,informative_points);
       x{i}.s{j}.vect=p.vect3(:,informative_points);
      
      
       
   end
   
   score_clone=zeros(length(indIN),40);
   
   for j=1:length(indIN)
       
      
       indIN_cv=indIN([1:j-1 j+1:end]);
       [s]=build_MI_structure(matchedPoints_dir,imageList(indIN_cv),imageList(indOUT));
       
       u=indIN(j);
       score_clone(j,:)=classify_image(s,indIN_cv,imageList,u,matchedPoints_dir,1);
       
   end
       

    for j=21:40
      
            dp(j)=detectProb(score_no_clone(:,j)',score_clone(:,j)');
            
    end
         %   dp_x=dp+[.019:-.001:0]; % favour lower thresholds
            [t1 t2]=max(dp);
            
            x{i}.AROC=dp(t2);
            x{i}.threshold=t2-20;
            x{i}.null_score_distribution=score_no_clone(:,t2);
            x{i}.clone_score_distribution=score_clone(:,t2);
            x{i}
            
   
end





save(save_name,'x','imageList')     