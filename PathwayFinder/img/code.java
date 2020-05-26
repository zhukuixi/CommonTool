
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Hashtable;
import java.util.List;
import java.util.Set;

public class ImproveBackwardForward_pathwayFinder_2ColumnStyle_FORJAR {
	static Hashtable<String,String> from_to=new Hashtable<String,String> (); //key is from to, value is useless ""
	static Hashtable<String,String> from_to_origin=new Hashtable<String,String> (); //key is from to, value is useless ""

	static Hashtable<String,String> node_list = new Hashtable<String,String> ();
	static ArrayList<String> node_array = new ArrayList<String>();

	static Hashtable<String,Hashtable<String,String>> node_child=new Hashtable <String,Hashtable<String,String>> ();
	static Hashtable<String,Hashtable<String,String>> node_parent=new Hashtable <String,Hashtable<String,String>> ();


	static Hashtable<String,String> finalEdge= new Hashtable<String,String>();
	static Hashtable<String,String> finalNode = new Hashtable<String,String>();


	static Hashtable<String,String> finalEdge_open= new Hashtable<String,String>();
	static Hashtable<String,String> finalNode_open = new Hashtable<String,String>();

	static ArrayList<String> targetList= new ArrayList<String>();

	//static Hashtable<String,String> miss = new Hashtable<String,String>();

	static String sourceNode;
	static String DirectionMode,endMode,streamFlowMode;
	static int K;
	public static void main(String args[]) throws IOException{



		K=Integer.parseInt(args[0]);
		String networkFile=args[1];
		String targetFile=args[2];
		String outputFile=args[3];
	 	DirectionMode=args[4];
	 	endMode=args[5];
	 	streamFlowMode=args[6];



		from_to.clear();
		from_to_origin.clear();
		node_list.clear();
		node_array.clear();
		node_child.clear();
		node_parent.clear();
		finalEdge.clear();
		finalNode.clear();
		finalEdge_open.clear();
		finalNode_open.clear();
		targetList.clear();

//	K=i;
//	String networkFile="D:/MountSinai_DataBackup/mssn/Micro_Neuron_MAYO/networkPrediction_new/NET/raw/ciPG_ROSMAP_CD68_seed_0.3.txt";
// String targetFile="D:/MountSinai_DataBackup/mssn/Micro_Neuron_MAYO/networkPrediction_new/NET/target.txt";
//	DirectionMode ="directed";//"directed" or "undirected"
//	endMode="open"; //"open" or "closed"
//	streamFlowMode="down"; //"up" or "down"
//String outputFile="D:/MountSinai_DataBackup/mssn/Micro_Neuron_MAYO/networkPrediction_new/NET/pathFinder_999/ciPG_ROSMAP_CD68_seed_0.3.txt";



		readNetwork(networkFile);
		readTargetList(targetFile);
		fun();
		outputLevel(outputFile);




	}

