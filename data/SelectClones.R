# R script to make a tab separated list of clones to be used in the paper
# by cleaning up an export from FileMaker

# 350 male brains that Nick used for analysis in the paper
massecfg=list(brains=
c("SAEM8", "SAGM18", "SAGO2", "SAGS12", "SAHS13", "SAHS9", "SAJR8", 
"SAJT12", "SAJV37", "SAKO6", "SABB5", "SAEG17", "SAJV25", "SAJV29", 
"SAJV42", "SAJV53", "SAJV55", "SAJV6", "SAEG2", "SAEH10", "SAEH9", 
"SAEM15", "SAHD16", "SAHM16", "SAHR6", "SAJT23", "SAJT42", "SAJV15", 
"SAJV54", "SAJY10", "SAKO11", "SAKR3", "SAKT1", "SAKW1", "SABB4", 
"SABL1", "SABL3", "SACP3", "SACT4", "SAGM15", "SAHS12", "SAJR10", 
"SAJT9", "SAJV11", "SAJV2", "SAKB10", "SAKO13", "SAKP12", "SAKP39", 
"SAKP44", "SAHN8", "SAKQ2", "SAKW21", "SAHC11", "SAHE15", "SAHM14", 
"SAJR1", "SAJV16", "SAJV22", "SAJV34", "SAJY8", "SAKB22", "SAKP16", 
"SADM1", "SADN6", "SAEH1", "SAEM24", "SAGS9", "SAHD6", "SAJT38", 
"SAJV26", "SAJV47", "SAJV59", "SAKB5", "SAKF18", "SAKP20", "SAKW13", 
"SAGO6", "SAHR2", "SAHS20", "SAKC11", "SAKR5", "SAGM14", "SAHF1", 
"SAHM9", "SAHS14", "SAJV10", "SAKB19", "SAKC5", "SAKP1", "SAKW12", 
"SABD1", "SAEH6", "SAHR15", "SAJT4", "SAJV33", "SAKC22", "SAEB7", 
"SAGM29", "SAHC16", "SAHD11", "SAHD12", "SAJT14", "SAJT24", "SAJT3", 
"SAJV45", "SAKO12", "SAKP37", "SAKU10", "SAKW22", "SACR28", "SACR8", 
"SADM6", "SAEL7", "SAGM19", "SAGO14", "SAGS16", "SAGS20", "SAGV19", 
"SAHC5", "SAHD17", "SAHP2", "SAHP6", "SAHS18", "SAJT1", "SAJT11", 
"SAJT26", "SAJT31", "SAJV12", "SAJV32", "SAJV41", "SAJV44", "SAJV56", 
"SAJV7", "SAJY14", "SAJY20", "SAKC29", "SAKP19", "SAKP45", "SAKQ24", 
"SAKR13", "SAKR6", "SAKU1", "SAKU12", "SAEB9", "SAHN2", "SAHS30", 
"SAJV14", "SAKR14", "SADN4", "SAEM5", "SAGM4", "SAGW20", "SAHR3", 
"SAJV3", "SAKC12", "SAEG15", "SAHP12", "SAKB6", "SAKV4", "SAGJ3", 
"SAGO13", "SAGS3", "SAKP7", "SAGV20", "SAJT27", "SAKC19", "SAJV20", 
"SAKU8", "SAEL23", "SAHS27", "SAKA5", "SAKC25", "SAKO3", "SAEB8", 
"SAEG6", "SAEH3", "SAGJ12", "SAGJ5", "SAJV5", "SAJV51", "SAJY2", 
"SAEH2", "SAGS23", "SAKA2", "SAKP27", "SAKT4", "SAGT5", "SAHC7", 
"SAHN14", "SAHS17", "SAJV13", "SAJV18", "SAJV43", "SAJY9", "SAKV8", 
"SAKA4", "SAEG11", "SAEG16", "SAGO1", "SAGW3", "SAHF6", "SAKB14", 
"SAKF8", "SAKP10", "SAGM22", "SAGW22", "SAHC13", "SAJV19", "SAJV46", 
"SAJV48", "SAKP18", "SACP10", "SAEB1", "SAEH8", "SAGO11", "SAHR16", 
"SAJT13", "SAJY12", "SAKC10", "SAGV6", "SAHP7", "SAJT29", "SAJT34", 
"SAKV3", "SAHP1", "SAKU4", "SAEL12", "SAHS10", "SAKW6", "SAHR9", 
"SAKB24", "SAKW20", "SAGO5", "SAKO19", "SABN2", "SAGM25", "SAGS5", 
"SAGT1", "SAHP10", "SAHP3", "SAHS2", "SAJQ13", "SAJT32", "SAJT40", 
"SAJV24", "SAJV31", "SAJV58", "SAJY4", "SAKB23", "SAKB4", "SAKB8", 
"SAKC20", "SAKF7", "SAKP13", "SAKP32", "SAKP5", "SAKQ10", "SAKQ4", 
"SAKU2", "SAKU5", "SAKU6", "SAKU9", "SAKW17", "SAKW2", "SAKW5", 
"SAKW9", "SAJV17", "SAKA6", "SAKC28", "SACM21", "SAGV12", "SAJV21", 
"SAKP17", "SACP7", "SAEG12", "SAGA1", "SAGW5", "SAHE23", "SAHR11", 
"SAJT8", "SAKP11", "SAKP31", "SAEB5", "SAGW11", "SAHP16", "SAHS25", 
"SAJT15", "SAJV1", "SAKA1", "SAKB15", "SAKB18", "SAKB26", "SAKP2", 
"SAKP3", "SAKP36", "SAKQ12", "SACR33", "SAEM11", "SAEB4", "SAEG14", 
"SAGO7", "SAHE17", "SAHP5", "SAKQ17", "SAKR4", "SAJT19", "SAKC9", 
"SAKP25", "SAGM8", "SAKF9", "SAKC3", "SAGM11", "SAGW4", "SACR2", 
"SAEH7", "SAJY3", "SAKP8", "SAKQ18", "SAKQ3", "SAGT11", "SAGV23", 
"SAHM4", "SAHS23", "SAKQ25", "SAGT7", "SAHM10", "SAKO2", "SAEG9", 
"SAGW17", "SAKC7", "SAKR2", "SAGJ13", "SAGM40", "SAJY1", "SAJT5", 
"SAKP4", "SAKQ7", "SAEM9", "SAGJ7", "SAEM4", "SAJY21", "SACR1", 
"SAKQ20", "SAGO12", "SAGT3", "SAGW14", "SAKQ16", "SAKP43", "SAKW7"),
clones=c("AL-a", "AL-b", "AL-c", "AL-d", "AL-e", "AL-i", "AL-j", "AL-k", 
"AL-m", "AL-o", "AL-p", "AL-PNs", "AL-q", "AL-r", "AL-s", "AL-t", 
"AL-w", "aSP1-a", "aSP2-a", "aSP2-b", "aSP2-c", "aSP3-a", "aSP3-c", 
"aSP3-d", "aSP3-e", "aSP3-g", "aSP3-i", "aSP3-k", "aSP3-n", "aSP3-q", 
"mAL-a", "mAL-PNs", "Mb", "mcAL-a", "mcAL-b", "mcAL-PNs", "P-a", 
"P-b", "P-d", "P-e", "P-f", "P-g", "P-h", "P-j", "P-k", "P-l", 
"P-m", "P-o", "P-p", "P-r", "P-s", "P-t", "P-u", "pSP1-a", "SG-a", 
"SG-b", "SG-d", "SG-e", "SG-f", "SG-h"))

