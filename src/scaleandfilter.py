#!/usr/bin/env python2
"""Script to rescale and filter confocal files (e.g. nrrd or pic)

Usage: fiji --headless scaleandfilter.py

Options:
  -x ..., --scalex=...	 scale factor in x
  -y ..., --scaley=...	 scale factor in y
  -z ..., --scalez=...	 scale factor in z
  -i ..., --in=...       input file
  -o ..., --out=...      output file
  -a ..., --anisofilter=... location of anisofilter binary

  -h, --help			 show this help
"""

__author__ = "Gregory Jefferis"
__copyright__ = "Copyright (c) 2010-12 Gregory Jefferis"
__license__ = "GPL >= v2"

import sys
import getopt
from ij import IJ, ImagePlus, ImageStack
from ij.io import Opener, FileSaver
from io import Nrrd_Writer
from ij.process import StackProcessor
if sys.version_info > (2, 4):
	import subprocess
import os
from features import TubenessProcessor

# nb soon script.imglib -> net.imglib2.script
from script.imglib import ImgLib
from script.imglib.algorithm import Scale3D

def scaleandfilter(infile,outfile,scalex,scaley,scalez,anisofilter):
	
	print ("infile is: "+infile)
	imp = Opener().openImage(infile)
	print imp
	print "scalex = %f; scaley = %f ; scalez = %f" % (scalex,scaley,scalez)
	
	# Rescale
	cal = imp.getCalibration()
	iml = ImgLib.wrap(imp)
	scaledimg = Scale3D(iml, scalex, scaley, scalez)
	imp2=ImgLib.wrap(scaledimg)
	
	# find range of pixel values for scaled image
	from mpicbg.imglib.algorithm.math import ComputeMinMax
	# (for imglib2 will be: net.imglib2.algorithm.stats)
	minmax=ComputeMinMax(scaledimg)
	minmax.process()
	(min,max)=(minmax.getMin().get(),minmax.getMax().get())
	# Make a copy of the stack (converting to 8 bit as we go)
	stack = ImageStack(imp2.width, imp2.height)
	print "min = %e, max =%e" % (min,max)
	for i in xrange(1, imp2.getNSlices()+1):
		imp2.setSliceWithoutUpdate(i)
		ip=imp2.getProcessor()
		# set range
		ip.setMinAndMax(min,max)
		stack.addSlice(str(i), ip.convertToByte(True))
	
	# save copy of calibration info
	cal=imp.getCalibration()
	# close original image
	imp.close()
	# make an image plus with the copy
	scaled = ImagePlus(imp2.title, stack)
	
	# Deal with calibration info which didn't seem to come along for the ride
	cal.pixelWidth/=scalex
	cal.pixelHeight/=scaley
	cal.pixelDepth/=scalez
	scaled.setCalibration(cal)
	print "dx = %f; dy=%f; dz=%f" % (cal.pixelWidth,cal.pixelHeight,cal.pixelDepth)
	
	intif=infile+".tif"
	outtif=infile+"-filtered.tif"
	if anisofilter.upper() != 'FALSE':
		print("saving input file as "+intif)
		f=FileSaver(scaled)
		f.saveAsTiffStack(intif)
		scaled.close()
		# anisotropic filtering
		anisopts="-scanrange:10 -tau:2 -nsteps:2 -lambda:0.1 -ipflag:0 -anicoeff1:1 -anicoeff2:0 -anicoeff3:0"
		anisopts=anisopts+" -dx:%f -dy:%f -dz:%f" % (cal.pixelWidth,cal.pixelHeight,cal.pixelDepth)

		if sys.version_info > (2, 4):
			#for testing
			# subprocess.check_call(["cp",intif,outtif])
			subprocess.check_call([anisofilter]+anisopts.split(' ')+[intif,outtif])
		else:
			os.system(" ".join([anisofilter]+anisopts.split(' ')+[intif,outtif]))
		# Open anisofilter output back into Fiji
		print("Opening output tif: "+outtif)
		imp = Opener().openImage(outtif)
		imp.setCalibration(cal)
	# Hessian (tubeness)
	print("Running tubeness")
	tp=TubenessProcessor(1.0,False)
	result = tp.generateImage(scaled)
	IJ.run(result, "8-bit","")
	# Save out file
	fileName, fileExtension = os.path.splitext(outfile)
	print("Saving as "+fileExtension+": "+outfile)
	if fileExtension.lower()=='.nrrd':
		nw=Nrrd_Writer()
		nw.setNrrdEncoding("gzip")
		nw.save(result,outfile)
	else:
		# Save to PIC
		IJ.run(result,"Biorad ...", "biorad=["+outfile+"]")
	imp.close()
	result.close()
	
def usage():
	print __doc__

def main(argv):

	# remove -batch argument which puts imagej into batch mode but is not
	# helpful here
	if argv.count('-batch') > 0:
		argv.remove('-batch')
	
	scalex=0.5
	scaley=0.5
	scalez=1.0
	infile=''
	outfile=''
	anisofilter='anisofilter'
	
	try:
		opts, args = getopt.getopt(argv, "hx:y:z:i:o:a:", 
		    ["help", "scalex=", "scaley=","scalez=","in=","out=","anisofilter="])
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
		elif opt in ("-z", "--scalez"):
			scalez = float(arg)
		elif opt in ("-i", "--in"):
			infile = arg
		elif opt in ("-o", "--out"):
			outfile = arg
		elif opt in ("-a", "--anisofilter"):
			anisofilter = arg
	
	scaleandfilter(infile,outfile,scalex,scaley,scalez,anisofilter)
	
if __name__ == "__main__":
	main(sys.argv[1:])
