#https://biocorecrg.github.io/CRG_RIntroduction/volcano-plots.html

setwd("D:/Dropbox/TIME/1005/Volcano")
target = read.table("target.txt",sep="\t")
library("openxlsx")
library(ggplot2)
sheetName = openxlsx::getSheetNames("TRACY_Chang_RNAseq_shRNA_Alldata.xlsx")

getFix<-function(name){
	return(strsplit(name,">|<")[[1]][2])
}

for(i in 1:length(sheetName)){
	curName = sheetName[i]
	data <- read.xlsx("TRACY_Chang_RNAseq_shRNA_Alldata.xlsx", sheet = i, startRow = 1, colNames = TRUE)
	ind=which(grepl("^>|^<",data$q.value))
	data$q.value[ind] = unlist(lapply(data$q.value[ind],getFix))
	data$q.value = as.numeric(data$q.value)
	
	data$negativeQvalue = -log10(data$q.value)
	
	xlimMax=max(abs(range(data$Difference)))
	ylimMax=max(data$negativeQvalue)
	redIndex = which(data$q.value<0.05 & data$X1%in%target[,1])
	
	data$BlackRed = "black"
	data$BlackRed[redIndex]="red"
	data$delabel = NA
	data$delabel[redIndex] = data$X1[redIndex]
	
	data$pointalpha = 0.2
	data$pointalpha[redIndex] = 1
	
	library(ggrepel)
	# plot adding up all layers we have seen so far
	ggplot(data=data, aes(x=Difference, y=negativeQvalue, col=BlackRed,alpha=pointalpha, label=delabel)) +
        geom_point() + 
        theme_minimal() + xlab("Difference")+ ylab("-log10(q value)")+
        geom_text_repel(size=9) +xlim(-xlimMax, xlimMax)+
       scale_color_manual(values=c("black", "red"))+
        geom_hline(yintercept=0, col="black") +
        geom_hline(yintercept=-log10(0.05), col="black",linetype="longdash",size=2)+theme(legend.position = "none") +        
        ggtitle(curName) +
	theme(plot.title = element_text(hjust = 0.5,face="bold",size=35))
	ggsave(paste(curName,".png",sep=""),width = 20, height = 20, units = "cm")
	}



