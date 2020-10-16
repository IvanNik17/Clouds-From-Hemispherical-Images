function [C,X,Y,Z] = saveobjmesh(input_image,name,meshsize)
%Original Script from Anders Sandberg
%http://www.aleph.se/Nada/Ray/saveobjmesh.m
% SAVEOBJMESH Save a x,y,z mesh as a Wavefront/Alias Obj file
% SAVEOBJMESH(fname,x,y,z)
%     Saves the mesh to the file named in the string fname
%     x,y,z are equally sized matrices with coordinates.

threshold = 0.0001;
 
img = input_image;

[IY, IX, C] = size(img);
 
T = meshsize-1;
R = 300;

X = zeros(T+1,T+1);
Y = zeros(T+1,T+1);
Z = zeros(T+1,T+1);
I = zeros(T+1,T+1);

X(X == 0) = NaN;
Y(Y == 0) = NaN;
Z(Z == 0) = NaN;

output_dir = 'Result_objects/';
name = strcat(output_dir, num2str(name));

name_bottom = strcat(name,'_bottom.obj');
name_top = strcat(name,'_top.obj');

n = zeros(T+1,T+1,2);

fid=fopen(name_bottom,'w');
fprintf(fid,'o mesh1\n'); 
  
  
nn=1;
for y1 = 0:T
    for x1 = 0:T

       %angles depending of the possition of the pixel 
       x = 1/T * x1; 
       y = 1/T * y1;
       
       phi   = pi * x;
       theta = pi * y - 0.5 * pi;

       %position in the original image
       ix = 1 + (IX-1) * ( sin(theta) * cos(phi) / 2 + 0.5);
       iy = 1 + (IY-1) * ( sin(theta) * sin(phi) / 2 + 0.5);
       
       y_1 = floor(iy);
       x_1 = floor(ix);

       y_2 = ceil(iy);
       x_2 = ceil(ix);
       
       if y_1 == 0
           y_1 = 1;
       end

       if x_1 == 0
           x_1 = 1;
       end

       if y_2 > IY
           y_2 = IY;
       end

       if x_2 > IX
           x_2 = IX;
       end
      
       %Biliniar interpolation
       
       c1 = (iy-y_1)*img(y_2,x_1)+(1-(iy-y_1))*img(y_1,x_1);
       c2 = (iy-y_1)*img(y_2,x_2)+(1-(iy-y_1))*img(y_1,x_2);


       I(y1+1,x1+1) = (ix-x_1)*c2+(1-(ix-x_1))*c1;

       if cos(theta) > 0.2 && I(y1+1,x1+1) > threshold
           n(y1+1,x1+1,1)=nn;
           X(y1+1,x1+1) = (R-I(y1+1,x1+1)*R/20) * sin(theta) * cos(phi);
           Y(y1+1,x1+1) = (R-I(y1+1,x1+1)*R/20) * sin(theta) * sin(phi);
           Z(y1+1,x1+1) = (R-I(y1+1,x1+1)*R/20) * cos(theta);

           fprintf(fid, 'v %f %f %f\n',X(y1+1,x1+1),Y(y1+1,x1+1),Z(y1+1,x1+1));
           fprintf(fid, 'vt %f %f\n',(iy-1)/(IY-1),(ix-1)/(IX-1));

           nn=nn+1;
       end
    end
end

for i=1:T
    for j=1:T
        %         if I(i,j) > threshold && I(i+1,j) > threshold && I(i,j+1) > threshold && I(i+1,j+1) > threshold
        if (n(i,j,1) ~= 0 && n(i+1,j,1) ~= 0 && n(i,j+1,1) ~= 0 && n(i+1,j+1,1) ~= 0)
            if i >= (T+1)/2
                fprintf(fid,'f %d/%d %d/%d %d/%d %d/%d\n',n(i,j,1),n(i,j,1),n(i,j+1,1),n(i,j+1,1),n(i+1,j+1,1),n(i+1,j+1,1),n(i+1,j,1),n(i+1,j,1));
            else
                fprintf(fid,'f %d/%d %d/%d %d/%d %d/%d\n',n(i,j,1),n(i,j,1),n(i+1,j,1),n(i+1,j,1),n(i+1,j+1,1),n(i+1,j+1,1),n(i,j+1,1),n(i,j+1,1));
            end
        end
    end
end

fclose(fid); 

C = I;

nn=1;

fid=fopen(name_top,'w');
fprintf(fid,'o mesh2\n');

for y1 = 0:T
    for x1 = 0:T

       %angles depending of the possition of the pixel 
       x = 1/T * x1; 
       y = 1/T * y1;
       
       phi   = pi * x;
       theta = pi * y - 0.5 * pi;

       %position in the original image
       ix = 1 + (IX-1) * ( sin(theta) * cos(phi) / 2 + 0.5);
       iy = 1 + (IY-1) * ( sin(theta) * sin(phi) / 2 + 0.5);
       
       y_1 = floor(iy);
       x_1 = floor(ix);

       y_2 = ceil(iy);
       x_2 = ceil(ix);
       
       if y_1 == 0
           y_1 = 1;
       end

       if x_1 == 0
           x_1 = 1;
       end

       if y_2 > IY
           y_2 = IY;
       end

       if x_2 > IX
           x_2 = IX;
       end
      
       %Biliniar interpolation
       
       c1 = (iy-y_1)*img(y_2,x_1)+(1-(iy-y_1))*img(y_1,x_1);
       c2 = (iy-y_1)*img(y_2,x_2)+(1-(iy-y_1))*img(y_1,x_2);


       I(y1+1,x1+1) = (ix-x_1)*c2+(1-(ix-x_1))*c1;
       
       if cos(theta) > 0.2 &&  I(y1+1,x1+1) > threshold
           n(y1+1,x1+1,1)=nn;
           X(y1+1,x1+1) = (R+I(y1+1,x1+1)*R/20) * sin(theta) * cos(phi);
           Y(y1+1,x1+1) = (R+I(y1+1,x1+1)*R/20) * sin(theta) * sin(phi);
           Z(y1+1,x1+1) = (R+I(y1+1,x1+1)*R/20) * cos(theta);

           fprintf(fid, 'v %f %f %f\n',X(y1+1,x1+1),Y(y1+1,x1+1),Z(y1+1,x1+1));
           fprintf(fid, 'vt %f %f\n',(iy-1)/(IY-1),(ix-1)/(IX-1));

           nn=nn+1;
       end
    end
end



for i=1:T
    for j=1:T
        %         if I(i,j) > threshold && I(i+1,j) > threshold && I(i,j+1) > threshold && I(i+1,j+1) > threshold
        if (n(i,j,1) ~= 0 && n(i+1,j,1) ~= 0 && n(i,j+1,1) ~= 0 && n(i+1,j+1,1) ~= 0)
            if i >= (T+1)/2
                fprintf(fid,'f %d/%d %d/%d %d/%d %d/%d\n',n(i,j,1),n(i,j,1),n(i,j+1,1),n(i,j+1,1),n(i+1,j+1,1),n(i+1,j+1,1),n(i+1,j,1),n(i+1,j,1));
            else
                fprintf(fid,'f %d/%d %d/%d %d/%d %d/%d\n',n(i,j,1),n(i,j,1),n(i+1,j,1),n(i+1,j,1),n(i+1,j+1,1),n(i+1,j+1,1),n(i,j+1,1),n(i,j+1,1));
            end
        end
    end
end
 
fclose(fid);  
 



  
  return
  
