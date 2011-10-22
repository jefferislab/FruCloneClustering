function [s]=build_MI_structure(matched_dots_dir,fileNamesIN,fileNamesOUT,neuronal_feature)
% BUILD_MI_STRUCTURE Calculate mutual information for one clone type
%
%given a list of file names given by the cell fileNamesIN and fileNamesOUT, this function
%computes the mutual information between matched dots and to which list the image
%belong to. The general purpose is to feed in the file
%names that all contain the same clone, and those that don't, and this function will identify how
%informative each dots in each these files is of the clone.
%
% See also create_image_classifier

s=cell(1,length(fileNamesIN));

for i=1:length(fileNamesIN)
    
    h=dir([matched_dots_dir, fileNamesIN{i},'_matched_dots.mat']); % chaned '*' to '_' NYM May 22,2011
    
    if neuronal_feature == 1
        load([matched_dots_dir h(1).name],'coords_cell_bodies','match1','matched_images');
        y = match1; % match1 is the comparaison between dots using both just lcoation
        coords = coords_cell_bodies;
        vect=[];
        
    elseif neuronal_feature == 2
        load([matched_dots_dir h(1).name],'coords_projections','vect_projections','match2','matched_images');
        y = match2; % match2 is the comparaison between dots using both location and tangent vector
        coords = coords_projections;
        vect = vect_projections;
    end
    
    if nargin==2 && i==1
        fileNamesOUT=setdiff(matched_images,fileNamesIN);
    end
    % during the first iteration, set up the index list
    % matched_images is the list of file names that make up each XXXmatchedPoints.mat
    % file
    
    if i==1
        
        indIN=zeros(1,length(fileNamesIN));
        indOUT=zeros(1,length(fileNamesOUT));
        
        for j=1:length(fileNamesIN)
            indIN(j)=find(strcmp(fileNamesIN{j},matched_images));
        end
        
        for j=1:length(fileNamesOUT)
            indOUT(j)=find(strcmp(fileNamesOUT{j},matched_images));
        end
        
    end
    
    % y is a matrix in each XXXmatchedPoints.mat file where each dot is
    % described by a row. A one in a column mean that dot in the image matched
    % another dot in the image specified by the column.
    
    % remove the comparaison between the image and itself
    indIN_current=indIN([1:i-1 i+1:end]);
    
    yIN=double(y(:,indIN_current)); 
    yOUT=double(y(:,indOUT));
    n1=length(indIN_current);
    n2=length(indOUT);
    
    [m dummy]=size(yIN); 
    
    s{i}.MI=zeros(1,m,'single');
    
    
    t11=sum(yIN,2)/(n1+n2)+10^(-20);
    
    t01=n1/(n1+n2)-sum(yIN,2)/(n1+n2)+10^(-20);
    
    t10=sum(yOUT,2)/(n1+n2)+10^(-20);
    
    t00=n2/(n1+n2)-sum(yOUT,2)/(n1+n2)+10^(-20);
    
    s{i}.MI(:)=s{i}.MI(:)+(t11.*log2(t11./((t11+t10).*(t11+t01))));
    s{i}.MI(:)=s{i}.MI(:)+(t10.*log2(t10./((t11+t10).*(t10+t00))));
    s{i}.MI(:)=s{i}.MI(:)+(t01.*log2(t01./((t00+t01).*(t11+t01))));
    s{i}.MI(:)=s{i}.MI(:)+(t00.*log2(t00./((t00+t01).*(t10+t00))));
    
    s{i}.image = fileNamesIN{i};
    s{i}.y = uint8(y);
    s{i}.coords = single(coords);
    s{i}.vect = vect;
 
    
    clear y
    
end
