function predict_clone_from_trace(trace_file,clone_classifier,register_option,registration_dir);


% Choose register_option=1 to reformat coordinates
% clone_classier is a .mat file created by create_image_classifier.m

disp('Location of gregxform unix command...');
gregxform_dir='/Applications/IGSRegistrationTools/bin/'

disp('Location of ann command...');
ann_dir='~/dev/ann_1.1.2/bin/'

disp('Location of image properties (ie SAKU1-1_properties.mat...)');
image_properties_dir='~/NickTempFolder/imageProperties/'


% Load classifier structure with mutual information data
load clone_classifier

clones={};

for i=1:length(x)
    clones{i}=x{i}.clone;
end

q=999;

% Read in trace file
x1=dlmread(trace_file);

% Optionally transform query points based on a registration file
if register_option==1 & nargin==3
    error('Must specify registration directory');
elseif register_option==1 & nargin==4

    save(['InputCoords',num2str(q),'.txt'],'x1','-ascii');

    command=[gregxform_dir,'gregxform ',reg,' -f',' <InputCoords',num2str(q),'.txt >OutputCoords',num2str(q),'.txt'];

    system(command);

    [f1 f2 f3]=textread(['OutputCoords',num2str(q),'.txt'],'%s %s %s');

    y=zeros(length(f1),3);

    for i=1:length(f1);

        if f1{i}(1)~='E'

            y(i,1)=str2num(f1{i});
            y(i,2)=str2num(f2{i});
            y(i,3)=str2num(f3{i});

        end

    end

    ind=find(y(:,1)>0);

    y=y(ind,:);

    delete(['InputCoords',num2str(q),'.txt'])
    delete(['OutputCoords',num2str(q),'.txt'])

end


% rename var (FIXME)
y=x1;
clear x1

% Calculate tangent vectors for query points
[alpha,vect]=extract_properties(y,ann_dir,q);

MI_threshold=[0.005:0.005:0.1];
MI_threshold2=[0.005:0.005:0.1]*5;
count=zeros(1,length(x))+10^(-20);
score=zeros(1,length(x));
% count2=zeros(1,40)+10^(-20);
% score2=zeros(1,40);

% aggregated position & vector information for query points
p1.gamma2=y';
p1.vect2=vect;

% Make a nearest search structure for query points
ptrtree=BuildGLTree3DFEX(y);

% Iterate through each template clone
for i=1:length(x)

    disp(['Comparing trace to clone ',clones{i}])

% iterate through each template image for current template clone
    for j=1:length(x{i}.s)

% load dot positions and tangent vectors for this image
% note that there may be multiple variants of this image
% depending on flips etc - this will just use the first one
% TODO - tidy this up
        h=dir([image_properties_dir x{i}.images{j},'*properties.mat']);
        load([image_properties_dir h(1).name]);

% p.gamma is aggregated position & vector information for this
% template image
        [m1 n1]=size(p.gamma2);

% Binary vector containing match points (size of template)
        y=zeros(n1,1,'uint8');

% restrict to template dots above minimum MI score
        ind=find(x{i}.s{j}.MI>.005);
        p2=[];
        p2.gamma2=p.gamma2(:,ind);
        p2.vect2=p.vect2(:,ind);

% find index of template dots that have a match in query
        [matchedPoints]=compareImages_GLTree(p2,p1,ptrtree);

        clear p2

% selected template dots
        y(ind(matchedPoints))=1;

% subtract optimal MI threshold for this template clone (+ rectify)
        modified_MI=max(0,x{i}.s{j}.MI'-MI_threshold(x{i}.threshold));

% count is sum of MI for all template dots
% score for matched template dots
        count(i)=count(i)+sum(modified_MI);
        score(i)=score(i)+sum(single(y(:)).*modified_MI);

    end

end

clear y

DeleteGLTree3DFEX(ptrtree);

score=score./count;

[dummy ind]=sort(score,'descend');


disp('The top five clone scores...');
disp(' ')

for i=1:5

    disp([clones{ind(i)},'  score = ',num2str(score(ind(i)))]);

end
