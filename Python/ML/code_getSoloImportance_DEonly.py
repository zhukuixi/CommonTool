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

#Visualization
from sklearn.model_selection import train_test_split
import numpy as np

from sklearn.model_selection import StratifiedKFold
from sklearn.model_selection import cross_val_score

from eli5.sklearn import PermutationImportance
from sklearn.feature_selection import SelectFromModel

import copy
import os
from pathlib import Path
from sklearn.preprocessing import StandardScaler

# def warn(*args, **kwargs):
#     pass

# import warnings
# warnings.warn = warn


sys_layerCut = 0.01
data_ind = int(sys.argv[1])
layer_ind = 0
percentage_cut = float(sys.argv[2])
outputDir = sys.argv[3]
Flag_Clinical = sys.argv[4] ## ClinicalYes  or ClinicalNo
Flag_DE = sys.argv[5]       ## DEYes   or DENo
Flag_Radius = sys.argv[6]   ## RadYes or RadNo



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
cur_config = data_name[data_ind].split(".")[0].split("_")[1]

print("config:"+cur_config+" layer:"+str(layer_ind))
data = pd.read_csv(dataFolder+data_name[data_ind],sep="\t",header=0)

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
tempData = topFeatureDATA.loc[:,selectedFeature_P180]


       
            
            

print(cur_config+' step4...')


## read in from tuneing
df_record2=pd.read_csv(current_outFolder+"/step2_SoftFeature.txt",sep='\t')
df_record2 = df_record2.loc[df_record2.clf!="merge",:]
transformSoftRank(df_record2)   
softrank = df_record2.groupby('clf')['SoftFeatureRank'].apply(softRankSummary)
df_softrank = pd.DataFrame(softrank.tolist(), index= softrank.index,columns = tempData.drop('DX',axis=1).columns )
df_softrank.columns =  [mapping_dic[e] if e in mapping_dic else e for e in df_softrank.columns]


df_softrank.to_csv(current_outFolder+'/soloFeature_'+str(percentage_cut)+'.txt',sep='\t')
         
   


     
     
