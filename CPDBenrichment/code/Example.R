PathwayEnrichment <-function(interest,bg_input,mapping,pathway,needMapping){
	options(stringsAsFactors = FALSE)
	## input : one column vector
	
	## mapping : two column file
	## The first column got the same ID type as input
	## The second column got the ID type in the pathway

	## pathway: 2 columns file
	## 1st column:pathwayName
	## 2nd column:pathwayMembers separated by comma
	## Example:
	## PathwayA A,B,C,D,E,F
	
	## needMapping:Boolean variable indicating whether should perform ID convertion(mapping)
	
	## Get the background
	bg_all = c()
	if(bg_input==FALSE){bg_all=unique(unlist(strsplit(pathway[,2],",")))}
	else{bg_all=bg_input}
		
	if (needMapping){
		symbol = mapping[match(interest,mapping[,1]),2]
		symbol = symbol[!is.na(symbol)]
		interest = symbol
	}
	interest = unique(interest)
	interest = intersect(interest,bg_all)
	
	
	## Pathway Enrichment
	ans=c()
	for(j in 1:nrow(pathway)){
		path_name=pathway[j,1]
		path_member=strsplit(pathway[j,2],",")[[1]]
		path_member = intersect(path_member,bg_all)
		aa=length(intersect(interest,path_member))
		bb=sum(!path_member%in%interest)
		cc=sum(!interest%in%path_member)
		dd=sum(!bg_all%in%union(path_member,interest))
		model=fisher.test(matrix(c(aa,bb,cc,dd),2,2),alternative="greater")
		pvalue_bg=model$p.value		

		ans=rbind(ans,c(pathway[j,1],pvalue_bg))
	}
	fdr=p.adjust(as.numeric(ans[,2]),"fdr")
	ans=cbind(ans,fdr)
	colnames(ans)=c("pathway","pvalue","fdr")
	ans = ans[order(as.numeric(ans[,2])),]
	return(ans)
}







target_detail = read.table("F:/MountSinai_DataBackup/mssn/Micro_Neuron_MAYO/MP/9target_detail.txt",sep="\t")
enrichFolder = "F:/MountSinai_DataBackup/mssn/Micro_Neuron_MAYO/MP/enrichment_output/"
downstreamFolder = "F:/MountSinai_DataBackup/mssn/Micro_Neuron_MAYO/MP/downstream_output/"
netFolders = list.files(downstreamFolder)
pathway = read.table("F:/MountSinai_DataBackup/mssn/Micro_Neuron_MAYO/MP/CPDBenrichment/supportFile/CPDB_pathways_ensemble.tab",sep="\t",header=T)
pathway[,1]=paste(pathway[,1],pathway[,3],sep="_")
pathway[,2]=pathway[,4]
pathway = pathway[,c(1,2)]

for(i in 1:length(netFolders)){
	tmpOutFolder = paste(enrichFolder,netFolders[i],sep="")
	dir.create(tmpOutFolder,showWarnings =F)
	subnetFiles = list.files(paste(downstreamFolder,netFolders[i],sep=""))
	for(j in 1:length(subnetFiles)){
		tmpSubNet = read.table(paste(downstreamFolder,netFolders[i],"/",subnetFiles[j],sep=""),sep="\t")
		targetRealname = target_detail[match(strsplit(subnetFiles[j],"_")[[1]][1],target_detail[,2]),1]
		interest = tmpSubNet[,2]
		re=PathwayEnrichment(interest,FALSE,NULL,pathway,FALSE)
		write.table(re,paste(tmpOutFolder,targetRealname,".txt",sep=""),sep="\t",row.names=F,quote=F)
	}
}



