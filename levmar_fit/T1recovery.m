function x = T1recovery(p, data, P)

    T1=p(1);
    a=p(2);
    c=p(3);
    TI=data;
    x=abs((a-c).*exp(-1./T1.*TI)+c) ;

  