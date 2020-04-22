function x = lorentzfit3pool_BW(p, w, P)
BW=p(11);

x= p(1)-p(2).*p(3).^2./4./(p(3).^2/4+((w-p(4)-BW/2).*heaviside(w-BW/2-p(4))+(w-p(4)+BW/2).*heaviside(-(w+BW/2-p(4)))).^2) - p(5).*p(6).^2./4./(p(6).^2./4+(w-p(7)).^2) - p(8).*p(9).^2./4./(p(9).^2./4.+(w-p(10)).^2);
    
  
 