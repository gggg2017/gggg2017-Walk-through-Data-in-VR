# -*- coding: utf-8 -*-
"""
Created on Fri May 21 14:51:26 2021

@author: GG
"""


import numpy as np
from PIL import Image
import matplotlib.pyplot as plt
from scipy.signal import find_peaks
from sklearn.linear_model import LinearRegression

NumCol = 2048
NumRow = 2048

anomaly = np.zeros([NumCol,NumRow,3],dtype=np.uint8)
anomaly.fill(255)

raw = np.memmap('112.1.raw', dtype=np.uint8, shape=(NumCol, NumRow))

loc = []
for i in range(NumRow):
    peaks, _ = find_peaks(np.array(raw[:,i].flatten()), distance=200)
    loc.append(peaks)

loc = np.asmatrix(loc)
(m,n) = np.shape(loc)
anomaly_length = 300
delta = 30
count = 0

for j in range(n):
    x = np.arange(0,m).reshape((-1,1))
    y = loc[:,j]
    
    # Create linear regression object
    model = LinearRegression()

    # Train the model using the training sets
    model.fit(x,y)
    
    for k in range(m):
        if loc[k,j] > model.coef_ * k + model.intercept_ + delta or loc[k,j] < model.coef_ * k + model.intercept_ - delta:
            anomaly[loc[k,j], int(k-anomaly_length/2):int(k+anomaly_length/2)] = [255, 0, 0]

img = Image.fromarray(anomaly, 'RGB')
img.save('test.jpg')
img.show()