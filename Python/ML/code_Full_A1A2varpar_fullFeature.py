import sys #access to system parameters https://docs.python.org/3/library/sys.html
print("Python version: {}". format(sys.version))

import pandas as pd #collection of functions for data processing and analysis modeled after R dataframes with SQL like features
print("pandas version: {}". format(pd.__version__))
pd.set_option('display.max_columns', None)

import matplotlib #collection of functions for scientific and publication-ready visualization
print("matplotlib version: {}". format(matplotlib.__version__))

import numpy as np #foundational package for scientific computing
print("NumPy version: {}". format(np.__version__))

import scipy as sp #collection of functions for scientific computing and advance mathematics
print("SciPy version: {}". format(sp.__version__)) 


import sklearn #collection of machine learning algorithms
print("scikit-learn version: {}". format(sklearn.__version__))

#ignore warnings
import warnings
warnings.filterwarnings('ignore')


from sklearn import ensemble
from xgboost import XGBClassifier

#Common Model Helpers
import sys
import copy

#Visualization
from sklearn.model_selection import train_test_split
import numpy as np

from sklearn.model_selection import StratifiedKFold
from sklearn.preprocessing import StandardScaler

from sklearn.model_selection import cross_val_score

from eli5.sklearn import PermutationImportance
from sklearn.feature_selection import SelectFromModel
# def warn(*args, **kwargs):
#     pass

from pathlib import Path

# import warnings
# warnings.warn = warn

b = range(1,16)


sys_parallelIndex = int(sys.argv[1])
sys_layerCut = float(sys.argv[2])
layer_ind = b[sys_parallelIndex]
percentage_cut = sys_layerCut
outputDir = sys.argv[3]
Flag_Clinical = sys.argv[4] ## ClinicalYes  or ClinicalNo
Flag_DE = sys.argv[5]       ## DEYes   or DENo
Flag_Radius = sys.argv[6]   ## RadYes or RadNo

print("ha")

import os


#adjusted data (B4+V12)
outFolder = '/xdisk/ruichang/mig2020/rsgrps/ruichang/kuixizhu/sc/orga/work/zhuk01/Python/layerMadness/output/'+outputDir+'/'

dataFolder = ''
layerFolder = ''

if Flag_Clinical=="ClinicalYes":
    dataFolder = '/xdisk/ruichang/mig2020/rsgrps/ruichang/kuixizhu/sc/orga/work/zhuk01/Python/layerMadness/input/data_withClinical/'
else:
    dataFolder = '/xdisk/ruichang/mig2020/rsgrps/ruichang/kuixizhu/sc/orga/work/zhuk01/Python/layerMadness/input/data/'
data_name=os.listdir(dataFolder)
data_name = [e for e in data_name if 'ML_' in e]


if Flag_Radius == "RadYes":
    layerFolder = '/xdisk/ruichang/mig2020/rsgrps/ruichang/kuixizhu/sc/orga/work/zhuk01/Python/layerMadness/input/layer/radius/'
else:
    layerFolder = '/xdisk/ruichang/mig2020/rsgrps/ruichang/kuixizhu/sc/orga/work/zhuk01/Python/layerMadness/input/layer/upstream/'
   
deFolder = '/xdisk/ruichang/mig2020/rsgrps/ruichang/kuixizhu/sc/orga/work/zhuk01/Python/layerMadness/input/DE/'


mappingFile =  '/xdisk/ruichang/mig2020/rsgrps/ruichang/kuixizhu/sc/orga/work/zhuk01/Python/layerMadness/input/mapping.txt'
## read in P180 ID mapping file
mapping_dic = {}
mapping_dic_real2p180 = {}
mapping_f = open(mappingFile).read().splitlines()

for line in mapping_f:
    P180_name,real_name = line.split("\t")
    mapping_dic[P180_name] = real_name
    mapping_dic_real2p180[real_name] = P180_name


import functools
from sklearn.metrics import mean_squared_error, mean_absolute_error, roc_auc_score, r2_score, make_scorer

def softRankSummary(df):
    return functools.reduce(lambda a,b:np.add(a,b),df)

def transformSoftRank(df):
    re=[   [float(e) for e in record[1:len(record)-1].split(',')]  for record in df.SoftFeatureRank]
    df.SoftFeatureRank = pd.Series(re)
    

