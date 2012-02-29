function x1=remove_isolated_points(x)
% Function was used to clean up isolated points that mask left behind. 
%
% However, not currently used by any function; can get rid of this
% function. Nicolas Masse. Feb 22, 2011



x1={};



for i=1:length(x)
    
    x1{i}.clone=x{i}.clone;
    x1{i}.images=x{i}.images;
    x1{i}.AROC=x{i}.AROC;
   
    x1{i}.null_score_distribution=x{i}.null_score_distribution;
    x1{i}.clone_score_distribution=x{i}.clone_score_distribution;
    
    for j=1:length(x{i}.s)
        
        t=x{i}.threshold;
        
        ind=find(x{i}.s{j}.MI>t*.005);
        
        while length(ind)<20 & t>0
            
            t=t-1;
            ind=find(x{i}.s{j}.MI>t*.005);
            
        end
            
        
         x1{i}.threshold=t;
        
        y=double(x{i}.s{j}.coords(:,ind));
        
        [m1 m2]=size(y);
        
        if m2>2
        
        ptrtree=BuildGLTree3D(y);
        
        [NNG1,distances]=KNNSearch3D(y,y,ptrtree,2);
        
        ind1=find(distances(:,1)<2);
        
        x1{i}.s{j}.coords=x{i}.s{j}.coords(:,ind(ind1));
        x1{i}.s{j}.vect=x{i}.s{j}.vect(:,ind(ind1));
        x1{i}.s{j}.MI=x{i}.s{j}.MI(:,ind(ind1));
        
         DeleteGLTree3D(ptrtree);
        
        else
            
             x1{i}.s{j}.coords=[];
             x1{i}.s{j}.vect=[];
             x1{i}.s{j}.MI=[];
             
        end
            
            
        
        
        
       
        
    end
    
end

