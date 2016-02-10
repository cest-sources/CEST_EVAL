function [P]=change_w_fit(P)

P.EVAL.w_fit=0;

if max(abs(P.SEQ.w))>10
        [tempidx_s,val_s]=find_nearest(P.SEQ.w,-10);
        [tempidx_e,val_e]=find_nearest(P.SEQ.w,10);
        part_1=P.SEQ.w(1:tempidx_s-1);
        part_2=[val_s:0.01:val_e];
        part_3=P.SEQ.w(tempidx_e+1:end);
        P.EVAL.w_fit(1:numel(part_1))=part_1;
        P.EVAL.w_fit(numel(part_1)+1:numel(part_1)+numel(part_2))=part_2;
        P.EVAL.w_fit(numel(part_1)+numel(part_2)+1:numel(part_1)+numel(part_2)+numel(part_3))=part_3;
        clear part_1 part_2 part_3 tempidx_s tempidx_e val_s val_e
else   
        P.EVAL.w_fit=min(P.SEQ.w):0.01:max(P.SEQ.w);
end
