function [ res ] = LBP_3D_adjoin( vol, bg_threshold )
%% Apr.28.2019
% SF Liu
% This code is an LBP (adjion) algorithm in 3D.
% vol: the unprocessed MRI image
% Return the matrix as the same size as the vol, which is the texture feature
% of each voxel.The value is between -1 and 2^6. The -1 means the value 
% of the voxel is less than the bg_threshold. The real value is between 1 
% and 2^6.

%%
[height,width,depth]=size(vol);
LBP_map=zeros(height,width,depth)-1;
for p = 2:height-1
    for q = 2:width-1
        for r = 2:depth-1
            if vol(p,q,r)<=bg_threshold
                continue;
            end
            temp=0;
            neighbor = [vol(p+1,q,r) vol(p-1,q,r) vol(p,q+1,r) vol(p,q-1,r) vol(p,q,r+1) vol(p,q,r-1)] > vol(p,q,r);
            for i = 1:6
            temp = temp+neighbor(i)*2^(i-1);
            end
            LBP_map(p,q,r)=temp+1;
        end
    end
end

res=LBP_map;
end

