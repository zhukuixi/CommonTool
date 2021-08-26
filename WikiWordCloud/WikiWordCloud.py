# -*- coding: utf-8 -*-
"""
Created on Tue Jul 27 16:35:56 2021

@author: Kuixi Zhu
"""
from os import path,listdir
import numpy as np
from PIL import Image
import wikipedia
from wordcloud import WordCloud, STOPWORDS
from os.path import isfile
import pandas as pd

# get path to script's directory
currdir = path.dirname("D:/JooGitRepo/CommonTool/WikiWordCloud/")

def get_wiki(query):
	# get best matching title for given query
    if len(wikipedia.search(query))>0:
        title = wikipedia.search(query)[0]
        #get wikipedia page for selected title
        page = wikipedia.page(title)
        return page.content
    else:
        return ""


def create_wordcloud(text):
	# create numpy araay for wordcloud mask image
	#mask = np.array(Image.open(currdir+"/doctor.jpg"))

	# create set of stopwords	
	stopwords = set(STOPWORDS)

	# create wordcloud object
	wc = WordCloud(background_color="white",
					max_words=200, 
					mask=None,
	               	stopwords=stopwords)
	
	# generate wordcloud
	wc.generate(text)

	# save wordcloud
	wc.to_file(path.join(currdir, "wcloud1.png"))


if __name__ == "__main__":
	# get text for article
    compoundInfo = pd.read_csv("D:/work/TargetPerturbation/CMAP_LINC/processed/compoundinfo_beta.txt",sep="\t")
    compoundInfo_dict = dict(compoundInfo.iloc[:,:2].values)
    folder = 'D:/work/TargetPerturbation/application/CD68/output/CMAP/all/'
    files = [f for f in listdir(folder) if isfile(path.join(folder, f))]
    for file in files:
        cur_file = pd.read_csv(path.join(folder,file),sep="\t")
        cur_file = cur_file.sort_values("1")
        pert_id = cur_file.loc[(cur_file["1"]<0.05) & (cur_file["2"]<0.05),"pert_id"]
        pert_id = pert_id.unique()
        searchWord = [compoundInfo_dict[p] for p in pert_id]
        searchWord = searchWord[:5]
        text=''
        for word in searchWord:
            text += get_wiki(word)	
    	# generate wordcloud
    	create_wordcloud(text)