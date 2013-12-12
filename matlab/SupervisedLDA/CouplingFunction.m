function ca=CouplingFunction(P,Q,i,j,ca,TermWt,option)

if ca(i,j)>-1
    return;
elseif i==1 && j==1
    TermVector1=P(:,1)';
    TermVector2=Q(:,1)';
    d=GetDistance(TermVector1,TermVector2,TermWt,option);
    ca(i,j)=d;
elseif i>1 && j==1
    ca=CouplingFunction(P,Q,i-1,1,ca,TermWt,option);
    
    TermVector1=P(:,i)';
    TermVector2=Q(:,1)';
    d=GetDistance(TermVector1,TermVector2,TermWt,option);
    
    %ca(i,j)=max(ca(i-1,j),d);
    ca(i,j)=ca(i-1,j)+d;
elseif i==1 && j>1
    ca=CouplingFunction(P,Q,1,j-1,ca,TermWt,option);
    
    TermVector1=P(:,1)';
    TermVector2=Q(:,j)';
    d=GetDistance(TermVector1,TermVector2,TermWt,option);
    
    %ca(i,j)=max(ca(1,j-1),d);
    ca(i,j)=ca(1,j-1)+d;
elseif i>1 && j>1 
    ca1=CouplingFunction(P,Q,i-1,j,ca,TermWt,option);
    ca2=CouplingFunction(P,Q,i-1,j-1,ca,TermWt,option);
    ca3=CouplingFunction(P,Q,i,j-1,ca,TermWt,option);
    
    TermVector1=P(:,i)';
    TermVector2=Q(:,j)';
    d=GetDistance(TermVector1,TermVector2,TermWt,option);
    
    ca(i,j)=min([ca1(i-1,j) ca2(i-1,j-1) ca3(i,j-1)])+d;
end;

return;



