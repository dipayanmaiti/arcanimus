function MDScoords=GetMDSCoords(D,N,dims)

opt.disp=0;
m=1/N*ones(N,1);
M=diag(m);
[vec, val] = eigs(-.5*(D.^2 - sum(D.^2)'*ones(1,N)/N - ones(N,1)*sum(D.^2)/N + sum(sum(D.^2))/(N^2)), dims, 'LR', opt); 

% The same eigenvectors can be obtained by using the matrix S=-0.5*Xi*D*Xi'
% where Xi=eye(N)-ones(N,1)*m'
% refer to: http://www.utdallas.edu/~herve/Abdi-MDS2007-pretty.pdf

% Obtain MDS coordinates
MDScoords = M^(-0.5)*vec*sqrt(val);

return;