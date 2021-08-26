
dir="D:/Dropbox//TIME/0730/shRNA/output_shRNAdeEnrichment/forDrawBarplot/"
setwd(dir)

sort_file=list.files()
options(stringsAsFactors=F)
fun<-function(input_row){	
	temp = input_row
	ind_sig = which(temp<0.05)
	ind_nosig = which(temp>=0.05)
	temp[ind_sig] = 1
	temp[ind_nosig] = 0
	return(temp)
}

for(i in 1:length(sort_file)){

	dat=read.table(sort_file[i],sep="\t",header=T,check.names=F)
	dat = apply(dat,2,fun)
	dat=dat[1:100,1:10]
	
	getName<-function(inName){
		elements = strsplit(inName,"_")[[1]]
		return(paste(elements[1],elements[3],sep=" in "))
	}
	getPath<-function(inName){
			elements = strsplit(as.character(inName),"\\.")[[1]]
			return(paste(elements,collapse=" "))
	}
	rownames(dat) = unlist(lapply(rownames(dat),getName))
	forDAT2 = rownames(dat)
	name = colnames(dat)
	dat=t(dat)


	dat=data.frame(dat)
	library(reshape2)
	rownames(dat)=seq_len(nrow(dat))
	#dat$name <- seq_len(nrow(dat))
	dat$network <-name
	dat=data.frame(dat)

	dat2 <- melt(dat, id.vars = "network")

	library(ggplot2)
	dat2$network=as.factor(dat2$network)
	dat2$value=as.numeric(dat2$value)

	base_size=12
	base_family=""
	newName = unlist(lapply(dat2$variable,getPath))
	dat2$variable = factor(newName,levels=unique(newName))

	cols<- c("ATP1B1"="magenta","DCAF12"="magenta3", "FIBP"="green", "JMJD6"="green3",
		"NDRG4"="pink","NSF"="yellow","NUDT2"="blue","RAB9A"="red","STXBP1"="cyan",
		"YWHAZ"="brown")
	
	 ggplot(dat2, aes(x=variable, y=value, fill=network)) + scale_y_continuous(limits = c(0, 10))+
	    geom_bar(stat="identity") +
	   xlab("\nPathway") +
	   ylab("Frequency\n") +

	   scale_fill_manual(values = cols)+
		 theme_grey(base_size = base_size, base_family = base_family) %+replace% 
		theme(axis.text.x = element_text(vjust=0.5),axis.text = element_text(size = rel(0.8),angle=90,hjust=1), axis.ticks = element_line(colour = "black"), 
		    legend.key = element_rect(colour = "grey80"), panel.background = element_rect(fill = "white", 
			colour = NA), panel.border = element_rect(fill = NA, 
			colour = "grey50"), panel.grid.major = element_line(colour = "grey90", 
			size = 0.2), panel.grid.minor = element_line(colour = "grey98", 
			size = 0.5), strip.background = element_rect(fill = "grey80", 
			colour = "grey50", size = 0.2))
	if(i==1){
		ggsave(filename=paste("D:/FDR.png",sep=""),width=15,height=10)
	}else{
		ggsave(filename=paste("D:/pvalue.png",sep=""),width=15,height=10)

	}
}
