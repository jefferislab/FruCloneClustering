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
