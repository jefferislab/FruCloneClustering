function [top5scores,top5ind,score]=score_trace_w_cell_bodies(trace_file,x);
% TODO - Nick determine if this is still useful

% x is the clone classifier structure


load trace_to_cell_body

[pathstr, name, ext, versn] = fileparts(trace_file); 

ix = find(strcmp(name, s2));
cell_body_file = s3(ix);
s = readpic([pathstr filesep cell_body_file{1},'.pic']);
metadata = impicinfo([pathstr filesep cell_body_file{1},'.pic']);

ind = find(s>0);


coords_trace_CB = ind2coord(size(s), ind, metadata.Delta, [2 1 3]);
vect_trace_CB=[];



clones={};
num_template_images=0;
clone_template=[0];
for i=1:length(x)
    clones{i}=x{i}.clone;
    num_template_images=num_template_images+length(x{i}.s1);
    clone_template=[clone_template ones(1,length(x{i}.s1))*i];
end


% Loading coordinates of trace.
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


% Calculate tangent vectors along trace
ptrtree=BuildGLTree3D(y');
[alpha,vect]=extract_properties(y,ptrtree);
DeleteGLTree3D(ptrtree);
coords_trace_P = y';
vect_trace_P = vect;



% Calculate MI percentiles scores for each clone.
% This calculations shold probably be done while building the templates.
for i=1:length(x)
    
    MI=[];
    for j=1:length(x{i}.s1);
        MI = [MI x{i}.s1{j}.MI];
    end
    
    x{i}.MI_pct_CB = prctile(MI,[0.1:0.1:100]);
    
    MI=[];
    for j=1:length(x{i}.s2);
        MI = [MI x{i}.s2{j}.MI];
    end
    
    x{i}.MI_pct_P = prctile(MI,[0.1:0.1:100]);
    
end
  
% Initialize trace score
score_P=zeros(size(coords_trace_P,1),num_template_images+1);
score_CB=zeros(size(coords_trace_CB ,1),num_template_images+1); 
score=zeros(size(y,1),num_template_images+1); 
count=1;

for i=1:length(x)    
    
      
for j=1:length(x{i}.s1)
     
%     p2.gamma2=x{i}.s{j}.coords(:,:);
%     p2.vect2=x{i}.s{j}.vect(:,:);
    
    coords_template_CB = x{i}.s1{j}.coords; 
    
    vect_template_CB = [];
    
    coords_template_P = x{i}.s2{j}.coords;
    vect_template_P = x{i}.s2{j}.vect;
    
%     ptrtree=BuildGLTree3D(p2.gamma2);
    ptrtree=BuildGLTree3D(coords_template_P);
    
       
%     [matched_dots_in_trace,matched_dots_in_template]=compareImages_GLTree(p1,p2,ptrtree);
    [matched_dots_in_trace_P,matched_dots_in_template_P] = ...
        compareImages_GLTree(coords_trace_P,coords_template_P,vect_trace_P,vect_template_P,ptrtree,2);
  
    DeleteGLTree3D(ptrtree);
    
    ptrtree=BuildGLTree3D(double(coords_template_CB));
    
    [matched_dots_in_trace_CB,matched_dots_in_template_CB] = ...
        compareImages_GLTree(coords_trace_CB,coords_template_CB,vect_trace_CB,vect_template_CB,ptrtree,1);
    
    DeleteGLTree3D(ptrtree);
    
    
    
    count=count+1;
    score_CB(matched_dots_in_trace_CB,count)=x{i}.s1{j}.MI(matched_dots_in_template_CB);
    score_P(matched_dots_in_trace_P,count)=x{i}.s2{j}.MI(matched_dots_in_template_P);
    
    for k=matched_dots_in_trace_CB
        q=min(1,max(0,find(score_CB(k,count)>=x{i}.MI_pct_CB,1,'last')-500));
         if isempty(q)
              score_CB(k,count)=0;
         else
            score_CB(k,count)=q;
        end
    end
    
    for k=matched_dots_in_trace_P
        q=min(1,max(0,find(score_P(k,count)>=x{i}.MI_pct_P,1,'last')-500));
         if isempty(q)
              score_P(k,count)=0;
         else
            score_P(k,count)=q;
        end
    end
    
    
   

    
end
   



end

clone_score_CB=zeros(size(score_CB,1),length(x));
clone_score_P=zeros(size(score_P,1),length(x));

for i=1:length(x)  
    ix=find(clone_template==i);
    x{i}.optimal_weighting=[sind(10) cosd(10)];
    clone_score_CB(:,i)=mean(score_CB(:,ix)')';
    clone_score_P(:,i)=mean(score_P(:,ix)')';
    
   % score(:,ix)=repmat(mean(score(:,ix)),size(score,1),1);
end
clone_score_P(:,end+1)=.0001*ones(size(clone_score_P,1),1); % if all scores are zero, then maximum value won't correspond to AL-a (clone #1)
clone_score_CB(:,end+1)=.0001*ones(size(clone_score_CB,1),1);

    [dummy ind_CB]=sort(clone_score_CB','descend');
    [dummy ind_P]=sort(clone_score_P','descend');
  
  clear y
  figure;
  subplot(2,1,1),imagesc(clone_score_P);
  subplot(2,1,2),hold off;plot((ind_P(1,:)));%hold on;plot((ix(2,:)),'r')
  
  score1=zeros(1,max(clone_template));
  
  % NOTE: Still looking for the best way of combining cell body scores and
  % projection scores. Also, still not convinced that optimal_weighting is
  % that optimal.
  for k=1:max(clone_template)
     % score1(k)=length(find(clone_template(ix(1:2,:))==k))/length(ix);
     score1(k)=x{k}.optimal_weighting(1)* length(find((ind_CB(1,:))==k))/length(ind_CB) + ...
         x{k}.optimal_weighting(2)* length(find((ind_P(1,:))==k))/length(ind_P);
  end

  

  [dummy ind]=sort(score1,'descend');
  
  
  disp('The top five clone scores...');
  disp(' ')
  
  for i=1:5
      
      disp([clones{ind(i)},'  score = ',num2str(score1(ind(i)))]);
      
  end
  
  

  figure;
  hold off;

 for i=1:length(x{ind(1)}.s1)
   
      %ind(1)=30;

      ix=find(x{ind(1)}.s2{i}.MI>.01);
      iy=find(x{ind(1)}.s1{i}.MI>.02);
      
    % Plot projections from template
    % flip on 3rd axis
     plot3(x{ind(1)}.s2{i}.coords(1,ix),x{ind(1)}.s2{i}.coords(2,ix),184-x{ind(1)}.s2{i}.coords(3,ix),'k.');
     hold on;
     % now flip across 1st axis
     plot3(315.13-x{ind(1)}.s2{i}.coords(1,ix),x{ind(1)}.s2{i}.coords(2,ix),184-x{ind(1)}.s2{i}.coords(3,ix),'k.');
     
     % Plot cell bodies from template.    
      plot3(x{ind(1)}.s1{i}.coords(1,iy),x{ind(1)}.s1{i}.coords(2,iy),184-x{ind(1)}.s1{i}.coords(3,iy),'b.');
    % Plot cell bodies from template, flipped
     plot3(315.13-x{ind(1)}.s1{i}.coords(1,iy),x{ind(1)}.s1{i}.coords(2,iy),184-x{ind(1)}.s1{i}.coords(3,iy),'b.');
 end
 % Plot jai cell body, flipped around 3
 plot3(coords_trace_CB(1,:),coords_trace_CB(2,:),184-coords_trace_CB(3,:),'r.');
 plot3(315.13-coords_trace_CB(1,:),coords_trace_CB(2,:),184-coords_trace_CB(3,:),'r.');
% Plot jai trace, flipped around 3
 plot3(coords_trace_P(1,:),coords_trace_P(2,:),184-coords_trace_P(3,:),'g.');
%  plot3(315-.13-coords_trace_P(1,:),315.13-coords_trace_P(2,:),184-coords_trace_P(3,:),'g.');
 title(['Red = Trace, Black = ',clones{ind(1)},'  Score = ',num2str(score1(ind(1)))]);
 zlabel('Anterior/Posterior')
 xlabel('Medial/Lateral')
 ylabel('Dorsal/Ventral')
 drawnow     

  
  top5ind=ind(1:5);
  top5scores=score1(ind(1:5));
  
  

