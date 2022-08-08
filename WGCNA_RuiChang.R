library(WGCNA)


## By Rui Chang ##
WGCNA<-function(exp){
	print("Starting WGCNA RuiChang..")
	# exp: columns are features and rows are samples
	
	powers <- seq(1,20,by=0.5)
	WGCNAmodel = pickSoftThreshold(exp,powerVector=powers,corFnc="bicor",networkType="signed")

	## Draw a graph to find power matches R^2=0.85
        tableSFT<-WGCNAmodel[[2]]
	#plot(tableSFT[,1],tableSFT[,2],xlab="Power (Beta)",ylab="SFT R")
	## Decide the power number
	selectedPower = NA
	initialAttempt= 0.85
	while(is.na(selectedPower)){
		selectedPower = tableSFT[which(tableSFT[,2]>=initialAttempt)[1],1]
		initialAttempt = initialAttempt-0.05
	}
	print(paste("selectedPower:",selectedPower,"with R^2:",initialAttempt+0.05))

	
	## Run an automated network analysis
	net <- blockwiseModules(exp,power=selectedPower,deepSplit=4,minModuleSize=15,
				mergeCutHeight=0.25,
				corType="bicor",networkType="signed",pamStage=TRUE,pamRespectsDendro=TRUE,reassignThresh=0.05,
				verbose=3,saveTOMs=FALSE,maxBlockSize=10000)

	
	node = colnames(exp)
	module = cbind(node,net$colors)
	return(module)
}


outputModule<-function(module_info,outFolder){
  uniqueColor = unique(module_info[,2])
  for(i in 1:length(uniqueColor)){
    currentColor = uniqueColor[i]
    tmp_module = module_info[module_info[,2]==currentColor,1]
    #tmp_module = mapping[match(tmp_module,mapping[,1]),2]
    write.table(tmp_module,paste(outFolder,currentColor,".txt",sep=""),sep="\t",row.names=F,col.names=F,quote=F)
  }
}

