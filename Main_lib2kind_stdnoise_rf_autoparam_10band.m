%%
% Method name : regression-based surface water fraction mapping method (RSWFM)
% Article name : Regression-based surface water fraction mapping using a synthetic spectral library for monitoring small water bodies
% DOI: 10.1080/15481603.2023.2217573

% Usage
% Before running the main function code on MATLAB, the three steps below needed to be executed first to generate input files.  
% 
% 1. Select pure endmember samples for four classes of water-vegetation-impervious surface-soil (WVIS) on the Sentinel-2 image with 10 bands on ENVI classic.
%    Here, you can select several sub-classes according to the image for each class and about 20 samples for each sub-class.
% 2. Put the sample spectra out to create files "water_sample.txt" and "land_sample.txt".
% 3. Calculate the mean spectra for each sub-class of WVIS from the samples 
%    and create four txt files ("E_W.txt, E_V.txt, E_I.txt, and E_S.txt") for WVIS classes.   
%    
% Then, put the seven files into the data folder or change the file path in the code to run the main function. It takes about 20 minitues to run the example data. 

%%
% 
%	Input	
%		S2 - Sentinel-2 image with 10 bands
% 
%		E_W_n - All water samples spectra derived from ENVI Classic
%       E_L_n - All land samples spectra derived from ENVI Classic, including vegetation, impervious surface, and soil
% 
%		E_water - Mean water endmember spectra for each water sub-class
%       E_vegetation - Mean vegetation endmember spectra for each vegetation sub-class
%       E_impervious - Mean impervious endmember spectra for each impervious sub-class
%       E_soil - Mean soil endmember spectra for each soil sub-class

%	Output
%       predict_wr - surface water fraction map

%   Hyperparameters:
%       k : determines the number of synthetic pure spectra in the training data
%       c : controls the magnitude of Gaussian noise
%       step : mixing ratio interval (ranges from 0 to 1)

%%

clear all

%%%%% set hyperparameters
k = 500;  %% iterations of adding white-noise to pure samples
c = 5;  %% noise : std/c
step = 0.1;   %% mixing ratio interval of spectral libary construction

fprintf(strcat('----------------------k',string(k),'--c',string(c),'--start---------------------\n'));

%%%%% read images
%%% Sentinel-2 (resolution:10m)
S2filename = 'Sentinel2_SR.tif';
[S2,R] = geotiffread(strcat('./data/',S2filename));
info = geotiffinfo(strcat('./data/',S2filename));

Ponds = double(S2);
[Px,Py,Pbands] = size(Ponds);

%%%%% load endmember spectra
%%% single endmember sample spectra
E_W_n = textread('./data/water_sample.txt');     %% all water sample spectra (derived from ENVI Classic)
E_W_n=E_W_n/10000;
w_multi = std(E_W_n(:,8:17))/c; 
E_L_n = textread('./data/land_sample.txt');      %% all land sample spectra (derived from ENVI Classic)
E_L_n=E_L_n/10000;
l_multi = std(E_L_n(:,8:17))/c;

%%%%% mean endmember spectra
E_water = textread('./data/E_W.txt');
E_vegetation = textread('./data/E_V.txt');
E_impervious = textread('./data/E_I.txt');
E_soil = textread('./data/E_S.txt');

E_land = [E_vegetation,E_impervious,E_soil];

E_water=E_water/10000;
E_vegetation=E_vegetation/10000;
E_impervious=E_impervious/10000;
E_soil=E_soil/10000;
E_land=E_land/10000;


%%%%%  construct spectral library
%%% synthetic mixed spectra 
[x_1,x_2,x_2_land,y_1,y_2,y_2_land] = lib_2kinds_nonlinear(E_water,E_vegetation,E_impervious,E_soil,Pbands,step);
x = [x_1;x_2;x_2_land];
y = [y_1;y_2;y_2_land];

%%% synthetic pure spectra
if k>0   
    x=double(x);
    y=double(y);

    [~,waternum] = size(E_water);
    [~,landnum] = size(E_land);
    
    x_w = x(1:waternum,:);
    x_l = x(waternum+1:waternum+landnum,:);
    
    x_other = x(waternum+landnum+1:length(x(:,1)),:);
    
    y_w = y(1:waternum,:);
    y_l = y(waternum+1:waternum+landnum,:);
    
    y_other = y(waternum+landnum+1:length(y(:,1)),:);
    
    % water
    for i=1:k+1
        if i==1
            x_w_ext = x_w;
        else
            x_w_ext = [x_w_ext ; (x_w + w_multi .* randn(waternum,Pbands))];
        end
    end
    for i=1:k+1
        if i==1
            y_w_ext = y_w;
        else
            y_w_ext = [y_w_ext ; y_w ];
        end
    end
    
    % land
    for i=1:k+1
        if i==1
            x_l_ext = x_l;
        else
            x_l_ext = [x_l_ext ; (x_l + l_multi .* randn(landnum,Pbands))];
        end
    end
    for i=1:k+1
        if i==1
            y_l_ext = y_l;
        else
            y_l_ext = [y_l_ext ; y_l];
        end
    end
    
    x_r = [x_w_ext ; x_l_ext ; x_other];
    y_r = [y_w_ext ; y_l_ext ; y_other];  
end

fprintf('...Spectral library construction over.\n')


%%%%%  unmix Sentinel-2 image
Ponds(:,:,1:10) = Ponds(:,:,1:10)/10000;

if k>0
    predict_wr = unmixing(Ponds,x_r,y_r);  
elseif k==0
    predict_wr = unmixing(Ponds,x,y);  
end

fprintf('...Training and predicting over.\n')


%%%%% save water fraction map.

filename_fraction = strcat('WF_K',string(k),'_C',string(c),...
    '_',extractBefore(string(S2filename),'.tif'),'.tif');
geotiffwrite(filename_fraction,predict_wr,R, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);

fprintf('...Water fraction save over.\n')


fprintf('---------------------------over---------------------------\n');
