library(WGCNA)


WGCNA<-function(exp){
  
  powers = c(c(1:10), seq(from = 12, to=20, by=2))
  
  ################################################
  # Call the network topology analysis function
  # 最佳的beta值就是sft$powerEstimate
  ################################################
  
  sft = pickSoftThreshold(exp, powerVector = powers, verbose = 5)
  
  ########################
  ## co-expression matrix
  ########################
  net = blockwiseModules(
    exp,
    power = sft$powerEstimate,
    maxBlockSize = 6000,
    TOMType = "unsigned", minModuleSize = 30,
    reassignThreshold = 0, mergeCutHeight = 0.25,
    numericLabels = TRUE, pamRespectsDendro = FALSE,
    saveTOMs = FALSE,
    saveTOMFileBase = "AS-green-FPKM-TOM",
    verbose = 3
  )
  table(net$colors)
  
  # Convert labels to colors for plotting
  mergedColors = labels2colors(net$colors)
  # Plot the dendrogram and the module colors underneath
  plotDendroAndColors(net$dendrograms[[1]], mergedColors[net$blockGenes[[1]]],
                      "Module colors",
                      dendroLabels = FALSE, hang = 0.03,
                      addGuide = TRUE, guideHang = 0.05)
  ## assign all of the gene to their corresponding module 
  ## hclust for the genes.
  
  ########################
  ## export modules
  ########################
  moduleColors <- labels2colors(net$colors)
  
  module = cbind(colnames(exp),moduleColors)
  return(module)
}

outputModule<-function(module_info,outFolder){
  uniqueColor = unique(module_info[,2])
  for(i in 1:length(uniqueColor)){
    currentColor = uniqueColor[i]
    tmp_module = module_info[module_info[,2]==currentColor,1]
    tmp_module = mapping[match(tmp_module,mapping[,1]),2]
    write.table(tmp_module,paste(outFolder,currentColor,".txt",sep=""),sep="\t",row.names=F,col.names=F,quote=F)
  }
}


#######################################################################
#######################################################################

datacont_Folder = "D:/work/BuildNetwork/scRNAseq/BN/exp/cont/"
otherInput_Folder = "D:/work/BuildNetwork/scRNAseq/BN/otherInput/"
setwd(datacont_Folder)
exp_micro = read.table("micro_5k.txt",sep="\t")
exp_astro = read.table("astro_5k.txt",sep="\t")
setwd(otherInput_Folder)
node_micro = read.table("node_micro_5k.txt",sep="\t")
node_astro = read.table("node_astro_5k.txt",sep="\t")

colnames(exp_micro) = node_micro[,1]
colnames(exp_astro) = node_astro[,1]


module_micro = WGCNA(exp_micro)
module_astro = WGCNA(exp_astro)

setwd("D:/work/BuildNetwork/scRNAseq/BN/KDA/target/module/")
mapping = read.table("D:/work/BuildNetwork/scRNAseq/mouse_mapping.txt",sep="\t")
## micro
dir.create("micro")
outputModule(module_micro,"D:/work/BuildNetwork/scRNAseq/BN/KDA/target/module/micro/")

## astro
dir.create("astro")
outputModule(module_astro,"D:/work/BuildNetwork/scRNAseq/BN/KDA/target/module/astro/")

