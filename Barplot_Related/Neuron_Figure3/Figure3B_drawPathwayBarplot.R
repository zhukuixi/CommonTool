setwd("D:/Dropbox/TIME/2021/0322/Figure3B/CPDB_module_enrichment/MAYO_ENO2/")
mayo_moduleFiles = list.files()
store = c()
for(i in 1:length(mayo_moduleFiles)){
  tmp = read.table(mayo_moduleFiles[i],sep="\t",header=T)
  color = strsplit(mayo_moduleFiles[i],"\\.")[[1]][1]
  tmp = tmp[which(tmp[,4]<0.05),]
  if(nrow(tmp)==0){
    next
  }
  re = cbind(cbind(cbind(paste(tmp[,1],tmp[,3],sep="_"),tmp[,4]),c("MAYO")),color)
  store = rbind(store,re)
}


setwd("D:/Dropbox/TIME/2021/0322/Figure3B/CPDB_module_enrichment/ROSMAP_ENO2/")
rosmap_moduleFiles = list.files()
for(i in 1:length(rosmap_moduleFiles)){
  tmp = read.table(rosmap_moduleFiles[i],sep="\t",header=T)
  color = strsplit(rosmap_moduleFiles[i],"\\.")[[1]][1]
  tmp = tmp[which(tmp[,4]<0.05),]
  if(nrow(tmp)==0){
    next
  }
  re = cbind(cbind(cbind(paste(tmp[,1],tmp[,3],sep="_"),tmp[,4]),c("ROSMAP")),color)
  store = rbind(store,re)
}

sort(table(store[,1]),decreasing = T)[1:10]


store = cbind(store,paste(store[,3],store[,4],sep="_"))

config = unique(store[,5])


unique_path = unique(store[,1])
forDraw = c()

for(i in 1:length(unique_path)){
  curPath = unique_path[i]
  ind = which(store[,1]==curPath)
  tmp = store[ind,]
  value = rep(1,length(config))
  if(length(ind)>1){
    value[match(tmp[,5],config)] = as.numeric(tmp[,2])
  }else{
    value[match(tmp[5],config)] = as.numeric(tmp[2])
  }
  count = sum(value<0.05)
  cross = any(value[1:6]<0.05) & any(value[7:9]<0.05)
  neglogSum = sum(-log2(value))
  value = -log2(value)
  content = c(curPath,value,count,cross,neglogSum)
  forDraw = rbind(forDraw,content)
}

colnames(forDraw)=c("path",config,"count","cross","neglogSum")
rownames(forDraw) = forDraw[,1]
forDraw = forDraw[,-1]
forDraw = data.frame(forDraw)


forDraw = forDraw[order(forDraw$cross,forDraw$count,forDraw$neglogSum,decreasing = T),]

dat = forDraw

dat = dat[,1:9]
dat = dat[1:50,]
dat=t(dat)








dat=data.frame(dat,check.names = FALSE)
library(reshape2)
rownames(dat)=seq_len(nrow(dat))
dat$network <-config

dat2 <- melt(dat, id.vars = "network")

library(ggplot2)
dat2$network=as.factor(dat2$network)
dat2$value=as.numeric(dat2$value)

base_size=12
base_family=""


cols<- c("MAYO_blue"="blue",
         "MAYO_greenyellow"="greenyellow",
         "MAYO_lightcyan"="lightcyan",
         "MAYO_midnightblue"="midnightblue",
         "MAYO_purple"="purple",
         "MAYO_turquoise"="turquoise",
         "ROSMAP_green"="green",
         
         "ROSMAP_purple"= "purple",
         "ROSMAP_turquoise" ="turquoise"
)

texture = c("MAYO"="circle", "ROSMAP"="stripe")


dat2$network = factor(dat2$network,levels=config)
dat2$texture = c("MAYO")
dat2$texture[grepl("ROSMAP",dat2[,1])] = "ROSMAP"
library(ggpattern)


ggplot(dat2, aes(x=variable, y=value, fill=network,pattern=texture)) + 
  geom_bar(stat="identity") +
  xlab("\nPathways") +
  ylab("Frequency\n") +
  scale_fill_manual(values = cols)+ scale_pattern_manual(values = c("MAYO"="circle", "ROSMAP"="stripe"))+
  theme_grey(base_size = base_size, base_family = base_family)+
  theme(axis.text = element_text(hjust=0.95,size = rel(0.8),angle=90))                                                                                                                                                       

ggsave("MAYO_ROSMAP_Path.png",width=15,height=10)







set.seed(40)
df2 <- data.frame(Row = rep(1:9,times=9), Column = rep(1:9,each=9),
                  Evaporation = runif(81,50,100),
                  TreeCover = sample(c("Yes", "No"), 81, prob = c(0.3,0.7), replace = TRUE))

ggplot(data=df2, aes(x=as.factor(Row), y=as.factor(Column),
                     pattern = TreeCover, fill= Evaporation)) +
  geom_tile_pattern(pattern_color = NA,
                    pattern_fill = "black",
                    pattern_angle = 45,
                    pattern_density = 0.5,
                    pattern_spacing = 0.025,
                    pattern_key_scale_factor = 1) +
  scale_pattern_manual(values = c(Yes = "none", No = "stripe")) +
  scale_fill_gradient(low="#0066CC", high="#FF8C00") +
  coord_equal() + 
  labs(x = "Row",y = "Column") + 
  guides(pattern = guide_legend(override.aes = list(fill = "white")))








cols<- c("MAYO_blue"="blue",
         "MAYO_greenyellow"="greenyellow",
         "MAYO_lightcyan"="lightcyan",
         "MAYO_midnightblue"="midnightblue",
         "MAYO_purple"="purple",
         "MAYO_turquoise"="turquoise",
         "ROSMAP_green"="green",
         
         "ROSMAP_purple"= "purple",
         "ROSMAP_turquoise" ="turquoise"
)



dat2$network = factor(dat2$network,levels=config)
dat2$texture = c("MAYO")
dat2$texture[grepl("ROSMAP",dat2[,1])] = "ROSMAP"
library(ggpattern)


ggplot(dat2, aes(x=variable, y=value, fill=network)) + 
  geom_bar(stat="identity") +geom_col_pattern(aes(pattern=texture ),pattern_angle=0,pattern_alpha=1,
                                              colour  = 'black')+
  xlab("\nPathways") +
  ylab("Frequency\n") +
  scale_fill_manual(values = cols)+ scale_pattern_manual(values = c("MAYO"="none", "ROSMAP"="magick"))+
  theme_grey(base_size = base_size, base_family = base_family)+
  theme(axis.text = element_text(hjust=0.95,size = rel(0.6),angle=90))    


