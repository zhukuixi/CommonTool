# -*- coding: utf-8 -*-
"""
Created on Tue Jun  7 15:50:47 2022

@author: Kuixi Zhu
"""

import numpy as np

class HMM:   
        
    def getHiddenState(self,O,A,B,pi):
        T = len(O)
        N_state = len(pi)
        delta = np.zeros([N_state,T])
        psi = np.zeros([N_state,T])
        dictMapping = dict(zip(["red","white"],[0,1]))
        
        # Forward
        for t in range(T):
            currentObsereIndex = dictMapping[O[t]]
            for i in range(N_state):
                if t==0:
                    delta[i,t] = pi[i]*B[i,currentObsereIndex]
                    psi[i,t] = 0
                else:
                    maxJ=-1
                    maxDelta = -np.Infinity
                    for j in range(N_state):
                        tempDelta = delta[j,t-1]*A[j,i]*B[i,currentObsereIndex]
                        if tempDelta>maxDelta:
                            maxDelta = tempDelta
                            maxJ = j
                    delta[i,t] = maxDelta
                    psi[i,t] = maxJ
        
        # Get maxProba and maxEndState
        maxProba = max(delta[:,-1])
        maxEndState = np.argmax(psi[:,-1])        
        optimalStateChain = np.zeros(T)
      #  optimalStateChain[-1] = maxEndState
        
        # Trace back
        for t in reversed(range(T)):
            if t==T-1:
                optimalStateChain[t]  = maxEndState
            else:
                optimalStateChain[t] = psi[int(optimalStateChain[t+1]),t+1]
        return optimalStateChain       
        
    def getProbaForward(self,O,A,B,pi):
        T = len(O)
        N_state = len(pi)
        alpha = np.zeros([N_state,T])
        dictMapping = dict(zip(["red","white"],[0,1]))
        for t in range(T):
            currentObsereIndex = dictMapping[O[t]]
            for i in range(N_state):         
                if t==0:
                    alpha[i,t] = pi[i]*B[i,currentObsereIndex]
                else:
                    alpha[i,t] = alpha[:,t-1].dot(A[:,i])*B[i,currentObsereIndex]
        return sum(alpha[:,-1])
        
    def getProbaBackward(self,O,A,B,pi):
        T = len(O)
        N_state = len(pi)
        beta = np.zeros([N_state,T])
        dictMapping = dict(zip(["red","white"],[0,1]))
        for t in reversed(range(T)):           
            for i in range(N_state):         
                if t==T-1:
                    beta[i,t] =1
                else:  
                    nextObsereIndex = dictMapping[O[t+1]]
                    beta[i,t] = sum(beta[:,t+1]*A[i,:]*B[:,nextObsereIndex])
        return sum(pi*beta[:,0]*B[:,dictMapping[O[0]]])        
    
    def getModel(self,O):
        A = np.array([[1/3,1/3,1/3],[1/3,1/3,1/3],[1/3,1/3,1/3]])
        B = np.array([[0.5,0.5],[0.5,0.5],[0.5,0.5]])
        pi = np.array([1/3,1/3,1/3])        
        dictMapping = dict(zip(["red","white"],[0,1]))
        N_state = 3
        T = 3
        N_ob = 2
        beta = np.zeros([N_state,T])
        alpha = np.zeros([N_state,T])
        r_store = np.zeros([N_state,T])
        e_store = np.zeros([T,N_state,N_state])
        
        repeatTime = 1000
        
        for repeatIndex in range(repeatTime):
            ## E step
            # get alpha                    
            for t in range(T):
                currentObsereIndex = dictMapping[O[t]]
                for i in range(N_state):         
                    if t==0:
                        alpha[i,t] = pi[i]*B[i,currentObsereIndex]
                    else:
                        alpha[i,t] = alpha[:,t-1].dot(A[:,i])*B[i,currentObsereIndex]
                        
            # get beta
            for t in reversed(range(T)):           
                for i in range(N_state):         
                    if t==T-1:
                        beta[i,t] =1
                    else:  
                        nextObsereIndex = dictMapping[O[t+1]]
                        beta[i,t] = sum(beta[:,t+1]*A[i,:]*B[:,nextObsereIndex])
          
            # get r_store
            for t in range(T):
                for i in range(N_state):
                    r_store[i,t] = (alpha[i,t]*beta[i,t])/(alpha[:,t].dot(beta[:,t]))
                    
            # get e_store
            for t in range(T-1):
                nextObsereIndex = dictMapping[O[t+1]]
                for i in range(N_state):
                    for j in range(N_state):
                        temp = 0 
                        for i_ in range(N_state):
                            for j_ in range(N_state):
                                temp += alpha[i_,t]*A[i_,j_]*B[j_,nextObsereIndex]*beta[j_,t+1]            
                        e_store[t,i,j] = alpha[i,t]*A[i,j]*B[j,nextObsereIndex]*beta[j,t+1]/temp
           
            ## M step
            # get A
            for i in range(N_state):
                for j in range(N_state):
                    A[i,j] = sum(e_store[:-1,i,j])/sum(r_store[i,:-1])
            
            # get B
            for j in range(N_state):
                for k in range(N_ob):
                    B[i,k] = sum([r_store[j,t] if dictMapping[O[t]]==k else 0  for t in range(T) ])/sum(r_store[j,:])    
            # get pi
            pi = r_store[:,0]
        return [A,B,pi]
        
                
if __name__ == '__main__':
    O = ['red','white','red']
    A = np.array([[0.5,0.2,0.3],[0.3,0.5,0.2],[0.2,0.3,0.5]])
    B = np.array([[0.5,0.5],[0.4,0.6],[0.7,0.3]])
    pi = np.array([0.2,0.4,0.4])
    model_hmm = HMM()
    model_hmm.getModel(O)
        