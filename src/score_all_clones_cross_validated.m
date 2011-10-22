function score_all_clones_cross_validated(clone_file,matchedPoints_dir);

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


 % If cross_validation = 1, will loop through all images. If cross_validation = 0, will
 % loop trhough only those images containing the clone.
 full_cross_validation = 1 

save_name='clone_classifier_June6.mat'

x={};

% root_dir = '/Volumes/JData/JPeople/Nick/FruCloneClustering/';

clone_file = 'F:\FruCloneClustering\all-clones.tab';

clone=collect_clone_information(clone_file);

% matchedPoints_dir=[root_dir, 'Matched_dots/'];
matchedPoints_dir='E:\imageProcessing\matched_points_June6\'

load(['F:\FruCloneClustering\final_image_list_feb_18.mat']);


% To save time, we only use classified clones.
ind_classified = [];


ind=[];
for i=1:length(clone)
    if length(clone{i}.image)>=4 ~(strcmp(clone{i}.cloneName,'AL-f') | strcmp(clone{i}.cloneName,'P-e') | ...
            strcmp(clone{i}.cloneName,'P-h') | strcmp(clone{i}.cloneName,'P-s') | strcmp(clone{i}.cloneName,'SG-h') | ...
            strcmp(clone{i}.cloneName,'AMMC') | strcmp(clone{i}.cloneName,'MandibularNerve-a') | strcmp(clone{i}.cloneName,'MandibularNerve-b'))
        ind=[ind i];
    end
end

clone{i}.cloneName

clone=clone(ind);



cloneIndex={};
cloneIndexSize=zeros(1,length(clone));


for i=3:length(clone)
    
    
    %for each clone, determine the index of which images containing the
    %clone have a matching XXXmatchedPoints.mat file. This index list
    %is given by cloneIndex
    
    count=0;
    
    cloneIndex{i}=[];
    
    for j=1:length(clone{i}.image)
        
        i1=find(strcmp(clone{i}.image{j},image_list));
        
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
    score_no_clone1=[];
    score_clone1=[];
    
    score_no_clone2=[];
    score_clone2=[];
    
    indIN=cloneIndex{i};
    indOUT=setdiff(1:length(image_list),cloneIndex{i});
    
    x{i}.s1=build_MI_structure(matchedPoints_dir,image_list(indIN),image_list(indOUT),1);
    x{i}.s2=build_MI_structure(matchedPoints_dir,image_list(indIN),image_list(indOUT),2);
    
    x{i}.clone = clone{i}.cloneName;
    x{i}.images = image_list(indIN);
    
    
    if full_cross_validation
        
        % Leave one out cross-validation
        for j=1:length(image_list);
            
            if j/40 == round(j/40)
                disp([i j])
            end
            
            indIN=setdiff(cloneIndex{i},j);
            indOUT=setdiff(1:length(image_list),[j cloneIndex{i}]);
            
            s1=build_MI_structure(matchedPoints_dir,image_list(indIN),image_list(indOUT),1);
            s2=build_MI_structure(matchedPoints_dir,image_list(indIN),image_list(indOUT),2);
            
            score1=classify_image(s1,j,1);
            score2=classify_image(s2,j,1);
            
            if any(find(j==cloneIndex{i}))
                score_clone1=[score_clone1 score1'];
                score_clone2=[score_clone2 score2'];
            else
                score_no_clone1=[score_no_clone1 score1'];
                score_no_clone2=[score_no_clone2 score2'];
            end
            
            
        end
        
    else
        
        indOUT=setdiff(1:length(image_list), cloneIndex{i});
        
        score_no_clone1=classify_image(x{i}.s1,indOUT,1)';
        score_no_clone2=classify_image(x{i}.s2,indOUT,1)';
        
        for j=1:length(cloneIndex{i})
            
            indIN=setdiff(cloneIndex{i},cloneIndex{i}(j));
            
            s1=build_MI_structure(matchedPoints_dir,image_list(indIN),image_list(indOUT),1);
            s2=build_MI_structure(matchedPoints_dir,image_list(indIN),image_list(indOUT),2);
            
            score1=classify_image(s1,cloneIndex{i}(j),1);
            score2=classify_image(s2,cloneIndex{i}(j),1);
            
            score_clone1=[score_clone1 score1'];
            score_clone2=[score_clone2 score2'];
            
        end
        
    end
    
    
    % Calculated 40 different scores by subracting MI with 40 different
    % thresholds before rectifying. Calcuating AROC scores for all 40.
    for j=1:40
        
        dp1(j)=detectProb(score_no_clone1(j,:)',score_clone1(j,:)');
        dp2(j)=detectProb(score_no_clone2(j,:)',score_clone2(j,:)');
        
    end
    
    [dummy t1]=max(dp1);
    [dummy t2]=max(dp2);
    
    x{i}.AROC_CB=dp1(t1);
    x{i}.threshold_CB=t1;
    x{i}.null_score_distribution_CB=score_no_clone1;
    x{i}.clone_score_distribution_CB=score_clone1;
    
    x{i}.AROC_P=dp2(t2);
    x{i}.threshold_P=t2;
    x{i}.null_score_distribution_P=score_no_clone2;
    x{i}.clone_score_distribution_P=score_clone2;
    
    
    % TODO: The below finds weights used to combine cell body and
    % projection scores. Should come up with a better way. Current methods
    % is not optimized for Jai's tarces (ie N0071.swc)
    % Nicolas Masse, Feb 22, 2011
       
    for i = 1:length(x)
        
        x1=x{i}.null_score_distribution_CB(x{i}.threshold_CB,:);x2=x{i}.clone_score_distribution_CB(x{i}.threshold_CB,:);
        y1=x{i}.null_score_distribution_P(x{i}.threshold_P,:);y2=x{i}.clone_score_distribution_P(x{i}.threshold_P,:);
        
        dp = detectProb_2D([x1' y1'],[x2' y2']);
        % Adding a prior to increase weighting of projection scores which are usually more reliable.
        dp = dp + 0.005 * sind([1:360]);
        
        [dummy ang] = max(dp);
        
        x{i}.optimal_weighting = [cosd(ang) sind(ang)];
        x{i}.AROC_combined = dp(ang) - 0.005 * sind(ang);
        
    end
        
        
    
    
    % removing matched dots matricies because of memory concerns
    for j = 1:length(x{i}.s2)
        
        x{i}.s1{j} = rmfield(x{i}.s1{j},'y');
        x{i}.s2{j} = rmfield(x{i}.s2{j},'y');
        
    end
    
    x{i}.note = 'Cell body threshold is 0.5 of maximum filtered value; cell bodies a match if within 20 um';
    
    save(save_name,'x','image_list','-v7.3')
    
    disp([clone{i}.cloneName,'   ',num2str(0),'   ',num2str(x{i}.AROC_P)])
    
    
end

