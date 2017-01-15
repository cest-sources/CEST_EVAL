function y = predict_pH(mdl,x)
% ** function y = predict_pH(mdl,x)
%
% 'mdl' is a fit object specifying the linear model (CESTratio ~ pH).
% 'x' is the CESTratio map.
% 'y' is the predicted pH map.

imsize = size(x);
x = x(:);
y = predict(mdl,x);
y(y<5 | y>8) = NaN;
y = reshape(y,imsize);