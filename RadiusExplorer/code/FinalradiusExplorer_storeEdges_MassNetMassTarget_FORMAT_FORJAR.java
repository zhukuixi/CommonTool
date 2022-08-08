package root;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Hashtable;
import java.util.List;

//only radius mode, not up and down
public class FinalradiusExplorer_storeEdges_MassNetMassTarget_FORMAT_FORJAR {
	static Hashtable<String,String> from_to=new Hashtable<String,String> (); //key is from to, value is useless ""

	static Hashtable<String,Hashtable<String,String>> node_neighbor=new Hashtable <String,Hashtable<String,String>> ();
	static Hashtable<String,Hashtable<String,String>> node_parent=new Hashtable <String,Hashtable<String,String>> ();
	static Hashtable<String,Hashtable<String,String>> node_child=new Hashtable <String,Hashtable<String,String>> ();
	
	static ArrayList<String> targetList= new ArrayList<String>();
	static Hashtable<String,String> visited = new Hashtable<String,String>();
	static Hashtable<String,String> visited_edge = new Hashtable<String,String>();

	static ArrayList<String> levelStoreEdge= new ArrayList<String>(); 
	static ArrayList<String> levelStoreNode= new ArrayList<String>(); 

	static Hashtable<String,String> allLevelStore = new Hashtable<String,String>();
	static String sourceNode;
	static String mode;
	//static 	Hashtable<String,String> edge_type = new Hashtable<String,String>();

	public static void main(String args[]) throws IOException{
		
		String netFolder= args[0];
		String targetFile= args[1];
		String outFolder = args[2];
		mode= args[3];  //up, down, radius
		int maxStep = Integer.parseInt(args[4]);  //if -1, it outputs all level
		String outputMode = args[5]; //edge, node
	
		/*
		String netFolder="D:/JooGitRepo/CommonTool/RadiusExplorer/input/network/";
		String targetFile="D:/JooGitRepo/CommonTool/RadiusExplorer/input/target.txt";
		String outFolder = "D:/JooGitRepo/CommonTool/RadiusExplorer/output_edge/";
		mode="down";
		int maxStep = 2;
		String outputMode = "edge";
		 */
	
		
		
		readTargetList(targetFile);

		File folder = new File(netFolder);
		String nets[]=folder.list();
		
	
		
		for(String net:nets) {		
			from_to.clear();
			node_neighbor.clear();
			node_parent.clear();
			node_child.clear();
			readNetwork(netFolder+net);			

			for(int i=0;i<targetList.size();i++){		
				sourceNode=targetList.get(i);
				if(node_neighbor.containsKey(sourceNode)==false) {
					System.out.println(sourceNode+" does not appear in "+net+"\n");
					continue;
				}
				
				visited.clear();
				levelStoreEdge.clear();
				levelStoreNode.clear();
				allLevelStore.clear();				
				String outputFile=outFolder+sourceNode+"_"+net+"_"+mode+".txt";	
				BFS_explore(sourceNode);
				if(outputMode=="edge") {
					outputLevelEdge_StepLimit(outputFile,maxStep);
				}else {
					outputLevelNode_StepLimit(outputFile,maxStep);
				}
			}
		}
		
	
		
	}
	
	private static void readNetwork(String networkFile) throws IOException{
		File inputExp = new File(networkFile);
		FileReader fr = new FileReader(inputExp);
		BufferedReader in = new BufferedReader(fr);
		String s;
		while((s=in.readLine())!=null){
			if (s.equals("")) {
				continue;
			}
			
			String edge[]=s.split("\t");
			String node1=edge[0];
			String node2=edge[1];
		//	edge_type.put(node1+"\t"+node2, edge[2]);
			Hashtable<String,String> temp1;
			Hashtable<String,String> temp2;
			
			Hashtable<String,String> temp_par;
			Hashtable<String,String> temp_kid;
			
			//node2-par
			if(node_parent.containsKey(node2)==false){
				temp_par = new Hashtable<String,String>();			
			}
			else{
				temp_par = node_parent.get(node2);
			}			
			temp_par.put(node1, "");
			node_parent.put(node2, temp_par);
			
			//node1-kid
			if(node_child.containsKey(node1)==false){
				temp_kid = new Hashtable<String,String>();			
			}
			else{
				temp_kid = node_child.get(node1);
			}			
			temp_kid.put(node2, "");
			node_child.put(node1, temp_kid);
			
			
			//from to
			from_to.put(node1+"\t"+node2, "");
			
			//node1
			if(node_neighbor.containsKey(node1)==false){
				temp1 = new Hashtable<String,String>();			
			}
			else{
				temp1 = node_neighbor.get(node1);
			}			
			temp1.put(node2, "");
			node_neighbor.put(node1, temp1);
			//node2
			if(node_neighbor.containsKey(node2)==false){
				temp2 = new Hashtable<String,String>();			
			}
			else{
				temp2 = node_neighbor.get(node2);
			}			
			temp2.put(node1, "");
			node_neighbor.put(node2, temp2);
			}
		in.close();
	}
	