	private static void fun(){
		if(endMode.equals("open")){


			ArrayList<Hashtable<String,String>> forward = new ArrayList<Hashtable<String,String>>();
			//forward

			//k=0
			Hashtable<String,String> k_0_forward= new Hashtable<String,String>();
			for(String ele:targetList){
				k_0_forward.put(ele, "");
				finalNode_open.put(ele, "");
			}
			forward.add(k_0_forward);

			for(int i=1;i<=K;i++){
				Hashtable<String,String> k_i_forward = new Hashtable<String,String>(); //current layer we are going to add it on
				Hashtable<String,String> k_iminus1_forward=forward.get(i-1);   //previous -1 layer


				for(String ele:k_iminus1_forward.keySet()){ //each element in the i-1 layer
					if(node_child.containsKey(ele)){
						for(String kid:node_child.get(ele).keySet()){
								k_i_forward.put(kid,"");
								finalNode_open.put(kid, "");
								finalEdge_open.put(ele+"\t"+kid,"");
							}
					}
				}
				forward.add(k_i_forward);
			}


			return;
		}




		ArrayList<Hashtable<String,String>> backward = new ArrayList<Hashtable<String,String>>();
		ArrayList<Hashtable<String,String>> forward = new ArrayList<Hashtable<String,String>>();

		Hashtable<String,String> forward_store = new Hashtable<String,String> ();



		//backward

		//k=0
		Hashtable<String,String> k_0_backward = new Hashtable<String,String>();
		for(String ele:targetList){
			k_0_backward.put(ele, "");
			//backward_store.put(ele, "");
		}

		backward.add(k_0_backward);
		//k=1~K
		for(int i=1;i<=K;i++){
			//System.out.println("backward "+i+"/"+K);
			Hashtable<String,String> k_i_backward = new Hashtable<String,String>(); //current layer we are going to add it on
			Hashtable<String,String> k_iminus1_backward=backward.get(i-1);   //previous -1 layer

			for(String ele:k_iminus1_backward.keySet()){ //each element in the i-1 layer
				if(node_parent.containsKey(ele)){
					for(String par:node_parent.get(ele).keySet()){
						if(i==K){
							if(targetList.contains(par)){
								k_i_backward.put(par,"");
							}
						}
						else{
								k_i_backward.put(par,"");
						}
					}
				}
			}

			backward.add(k_i_backward);
		}



		System.out.println();

		/*
		//forward

		Hashtable<String,String> k_targetBorn_forward=new Hashtable<String,String>();
		for(int i=K;i>=0;i--){
			//System.out.println("forward "+i+"/"+K);
			Hashtable<String,String> k_targetBorn_forward_temp=new Hashtable<String,String>();
			Hashtable<String,String> k_i_backward = backward.get(i);
			Hashtable<String,String> k_i_forward = new Hashtable<String,String>();


			for(String ele:k_i_backward.keySet()){ //each element in the i layer


				if(i>0 && (targetList.contains(ele)||k_targetBorn_forward.containsKey(ele))){  //it is target itself or it is descedent of target

					k_i_forward.put(ele, "");             //mark layer k
					forward_store.put(ele, "");
					if(node_child.containsKey(ele)){
						for(String child:node_child.get(ele).keySet()){  //mark guidance layer temp
							k_targetBorn_forward_temp.put(child, "");
							}
					}
				}
				else if(i==0 && k_targetBorn_forward.containsKey(ele)){  //it is descedent of target

					k_i_forward.put(ele, "");             //mark layer k
					forward_store.put(ele, "");
					if(node_child.containsKey(ele)){
						for(String child:node_child.get(ele).keySet()){  //mark guidance layer temp
							k_targetBorn_forward_temp.put(child, "");
							}
					}
				}
			}
			k_targetBorn_forward.clear();
			for(String key:k_targetBorn_forward_temp.keySet()){
				k_targetBorn_forward.put(key, "");
			}
			forward.add(k_i_forward);
		}
	*/
		Hashtable<String,String> k_targetBorn_forward_final=new Hashtable<String,String>();
		for(int i=K;i>=0;i--){
			Hashtable<String,String> k_i_backward = backward.get(i);
			Hashtable<String,String> k_targetBorn_forward_temp=new Hashtable<String,String>();
			for(String ele:k_i_backward.keySet()){
				if(i==K){
						if(targetList.contains(ele)){
							if(node_child.containsKey(ele)){
								for(String des:node_child.get(ele).keySet()){
									if(backward.get(i-1).containsKey(des)){
										k_targetBorn_forward_temp.put(des, "");
										finalEdge.put(ele+"\t"+des, "");
										finalNode.put(ele, "");
										finalNode.put(des, "");
									}
								}
							}
						}

				}


				if(i<K&i>0){
					if(targetList.contains(ele) || k_targetBorn_forward_final.containsKey(ele) ){
							if(node_child.containsKey(ele)){
								for(String des:node_child.get(ele).keySet()){
									if(backward.get(i-1).containsKey(des)){
										k_targetBorn_forward_temp.put(des, "");
										finalEdge.put(ele+"\t"+des, "");
										finalNode.put(ele, "");
										finalNode.put(des, "");
									}
								}
							}
						}

				}

			}
			k_targetBorn_forward_final.clear();
			for(String key:k_targetBorn_forward_temp.keySet()){
				k_targetBorn_forward_final.put(key, "");
			}
		}


	}
	private static void readNetwork(String networkFile) throws IOException{
		node_list.clear();
		node_parent.clear();
		node_child.clear();
		from_to.clear();

		System.out.println(networkFile);
		File inputExp = new File(networkFile);
		FileReader fr = new FileReader(inputExp);
		BufferedReader in = new BufferedReader(fr);
		String s;

		while((s=in.readLine())!=null){

			String edge[]=s.split("\t");
			String node1 = null,node2 = null;
			node1=edge[0];
			node2=edge[1];
			from_to_origin.put(node1+"\t"+node2, "");

			Hashtable<String,String> temp_kid;
			Hashtable<String,String> temp_parent;
			node_list.put(node1, "");
			node_list.put(node2, "");
			if(DirectionMode.equals("directed")){
				if(streamFlowMode.equals("down")){
				//node2-par
					if(node_parent.containsKey(node2)==false){
						temp_parent = new Hashtable<String,String>();
					}
					else{
						temp_parent = node_parent.get(node2);
					}
					temp_parent.put(node1, "");
					node_parent.put(node2, temp_parent);


					//node1-kid
					if(node_child.containsKey(node1)==false){
						temp_kid = new Hashtable<String,String>();
					}
					else{
						temp_kid = node_child.get(node1);
					}
					temp_kid.put(node2, "");
					node_child.put(node1, temp_kid);
					}
				else if(streamFlowMode.equals("up")){
					//node1-par
					if(node_parent.containsKey(node1)==false){
						temp_parent = new Hashtable<String,String>();
					}
					else{
						temp_parent = node_parent.get(node1);
					}
					temp_parent.put(node2, "");
					node_parent.put(node1, temp_parent);


					//node2-kid
					if(node_child.containsKey(node2)==false){
						temp_kid = new Hashtable<String,String>();
					}
					else{
						temp_kid = node_child.get(node2);
					}
					temp_kid.put(node1, "");
					node_child.put(node2, temp_kid);
					}
			}





			if(DirectionMode.equals("undirected")){
				//node2-par
				if(node_parent.containsKey(node2)==false){
					temp_parent = new Hashtable<String,String>();
				}
				else{
					temp_parent = node_parent.get(node2);
				}
				temp_parent.put(node1, "");
				node_parent.put(node2, temp_parent);


				//node1-kid
				if(node_child.containsKey(node1)==false){
					temp_kid = new Hashtable<String,String>();
				}
				else{
					temp_kid = node_child.get(node1);
				}
				temp_kid.put(node2, "");
				node_child.put(node1, temp_kid);


				//node1-par
				if(node_parent.containsKey(node1)==false){
					temp_parent = new Hashtable<String,String>();
				}
				else{
					temp_parent = node_parent.get(node1);
				}
				temp_parent.put(node2, "");
				node_parent.put(node1, temp_parent);


				//node2-kid
				if(node_child.containsKey(node2)==false){
					temp_kid = new Hashtable<String,String>();
				}
				else{
					temp_kid = node_child.get(node2);
				}
				temp_kid.put(node1, "");
				node_child.put(node2, temp_kid);

			}


		}
		in.close();

		}
	private static void readTargetList(String targetFile) throws IOException{
		File inputExp = new File(targetFile);
		FileReader fr = new FileReader(inputExp);
		BufferedReader in = new BufferedReader(fr);
		String s;
		int count=0;
		while((s=in.readLine())!=null){

			if(node_list.containsKey(s)==false){
				System.out.println(s+"\t does not exist in the network");
				count++;
				}
			else{
				targetList.add(s);
			}
		}
		in.close();
		System.out.println("Totally,"+count+" target genes are not in the network!");


	}
	/*
	private static void outputLevel(String outputFile) throws IOException{
		File outputExp = new File(outputFile);
		FileWriter fw = new FileWriter(outputExp);
		BufferedWriter out = new BufferedWriter(fw);
		if(endMode.equals("closed")){
			for(String edge:finalEdge.keySet()){
				out.write(edge+"\n");
			}
		}
		else if(endMode.equals("open")){
			for(String edge:finalEdge_open.keySet()){
				out.write(edge+"\n");
			}
		}
		out.flush();
		out.close();


	}*/

