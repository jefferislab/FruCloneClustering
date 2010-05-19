function reformat_remaining_images(input_dir,output_dir,registration_dir,gregxform_dir,filtered_image_dir)

% this script takes the dimension redcued images and transforms them 
% onto the IS2 template
% the input files are XXX_dimensionReduced.mat and output files are XXX_reformated.mat.
% Must specify the directory for the registration data, the gregxform
% command and the image directory which the resized (or filtered) PIC files

% INPUT
%input_dir='/Volumes/JData/JPeople/Nick/FruCloneClustering/images/';
h=dir([input_dir,'*_dimension_reduced.mat']);

% OUTPUT
%output_dir='/Volumes/JData/JPeople/Nick/FruCloneClustering/images/';

%gregxform_dir='~/Desktop/Universal/';
%registration_dir='~/Registration/warp/';
%image_dir='/Volumes/JData/JPeople/Nick/FruCloneClustering/images/';


for i=1:length(h)
    
     n=find(h(i).name=='_',1,'first');
     name=h(i).name(1:n-1);
     
     n=find(h(i).name=='-',1,'first');
     short_name=h(i).name(1:n-1);
    
     flag=1;

     h1=dir([output_dir,'*_reformated.mat']);

     
     for j=1:length(h1)
         
         n=find(h1(j).name=='_',1,'first');
         name1=h1(j).name(1:n-1);
         
      
         if strcmp(name,name1)
         
                 flag=0;
                 break
             
         end
         
     end
     
     h2=dir([output_dir,'*-in_progress.mat']);
     
     for j=1:length(h2)
         
         n=find(h2(j).name=='_',1,'first');
         name2=h2(j).name(1:n-1);
         
         if strcmp(name,name2)
             
                 flag=0;
                 break
            
         end
         
     end
     
 
     

         
         if flag==1
             
            
             save([output_dir,h(i).name,'-in_progress.mat'],'flag','-v7');
             disp(['Reformating image ',h(i).name])
        h1=dir([filtered_image_dir name,'*tubed.PIC']);
        
 	
          load([input_dir,h(i).name])
		dotsReformated={};
        
        image_data = impicinfo([filtered_image_dir,h1(1).name])
        if (image_data.Delta(1) ~= image_data.Delta(2))
            disp(['WARNING: X and Y dimension mismatch for image',h1(1).name]);
        end

		for j=1:length(dots)

		    y=dots{j};

		    if ~isempty(y)

		        q=floor(rand*1000000);


		    y=reformat_coords(name,y',q,gregxform_dir,registration_dir,image_data);
		    [m1 m2]=size(y);

		    dotsReformated{j}=y';

		    end

		end
              
           
              save([output_dir,name,'_reformated.mat'],'dots','dotsReformated','-v7');
              delete([output_dir,h(i).name,'-in_progress.mat'])
             
              
         end
         
end


