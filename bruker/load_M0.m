function M0_stack = load_M0(directory_M0)
% ** function M0_stack = load_M0(directory_M0)

cd(directory_M0);

% read acqp
file_acqp = textread('method','%s','delimiter','=','whitespace','');
size_file_acqp = size(file_acqp);
for cont_acqp = 1:size_file_acqp(1)
    if strcmp(file_acqp(cont_acqp),'##$PVM_NRepetitions')==1
        num_rip = round(str2num(char(file_acqp(cont_acqp+1))));
    end
end

% read reco
file_reco = textread('pdata/1/reco','%s','delimiter','\n','whitespace','');
size_reco = size(file_reco);
for cont_reco = 1:size_reco(1)
    if strcmp(file_reco(cont_reco),'##$RECO_size=( 2 )')
        size_xy = str2num(char(file_reco(cont_reco+1)));
        size_x_res = size_xy(1);
        size_y_res = size_xy(2);
        break
    end
end

file_meta=textread('pdata/1/reco','%s','delimiter','=','whitespace','');
size_meta=size(file_meta);

for cont_meta=1:size_meta(1)
    if strcmp(file_meta(cont_meta),'##$RECO_wordtype')
        reco_word=(char(file_meta(cont_meta+1)));
    end
end

if strcmp(reco_word,'_32BIT_SGN_INT')
    reco_bit='uint32';
elseif strcmp(reco_word,'_16BIT_SGN_INT')
    reco_bit='uint16';
end

file_reco_slope=textread('pdata/1/reco','%s','delimiter','=','whitespace','');

for cont_reco=1:size(file_reco_slope,1)
    if strcmp(file_reco_slope(cont_reco),'##$RECO_map_slope')
        slope=str2num(char(file_reco_slope(cont_reco+2)));  % correction factor
        break
    end
end

size_zx=size_x_res;
size_zy=size_y_res;
size_zz=num_rip;

M0_stack = zeros(size_zx,size_zy,1,1);

id_read = waitbar(0,'Reading 2dseq M0...');
fid=fopen('pdata/1/2dseq');

image_M0 = zeros(size_zx,size_zy,1,size_zz);
for cont_z=1:size_zz
    waitbar(cont_z/size_zz);
    for cont_i=1:size_zx
        for cont_j=1:size_zy
            image_M0(cont_i,cont_j,1,cont_z)=fread(fid,1,reco_bit);
        end
    end
end
fclose(fid);
close(id_read);

image_M0 = image_M0/slope(1);   % scale image by correction factor
M0_stack = mean(image_M0(:,:,1,:),4);