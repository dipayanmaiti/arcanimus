function Index=GetLowestfNodeInOpenset(V)
O=[V(logical([V.OpenSet]==1)).Node];            % Open Set
OfScore=[V(logical([V.OpenSet]==1)).fScore];    % Open Set fScore
[Minf,Index]=min(OfScore);                      % Get array Index for minimum fScore
MinfNode=O(Index);                              % Get Node corresponding to minimum fScore
Index=find([V.Node]==MinfNode);                 % Return Index of minimum fScore Node in V
return