function NeighborNodes=GetNeighborNodes(A,s_TermVectorMatrix,EntityList,...
    x,xPredecessor,TermWt,NeighborEdgeThreshold,distopt)

% finding neighbors of x which are within an edgelength of 'EdgeThreshold'

PossibleNeighbors=find(A(x,:)==1);
TermVectorx=GetTermVector(s_TermVectorMatrix{x},EntityList);
EdgesFromx=zeros(size(PossibleNeighbors));
for i=1:size(PossibleNeighbors,2)
    TermVectory=GetTermVector(s_TermVectorMatrix{PossibleNeighbors(i)},EntityList);
    EdgesFromx(i)=GetDistance(TermVectorx,TermVectory,TermWt,distopt);
end;
NeighborsWithinThreshold=PossibleNeighbors((EdgesFromx<=NeighborEdgeThreshold));
NeighborNodes=setdiff(intersect(PossibleNeighbors, NeighborsWithinThreshold),xPredecessor);
return;
