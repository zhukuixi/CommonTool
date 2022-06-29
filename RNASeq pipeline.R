library(limma)
library(edgeR)
library(ggplot2)
library(variancePartition)
library(dplyr)


#For GenesiPSC's looser cutoff, genes with > 0.1 CPM in at least 10% of experiments were retained for the liberal cutoff.
#For GenesiPSC's tight cutoff for Gabriel's analysis, 1 CPM in at least 30% of the experiments were retained 
MIN_GENE_CPM=1
MIN_SAMPLE_PERCENT_WITH_MIN_GENE_CPM=0.3
low_expression_cutoff=paste("cutoff",paste("cpm=",MIN_GENE_CPM,sep=''),paste("sample=",MIN_SAMPLE_PERCENT_WITH_MIN_GENE_CPM,sep=''),sep='_')

dataversion = "v3.317"

gene_expression_counts = read.csv("~/Dropbox/ChangLabPipeline/NeuronalRNASeq/Data/gene_expression_counts.csv", row.names = 1)
hgncTable = read.delim("~/Dropbox/ChangLabPipeline/NeuronalRNASeq/Data/hgnc_complete_set.txt")
info = read.csv("../sample info full.csv", row.names = 1)
################################################################################
# Functions:
################################################################################
getGeneFilteredGeneExprMatrix <- function(gene_expression_counts) {
  # if (!is.null(ONLY_USE_GENES)) {
  #     useGenes = colnames(gene_expression_counts)
  #     useGenes = useGenes[useGenes %in% ONLY_USE_GENES]
  #     gene_expression_counts = gene_expression_counts[, useGenes]
  #     writeLines(paste("\nLimiting expression data to ", length(useGenes), " genes specified by the ONLY_USE_GENES parameter.", sep=""))
  # }
  
  # Make edgeR object:
  MATRIX.ALL_GENES = DGEList(counts=gene_expression_counts, genes=rownames(gene_expression_counts))
  
  # Keep genes with at least MIN_GENE_CPM count-per-million reads (cpm) in at least (MIN_SAMPLE_PERCENT_WITH_MIN_GENE_CPM)% of the samples:
  #Gabriel: version-2: new low-expression gene cutoff: this is due to PCA test on different cutoff to see the batch effect converge
  fracSamplesWithMinCPM = rowSums(cpm(MATRIX.ALL_GENES) >MIN_GENE_CPM)
  isNonLowExpr = fracSamplesWithMinCPM >= MIN_SAMPLE_PERCENT_WITH_MIN_GENE_CPM*ncol(gene_expression_counts)
  
  #Gabriel: version-1.
  #fracSamplesWithMinCPM = rowSums(cpm(MATRIX.ALL_GENES) >1)
  #isNonLowExpr = fracSamplesWithMinCPM >= 50
  #ORG Menachem
  #fracSamplesWithMinCPM = rowMeans(cpm(MATRIX.ALL_GENES) >=MIN_GENE_CPM)
  #isNonLowExpr = fracSamplesWithMinCPM >= MIN_SAMPLE_PERCENT_WITH_MIN_GENE_CPM
  
  
  
  MATRIX.NON_LOW_GENES = MATRIX.ALL_GENES[isNonLowExpr, ]
  writeLines(paste("\nWill normalize expression counts for ", nrow(MATRIX.NON_LOW_GENES), " genes (those with a minimum of ", MIN_GENE_CPM, " CPM in at least ", sprintf("%.2f", 100 * MIN_SAMPLE_PERCENT_WITH_MIN_GENE_CPM), "% of the ", ncol(MATRIX.NON_LOW_GENES), " samples).", sep=""))
  
  
  # FRACTION_BIN_WIDTH = 0.02
  # plotFracSamplesWithMinCPM = data.frame(GeneFeature=names(fracSamplesWithMinCPM), fracSamplesWithMinCPM=as.numeric(fracSamplesWithMinCPM))
  # gRes = ggplot(plotFracSamplesWithMinCPM, aes(x=fracSamplesWithMinCPM))
  # gRes = gRes + geom_vline(xintercept=MIN_SAMPLE_PERCENT_WITH_MIN_GENE_CPM, linetype="solid", col="red")
  # gRes = gRes + geom_histogram(color="black", fill="white", binwidth=FRACTION_BIN_WIDTH) #+ scale_x_log10()
  # gRes = gRes + xlab(paste("Fraction of samples with at least ", MIN_GENE_CPM, " CPM", sep="")) + ylab("# of genes")
  
  return(list(filteredExprMatrix=MATRIX.NON_LOW_GENES, plotHist=NULL))
}





