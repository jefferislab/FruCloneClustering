function y=reformat_coords(name,x,q,gregxform_dir,registration_dir,image_data);


%imageDir='/Volumes/JData/JPeople/Nick/FruCloneClustering/images/';
%imageDir='~/Projects/imageProcessing/';
%registrationDir='/Volumes/JData/JPeople/Sebastian/fruitless/Registration/IS2Reg/Registration/warp/';
%registrationDir='~/Registration/warp/';




%in the original implementation, images were all given a depth of 152
%images. Here we scale back to original size.
%zScale=image_data.x.NumImages/152;
x(:,3)=x(:,3)*image_data.Delta(3);

x(:,1)=x(:,1)*image_data.Delta(1);
% NB mirror image in Y to conform to matlab's coordinate system which is 
% left handed (starting bottom, left, front vs top, left front in ImageJ)
x(:,2)=(image_data.Height-x(:,2))*image_data.Delta(2);


save(['InputCoords',num2str(q),'.txt'],'x','-ascii');

reg=[registration_dir,'IS2_',name,'_01_warp_m0g80c8e1e-1x26r4.list'];


% TODO: Some new versions of gregxform were bailing out due to an assertion
% failure in GetJacobian:
% Assertion failed: ((f[dim] >= 0.0) && (f[dim] <= 1.0)), function GetJacobian, file /Users/jefferis/dev/cmtk/core/libs/Base/cmtkSplineWarpXformJacobian.cxx, line 228.
% Abort trap
% Need to fix/discuss with Torsten Rohlfing

%command=['/Users/nmasse/src/cmtk/core/build/bin/gregxform ',reg,' -f',' <InputCoords',num2str(q),'.txt >OutputCoords',num2str(q),'.txt'];
command=[gregxform_dir,'gregxform ',reg,' ',' <InputCoords',num2str(q),'.txt >OutputCoords',num2str(q),'.txt'];

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