# trick to find location of this script (which is in data directory)
massecfg$datadir=path.expand(dirname(attr(body(function() {}),'srcfile')$filename))

# This tab separated file was exported from the FileMaker Clones table
ClonesForNick=read.table(file.path(massecfg$datadir,'ClonesForNick.tab'),sep='\t')
names(ClonesForNick)=c("CloneType","Image","CloneSize")
ClonesForNick$Brain=sub("-.*$","",ClonesForNick$Image)
# Reorder columns
ClonesForNick=ClonesForNick[c("CloneType","Image","Brain","CloneSize")]

# only include brains and clones from v1 data
selected_clones=subset(ClonesForNick,Brain%in%massecfg$brains & CloneType%in%massecfg$clones)
write.table(selected_clones,
	file=file.path(massecfg$datadir,'SelectedClonesForNickv2.tab'),
	sep='\t',row.names=F,quote=FALSE)

# Seba and Aaron recommend removing P-h (this might be part of P-a) and adding AL-f
recommended_clones=c(setdiff(massecfg$clones,"P-h"),"AL-f")
selected_clones2=subset(ClonesForNick,Brain%in%massecfg$brains & 
	CloneType%in%recommended_clones)
write.table(selected_clones2,
	file=file.path(massecfg$datadir,'SelectedClonesForNickWithAL-f.tab'),
	sep='\t',row.names=F,quote=FALSE)
