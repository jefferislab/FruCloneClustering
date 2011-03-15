function WritePointsToAM( outfile, points )
%WritePointsToAM Write 3D points to a text file that can be opened in Amira
%   Detailed explanation goes here

fid=fopen(outfile,'w');
fprintf(fid,'# AmiraMesh ASCII 1.0\n');

nVertices=length(points(:,1));
% write the header and then close the file
fprintf(fid,'define Markers %d\nParameters {\nContentType \"LandmarkSet\",\nNumSets 1\n}\n',nVertices);
fprintf(fid,'Markers { float[3] Coordinates } = @1\n\n');
fprintf(fid,'@1\n');


% Write the 3D coords (appending to the file containing the header)
dlmwrite(outfile,points,'-append','delimiter',' ');

fclose(fid);

end