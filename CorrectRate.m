function [ correct_rate, res_y ] = CorrectRate( SLIC_label, truth, test_y )
%%
% This function is to handel the SLIC segmentation's label, the truth data
% and the KNN predict vector, then return the matching accuracy between 
% res_y and truth.
% It returns the res_y by the way.
%%

[height,width,depth]=size(SLIC_label);
res_y=truth*0;
truth_count=0;
brain_count=0;
for p=1:height
    for q=1:width
        for r=1:depth
            label=SLIC_label(p,q,r);
            if label<1
                continue;
            end
            brain_count=brain_count+1;
            temp=test_y(label);
            res_y(p,q,r)=temp;
            if truth(p,q,r)==temp
                truth_count=truth_count+1;
            end
        end
    end
end

correct_rate=truth_count/brain_count;

end