def getDEFeature(de,pvalue_cutoff=0.05):
   return(de.ID.loc[de["P.value"]<pvalue_cutoff].to_list())



    

MLA = [
    #Ensemble Methods   
    ensemble.RandomForestClassifier(max_depth=2,n_estimators=50),    
    #GLM
    sklearn.linear_model.LogisticRegression(penalty='elasticnet',l1_ratio=0.5,solver='saga',verbose=0),   
    #xgboost: http://xgboost.readthedocs.io/en/latest/model.html
    XGBClassifier(n_estimators=50,max_depth=2,learning_rate=0.05)    
    ]


sc= StandardScaler()
cur_config = 'A1A2'

print("config:"+cur_config+" layer:"+str(layer_ind))
data = pd.read_csv(dataFolder+'ML_A1A2.txt',sep="\t",header=0)

topFeatureDATA = data.copy(deep=True)
topFeatureDATA_left = sc.fit_transform(topFeatureDATA.drop('DX',axis=1))
topFeatureDATA_left = pd.DataFrame(topFeatureDATA_left,columns = topFeatureDATA.columns[:-1])
topFeatureDATA_right =topFeatureDATA.DX
topFeatureDATA_combo = pd.concat([topFeatureDATA_left,topFeatureDATA_right],axis=1,ignore_index=True)
topFeatureDATA_combo.columns = topFeatureDATA.columns
topFeatureDATA = topFeatureDATA_combo

## include layer information for feature selection
layerInfo = pd.read_csv(layerFolder+cur_config+'.txt',sep="\t",header=0)     
 
print(layer_ind)
current_outFolder = outFolder+cur_config+"/Layer_"+str(layer_ind)+"_"+str(percentage_cut)
Path(current_outFolder).mkdir(parents=True, exist_ok=True)

featureFromToplayer = layerInfo.loc[(layerInfo.layer <= layer_ind) & (layerInfo.percentage > percentage_cut),"name"]
selectedFeature_realName = list(set(featureFromToplayer))+['DX']    
selectedFeature_P180 = [mapping_dic_real2p180[e] if e in mapping_dic_real2p180 else e for e in selectedFeature_realName ]         


deFile = pd.read_csv(deFolder+cur_config+".txt",sep="\t",header=0)
de = list(deFile.ID[deFile["P.value"]<0.05])

if Flag_DE == "DEYes":
   selectedFeature_P180.extend(de)

if Flag_Clinical=="ClinicalYes":
    selectedFeature_P180.extend(['PTEDUCAT','AGE','BMI.bl'])

selectedFeature_P180 = list(np.unique(selectedFeature_P180))
tempData = topFeatureDATA

### 1 
record = []

print(cur_config+' step1...')
for times in range(100):        
    x_train, x_test, y_train, y_test = train_test_split(tempData.drop('DX',axis=1), tempData['DX'],stratify=tempData['DX'], test_size=0.2, random_state=times)
    x_train=np.array(x_train)
    y_train=np.array(y_train)
    x_test = np.array(x_test)
    total_predict = np.zeros(len(y_test))
    for i in range(len(MLA)):
        clf = copy.deepcopy(MLA[i])
        clf.random_state = times
        
        clf.fit(x_train,y_train)
        predict_result = clf.predict_proba(x_test)[:,1]
        total_predict += predict_result
        auc = roc_auc_score(y_test,predict_result)
        record.append([clf.__class__.__name__, auc,times])
        #print(clf.__class__.__name__ +" "+ str(auc))
           
    total_auc = roc_auc_score(y_test,total_predict)
    record.append(["merge", total_auc,times])
df_record1 = pd.DataFrame(record)
df_record1.columns=['clf','AUC','Time']
# get mean
output = df_record1.groupby('clf')['AUC'].agg(AUC='mean')
output['layer'] = layer_ind
output['data'] = cur_config
output['clf'] = output.index.values
output['feature_importance'] = 0
output.to_csv(current_outFolder+'/step1.txt',sep='\t')




## layer madness:step2 and step3

        
       

     
record = []
print(cur_config+' setp2...')

