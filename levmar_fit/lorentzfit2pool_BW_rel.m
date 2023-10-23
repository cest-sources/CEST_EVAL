function x = lorentzfit2pool_BW_rel(p, w, P)

%will Gamma in Hz;  db0 in ppm:  p(4) und p(7) sind in ppm jetzt
BW=p(8);

x= p(1)-p(2).*p(3).^2./4./(p(3).^2/4+((w-p(4)-BW/2).*heaviside(w-BW/2-p(4))+(w-p(4)+BW/2).*heaviside(-(w+BW/2-p(4)))).^2) - p(5).*p(6).^2./4./(p(6).^2./4+(w-p(4)).^2);

if ~isequal(size(x),size(w))
      x = x.';
end