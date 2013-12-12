function lambda=GetLambdaMinf(x,d,A,b)

% This step corresponds to the line search step in the paper by Bramley and
% Winnicka
% We use the backtracking line search :
% http://en.wikipedia.org/wiki/Backtracking_line_search

c1=0.1; c2=0.5;
DrawFig=0;
if DrawFig==1
    fignum=GetNextFigureNumber();
    figure(fignum);
    clf(fignum);
   
    lim=1;
    l=-lim:0.01:lim;
    f1=zeros(size(l));
    for i=1:size(l,2)
        f1(i)=0.5*norm((A*(x+l(i)*d)-b)...
            .*logical(A*(x+l(i)*d)-b>0),2)^2;
    end;
    figure(fignum)
    subplot(1,3,1);
    plot(l,f1); hold on;
    
    f2=zeros(size(l));
    t=(A*x-b).*(logical(A*x-b>0));
    fprime_xk=A'*t;
    f_xk=0.5*norm((A*x-b).*logical(A*x-b>0),2)^2;
    for i=1:size(l,2)
        f2(i)=f_xk+c1*l(i)*d'*fprime_xk;
    end;
    
    figure(fignum)
    subplot(1,3,2);
    plot(l,f2); hold on;
    
    subplot(1,3,3);
    plot(l,f1-f2); hold on;
    title('Wolfe Conditions - Blue -ve (i), Red +ve (ii)');
    
    % ---------------------------------
    
    l=-lim:0.01:lim;
    f1=zeros(size(l));
    for i=1:size(l,2)
        t=(A*(x+l(i)*d)-b).*(logical(A*(x+l(i)*d)-b>0));
        fprime_xkJump=A'*t;
        f1(i)=d'*fprime_xkJump;
    end;
    figure(fignum)
    subplot(1,3,1);
    plot(l,f1,'r');
    
    f2=zeros(size(l));
    t=(A*x-b).*(logical(A*x-b>0));
    fprime_xk=A'*t;
    for i=1:size(l,2)
        f2(i)=c2*d'*fprime_xk;
    end;
    figure(fignum)
    subplot(1,3,2);
    plot(l,f2,'r');
    
    subplot(1,3,3);
    plot(l,f1-f2,'r');
    grid on;
    
    % ---------------------------------
    figure(fignum);
    hold off;
end;

iterMax=100;
lambda=1; % Initial Guess
tau=unifrnd(0,1); % tau=0.9;
SatisfyWolfe=0;

f_xk=0.5*norm((A*x-b).*logical(A*x-b>0),2)^2;
t=(A*x-b).*(logical(A*x-b>0));
fprime_xk=A'*t;

iter=1;
while ~SatisfyWolfe

    
    if iter>iterMax
        break;
    end;
    
    % Satisfy the Wolfe conditions to exit
    % http://en.wikipedia.org/wiki/Wolfe_conditions        
    f_xkJump=0.5*norm((A*(x+lambda*d)-b).*logical(A*(x+lambda*d)-b>0),2)^2;   
    t=(A*(x+lambda*d)-b).*(logical(A*(x+lambda*d)-b>0));
    fprime_xkJump=A'*t;
    
    SatisfyWolfe1=logical(f_xkJump<=...
        f_xk+c1*lambda*d'*fprime_xk);
    
    SatisfyWolfe2=logical(d'*fprime_xkJump...
        >=c2*d'*fprime_xk);
    
    %x+lambda*d
    %SatisfyDirichletConstraint=logical(all(x+lambda*d>0));

    SatisfyWolfe=logical(...
        SatisfyWolfe1*...
        SatisfyWolfe2);
        %*...
        %SatisfyDirichletConstraint);
    
    lambda=tau*lambda;
    iter=iter+1;
end;
lambda=lambda/tau;

return;