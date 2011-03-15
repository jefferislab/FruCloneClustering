# Script to preprocess a directory of images 
NickImagesDir="/Volumes/JData/JPeople/Nick/FruCloneClustering/images"
NickProcessedImagesDir="/Volumes/JData/JPeople/Nick/FruCloneClustering/preprocessed"

# - Downsample (factor of 2 xy)
# - Filter (anisofilter, doesn't yet work on cluster)
# - Tubeness (Fiji)
# - Threshold (matlab, but trivial)
# - Connected clusters (matlab image processing) Could modify Fiji "Find

PreprocessImage<-function(infile,outfile,Verbose=TRUE,DryRun=FALSE,RemoveIntermediates=TRUE){
	if(missing(outfile)) outfile=paste(infile,sep="",".4xd-tubed.PIC")
	# Verbose reporting
	if(Verbose) cat("about to process image:",infile,"\n")
	macro=character()
	# open file
	macro=c(macro,paste('open("',infile,'");',sep=""))
	# resample, 8 bit, save as tiff
	resampledfile=file.path(dirname(infile),paste(basename(infile),sep="",".4xd.tif"))
	macro=c(macro,paste('run("Scale...", "x=0.5 y=0.5 z=1.0 interpolation=Bicubic process title=Scaled");',sep=""))
	# Make sure that we select the right window
	macro=c(macro,'selectWindow("Scaled");')
	macro=c(macro,'run("8-bit");')
	# store current voxel size
	macro=c(macro,'getVoxelSize(xp,yp,zp,unit);')
	macro=c(macro,paste('saveAs("Tiff", "',resampledfile,'");',sep=""))
	# run anisofilter
	filteredResampledfile=paste(basename(infile),sep="",".4xd-filtered.tif")
	anisoOptions="-scanrange:10 -tau:2 -nsteps:2 -lambda:0.1 -ipflag:0 -anicoeff1:1 -anicoeff2:0 -anicoeff3:0"
	macro=c(macro,paste('exec("sh","-c",',paste('"cd ',dirname(infile),'; anisofilter ',anisoOptions," ",
		basename(resampledfile)," ",filteredResampledfile,'");',sep="")))
	# open the result
	macro=c(macro,paste('open("',file.path(dirname(infile),filteredResampledfile),'");',sep=""))
	# fix voxel size
	macro=c(macro,'setVoxelSize(xp,yp,zp,unit);')
	# calculate tubeness assuming isotropic voxels and smoothing with sigma = pixel separation
	macro=c(macro,'run("Tubeness", "sigma=1");')
	# this makes float output, so change to 8 bit
	macro=c(macro,'run("8-bit");')
	# save as Biorad PIC file for matlab to open
	macro=c(macro,paste('run("Biorad ...", "biorad=[',outfile,']");',sep=""))
	
	tmp=paste(tempfile(),sep=".","ijm")
	cat(paste(macro,collapse="\n"),file=tmp)
	command=paste("fiji -eval \'runMacro(\"",tmp,"\");\' -batch",sep="")
	if(DryRun)
		return(command)
	system(command)
	unlink(tmp)
	if(RemoveIntermediates)
		unlink(c(resampledfile,filteredResampledfile))

	if(!Verbose) cat("+")
}

images=dir(NickImagesDir,patt="02\\.(pic|PIC)+(\\.gz)*$",full=T)
for(i in images){
	# final output file
	tubenessFile=file.path(NickProcessedImagesDir,paste(basename(i),sep="",".4xd-tubed.PIC"))
	
	# print(paste('name of the output file:',tubenessFile,sep=' '))
	lockfile=paste(i,sep=".","lock")
	if(!(RunCmdForNewerInput(NULL,i,tubenessFile) && makelock(lockfile))){
		cat(".")
		next
	}
	PreprocessImage(i,tubenessFile)
	unlink(lockfile)
}
