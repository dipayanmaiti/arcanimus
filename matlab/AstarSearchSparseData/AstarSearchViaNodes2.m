function [Path,V,FigNum]=AstarSearchViaNodes2(A,DocList,EntityList, ...
    s_TermVectorMatrix,NodeSequence,MDScoords,start,goal,TermWt,NeighborEdgeThreshold,distopt)

dist.opt=distopt; %option=0 for Euclidean distance, option=1 for Soergel
%distance
NumDocs=length(DocList);

DisplayMDS=0;
if DisplayMDS==1
    % Visualize the Astar search in the MDS space
    FigNum=DisplayMDSGraph(MDScoords,A,DocList,NumDocs);
    figure(FigNum);
    title('Tree for A^* Search: Red=Closed Set, G=Open Set'); hold on;
elseif DisplayMDS==0
    FigNum=0;
end;


gScore=0;
hScore=CalcHeuristicDistViaNodes(s_TermVectorMatrix,start,goal,[],NodeSequence,EntityList,TermWt,dist.opt);
fScore=gScore+hScore;

V.Node=[start];       
V.gScore=gScore;      
V.hScore=hScore;      
V.fScore=fScore;      
V.NNSuccessorSet=[];  % Contains an array of nearest neighbor successors to Node (only if it is a closed node)
V.Predecessor=-1;     % The predecessor index (not node value) in V
V.ClosedSet=0;        % ClosetSet is the set of nodes already evaluated. 
V.OpenSet=1;          % Openset is the set of tentative nodes to be evaluated.
V.Ancestry=[];        % The ancestry vector lists the sequence of nodes in 
                      % NodeSequence that the node counts as its ancestors.
                      % It will be used to calculate the heuristic distance
                      % to goal via NodeSequence. For details check the
                      % CalcHeuristicDistViaNodes function to see how
                      % ancestry vector is utilized.
V.IsConsistentWithAncestry=1;
                      % This field is consistent (=1) if V.Node is not an element of
                      % NodeSequence. If V.Node IS an element of NodeSequence, then it 
                      % is consistent (=1) with its ancestry if 
                      % 1) V.Node comes right after its most
                      % recent ancestor based on NodeSequence OR
                      % 2) V.Node has an empty ancestor set and V.Node is 
                      % the first element of NodeSequence 
                      % and is inconsistent (=0) if 
                      % 1) V.Node has a non-empty ancestor set and does not come right 
                      % after its most recent ancestor based on NodeSequence OR 
                      % 2) V.Node has an empty ancestor set but V.Node is not the first 
                      % element of NodeSequence.
                      
NodeToPlot=start;
% if DisplayMDS==1
%     PlotNewVNode(V,1,[],MDScoords(NodeToPlot,:),FigNum);
% end;
NumOpen=1;

