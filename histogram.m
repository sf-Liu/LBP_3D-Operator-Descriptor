
%% Apr.12.2019
% SF Liu
% Organizational segmentation by extracting grayscale features of the MRS dataset
% The SLIC_3D function is from my tutor Sam Kong and used with great thanks

clear;
clc;
%% prepar train set
SLIC_num=30000;

src=load_nii('brain data\1_brain.nii');
vol=src.img;
[SLIC_label_train,sv_centers]=SLIC_3D(vol,SLIC_num,0,1,2);
vol_int=round(vol/max(max(max(vol)))*255);
src=load_nii('brain data\1_truth.nii');
truth_train=src.img;

[height,width,depth]=size(vol);
label_num=max(max(max(SLIC_label_train)));
counter=zeros(label_num,3);
%一个计数器：第i个超像素在4个分区的像素数
hist=zeros(label_num,256);

for p=1:height
    for q=1:width
        for r=1:depth
            label=SLIC_label_train(p,q,r);
            if label<1
                continue;
            end
            counter(label,truth_train(p,q,r))= counter(label,truth_train(p,q,r))+1;
            hist(label,vol_int(p,q,r))=hist(label,vol_int(p,q,r))+1;
        end
    end
end
train_x=[sv_centers,hist];
train_y=zeros(label_num,1);
for i=1:label_num
    train_y(i)=find(counter(i,:)==max(counter(i,:)),1);
end

%% praper test set
src=load_nii('brain data\2_brain.nii');
vol=src.img;
[SLIC_label_test,sv_centers]=SLIC_3D(vol,SLIC_num,0,1,2);
vol_int=round(vol/max(max(max(vol)))*255);
label_num=max(max(max(SLIC_label_test)));
hist=zeros(label_num,256);

for p=1:height
    for q=1:width
        for r=1:depth
            label=SLIC_label_test(p,q,r);
            if label<1
                continue;
            end
            hist(label,vol_int(p,q,r))=hist(label,vol_int(p,q,r))+1;
        end
    end
end
test_x=[sv_centers,hist];

%% knn
c = fitcknn(train_x,train_y,'NumNeighbors',5);
test_y = predict(c,test_x);

%% verification
src=load_nii('brain data\2_truth.nii');
truth_test=src.img;

train_fit=CorrectRate(SLIC_label_train,truth_train,train_y)
test_pr=CorrectRate(SLIC_label_test,truth_test,test_y)

train_y=predict(c,train_x);
train_pr=CorrectRate(SLIC_label_train,truth_train,train_y)
    