calcResiduals <- function(geneBySampleValues, samplesByCovariates, varsToAddBackIn=NULL, sampleWeights=NULL) {
  #################################################################################
  # Use the calcResiduals() code after this section in a for loop:
  #################################################################################
  if (is.matrix(sampleWeights)) {
    residualizedMat = matrix(NA, nrow=nrow(geneBySampleValues), ncol=ncol(geneBySampleValues), dimnames=dimnames(geneBySampleValues))
    for (gInd in 1:nrow(geneBySampleValues)) {
      gRow = calcResiduals(geneBySampleValues[gInd, , drop=FALSE], samplesByCovariates, varsToAddBackIn, sampleWeights[gInd, ])
      residualizedMat[gInd, ] = gRow
    }
    return(residualizedMat)
  }
  #################################################################################
  
  #result.lm = lsfit(x=samplesByCovariates, y=t(geneBySampleValues), wt=sampleWeights, intercept=FALSE)
  
  # Formula of "y ~ 0 + x" means no intercept:
  result.lm = lm(t(geneBySampleValues) ~ 0 + samplesByCovariates, weights=sampleWeights)
  covarNames = colnames(samplesByCovariates)
  
  coef = result.lm$coefficients
  isMatrixForm = is.matrix(coef)
  if (isMatrixForm) {
    rownames(coef) = covarNames
  }
  else {
    names(coef) = covarNames
  }
  
  allVarsToAddBack = '(Intercept)'
  if (!is.null(varsToAddBackIn)) {
    allVarsToAddBack = c(allVarsToAddBack, varsToAddBackIn)
  }
  allVarsToAddBack = intersect(allVarsToAddBack, covarNames)
  
  residualizedMat = result.lm$residuals
  for (v in allVarsToAddBack) {
    if (isMatrixForm) {
      multCoef = coef[v, , drop=FALSE]
    }
    else {
      multCoef = coef[v]
    }
    residualizedMat = residualizedMat + samplesByCovariates[, v, drop=FALSE] %*% multCoef
  }
  
  residualizedMat = t(residualizedMat)
  rownames(residualizedMat) = rownames(geneBySampleValues)
  colnames(residualizedMat) = colnames(geneBySampleValues)
  
  return(residualizedMat)
}


#************************************************************
#Remove low-expressed genes
#************************************************************
filteredMatPlot = getGeneFilteredGeneExprMatrix(gene_expression_counts)

# Will normalize expression counts for 15847 genes (those with a minimum of 1 CPM in at least 30.00% of the 84 samples).


TRUE.GENE_EXPRESSION_DGELIST_MAT = filteredMatPlot$filteredExprMatrix
write.table(rownames(TRUE.GENE_EXPRESSION_DGELIST_MAT),
            quote=FALSE,sep="\t",
            file=paste("expressed.gene.ensemble","CPMcut=",MIN_GENE_CPM,"Percent=",MIN_SAMPLE_PERCENT_WITH_MIN_GENE_CPM,dataversion,"txt",sep=".")
            ,col.names=F,row.names=F)

TRUE.GENE_EXPRESSION_MAT = TRUE.GENE_EXPRESSION_DGELIST_MAT$counts

#------------NEW-Nov-2015: Just to double check the effect of gene length on gene expression variance------------#
# RPKM: normalize against gene length-----------#
#write.table(rownames(TRUE.GENE_EXPRESSION_MAT),quote=FALSE,sep="\n",file=paste("filtered.gene.ensemble",dataversion,"txt",sep="."),col.names=F,row.names=F)
#rpkm(TRUE.GENE_EXPRESSION_MAT,)

#------------# TMM normalization for effective library size-----------------#
TRUE.GENE_EXPRESSION_DGELIST_MAT.NORM <-calcNormFactors(TRUE.GENE_EXPRESSION_DGELIST_MAT,method='TMM')


#****************Calculate log-CPM by voom****************
# voom normalization
#*********************************************************
pdf(paste("voom.OutlierRemove",dataversion,"pdf",sep="."))
vobj = voom(TRUE.GENE_EXPRESSION_DGELIST_MAT.NORM, plot=T)
VOOM_RAW_LOG_EXPRESSION_MAT = vobj$E
write.table(VOOM_RAW_LOG_EXPRESSION_MAT,quote=FALSE,sep="\t",col.names=TRUE,file="Voom_Log2CPM_noCov_OutlierRemoval.txt")
dev.off()

