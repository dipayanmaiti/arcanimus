function f = LeastSqErrfun(x,A,b)
f=0.5*norm((A*x-b).*logical(A*x-b>0),2)^2;