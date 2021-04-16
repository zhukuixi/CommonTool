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

// The target is the corresponding KD for each network

public class radiusExplorer_MemberNameOnly_up_down_MassNetMassTargetMassMode_forJar {
	
	
	
	
	
	
	
	static Hashtable<String,Hashtable<String,String>> node_neighbor=new Hashtable <String,Hashtable<String,String>> ();
	static Hashtable<String,Hashtable<String,String>> node_parent=new Hashtable <String,Hashtable<String,String>> ();
	static Hashtable<String,Hashtable<String,String>> node_child=new Hashtable <String,Hashtable<String,String>> ();
	
	static ArrayList<String> targetList= new ArrayList<String>();
	static ArrayList<String> modeList= new ArrayList<String>();

	static Hashtable<String,String> visited = new Hashtable<String,String>();
	static ArrayList<String> levelStore= new ArrayList<String>(); 
	
	static Hashtable<String,String> allLevelStore = new Hashtable<String,String>();

	static int index;
	static String mode;
	

	
	public static void main(String args[]) throws IOException{
		
		String netFolder= args[0];
		String targetFile = args[1];
		String modeFile = args[2];
		String levelout = args[3];
	
		//	java -jar radiusExplorer.jar F:/MountSinai_DataBackup/mssn/ADNI1_ADNI2_OCT/Direction_1/Network_CI/network/ F:/MountSinai_DataBackup/mssn/ADNI1_ADNI2_OCT/Direction_1/Network_CI/target.txt F:/MountSinai_DataBackup/mssn/ADNI1_ADNI2_OCT/Direction_1/Network_CI/mode.txt F:/MountSinai_DataBackup/mssn/ADNI1_ADNI2_OCT/Direction_1/Network_CI/level/

		

		getTarget(targetFile);
		getMode(modeFile);
		getLevelOut(netFolder,levelout);		
				
	}
	
	public static void getTarget(String targetFile) throws IOException{
		File inputExp = new File(targetFile);
		FileReader fr = new FileReader(inputExp);
		BufferedReader in = new BufferedReader(fr);
		String s;
		while((s=in.readLine())!=null){
			targetList.add(s);
		}
		in.close();		
	}
	public static void getMode(String modeFile) throws IOException{
		File inputExp = new File(modeFile);
		FileReader fr = new FileReader(inputExp);
		BufferedReader in = new BufferedReader(fr);
		String s;
		while((s=in.readLine())!=null){
			modeList.add(s);
		}
		in.close();		
	}
	public static void getLevelOut(String netFolder,String levelout) throws IOException {
		
		File f = new File(netFolder);
		
		int count=0;
		for(String net:f.list()) { //net
			count++;			
			System.out.println(count+"/"+f.list().length);
			System.out.println(net);
			node_neighbor.clear();
			node_parent.clear();
			node_child.clear();
			readNetwork(netFolder+net);
			new File(levelout+net+"/").mkdirs();
			String cwd=levelout+net+"/";
			
			for(String target : targetList) { //target		
				for(int j=0;j<modeList.size();j++){  //mode
					visited.clear();
					levelStore.clear();
					allLevelStore.clear();				
					mode=modeList.get(j); //"up/down/radius"
					String targetIn = target;				
					//System.out.println(target+"\t"+targetIn);
					BFS_explore(targetIn);
					String outputFile=cwd+target+"_"+mode+".txt";	
					outputLevel(outputFile,target);
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
			String edge[]=s.split("\t");
			String node1=edge[0];
			String node2=edge[1];
			
			

			
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
			
			
			Hashtable<String,String> temp1;
			Hashtable<String,String> temp2;					
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
	private static void BFS_explore(String sourceNode){
		levelStore.add(sourceNode);
		visited.put(sourceNode, "");
		ArrayList<String> stack = new ArrayList<String>();
		stack.add(sourceNode);
		
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
		String curLevelMember="";
		while(stack.size()!=0){
		
			String curNode=stack.get(0);
			stack.remove(0);
			if(mode_connect.containsKey(curNode)){	
				for(String neighbor:mode_connect.get(curNode).keySet()){
					if(visited.containsKey(neighbor)==false){
						allLevelStore.put(neighbor,"");
						if(curLevelMember.equals("")){
							curLevelMember=neighbor;
							}
						else{
							curLevelMember=curLevelMember+","+neighbor;
							}
						visited.put(neighbor, "");
						}
					}
				}
			
			if(stack.size()==0){			
				if(curLevelMember.equals("")){
					break;
					}			
				levelStore.add(curLevelMember);
				//levelStore.set(level, curLevelMember);
			
				String [] refill =curLevelMember.split(",");
				for(String newMember:refill){
					stack.add(newMember);
				}
				curLevelMember="";
				//System.out.println(level+"\t"+stack+"\t"+refill.length);
				
			
			}
		
			
			
			
			
		}
		
		
		
	}
	
	private static void outputLevel(String outputFile,String targetIn) throws IOException{
		File outputExp = new File(outputFile);
		FileWriter fw = new FileWriter(outputExp);
		BufferedWriter out = new BufferedWriter(fw);
	
		
		for(int level=0;level<levelStore.size();level++){
			for(String ele:levelStore.get(level).split(",")){
				out.write(level+"\t"+ele+"\n");
			}			
		}
	
		
		out.flush();
		out.close();
		
		
	}
	
}
