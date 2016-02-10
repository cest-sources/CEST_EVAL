function x = lorentzfit1pool(p, data, P)
  n=numel(data);

% data1, data2 are actually unused



  for k=1:n
      i=data(k);
     x(k)=p(1) - p(2)*p(3)^2/4/(p(3)^2/4+(i-p(4))^2) ;

  end
