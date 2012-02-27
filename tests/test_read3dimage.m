function test_suite = testCoords
% unit test for reading 3d image

initTestSuite;

function test_nrrd
filename=which('7x6x3-neworigin.nhdr');
if ~isempty(filename)
	[x,voxdims,origin] = read3dimage(filename);
	assertEqual(voxdims, [0.5 0.4 1.0])
	assertEqual(origin, [10 20 15])
end

function test_pic
filename=which('7x6x3-origin.PIC');
if ~isempty(filename)
	[x,voxdims,origin] = read3dimage(filename);
	assertEqual(voxdims, [0.5 0.4 1.0])
	assertEqual(origin, [0 0 0])
end