	private static void readTargetList(String targetFile) throws IOException{
		File inputExp = new File(targetFile);
		FileReader fr = new FileReader(inputExp);
		BufferedReader in = new BufferedReader(fr);
		String s;
		while((s=in.readLine())!=null){
			targetList.add(s);			
		}
		in.close();
		
		
	}
	private static void BFS_explore(String sourceNode){
		levelStoreEdge.add(sourceNode);
		levelStoreNode.add(sourceNode);
		visited.put(sourceNode, "");
		ArrayList<String> stack = new ArrayList<String>();
		stack.add(sourceNode);
		String newMember="";
		
		Hashtable <String,Hashtable<String,String>> mode_connect = new Hashtable <String,Hashtable<String,String>> ();
		if(mode.equalsIgnoreCase("up")){
			mode_connect=node_parent;
		}
		else if(mode.equalsIgnoreCase("down")){
			mode_connect=node_child;
		}
		else{
			mode_connect=node_neighbor;
		}
		
		
		while(stack.size()!=0){
			String curNode=stack.get(0);
			stack.remove(0);
			//get neighbor
			String curLevelEdge;			
			curLevelEdge="";		
			if(mode_connect.containsKey(curNode)){				
				for(String neighbor:mode_connect.get(curNode).keySet()){
					
					String newEdgeTotal;
					String newEdge1="";
					String newEdge2="";
					if(from_to.containsKey(neighbor+"\t"+curNode)){						
						newEdge1=neighbor+"\t"+curNode;
						if(visited_edge.containsKey(newEdge1)) {
							newEdge1="";
						}else {						
							visited_edge.put(newEdge1,"");
						}
					}
					
					if(from_to.containsKey(curNode+"\t"+neighbor)){
						newEdge2=curNode+"\t"+neighbor;
						if(visited_edge.containsKey(newEdge2)) {
							newEdge2="";
						}else {						
							visited_edge.put(newEdge2,"");
						}					
					}
					if(!newEdge1.equals("")&&!newEdge2.equals("")){
						newEdgeTotal=newEdge1+","+newEdge2;
					}
					else{
						newEdgeTotal = newEdge1.length()>newEdge2.length()? newEdge1:newEdge2;						
					}
					
					if(curLevelEdge.equals("")){
						curLevelEdge=newEdgeTotal;
					}
					else{
						curLevelEdge=curLevelEdge+","+newEdgeTotal;
					}
					
					
					if(visited.containsKey(neighbor)==false){
					
						
						if(newMember.equals("")){
							newMember=neighbor;
						}
						else{
							newMember=newMember+","+neighbor;
						}
						allLevelStore.put(neighbor,"");						
						visited.put(neighbor, "");
					}
				}
				if(!curLevelEdge.equals("")) {
					levelStoreEdge.add(curLevelEdge);
				}
			}
			if(stack.size()==0){
				if(newMember=="") {
					break;
				}
				levelStoreNode.add(newMember);
				String [] refill =newMember.split(",");
				for(String newUnit:refill){					
					stack.add(newUnit);					
				}
				newMember="";
				//System.out.println(level+"\t"+stack+"\t"+refill.length);
			}
		
			
			
			
			
		}
		
		
		
	}
	private static void outputLevelNode_StepLimit(String outputFile,int maxStep) throws IOException{
		File outputExp = new File(outputFile);
		FileWriter fw = new FileWriter(outputExp);
		BufferedWriter out = new BufferedWriter(fw);
	
		int limit=0;
		if (maxStep==-1) {
			limit=levelStoreNode.size();
		}
		else if(maxStep+1<levelStoreNode.size()){
			limit=maxStep+1;
		}else{
			limit=levelStoreNode.size();
		}
		
		for(int level=0;level<limit;level++){
			for(String ele:levelStoreNode.get(level).split(",")){
				out.write(level+"\t"+ele+"\n");
			}			
		}
	
		
		out.flush();
		out.close();
		
		
	}
	
	private static void outputLevelEdge_StepLimit(String outputFile,int maxStep) throws IOException{
		File outputExp = new File(outputFile);
		FileWriter fw = new FileWriter(outputExp);
		BufferedWriter out = new BufferedWriter(fw);
		out.write("from\tto\n");
		int limit=0;
		if (maxStep==-1) {
			limit=levelStoreEdge.size();
		}
		else if(maxStep+1<levelStoreEdge.size()){
			limit=maxStep+1;
		}else{
			limit=levelStoreEdge.size();
		}
		Hashtable<String,String> node_count= new Hashtable<String,String>();
		Hashtable<String,String> edge_count= new Hashtable<String,String>();
		for(int level=1;level<limit;level++){
			String curEdges[]=levelStoreEdge.get(level).split(",");
		
			
			for(String edge:curEdges){
				edge_count.put(edge, "");
				if(edge.length()==0) {
					continue;
				}
				String temp[]=edge.split("\t");			
				node_count.put(temp[0], "");
				node_count.put(temp[1], "");				
				out.write(edge+"\n");
			}
		}
		//System.out.println(sourceNode+"\t"+"nodeSize"+"\t"+node_count.size()+"\tedgesize\t"+edge_count.size());
		out.flush();
		out.close();
		
		
	}
}
