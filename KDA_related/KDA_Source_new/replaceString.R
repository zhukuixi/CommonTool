replaceString <- function( fullfnames , oldstr , newstr )
{
  no.files <- length( fullfnames )
  res <- NULL
  for ( each in fullfnames )
  {
    #print(paste(i, "/", no.files, ":", each) )
    each2 <- paste( each , oldstr , sep = "" )
    splitted <- splitString( each2 , oldstr )

    neweach <- concatenate( splitted , newstr )

# How could this ever be run?  There is no way for this conditional to evaluate to TRUE!
#    if ( FALSE )
#	{
#      neweach <- ""
#      for ( is in splitted )
#	  {
#        neweach <- paste( neweach , newstr , sep = is )
#      }
#    }

    #oldeach  = paste(pathnet, each,   sep="")
    #neweach  = paste(pathnet, newstr, splitted[2], sep="")
    #a=file.rename(from=oldeach, to=neweach)
    #print(a)

    res <- c( res , neweach )
  }
  return( res )
}
