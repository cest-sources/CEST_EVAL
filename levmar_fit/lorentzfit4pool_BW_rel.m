function x = lorentzfit4pool_BW_rel(p, w, P)
% LORENTZFIT4POOl BW relative
%   
BW=p(14);
x= p(1)-p(2).*p(3).^2./4./(p(3).^2/4+((w-p(4)-BW/2).*heaviside(w-BW/2-p(4))+(w-p(4)+BW/2).*heaviside(-(w+BW/2-p(4)))).^2)...
 - p(5).*p(6).^2./4./(p(6).^2./4+(w-p(7)-p(4)).^2) - p(8).*p(9).^2./4./(p(9).^2./4.+(w-p(10)-p(4)).^2)- p(11).*p(12).^2./4./(p(12).^2./4.+(w-p(13)-p(4)).^2);
  
if ~isequal(size(x),size(w))
      x = x.';
  end