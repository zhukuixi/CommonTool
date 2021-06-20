setInSets <- function( setC , setlist )
{
   for ( i in c( 1:length( setlist ) ) )
   {
       isSub <- setsub( setC , setlist[[i]] )
       if ( isSub )
	   { #setC is a subset of setlist[[i]]
          return( TRUE )
       }
   }
   return( FALSE )
}

