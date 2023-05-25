function Err = oobErrRF(params,X,Y,str_method)

PointCount = size(X,1);
c = cvpartition(PointCount,'KFold',5);% 5 k-fold

rmse_sum = 0;
for ModelIndex = 1:c.NumTestSets
    
    TrainIndex = training(c,ModelIndex);
    TestIndex = test(c,ModelIndex);
    X_train = X(TrainIndex,:);
    Y_train = Y(TrainIndex,:);
    X_test = X(TestIndex,:);
    Y_test = Y(TestIndex,:);
    
    
    randomForest = TreeBagger(params.ntree,X_train,Y_train,...
            'Method',str_method, 'OOBPrediction','on',...
            'NumPredictorstoSample',params.mtry);

    [yhatN,~,~] = predict(randomForest,X_test);
    rmse = sqrt( sum( (Y_test - yhatN) .^2) /size(Y_test,1) );
    
    rmse_sum=rmse_sum+rmse;
end

Err = rmse_sum/c.NumTestSets;


end
