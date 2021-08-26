options(stringsAsFactors=F)

setwd("D:/Dropbox/TIME/1226/ClinicalPathwayRegression")

explainCutoff=0.9





computeEigenPathway<-function(cur_residual){
  record = c()
  exp = as.matrix(cur_residual[,1:(ncol(cur_residual)-7)])
  if(ncol(exp)==1){
    return(exp)
  }
  #scale
  for(i in 1:ncol(exp)){
    exp[,i] = (exp[,i]-mean(exp[,i]))/(sd(exp[,i]))
  }
  svdModel = svd(exp)
  explainVariance = cumsum(svdModel$d/sum(svdModel$d))
  cutoff = which(explainVariance>=explainCutoff)[1]
  moduleEigenVectors = c()
  if(length(svdModel$d[1:cutoff])>1){
    moduleEigenVectors = svdModel$u[,1:cutoff] %*% diag(svdModel$d[1:cutoff]) 
  }else{
    moduleEigenVectors = svdModel$u[,1:cutoff]* svdModel$d[1:cutoff] 
    
  }
  return(moduleEigenVectors)
}

lmp <- function (modelobject) {
  if (class(modelobject) != "lm") stop("Not an object of class 'lm' ")
  f <- summary(modelobject)$fstatistic
  p <- pf(f[1],f[2],f[3],lower.tail=F)
  attributes(p) <- NULL
  return(p)
}

correlationEigen<-function(cur_residual,eigenpath){	
  ## correlation wih eigen loading
  record=c()
  
  clinicalFeature = c("DX","ABETA142","PTAU181P","ADNI_MEM","ADNI_EF","TOTSCORE","TOTAL13")
  
  for(j in 1:length(clinicalFeature)){
    eigenVectorLoading = eigenpath
    cur_clinicalFeature = clinicalFeature[j]
    clinicalVector = as.numeric(cur_residual[,match(cur_clinicalFeature,colnames(cur_residual))])
    ind = which(!is.na(clinicalVector))
    eigenVectorLoading = as.matrix(eigenVectorLoading)
    if(length(ind)>0){
      clinicalVector = clinicalVector[ind]
      eigenVectorLoading = eigenVectorLoading[ind,]				
    }
    model = NULL
    pvalue = NULL
    if(cur_clinicalFeature=="DX"){
      model = glm(clinicalVector~eigenVectorLoading,family="binomial")
      pvalue = anova(model,test="Chisq")[[5]][2]
    }else{
      model = lm(clinicalVector~eigenVectorLoading)
      pvalue = lmp(model)
    }
    record = rbind(record,c(cur_clinicalFeature,pvalue))
  }
  
  
  df_record = data.frame(record)
  colnames(df_record) = c("Clinical","Pvalue")
  return(df_record)
}


correlationEigen_individual<-function(cur_residual,eigenpath){	
  ## correlation wih eigen loading
  record=c()
  
  clinicalFeature = c("DX","ABETA142","PTAU181P","ADNI_MEM","ADNI_EF","TOTSCORE","TOTAL13")
  
  for(j in 1:length(clinicalFeature)){
    eigenVectorLoading = eigenpath
    cur_clinicalFeature = clinicalFeature[j]
    clinicalVector = as.numeric(cur_residual[,match(cur_clinicalFeature,colnames(cur_residual))])
    ind = which(!is.na(clinicalVector))
    eigenVectorLoading = as.matrix(eigenVectorLoading)
    if(length(ind)>0){
      clinicalVector = clinicalVector[ind]
      eigenVectorLoading = eigenVectorLoading[ind,]				
    }
    model = NULL
    pvalue = NULL
    
    if(length(ncol(eigenVectorLoading))>0){
      for(i in 1:ncol(eigenVectorLoading)){
        model = cor.test(eigenVectorLoading[,i],clinicalVector)
        pvalue = model$p.value
        record = rbind(record,c(cur_clinicalFeature,i,pvalue))
      }
    }else{
      model = cor.test(eigenVectorLoading,clinicalVector)
      pvalue = model$p.value
      record = rbind(record,c(cur_clinicalFeature,1,pvalue))
    }
    
  }
  
  df_record = data.frame(record)
  colnames(df_record) = c("Clinical","eigenVectorIndex","Pvalue")
  return(df_record)
}




setwd("D:/Dropbox/TIME/1226/ClinicalPathwayRegression/data/")
biomarkerFolder = "D:/Dropbox/TIME/1226/ClinicalPathwayRegression/biomarker_0716/"
mapping = read.table("D:/Dropbox/2020_asus_DiskD/MountSinai_DataBackup/mapping.txt",sep="\t")
outFolder = "D:/Dropbox/TIME/1226/ClinicalPathwayRegression/output/biomarker_0716/"

countSig = function(df){
  ans = c()
  for(i in 6:15){
    count = sum(as.numeric(df[,i])<0.05)
    ans = c(ans,count)      
  }
  return(ans)
}

