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

function testc2i_round_trip
% arbitrary point on grid should survive round trip
orig_point=[2.5;1.2;0];
ind=coord2ind([7 6 3],[0.5 .4 1],orig_point);
new_point=ind2coord([7 6 3], ind, [0.5;0.4;1]);
assertAlmostEqual(orig_point,new_point);

function testc2i_round_trip_off_grid
% arbitrary point off grid should NOT survive round trip
orig_point=[2.6;1.2;0];
ind=coord2ind([7 6 3],[0.5 .4 1],orig_point);
new_point=ind2coord([7 6 3], ind, [0.5;0.4;1]);
assertFalse(sum(abs(orig_point-new_point))<0.01);

function testi2c_origin
% origin (0,0,0) should correspond to position of voxel at index 1 
assertEqual([0;0;0],ind2coord([7 6 3],1,[0.5 0.4 1.0]));
