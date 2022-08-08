# -*- coding: utf-8 -*-
"""
Created on Wed Jul  6 11:06:16 2022

@author: Kuixi Zhu
"""

import pandas as pd
from os import listdir
from os.path import isfile, join

mypath = 'D:/work/BuildNetwork/LBD_protein/KDA/KDA_summary/raw/output'
files = [f for f in listdir(mypath) if isfile(join(mypath, f))]
nameAppear= {}

# each file is a column!
for f in files:
    tmp = pd.read_csv(join(mypath,f),sep="\t")
    for i in range(tmp.shape[0]):
        name,freq = tmp.iloc[i,0], tmp.iloc[i,1]
        if name not in nameAppear:
            tmp_dict = dict(zip(files,[0]*len(files)))             
        else:
            tmp_dict = nameAppear[name]
        tmp_dict[f] = freq
        nameAppear[name] = tmp_dict       
    
finalKDA = pd.DataFrame(nameAppear).transpose()
finalKDA['rowSum'] = finalKDA.apply(sum,axis=1)
finalKDA.sort_values("rowSum",ascending=False,inplace=True)
finalKDA.to_csv("D:/work/BuildNetwork/LBD_protein/KDA/KDA_summary/KDA_sorted.txt",sep="\t")



################################  FOR EACH SPECIFIC MODULE #############################
# Treat each module differently

import os
import pandas as pd
rootdir = 'D:/work/BuildNetwork/AMPAD/2021_AMPAD_Astro_Endo_Oligo/NetworkFolder_template/KDA/KDA_output/MAYO_GFAP/'

files_store = []
for subdir, dirs, files in os.walk(rootdir):
    for file in files:
       category = subdir.split("/")[-1]  
       columnName = category+"~"+file
       files_store.append(columnName)
       
nameAppear= {}
for subdir, dirs, files in os.walk(rootdir):
    for file in files:
       category = subdir.split("/")[-1]    
       columnName = category+"~"+file
       kdFile = pd.read_csv(os.path.join(subdir, file),sep="\t")
       keyDriver = kdFile.keydrivers.loc[kdFile.keydriver==1]
       for kd in keyDriver:
           if kd not in nameAppear:
               tmp_dict = dict(zip(files_store,[0]*len(files_store)))             
           else:
               tmp_dict = nameAppear[kd]
           tmp_dict[columnName] += 1
           nameAppear[kd] = tmp_dict 
           
finalKDA = pd.DataFrame(nameAppear).transpose()
            
               

# Read in Module Enriched with DE
ModuleEnrichedDeFile = pd.read_csv("D:/work/BuildNetwork/AMPAD/2021_AMPAD_Astro_Endo_Oligo/NetworkFolder_template/KDA/module_de_enrichment/MAYO_GFAP/output/DE_Module_Enrichment.txt",sep="\t")       
ModuleEnrichedDe = ModuleEnrichedDeFile.module.loc[ModuleEnrichedDeFile.fdr<0.05].to_list()

interestedColumn = []
for c in finalKDA.columns.values:
    elements =  c.split("_") 
    if any([dm in elements for dm in ModuleEnrichedDe]):
        interestedColumn.append(c)
    

finalKDA['rowSum_allModule_de'] = finalKDA.apply(sum,axis=1)               
finalKDA['rowSum_deModule_de'] = finalKDA.loc[:,interestedColumn].apply(sum,axis=1)   
finalKDA['rowSum_deModule_de']  += finalKDA['de~SOLO_keydriver.xls'] 
finalKDA.sort_values(['rowSum_deModule_de','rowSum_allModule_de'],ascending=False,inplace=True)
finalKDA.to_csv("D:/work/BuildNetwork/AMPAD/2021_AMPAD_Astro_Endo_Oligo/NetworkFolder_template/KDA/KDA_summary/processed_summary/KDA_sorted_MAYO_GFAP_perModule.txt",sep="\t")