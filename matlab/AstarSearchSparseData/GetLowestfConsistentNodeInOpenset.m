function Index=GetLowestfConsistentNodeInOpenset(V,goal)
O=[V(logical([[V.OpenSet]==1].*[[V.IsConsistentWithAncestry]==1])).Node];            % Open and Consistent Set
OfScore=[V(logical([[V.OpenSet]==1].*[[V.IsConsistentWithAncestry]==1])).fScore];    % Open and Consistent Set fScore
[Minf,Index]=min(OfScore);                      % Get array Index for minimum fScore
MinfNode=O(Index);                              % Get Node corresponding to minimum fScore
Index=find([V.Node]==MinfNode);                 % Return Index of minimum fScore Node in V

% if fScore for goal is also Minf, use goal
goalIndex=find(O==goal);
if ~isempty(goalIndex)
    goalfScore=OfScore(goalIndex);
    if goalfScore==Minf
        Index=find([V.Node]==goal); 
    end;
end;
return