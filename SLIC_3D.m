function [sv_image, SV_Centers ] = SLIC_3D(  volume_image, expected_sv_number,  bg_threshold, is_EnforeConnectivity, m_weight )
%% Feb 20, 2014
% Sam Kong
% Get segment labels of the image using slic
% For 2D Grey Image

%% main function
[ volume_width, volume_height, volume_slice] = size( volume_image );

supervoxel_size = ( volume_width * volume_height * volume_slice) / expected_sv_number;
supervoxel_step = floor( supervoxel_size^(1/3));

width_strips = round( 0.5 + volume_width / supervoxel_step );
height_strips = round( 0.5 + volume_height / supervoxel_step );
slice_strips = round( 0.5 + volume_slice / supervoxel_step );

%% compute seeds
width_err = volume_width  - supervoxel_step * width_strips;
height_err = volume_height - supervoxel_step * height_strips;
slice_err = volume_slice - supervoxel_step * slice_strips;

if width_err < 0
    width_strips = width_strips - 1;
    width_err = volume_width  - supervoxel_step * width_strips;
end

if height_err < 0
    height_strips = height_strips - 1;
    height_err = volume_height - supervoxel_step * height_strips;
end

if slice_err < 0
    slice_strips = slice_strips - 1;
    slice_err = volume_slice - supervoxel_step * slice_strips;
end

width_errperstrip = width_err / width_strips;
height_errperstrip = height_err / height_strips;
slice_errperstrip = slice_err / slice_strips; 

width_off = supervoxel_step / 2;
height_off = supervoxel_step / 2;
slice_off = supervoxel_step / 2;

segmentseeds = zeros(expected_sv_number, 4);
supervoxel_number = 0;

for k = 1: slice_strips
    slice_e = ( k - 1 ) * slice_errperstrip;
    seed_k = floor( ( k - 1 ) * supervoxel_step + slice_off + slice_e );
    for j = 1:height_strips
        height_e = ( j - 1 ) * height_errperstrip;
        seed_j = floor( ( j - 1) * supervoxel_step + height_off + height_e );
        for i = 1:width_strips
            width_e = ( i - 1 ) * width_errperstrip;
            seed_i = floor( ( i - 1) * supervoxel_step + width_off + width_e );
         
            seed_intensity = volume_image( seed_i, seed_j, seed_k );         
            
            if seed_intensity>bg_threshold
                supervoxel_number = supervoxel_number + 1;
                segmentseeds( supervoxel_number , : ) = [ seed_i, seed_j, seed_k, seed_intensity ];
            end
        end
    end
end

segmentseeds = segmentseeds(1:supervoxel_number, :);

%%Pertube seeds
%segmentseeds = perturbSeeds( volume_image, segmentseeds, bg_threshold );

%% Assign segments

error_threshold = round (expected_sv_number*0.01);

sv_image = zeros( volume_width, volume_height, volume_slice ) - 1;
mat_voxel_distance = zeros( volume_width, volume_height, volume_slice) + inf;

for iter = 1:10
    % assign labels
