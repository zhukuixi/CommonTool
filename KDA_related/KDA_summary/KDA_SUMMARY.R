

rm(list=ls())
style="KDA_scRNA_microAstro"
summary_style="summary"
KDA_folder = "/xdisk/ruichang/mig2020/rsgrps/ruichang/kuixizhu/sc/orga/work/zhuk01/KDA/"
startPoint = length(strsplit(KDA_folder,"/+")[[1]])+3
folders  = list.dirs(path = paste(KDA_folder,style,"/output/", sep=""),full.names = TRUE, recursive = TRUE)





mapping=read.delim("/xdisk/ruichang/mig2020/rsgrps/ruichang/kuixizhu/sc/orga/work/zhuk01/hgnc_complete_set.txt",sep="\t",header=TRUE)

ensg2symbol<-function(target){
  answer=c()
  for(i in 1:length(target)){
    ind=which(as.matrix(mapping[,20])==target[i])
    if(length(ind)>0){
      answer=c(answer,as.character(mapping[ind,2]))
    }else{
      
      answer=c(answer,as.character(target[i]))
    }
  }
  return(answer)
}

entrez2symbol<-function(target){
  answer=c()
  for(i in 1:length(target)){
    ind=which(as.matrix(mapping[,19])==target[i])
    if(length(ind)>0){
      answer=c(answer,as.character(mapping[ind,2]))
    }else{
      answer=c(answer,as.character(target[i]))
    }
  }
  return(answer)
}

FolderJudge<-function(folder){
  ## check if a folder is the folder contains KDA result
  elements=strsplit(folder,"/")[[1]]
  if(grepl("posterior_",elements[length(elements)])){
    return(TRUE)	
  }else{
    return(FALSE)
  }
}


netFolder = folders[unlist(lapply(folders,FolderJudge))]


for(folder_index in 1:length(netFolder)){
  curFolder = netFolder [folder_index]
  elements=strsplit(curFolder ,"/+")[[1]]		
  mark=paste(elements[startPoint:length(elements)],collapse="~")
  files=list.files(curFolder)
  
  
  kda_collection=c()
  for (i in 1:length(files)){
    if(length(files)==0){
      break
    }
    if(!grepl("\\.xls$",files[i])){
      next
    }
    if(file.info(paste(curFolder,files[i],sep="/"))$size == 0){
      next
    }
    re=strsplit(files[i],"_")
    color=re[[1]][2]
    #	if(re[[1]][1]=="CT"){    ############
    #		next                 ############
    #	}                        ############
    
    #if(!is.na(color)&&color=="grey"){
    #  next
    #}
    tmp=read.table(paste(curFolder,files[i],sep="/"),header=T,sep="\t")
    # hugo=read.delim("~/Downloads/hgnc_complete_set.txt",sep="\t")
    keyDriver = tmp$keydrivers[tmp$keydriver==1]
    keyDriver_symbol=as.matrix(keyDriver)
    kda_collection=c(kda_collection,keyDriver_symbol)
  }
  

  if(length(kda_collection)==0){
    next
  }
  
  result=as.matrix(table(kda_collection))
  result=cbind(rownames(result),result[,1])
  result=result[order(result[,2],decreasing=T),1:2]
  result=matrix(result,ncol=2)
  colnames(result)=c("Name","Freq")
  outputFolder=paste(KDA_folder,style,"/",summary_style,"/output/",sep="")
  dir.create(outputFolder,showWarnings=FALSE)
  write.table(result,file=paste(paste(KDA_folder,style,"/",summary_style,"/output/",mark,".txt",sep=""),sep=""),sep="\t",col.names=T,row.names=F,quote=F)
  
  
}


