# -*- coding: utf-8 -*-
"""
Created on Tue Jun 14 14:25:24 2022

@author: Kuixi Zhu
"""

import numpy as np
import itertools

class CRFMatrix:
    def __init__(self,M,start,stop):
        self.M = M
        self.N = len(M)-1
        self.start = start
        self.stop = stop
        self.forward = np.zeros((2,len(M)))
        self.z = 0
        
    def fit(self):
        for t in range(self.N+1):
            if t==0:
                self.forward[self.start-1,t] = 1
            else:
                self.forward[:,t] = self.forward[:,t-1].transpose().dot(M[t])
        self.z = sum(self.forward[:,-1])
    
    def getProbaForPath(self,path):
        proba = 1
        for t in range(1,len(path)):
            lastState,currentState = path[t-1]-1,path[t]-1           
            proba *= self.M[t-1][lastState][currentState]
            proba /=self.z
        return proba
    
            
        
    

if __name__ == '__main__':
    # 创建随机矩阵
    M1 = [[0, 0], [0.5, 0.5]]
    M2 = [[0.3, 0.7], [0.7, 0.3]]
    M3 = [[0.5, 0.5], [0.6, 0.4]]
    M4 = [[0, 1], [0, 1]]
    M = [M1, M2, M3, M4]
    # 构建条件随机场的矩阵模型
    crf = CRFMatrix(M=M, start=2, stop=2)
    # 得到所有路径的状态序列的概率
    crf.fit()
    # 打印结果
 
    # Get all combinations of [1, 2, 3] and length 2
    # Print the obtained combinations
    for path in itertools.product([1,2], repeat=3):    
        currentPath = [2]+list(path)+[2]
        proba = crf.getProbaForPath(currentPath)
        print("path is "+'->'.join([str(s) for s in currentPath])+" with proba:" +str(proba))
        



        