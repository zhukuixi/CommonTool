getAllParts <- function( fullfnames , sep = "-" , retLen = FALSE )
{
  splitted <- unlist( strsplit( fullfnames[1] , sep ) )
  nn <- length( fullfnames )
  nf <- length( splitted )
  ret <- matrix( "" , nn , nf )
  lens <- rep( 0 , nn )
  for( i in c( 1:nn ) )
  {
    each <- fullfnames[i]
    splitted <- unlist( strsplit( each , sep ) )
    ino <- length( splitted )
    if ( ino >= nf )
	{
       ret[i,] <- splitted[1:nf]
    }
	else
	{
       ret[i,] <- c( splitted , rep( "" , nf - ino ) )
    }
    lens[i] <- ino
  }

  if ( retLen )
  {
     return( lens )
  }
  else
  {
     return( ret ) 
  }
  
}

