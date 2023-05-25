function fraction_predict = unmixing(s2,lib_x,lib_y)

[xL,yL,~] = size(s2);

x = lib_x;
y = lib_y;

%%%%%%%%%%%%%%%% regression %%%%%%%%%%%%%%
%%%%% Bayesian optimization : ntree mtry

%%%% train %%
mRF = generic_random_forests_ompParam(x,y,'regression');

%%%% predict %%
fraction_predict = rfpredict(s2,mRF);


