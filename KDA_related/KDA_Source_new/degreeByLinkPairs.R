degreeByLinkPairs <- function( linkpairs , directed = F , cleangarbage = F )
{
    codepair <- c( 0 , 1 )  #[1] for no connection, [2] for connection

    edgesInNet <- dim( linkpairs )[1]
    
    # consider both columns
	# Need to find out why we build the object this way
	#  Could be a cleaner way, but there may be a reason why
	#  it's currently done this way
    allnodenames <- NULL
    allnodenames <- c( allnodenames , as.character( linkpairs[,1] ) )
    allnodenames <- c( allnodenames , as.character( linkpairs[,2] ) )
     
    nametable <- table( allnodenames )
    # Not sure why this was here, uncommented out
	# length( nametable )
    
    uniquenames <- names( nametable )
    no.uniquenames <- length( uniquenames )

    totallinks <- as.integer( nametable ) # no of links for each node
    totalmatrix <- cbind( names( nametable ),  totallinks )

    if ( directed )
	{
        # outlines
        dnodenames <- as.character( linkpairs[,1] )
        dnametable <- table( dnodenames )
        duniquenames <- names( dnametable )
        dmatrix <- cbind( names( dnametable ), as.integer( dnametable ) )
        colnames( dmatrix ) <- c( "node" , "links" )

        iolinks <- mergeTwoMatricesByKeepAllPrimary( primaryMatrix = cbind( uniquenames ) ,
				minorMatrix = dmatrix , missinglabel = "0" , keepAllPrimary = TRUE ,
				keepPrimaryOrder = TRUE , keepAll = FALSE )
        outlinks <- as.integer( as.matrix( iolinks[,2] ) )


        # inlines
        dnodenames <- as.character( linkpairs[,2] )
        dnametable <- table( dnodenames )
        duniquenames <- names( dnametable )
        dmatrix <- cbind( names( dnametable ) , as.integer( dnametable ) )
        colnames( dmatrix ) <- c( "node" , "links" )

        iolinks <- mergeTwoMatricesByKeepAllPrimary( primaryMatrix = cbind( uniquenames ) ,
				minorMatrix = dmatrix , missinglabel = "0" , keepAllPrimary = TRUE ,
				keepPrimaryOrder = TRUE , keepAll = FALSE )
        inlinks <- as.integer( as.matrix( iolinks[,2] ) ) 

    }
	else
	{
        inlinks <- totallinks
        outlinks <- totallinks
    }

    #hubidx    = order(-totallinks)

    # output in/out links for each gene
    #
    linksMatrix <- cbind( inlinks , outlinks , totallinks )
    colnames( linksMatrix ) <- c( "inlinks" , "outlinks" , "totallinks" )
    rownames( linksMatrix ) <- uniquenames

    rm( inlinks , outlinks , totallinks )

    if ( cleangarbage )
	{
        collect_garbage()
    }

    return( data.frame( linksMatrix ) )
}