while NumOpen~=0

    Index=GetLowestfConsistentNodeInOpenset(V,goal);
    x=V(Index).Node;
    if x==goal
        Path=ReconstructPath(V,Index,[]);
        break;
    end;
    
    V(Index).ClosedSet=1;
    V(Index).OpenSet=0;   
    NodeToPlot=V(Index).Node;
    if DisplayMDS==1
        PlotNewVNode(V,Index,[],MDScoords(NodeToPlot,:),FigNum);
    end;
    
    xPredecessorIndex=V(Index).Predecessor;
    if xPredecessorIndex==-1
        xPredecessor=[];
    else
        xPredecessor=V(xPredecessorIndex).Node;
    end;
    
    % Obtain neighbors of x but not predecessor of x
    NeighborNodes=GetNeighborNodes(A,s_TermVectorMatrix,EntityList,...
        x,xPredecessor,TermWt,NeighborEdgeThreshold,dist.opt);
    NumNeighbors=size(NeighborNodes,2);
    xAncestry=V(Index).Ancestry;
    TermVector1=GetTermVector(s_TermVectorMatrix{x},EntityList);
    
    xNNSuccessorSet=[];
    for j=1:NumNeighbors

        y=NeighborNodes(j);
        TermVector2=GetTermVector(s_TermVectorMatrix{y},EntityList);
        tentative_gScore=V(Index).gScore+GetDistance(TermVector1,TermVector2,TermWt,dist.opt);        
        O=[V(logical([V.OpenSet]==1)).Node];            % Open Set
        C=[V(logical([V.ClosedSet]==1)).Node];          % Closed Set
        OgScore=[V(logical([V.OpenSet]==1)).gScore];    % Open Set gScore
        CfScore=[V(logical([V.ClosedSet]==1)).fScore];  % Closed Set fScore
        
        
        % Obtain the ancestry of y
        yAncestry=UpdateAncestry(x,xAncestry,NodeSequence);
        % Check If y is consistent with its new predecessor x
        NeighborIsConsistent=IsNeighborConsistent(y,start,goal,NodeSequence,yAncestry); 
  
        if NeighborIsConsistent==1 % Do not expand to neighbor nodes inconsistent with predecessor x
            if sum(O==y)>0 % If y is already in OpenSet. Hence y is already consistent with its current predecessor
 
                CurrgScore=OgScore(O==y);
                yIndex=find([V.Node]==y);  % Logical Indexing is faster: logical([V.Node]==y)
                CurrAncestry=V(yIndex).Ancestry;
                I=IsBetterStoryHeuristic(y,V,tentative_gScore,CurrgScore,[],[],yAncestry,CurrAncestry,Index);
                if I
                    % If tentative ancestry of y same as old then compare gScore
                    % If tentative ancestry of y is better than curr ancestry,
                    % make y neighbor of x irrespective of curr gScore

                    %Index=find([V.Node]==x)
                    
                    V(yIndex).gScore=tentative_gScore;
                    h=CalcHeuristicDistViaNodes(s_TermVectorMatrix,y,goal,yAncestry,NodeSequence,EntityList,TermWt,dist.opt);
                    V(yIndex).hScore=h;
                    V(yIndex).fScore=tentative_gScore+h;
                    
                    V(yIndex).Ancestry=yAncestry;
                    yPredecessorIndex=V(yIndex).Predecessor;
                    V(yPredecessorIndex).NNSuccessorSet=...
                        setdiff(V(yPredecessorIndex).NNSuccessorSet,y);
                    V(yIndex).Predecessor=Index;
                    V(yIndex).IsConsistentWithAncestry=NeighborIsConsistent;
                    xNNSuccessorSet=[xNNSuccessorSet y];
                    V(Index).NNSuccessorSet=xNNSuccessorSet;
                    NodeToPlot=y;
                    if DisplayMDS==1
                        PlotNewVNode(V,yIndex,MDScoords(x,:),MDScoords(NodeToPlot,:),FigNum);
                    end;
                end;
            elseif sum(C==y)>0 % If y is already in ClosedSet 
 
                if x==y % ignore this. This code identifies x as a neighbor of x
                    continue;
                else
                    h=CalcHeuristicDistViaNodes(s_TermVectorMatrix,y,goal,yAncestry,NodeSequence,EntityList,TermWt,dist.opt);
                    tentative_fScore=tentative_gScore+h;
                    CurrfScore=CfScore(C==y);
                    yIndex=find([V.Node]==y);  % Logical Indexing is faster: logical([V.Node]==y)
                    CurrAncestry=V(yIndex).Ancestry;
                    I=IsBetterStoryHeuristic(y,V,[],[],tentative_fScore,CurrfScore,yAncestry,CurrAncestry,Index);
                    if I
                        ScoreAdj=tentative_fScore-CurrfScore;
                        V(yIndex).gScore=tentative_gScore;
                        V(yIndex).hScore=h;
                        V(yIndex).fScore=tentative_fScore;
                        V(yIndex).Ancestry=yAncestry;
                        yPredecessorIndex=V(yIndex).Predecessor;
                        V(yPredecessorIndex).NNSuccessorSet=...
                            setdiff(V(yPredecessorIndex).NNSuccessorSet,y);
                        V(yIndex).Predecessor=Index;
                        V(yIndex).IsConsistentWithAncestry=NeighborIsConsistent;
                        xNNSuccessorSet=[xNNSuccessorSet y];
                        V(Index).NNSuccessorSet=xNNSuccessorSet;
                        
                        t=V(yIndex);
                        t.ClosedSet=0;        % ClosedSet is the set of nodes already evaluated.
                        t.OpenSet=1;          % Openset is the set of tentative nodes to be evaluated.
                        t.NNSuccessorSet=[];  % y comes in as a new Open node with no successors i.e. it has not yet been expanded
                        
                        % Remove all Open and Closed Nodes in the tree with
                        % y as the starting node.
                        V=BreadthFirstUpdateScore(s_TermVectorMatrix,goal,V,y,ScoreAdj,...
                            yAncestry,NodeSequence,EntityList,TermWt,dist.opt,MDScoords,FigNum);
                        % Reset predecessor Index for t since size of V has
                        % changed
                        t.Predecessor=find([V.Node]==x);
                        V=[V t];
                        
                        NodeToPlot=y;
                        if DisplayMDS==1
                            PlotNewVNode(V,yIndex,MDScoords(x,:),MDScoords(NodeToPlot,:),FigNum);
                        end;
                    end;
                end;
            else
 
                t.Node=y;
                t.Ancestry=yAncestry;
                t.gScore=tentative_gScore;
                h=CalcHeuristicDistViaNodes(s_TermVectorMatrix,y,goal,yAncestry,NodeSequence,EntityList,TermWt,dist.opt);
                t.hScore=h;
                t.fScore=tentative_gScore+h;
                
                t.Predecessor=Index;  % The predecessor index (not node value) in V
                t.ClosedSet=0;        % ClosedSet is the set of nodes already evaluated.
                t.OpenSet=1;          % Openset is the set of tentative nodes to be evaluated.
                t.IsConsistentWithAncestry=NeighborIsConsistent;
                t.NNSuccessorSet=[];  % NNSuccessorSet is empty unless it is a Closed Node
                V=[V t];
                xNNSuccessorSet=[xNNSuccessorSet y];
                V(Index).NNSuccessorSet=xNNSuccessorSet;
                NodeToPlot=y; % Plot the last node inserted to V
                yIndex=length(V);
                
                if DisplayMDS==1
                    PlotNewVNode(V,yIndex,MDScoords(x,:),MDScoords(NodeToPlot,:),FigNum);
                end;
            end;
        end;
        Index=find([V.Node]==x);   % Index is being reset here to the correct value. I have no idea how it changes.
    end;
    O=[V(logical([V.OpenSet]==1)).Node];   % Open Set
    NumOpen=size(O,2);
end;

if DisplayMDS==1
    % Overlay shortest A* Search path on graph
    figure(FigNum);
    PathLen=length(Path);
    for i=1:PathLen-1
        linecoords=MDScoords([Path(i) Path(i+1)],:);
        line(linecoords(:,1),linecoords(:,2),'LineWidth',3,'Color','g','MarkerFaceColor','none');
    end;
    
    figure(FigNum);
    hold off;
    
end;
return;











