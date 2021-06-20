downStreamGenes <- function( netpairs , seednodes , N = 100 )
{
   prenodes = seednodes
   cnt = N
   while(T) {
      retlinks = findNLayerNeighborsLinkPairs_KDA(linkpairs=netpairs, subnetNodes=prenodes, 
                      nlayers=1)

      if(is.null(retlinks)){return (NULL); }

      curnodes = union(retlinks[,1],retlinks[,2]) 
      pcdiff   = setdiff(curnodes, prenodes)
      prenodes = curnodes
      
      if(length(pcdiff)==0){break}

      cnt= cnt-1
      if (cnt==0) {break;}
   }

   if(is.null(retlinks)){
        return (NULL)

   } else {
        return(curnodes)
   }
}

