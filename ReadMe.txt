1. 操作系统：Win 10       运行平台：Matlab R2017a

2. 文件说明：
brain data：数据集
CorrectRate.m: 函数文件，计算预测结果与标签之间的正确率
HIS_LBP.m: HIS_LBP模型的主程序，模型细节详见论文
HIS_LBPa.m: HIS_LBPa模型的主程序，模型细节详见论文   
HIS_LBPd.m: HIS_LBPd模型的主程序，模型细节详见论文   
HIS_MLBP.m: HIS_MLBP模型的主程序，模型细节详见论文 
HIST.m: HIST模型的主程序，模型细节详见论文
LBP_3D_adjoin.m: 函数文件，LBPa算法，算法细节详见论文
LBP_3D_diagonal.m: 函数文件，LBPd算法，算法细节详见论文
LBPa.m: LBPa模型的主程序，模型细节详见论文
LBPd.m: LBPd模型的主程序，模型细节详见论文
MLBP.m: MLBP模型的主程序，模型细节详见论文
SLIC_3D.m: 函数文件，三维情形下的SLIC算法
load_nii.m， load_nii_hdr.m， load_nii_img.m，xform_nii.m：
函数文件，用以读取MRI数据（.nii文件），这些文件来自于Matlab的工具库“NIfTI_20140122”

3. 使用说明：
通过Matlab打开相应模型的主程序，即可运行，得到该模型下的结果
需要注意的是，所使用的Matlab需要支持“parpool”功能，版本不宜过低