# Plot distribtuion of CPM values
pdf(paste("distribution.OutlierRemoval.cpm",dataversion,"pdf",sep="."))
plot(density(vobj$E[,1]))
for(i in 2:ncol(vobj)){
  lines(density(vobj$E[,i]))
}
dev.off()

design <- model.matrix(~info$RNAprepBatch + 
                         info$Adjusted.nM + 
                         info$Lib.batch + 
                         info$RQN + 
                         info$Exonic.Rate + 
                         info$Intronic.Rate + 
                         info$Intergenic.Rate  + 
                         info$High.Quality.Exonic.Rate + 
                         info$High.Quality.Intronic.Rate + 
                         info$High.Quality.Intergenic.Rate 
                       + info$Expression.Profiling.Efficiency+info$Intragenic.Rate+info$High.Quality.Intragenic.Rate+info$High.Quality.Ambiguous.Alignment.Rate, info)

adjusted_covariates="19_covariates"
residual_analysis="Neuro_KD"
#Apply voom
PRED.GENE_EXPRESSION_MAT<- voom(TRUE.GENE_EXPRESSION_DGELIST_MAT.NORM,
                                design=design,
                                plot=TRUE) # col numb. of sample=row# of design matrix

# Coefficients not estimable: info$`Expression Profiling Efficiency` 
# Warning message:
# Partial NA coefficients for 15847 probe(s) 


#Get the numeric matrix of normalized expression values on the log2 scale
VOOM_NORMALIZED_LOG_EXPRESSION_MAT = PRED.GENE_EXPRESSION_MAT$E
#Get the numeric matrix of inverse variance weights
VOOM_WEIGHTS_MAT = PRED.GENE_EXPRESSION_MAT$weights
#ORG: Now, we get the exact voom residuals 
VOOM_WEIGHTED_RESIDUALIZED_WITH_PRIMARY_MAT = calcResiduals(VOOM_NORMALIZED_LOG_EXPRESSION_MAT,
                                                            design,
                                                            varsToAddBackIn=NULL, 
                                                            sampleWeights=VOOM_WEIGHTS_MAT)
VOOM_WEIGHTED_RESIDUALIZED_WITH_PRIMARY_MAT.scale=t(scale(t(VOOM_WEIGHTED_RESIDUALIZED_WITH_PRIMARY_MAT),
                                                          scale = FALSE, center = TRUE))
save(VOOM_WEIGHTED_RESIDUALIZED_WITH_PRIMARY_MAT.scale,file=paste("Res.KNOWN",
                                                                  residual_analysis,
                                                                  adjusted_covariates,
                                                                  dataversion,
                                                                  low_expression_cutoff,"RData",sep="."))
write.table(VOOM_WEIGHTED_RESIDUALIZED_WITH_PRIMARY_MAT.scale,
            quote=FALSE,sep="\t",
            col.names=TRUE,
            row.names=TRUE,
            file=paste("Res.KNOWN",residual_analysis,adjusted_covariates,dataversion,low_expression_cutoff,"txt",sep="."))

#canonical way (returns the same results as Menachem's way)
#fit=lmFit(VOOM_NORMALIZED_LOG_EXPRESSION_MAT, design, weights=VOOM_WEIGHTS_MAT)
#Res.KNOWN.AllKNOWN = residuals(fit, VOOM_NORMALIZED_LOG_EXPRESSION_MAT)
#write.table(Res.KNOWN.AllKNOWN,quote=FALSE,sep="\t",col.names=TRUE,row.names=TRUE,file=paste("Res.KNOWN",residual_analysis,adjusted_covariates,dataversion,low_expression_cutoff,"txt",sep="."))
# save(Res.KNOWN.AllKNOWN,file=paste("Res.KNOWN",residual_analysis,adjusted_covariates,dataversion,low_expression_cutoff,"RData",sep="."))
# Res.KNOWN.AllKNOWN.scale=t(scale(t(Res.KNOWN.AllKNOWN),scale = FALSE, center = TRUE))
# save(Res.KNOWN.AllKNOWN.scale,file=paste("Res.KNOWN",residual_analysis,adjusted_covariates,dataversion,low_expression_cutoff,"RData",sep="."))
# write.table(Res.KNOWN.AllKNOWN.scale,quote=FALSE,sep="\t",col.names=TRUE,row.names=TRUE,file=paste("Res.KNOWN",residual_analysis,adjusted_covariates,dataversion,low_expression_cutoff,"txt",sep="."))

info$RNAprepBatch = as.factor(info$RNAprepBatch)
info$Lib.batch = as.factor(info$Lib.batch)

