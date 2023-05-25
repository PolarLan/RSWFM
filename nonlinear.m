function rnonlinear = nonlinear(w,M,B)

rnonlinear = zeros(w,1);

if M==2
for j=1:M
    for l=j:M
          rnonlinear = rnonlinear + exprnd(0.05)*(B(:,j).*B(:,l));
    end
end

elseif M==3
    for j=1:M
       for l=j:M
           for k=l:M
               rnonlinear = rnonlinear + exprnd(0.05)*(B(:,j).*B(:,l).*B(:,k));
           end
       end
    end
end