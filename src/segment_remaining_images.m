function segment_remaining_images(input_dir,output_dir);

% this script takes tubed images, thresholds them, and then segments them
% the input files are XXXtubed.PIC the and output files are XXXtubed.mat.

%input directory
tubed_dir='/Volumes/JData/JPeople/Nick/FruCloneClustering/images/';
tubed_dir=input_dir;
%output directory
%output_dir='~/Projects/imageProcessing/tubed_files/';


h=dir([tubed_dir,'*-tubed.PIC']);


for i=1:length(h)

    n=find(h(i).name=='_',1,'first');
    name=h(i).name(1:n-1);

    flag=1;

    h1=dir([output_dir,'*_tubed.mat']);


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


        save([output_dir,h(i).name,'-in_progress.mat'],'flag');

        x=readpic([tubed_dir,h(i).name]);
        threshold=10;
        u=zeros(size(x),'uint8');
        u(find(x>=threshold))=1;

        [L,NUM]=bwlabeln(u,26);

        disp(['Segmenting image ',h(i).name,'. Image has ',num2str(NUM),' components.'])


        save([output_dir,name,'_filtered2_tubed.mat'],'x','L','NUM')
        delete([output_dir,h(i).name,'-in_progress.mat'])

    end

end




