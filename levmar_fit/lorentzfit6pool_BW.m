function x = lorentzfit6pool_BW(p, w, P)
% LORENTZFIT6POOl_BW
% p parameter vector p(1) baseline,
% p(2) amplitude of Lorentz, p(3) width of Lorentz, p(4) position of Lorentz
% p(5) amplitude of Lorentz, p(6) width of Lorentz, p(7) position of Lorentz
% and so on
% p(20) bandwith of the plateau within the water loretz given by [p(2) p(3), p(4)]

% w is the offset axis vector
% P is a vector of Parameters

BW=p(20);
x= p(1)-p(2).*p(3).^2./4./(p(3).^2/4+((w-p(4)-BW/2).*heaviside(w-BW/2-p(4))+(w-p(4)+BW/2).*heaviside(-(w+BW/2-p(4)))).^2)...
- p(5).*p(6).^2./4./(p(6).^2./4+(w-p(7)).^2) - p(8).*p(9).^2./4./(p(9).^2./4.+(w-p(10)).^2)- p(11).*p(12).^2./4./(p(12).^2./4.+(w-p(13)).^2)- p(14).*p(15).^2./4./(p(15).^2/4.+(w-p(16)).^2)- p(17).*p(18).^2./4./(p(18).^2/4.+(w-p(19)).^2);
  
if ~isequal(size(x),size(w))
      x = x.';
  end
