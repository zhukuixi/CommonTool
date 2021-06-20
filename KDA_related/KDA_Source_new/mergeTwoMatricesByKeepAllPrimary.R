mergeTwoMatricesByKeepAllPrimary <- function( primaryMatrix , minorMatrix , missinglabel = "" ,
		                            keepAllPrimary = TRUE , keepPrimaryOrder = TRUE ,
									keepAll = FALSE )
{
  no.promarycols <- dim( primaryMatrix )[2]
  no.mustbegenes <- dim( primaryMatrix )[1]

  # we add in one more column to indicate which genes are mustbeincluded after being merged with mcg
  keyword <- "mustbeused"
  mustbeGenesMatrix <- cbind( primaryMatrix , c( 1:no.mustbegenes ) , rep( keyword , no.mustbegenes ) )

  if ( is.null( colnames( primaryMatrix ) ) )
  {
    colnames( mustbeGenesMatrix ) <- c( c( 1:no.promarycols ) , "primorder" , keyword )
  }
  else
  {
    colnames( mustbeGenesMatrix ) <- c( colnames( primaryMatrix ) , "primorder" , keyword )
  }
# Why is this uncommented?
#  dim( mustbeGenesMatrix )

  if ( is.null( keepAllPrimary ) )
  { #normal merge: to have the common elements
    myMatrix <- merge( mustbeGenesMatrix , minorMatrix , by.x = 1 , by.y = 1 , all.x = FALSE ,
			           sort = FALSE , all = FALSE )
  }
  else
  {
    myMatrix <- merge( mustbeGenesMatrix , minorMatrix , by.x = 1 , by.y = 1 , all.x = TRUE ,
			           sort = FALSE , all = TRUE )
  }
# Again, why is this left uncommented?
#  dim( myMatrix )
  nocols.mymatrix <- dim( myMatrix )[2]

  #the mustbeused genes which are not included in minor have NAs in the column $mustbeused
  #so we can use this information to figure out which mustbeused genes missing in minorMatrix
  myMatrix[,nocols.mymatrix] <- ifelse( is.na( myMatrix[,nocols.mymatrix] ) , missinglabel ,
		                        as.character( myMatrix[,nocols.mymatrix] ) )

  orders <- order( as.numeric( as.matrix( myMatrix[,no.promarycols + 1] ) ) )
  if ( keepPrimaryOrder )
      myMatrix <- myMatrix[orders,]

  if ( is.null( keepAllPrimary ) )
  {
     selected <- rep( T , dim( myMatrix )[1] )
  }
  else
  {
     if ( keepAllPrimary )
	 {
       selected <- !( is.na( myMatrix[,no.promarycols + 2] ) )
     }
     else #return the row-elements in minor which are missed in primary
	 {
	   selected <- is.na( myMatrix[,no.promarycols + 2] )
	 }
  }
# Why are these here?
#  sum(selected)

  #keep the primary matrix and remove the mustbeused column
  return( myMatrix[selected,-c( no.promarycols + 1 , no.promarycols + 2 )] )
}
