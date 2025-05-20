# [IJML] LBP_3D-Operator-Descriptor  
This is the official repo for the International Journal of Machine Learning (IJML) paper [Supervoxel Clustering with a Novel 3D Descriptor for Brain Tissue Segmentation](https://www.ijml.org/vol10/964-AM0045.pdf)

## Requirements
**OS**：Win 10      **Operating platform**：Matlab R2017a  
    
## Document description:  
`brain data`：data set  
`CorrectRate.m`: Function file, calculating the correct rate (SA) between the predicted result and the label.  
`HIS_LBPa.m`: The main program of the HIS_LBPa, the details of the model are detailed in the paper.  
`HIS_LBPd.m`: The main program of the HIS_LBPd, the details of the model are detailed in the paper.  
`HIS_MLBP.m`: The main program of the HIS_MLBP, the details of the model are detailed in the paper.  
`HIST.m`: The main program of the HIST, the details of the model are detailed in the paper.  
`LBP_3D_adjoin.m`: Function file, LBPa operator, the details of the operator are detailed in the paper.  
`LBP_3D_diagonal.m`: Function file, LBPd operator, the details of the operator are detailed in the paper.  
`LBPa.m`: The main program of the LBPa, the details of the model are detailed in the paper.    
`LBPd.m`: The main program of the LBPd, the details of the model are detailed in the paper.   
`MLBP.m`: The main program of the MLBP, the details of the model are detailed in the paper.   
`computeDSC`: Function file, calculate prediction accuracy (DICE).   
`SLIC_3D.m`: Function file, SLIC algorithm in 3D case.   
`load_nii.m`, `load_nii_hdr.m`, `load_nii_img.m`, `xform_nii.m`：  
Function file for reading MRI data (.nii files) from Matlab Tool Library "NIfTI_20140122".  
   
## Instructions for excution:
Open the main program of the corresponding model through Matlab, you can run and get the result under the model.  
Please note that MATLAB should be in a version which supports the "parpool" function.  

---------------------
For help or issues using the codes, please submit a GitHub issue.

For other communications related to our work, please contact Yongfan Liu (`yongfal@uci.edu`) 
