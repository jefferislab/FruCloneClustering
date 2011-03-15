function [counts, bins] = pichist ( picfile )
%PICHIST Returns a histogram of values in a biorad pic file
%   Assumes that the image is 8 bit

counts=[];
bins=[];
inf=impicinfo(picfile);

if isempty(inf), return, end

if inf.BitDepth~=8
	warning('Unsupported bitdepth %s',inf.BitDepth);
	return
end

x=readpic(picfile);

[counts,bins]=hist(x(:),0:255);

end
