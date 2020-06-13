#Neuron Figure 2B heatmap
## Run in Rstudio
## https://davetang.org/muse/2018/05/15/making-a-heatmap-in-r-with-the-pheatmap-package/

library(pheatmap)
library(gplots)


## Get cov table
mayo_cov=read.table("/input/AMP-AD_MayoPrivate_RNAseq.QCed.TCX.covariates.tab",sep="\t",header=T)


## Get residuals
load("/input/MayoPrivateCQN_CellTypeSpecific_residuals_lmFit-BatchSourceRinSexExonicrateAgeAtDeathNumCelltypemarkers_residualsPerCellType_ENO2.RData")
mayo_exp=resid.ENO2


## Get DE
mayo_DE = read.table("/input/MayoPrivateCQN_CellTypeSpecific_residuals_lmFit-BatchSourceRinSexExonicrateAgeAtDeathNumCelltypemarkers_residualsPerCellType_DE-AD-Control_ENO2_geneIDsPAdj0.05.txt",sep="\t")



### Get AD CN sample

mayo_sample = mayo_cov[which(mayo_cov$Diagnosis%in%c("AD","Control")),1]


mayo_forDraw  = mayo_exp[which(rownames(mayo_exp)%in%mayo_DE[,1]),which(colnames(mayo_exp)%in%mayo_sample)]


cal_z_score <- function(x){
  (x - mean(x)) / sd(x)
}
 
mayo_norm <- t(apply(mayo_forDraw, 1, cal_z_score))



my_sample_col <- data.frame(sample=mayo_cov$Diagnosis[which(mayo_cov$Diagnosis%in%c("AD","Control"))])
row.names(my_sample_col) <- colnames(mayo_forDraw)
 

 
mayo_heatmap=pheatmap(mayo_norm, annotation_col = my_sample_col,show_rownames=F,show_colnames=F,
		clustering_distance_cols = "correlation",
		clustering_distance_rows = "correlation",
		color = greenred(75)
		)

save_pheatmap_png <- function(x, filename, width=12, height=10, res = 600) {
  png(filename, width = width, height = height, res = res,units="in",)
  grid::grid.newpage()
  grid::grid.draw(x$gtable)
  dev.off()
}
 
save_pheatmap_png(/output/mayo_heatmap, "mayo_heatmap.png")

