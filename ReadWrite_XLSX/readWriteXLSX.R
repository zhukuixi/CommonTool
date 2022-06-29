rm(list=ls())
options(java.parameters = "-Xmx8000m")

library("openxlsx")

############################################################################################################
wb <- loadWorkbook("Supplementary_TableS8.xlsx")
sheets <- names(wb)
for(i in 1:length(sheets)){
	enrich = read.xlsx("Supplementary_TableS8.xlsx",sheet = curTarget)
}
############################################################################################################

setwd("D:/Dropbox/TIME/2021/0328/Figure7_05182021/CPDBtermOverlap/INPUT")
options(stringsAsFactors = F)
network = read.table("combo_pairWiseSP_VGF_REST.txt",sep="\t")
network_node = unique(c(network[,1],network[,2]))

cpdb = read.table("CPDB_pathways_symbol.tab",sep="\t",header=T)
cpdb = cbind(cpdb,paste(cpdb[,1],cpdb[,2],sep="_"))

wb <- loadWorkbook("Supplementary_TableS8.xlsx")
sheets <- names(wb)

getPathOverlap<-function(input_row,netnode){
  members = strsplit(input_row,",")[[1]]
  overlap_members = intersect(members,netnode)
  return(c(paste(overlap_members,collapse=","),length(overlap_members)))
}

result=list()
for(i in 1:length(sheets)){
  curTarget = sheets[i]
  enrich = read.xlsx("Supplementary_TableS8.xlsx",sheet = curTarget)
  names = paste(enrich[,1],enrich[,2],sep="_")
  ind = match(names,cpdb[,5])
  overlap_member = lapply(cpdb[ind,4],getPathOverlap,network_node)
  df_overlap_member <- data.frame(matrix(unlist(overlap_member), nrow=length(overlap_member), byrow=TRUE))
  colnames(df_overlap_member) = c("overlap_member","overlap_size")
  enrich = cbind(enrich,df_overlap_member)
  result[[i]]=enrich
}

write.xlsx(result, file = "writeXLSX2.xlsx")



