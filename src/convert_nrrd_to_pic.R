# Convert a directory of nrrds to pics 
cmdargs=commandArgs(trailingOnly=TRUE)
print(cmdargs)

if(length(cmdargs)!=1) {
	warning("Using default input and output directories")
	# Script to preprocess a directory of images 
	NickImagesDir="/Volumes/JData/JPeople/Nick/FruCloneClustering/Reformated_images"
} else {
	NickImagesDir=cmdargs[[1]]
}
cat(NickImagesDir,"\n")

ConvertNrrdToPic<-function(infile,outfile,Verbose=TRUE,DryRun=FALSE,RemoveIntermediates=TRUE){
	if(missing(outfile)) outfile=sub("nrrd$","pic",infile)
	# Verbose reporting
	if(Verbose) cat("about to process image:",infile,"\n")
	macro=character()
	# open file
	macro=c(macro,paste('open("',infile,'");',sep=""))
	# resample, 8 bit, save as pic
		
	macro=c(macro,paste('run("Biorad ...", "biorad=[',outfile,']");',sep=""))

	tmp=paste(tempfile(),sep=".","ijm")
	cat(paste(macro,collapse="\n"),file=tmp)
	command=paste("fiji --headless -eval \'runMacro(\"",tmp,"\");\' -batch",sep="")
	if(DryRun)
		return(command)
	system(command)
	unlink(tmp)
	
	if(!Verbose) cat("+")
}
# debug(ConvertNrrdToPic)
images=dir(NickImagesDir,patt="02\\.(nrrd|NRRD)+(\\.gz)*$",full=T)
for(i in images){
	# final output file
	picfile=file.path(dirname(i),paste(sub("nrrd$","pic",basename(i))))
	
	# print(paste('name of the output file:',picfile,sep=' '))
	lockfile=paste(i,sep=".","lock")
	if(!(RunCmdForNewerInput(NULL,i,picfile) && makelock(lockfile))){
		cat(".")
		next
	}
	ConvertNrrdToPic(i,picfile)
	unlink(lockfile)
}
