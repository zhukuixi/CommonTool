![](https://github.com/zhukuixi/CommonTool/blob/master/PathwayFinder/img/connecting-the-dots-sized.gif)
# Pathway Finder

## Main idea
Given a network and a list of target, we want to retrieve edges and nodes related to our targets from the network.     
**Example 1**: If you want to collect all the nodes which are located upstream of the targets but not too far away, says, within 3 steps away, you can use  
#   
    K=3
	DirectionMode="directed"  
	endMode="open"   
	streamFlowMode="up"  
In this configuration, paths would start from target node, follow the direction of edges in network. A path would end if it cannot go any further or reach the maximum length defined by K.


**Example 2:** If you want to investigate edges and nodes between the targets, you may want to set endMode as "closed". In this way, the path would not only start from but ends with target nodes.   
#   
    K=3
	DirectionMode="directed"  
	endMode="closed"   
	streamFlowMode="down" 


## Parameter listed in order
K=Integer.parseInt(args[0]);      #Number of step. It is the maximum length of a path.        
String networkFile=args[1];       #Network file,2 column format  
String targetFile=args[2];        #Target file, 1 column format  
String outputFile=args[3];		  #output, each row is an edge  
DirectionMode=args[4];            #See below  
endMode=args[5];                  #See below  
streamFlowMode=args[6];	          #See below  
		
		
##	
DirectionMode="directed" or "undirected"      
> Whether or not the algorithm treat the network as directed network    

endMode="open" or "closed"    
> When open, the path starts from target nodes  
> When open, the path starts from target nodes and ends in target nodes

streamFlowMode="up" or "down";  
> When DirectionMode="directed":
> "up" means the path grows on the opposite direction of edge    
> "down" means the path grows with the direction of edge  


## To Run
	java -jar ImproveBackwardForward_pathwayFinder_2ColumnStyle.jar 3 network.txt target.txt output.txt directed open up

		
		
