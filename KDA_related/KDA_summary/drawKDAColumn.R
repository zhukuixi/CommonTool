############################## OVERLAP ################

KDA_Folder = "D:/work/BuildNetwork/scRNAseq/BN/KDA/KDA_summary/"

dat=read.table(paste(KDA_Folder,"/SORT_summary.txt",sep="\t")
colname_dat = colnames(dat)[1:6]



dat=dat[1:min(100,nrow(dat)),1:6]

dat=t(dat)


dat=data.frame(dat)
library(reshape2)
rownames(dat)=seq_len(nrow(dat))
#dat$name <- seq_len(nrow(dat))
dat$network <-c(colname_dat)
dat=data.frame(dat)

dat2 <- melt(dat, id.vars = "network")

library(ggplot2)
dat2$network=factor(as.vector(dat2$network),levels=c("pureDE_Astro06","GeneModule_Astro06","DE_GeneModule_Astro06","pureDE_Micro06","GeneModule_Micro06","DE_GeneModule_Micro06"))

dat2$value=as.numeric(dat2$value)

base_size=12
base_family=""
cols<- c( "pureDE_Astro06"="dodgerblue","GeneModule_Astro06"="dodgerblue1","DE_GeneModule_Astro06"="dodgerblue2",
	"pureDE_Micro06"="magenta","GeneModule_Micro06"="magenta1","DE_GeneModule_Micro06"="magenta2"
)

 ggplot(dat2, aes(x=variable, y=value, fill=network)) + 
    geom_bar(stat="identity") +
   xlab("\nkey drivers") +
   ylab("Frequency\n") +
   
   scale_fill_manual(values = cols)+
	 theme_grey(base_size = base_size, base_family = base_family) %+replace% 
        theme(axis.text.x = element_text(vjust=0.5),axis.text = element_text(size = rel(0.8),angle=90), axis.ticks = element_line(colour = "black"), 
            legend.key = element_rect(colour = "grey80"), panel.background = element_rect(fill = "white", 
                colour = NA), panel.border = element_rect(fill = NA, 
                colour = "grey50"), panel.grid.major = element_line(colour = "grey90", 
                size = 0.2), panel.grid.minor = element_line(colour = "grey98", 
                size = 0.5), strip.background = element_rect(fill = "grey80", 
                colour = "grey50", size = 0.2))

ggsave(filename=paste(KDA_Folder,"summary.png",sep=""),width=15,height=10)







############################## SOLO ################
rm(list=ls())
dir="C:/PAPERS/mssn/Micro_Neuron_MAYO/KDA_Analysis/output_summary_ciPG_sort/"
setwd(dir)

sort_file=list.files()

for(i in 1:length(sort_file)){

dat=read.table(sort_file[i],sep="\t")
dat_temp=dat
dat[,1]=dat_temp[,1]
dat[,2]=dat_temp[,2]
dat[,3]=dat_temp[,3]
colnames(dat)=c("DE_GENE_GENEModule","GeneModule","pureDE")

dat=dat[1:min(100,nrow(dat)),1:3]

dat=t(dat)


dat=data.frame(dat)
library(reshape2)
rownames(dat)=seq_len(nrow(dat))
#dat$name <- seq_len(nrow(dat))
dat$network <-c("DE_GENE_GENEModule","GeneModule","pureDE")
dat=data.frame(dat)

dat2 <- melt(dat, id.vars = "network")

library(ggplot2)
dat2$network=as.factor(dat2$network)
dat2$value=as.numeric(dat2$value)

base_size=12
base_family=""
cols<- c("DE_GENE_GENEModule"="magenta", "GeneModule"="green","pureDE"="yellow")

 ggplot(dat2, aes(x=variable, y=value, fill=network)) + 
    geom_bar(stat="identity") +
   xlab("\nkey drivers") +
   ylab("Frequency\n") +
   
   scale_fill_manual(values = cols)+
	 theme_grey(base_size = base_size, base_family = base_family) %+replace% 
        theme(axis.text.x = element_text(vjust=0.5),axis.text = element_text(size = rel(0.8),angle=90), axis.ticks = element_line(colour = "black"), 
            legend.key = element_rect(colour = "grey80"), panel.background = element_rect(fill = "white", 
                colour = NA), panel.border = element_rect(fill = NA, 
                colour = "grey50"), panel.grid.major = element_line(colour = "grey90", 
                size = 0.2), panel.grid.minor = element_line(colour = "grey98", 
                size = 0.5), strip.background = element_rect(fill = "grey80", 
                colour = "grey50", size = 0.2))

ggsave(filename=paste("C:/PAPERS/mssn/Micro_Neuron_MAYO/KDA_Analysis/output_summary_ciPG_sort/",sort_file[i],".png",sep=""),width=15,height=10)

}