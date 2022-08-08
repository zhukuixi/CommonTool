![](https://github.com/zhukuixi/CommonTool/blob/master/RadiusExplorer/img/path.jpg)
# Radius Explorer

## Main idea
Given a list of networks and a list of targets, we want to retrieve nodes related to our targets from each of the network and arrange the nodes from the closest to the furthest. Finally, it will create a folder for each network. Within each network folder, it creates a result file based on the combination of target and mode from targetFile and modeFile. The file name's format is A_B.txt, where A is the a name of target node and B is the name of mode.

## About mode
The mode could be up, down and radius. We assume the networks are directed network.    
**up** means starts from the target node and goes upward.  
**down** means starts from the target node and goes downward.   
**radius** means starts from the target node and goes upward and downward.  
   
## Parameter listed in order
		String netFolder= args[0];      #The first one is a directory to the network.  (This folder contains all the network you want to check) 
		String targetFile = args[1];    #The second one is the path of the target file. (This is a simple txt file with single column)
		String outFolder = args[2];
		mode= args[3];  //up, down, radius
		int maxStep = Integer.parseInt(args[4]);  //if -1, it outputs all level
		String outputMode = args[5]; //edge OR node


## To Run	 
	 java -jar RadiusExplorer_FINAL.jar ./input/network/ ./input/target.txt ./output_edge/ down 2
     edge


