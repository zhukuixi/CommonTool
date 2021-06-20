# -*- coding: utf-8 -*-
"""
Created on Tue Feb 23 14:27:38 2021

@author: Kuixi Zhu
"""
from lxml import etree
import pandas as pd


ans = []
pd.set_option('display.max_columns', None)

for event, drug in etree.iterparse("full_database.xml", events=('end',), tag='{http://www.drugbank.ca}drug'):
    cur_drugName,cur_targetName, cur_action = '','',''
    for drug_element in drug.iterfind('{http://www.drugbank.ca}drugbank-id'):
        if len(drug_element.attrib)>0:
            ##print(drug_element.tag+" a  "+str(drug_element.text))
            cur_drugName = str(drug_element.text)    
            break
    for drug_element in drug.iterfind('{http://www.drugbank.ca}targets/{http://www.drugbank.ca}target/'):        
        
        if drug_element.tag=="{http://www.drugbank.ca}name":
            cur_targetName =str( drug_element.text)
        if drug_element.tag=="{http://www.drugbank.ca}actions":
            for action in drug_element:
                if cur_action=='':
                    cur_action = str(action.text)
                else:
                    cur_action = cur_action+","+str(action.text)
            #print("?"+cur_drugName+" "+cur_targetName+" "+cur_action)
            ans.append([cur_drugName,cur_targetName,cur_action])
            cur_targetName, cur_action = '',''
    drug.clear()        
            
         
                   
df_ans = pd.DataFrame(ans,columns=['DrugBank ID','Target','Action'])
df_ans.to_csv("drugbank_DrugTargetAction.txt",sep="\t",index=False)


df_drugLink = pd.read_csv("drug links.csv")
df_uniportLink = pd.read_csv("uniprot links.csv")
df_drugStructureLink = pd.read_csv("structure links.csv")

df_uniportLink = df_uniportLink.loc[:,['UniProt ID','UniProt Name']]
df_uniportLink = df_uniportLink.drop_duplicates()
df_uniportLink.columns=['Target UniProt ID','Target']


combo=df_ans.merge(df_uniportLink,on='Target',how='left')


cols_to_use = df_drugStructureLink.columns.difference(df_drugLink.columns).tolist()
cols_to_use.append('DrugBank ID')
dfNew = pd.merge(df_drugLink, df_drugStructureLink[cols_to_use], on='DrugBank ID', how='outer')


combo=combo.merge(dfNew,on='DrugBank ID',how='left')

combo.to_csv("combo.txt",sep="\t",index=False)
