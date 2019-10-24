
%% May.10.2019
% SF Liu
% This code only uses the super-pixel texture features (LBP) and KNN for training-predicting.
% It will compute the Dice.
% The SLIC_3D and computeDSC function is from my tutor Sam Kong and used with great thanks

clear;
clc;
%% prepar train set
SLIC_num=30000;
train_x=[];
train_y=[];

src=load_nii('brain data\1_brain.nii');
vol=src.img;
[height,width,depth]=size(vol);

parfor dataset=1:15
    name=num2str(dataset);
    src=load_nii(['brain data\train\',name,'_brain.nii']);
    vol=src.img;
    [SLIC_label_train,sv_centers]=SLIC_3D(vol,SLIC_num,0,1,2);
    vol_lbp=LBP_3D_diagonal(vol,0);
    src=load_nii(['brain data\train\',name,'_truth.nii']);
    truth_train=src.img;

    label_num=max(max(max(SLIC_label_train)));
    counter=zeros(label_num,3);
    %计数器：第i个超像素在4个分区的像素数,用以确定超体素的标签
    lbp_hist=zeros(label_num,256);

    for p=1:height
        for q=1:width
            for r=1:depth
                label=SLIC_label_train(p,q,r);
                truth=truth_train(p,q,r);
                lbp=vol_lbp(p,q,r);
                if label<1||truth<1||lbp<1
                    continue;
                end
                counter(label,truth_train(p,q,r))= counter(label,truth_train(p,q,r))+1;
                lbp_hist(label,vol_lbp(p,q,r))=lbp_hist(label,vol_lbp(p,q,r))+1;
            end
        end
    end
    temp=[sv_centers,lbp_hist];
    train_x=[train_x;temp];
    
    temp=zeros(label_num,1);
    for i=1:label_num
        temp(i)=find(counter(i,:)==max(counter(i,:)),1);
    end
    train_y=[train_y;temp];
end

%% praper test set
name='2';
src=load_nii(['brain data\test\',name,'_brain.nii']);
w=2.5;
train_xw=train_x;
train_xw(:,1:3)=train_x(:,1:3)*w;
vol=src.img;
[SLIC_label_test,sv_centers]=SLIC_3D(vol,SLIC_num,0,1,2);
vol_lbp=LBP_3D_diagonal(vol,0);
label_num=max(max(max(SLIC_label_test)));
lbp_hist=zeros(label_num,256);

for p=1:height
    for q=1:width
        for r=1:depth
            label=SLIC_label_test(p,q,r);
            lbp=vol_lbp(p,q,r);
            if label<1||lbp<1
                continue;
            end
            lbp_hist(label,vol_lbp(p,q,r))=lbp_hist(label,vol_lbp(p,q,r))+1;
        end
    end
end
test_x=[sv_centers*w,lbp_hist];

% knn
c = fitcknn(train_xw,train_y,'NumNeighbors',5);

% verification
test_y = predict(c,test_x);
src=load_nii(['brain data\test\',name,'_truth.nii']);
truth_test=src.img;
[test_pr, truth_test_pr]=CorrectRate(SLIC_label_test,truth_test,test_y);
test_pr
DICE=computeDSC(truth_test, truth_test_pr)

%%
slice=53;
temp=squeeze(truth_test_pr(:,slice,:));
temp1=squeeze(truth_test(:,slice,:));
imshow([DrawRGBMRI(temp),DrawRGBMRI(temp1)]);