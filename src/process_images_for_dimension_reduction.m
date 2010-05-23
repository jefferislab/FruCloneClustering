function process_images_for_dimension_reduction(input_dir,output_dir);

% this scripts looks for tubed files (ending in *tubed.mat) in the tubed directory, performs the dimension reduction,
% and saves them in the dimension reduction directory

% INPUT
%input_dir='/lmb/home/nmasse/FruCloneClustering/preprocessed/';
h=dir(fullfile(input_dir,'*_tubed.mat'));


% OUTPUT
%output_dir='/lmb/home/nmasse/FruCloneClustering/preprocessed/';



for i=1:length(h)

     n=find(h(i).name=='_',1,'first');
     name=h(i).name(1:n-1);

     flag=1;

     % check whether file has already been processed
     h1=dir(fullfile(output_dir,'*dimension_reduced.mat'));

     for j=1:length(h1)

         n=find(h1(j).name=='_',1,'first');
         name1=h1(j).name(1:n-1);


        if strcmp(name,name1)
        
                 flag=0;
                 break
        end

     end

     % check whether file is currently being processed
     h2=dir(fullfile(output_dir,'*-in_progress.mat'));

     for j=1:length(h2)

            n=find(h2(j).name=='_',1,'first');
         name2=h2(j).name(1:n-1);

         if strcmp(name,name2)
                 flag=0;
                 break
             
         end

     end
     
     % if file has not been, or is currenlty, in process, then perform
     % the dimension reduction
         if flag==1

             save(fullfile(output_dir,[h(i).name,'-in_progress.mat']),'flag');

             [dots,dim,Prob,lam,coords]=image_dimension_reduction(...
				 fullfile(input_dir,h(i).name));
             save(fullfile(output_dir,[name,'_dimension_reduced.mat'])...
				 ,'dots','Prob','lam','dim','coords','no_iterations','-v7')
             delete(fullfile(output_dir,[h(i).name,'-in_progress.mat']))
           

          end

end
