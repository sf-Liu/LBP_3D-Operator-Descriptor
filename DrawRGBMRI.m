function res = DrawRGBMRI( src )
% SF Liu
% 将（大脑）MRI的truth图以红黄蓝的方式显示出来
[x,y]=size(src);
res=zeros(x,y,3);
for i = 1:x
    for j = 1:y
        temp=src(i,j);
        if temp == 1
            res(i,j,1)=255;
        elseif temp == 2
            res(i,j,2)=255;
        elseif temp == 3
            res(i,j,3)=255;
        end
    end
end


end

