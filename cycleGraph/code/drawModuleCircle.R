rm(list=ls())
# Must Use R v3.6.1
library(tidyverse)

###### PICK TOP 3 Enriched Pathway for each module #####


mayo_files = list.files("/input/MAYO_ENO2/")

mayo_store=c()
setwd("/input/MAYO_ENO2/")
##using pvalue as height
for(i in 1:length(mayo_files)){
	color = strsplit(strsplit(mayo_files[i],"\\.")[[1]][1],".txt")[[1]]
	temp = read.table(mayo_files[i],sep="\t")
	sig_count = sum(temp[,4]<0.05)
	if (sig_count==0){
		next
	}
	temp = temp[1:min(3,sig_count),]
	temp = cbind(temp,seq(nrow(temp)))
	temp = cbind(temp,color)
	temp = temp[,c(1,7,4,6)]
	colnames(temp)=c("individual","group","value","id")
	mayo_store = rbind(mayo_store,temp)
}



### OUTPUT THE TOP PICK RESULT ###
#write.table(mayo_store,"/intermediateResult/moduleEnrichment_mayo_eno2_top3.txt",sep="\t",quote=F)

### READ IN THE TOP PICK RESULT ###
#mayo_store = read.table("/intermediateResult/moduleEnrichment_mayo_eno2_top3.txt",sep="\t")


############## draw for MAYO  ##################

data = mayo_store[,1:3]
data$group = as.factor(data$group)

cols=levels(data$group)
col_rgb=lapply(cols,col2rgb)
x=c()
for(i in 1:length(col_rgb)){
	str = paste(c(col_rgb[[i]][1],col_rgb[[i]][2],col_rgb[[i]][3]),collapse=" ")
	x=c(x,str)
}


final_color=sapply(strsplit(x, " "), function(x)
    rgb(x[1], x[2], x[3], maxColorValue=255))



data$value = -log(data$value)


# Set a number of 'empty bar' to add at the end of each group
empty_bar=1
to_add = data.frame( matrix(NA, empty_bar*nlevels(data$group), ncol(data)) )
colnames(to_add) = colnames(data)
to_add$group=rep(levels(data$group), each=empty_bar)
data=rbind(data, to_add)
data=data %>% arrange(group)
data$id=seq(1, nrow(data))
 
# Get the name and the y position of each label
label_data=data
number_of_bar=nrow(label_data)
angle= 90 - 360 * (label_data$id-0.5) /number_of_bar     # I substract 0.5 because the letter must have the angle of the center of the bars. Not extreme right(1) or extreme left (0)
label_data$hjust<-ifelse( angle < -90, 1, 0)
label_data$angle<-ifelse(angle < -90, angle+180, angle)


# prepare a data frame for base lines
base_data=data %>% 
  group_by(group) %>% 
  summarize(start=min(id), end=max(id) - empty_bar) %>% 
  rowwise() %>% 
  mutate(title=mean(c(start, end)))
 
# prepare a data frame for grid (scales)
grid_data = base_data
grid_data$end = grid_data$end[ c( nrow(grid_data), 1:nrow(grid_data)-1)] + 1
grid_data$start = grid_data$start - 1
grid_data=grid_data[-1,]
 

# Make the plot
p = ggplot(data, aes(x=as.factor(id), y=value, fill=group)) +       # Note that id is a factor. If x is numeric, there is some space between the first bar
  scale_fill_manual(values=final_color)+
  geom_bar(aes(x=as.factor(id), y=value, fill=group), stat="identity", alpha=0.5) +
  
 
  geom_bar(aes(x=as.factor(id), y=value, fill=group), stat="identity", alpha=0.5) +
  ylim(-40,150) +      ### You can adjust this 2 numbers to change the graph. This two numbers indicates the lower and upper boudary of values showed in the cycle graph. The first negative value
                       ### determines how hollow the middle circle is. The second positive number determines the height of bar. You can play with them.
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.text = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank(),
    plot.margin = unit(rep(0,4
), "in") 
  ) +
  coord_polar() + 
  geom_text(data=label_data, aes(x=id, y=value+1, label=individual, hjust=hjust,vjust=0), color="black", fontface="bold",alpha=0.9, size=2.5, angle= label_data$angle, inherit.aes = FALSE )+
  # Add base line information
  geom_segment(data=base_data, aes(x = start, y = -2, xend = end, yend = -2), colour = "black", alpha=0.8, size=0.3 , inherit.aes = FALSE )  +
 geom_text(data=base_data, aes(x = title, y = -10, label=group),vjust=0 , colour = "black", alpha=0.8, size=2, fontface="bold", inherit.aes = FALSE)
 ggsave("/output/mayo_neuron_cyclePlot1.png", height=12, width=12, units='in', dpi=600)