form <- ~ (1|info$RNAprepBatch) + 
  info$Adjusted.nM + 
  (1|info$Lib.batch) +
  info$RQN +
  info$Exonic.Rate + 
  info$Intronic.Rate + 
  info$Intergenic.Rate  + 
  info$High.Quality.Exonic.Rate + 
  info$High.Quality.Intronic.Rate + 
  info$High.Quality.Intergenic.Rate 
#+info$`High Quality Ambiguous Alignment Rate`


varPart <- fitExtractVarPartModel(VOOM_NORMALIZED_LOG_EXPRESSION_MAT, form, info)

#Error in .fitExtractVarPartModel(exprObj, formula, data, REML = REML,  : 
#                                   the fixed-effects model matrix is column rank deficient (rank(X) = 9 < 13 = p);
#                                 the fixed effects will be jointly unidentifiable 
#                                 
#                                 Suggestion: rescale fixed effect variables.
#                                 This will not change the variance fractions or p-values.
                                 

# sort variables (i.e. columns) by median fraction of variance explained
vp <- sortCols( varPart )
# Figure 1a
# Bar plot of variance fractions for the first 10 genes 
plotPercentBars( vp[1:10,] )
#
# Figure 1b
# violin plot of contribution of each variable to total variance 

pdf(paste("VP",adjusted_covariates,residual_analysis,date,"pdf",sep="."))
plotVarPart( vp )
dev.off()



######## DIFFERENTIAL EXPRESSION ##########

# info.full = read.csv("sample info full.csv", row.names = 1)
# info.full$condition = relevel(info.full$condition, ref = "media.only")

info$condition = as.factor(info.full$condition)
info$RNAprepBatch = as.factor(info.full$RNAprepBatch)
info$Lib.batch = as.factor(info.full$Lib.batch)

design2 <- model.matrix(~0+info$condition +
                          info$RNAprepBatch + 
                          info$Adjusted.nM + 
                          info$Lib.batch +
                          info$RQN +
                          info$Exonic.Rate + 
                          info$Intronic.Rate + 
                          info$Intragenic.Rate + 
                          info$Intergenic.Rate  + 
                          info$High.Quality.Exonic.Rate + 
                          info$High.Quality.Intronic.Rate + 
                          info$High.Quality.Intergenic.Rate +
                          info$High.Quality.Intragenic.Rate + info$High.Quality.Ambiguous.Alignment.Rate
                        , info)

colnames(design2)
colnames(design2)[1:28] = levels(info$condition)
colnames(design2)[29:50] = c('RNAprepBatch1','RNAprepBatch2',
                             'RNAprepBatch3',
                             'RNAprepBatch4',
                             'RNAprepBatch5',
                             'RNAprepBatch6',
                             'RNAprepBatch7',
                             'RNAprepBatch8',
                             'RNAprepBatch9',
                             'Adjusted.nM',
                             'Lib.batch2',
                             'Lib.batch3',
                             'RQN',                             
                             'Exonic.Rate',
                             'Intronic.Rate',
                             'Intragenic.Rate',
                             'Intergenic.Rate',
                             'High.Quality.Exonic.Rate',
                             'High.Quality.Intronic.Rate',
                             'High.Quality.Intergenic.Rate',
                             'High.Quality.Intragenic.Rate',
                             'High.Quality.Ambiguous.Alignment.Rate')


colnames(design2)

ANALY.GENE_EXPRESSION_MAT<- voom(TRUE.GENE_EXPRESSION_DGELIST_MAT.NORM,design=design2,plot=TRUE)

# #Coefficients not estimable: 
# #info.full.RNAprepBatch2 
# #info.full.RNAprepBatch3 
# info.full.RNAprepBatch4 
# info.full.RNAprepBatch5 
# info.full.RNAprepBatch6 
# info.full.RNAprepBatch7 
# info.full.RNAprepBatch8 
# info.full.RNAprepBatch9 
# info.full.RNAprepBatch10 
# info.full.Lib.batch2 


design3 = design2[,c(1:29,38,40:50)]
colnames(design3)
#A = design2[,c(29,31:37,39)]

res <- cor(design2)
cor.mat = round(res, 2)

#design2 = design2[,c(-31,-39)]

ANALY.GENE_EXPRESSION_MAT<- voom(TRUE.GENE_EXPRESSION_DGELIST_MAT.NORM,design=design3,plot=TRUE)


#### Without Contrasts 

fit=lmFit(ANALY.GENE_EXPRESSION_MAT, design3) 
#fit2 <- eBayes(fit, trend=TRUE)
fit2 <- eBayes(fit)

