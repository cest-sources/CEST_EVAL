function Mz_stack = load_Mz(directory_Mz)
% ** function Mz_stack = load_Mz(directory_Mz)

cd(directory_Mz);

num_ppm=0;
cont_ppm=1;
x=[];
file_acqp=textread('acqp','%s','delimiter','=','whitespace','');
size_file_acqp=size(file_acqp);
for cont_acqp=1:size_file_acqp(1)
    if strcmp(file_acqp(cont_acqp),'##$ACQ_institution')==1
        institution=(char(file_acqp(cont_acqp+2)));
    end
    if strcmp(file_acqp(cont_acqp),'##$ACQ_station')==1
        scanner=(char(file_acqp(cont_acqp+2)));
    end
    if strcmp(file_acqp(cont_acqp),'##$BF1')==1
        B0_field=round(str2num(char(file_acqp(cont_acqp+1))));
        B0_field_nonround=str2num(char(file_acqp(cont_acqp+1)));   % CT 20161205
    end
    if strcmp(file_acqp(cont_acqp),'##$ACQ_O2_list_size')==1
        num_ppm=round(str2num(char(file_acqp(cont_acqp+1))));
    end
    if strcmp(file_acqp(cont_acqp),'##$ACQ_O2_list')==1
        cont_acqp=cont_acqp+1;
        
        offset=(str2num(char(file_acqp(cont_acqp+1)))/B0_field_nonround);
        x=horzcat(x,offset);
        punti = size(x);
        cont_acqp=cont_acqp+1;
        
        while punti(2) < num_ppm
            offset=(str2num(char(file_acqp(cont_acqp+1)))/B0_field_nonround);
            x=horzcat(x,offset);
            punti = size(x);
            cont_acqp=cont_acqp+1;
        end
    end
    if strcmp(file_acqp(cont_acqp),'##$ACQ_coils')==1
        coil_info=char(file_acqp(cont_acqp+2));
        coil_info2=textscan(coil_info,'%s','delimiter',',', 'whitespace','()');
        coil_1H=coil_info2{1}{1}
    end
end
size_zz=num_ppm;


file_imnd=textread('method','%s','delimiter','=','whitespace','');
size_file_imnd=size(file_imnd);
for s=1:size_file_imnd(1)
    
    if strcmp(file_imnd(s),'##$PVM_MagTransPower')==1
        power=str2num(char(file_imnd(s+1)));
    end
    if strcmp(file_imnd(s),'##$PVM_MagTransModuleTime')==1
        durata=str2num(char(file_imnd(s+1)));
    end
end

% leggi nel file reco
file_reco=textread('pdata/1/reco','%s','delimiter','\n','whitespace','');
size_reco=size(file_reco);
for cont_reco=1:size_reco(1)
    if strcmp(file_reco(cont_reco),'##$RECO_size=( 2 )')
        size_xy=str2num(char(file_reco(cont_reco+1)));
        size_zx=size_xy(1);
        size_zy=size_xy(2);
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

% leggi la scala applicata ai valori in questa acquisizione
for cont_reco=1:size(file_reco_slope,1)
    if strcmp(file_reco_slope(cont_reco),'##$RECO_map_slope')
        slope=str2num(char(file_reco_slope(cont_reco+2)));
        break
    end
end

id_read = waitbar(0,'Reading Mz stack...');
image_Mz=zeros(size_zx,size_zy,1,size_zz);

fid=fopen('pdata/1/2dseq');
for cont_z=1:size_zz
    waitbar(cont_z/size_zz);
    for cont_i=1:size_zx
        for cont_j=1:size_zy
            image_Mz(cont_i,cont_j,1,cont_z)=fread(fid,1,reco_bit);
        end
    end
end
fclose(fid);
close(id_read);

image_Mz = image_Mz/slope(1); % scale image by correction factor

[~,IX] = sort(x');
Mz_stack = double(image_Mz(:,:,:,IX));