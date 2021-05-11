KDA_Folder = "D:/work/BuildNetwork/scRNAseq/BN/KDA/KDA_summary/"

countPositive<-function(input){
	return(length(which(input>0)))
}
countCrossFun<-function(input){
	ans=any(input[1:3]>0)+any(input[4:6]>0)
	return(ans)
}

answer=c()
cur_table=read.table(paste(KDA_Folder,"summary.txt",sep=""),header=T,sep="\t",row.names=1)
colnames(cur_table)=c("pureDE_Astro06","GeneModule_Astro06","DE_GeneModule_Astro06",
		"pureDE_Micro06","GeneModule_Micro06","DE_GeneModule_Micro06")
cur_table=as.matrix(cur_table)
CrossCount=apply(cur_table,1,countCrossFun)
PosCount=apply(cur_table,1,countPositive)	
rowSumCount=apply(cur_table,1,sum)


cur_table=cbind(cur_table,CrossCount)
cur_table=cbind(cur_table,PosCount)
cur_table=cbind(cur_table,rowSumCount)

sort_cur_table=cur_table[order(AppearCount,PosCount,rowSumCount,decreasing=T),]	


write.table(answer,paste(KDA_Folder,"SORT_summary.txt",sep=""),sep="\t",quote=F)




