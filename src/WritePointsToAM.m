function WritePointsToAM( outfile, points )
%WritePointsToAM Write 3D points to a text file that can be opened in Amira
% outfile - path to AmiraLandmarks output file
% points  - 3xN 3D points (
%           (NB 3xN is default matlab format. If points are Nx3, they will be transposed)

fid=fopen(outfile,'w');
fprintf(fid,'# AmiraMesh ASCII 1.0\n');

siz=size(points);
if siz(1)~=3
	if siz(2)==3
		disp('Warning - transposing points so that they are 3 x N)');
		points=points';
		nVertices=siz(1);
	else
		error('cannot interpret points as 3d coordinates');
	end
else
	nVertices=siz(2);
end

% write the header and then close the file
fprintf(fid,'define Markers %d\nParameters {\nContentType \"LandmarkSet\",\nNumSets 1\n}\n',nVertices);
fprintf(fid,'Markers { float[3] Coordinates } = @1\n\n');
fprintf(fid,'@1\n');
fclose(fid);

% Write the 3D coords (appending to the file containing the header)
dlmwrite(outfile,points','-append','delimiter',' ');

end
