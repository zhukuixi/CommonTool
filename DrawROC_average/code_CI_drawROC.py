# -*- coding: utf-8 -*-
"""
Created on Thu Jul 15 15:26:55 2021

@author: Kuixi Zhu
"""
import pandas as pd
import numpy as np
from sklearn.metrics import roc_curve,auc
from numpy import interp
import matplotlib.pyplot as plt


chooseFile = pd.read_csv('/xdisk/ruichang/mig2020/rsgrps/ruichang/kuixizhu/sc/orga/work/zhuk01/Python/layerMadness/summary/choose4.txt',sep="\t")
## Delete empty rows
chooseFile.replace('', np.nan, inplace=True)
chooseFile.dropna( inplace=True)
chooseFile['Config_forDraw']=[getName(e) for e in chooseFile.Config]

storeROC = pd.read_csv('/xdisk/ruichang/mig2020/rsgrps/ruichang/kuixizhu/sc/orga/work/zhuk01/Python/layerMadness/summary/CI_ROCrecord_mass.txt',sep="\t")
storeROC_FF_DE = pd.read_csv('/xdisk/ruichang/mig2020/rsgrps/ruichang/kuixizhu/sc/orga/work/zhuk01/Python/layerMadness/summary/CI_ROCrecord_FullFeature_DE.txt',sep="\t")

subgroupList = ['A1','A2','A3','A4','B1','B2','B3','B4']

drawConfigList = ['All','All_Clinic','DE','DE_Clinic','Network','Network_DE','Network_Clinic','Network_DE_Clinic']
drawConfigList = drawConfigList[-1::-1]


colors = ['black','violet','indigo','blue','green', 'yellow','orange' ,'red']
colors = colors[-1::-1]

for subgroup in subgroupList:
    plt.figure()
    colorCount = -1
    for drawConfig in drawConfigList:
        colorCount+=1
        _,cur_clf,cur_percentile,_auc,cur_layer,cur_subgroup,cur_config,config_forDraw = chooseFile.loc[(chooseFile.Subgroup==subgroup)&(chooseFile.Config_forDraw==drawConfig),:].iloc[0].iloc[0:]
        tprs = []
        base_fpr = np.linspace(0, 1, 101)
    
        if cur_layer.startswith('Layer'):
            tmp = storeROC.loc[(storeROC.test_clf==cur_clf)&(storeROC.test_percentile==cur_percentile)&(storeROC.layer==cur_layer)&(storeROC.subgroup==cur_subgroup)&(storeROC.config==cur_config),:]
        else: ##DE,FE
            tmp = storeROC_FF_DE.loc[(storeROC_FF_DE.test_clf==cur_clf)&(storeROC_FF_DE.test_percentile==cur_percentile)&(storeROC_FF_DE.layer==cur_layer)&(storeROC_FF_DE.subgroup==cur_subgroup)&(storeROC_FF_DE.config==cur_config),:]
        
        for cur_time in range(10):
            fpr, tpr, _ = roc_curve(tmp.test_label, tmp.test_proba,pos_label='CN')
            tpr_inter = interp(base_fpr, fpr, tpr)
            tpr_inter[0] = 0 
            tprs.append(tpr_inter)
                            
        tprs = np.array(tprs)
        mean_tprs = tprs.mean(axis=0)
        mean_tprs[-1] = 1.0
        #std = tprs.std(axis=0)
        mean_auc = auc(base_fpr,mean_tprs)
        
  
        lw = 1
        plt.plot(base_fpr, mean_tprs,color=colors[colorCount],
                 lw=lw, label=drawConfig+' %0.2f' % mean_auc)
    plt.plot([0, 1], [0, 1], color='grey', lw=lw, linestyle='--')
    plt.xlim([0.0, 1.0])
    plt.ylim([0.0, 1.05])
    plt.xlabel('False Positive Rate')
    plt.ylabel('True Positive Rate')
    plt.title(subgroup)
    plt.legend(loc="lower right")
    plt.savefig('/xdisk/ruichang/mig2020/rsgrps/ruichang/kuixizhu/sc/orga/work/zhuk01/Python/layerMadness/summary/ROC/'+subgroup+'_.png',dpi=600)
       
       
        

