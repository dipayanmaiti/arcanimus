function V=BreadthFirstUpdateScore(s_TermVectorMatrix,goal,V,y,...
    ScoreAdj,yAncestry,NodeSequence,EntityList,TermWt,distopt,MDScoords,FigNum)

DisplayBreadthFirst=0;
yIndex=find([V.Node]==y);
O=[];
C=[];
O=V(yIndex).Node;
NodeIndexToRemove=[];

while ~isempty(O)
    n=O(1);
    O=O(2:end);
    nIndex=find([V.Node]==n);
    
    if DisplayBreadthFirst==1
        TraversedNodeCoords=MDScoords(n,:);
        figure(FigNum);
        plot(TraversedNodeCoords(1),TraversedNodeCoords(2),...
            'MarkerFaceColor','k','Markersize',15,'MarkerEdgeColor','m');
    end;

    NodeIndexToRemove=[NodeIndexToRemove nIndex];
    O=[V(nIndex).NNSuccessorSet O];
    if length(O)~=length(unique(O))
        fprintf(2,'\n Error in Breadth First Deletion \n');
        pause();
    end;
    C=[C n];        
end;

[VNodes,VPredNodes,OpenSetIdentifier,junk]=VNodesAndPredecessors(V,[],[],'get');
%[VNodes; VPredNodes; OpenSetIdentifier]

NodesToRemove=[V(NodeIndexToRemove).Node];

% Reset Predeccesors for V nodes
V(NodeIndexToRemove)=[];
[junk1,junk2,junk3,V]=VNodesAndPredecessors(V,VNodes,VPredNodes,'reset');
[VNodes,VPredNodes,OpenSetIdentifier,junk]=VNodesAndPredecessors(V,[],[],'get');
%[VNodes; VPredNodes; OpenSetIdentifier]
return;


%{
nCurrAncestry=V(nIndex).Ancestry;
%nAncestry=[setdiff(V(nIndex).Ancestry,CurrAncestry) yAncestry];
if length(nCurrAncestry)>length(yAncestry)
    nAncestry=nCurrAncestry;
else
    nAncestry=yAncestry;
end;
V(nIndex).Ancestry=nAncestry;
V(nIndex).gScore=V(nIndex).gScore+ScoreAdj;
h=CalcHeuristicDistViaNodes(s_TermVectorMatrix,n,goal,nAncestry,NodeSequence,EntityList,TermWt,distopt);
V(nIndex).hScore=h;
V(nIndex).fScore=V(nIndex).gScore+h;
%}
