configureNodeVisualization = function(allnodes, signature, kdaMatrix, bNodeSz=40, bFontSz=12) {

   # SIG--signature; NSIG--not signature; GKD--Global KeyDriver; LKD--Local KeyDriver; NKD--Not KeyDriver
   #
   xcategories = c("SIG_GKD", "SIG_LKD", "SIG_NKD", "NSIG_GKD", "NSIG_LKD", "NSIG_NKD"); xcat2=c("NSIG_GKD", "NSIG_LKD", "NSIG_NKD")
   xcolors     = c("red",     "blue",    "lightgreen",  "red",      "blue",     "grey");  names(xcolors)<- xcategories
   xshapes     = c("square",  "square",  "circle",   "circle",    "circle",   "circle");names(xshapes)<- xcategories
   xsizes      = c(3*bNodeSz, 2*bNodeSz, bNodeSz,   3*bNodeSz,  2*bNodeSz,  bNodeSz);     names(xsizes) <- xcategories
   xfontsz     = c(3*bFontSz, 2*bFontSz, bFontSz,   3*bFontSz,  2*bFontSz,  bFontSz);     names(xfontsz)<- xcategories

   no.nodes = length(allnodes)

   # legend table 
   legendtb = cbind(xcategories, xshapes, xcolors, xcolors, xsizes, xfontsz)
   colnames(legendtb) <- c("label", "shape", "color", "border", "node_size", "font_size")

   sigInNet = intersect(allnodes, signature)
   sig_status = rep("NSIG", no.nodes); names(sig_status) <- allnodes; sig_status[sigInNet]="SIG"
   kdr_status = rep("NKD",  no.nodes); names(kdr_status) <- allnodes; 

   nf.cols = dim(kdaMatrix)[2]; nf.rows = dim(kdaMatrix)[1]
   keydrvNames = NULL
   if(nf.rows>0) {
     keydrv  = as.integer(kdaMatrix[,nf.cols])

     # global driver
     keysel  = c(1:nf.rows)[keydrv==1]; 
     keydrvNames = kdaMatrix[keysel,1];
     kdr_status[keydrvNames] = "GKD"

     # local driver
     if(sum(keydrv==0)>0) {
        keysel  = c(1:nf.rows)[keydrv==0];
        keydrvNames = kdaMatrix[keysel,1];
        kdr_status[keydrvNames] = "LKD"
     }

     # combined signature-keydriver status
     #
     sigkdr_status=paste(sig_status, kdr_status, sep="_")
     hnList = tapply(allnodes, sigkdr_status, list) # make a list for each category
     sigkdr_names = names(hnList)

     isNonSig = intersect(xcat2, sigkdr_names) # if all nodes are signatures, we use only circle for display
     if(length(isNonSig)==0){
       xshapes     = c("circle",   "circle",   "circle",  "circle",   "circle",   "circle");names(xshapes)<- xcategories
     }

     # set up actual visualization properties
     yHighColor = xcolors[sigkdr_names]
     yHighShape = xshapes[sigkdr_names]
     yHighSize  = xsizes[sigkdr_names]
     yHighFontSZ= xfontsz[sigkdr_names]

   } else {
     hnList     = list(sigInNet) # highlight only signature
     yHighColor = c("brown")
     yHighShape = c("circle")
     yHighSize  = c("1")
     yHighFontSZ= c("1")
   }

   return( list(hnList, cbind(yHighColor, yHighShape, yHighSize, yHighFontSZ), legendtb) )
}
