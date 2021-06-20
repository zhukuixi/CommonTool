removeDuplicatedLinks <- function( linkpairs  )
{


    # 1. remove duplications 
    #
    linkpairs=as.matrix(linkpairs)	
    linkpairs=unique(linkpairs)
	



    # 2. A->A self interaction 
	temp=linkpairs

   nonselSelfLinks <- which(linkpairs[,1] != linkpairs[,2])

	if(length(nonselSelfLinks)>0){
	    linkpairs<- linkpairs[nonselSelfLinks,]
	    if(class(linkpairs)!="matrix"){
		linkpairs=matrix(linkpairs,ncol=2)
	    }
	}else{		
		linkpairs=NULL
	}
	
	

      return( linkpairs)
   
}

