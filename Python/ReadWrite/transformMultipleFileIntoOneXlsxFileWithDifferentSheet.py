# -*- coding: utf-8 -*-
"""
Created on Thu May 13 20:38:35 2021

@author: Kuixi Zhu
"""
import pandas as pd
from openpyxl import load_workbook

from os import listdir
from os.path import isfile, join

mayo_folder = 'F:/MountSinai_DataBackup/mssn/Micro_Neuron_MAYO/microglialPaper_Figure/output/Module_Enrichment/MAYO/'
rosmap_folder = 'F:/MountSinai_DataBackup/mssn/Micro_Neuron_MAYO/microglialPaper_Figure/output/Module_Enrichment/ROSMAP/'

mayo_files = [f for f in listdir(mayo_folder) if isfile(join(mayo_folder, f))]
rosmap_files = [f for f in listdir(rosmap_folder) if isfile(join(rosmap_folder, f))]


writer = pd.ExcelWriter('F:/MountSinai_DataBackup/mssn/Micro_Neuron_MAYO/microglialPaper_Figure/output/Module_Enrichment/joo.xlsx',engine='openpyxl')#可以向不同的sheet写入数据



for file in mayo_files:
    if file=="grey.txt":
        continue
    tmp = pd.read_csv(mayo_folder+file,sep="\t")
    tmp.to_excel(writer, sheet_name="MAYO_"+file.split(".")[0])#将数据写入excel中的sheet表,sheet_name改变后即是新增一个sheet

for file in rosmap_files:
    if file=="grey.txt":
        continue
    tmp = pd.read_csv(rosmap_folder+file,sep="\t")
    tmp.to_excel(writer, sheet_name="ROSMAP_"+file.split(".")[0])#将数据写入excel中的sheet表,sheet_name改变后即是新增一个sheet


writer.save()#保存