getFileExtension <- function( fullfname )
{
    splitted <- unlist( strsplit( fullfname , "\\." ) )

    if ( length( splitted ) > 1 )
	{
      return( splitted[length( splitted )] )
    }
	else
	{
      return( "" )
    }
}

