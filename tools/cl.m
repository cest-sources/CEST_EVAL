function clims=cl(i,max,cmap)
%%cl(i,max)
%%returns color vector clims [ R G B] of colormap cmap
%    autumn varies smoothly from red, through orange, to yellow.
%    cool consists of colors that are shades of cyan and magenta. It varies smoothly from cyan to magenta.
%    gray returns a linear grayscale colormap.
%    hot varies smoothly from black through shades of red, orange, and yellow, to white.
%    hsv varies the hue component of the hue-saturation-value color model. The colors begin with red, pass through yellow, green, cyan, blue, magenta, and return to red. The colormap is particularly appropriate for displaying periodic functions. hsv(m) is the same as hsv2rgb([h ones(m,2)]) where h is the linear ramp, h = (0:m–1)'/m.
%    jet ranges from blue to red, and passes through the colors cyan, yellow, and orange. It is a variation of the hsv colormap. The jet colormap is associated with an astrophysical fluid jet simulation from the National Center for Supercomputer Applications. See Examples on page -3.
% jet is default

if nargin<3
    cmap='jet';
end;
if max==1 &&i==1
    clims =[0 0 1];
elseif max==2 &&i==1
    clims =[0 0 1];
elseif max==2 &&i==2 
    clims =[0 0.4 0];
else

cmap=colormap(cmap);

clims=cmap(1+fix((max-i)*size(cmap,1)/max),:);
end;