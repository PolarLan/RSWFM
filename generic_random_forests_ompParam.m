function BaggedEnsemble = generic_random_forests_ompParam(X,Y,str_method)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% auto omptimize ntree and mtry (bayes optimization)
%
% Parameters - 
%	Input	
%		X - matrix
%		Y - matrix of response
%		str_method - 'classification' or 'regression'
%
%	Output
%               BaggedEnsemble - ensemble of the best random forests
%               Plots of out of bag error
%

% maxNtree - the range of ntree to optimize   line23
% maxIter - Max iteriate times   line36

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%% define optimizable parameters
maxNtree = 600;
ntree = optimizableVariable('ntree',[1,maxNtree],'Type','integer');
mtry = optimizableVariable('mtry',[1,size(X,2)],'Type','integer');
hyperparametersRF = [ntree; mtry];



%%%%%%%%%%%% bayes opmtimize
%%% bayesopt properties
%%% MaxObjectiveEvaluations : Max iteriate times
%%% AcquisitionFunctionName : 'expected-improvement-plus' (random seed)
%%% Verbose : 0(no see result in optimization processing)
fun = @(params)oobErrRF(params,X,Y,str_method);    %object function
maxIter = 30;
bayesResult = bayesopt(fun,hyperparametersRF,...    %bayes optimization
    'MaxObjectiveEvaluations',maxIter,... 
    'AcquisitionFunctionName','expected-improvement-plus','Verbose',0,'PlotFcn',[]);

bestOOBErr = bayesResult.MinObjective;    %% min mae error
bestHyperparameters = bayesResult.XAtMinObjective;    %% best Hyperparameters



%%%%%%%%%%%% best RF model
BaggedEnsemble = TreeBagger(bestHyperparameters.ntree,X,Y,...
    'Method',str_method, 'OOBPrediction','on',...
    'NumPredictorstoSample',bestHyperparameters.mtry);

%%%%%%%%%%%% print result
fprintf('The optimal hyper-paramaters of RF: \t ');
fprintf(strcat('ntree=',string(BaggedEnsemble.NumTrees),'\t'));
fprintf(strcat('mtry=',string(BaggedEnsemble.NumPredictorsToSample),'\t'));
% fprintf(strcat('minError=',string(bestOOBErr),'\n'))
fprintf('\n...Parameters optimizing over.\n');

oobPredict(BaggedEnsemble);

% view trees
% view(BaggedEnsemble.Trees{1}) % text description
% view(BaggedEnsemble.Trees{1},'mode','graph') % graphic description