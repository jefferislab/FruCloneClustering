function [top5scores,top5ind,score]=score_trace(trace_file);




%disp('Location of traces');

register_option=0;
% traces_dir='C:\Users\Nicolas Masse\Projects\Tracing\IS2\';
% 
% image_properties_dir='E:\imageProcessing\imageProperties\';

% addpath('C:\Users\Public\scripts\');

load('/Volumes/JData/JPeople/Nick/FruCloneClustering/data/clone_classifier.mat')

clones={};

num_template_images=0;
clone_template=[0];
for i=1:length(x)
    clones{i}=x{i}.clone;
    num_template_images=num_template_images+length(x{i}.s);
    clone_template=[clone_template ones(1,length(x{i}.s))*i];
end


[s1 s2 s3 s4 s5 s6 s6]=textread(trace_file,'%s %s %s %s %s %s %s');
x1=zeros(length(s1)-6,3);

for i=7:length(s1);
    if ~isempty(str2num(s3{i}))
    x1(i-6,1)=str2num(s3{i});
    x1(i-6,2)=str2num(s4{i});
    x1(i-6,3)=str2num(s5{i});
    end
    
end



y=x1;
clear x1

score=zeros(size(y,1),num_template_images+1);




 ptrtree=BuildGLTree3D(y');
[alpha,vect]=extract_properties(y,ptrtree);
DeleteGLTree3D(ptrtree);

p1.gamma2=y';
p1.vect2=vect;

count=1;



for i=1:length(x)    
    
      
for j=1:length(x{i}.s)
     
    p2.gamma2=x{i}.s{j}.coords(:,:);
    p2.vect2=x{i}.s{j}.vect(:,:);
    
   
    
    ptrtree=BuildGLTree3D(p2.gamma2);
 
    [m1 n1]=size(p2.gamma2);
    
    y=zeros(n1,1,'uint8');
    
       
    [matched_dots_in_trace,matched_dots_in_template]=compareImages_GLTree(p1,p2,ptrtree);
    
    DeleteGLTree3D(ptrtree);
    
    clear p2

   
    
    count=count+1;
    score(matched_dots_in_trace,count)=x{i}.s{j}.MI(matched_dots_in_template);
    for k=matched_dots_in_trace
        q=max(0,find(score(k,count)>=x{i}.MI_pct,1,'last')-500);
         if isempty(q)
              score(k,count)=0;
         else
            score(k,count)=q;
        end
    end
   

    
end
   



end

clone_score=zeros(size(score,1),length(x));

for i=1:length(x)  
    ix=find(clone_template==i);
    clone_score(:,i)=mean(score(:,ix)')';
   % score(:,ix)=repmat(mean(score(:,ix)),size(score,1),1);
end
clone_score(:,end+1)=.0001*ones(size(clone_score,1),1); % if all scores are zero, then maximum value won't correspond to AL-a (clone #1)
  
    [dummy ix]=sort(clone_score','descend');
  
  clear y
  subplot(2,1,1),imagesc(clone_score);
  subplot(2,1,2),hold off;plot((ix(1,:)));%hold on;plot((ix(2,:)),'r')
  score1=zeros(1,max(clone_template));
  for k=1:max(clone_template)
     % score1(k)=length(find(clone_template(ix(1:2,:))==k))/length(ix);
     score1(k)=length(find((ix(1,:))==k))/length(ix);
  end

  

  [dummy ind]=sort(score1,'descend');
  
  
  disp('The top five clone scores...');
  disp(' ')
  
  for i=1:5
      
      disp([clones{ind(i)},'  score = ',num2str(score1(ind(i)))]);
      
  end
  
  

  figure;
  hold off;

 for i=1:length(x{ind(1)}.s)
   

      ix=find(x{ind(1)}.s{i}.MI>.035);
      
 
     plot3(x{ind(1)}.s{i}.coords(1,ix),x{ind(1)}.s{i}.coords(2,ix),x{ind(1)}.s{i}.coords(3,ix),'k.');
     hold on;
     plot3(x{ind(1)}.s{i}.coords(1,ix),315.13-x{ind(1)}.s{i}.coords(2,ix),x{ind(1)}.s{i}.coords(3,ix),'k.');
 end
 
 plot3(p1.gamma2(1,:),p1.gamma2(2,:),p1.gamma2(3,:),'r.');
 title(['Red = Trace, Black = ',clones{ind(1)},'  Score = ',num2str(score(ind(1)))]);
 drawnow     

  
  top5ind=ind(1:5);
  top5scores=score1(ind(1:5));
  
  

