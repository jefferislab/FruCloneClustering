function test_suite = testCoords
% unit test for coord/pixel index conversion

initTestSuite;
  
% See http://www.mathworks.com/matlabcentral/fileexchange/22846-matlab-xunit-test-framework


% Assume that we will have a 7 pixel wide (X) x 6 pixel high (Y) image
% with voxel dimensions 0.5,0.4,1

function testc2i_origin
% 0,0,0 should correspond to index 1 
assertEqual(1,coord2ind([7 6 3], [0.5 0.4 1.0],[0;0;0]))

function testc2i_bottom_right
% 3,2,0 should correspond to index 7*6
assertEqual(7*6,coord2ind([7 6 3], [0.5 0.4 1.0],[3;2;0]))

function testc2i_bottom_right_with_null_axperm
% 3,2,0 should correspond to index 7*6
assertEqual(7*6,coord2ind([7 6 3], [0.5 0.4 1.0],[3;2.0;0],[1 2 3]))

function testc2i_round_trip
% arbitrary point on grid should survive round trip
orig_point=[2.5;1.2;0];
axperm=[1 2 3];
ind=coord2ind([7 6 3],[0.5 .4 1],orig_point,axperm);
new_point=ind2coord([7 6 3], ind, [0.5;0.4;1],axperm);
assertAlmostEqual(orig_point,new_point);

function testc2i_round_trip_with_origin
% arbitrary point on grid should survive round trip even with space origin
origin=[2;4;5.5];
orig_point=[2.5;1.2;0]+origin;
axperm=[1 2 3];
ind=coord2ind([7 6 3],[0.5 .4 1],orig_point,axperm,origin);
new_point=ind2coord([7 6 3], ind, [0.5;0.4;1],axperm,origin);
assertAlmostEqual(orig_point,new_point);

% axperm=[2 1 3]
% ind=coord2ind([6 7 3],[0.5 .4 1],orig_point,axperm,origin);
% new_point=ind2coord([6 7 3], ind, [0.5;0.4;1],axperm,origin);
% assertAlmostEqual(orig_point,new_point);


function testc2i_round_trip_off_grid
% arbitrary point off grid should NOT survive round trip
orig_point=[2.6;1.2;0];
ind=coord2ind([7 6 3],[0.5 .4 1],orig_point);
new_point=ind2coord([7 6 3], ind, [0.5;0.4;1]);
assertFalse(sum(abs(orig_point-new_point))<0.01);

function testi2c_origin
% origin (0,0,0) should correspond to position of voxel at index 1 
assertEqual([0;0;0],ind2coord([7 6 3],1,[0.5 0.4 1.0]));

function testi2c_non_zero_origin
% origin should correspond to position of voxel at index 1 
assertEqual([2;4;5.5],ind2coord([7 6 3],1,[0.5 0.4 1.0],[1 2 3],[2;4;5.5]));

function testi2c_additivity_origin
% point at given index should just be shifted by the position of the origin
origin=[2;4;5.5];
c1=ind2coord([7 6 3],50,[0.5 0.4 1.0],[1 2 3]);
c2=ind2coord([7 6 3],50,[0.5 0.4 1.0],[1 2 3],origin);
assertEqual(c1+origin,c2);

function testi2c_point
% test a specific index 
assertAlmostEqual([2;1.2;0], ind2coord([7 6 3],26,[0.5 0.4 1.0]))
assertAlmostEqual([2;1.2;1], ind2coord([7 6 3],26+42,[0.5 0.4 1.0]))

function testi2c_point_with_axperm
% use some data from a test nrrd
xvd = reshape([0.500000 0.400000 1.000000 ],[1  3]);
x = uint8(reshape([119 228 211 206 211 228 217 189 173 168 173 189 189 162 146 119 119 162 173 119 130 124 119 119 168 119 119 119 124 119 173 146 130 119 119 119 189 162 146 140 119 162 255 228 211 206 211 228 217 119 119 119 173 189 189 162 119 119 146 162 173 146 119 119 130 146 168 140 124 119 124 140 173 146 130 124 130 146 189 162 146 140 146 162 255 255 255 255 255 255 236 236 236 236 236 236 216 217 217 217 217 217 197 197 197 197 197 197 177 177 178 178 178 178 158 158 158 158 158 158 138 138 138 139 139 139 ],[6  7  3]));
assertAlmostEqual([1;0;2], ind2coord(x,find(x==216),xvd,[2 1 3]));

% now go the other way
assertEqual(find(x==216), coord2ind(x,xvd,[1;0;2],[2 1 3]));
% and test for a load of coords now
pixelseq119=find(x==119);
assertEqual(pixelseq119',coord2ind(x,xvd,ind2coord(x,pixelseq119,xvd,[2 1 3]),[2 1 3]));


