function x = LD_lorentzfit3pool(p, w, P)
% LORENTZFIT6POOl
%   
x= p(1) + p(2).*p(3).^2./4./(p(3).^2/4+(w-p(4)).^2) + p(5).*p(6).^2./4./(p(6).^2./4+(w-p(7)).^2) + p(8).*p(9).^2./4./(p(9).^2./4.+(w-p(10)).^2) ;
  
