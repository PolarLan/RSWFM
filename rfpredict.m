function predict_wf = rfpredict(s2_predict,mRF)

[xL,yL,bands] = size(s2_predict);

Z = zeros(xL*yL,bands);

n=0;
for i=1:xL
    for j=1:yL
        n=n+1;
        Z( n,: ) = squeeze( s2_predict(i,j,:) )';
    end
end

[yhatN,scoreN,costN] = predict(mRF,Z);

predict_wf=zeros(xL,yL);
n=0;
for i=1:xL
    for j=1:yL
        n=n+1;
        predict_wf(i,j)  = yhatN(n);
    end
end

