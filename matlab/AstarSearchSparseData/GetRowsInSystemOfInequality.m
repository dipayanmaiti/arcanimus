function a=GetRowsInSystemOfInequality(P,s_TermVectorMatrix,EntityList,NumUniqueEntities,distopt)
% P is path - vector of nodes from start to goal
a=zeros(1,NumUniqueEntities);
L=length(P);
for i=1:L-1
    % edge is defined by P(i) and P(i+1)
    xi=GetTermVector(s_TermVectorMatrix{P(i)},EntityList);
    xi_plus_1=GetTermVector(s_TermVectorMatrix{P(i+1)},EntityList);
    t=GetElementWiseDist(xi,xi_plus_1,distopt);
    a=a+t;
end;

return;