function [x TraceSol]=SoergelSolveSysInequalities(A,b)
x0=abs(normrnd(0,1,size(A,2),1));
x0=x0./sum(x0);
[m,n]=size(A);
epsilon=0.001;

FigDraw=0;
% Initialize
r0=b-A*x0;
IndexSet=1:m;
I=IndexSet(r0<0); % Active indices
rho=norm(r0(I),2);

x=x0;
TraceSol=[x];
r=r0;
relrho=1;
%I
count=1;
f=Inf;

%while (relrho>epsilon && rho>epsilon) 
while (count<10) 
    f=0.5*norm((A*x-b).*logical(A*x-b>0),2)^2;
    %[count relrho rho f]
    %I
    
    if f<epsilon
        break;
    end;
    
    rI=r(I);
    AI=A(I,:);
    pInvAI=pinv(AI); % Pseudo inverse of AI
    d=pInvAI*rI;
    d=d./norm(d,2);
    
    %lambda=GetLambdaMinf(x,d,A,b);
    lambda=0.001;
    x=x+lambda*d;
    TraceSol=[TraceSol x];
    r=b-A*x;
    I=IndexSet(r<0); %new active index set
    
    relrho=abs(norm(r(I),2)-rho)/rho;
    rho=norm(r(I),2);
    count=count+1;
end;

if FigDraw==1
    fignum=GetNextFigureNumber();
    figure(fignum);
    plot(x,'.-k');
end;
return;