	private static void outputLevel(String outputFile) throws IOException{
		String temp[]=outputFile.split("/");
		int LastLength=temp[temp.length-1].length();
		//System.out.println(outputFile+"\n"+Arrays.toString(temp));
		String folder=outputFile.substring(0, outputFile.length()-LastLength);
	//	System.out.println(folder);



	  new File(folder).mkdirs();

		File outputExp = new File(outputFile);

		FileWriter fw = new FileWriter(outputExp);
		BufferedWriter out = new BufferedWriter(fw);
		Hashtable<String,String> outEdgeStore = new Hashtable<String,String> ();

		if(endMode.equals("closed")){

			if(DirectionMode.equals("directed")){
				for(String edge:finalEdge.keySet()){
					if(streamFlowMode.equals("down")){
						if(from_to_origin.containsKey(edge)) {
							outEdgeStore.put(edge,"");
						}
					}
					else if(streamFlowMode.equals("up")){
						String dir[]=edge.split("\t");
						if(from_to_origin.containsKey(dir[1]+"\t"+dir[0])) {
							outEdgeStore.put(dir[1]+"\t"+dir[0],"");
						}
					}
				}
			}
			else if(DirectionMode.equals("undirected")){
				for(String edge:finalEdge.keySet()){
					String dir[]=edge.split("\t");
					if(from_to_origin.containsKey(edge)) {
						outEdgeStore.put(edge,"");
					}
					else if(from_to_origin.containsKey(dir[1]+"\t"+dir[0])){
						outEdgeStore.put(dir[1]+"\t"+dir[0],"");
					}
				}

			}



		}

		else if(endMode.equals("open")){

			for(String edge:finalEdge_open.keySet()){
				if(DirectionMode.equals("directed")){
					if(streamFlowMode.equals("down")){
						if(from_to_origin.containsKey(edge)){
								outEdgeStore.put(edge,"");
							}
						}
						else if(streamFlowMode.equals("up")){
							String dir[]=edge.split("\t");
							if(from_to_origin.containsKey(dir[1]+"\t"+dir[0])) {
								outEdgeStore.put(dir[1]+"\t"+dir[0],"");
							}
						}
					}
				else if(DirectionMode.equals("undirected")){

					String dir[]=edge.split("\t");
					if(from_to_origin.containsKey(edge)) {
						outEdgeStore.put(edge,"");
					}

					else if(from_to_origin.containsKey(dir[1]+"\t"+dir[0])) {
						outEdgeStore.put(dir[1]+"\t"+dir[0],"");
					}


				}
			}

		}
		for(String ele:outEdgeStore.keySet()) {
			out.write(ele+"\n");
		}
		out.flush();
		out.close();


	}


}