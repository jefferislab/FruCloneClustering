//infile="/Volumes/JData/JPeople/Nick/FruCloneClustering/images/SAAG7-1_02.pic";
//outfile=""
//Open Image
var imp = new Opener().openImage(infile);
// Rescale
ip = imp.getProcessor();
ip.setInterpolate(true);
var sp = new StackProcessor(imp.getStack(),ip);
var sp2=sp.resize(ip.width / 2, ip.height / 2);
imp.setStack(sp2);
// Don't forget to change voxel size
var cal = imp.getCalibration();
cal.pixelWidth *= 2;
cal.pixelHeight *= 2;

IJ.run(imp, "8-bit", "");
IJ.run(imp,"Biorad ...", "biorad=["+outfile+"]");