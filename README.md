# butterflies
 
There are two options for running this repository: 

1. Learn dictionary elements on random image patches and test classification performance
    1. Run `lacombe_butterflyPatches.m` which will create a folder `butterflydata/` where it will store image patches for each butterfly category separated into train and test sets (note that only the test set distinguishes between patches from different images)
    2. Run `lacombe_butterflyDictionary.m` which will learn category-specific dictionaries that will be used for classification of images (this will overwrite the pretrained weights)
    3. Run `lacombe_butterflyTest.m` to test the classification accuracy of the category-specific dictionaries on an image-by-image basis

2. Only test classification performance using pretrained weights
    1. Run `lacombe_butterflyTest.m` to test the classification accuracy of the *pretrained* category-specific dictionaries on an image-by-image basis

