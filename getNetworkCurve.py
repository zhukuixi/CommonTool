# -*- coding: utf-8 -*-
"""
Created on Mon Feb 13 10:36:41 2023

@author: Kuixi Zhu
"""
import os
import pandas as pd
import sys
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib as mpl

def get_line_number(file_name):
    count = 0
    with open(file_name) as f:
        for i, line in enumerate(f, 2):
            count +=1
    return count

def getCurve():
    out_folder = sys.argv[1]
    files = os.listdir(out_folder)
    files = [f for f in files if os.path.isdir(os.path.join(out_folder,f))]  
    projectFolders = files
    for i in range(len(projectFolders)):
        store = dict()
        currentProjectFolder = os.path.join(out_folder,projectFolders[i])
        # for each project
        projectFiles = os.listdir(currentProjectFolder)        
        projectDays = [f for f in projectFiles if os.path.isdir(os.path.join(currentProjectFolder,f)) and str(f).startswith('day')]      
        projectDays.sort(key=lambda x:int(x.split('day')[1]))        
        for j in range(len(projectDays)):           
            for k in range(1,101):                
                currentMoveFile = os.path.join(currentProjectFolder,projectDays[j],"move_"+str(k)+".txt")
                if os.path.exists(currentMoveFile) and os.stat(currentMoveFile).st_size > 0:
                    moveFile = pd.read_csv(currentMoveFile,skiprows=2,sep="\t")
                    curve = moveFile.iloc[:,-1]
                    if "move_"+str(k) in store:
                        store["move_"+str(k)]  += curve.to_list()
                    else:
                        store["move_"+str(k)]  = curve.to_list()
        ## sorted the store by value's length
        
        store = dict(sorted(store.items(), key=lambda item:len(item[1]),reverse=True))    
        fig, ax = plt.subplots()
        lengthSummary = [len(v) for v in store.values()]        
        store_sortedKeys = list(store.keys())
        df_forDraw  = pd.DataFrame()
        fig, axs = plt.subplots(2)
        for rank in list(range(0,100,20))+[99]:
            currentKey = store_sortedKeys[rank]
            temp_x = list(range(len(store[currentKey])))
            temp_y = store[currentKey]
            temp_x = temp_x[0::100]
            temp_y = temp_y[0::100]
            temp_df = pd.DataFrame({'x':temp_x,'y':temp_y,'rank':rank+1})                                   
            df_forDraw = pd.concat([df_forDraw,temp_df])

        sns.scatterplot(x='x',y='y',data=df_forDraw,hue="rank",ax=axs[0],palette="flare")
        sns.histplot(lengthSummary,ax = axs[1])
        fig.savefig(os.path.join(out_folder,"CurveSummary_"+projectFolders[i]+".png"))   
        
        # maxLength = 0         
        # maxMoveFile = ""
        # minLength = np.inf
        # minMoveFile = ""
        # for key in store:
        #     if len(store[key])>maxLength:
        #         maxLength = len(store[key])
        #         maxMoveFile = key
        #     if len(store[key])<minLength:
        #         minLength = len(store[key])
        #         minMoveFile = key                 
        # maxCurve = store[maxMoveFile]
        # minCurve = store[minMoveFile]       
        # fig, axs = plt.subplots(ncols=2)
        # sns.scatterplot(range(len(maxCurve)),maxCurve,ax=axs[0]).set(title=maxMoveFile)
        # sns.scatterplot(range(len(minCurve)),minCurve,ax=axs[1]).set(title=minMoveFile)          
        # fig.savefig(os.path.join(out_folder,"CurveSummary_"+projectFolders[i]+".png"))                
            
        

if __name__ == "__main__":
    print("start")
    getCurve()
    print("end")