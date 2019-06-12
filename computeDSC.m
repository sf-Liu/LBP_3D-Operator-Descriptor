function Seg_DSC = computeDSC( mat_standard_seg, mat_svrim_seg)

%find correpsonding
Seg_DSC = zeros( 1, 3 );
for i = 1:3
    standard_mat = double(mat_standard_seg==i);
    standard_sum = sum(standard_mat(:));
    svrim_mat = double(mat_svrim_seg==i);
    svrim_sum =  sum(svrim_mat(:));
    i_overlapping = standard_mat.*svrim_mat;
    i_overlapping_sum = sum(i_overlapping(:));
    i_DSC = 2*i_overlapping_sum/( standard_sum + svrim_sum);
%     i_DSC = i_overlapping_sum/( standard_sum + svrim_sum-i_overlapping_sum);

    Seg_DSC( i ) = i_DSC;

end

end