


findNLayerNeighborsLinkPairs_EXPAND <- function( linkpairs , subnetNodes , nlayers = 1  )
{
  #linkpairs=linkpairs; subnetNodes=ineighbors; nlayers=nlayers-1; directed=directed
   merged <- merge( linkpairs , subnetNodes , by.x = 1 , by.y = 1 , all = FALSE )  ##找下游的一层
   merged <- as.matrix( merged )


     mergeleft <- merge( linkpairs , subnetNodes , by.x = 2 , by.y = 1 , all = FALSE )
     mergeleft <- as.matrix( mergeleft )
     mergeleft <- mergeleft[,c( 2 , 1 )] # keep the original link direction
     merged <- rbind( merged , mergeleft )
   
   dim1 <- dim( merged )[1]
   if ( isTRUE( all.equal( dim1 , 0 ) ) )  #若此时扩展网络为空，则返回NULL
   {
# no links
         return( NULL )
   }
   else if ( is.null( dim1 ) )
   {
# only one link
       merged <- rbind( merged )
   }
   merged <- removeDuplicatedLinks( merged ) ##去除自己指向自己的边，同时对A->B,B->A都存在的边选其中一个 （下游）。。


   # get nodes   
   ineighbors <- union( merged[,1] , merged[,2] )

   if (nlayers==1){
      res=getSubnetwork_LinkPairs(linkpairs, subnetNodes=ineighbors) ##寻找原网络中包含这些点的边
      return (res)
   }


   # stop earlier if no change
   #
   common <- intersect( ineighbors , subnetNodes )
   if ( length( common ) == length( ineighbors ) )
   {
      return ( merged )
   }

   return ( findNLayerNeighborsLinkPairs_EXPAND( linkpairs , ineighbors , nlayers - 1) )
}