for times in range(100):
   
   
   #print("Times:" + str(times))
   x_train, x_test, y_train, y_test = train_test_split(tempData.drop('DX',axis=1), tempData['DX'],stratify=tempData['DX'], test_size=0.2, random_state=times)
    
   x_train=np.array(x_train)
   y_train=np.array(y_train)
   x_test = np.array(x_test)
   total_predict = np.zeros(len(y_test))
   
   for i in range(len(MLA)):
       
       skf = StratifiedKFold(n_splits=5,random_state=times)
       
       clf = copy.deepcopy(MLA[i])
       clf.random_state = times
       sel = SelectFromModel(
           PermutationImportance(clf, cv=skf,random_state=times)    
       ).fit(x_train, y_train)
       x_train_trans = sel.transform(x_train)  
       x_test_trans = sel.transform(x_test)  
       
       
       vali_auc = np.mean(cross_val_score(clf,x_train_trans,y_train,cv=skf,scoring='roc_auc'))
       
       
       clf.fit(x_train_trans,y_train)
       predict_result =clf.predict_proba(x_test_trans)[:,1]
       total_predict += predict_result
   
       
       test_auc = roc_auc_score(y_test,predict_result)
       
       soft_rank = [vali_auc if i==True else 0 for i in sel.get_support()]
       
       record.append([clf.__class__.__name__, sum(sel.get_support()),test_auc,times,soft_rank])
       #print(clf.__class__.__name__ +" "+ str(sum(sel.get_support())) +" "+ str(test_auc))
   total_test_auc = roc_auc_score(y_test,total_predict)
   record.append(["merge",0,total_test_auc,times,[]])
   
df_record2 = pd.DataFrame(record)
df_record2.columns=['clf','FeatureCount','AUC','Time','SoftFeatureRank']
# get mean
df_record2.groupby('clf')['AUC','FeatureCount'].agg({'AUC':'mean','FeatureCount':'mean'})
df_record2 = df_record2.sort_values(by=['clf','Time'])
df_record2.to_csv(current_outFolder+"/step2_SoftFeature.txt",sep="\t")
output = df_record2.groupby('clf')['AUC'].agg(AUC='mean')  
output.to_csv(current_outFolder+'/step2.txt',sep='\t')
        
 
            
         
            
print(cur_config+' step3...')
       
        
softrank = df_record2.groupby('clf')['SoftFeatureRank'].apply(softRankSummary)
df_softrank = pd.DataFrame(softrank.tolist(), index= softrank.index,columns = tempData.drop('DX',axis=1).columns )
df_softrank.drop("merge",axis=0,inplace=True)
df_softrank_sum = pd.DataFrame(df_softrank.apply(sum,axis=0),columns=['value'])
 
percentile_cutoffs = [20,40,60,80]
for percentile_cut in percentile_cutoffs:
         print(cur_config+' step3 with percentile_cut='+str(percentile_cut))
         cutoff = np.percentile(df_softrank_sum.value,percentile_cut)
         df_softrank_sum.loc[df_softrank_sum.value>=percentile_cut,:]
         selectedPanel = df_softrank_sum.loc[df_softrank_sum.value>=cutoff,:].sort_values('value',ascending=False).index.tolist()
         if len(selectedPanel)==0:
                 next   
         record = []
         for times in range(100):
             #print("Times:" + str(times))
             x_train, x_test, y_train, y_test = train_test_split(tempData.drop('DX',axis=1), tempData['DX'],stratify=tempData['DX'], test_size=0.2, random_state=times)
             x_train = x_train.loc[:,selectedPanel]
             x_test = x_test.loc[:,selectedPanel]
             x_train=np.array(x_train)
             y_train=np.array(y_train)
             x_test = np.array(x_test)
             total_predict = np.zeros(len(y_test))
             for i in range(len(MLA)):
                 clf = copy.deepcopy(MLA[i])
                 clf.random_state = times       
                 clf.fit(x_train,y_train)
                 predict_result =clf.predict_proba(x_test)[:,1]
                 total_predict += predict_result
                 auc = roc_auc_score(y_test,predict_result)
                 record.append([clf.__class__.__name__, auc,times])
                 #print(clf.__class__.__name__ +" "+ str(auc))
             total_auc = roc_auc_score(y_test,total_predict)
             record.append(["merge",total_auc,times])
             
         df_record2_common = pd.DataFrame(record)
         df_record2_common.columns=['clf','AUC','Time']
         # get mean
         output=df_record2_common.groupby('clf')['AUC'].agg(AUC='mean')
         df_record2_common = df_record2_common.sort_values(by=['clf','Time'])
   
         output = df_record2_common.groupby('clf')['AUC'].agg(AUC='mean')  
         output['layer'] = layer_ind
         output['clf'] = output.index.values
         output['data'] = cur_config
         output = output.loc[:,['AUC','layer','data','clf']]         
         output['feature_importance'] = percentile_cut
         output.to_csv(current_outFolder+'/step3_'+str(percentile_cut)+'.txt',sep='\t')
 
         panel = df_softrank_sum.loc[df_softrank_sum.value>=cutoff,:]
         panel.index= [mapping_dic[ele] if ele in mapping_dic else ele for ele in panel.index]
         panel_sort = panel.sort_values('value',ascending=False)
         panel_sort.columns = ['importance']       
         panel_sort.to_csv(current_outFolder+'/panel_'+str(percentile_cut)+'.txt',sep='\t')

         
     



       
            

