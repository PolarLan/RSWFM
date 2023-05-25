function [x_1,x_2,x_2_land,y_1,y_2,y_2_land] = lib_2kinds_nonlinear(E_water,E_vegetation,E_impervious,E_soil,bands,steps)

w = bands;

%%%%%%%%%%%% endmembers %%%%%%%%%%%%%
[~,waterY] = size(E_water);
[~,vegetationY] = size(E_vegetation);
[~,imperviousY] = size(E_impervious);
[~,soilY] = size(E_soil);

%% pure image endmember (W V I S)
n=1;

R_1 = zeros(w,1);
Ff_1 = zeros(n,1);

R_1 = [R_1 E_water E_vegetation E_impervious E_soil];
for i = 1:waterY
    Ff_1 = [Ff_1 1];
end
for i = 1:(vegetationY+imperviousY+soilY)
    Ff_1 = [Ff_1 0];
end

R_1(:,1)=[];
Ff_1(:,1)=[];

x_1 = R_1';
y_1 = Ff_1(1,:)';

%% mixed spectra (water-X)

n = 2;

fcn = 0:steps:1;
fx = (1:n)';
Fn = zeros(n,1);
comb = nchoosek(fx,2);
[shapX,~] = size(comb);
for i = 1:shapX
    fn = zeros(n,1);
    combline = comb(i,:);
    for k = 1:length(fcn)
        fn(combline(1)) = fcn(k);
        fn(combline(2)) = 1-fcn(k);
        Fn = [Fn fn];
    end
end
Fn(:,1)=[];

[~,cols] = find(Fn==0);
cols = unique(cols);
[sizcol,~] = size(cols);
for i = 1:sizcol
    cutnum = cols(i);
    Fn(:,cutnum)=[];
    cols = cols-1;
end

F_2 = Fn;   % fraction of 2kinds - compose mode

%%%%%%%%%%%% endmembers %%%%%%%%%%%%%
E_land = [E_vegetation,E_impervious,E_soil];

[~,landY] = size(E_land);
[~,FY] = size(F_2);

%%%%%%%%%%%% spectra library construction %%%%%%%%%%%

R_2 = zeros(w,1);
Ff_2 = zeros(n,1);
for a = 1:waterY
    B = zeros(w,n);
    B(:,1) = E_water(:,a);
    for b = 1:landY
        B(:,2) = E_land(:,b);
        for c = 1:FY
            f = F_2(:,c);
            Ff_2 = [Ff_2 f];
            rlinear = B * f;  %linear
            R_2 = [R_2 rlinear];
            Ff_2 = [Ff_2 f];
            rnonlinear = rlinear + nonlinear(w,n,B);   %nonlinear
            R_2 = [R_2 rnonlinear];
        end
    end
end

R_2(:,1)=[];
Ff_2(:,1)=[];

x_2 = R_2';  %spectrum
y_2 = Ff_2(1,:)';  %water fraction

%% mixed spectra (X-Y)  ---  VI VS IS

n=2;

E_IS = [E_impervious,E_soil];

[~,ISY] = size(E_IS);

R_2_land = zeros(w,1);

for a = 1:vegetationY
    B = zeros(w,n);
    B(:,1) = E_vegetation(:,a);
    for b = 1:ISY
        B(:,2) = E_IS(:,b);
        for c = 1:FY
            f = F_2(:,c);
            rlinear = B * f;
            R_2_land = [R_2_land rlinear];
            rnonlinear = rlinear + nonlinear(w,n,B);
            R_2_land = [R_2_land rnonlinear];
        end
    end
end
for a = 1:imperviousY
    B = zeros(w,n);
    B(:,1) = E_impervious(:,a);
    for b = 1:soilY
        B(:,2) = E_soil(:,b);
        for c = 1:FY
            f = F_2(:,c);
            rlinear = B * f;
            R_2_land = [R_2_land rlinear];
            rnonlinear = rlinear + nonlinear(w,n,B);
            R_2_land = [R_2_land rnonlinear];
        end
    end
end

R_2_land(:,1)=[];

x_2_land = R_2_land';  %spectrum

[aa,~] = size(x_2_land);
y_2_land = zeros(aa,1);  %water fraction = 0

end
