
source("PathwayEnrichment.R")

# Read in pathway file
options(stringsAsFactors=F)
pathway = read.table("../supportFile/pathwayDatabase/CPDB_pathways_ensemble.tab",sep="\t",header=T)
pathway[,1]=paste(pathway[,1],pathway[,3],sep="_")
pathway[,2]=pathway[,4]
pathway = pathway[,c(1,2)]

# Read in input query file
input = read.table("../input/black.txt",sep="\t",header=T)
interest = input[,1]

# Do the enrichment and Output result
result=PathwayEnrichment(interest,NULL,pathway)
write.table(result,"../output/black1.txt",sep="\t",row.names=F,quote=F)



