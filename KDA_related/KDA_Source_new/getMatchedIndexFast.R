getMatchedIndexFast=function(cvector, subvect){
  fullindex = c(1:length(cvector) )
  orgIdx    = cbind(cvector, fullindex)

  index2    = c(1:length(subvect))
  subIdex   = cbind(subvect, index2)

  merged    = merge(subIdex, orgIdx, by.x=1, by.y=1, all.x=T)
  merged    = as.matrix(merged)

  if(dim(merged)[1]>1){
    od        = order(as.integer(merged[,2]))  # restore the original order of subvect
    merged    = merged[od, ]
  }
  
  outIndex  = as.integer(merged[,3])

  return (outIndex)
}
