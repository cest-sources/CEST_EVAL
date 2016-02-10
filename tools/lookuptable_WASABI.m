function [WASABI_bib, bib_entries] = lookuptable_WASABI(P)

tic

B1_bib=[0.5:0.05:1.5]*P.SEQ.B1;
offset_bib=[-0.3:0.025:0.3];
c_bib=[0.6:0.1:0.9];
af_bib=[1.3:0.1:1.8];

if ( isnan(P.SEQ.tp) || isnan(P.SEQ.FREQ) )
    error('pulse length or frequency missing in P.SEQ')
else
    t_p=P.SEQ.tp*10^-6;
    freq=P.SEQ.FREQ;
    GAMMA=gamma_;
end
for ii=1:numel(B1_bib)
    for jj=1:numel(offset_bib)
        for kk=1:numel(c_bib)
            for ll=1:numel(af_bib)
            
                for mm=1:numel(P.SEQ.w)
                
                    B1=B1_bib(ii);
                    offset=offset_bib(jj);
                    c=c_bib(kk);
                    af=af_bib(ll);
                    xx=P.SEQ.w(mm);

                    WASABI_bib(ii,jj,kk,ll,mm)=abs(c-af*sin(atan((B1/((freq/GAMMA)))/(xx-offset))).^2*sin(sqrt((B1/((freq/GAMMA))).^2+(xx-offset).^2)*freq*(2*pi)*t_p/2).^2);
%                     WASABI_bib(ii,jj,kk,mm)=c*abs(af-2*sin(atan((B1/((freq/gamma_)))/(xx-offset))).^2*sin(sqrt((B1/((freq/gamma_))).^2+(xx-offset).^2)*freq*(2*pi)*t_p/2).^2);
                    bib_entries{ii,jj,kk,ll}=[B1 offset c af];
%                     bib_entries{ii,jj,kk}=[B1 offset c af];
                end
            end
        end
    end
end
toc
display('WASAB1 Lookup-table created succesfully!')