%     iter
    for m = 1:supervoxel_number
        seed_i = segmentseeds( m, 1 );
        seed_j = segmentseeds( m, 2 );
        seed_k = segmentseeds( m, 3 );
        seed_intensity = segmentseeds(m, 4);

        i_left = seed_i - round( supervoxel_step*0.8 );
        i_right = seed_i + round( supervoxel_step*0.8 );
        j_left = seed_j - round( supervoxel_step*0.8 );
        j_right = seed_j + round( supervoxel_step*0.8 );
        k_left = seed_k - round( supervoxel_step*0.8 );
        k_right = seed_k + round( supervoxel_step*0.8 );
        
        i_left = max( i_left, 2);
        i_right = min( i_right, volume_width - 1);
        j_left = max( j_left, 2);
        j_right = min( j_right, volume_height -1);
        k_left = max( k_left, 2);
        k_right = min( k_right, volume_slice -1);
        
        for voxel_k = k_left:k_right
            for voxel_j = j_left:j_right
                for voxel_i = i_left:i_right
                    
                    voxel_intensity =  volume_image( voxel_i , voxel_j, voxel_k );
                    if voxel_intensity>bg_threshold
                        distance_spatial = sqrt( ( seed_i - voxel_i)^2 + (seed_j - voxel_j)^2 + (seed_k - voxel_k)^2 );
                        
                        
                        distance_intensity = abs( seed_intensity - voxel_intensity );

                        distance_np = distance_intensity + 2* distance_spatial * m_weight / supervoxel_step;

                        if distance_np < mat_voxel_distance( voxel_i , voxel_j, voxel_k )

                            mat_voxel_distance( voxel_i , voxel_j, voxel_k ) = distance_np;
                            sv_image( voxel_i , voxel_j, voxel_k ) = m;
                        end
                    end
                end
            end
        end
    end
    
    % recompute seeds
    sigma_i = zeros( 1, supervoxel_number );
    sigma_j = zeros( 1, supervoxel_number );
    sigma_k = zeros( 1, supervoxel_number );
    sigma_intensity = zeros( 1, supervoxel_number );
    sigma_voxelnumber = zeros( 1, supervoxel_number );
    
    for voxel_k = 1:volume_slice
        for voxel_j = 1:volume_height
            for voxel_i = 1:volume_width
                voxel_label = sv_image( voxel_i , voxel_j, voxel_k );
                if voxel_label>0
                    voxel_intensity = volume_image( voxel_i , voxel_j, voxel_k );
                    sigma_i( voxel_label ) = sigma_i( voxel_label ) + voxel_i;
                    sigma_j( voxel_label ) = sigma_j( voxel_label ) + voxel_j;
                    sigma_k( voxel_label ) = sigma_k( voxel_label ) + voxel_k;
                    sigma_intensity( voxel_label ) = sigma_intensity( voxel_label ) + voxel_intensity;
                    sigma_voxelnumber( voxel_label) = sigma_voxelnumber( voxel_label) + 1;
                end
            end
        end
    end
    sigma_voxelnumber( sigma_voxelnumber<1) = 1;
    i_segmentseeds = segmentseeds;
    i_segmentseeds(:,1) = round ( sigma_i./sigma_voxelnumber );
	i_segmentseeds(:,2) = round ( sigma_j./sigma_voxelnumber );
    i_segmentseeds(:,3) = round ( sigma_k./sigma_voxelnumber );
    i_segmentseeds(:,4) =  sigma_intensity./sigma_voxelnumber;
    
    %check error
    i_seederror = abs(i_segmentseeds(:,1:3) - segmentseeds(:,1:3));
    i_seederror_sum = sum( i_seederror(:));
    
    segmentseeds = i_segmentseeds;
    %i_seederror_sum
    if i_seederror_sum < error_threshold
        break;
    end
end

