#!/usr/bin/env python2
"""Script to rescale and filter biorad PIC file

Usage: fiji --headless scaleandfilter.py

Options:
  -x ..., --scalex=...	 scale factor in x
  -y ..., --scaley=...	 scale factor in y
  -i ..., --in=...       input file
  -o ..., --out=...      output file

  -h, --help			 show this help
"""

__author__ = "Gregory Jefferis"
__copyright__ = "Copyright (c) 2010 Gregory Jefferis"
__license__ = "GPL >= v2"

import sys
import getopt
from ij import *
from ij.io import *
from ij.process import *
if sys.version_info > (2, 4):
	import subprocess
import os

def scaleandfilter(infile,outfile,scalex,scaley):
	
	# This form works in the Interpreter but not from command line
	# imp = Opener().openImage("/Volumes/JData/JPeople/Nick/FruCloneClustering/images/SAAG7-1_02.pic")
	print ("infile is: "+infile)
	IJ.run("Biorad...", "open=["+infile+"]")
	imp = IJ.getImage()
	
	print "scalex = %f; scaley = %f" % (scalex,scaley)
	# Rescale
	ip = imp.getProcessor()
	ip.setInterpolate(True)
	sp = StackProcessor(imp.getStack(),ip);
	sp2=sp.resize(int(round(ip.width * scalex)), int(round(ip.height *scaley)));
	imp.setStack(sp2);
	
	cal = imp.getCalibration()
	cal.pixelWidth /= scalex
	cal.pixelHeight /= scaley

	IJ.run(imp, "8-bit","")
	
	intif=infile+".tif"
	outtif=infile+"-filtered.tif"
	print("saving input file as "+intif)
	IJ.saveAs("tiff",intif)
	imp.close()

	# anisotropic filtering
	anisopts="-scanrange:10 -tau:2 -nsteps:2 -lambda:0.1 -ipflag:0 -anicoeff1:1 -anicoeff2:0 -anicoeff3:0"
	anisopts=anisopts+" -dx:%f -dy:%f -dz:%f" % (cal.pixelWidth,cal.pixelHeight,cal.pixelDepth)
	
	if sys.version_info > (2, 4):
		subprocess.check_call(["anisofilter"]+anisopts.split(' ')+[intif,outtif])
	else:
		os.system(" ".join(["anisofilter"]+anisopts.split(' ')+[intif,outtif]))
	
	#for testing
	# subprocess.check_call(["cp",intif,outtif])

	# Hessian (tubeness)
	print("Opening output tif: "+outtif)
	imp = Opener().openImage(outtif)
	imp.setCalibration(cal)
	print("Running tubeness on tif: "+outtif)
	IJ.run(imp,"Tubeness", "sigma=1")
	IJ.run(imp, "8-bit","")

	# Save to PIC
	print("Saving as PIC: "+outfile)
	# IJ.saveAs("tiff","outtif")
	IJ.run(imp,"Biorad ...", "biorad="+outfile)
	
def usage():
	print __doc__

def main(argv):

	scalex=0.5
	scaley=0.5
	infile=''
	outfile=''
	
	try:
		opts, args = getopt.getopt(argv, "hx:y:i:o:", ["help", "scalex=", "scaley=","in=","out="])
	except getopt.GetoptError:
		usage()
		sys.exit(2)
	for opt, arg in opts:
		if opt in ("-h", "--help"):
			usage()
			sys.exit()
		elif opt in ("-x", "--scalex"):
			scalex = float(arg)
		elif opt in ("-y", "--scaley"):
			scaley = float(arg)
		elif opt in ("-i", "--in"):
			infile = arg
		elif opt in ("-o", "--out"):
			outfile = arg
	
	scaleandfilter(infile,outfile,scalex,scaley)
	
if __name__ == "__main__":
	#main(['-i/Test.PIC','-o Test-out.PIC','-x 0.5','-y 0.5'])
	main(sys.argv[1:-1])