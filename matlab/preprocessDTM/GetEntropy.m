function Entropy=GetEntropy(A)
%% Entropy Calculation for data in vector A
c1=2;
F=sum(A)+c1;
f=A./F;
n=size(A,2);
Entropy=0;
for i=1:n
    if f(i)==0
        t=0;
    else
        t=f(i)*log(f(i));
    end;
    Entropy=Entropy+t;
end;
Entropy=-1*Entropy;
return;