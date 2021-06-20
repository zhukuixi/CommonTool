setsub <- function( setA , setB )
{
    if ( length( setA ) > length( setB ) )
	{
        return( FALSE )
    }
    setAB <- union( setA , setB )
    return ( setequal( setAB , setB ) )
}

