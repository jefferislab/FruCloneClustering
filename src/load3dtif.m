function img = load3dtif(infile)
% LOAD3DTIF Loads 3d tif by loading each 2d plane into a 3d matrix
% TODO: Check ordering of x,y axes given matlab vs image processing
% coordinate conventions
%
% See also IMREAD, IMFINFO
inf=imfinfo(infile);
if ~isstruct(inf)
	error('Unable to parse tif: %s',infile);
end

img=zeros(inf(1).Width,inf(1).Height,length(inf));
for j=1:length(inf)
	img(:,:,j)=imread(infile,j);
end
end
