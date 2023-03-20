

getStackedBarplot<-function(inputFile,filter,threshold=NULL,barType,topRow,topColumn,outputFile){

  
  # getStackBarplot draw a stack barplot.
  # Each row of the inputFile corresponds to one stacked bar in x-axis 
  # A stacked bar is consisted of the values of the same row.
  
  
  # :param inputFile: The file address of the input file. This file is a matrix with column and row names, 
  #                   where  each row corresponds to one target and each column corresponds to one source.
  #                   The value of each cell should be P.value.
  #                   It is expected that the rows of input file has been already sorted.
  # :param filter: it is a boolean value. If it is True, Only cells with value less than threshold would be represented in data visulization.
  # :param threshold: it is a numeric value. Only cells with value less than threshold would be represented in data visulization.
  # :param barType: It could be 'one' or '-logP'. If it is 'one', the bar length is 1. If it is '-logP', the bar length is -log(P.value)
  # :param topRow: it is a numeric value. Only visulize the first topRow rows of the inputFile.
  # :param topRow: it is a numeric value. Only visulize the first topColumn columns of the inputFile.
  # :param outputFile: The file address of output figure.
  


  library(reshape2)
  library(ggplot2)  

  # Read in data
  dat=read.table(inputFile,sep="\t",header=T,check.names=F,row.names=1)
  
  # filter data and do the numeric transformation
  if(filter==TRUE){
      ind_Significant = dat<threshold
      ind_inSignificant = dat>=threshold    
    dat[ind_inSignificant] = 0
    if(barType == "one"){  
      dat[ind_Significant] = 1
    }  
    if(barType == "-logP"){   
      dat[ind_Significant] = -log(dat[ind_Significant])
    }
  }

  dat=dat[1:topRow,1:topColumn]
  sourceName = colnames(dat)
  dat=t(dat)
  dat=data.frame(dat)
  rownames(dat) = seq_len(nrow(dat))
  dat$source <- sourceName
  # Reshape the table by melt()
  dat_melted <- melt(dat, id.vars = "source")
  dat_melted$source=as.factor(dat_melted$source)
  dat_melted$value=as.numeric(dat_melted$value)
  

  # Optional Customize color scheme
  #cols<- c("ATP1B1"="magenta","DCAF12"="magenta3", "FIBP"="green", "JMJD6"="green3",
  #         "NDRG4"="pink","NSF"="yellow","NUDT2"="blue","RBM4"="red","STXBP1"="cyan",
  #         "YWHAZ"="brown")

  # draw the stack barplot
  base_size=12
  base_family=""
  ggplot(dat_melted, aes(x=variable, y=value, fill=source)) + scale_y_continuous(limits = c(0, 10))+
    geom_bar(stat="identity") + xlab("\nPathway") + ylab("Frequency\n") +
    #scale_fill_manual(values = cols)+    
    theme_grey(base_size = base_size, base_family = base_family) +
    theme(axis.text.x = element_text(vjust=0.5),axis.text = element_text(size = rel(0.8),angle=90,hjust=1), axis.ticks = element_line(colour = "black"), 
          legend.key = element_rect(colour = "grey80"), panel.background = element_rect(fill = "white", colour = NA), panel.border = element_rect(fill = NA,colour = "grey50"),
          panel.grid.major = element_line(colour = "grey90",    size = 0.2), panel.grid.minor = element_line(colour = "grey98", size = 0.5), strip.background = element_rect(fill = "grey80",  colour = "grey50", size = 0.2))
  # output the figure        
  ggsave(filename=outputFile,width=15,height=10)
    
}







