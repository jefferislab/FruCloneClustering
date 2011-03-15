img = getArgument;
if (img=="") exit ("No argument!");
open(img);
getVoxelSize(xp,yp,zp,unit);
intif=img+".tif";
outtif=img+"-filtered.tif";
print("saving input file as "+intif);
saveAs("Tiff", intif);
anisopts="-scanrange:10 -tau:2 -nsteps:2 -lambda:0.1 -ipflag:0 -anicoeff1:1 -anicoeff2:0 -anicoeff3:0";
anisopts=anisopts+" -dx:"+xp+" -dy:"+yp+" -dz:"+zp;
anisocmd="anisofilter "+anisopts+" "+intif+" "+outtif;
print("Running command: "+anisocmd);

//exec("sh","-c", anisocmd);
// for testing
exec("sh","-c", "cp "+intif+" "+outtif);

print("Opening output tif: "+outtif);

open(outtif);
setVoxelSize(xp,yp,zp,unit);
print("Running tubeness on tif: "+outtif);

run("Tubeness", "sigma=1");
run("8-bit");
print("Saving as PIC: "+img+"filtered.PIC");
run("Biorad ...", "biorad=["+img+"filtered.PIC]");