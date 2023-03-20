

getStackBarplot<-function(input_file,barType,topN,outFileAddress){
  
  library(reshape2)
  library(ggplot2)
  
  # input_file is a matrix 
  # rows of matrix: targets
  # columns of the matrix: sources
  # value of each cell: p-value
  
  dat=read.table(sort_file[i],sep="\t",header=T,check.names=F)
  
  # Here we only consider cells with significant P.value
  # the length of bar is 1
  if(barType == "one"){
    ind_Significant = dat<0.05
    ind_inSignificant = dat>=0.05
    dat[ind_Significant] = 1
    dat[ind_inSignificant] = 0
  }
  
  # Here we only consider cells with significant p-value
  # the length of bar is -log(P.value)
  if(barType == "-logP"){
    ind_Significant = dat<0.05
    ind_inSignificant = dat>=0.05
    dat[ind_Significant] = -log(dat[ind_Significant])
    dat[ind_inSignificant] = 0
  }
  
  #dat=dat[1:topN,]
  dat=dat[1:topN,1:10]
  sourceName = colnames(dat)
  dat=t(dat)
  dat=data.frame(dat)
  rownames(dat) = seq_len(nrow(dat))
  dat$source <- sourceName
  # Reshape the table by melt()
  dat_melted <- melt(dat, id.vars = "source")
  dat_melted$source=as.factor(dat_melted$source)
  dat_melted$value=as.numeric(dat_melted$value)
  
  base_size=12
  base_family=""

  # Optional Customize color scheme
  #cols<- c("ATP1B1"="magenta","DCAF12"="magenta3", "FIBP"="green", "JMJD6"="green3",
  #         "NDRG4"="pink","NSF"="yellow","NUDT2"="blue","RBM4"="red","STXBP1"="cyan",
  #         "YWHAZ"="brown")

  # draw the stack barplot
  ggplot(dat_melted, aes(x=variable, y=value, fill=source)) + scale_y_continuous(limits = c(0, 10))+
    geom_bar(stat="identity") + xlab("\nPathway") + ylab("Frequency\n") +
    #scale_fill_manual(values = cols)+    
    theme_grey(base_size = base_size, base_family = base_family) +
    theme(axis.text.x = element_text(vjust=0.5),axis.text = element_text(size = rel(0.8),angle=90,hjust=1), axis.ticks = element_line(colour = "black"), 
          legend.key = element_rect(colour = "grey80"), panel.background = element_rect(fill = "white", colour = NA), panel.border = element_rect(fill = NA,colour = "grey50"),
          panel.grid.major = element_line(colour = "grey90",    size = 0.2), panel.grid.minor = element_line(colour = "grey98", size = 0.5), strip.background = element_rect(fill = "grey80",  colour = "grey50", size = 0.2))
  ggsave(filename=outFileAddress,width=15,height=10)
    
}







