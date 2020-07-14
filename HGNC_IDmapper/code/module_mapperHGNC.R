## Currently available columns for ID mapping:
## You can visit https://www.genenames.org/download/custom/ to check the meaning of each columns.
#"HGNC ID"                         "Approved symbol"                 "Approved name"                  
#"Status"                          "Previous symbols"                "Alias symbols"                  
#"Chromosome"                      "RefSeq IDs"                      "OMIM ID(supplied by OMIM)"      
#"UniProt ID(supplied by UniProt)" "NCBI Gene ID"                    "Ensembl gene ID"                
#"Enzyme IDs"


# You can ignore this block. If you are using a new HGNC table, you have to generate the new helper file correspondly.
# Generate helper table
# alias_ind_match = c()
#for(i in 1:nrow(hgnc)){
#	names = hgnc[i,c("Previous symbols","Alias symbols")]
#	names = paste(names,collapse=", ")
#	names = strsplit(names,", ")[[1]]
#	names = names[names!=""]
#	if(length(names)!=0){
#		content = cbind(names,i)
#		alias_ind_match = rbind(alias_ind_match, content)
#	}
#}
#colnames(alias_ind_match)=c("alias_previous_symbol","index")
#write.table(alias_ind_match,"aliasPreviousSymbol_ind.txt",quote=F,sep="\t",row.names=F)



## read in two helper file
hgnc = read.table("./HGNC_2020.txt",sep="\t",header=T,fill=TRUE,check.names=F,quote="")
alias_ind_match = read.table("./aliasPreviousSymbol_ind.txt",sep="\t",header=T,quote="")


ID_mapper<-function(input_sourceID,input_sourceIDtype,input_targetIDtype){
	# input_sourceID : A string.The source ID you input.
	# input_sourceIDtype: A string : "symbol","entrez","ensemble","uniport". You can also use any headers in hgnc table.
	# input_targetIDtype: A string : "symbol","entrez","ensemble","uniport". You can also use any headers in hgnc table.
	# keepMismatch: A boolean. Whether or not you want to show those original soureceIDs when they
	# 		     failed mapping to targetIDtype.

	getIDtype<-function(inputType){
		if(inputType=="symbol"){
			return("Approved symbol")
		}else if(inputType=="entrez"){
			return("NCBI Gene ID")
		}else if(inputType=="ensemble"){
			return("Ensembl gene ID")
		}else if(inputType=="uniport"){
			return("UniProt ID(supplied by UniProt)")
		}else{
			return(inputType)
		}
	}
	getMatchForSymbol <- function(input_symbol){
		## Try "Approved symbol" first
		match_ind = match(input_symbol,hgnc[,"Approved symbol"])
		
		## If no match , try "Previous symbols" and "Alias symbols"
		if(!is.na(match_ind)){
			return(match_ind)
		}else{
			match_ind = as.numeric(alias_ind_match[which(alias_ind_match[,1]==input_symbol),2])
			return(match_ind)
		}
	}

	sourceIDtype = getIDtype(input_sourceIDtype)
	targetIDtype= getIDtype(input_targetIDtype)
	match_ind = c()
	if(sourceIDtype == "Approved symbol"){
		match_ind_list = lapply(input_sourceID,getMatchForSymbol )
		ans = c()
		for(i in 1:length(match_ind_list)){
			cur_match_ind = match_ind_list[[i]]
			if(length(cur_match_ind)==0){
				cur_mappedID = ""
			}else{
				cur_mappedID = hgnc[cur_match_ind,targetIDtype]
			}
			ans = rbind(ans,cbind(input_sourceID[i],cur_mappedID))
		}

	}else{
		ans=c()
		match_ind= match(input_sourceID,hgnc[,sourceIDtype])
		mappedID = hgnc[match_ind,targetIDtype]
		ans = cbind(input_sourceID,mappedID )
	}
	
	## replacing the NA mapped IDs with ""
	ind_na = which(is.na(ans[,2]))
	ans[ind_na,2] = ""	
	colnames(ans) = c(input_sourceIDtype,input_targetIDtype)
	return(ans)

}