store = c()
biomarker = read.table("D:/Dropbox/TIME/1226/ClinicalPathwayRegression/biomarker_0716/biomarker_0716.txt",sep="\t",header=T)
for(i in 1:nrow(biomarker)){
  cur_subgroup = biomarker[i,1]
  cur_config = paste(biomarker[i,1],biomarker[i,2],sep="_")
  cur_feature = strsplit(biomarker[i,3],",")[[1]]
  
  print(cur_config)
  data = read.table(paste("Reg_",cur_subgroup,".txt",sep=""),sep="\t",header=T)
  print(nrow(data))
  data$DX[which(data$DX=="AD")]=1
  data$DX[which(data$DX=="CN")]=0
  for(j in 1:(ncol(data)-10)){
    data[,j]=(data[,j]-mean(data[,j]))/sd(data[,j])
  }
  
  features = cur_feature
  features_temp = mapping[match(features,mapping[,2]),1]
  ind = which(is.na(features_temp))
  features_temp[ind] = features[ind]
  features = features_temp
  features = c(features,c("DX","ABETA142","PTAU181P","ADNI_MEM","ADNI_EF","TOTSCORE","TOTAL13"))
  tmp_data = data[,features]
  eigenPath = computeEigenPathway(tmp_data)
  result = correlationEigen(tmp_data,eigenPath)
  store = rbind(store,c(result[,2], cur_config ))
        


}
colnames(store)=paste("reg_",c("DX","ABETA142","PTAU181P","ADNI_MEM","ADNI_EF","TOTSCORE","TOTAL13","config"),sep="")





deFolder ='/Users/zhukuixi/Dropbox/TIME/1027/ML_UnAdjusted/data/data_1126/DE/'

store_de = c()
for(i in 1:length(files)){
  cur_config = strsplit(strsplit(files[i],"_")[[1]][2],"\\.txt")[[1]][1]
  print(cur_config)
  data = read.table(files[i],sep="\t",header=T)
  print(nrow(data))
  
  data$DX[which(data$DX=="AD")]=1
  data$DX[which(data$DX=="CN")]=0
  for(j in 1:(ncol(data)-10)){
    data[,j]=(data[,j]-mean(data[,j]))/sd(data[,j])
  }
  cur_de = read.table(paste(deFolder,cur_config,".txt",sep=""),sep="\t",header=T,row.names=1)

  
 
  # no clinic
  features = rownames(cur_de)[which(cur_de$P.value<0.05)]
  features_temp = mapping[match(features,mapping[,2]),1]
  ind = which(is.na(features_temp))
  features_temp[ind] = features[ind]
  features = features_temp
  features = c(features,c("DX","ABETA142","PTAU181P","ADNI_MEM","ADNI_EF","TOTSCORE","TOTAL13"))
  tmp_data = data[,features]
  eigenPath = computeEigenPathway(tmp_data)
  result = correlationEigen(tmp_data,eigenPath)
  store_de = rbind(store_de,c(result[,2],paste("DE",cur_config,sep="_")))
}

colnames(store_de)=paste("reg_",c("DX","ABETA142","PTAU181P","ADNI_MEM","ADNI_EF","TOTSCORE","TOTAL13","config"),sep="")

store_combine = rbind(store,store_de)
store_matrix = matrix(as.numeric(store_combine[,1:7]),nrow(store_combine),7)
rownames(store_matrix) = paste(store_combine[,8],store_combine[,9],sep=' ')
colnames(store_matrix) = colnames(store_combine)[1:7]

neg_store_matrix = -log2(store_matrix)
colnames(neg_store_matrix) = colnames(store_matrix)
library(pheatmap)

makeColorRampPalette_advance<- function(colors, cutoff.fraction1, cutoff.fraction2,num.colors.in.palette)
{
  ramp1 <- colorRampPalette(colors[1:2])(num.colors.in.palette * cutoff.fraction1)
  ramp2 <- colorRampPalette(colors[3:4])(num.colors.in.palette * (cutoff.fraction2))
  ramp3 <- colorRampPalette(colors[4:5])(num.colors.in.palette * (1 - cutoff.fraction1-cutoff.fraction2))
  return(c(ramp1, ramp2,ramp3))
}




cols <- makeColorRampPalette_advance(c("white", "white",    # distances 0 to 3 colored from white to red
                                       "green", "yellow","red"), # distances 3 to max(distmat) colored from green to black
                                     (-log2(0.05))/max(neg_store_matrix),(-log2(0.01)+log2(0.05))/(max(neg_store_matrix)),
                                     1000)

# only by doing this, it can do cluster.



final_heatmap=pheatmap(neg_store_matrix, 
                       clustering_distance_cols = "correlation",
                       clustering_distance_rows = "correlation",
                       cluster_rows=F, cluster_cols=T,
                       color = cols
)



# negative log2 pvalue heatmap
final_heatmap=pheatmap(neg_store_matrix, 
                       clustering_distance_cols = "correlation",
                       clustering_distance_rows = "correlation",
                       cluster_rows=T, cluster_cols=T,
                       color = cols
)

final_heatmap=pheatmap(neg_store_matrix, 
                       clustering_distance_cols = "correlation",
                       clustering_distance_rows = "correlation",
                       cluster_rows=F, cluster_cols=T,
                       color = cols
)


a=sort(apply(neg_store_matrix,1,sum),decreasing=T)
df=data.frame(cbind(names(a),as.numeric(a)))
colnames(df) = c("config","value")
df$value = as.numeric(df$value)
df$config = factor(df$config)

df=df[order(df$value,decreasing=T),]
df$config = factor(df$config,levels=df$config)

# ability barplot
ggplot(df, aes(x=config, y=value)) +
  geom_bar(stat='identity') +
  coord_flip()