print(cur_config+' step4...')


## read in from tuneing
df_record2=pd.read_csv(current_outFolder+"/step2_SoftFeature.txt",sep='\t')
df_record2 = df_record2.loc[df_record2.clf!="merge",:]
transformSoftRank(df_record2)
  
   
softrank = df_record2.groupby('clf')['SoftFeatureRank'].apply(softRankSummary)
df_softrank = pd.DataFrame(softrank.tolist(), index= softrank.index,columns = tempData.drop('DX',axis=1).columns )
#df_softrank.drop("merge",axis=0,inplace=True)
#df_softrank_sum = pd.DataFrame(df_softrank.apply(sum,axis=0),columns=['value'])
#cutoff = np.percentile(df_softrank_sum.value,90)
percentile_cutoffs = [20,40,60,80]
for percentile_cut in percentile_cutoffs:
         print(cur_config+' soloMode with percentile cut='+str(percentile_cut))
         record = []
         for times in range(100): 
             #print("Times:" + str(times))
             x_train, x_test, y_train, y_test = train_test_split(tempData.drop('DX',axis=1), tempData['DX'],stratify=tempData['DX'], test_size=0.2, random_state=times)
             total_predict = np.zeros(len(y_test))
             for ind_mla in range(len(MLA)):
                 x_train, x_test, y_train, y_test = train_test_split(tempData.drop('DX',axis=1), tempData['DX'],stratify=tempData['DX'], test_size=0.2, random_state=times)
                 clfName = MLA[ind_mla].__class__.__name__
                 currentClfFeatureImportance = df_softrank.loc[clfName,:]                          
                 cutoff = np.percentile(currentClfFeatureImportance,percentile_cut)
                 currentClfFeatureImportance.loc[currentClfFeatureImportance>=cutoff]
                 selectedPanel = currentClfFeatureImportance.loc[currentClfFeatureImportance>=cutoff].sort_values(ascending=False).index.tolist()   
                 x_train = x_train.loc[:,selectedPanel]
                 x_test = x_test.loc[:,selectedPanel]
                 x_train=np.array(x_train)
                 y_train=np.array(y_train)
                 x_test = np.array(x_test)
                 clf = copy.deepcopy(MLA[ind_mla])
                 clf.random_state = times       
                 clf.fit(x_train,y_train)
                 predict_result =clf.predict_proba(x_test)[:,1]
                 total_predict += predict_result
                 auc = roc_auc_score(y_test,predict_result)
                 record.append([clf.__class__.__name__, auc,times])
                 #print(clf.__class__.__name__ +" "+ str(auc))
             total_auc = roc_auc_score(y_test,total_predict)
             record.append(["merge",total_auc,times])
             
         df_record_solo = pd.DataFrame(record)
         df_record_solo.columns=['clf','AUC','Time']
         # get mean
         output=df_record_solo.groupby('clf')['AUC'].agg(AUC='mean')
         df_record_solo = df_record_solo.sort_values(by=['clf','Time'])
   
         output = df_record_solo.groupby('clf')['AUC'].agg(AUC='mean')  
         output.to_csv(current_outFolder+'/step4_solo_'+str(percentile_cut)+'.txt',sep='\t')
         
   



     
     
