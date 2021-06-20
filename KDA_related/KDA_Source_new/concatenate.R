concatenate <- function( myvect , mysep="" )
{
  if ( is.null( myvect ) )
  {
    return ( "" )
  }
  else if ( isTRUE( all.equal( length( myvect ) , 1 ) ) )
  {
    return ( as.character( myvect ) )
  }

  return( paste( as.character( myvect ), sep = "" , collapse = mysep ) )

  #tmpfn = "tmp.txt"
  #write.table(t(as.character(myvect)),tmpfn,sep=mysep,quote=FALSE, col.names=F, row.names=FALSE)
  #concatenated <- read.delim(tmpfn, sep="!", header=F)
  #return (as.character(as.matrix(concatenated) ))
}

