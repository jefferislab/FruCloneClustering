function [nnidx, nndist] = ann_meta_wrapper (points, k, query, eps, ann_bin_dir)
% Meta wrapper for different methods of calling ANN nearest neighbours
%
% Usage: [nnidx, nndist] = ann_meta_wrapper (points, k, [query], [eps], [ann_bin_dir])
%
% Vars:
%     nnidx - indices of matching points:  (k)x(#points)
%     nndst - **square** distance of the points
%
%     points - data point(s): a (d)x(#points) matrix
%     k      - required k nearest neighbors
%     query  - query point(s): a (d)x(#points) matrix
%              pass empty matrix [] for self query
%     eps    - accuracy multiplicative factor
%     ann_bin_dir - directory containing ann_sample binary

% Uses Shai Bagon's code in matlab
%   http://www.wisdom.weizmann.ac.il/~bagon
% TODO: Will use octave-ann under octave
%   http://octave-swig.sourceforge.net/octave-ann.html
% falls back to using ann_sample from ann binary distribution

selfQuery = 0;

if nargin < 3 || isempty(query)
	selfQuery = 1;
end

if nargin < 4
	eps = 0.0;
end

if nargin < 5
	% FIXME what's a sensible default here?
	ann_bin_dir='';
end

isOctave = exist('OCTAVE_VERSION','builtin') ~= 0;

if ~isOctave && nargin < 5
	% Use Shai Bagon's code in Matlab
	anno=ann(points);
	% nb 4th param asm = 1 allows self matches

	if selfQuery
		[nnidx, nndist] = ksearch(anno,points,k,eps);
	else
		[nnidx, nndist] = ksearch(anno,query,k,eps);
	end
	anno = close(anno); %#ok<NASGU>

elseif isOctave && nargin < 5
	% Use Greg's new Octave annoctsearch function
	% which should have lower memory requirement than modified annmex
	if selfQuery
		[nnidx, nndist] = annoctsearch(points,points,k,eps);
	else
		[nnidx, nndist] = annoctsearch(points,query,k,eps);
	end
else
	% fall back to ann_sample tool
	[dim, npoints] = size(points);

	% set up output files
	tempstem = tempname;
	pointsfile = [tempstem ,'-ann-points.txt'];
	resultsfile = [tempstem,'-ann-results.txt'];
	points=points'; %#ok<NASGU>
	save(pointsfile,'points','-ascii');

	if(selfQuery)
		queryfile = pointsfile;
		nquery = npoints;
	else
		queryfile = [tempstem ,'-ann-query.txt'];
		save(queryfile,'query','-ascii');
		[dimignore, nquery] = size(query); %#ok<ASGLU>
	end


	command=[fullfile(ann_bin_dir,'ann_sample'), ...
		' -d ',num2str(dim),' -e ',num2str(eps),' -max ',num2str(npoints),...
		' -nn ',num2str(k),' -df ',pointsfile, ' -qf ',queryfile,...
		' > ',resultsfile];

	system(command);

	% read 3 columns of data from results file
	% organisation is as follows:
	% Query point: (182.702, 184.431, 11.4897)
	%     NN:	Index	Distance
	%     0     8       0
	%     1     114     0.0234169
	%     2     137     0.0301805

	[f2 f3]=textread(resultsfile,'%*s %s %s');

	% Find the first letter/digit of the second column
	numlines=length(f2);
	t=zeros(1,numlines,'single');
	for i=1:numlines
		t(i)=single(f2{i}(1));
	end

	% 73 is the numeric value of 'I' the first letter of Index
	% This will occur at the start of each block of nearest neighbour info
	ind=find(t==73);

	nnidx = zeros(k,nquery);
	nndist = zeros(k,nquery);

	for i=1:nquery % each query point
		for j=1:k % each of k neighbours for query point
			% note that ann is 0-indexed, but matlab 1-indexed
			nnidx(j,i) = str2double(f2{ind(i)+j})+1;
			nndist(j,i) = str2double(f3{ind(i)+j});
		end
	end

	delete(pointsfile);
	if ~selfQuery
		delete(queryfile);
	end
	delete(resultsfile);

end
