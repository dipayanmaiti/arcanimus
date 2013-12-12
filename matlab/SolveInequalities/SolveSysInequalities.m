function x=SolveSysInequalities(A,b)

% A=[         0           -1;
%            -1            0;
%       0.70711      0.70711;
%        0.5145      0.85749;];
% b=[-1 -1 0.70711 0.60025]';

% A=[         0            1;
%             1            0;
%       0.70711      0.70711;
%       0.51450      0.85749;];
% b=[ 1  1 0.70711 0.60025]';

lim=1;
X=-lim:0.05:lim;
Y=-lim:0.05:lim;
[X,Y]=meshgrid(X,Y);
f=zeros(size(X));
for i=1:size(X,1)
    for j=1:size(X,2)
        x=[X(i,j) Y(i,j)]';
        size(A*x-b)
        %f(i,j)=0.5*norm((A*x-b).*logical(A*x-b>0).*[1 1 1 100 100 100 100 1 1]',2)^2;
        f(i,j)=0.5*norm((A*x-b).*logical(A*x-b>0),2)^2;
    end;
end;
fignum=GetNextFigureNumber();
figure(fignum);
subplot(1,2,1);
surf(X,Y,f);
title('Objective Function - Positive 2-norm');


figure(fignum);
subplot(1,2,2);
contourf(X,Y,f,100); hold on;

x0=[0 0]';
epsilon=0.0001;

% Initialize
r0=b-A*x0;
[m,n]=size(A);
IndexSet=1:m;
I=IndexSet(r0<=0); % Active indices
rho=norm(r0(I),2);

x=x0;
TraceSol=[x];
r=r0;
relrho=1;

count=1;
while relrho>epsilon && rho>epsilon
    x
    rho
    relrho
    
    rI=r(I);
    AI=A(I,:);
    pInvAI=pinv(AI); % Pseudo inverse of AI
    d=pInvAI*rI;
    d=d./norm(d,2);
    
    lambda=GetLambdaMinf(x,d,A,b);
    x=x+lambda*d;
    TraceSol=[TraceSol x];
    
    figure(fignum);
    subplot(1,2,2);
    x1=TraceSol(1,end-1:end);
    x2=TraceSol(2,end-1:end);
    plot(x1,x2,'.w');
    %arrowh(x1,x2,'w',[],20);
    
    r=b-A*x;
    I=IndexSet(r<0); %new active index set
    relrho=abs(norm(r(I),2)-rho)/rho;
    rho=norm(r(I),2);
    count=count+1;
end;

figure(fignum);
hold off;

x
return;