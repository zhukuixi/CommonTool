# -*- coding: utf-8 -*-
"""
Created on Thu Oct 28 12:11:00 2021

@author: Kuixi Zhu
"""
import pandas as pd
import numpy as np
from sklearn.metrics import roc_curve,auc
from numpy import interp
import matplotlib.pyplot as plt

def DrawAverageROC(label_matrix,proba_matrix,positive_label,output_title,output_filename):
    tprs = []
    base_fpr = np.linspace(0, 1, 101)               
    for i in range(label_matrix.shape[0]):
        fpr, tpr, _ = roc_curve(label_matrix.iloc[i,:], proba_matrix.iloc[i,:],pos_label=positive_label)
        tpr_inter = interp(base_fpr, fpr, tpr)
        tpr_inter[0] = 0 
        tprs.append(tpr_inter)
                            
    tprs = np.array(tprs)
    mean_tprs = tprs.mean(axis=0)
    mean_tprs[-1] = 1.0
    mean_auc = auc(base_fpr,mean_tprs)    
  
    lw = 1
    plt.plot(base_fpr, mean_tprs,
                 lw=lw, label='AUC:'+' %0.2f' % mean_auc)
    plt.plot([0, 1], [0, 1], color='grey', lw=lw, linestyle='--')
    plt.xlim([0.0, 1.0])
    plt.ylim([0.0, 1.05])
    plt.xlabel('False Positive Rate')
    plt.ylabel('True Positive Rate')
    plt.title(output_title)
    plt.legend(loc="lower right")
    plt.savefig(output_filename,dpi=600)
       

def DrawSingleROC(label,proba,positive_label,output_title,output_filename):
    base_fpr = np.linspace(0, 1, 101)               
 
    fpr, tpr, _ = roc_curve(label, proba,pos_label=positive_label)
    tpr_inter = interp(base_fpr, fpr, tpr)
    tpr_inter[0] = 0 
    tpr_inter[-1] = 1.0
    current_auc = auc(base_fpr,tpr_inter)    
  
    lw = 1
    plt.plot(base_fpr, tpr_inter,
                 lw=lw, label='AUC:'+' %0.2f' % current_auc)
    plt.plot([0, 1], [0, 1], color='grey', lw=lw, linestyle='--')
    plt.xlim([0.0, 1.0])
    plt.ylim([0.0, 1.05])
    plt.xlabel('False Positive Rate')
    plt.ylabel('True Positive Rate')
    plt.title('AUC:'+' %0.2f' % current_auc)
    plt.legend(loc="lower right")
    plt.savefig(output_filename,dpi=600)
       