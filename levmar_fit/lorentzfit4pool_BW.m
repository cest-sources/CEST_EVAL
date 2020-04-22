function x = lorentzfit4pool_BW(p, w, P)
% LORENTZFIT5POOl BW
%   
BW=p(14);
x= p(1)-p(2).*p(3).^2./4./(p(3).^2/4+((w-p(4)-BW/2).*heaviside(w-BW/2-p(4))+(w-p(4)+BW/2).*heaviside(-(w+BW/2-p(4)))).^2)...
 - p(5).*p(6).^2./4./(p(6).^2./4+(w-p(7)).^2) - p(8).*p(9).^2./4./(p(9).^2./4.+(w-p(10)).^2)- p(11).*p(12).^2./4./(p(12).^2./4.+(w-p(13)).^2);
  
