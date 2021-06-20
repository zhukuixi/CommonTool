getFileName <- function( fullfname )
{
    ext <- getFileExtension( fullfname )
    if (ext == "" )
	{
       return( fullfname )
    }
    extd <- paste( "." , ext , sep = "" )
    return( splitString( fullfname , extd )[1] )
}

