splitString <- function( mystring , separator = "; " )
{
  splitted <- NULL
  for ( each in mystring )
  {
     if ( is.na( each ) | is.null( each ) )
	 {
        next
     }
     splitted <- c(splitted , unlist( strsplit( each , separator ) ) )
  }
  #a=unlist( strsplit(mystring, separator) )
  return( splitted )
}

