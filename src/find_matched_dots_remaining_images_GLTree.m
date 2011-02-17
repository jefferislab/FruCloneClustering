function find_matched_dots_remaining_images_GLTree(input_dir,output_dir)




% INPUT FILES location of the SA*properties.mat files
%input_dir='~/Projects/imageProcessing/property_files/';
%input_dir='/lmb/home/nmasse/FruCloneClustering/property_files/';

% OUTPUT FILES location of the SA*matchedPoints.mat files
%output_dir='~/Projects/imageProcessing/matched_points/';
%output_dir='/lmb/home/nmasse/FruCloneClustering/matched_points/';




properties_files=dir([input_dir,'*_properties.mat']);
matched_points_files=dir([output_dir,'*_matchedPoints.mat']);

load Final_image_list_Nov29

good_imageList=imageList;

for i=1:length(properties_files)
    
     n=find(properties_files(i).name=='_',1,'first');
     current_name=properties_files(i).name(1:n-1);
     
     n=find(properties_files(i).name=='-',1,'first');
     short_name=properties_files(i).name(1:n-1);
     
    % flag = 1 means that the current file listed in the strcutre h will go ahead for processing
    % However, there are first several checks to ensure the file is not currently completed or in process 
      flag=1;
     
    
     
 h=dir([output_dir,'*-matched_points-in_progress.mat']);
     
     for j=1:length(h)
         
         n=find(h(j).name=='_',1,'first');
         name2=h(j).name(1:n-1);
         
         if strcmp(name2,current_name)
                 flag=0;
                 break
         end
        
         
     end
     

h=dir([output_dir,'*matchedPoints.mat']);

     for j=1:length(h)

         n=find(h(j).name=='_',1,'first');
         name2=h(j).name(1:n-1);

      if strcmp(name2,current_name)
           
           load([output_dir h(j).name],'num_images','imageList');
           
           if num_images==length(properties_files)
               flag=0;
           else
               flag=2;
               break
           end
      end
      
     end



         
         if flag==1 | flag==2
             
             
             if flag==1
             imageList={};
             y=[];
             else
             load([output_dir h(j).name])
             end
             
             
           
             save([output_dir properties_files(i).name,'-matched_points-in_progress.mat'],'flag');
             
     
             load([input_dir properties_files(i).name],'p');
             
             p1=p;
             clear p
             
            
             
             [m1 n1]=size(p1.gamma2);
             
             for j=1:length(properties_files)
                 
                 disp([i j])
                 
                 flag2=0;
                 
                 n=find(properties_files(j).name=='-',1,'first');
                 short_name=properties_files(j).name(1:n-1);
                 
                 
                 % make sure no comparaisons are repeated
                 if ~any(strcmp(imageList,short_name)) & any(strcmp(good_imageList,short_name))
                     flag2=1;
                 end
                 
                 if flag2==1
                     
                     y1=zeros(n1,1,'uint8');
                 
           
                 load([input_dir properties_files(j).name],'p');
                 
                 
                 n=find(properties_files(j).name=='_',1,'first');
                 name=properties_files(j).name(1:n-1);
                 
                 i1=find(name~='-');
                 name=name(i1);

                 
                 %ind_union is the index of the query points (p1.gamma2)
                 %that are matched to the templaye (p.gamma2)
                 
                 
                 [dummy q1]=size(p.gamma2);
                 [dummy q2]=size(p1.gamma2);
                 if q1>200 & q2>200
                    ptrtree=BuildGLTree3D(p.gamma2);
                    [ind_union]=compareImages_GLTree(p1,p,ptrtree);
                    DeleteGLTree3D(ptrtree);
                    y1(ind_union)=1;
                    y=[y y1];
                    imageList{end+1}=short_name;
                   
                 else
                     ind_union=[];
                 end
                 


                 end
      
             end
             
             
%     f=fieldnames(x);


% Verify that there are no duplicate images 

if length(imageList)>0
    num_images=length(imageList);
    f=sort(imageList);
       
    f1={};

     ind=[1];
     f1{1}=f{1};
    
    for j=2:length(f)
        

            name1=f{j-1};
   
            name2=f{j};

        if ~strcmp(name1,name2)

             ind=[ind j];
             f1{j}=name2;
            
        end
        
    end
    
    
    
    imageList=f1(ind); 
    y=y(:,ind);
    
    save([output_dir current_name,'_matchedPoints.mat'],'num_images','imageList','y','-v7');
end


     delete([output_dir properties_files(i).name,'-matched_points-in_progress.mat'])

             
        
    end
         
end
     
