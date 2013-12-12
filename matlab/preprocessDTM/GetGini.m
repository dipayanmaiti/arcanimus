function GiniCoeff=GetGini(A)
%% Gini Coefficient Calculation for data in vector A
GiniCoeff=0;
n=size(A,2);
mu=mean(A);
for i=1:n
    for j=1:n
        GiniCoeff=GiniCoeff+...
            abs(A(i)-A(j));
    end;
end;

GiniCoeff=GiniCoeff/...
    (2*n*n*mu);
return;