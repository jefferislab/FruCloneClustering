function clone=collect_clone_information(clone_file)

% This function produces the cell clone which contains the name of each
% clone and the brains that contain the clone. 
%
% Input: cluster_file, a .tab files, containing the image names in the
%                      first column and the clone names in the second
%                      column. The file should be strcutrued as such to
%                      denote which clones contain which image
%
%                      ImageA  CloneA
%                      ImageB
%                      ImageC
%                      ImageD  CloneB
%                      ImageE
%
%                      Here, Images A-C contain clone A and images D and E
%                      contain clone B.


%clone_file='/Users/nmasse/Projects/imageProcessing/cloneProperties/all-clones.tab';


clone={};

   
    [f1 f2 f3]=textread(clone_file,'%s %s %s');
    
    numClones=0;
   
    
    for i=1:length(f2)
        
        n=find(f1{i}=='-',1,'first');
        imageName=f1{i}(1:n-1);
        
        if ~strcmp(f2{i},'');
            
            numClones=numClones+1;
            clone{numClones}.cloneName=f2{i};
            imageNumber=1;
            clone{numClones}.image{imageNumber}=imageName;
            
        else
            
            imageNumber=imageNumber+1;
            clone{numClones}.image{imageNumber}=imageName;
            
        end
        
        
        
       
        
    end
    
    for i=1:length(clone)
        
        clone{i}.image=unique(clone{i}.image);
        
    end