# -*- coding: utf-8 -*-
"""
Created on Tue May 24 13:48:10 2022

@author: Kuixi Zhu
"""

            
            
            
import os
import matplotlib.pyplot as plt
import operator


def get_line_number(file_name):
    count = 0
    with open(file_name) as f:
        for i, line in enumerate(f, 2):
            count +=1
    return count


outputFolderName = "/xdisk/ruichang/mig2020/rsgrps/ruichang/kuixizhu/sc/orga/work/zhuk01/NetworkConstruction/AMPAD_Astro_Endo_Oligo/output/rosmap_GFAP/"
folders = os.listdir(outputFolderName)
days = [f for f in folders if 'day' in f]
days = sorted(days)
dict_store={}
for day in days:
    print(day)
    files = os.listdir(os.path.join(outputFolderName,day))
    movefiles =  [f for f in files if 'move' in f]
    for f in movefiles:
        if f not in dict_store:
            dict_store[f] = get_line_number(os.path.join(outputFolderName,day,f))
        else:
            dict_store[f] += get_line_number(os.path.join(outputFolderName,day,f))
    
sorted_dict_store = {k: v for k, v in sorted(dict_store.items(), key=lambda item: item[1])}
print(sorted_dict_store)

minIndex = 44
maxIndex = 3

minStore , maxStore = [],[]

for day in days:
    minFileName = os.path.join(outputFolderName,day,"move_"+str(minIndex)+".txt")
    maxFileName =  os.path.join(outputFolderName,day,"move_"+str(maxIndex)+".txt")
    if os.path.exists(minFileName):
        with open(minFileName) as f:
            minLines = f.readlines()[2:]
            minStore.extend(minLines)
    if os.path.exists(maxFileName):
        with open(maxFileName) as f:
            maxLines = f.readlines()[2:]
            maxStore.extend(maxLines)


minFigure=[float(str.split(line,"\t")[-1][:-1]) for line in minStore ]
maxFigure=[float(str.split(line,"\t")[-1][:-1]) for line in maxStore ]


figure, axis = plt.subplots(1, 2)
axis[0].scatter(x=range(len(minFigure)), y=minFigure, c ="blue")
axis[0].set_title("min")
  
axis[1].scatter(x=range(len(maxFigure)), y=maxFigure, c ="blue")
axis[1].set_title("max")
figure.savefig('rosmap.png')
















                                
           