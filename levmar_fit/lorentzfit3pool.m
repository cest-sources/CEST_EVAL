function x = lorentzfit3pool(p, data, P)
  n=numel(data);

% data1, data2 are actually unused

  for k=1:n
      i=data(k);
     x(k)= p(1) - p(2)*p(3).^2/4./(p(3).^2/4.+(i-p(4))^2) - p(5)*p(6).^2/4./(p(6).^2/4.+(i-p(7))^2) - p(8)*p(9).^2/4./(p(9).^2/4.+(i-p(10))^2);

  end
  
 if ~isequal(size(x),size(data))
      x = x.';
  end