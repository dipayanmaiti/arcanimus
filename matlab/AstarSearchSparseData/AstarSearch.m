function [Path,V,FigNum]=AstarSearch(A,DocList,EntityList, ...
    s_TermVectorMatrix,MDScoords,start,goal,TermWt,NeighborEdgeThreshold,distopt)

dist.opt=distopt; %0=Soergel, 1=Euclidean

DisplayMDS=0;
if DisplayMDS==1
    NumDocs=length(DocList);
    
    % Visualize the Astar search in the MDS space
    FigNum=DisplayMDSGraph(MDScoords,A,DocList,NumDocs);
    figure(FigNum);
    title('Tree for A^* Search: Red=Closed Set, G=Open Set'); hold on;
elseif DisplayMDS==0
    FigNum=0;
end;


gScore=0;
hScore=CalcHeuristicDist(s_TermVectorMatrix,start,goal,EntityList,TermWt,dist.opt);
fScore=gScore+hScore;

V.Node=[start];       
V.gScore=gScore;      
V.hScore=hScore;      
V.fScore=fScore;      
V.Predecessor=-1;     % The predecessor index (not node value) in V
V.ClosedSet=0;        % ClosetSet is the set of nodes already evaluated. 
V.OpenSet=1;          % Openset is the set of tentative nodes to be evaluated.

NodeToPlot=start;
if DisplayMDS==1
    PlotNewVNode(V,1,[],MDScoords(NodeToPlot,:),FigNum);
end;
NumOpen=1;

while NumOpen~=0

    Index=GetLowestfNodeInOpenset(V);
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
    
    for j=1:NumNeighbors
        y=NeighborNodes(j);

        TermVector1=GetTermVector(s_TermVectorMatrix{x},EntityList);
        TermVector2=GetTermVector(s_TermVectorMatrix{y},EntityList);
        
        tentative_gScore=V(Index).gScore+GetDistance(TermVector1,TermVector2,TermWt,dist.opt);
        
        O=[V(logical([V.OpenSet]==1)).Node];   % Open Set
        C=[V(logical([V.ClosedSet]==1)).Node]; % Closed Set
        OgScore=[V(logical([V.OpenSet]==1)).gScore];
        
        if sum(O==y)>0 % If y is already in OpenSet
            CurrgScore=OgScore(O==y);
            if tentative_gScore<CurrgScore % tentative gScore is less than its current gScore
                V(logical([V.Node]==y)).gScore=tentative_gScore;
                h=CalcHeuristicDist(s_TermVectorMatrix,y,goal,EntityList,TermWt,dist.opt);
                V(logical([V.Node]==y)).hScore=h;
                V(logical([V.Node]==y)).fScore=tentative_gScore+h;
                V(logical([V.Node]==y)).Predecessor=Index;
            end;
            % If tentative gScore is NOT less than its current gScore, keep
            % original node gScore and predecessor
        elseif sum(C==y)>0 % If y is already in ClosedSet
            % If y is already in ClosedSet ignore the node
            % This seems to be the idea in some versions
            % Some versions incporporate try to incorporate a new path to y
            % via x :
            % http://www.edenwaith.com/products/pige/tutorials/a-star.php
              continue;          
        else
            t.Node=y;
            t.gScore=tentative_gScore;
            h=CalcHeuristicDist(s_TermVectorMatrix,y,goal,EntityList,TermWt,dist.opt);
            t.hScore=h;
            t.fScore=tentative_gScore+h;
            t.Predecessor=Index;  % The predecessor index (not node value) in V
            t.ClosedSet=0;        % ClosetSet is the set of nodes already evaluated.
            t.OpenSet=1;          % Openset is the set of tentative nodes to be evaluated.
            V=[V t];
            
            NodeToPlot=y; % Plot the last node inserted to V
            if DisplayMDS==1
                PlotNewVNode(V,length(V),MDScoords(x,:),MDScoords(NodeToPlot,:),FigNum);
                %PlotNewVNode(V,length(V),MDScoords(NodeToPlot,:),FigNum);
            end;
        end;
    end;
    O=[V(logical([V.OpenSet]==1)).Node];   % Open Set
    NumOpen=size(O,2);
end;

if DisplayMDS==1
    % Overlay shortest A* Search path on graph
    figure(FigNum);
    PathLen=length(Path);
    for i=1:PathLen-1
        linecoords=[];
        linecoords=MDScoords([Path(i) Path(i+1)],:);
        line(linecoords(:,1),linecoords(:,2),'LineWidth',3,'Color','g','MarkerFaceColor','none');
    end;
    
    figure(FigNum);
    hold off;
    
end;
return;











