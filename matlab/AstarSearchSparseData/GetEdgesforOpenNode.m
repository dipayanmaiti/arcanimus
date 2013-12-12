function e=GetEdgesforOpenNode(V,o)

% o is an open node in V
% V is the set of open and closed nodes after a complete A* search

Index=find([V.Node]==o);
Path=ReconstructPath(V,Index,[]);
e=[Path(1:end-1)' Path(2:end)'];

return;