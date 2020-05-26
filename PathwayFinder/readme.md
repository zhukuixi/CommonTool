		
# Pathway Finder

## Parameter listed in order
K=Integer.parseInt(args[0]);      #Number of step        
String networkFile=args[1];       #Network file,2 column format  
String targetFile=args[2];        #Target file, 1 column format  
String outputFile=args[3];		  #output  
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
		
		