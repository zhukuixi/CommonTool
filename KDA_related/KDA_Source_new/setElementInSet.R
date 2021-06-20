setElementInSet <- function( setA , setB )
{
    found <- rep( FALSE , length( setA ) )
    for ( i in c( 1:length( setA ) ) )
	{
       idiff <- setdiff( setA[i] , setB )
	   found[i] <- isTRUE( all.equal( length( idiff ) , 0 ) )
    }
    return ( found )
}

