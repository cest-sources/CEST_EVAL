function x = WASABIFIT(p, data,P)
  n=numel(data);

% data1, data2 are actually unused
freq=P.SEQ.FREQ;
t_p=P.SEQ.tp;

x=zeros(1,n);
  for k=1:n
      xx=data(k);
     
      B1=p(1);
      offset=p(2);
      c=p(3);
      
      x(k)=c*abs(1-2*sin(atan((B1/((freq/gamma_)))/(xx-offset))).^2*sin(sqrt((B1/((freq/gamma_))).^2+(xx-offset).^2)*freq*(2*pi)*t_p/2).^2);

  end