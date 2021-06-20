keydriverInSubnetwork <- function(linkpairs, signature, background=NULL, directed=T, nlayers=6, 
                                   enrichedNodes_percent_cut=-1, FET_pvalue_cut=0.05, 
                                   boost_hubs=T, dynamic_search=T, bonferroni_correction=T, expanded_network_as_signature =F) {

   allnodes = sort(union(linkpairs[,1], linkpairs[,2]))
   no.subnetsize = length(allnodes)

   #print(no.subnetsize)
   if(no.subnetsize <=4) {return (NULL)}

   # whole network nodes as the signature
   network_as_signature = length(setdiff(allnodes, signature)) ==0
   network_as_signature = expanded_network_as_signature | network_as_signature

   overlapped    = intersect(allnodes, signature)
   no.overlapped = length(overlapped) # within the subnetwork

   if(is.null(background) ){
      background2 = c(no.subnetsize, no.overlapped) 
   } else {
      background2 = background
   }

   keydrivers= NULL
   kdMatrix  = NULL
   kdIndex   = NULL # indices of keydrivers in dsnodes_list

   dsnodes_list = as.list(rep(0,no.subnetsize)); no.dsnodes = rep(0, no.subnetsize)
   cnt = 1

   intv = as.integer(no.subnetsize/10)
   if(intv==0) {intv =1}
   print("find downstream genes")

   # set up searching range
   if(dynamic_search) { # dynamic search for optimal layer
      layers_4search = c(1:nlayers)
   } else{  # fixed layer for optimal layer
      layers_4search = c(nlayers)
   }
   # if the network itself is the signature, no need for dynamic search
   if(network_as_signature){layers_4search = c(nlayers)}

   dn_matrix = matrix(1, no.subnetsize, nlayers)
   for(i in c(1:no.subnetsize) ) {

     if(i%%intv==0){ print(paste(i, "/", no.subnetsize)) }

     # initialization
     minpv=1;min_nohits=0;min_noidn=0;min_layer=0;min_dn=0; min_fc=0;
     minpvW=1;min_fcW=0;
     for(y in layers_4search) {
         #netpairs=linkpairs; seednodes=allnodes[i]; N=nlayers; directed=directed
         idn = downStreamGenes(netpairs=linkpairs, seednodes=allnodes[i], N=y )
         idn = setdiff(idn, allnodes[i])
         no.idn=length(idn);

         dn_matrix[i, y] = no.idn
      
         if(!network_as_signature){# do enrichment test for only expanded subnetwork
            hits    = intersect(idn, overlapped)
            no.hits = length(hits)

            if(no.hits==0){next}

            foldchg = (no.hits/no.idn)/(no.overlapped/no.subnetsize)
            pv = phyper(no.hits-1, no.idn, no.subnetsize-no.idn, no.overlapped, lower.tail=F)

            foldchgW = (no.hits/no.idn)/(background2[2]/background2[1])
            pvW = phyper(no.hits-1, no.idn, background2[1]-no.idn, background2[2], lower.tail=F)

            if(pv<minpv){
               minpv=pv;min_nohits=no.hits;min_noidn=no.idn;min_layer=y;min_fc=foldchg; 
               minpvW=pvW;min_fcW=foldchgW
            }
         } else{ # for non-expanded subnetwork
            no.hits = no.idn
            minpv=0;min_nohits=no.idn;min_noidn=no.idn;min_layer=y;min_fc=1
         }  
     } #y
     
     # record the down stream genes for the biggest layer
     if(no.idn>0) {
        dsnodes_list[[i]] = idn
        no.dsnodes[i]     = no.idn
     }

     correct_minpv = minpv*no.subnetsize; correct_minpv = ifelse( correct_minpv>1, 1, correct_minpv)

     res= c(min_nohits,min_noidn,no.overlapped,no.subnetsize, background2[2], background2[1], 
            length(signature), min_layer,min_fcW, minpvW, min_fc,minpv, correct_minpv)
     kdMatrix = rbind(kdMatrix, res)
     #print(res)
   }

   colnames(kdMatrix) <- c("hits", "downstream", "signature_in_subnetwork", "subnetwork_size", 
                           "signature_in_network", "network_size", "signature", "optimal_layer",
                           "fold_change_whole", "pvalue_whole", "fold_change_subnet", "pvalue_subnet", 
                           "pvalue_corrected_subnet")
   optLidx = getMatchedIndexFast(colnames(kdMatrix), "optimal_layer")

   mymincut = enrichedNodes_percent_cut*no.overlapped
   if (enrichedNodes_percent_cut<=0){
      #mymincut = mean(no.dsnodes) + sd(no.dsnodes)
      mincutLayers = apply(dn_matrix, 2, mean) + apply(dn_matrix, 2, sd)
      opL = ifelse(kdMatrix[, optLidx]==0, 1, kdMatrix[, optLidx])
      mymincut = mincutLayers[opL]
   }
   cutmatrix = c( mean(no.dsnodes), sd(no.dsnodes), mymincut)

   # pick up key drivers by pvalue and no. of downstream genes
   ncols = dim(kdMatrix)[2]

   if(bonferroni_correction) { # use corrected pvalue
      kdSel = (kdMatrix[,ncols] < FET_pvalue_cut) & (kdMatrix[,2]>= mymincut)
   } else{
      kdSel = (kdMatrix[,ncols-1] < FET_pvalue_cut) & (kdMatrix[,2]>= mymincut)
   }
   
   keydrv = rep(0, no.subnetsize)
   if( sum(kdSel) >0){

      keydrivers= allnodes[kdSel]
      kdIndex   = c(1:no.subnetsize)[kdSel]
      n.drivers = length(keydrivers)

      #******************* local driver or not **************************************
      #
      # check whether a driver is in the downstream of other drivers
      #keydrv = rep(0, no.subnetsize)
      #if (!network_as_signature) {
      for ( i in c(1:n.drivers) ) {

          # Note that kdIndex[i] is the index of ith keydriver in kdMatrix  
          # restrict to only candidate drivers 
          iselA  = (kdMatrix[,2] > kdMatrix[ kdIndex[i],2]) & kdSel
          isel   = c(1:no.subnetsize)[iselA]

          if ( sum(isel)>0) {
              if(directed) {
                 ilocal= setInSets(setC=allnodes[ kdIndex[i] ],       setlist=dsnodes_list[isel])
              } else{
                 ilocal= setInSets(setC=dsnodes_list[[ kdIndex[i] ]], setlist=dsnodes_list[isel])
              }
              keydrv[ kdIndex[i] ] = !ilocal + 0
          } else{
              keydrv[ kdIndex[i] ] = TRUE
          }
      }
     #}
   } else{
      print("Warning: the downstream metric is not used as the specified minimumal downstream size is too big !!")
   }

   # promote genes with many direct links to be key drivers
   #
   #              inlinks outlinks totallinks
   #0610031J06Rik       2        0          2
   #1110001J03Rik       0        1          1
   #
   if(boost_hubs) {
  
     if(!network_as_signature){
        # for expanded network, restrict the boosted nodes to the key driver candidates
        kdSelB = rep(F, no.subnetsize); kdSelB[kdIndex]=T;
        
        psel = kdMatrix[,ncols-3]*no.subnetsize < 0.05; kdPsd=1; kdPmean =1;
        kdpvalues = -log10(kdMatrix[,ncols-3]); kdpvalues = ifelse(is.na(kdpvalues), 0, kdpvalues)
        #histogram(kdpvalues)

        if(sum(psel)>0) {
          kdPmean= mean(kdpvalues[psel]); kdPsd= sd(kdpvalues[psel])
          #kdPmean= median(kdpvalues[psel]); kdPsd= mad(kdpvalues[psel])

          print( as.numeric(signif(kdpvalues[psel],2)) )
          directSel = (kdpvalues > (kdPmean + kdPsd ) ); directSel=ifelse(is.na(directSel), FALSE, directSel)
          #print(directSel)
          if( sum(directSel)>0) {
            kdSel = kdSel | directSel
            dIndex    = c(1:no.subnetsize)[kdSel]
            keydrv    = rep(F, no.subnetsize)
            keydrv[dIndex] = TRUE
          }
        }
        cutmatrix = rbind( c(mean(no.dsnodes), sd(no.dsnodes), concatenate(mymincut,";"),kdPmean,kdPsd, kdPmean + kdPsd ))

        colnames(cutmatrix) <- c("mean_downstream", "sd_downstream", "enrichedNodes_cut", 
                                 "mean_logP", "sd_logP", "cut_logP")

     } else{
        # for non-expanded network, consider all the nodes in the subnetwork
        kdSelB = rep(TRUE, no.subnetsize);

        # align the degree with allnodes
        mydegree  = degreeByLinkPairs(linkpairs=linkpairs, directed=directed, cleangarbage=F)
        mIdx = getMatchedIndexFast(rownames(mydegree), allnodes)
        mydegree = mydegree[mIdx, ]

        if(directed) {
            directSel = mydegree[,2]> mean(mydegree[,2]) + 2*sd(mydegree[,2])
            cutmatrix = rbind( c(mean(no.dsnodes), sd(no.dsnodes), concatenate(mymincut, ";"),
                         mean(mydegree[,2]),sd(mydegree[,2]), mean(mydegree[,2]) + 2*sd(mydegree[,2]) ))
        }else{
            directSel = mydegree[,3]> mean(mydegree[,3]) + 2*sd(mydegree[,3])
            cutmatrix = rbind( c(mean(no.dsnodes), sd(no.dsnodes), concatenate(mymincut, ";"),
                        mean(mydegree[,3]),sd(mydegree[,3]), mean(mydegree[,3]) + 2*sd(mydegree[,3])))
        }
        directSel = directSel & kdSelB

        directeHub  = rownames(mydegree)[directSel]
        isDirectHub = setElementInSet(allnodes, directeHub)

        keydrv[isDirectHub] = T
        kdSel = kdSel | isDirectHub
        colnames(cutmatrix) <- c("mean_downstream", "sd_downstream", "cut_downstream",
                                 "mean_degree", "sd_degree", "cut_degree")
    }


   } else{
     cutmatrix = rbind( c(mean(no.dsnodes), sd(no.dsnodes), concatenate(mymincut, ";"), "F"))
     colnames(cutmatrix) <- c("mean_downstream", "sd_downstream", "cut_downstream", "boost_directhubs")
   }

   if( sum(kdSel)==0){return(NULL)}

   ##
   # in this case, signature is the network nodes themselves, so pvalue will be 0 for all nodes
   # so the driver will be the ones with most downsttream genes
   #
   is_signature = rep(0, no.subnetsize); names(is_signature) <- as.character(allnodes)
   is_signature[as.character(overlapped)]  = 1
   
   fkd = cbind(allnodes, is_signature, kdMatrix, keydrv+0)[kdSel,];

   if(sum(kdSel) >1 ) {
       nf.cols = dim(fkd)[2]
       if(network_as_signature){
          mo = order(-as.integer(fkd[,3]))
       } else{
          mo = order(as.numeric(fkd[,nf.cols-1]))
       }

       fkd = fkd[mo, ]
       # put key driver on the top
       mo  = order( -as.integer(fkd[,nf.cols]) )
       fkd = fkd[mo, ]
   } else{
       fkd = rbind(fkd)
   }

   colnames(fkd) <- c("keydrivers", "is_signature", "hits", "downstream", "signature_in_subnetwork", 
                      "subnetwork_size", "signature_in_network", "network_size", "signature", "optimal_layer",
                      "fold_change_whole", "pvalue_whole", "fold_change_subnet", "pvalue_subnet", "pvalue_corrected_subnet", "keydriver")

   print(fkd)

   return( list( fkd , cutmatrix ) )
}
