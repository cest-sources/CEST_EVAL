function x = lorentzfit6pool(p, data, P)
% LORENTZFIT6POOl
%   

n=numel(data);
% data1, data2 are actually unused

for k=1:n
    i=data(k);
    x(k)=   p(1) - p(2)*p(3).^2/4./(p(3).^2/4.+(i-p(4)).^2) - p(5)*p(6).^2/4./(p(6).^2/4.+(i-p(7)).^2) - p(8)*p(9).^2/4./(p(9).^2/4.+(i-p(10)).^2) - p(11)*p(12).^2/4./(p(12).^2/4.+(i-p(13)).^2) - p(14)*p(15).^2/4./(p(15).^2/4.+(i-p(16)).^2)- p(17)*p(18).^2/4./(p(18).^2/4.+(i-p(19)).^2);
end

if ~isequal(size(x),size(data))
      x = x.';
  end