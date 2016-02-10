function x = lorentzfit2pool(p, data, P)
  n=numel(data);

% data1, data2 are actually unused
%will Gamma in Hz;  db0 in ppm:  p(4) und p(7) sind in ppm jetzt

  for k=1:n
      i=data(k);
      
     x(k)= p(1) - p(2)*p(3)^2/4/(p(3)^2/4+(i-p(4))^2) - p(5)*p(6)^2/4/(p(6)^2/4+(i-p(7))^2);
    
  end