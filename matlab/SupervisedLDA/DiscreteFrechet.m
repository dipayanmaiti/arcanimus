function d=DiscreteFrechet(P,Q,TermWt,option)

p=size(P,2); % p=number of nodes in P, columnwise
q=size(Q,2); % q=number of nodes in Q, columnwise

ca=zeros(p,q);
for i=1:p
    for j=1:q
        ca(i,j)=-1;
    end;
end;

ca=CouplingFunction(P,Q,p,q,ca,TermWt,option);
d=ca(p,q);
return;