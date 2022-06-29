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





