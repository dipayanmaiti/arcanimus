function x=SolveSysWtInequalities(A,b,x0,PathList,PathWithoutFeedback,numeq,numrange,s_TermVectorMatrix,EntityList,distopt)
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
I
count=1;
f=Inf;

while (relrho>epsilon && rho>epsilon) 
    
    Divergence=zeros(1,length(numeq));
    w=zeros(1,numeq);
    for i=1:length(PathList)
        P=PathCoordinates(PathList{i},s_TermVectorMatrix,EntityList,x,distopt);
        Q=PathCoordinates(PathWithoutFeedback,s_TermVectorMatrix,EntityList,x,distopt);
        Divergence(i)=DiscreteFrechet(P,Q,x,distopt);
    end;
    minw=min(w(w>0));
    w(w==0)=minw;
    w=(1./Divergence)/sum(1./Divergence);
    wmax=max(w);
    w=[w wmax*ones(1,numrange)];
    w=w./sum(w);
    
    f=0.5*norm((A*x-b).*w.*logical(A*x-b>0),2)^2;
    [count relrho rho f]
    I
    
    if f<epsilon
        break;
    end;
    
    rI=r(I);
    AI=A(I,:);
    pInvAI=pinv(AI); % Pseudo inverse of AI
    d=pInvAI*rI;
    d=d./norm(d,2);
    
    lambda=GetLambdaMinf(x,d,A,b);
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