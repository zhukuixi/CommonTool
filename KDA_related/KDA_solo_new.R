library( class )
library( cluster )
library( rpart )
library( lattice )

args <- commandArgs(trailingOnly = TRUE)
networkFile=args[1]
targetFile=args[2]
outputFolder=args[3]





###### Network KDA ######

##### Get all functions in KDA folder/package 
files <- list.files("/xdisk/ruichang/mig2020/rsgrps/ruichang/kuixizhu/sc/orga/work/zhuk01/KDA_Source_new/")

for (f in files){
  cat("sourcing: ",f,"\n")
  try(source(paste("/xdisk/ruichang/mig2020/rsgrps/ruichang/kuixizhu/sc/orga/work/zhuk01/KDA_Source_new/",f,sep=""),local=FALSE))
}




##### Input network 
NETWORK <- read.table(networkFile,sep="\t") #*** Customize
NETWORK=as.matrix(NETWORK)



##### Input genelist *** Customize
SEED=c()



				
SEED <- read.table(targetFile,sep="\t") #*** Customize
SEED=as.matrix(SEED)


##### Starting variables  #*** Customize
directed <- TRUE 
layer <- 6
minDsCut <- -1
fgeneinfo <- NULL

##### Starting variables  #*** Customize
outputDir <- outputFolder
dir.create(outputDir,recursive=T,showWarnings=F)
cnet <- NETWORK[,1:2]
cnet <- as.matrix(cnet)

totalnodes <- union( cnet[,1] , cnet[,2] )

xkdrMatrix <- NULL
paraMatrix <- NULL

genes=SEED[,1]
kdFname <- paste( outputDir ,"SOLO_keydriver.xls" , sep = "" )
  
  if(layer >=1 )
  {
    # expand network by K-hop nearest neighbors layers
    expandNet <- findNLayerNeighborsLinkPairs_EXPAND( linkpairs = cnet , subnetNodes = genes ,
                                               nlayers = layer  )
  }else{
    # no expansion
    expandNet <- getSubnetworkLinkPairs( linkpairs = cnet , subnetNodes = genes )
  }
  dim( expandNet )
  if(length(expandNet)==0){
	
	quit()
	}
  allnodes <- union( expandNet[,1] , expandNet[,2] )
  
  ################################################################################################
  # 4. keydriver for a given network
  #
  
  if (directed)
  {
    ret <- keydriverInSubnetwork( linkpairs = expandNet , signature = genes, background=NULL,
                                  nlayers = 6 , enrichedNodes_percent_cut=-1, FET_pvalue_cut=0.05,
                                  boost_hubs=T, dynamic_search=T, bonferroni_correction=T, expanded_network_as_signature =F)
  }else{
    ret <- keydriverInSubnetwork( linkpairs = expandNet , signature = genes , 
                                  nlayers = 6 , enrichedNodes_percent_cut=-1, FET_pvalue_cut=0.05,
                                  boost_hubs=T, dynamic_search=T, bonferroni_correction=T, expanded_network_as_signature =F)
  }
  
  if ( is.null( ret ) )
  {
   
  }else{  
  fkd <- ret[[1]]
  parameters <- ret[[2]]
 write.table( fkd , kdFname , sep = "\t" , quote = FALSE , col.names = TRUE , row.names = FALSE )
  }

