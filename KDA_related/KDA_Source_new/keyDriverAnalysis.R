keyDriverAnalysis = function(inputnetwork, signature, directed=T, nlayer_expansion=1,
      nlayer_search=6, enrichedNodes_percent_cut=-1, boost_hubs=T, dynamic_search=T, 
      FET_pvalue_cut=0.05, use_corrected_pvalue=T, outputfile=NULL, expanded_network_as_signature=FALSE) 
{

   if (!is.null(outputfile)) {
      #onetFname   = paste(outputfile, outputDir, key2, ".pair", sep='')
      snpFname    = paste(outputfile, ".snp",  sep='')
      kdFname     = paste(outputfile, "_keydriver.xls",  sep='')
   }

   # overlap between network & signature
   wholenodes = union(inputnetwork[,1], inputnetwork[,2]); no.wholenodes=length(wholenodes)
   wholeOvlp  = intersect(wholenodes, signature); no.wholeOvlp = length(wholeOvlp)
   
   if(length(wholeOvlp)<=2) {return (NULL)}

   if(nlayer_expansion >=1 ) {
      # expand network by n-layer nearest neighbors
      expandNet = findNLayerNeighborsLinkPairs(linkpairs=inputnetwork, 
                  subnetNodes=signature, nlayers=nlayer_expansion, directed=directed)
   } else if(nlayer_expansion ==0 ){
      # no expansion
      expandNet = getSubnetworkLinkPairs(linkpairs=inputnetwork, subnetNodes=signature)
   } else{
      expandNet = inputnetwork
   }

   if(is.null(expandNet)) {return (NULL)}
   if(dim(expandNet)[1]<=10) {return (NULL)}

   dim(expandNet)
   print(paste("dim(expandNet): ", dim(expandNet)) )

   allnodes = sort(union(expandNet[,1], expandNet[,2])); no.nodes=length(allnodes)

   # convert IDs into indices
   netIdxSrc = getMatchedIndexFast(allnodes, expandNet[,1])
   netIdxDst = getMatchedIndexFast(allnodes, expandNet[,2])
   signatIdx = getMatchedIndexFast(allnodes, intersect(allnodes, signature))
   expandNetIdx = cbind(netIdxSrc, netIdxDst)

   ################################################################################################
   # 4. keydriver for a given network
   #
   #linkpairs=expandNetIdx; signature=signatIdx; background=c(no.wholenodes, no.wholeOvlp); directed=directed; nlayers=nlayer_search; enrichedNodes_percent_cut=enrichedNodes_percent_cut; FET_pvalue_cut=FET_pvalue_cut; boost_hubs=boost_hubs; dynamic_search=dynamic_search; bonferroni_correction=use_corrected_pvalue

   if (directed) {
     ret= keydriverInSubnetwork(linkpairs=expandNetIdx, signature=signatIdx, background=c(no.wholenodes, no.wholeOvlp),
              directed=directed, nlayers=nlayer_search, enrichedNodes_percent_cut=enrichedNodes_percent_cut, 
              FET_pvalue_cut=FET_pvalue_cut, 
              boost_hubs=boost_hubs, dynamic_search=dynamic_search, bonferroni_correction=use_corrected_pvalue, expanded_network_as_signature = expanded_network_as_signature)
   } else{
     ret= keydriverInSubnetwork(linkpairs=expandNetIdx, signature=signatIdx, background=c(no.wholenodes, no.wholeOvlp),
              directed=directed, nlayers=nlayer_search, enrichedNodes_percent_cut=enrichedNodes_percent_cut,
              FET_pvalue_cut=FET_pvalue_cut, 
              boost_hubs=boost_hubs, dynamic_search=dynamic_search, bonferroni_correction=use_corrected_pvalue, expanded_network_as_signature = expanded_network_as_signature)
   }

   if ( is.null(ret)) {return (NULL)}

   # retrieve results
   #
   fkd = ret[[1]]
   parameters = ret[[2]]

   fkd[,1] = allnodes[as.integer(fkd[,1])]   

   if (!is.null(outputfile)) {
      write.table(fkd, kdFname, sep="\t",quote=FALSE, col.names=T, row.names=FALSE)

      ################################################################################################
      #  output networks & key drivers for visualization
      #
      #     Cytoscape output: 1) network file - *_cys.txt 2) node property file: *_cys-nodes.txt
      #  * signature== genes need be corrected in other version
      # allnodes=allnodes; signature=signature; kdaMatrix=fkd; bNodeSz=40; bFontSz=12

      nodeprop = configureNodeVisualization(allnodes=allnodes, signature=signature, kdaMatrix=fkd)

      hnList     = nodeprop[[1]] # node subcategpries
      listprop   = nodeprop[[2]] # visual properties for each subcategory
      legend     = nodeprop[[3]] # legend table for visual propertie

      resf = makeSNP(netpairsWtype   = expandNet, 
               edgecolorlevels = c("grey"),
               highlightNodes  = hnList,
               normColor="grey",   highColor=listprop[,1],
               normShape="circle", highShape=listprop[,2],
               normNodeSize ="40",  highNodeSize =listprop[,3],
               normFontSize ="12",  highFontSize =listprop[,4],
               legendtable=legend, snafile=snpFname )

      result = list(expandNet, fkd, ret[[2]], getFileFullNameNopath(resf) )
      names(result) <- c("subnetwork", "keydrivers", "parameters", "files")
   } else{
      result = list(expandNet, fkd, ret[[2]])
      names(result) <- c("subnetwork", "keydrivers", "parameters")
   }

   return (result)
}
