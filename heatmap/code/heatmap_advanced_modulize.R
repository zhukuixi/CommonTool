#Neuron Figure 2B heatmap
## Run in Rstudio
## https://davetang.org/muse/2018/05/15/making-a-heatmap-in-r-with-the-pheatmap-package/




drawHeatmapAdvanced<-function(covariateFile,residualFile,deFile,outputHeatmapAddress){
	library(pheatmap)
	library(gplots)


	## Get cov table
	## First column is sample
	## Second column is DX ("AD","Control")
	cur_covFile = covariateFile
	
	
	## Get residuals
	## row:DE
	## col:samples
	cur_residual = residualFile


	## Get DE
	cur_DE = deFile


	### Get AD CN sample

	sampleID = cur_covFile[which(cur_covFile$DX%in%c("AD","Control")),1]


	forDraw  = cur_residual[which(rownames(cur_residual)%in%cur_DE),which(colnames(cur_residual)%in%sampleID)]


	cal_minmax_score <- function(x){
	  (x - min(x)) / (max(x)-min(x))
	}

	forDraw_norm <- t(apply(forDraw, 1, cal_minmax_score))



	my_sample_col <- data.frame(sample=cur_covFile$DX[which(cur_covFile$SAMPLE%in%colnames(forDraw))])
	row.names(my_sample_col) <- colnames(forDraw)


 
	final_heatmap=pheatmap(forDraw_norm, annotation_col = my_sample_col,show_rownames=F,show_colnames=F,
		clustering_distance_cols = "correlation",
		clustering_distance_rows = "correlation",
		color = greenred(75)
		)

	save_pheatmap_png <- function(x, filename, width=12, height=10, res = 600) {
	  png(filename, width = width, height = height, res = res,units="in")
	  grid::grid.newpage()
	  grid::grid.draw(x$gtable)
	  dev.off()}
 
	save_pheatmap_png(final_heatmap, outputHeatmapAddress)

}

