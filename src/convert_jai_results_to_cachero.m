function [results]=convert_jai_results_to_cachero
% TODO - Nick describe this or put it somewhere else/remove it
clone=clone_dictionary;
[m n]=size(clone);

results={};


[r1 r2]=textread('Jai_results.txt','%s %s');
load DicksonResults_Jan12
load DicksonResults_Jan4 clones
question=zeros(1,m);

for j=1:m
        
  
    
        ix=strfind(clone{j,3},'?');
        if ~isempty(ix);
            clone{j,3}=clone{j,3}(1:ix(1)-1);
            question(j)=1;
            
        end
        
        
        if ~isempty(clone{j,4})
         ix=strfind(clone{j,4},'?');
        if ~isempty(ix);
            clone{j,4}=clone{j,4}(1:ix(1)-1);
            question(j)=1;
        end
        end
        
        
      
        
end

for i=1:length(r2)
   % for i=1:100
    
    results{i,1}=i;
    results{i,2}=r1{i};
    results{i,3}=r2{i};
    results{i,4}='';
    results{i,5}='';
    
    results{i,6}=clones{top5ind(i,1)};
    results{i,7}=top5scores(i,1);
    results{i,8}=clones{top5ind(i,2)};
    results{i,9}=top5scores(i,2);
    
    
    ix=strfind(r2{i},'-');
    if ~isempty(ix)
        r2{i}=r2{i}(3:ix(1)-1);
    else
        r2{i}=r2{i}(3:end);
    end
    
    c=0;
    
   for j=1:m
       
      % ix=strcmp(r2{i},clone{j,3});
       
       if strcmp(r2{i},clone{j,3})
           
           c=c+1;
           if c==1
            results{i,4}=clone{j,1};
            if question(j)==1
                results{i,4}(end+1)='?';
            end
           else
             results{i,5}=clone{j,1}; 
              if question(j)==1
                results{i,5}(end+1)='?';
            end
           end
           
           

       end
       
    %    ix=strfind(r2{i},clone{j,4});
       
       if strcmp(r2{i},clone{j,4})
           
           c=c+1;
           if c==1
            results{i,4}=clone{j,1};
           else
             results{i,5}=clone{j,1}; 
           end
           
           

       end
       
       
           
            
            
            
       
       
       
   end
   
end
           
           
        