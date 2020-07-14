# set the current working directory to the code folder
setwd("D:/JooGitRepo/CommonTool/HGNC_IDmapper/code")
source("D:/JooGitRepo/CommonTool/HGNC_IDmapper/code/module_mapperHGNC.R")


options(stringsAsFactors=F)
input = read.table("D:/JooGitRepo/CommonTool/HGNC_IDmapper/input/target.txt",sep="\t")
output = ID_mapper(input[,1],"symbol","entrez")
write.table(output,"D:/JooGitRepo/CommonTool/HGNC_IDmapper/output/output.txt",sep="\t",quote=F,row.names=F)