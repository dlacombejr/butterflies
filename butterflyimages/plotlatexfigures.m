

clear all
close all
clc



dr1=dir('*.png')

  f1={dr1.name}; 
    
    for i=1:length(f1) 
       
        a=['\begin{figure}\centering\includegraphics[scale=0.2]{/Users/williamedwardhahn/Desktop/MPCR_Paper_Butterflies/butterflyimages/' f1{i} '} \caption{}\end{figure}']
        
    end
    
