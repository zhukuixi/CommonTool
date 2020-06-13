
options(stringsAsFactors = FALSE)



MAYO_ENO2_ModuleFolder= "/input/MAYO_ENO2/"


mapping=read.table("/supportFile/hgnc_symbol_ensemble.txt",sep="\t",header=T)



cpdb=read.table("/supportFile/CPDB_pathways_genes.tab",sep="\t",header=T)
bgs=unique(cpdb[,3])
bg_all=c()
for(i in 1:length(bgs)){
	cur_bg=bgs[i]
	ind=which(cpdb[,3]==cur_bg)
	members=cpdb[ind,4]
	members_array=paste(members,collapse=",")
	bg_member=unique(strsplit(members_array,",")[[1]])
	bg_all=c(bg_all,bg_member)
	assign(paste("bg_",cur_bg,sep=""),bg_member)

}
bg_all=unique(bg_all)





target = c("MAYO_ENO2")
outFolder="/output/"

for(i in 1:length(target)){
	setwd(get(paste(target[i],"_ModuleFolder",sep="")))
	modules = list.files()
	for(k in 1:length(modules)){
		## Here we ignore grey module.
		if(modules[k]=="grey.txt"){
			next
		}
		interest = read.table(modules[k],sep="\t")
		symbol = mapping[match(interest[,1],mapping[,2]),1]
		symbol = symbol[!is.na(symbol)]
		interest = intersect(symbol,bg_all)
		
		ans=c()
		for(j in 1:nrow(cpdb)){
			path_name=cpdb[j,1]
			path_source=cpdb[j,3]
			path_member=strsplit(cpdb[j,4],",")[[1]]

			path_bg=bg_all
			aa=length(intersect(interest,path_member))
			bb=sum(!path_member%in%interest)
			cc=sum(!interest%in%path_member)
			dd=sum(!path_bg%in%union(path_member,interest))
			model=fisher.test(matrix(c(aa,bb,cc,dd),2,2),alternative="greater")
			pvalue_bg=model$p.value		

			ans=rbind(ans,c(cpdb[j,1:3],pvalue_bg))
		}
		fdr=p.adjust(as.numeric(ans[,4]),"fdr")
		ans=cbind(ans,fdr)
		colnames(ans)=c("pathway","external_id","source","pvalue","fdr")
		ans = ans[order(as.numeric(ans[,4])),]
			
		write.table(ans,paste(outFolder,target[i],"/",modules[k],sep=""),quote=FALSE,sep="\t")
	
	}
}








