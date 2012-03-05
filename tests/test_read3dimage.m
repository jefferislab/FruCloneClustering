function test_suite = read3dimage
% unit test for reading 3d image

initTestSuite;

function test_nrrd
nrrdiodir=fileparts(which('isnrrd'));
if ~isempty(nrrdiodir)
	filename=fullfile(nrrdiodir,'tests','7x6x3-neworigin.nhdr');
	[x,voxdims,origin] = read3dimage(filename);
	assertEqual(voxdims, [0.5 0.4 1.0]);
	assertEqual(origin, [10 20 15]);
else
	warning('unable to locate 7x6x3-neworigin.nhdr for test');
end

function test_pic
filename=which('7x6x3-origin.PIC');
if ~isempty(filename)
	[x,voxdims,origin] = read3dimage(filename);
	assertEqual(voxdims, [0.5 0.4 1.0]);
	assertEqual(origin, [0 0 0]);
else
	warning('unable to locate 7x6x3-origin.PIC for test');
end