% SV_Centers = segmentseeds( :, 1:3 );
%% Enforce Connectivity
if is_EnforeConnectivity == true 
    widthNeighbour =  [ -1,  0, 1, 0,  1, 1, -1, -1, 0, 0 ];
    heightNeighbour = [  0, -1, 0, 1, -1, 1,  1, -1, 0, 0 ];
    sliceNeighbour =  [  0,  0, 0, 0,  0, 0,  0,  0, 1, -1];

    sv_image_en = zeros( volume_width, volume_height, volume_slice ) - 1;
    voxel_i_vec = zeros( 1, volume_width * volume_height * volume_slice );
    voxel_j_vec = zeros( 1, volume_width * volume_height * volume_slice );
    voxel_k_vec = zeros( 1, volume_width * volume_height * volume_slice );

    adj_label = 1;
    label = 1;

    for voxel_k = 1: volume_slice
        for voxel_j = 1:volume_height
            for voxel_i = 1:volume_width
                if 1 > sv_image_en( voxel_i, voxel_j, voxel_k ) && volume_image( voxel_i, voxel_j, voxel_k ) > bg_threshold

                    sv_image_en( voxel_i, voxel_j, voxel_k ) = label;
                    voxel_i_vec(1) = voxel_i;
                    voxel_j_vec(1) = voxel_j;
                    voxel_k_vec(1) = voxel_k;

                    for n = 1:length(widthNeighbour)
                        voxel_x = voxel_i_vec(1) + widthNeighbour(n);
                        voxel_y = voxel_j_vec(1) + heightNeighbour(n);
                        voxel_z = voxel_k_vec(1) + sliceNeighbour(n);

                        if ( voxel_x>=1 && voxel_x<=volume_width ) &&( voxel_y>=1 && voxel_y<=volume_height ) &&( voxel_z>=1 && voxel_z<=volume_slice )
                            if sv_image_en( voxel_x, voxel_y, voxel_z ) >= 1 && volume_image( voxel_i, voxel_j, voxel_k ) > bg_threshold
                                adj_label = sv_image_en( voxel_x, voxel_y, voxel_z );
                            end
                        end
                    end

                    voxel_count = 1;
                    c = 1;
                    while c<=voxel_count
                        for n=1:length(widthNeighbour)
                            voxel_x = voxel_i_vec(c) + widthNeighbour(n);
                            voxel_y = voxel_j_vec(c) + heightNeighbour(n);
                            voxel_z = voxel_k_vec(c) + sliceNeighbour(n);
                            if ( voxel_x>=1 && voxel_x<=volume_width ) &&( voxel_y>=1 && voxel_y<=volume_height )&&( voxel_z>=1 && voxel_z<=volume_slice )
                                if volume_image( voxel_x, voxel_y, voxel_z ) > bg_threshold && 1>sv_image_en( voxel_x, voxel_y, voxel_z ) && sv_image( voxel_x, voxel_y, voxel_z )==sv_image( voxel_i, voxel_j, voxel_k )
                                    voxel_count = voxel_count +1;
                                    voxel_i_vec(voxel_count) = voxel_x;
                                    voxel_j_vec(voxel_count) = voxel_y;
                                    voxel_k_vec(voxel_count) = voxel_z;
                                    sv_image_en( voxel_x, voxel_y, voxel_z ) = label;

                                end
                            end
                        end
                        c = c +1;
                    end
    %                  voxel_count
                    if voxel_count< round( supervoxel_size/5 )
    %                 if voxel_count< 5
                        for c = 1:voxel_count
                            sv_image_en( voxel_i_vec(c), voxel_j_vec(c), voxel_k_vec(c) ) = adj_label;
                        end
                        label = label -1;
                    end
                    label = label +1;
                end
            end
        end
    end

    sv_image = sv_image_en;
end
supervoxel_number = max( sv_image(:) );
SV_Centers = zeros( supervoxel_number, 3 );
sigma_i = zeros( 1, supervoxel_number );
sigma_j = zeros( 1, supervoxel_number );
sigma_k = zeros( 1, supervoxel_number );
temp = zeros( 1, supervoxel_number );
temp(1:length(sigma_intensity)) = sigma_intensity ;
sigma_intensity = temp;
sigma_voxelnumber = zeros( 1, supervoxel_number );
    
for voxel_k = 1:volume_slice
	for voxel_j = 1:volume_height
        for voxel_i = 1:volume_width
            voxel_label = sv_image( voxel_i , voxel_j, voxel_k );
            if voxel_label>0
                voxel_intensity = volume_image( voxel_i , voxel_j, voxel_k );
                sigma_i( voxel_label ) = sigma_i( voxel_label ) + voxel_i;
                sigma_j( voxel_label ) = sigma_j( voxel_label ) + voxel_j;
                sigma_k( voxel_label ) = sigma_k( voxel_label ) + voxel_k;
                sigma_intensity( voxel_label ) = sigma_intensity( voxel_label ) + voxel_intensity;
                sigma_voxelnumber( voxel_label) = sigma_voxelnumber( voxel_label) + 1;
            end
        end
	end
end
sigma_voxelnumber( sigma_voxelnumber<1) = 1;
    
SV_Centers(:,1) = round ( sigma_i./sigma_voxelnumber );
SV_Centers(:,2) = round ( sigma_j./sigma_voxelnumber );
SV_Centers(:,3) = round ( sigma_k./sigma_voxelnumber );

end