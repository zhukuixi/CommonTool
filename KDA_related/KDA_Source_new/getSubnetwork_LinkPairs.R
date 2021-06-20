
getSubnetwork_LinkPairs<- function( linkpairs , subnetNodes )
{
   mergeright <- merge( linkpairs , subnetNodes , by.x = 2 , by.y = 1 , all = FALSE )
   if ( isTRUE( all.equal( dim( mergeright )[1] , 0 ) ) )
   {
     return( NULL )
   }

   mergeleft <- merge( mergeright , subnetNodes , by.x = 2 , by.y = 1 , all = FALSE )

   #mergeright = merge(linkpairs, subnetNodes, by.x=1, by.y=1, all=F)
   #mergeleft2 = merge(mergeright, subnetNodes, by.x=2, by.y=1, all=F)

   if ( isTRUE( all.equal( dim( mergeleft )[1] , 0 ) ) )
   {
     return( NULL )
   }

   return( as.matrix( mergeleft ) )   
}

