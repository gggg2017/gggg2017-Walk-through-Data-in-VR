# -*- coding: utf-8 -*-
"""
Spyder Editor

Convert and save Raw 2048x2048 file to the cooresponding JPG file; 

"""

import numpy as np
from PIL import Image


image = np.memmap('112.1.raw', dtype=np.uint8, shape=(2048, 2048))

image = image - image.min()
image = image * (255.0/image.max())

image = image.astype(np.uint8)

print(image)

img = Image.fromarray(image , 'L')
img.show()

img.save("112.1.jpg")