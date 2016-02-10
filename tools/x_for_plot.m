function x = x_for_plot(X,A)
% x_for_plot
%   input:  X - vector of measured x-values in Zspectrum
%           A - number of elements which shall be included between two x
%               values via linspace
%   output: x - new vector of x-values for display in imgui

if nargin < 2
    A = 10;
end

% initialization of x
x = [];

% 
for i = 2:numel(X)
    x = [x linspace(X(i-1),X(i),A)];
end

    