summary(decideTests(fit2))
summary(decideTests(fit2, `adjust.method` = "none", p.value = 0.05))

RBM4.deg = topTable(fit2, 
                     coef = "RBM4", 
                     number = Inf, 
                     adjust.method = "BH", 
                     sort.by = "logFC")
colnames(RBM4.deg)[1] <- "ensembl_gene_id_version"
RBM4.deg <- merge(RBM4.deg, bm, by ="ensembl_gene_id_version")

RBM4.deg.filt = RBM4.deg %>% filter(RBM4.deg$adj.P.Val < 0.05)


RAP9A.deg = topTable(fit2, 
                    coef = "RAP9A", 
                    number = Inf, 
                    adjust.method = "BH", 
                    sort.by = "logFC")
colnames(RAP9A.deg)[1] <- "ensembl_gene_id_version"
RAP9A.deg <- merge(RAP9A.deg, bm, by ="ensembl_gene_id_version")

RAP9A.deg.filt = RAP9A.deg %>% filter(RAP9A.deg$adj.P.Val < 0.05)

YWHAZ.deg = topTable(fit2, 
                    coef = "YWHAZ", 
                    number = Inf, 
                    adjust.method = "BH", 
                    sort.by = "logFC")
colnames(YWHAZ.deg)[1] <- "ensembl_gene_id_version"
YWHAZ.deg <- merge(YWHAZ.deg, bm, by ="ensembl_gene_id_version")

YWHAZ.deg.filt = YWHAZ.deg %>% filter(YWHAZ.deg$adj.P.Val < 0.05)


################################################################################
################################################################################
################################################################################
################################################################################
###### With Contrasts

# contrasts <- makeContrasts(ATP1B1-media.only, 
#                            ATP6V1A-media.only,
#                            CIRBP-media.only,
#                            DCAF12-media.only,
#                            empty-media.only,
#                            FIBP-media.only,
#                            FMNL2-media.only,
#                            GABARAP-media.only,
#                            HP1BP3-media.only,
#                            ICA-media.only,
#                            ITFG-media.only,
#                            JMJD6-media.only,
#                            NDRG4-media.only,
#                            NSF-media.only,
#                            NUDT2-media.only,
#                            ORF.empty-media.only,
#                            RAB3A-media.only,
#                            RAP9A-media.only,
#                            RBM4-media.only,
#                            RHBDD2-media.only,
#                            RHOG-media.only,
#                            STXBP1-media.only,
#                            SYN1-media.only,
#                            SYT1-media.only,
#                            TUBB2B-media.only,
#                            UNC119B-media.only,
#                            YWHAZ-media.only,
#                            levels= design3)


contrasts <- makeContrasts(ATP1B1-empty, 
                           ATP6V1A-empty,
                           CIRBP-empty,
                           DCAF12-empty,
                           media.only-empty,
                           FIBP-empty,
                           FMNL2-empty,
                           GABARAP-empty,
                           HP1BP3-empty,
                           ICA-empty,
                           ITFG-empty,
                           JMJD6-empty,
                           NDRG4-empty,
                           NSF-empty,
                           NUDT2-empty,
                           ORF.empty-empty,
                           RAB3A-empty,
                           RAP9A-empty,
                           RBM4-empty,
                           RHBDD2-empty,
                           RHOG-empty,
                           STXBP1-empty,
                           SYN1-empty,
                           SYT1-empty,
                           TUBB2B-empty,
                           UNC119B-empty,
                           YWHAZ-empty,
                           levels= design3)

fit=lmFit(ANALY.GENE_EXPRESSION_MAT$E, design3) 
fit2 <- contrasts.fit(fit, contrasts)
#fit3 <- eBayes(fit2, trend=TRUE)
fit3 <- eBayes(fit2)


summary(decideTests(fit3))
summary(decideTests(fit3, `adjust.method` = "none", p.value = 0.05))


topSetTmp = topTable(fit3, 
                   coef = 1, 
                   number = Inf, 
                   adjust.method = "BH", 
                   sort.by = "P")


geneset<-rownames(topSetTmp)
genename<-unlist(lapply(geneset,function (x) {unlist(strsplit(x,"[.]"))[1]}))
symbol<-hgncTable$symbol[match(genename,hgncTable$ensembl_gene_id)]
topSetTmp<-cbind(topSetTmp,symbol)
outPrefix="Neuron.DE.RAP9AvsEmpty"
write.table(topSetTmp,file=paste(sep="",outPrefix,".txt"),sep="\t",col.names=T,row.names=T,quote=F)

