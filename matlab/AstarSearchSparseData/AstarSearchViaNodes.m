function [Path,V,FigNum]=AstarSearchViaNodes(A,DocList,EntityList, ...
    s_TermVectorMatrix,NodeSequence,MDScoords,start,goal,TermWt,NeighborEdgeThreshold,distopt)

dist.opt=distopt; %option=0 for Euclidean distance, option=1 for Soergel distance
NumDocs=length(DocList);

DisplayMDS=1;
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
if DisplayMDS==1
    PlotNewVNode(V,1,MDScoords(NodeToPlot,:),FigNum);
end;
NumOpen=1;

while NumOpen~=0
    
    if DisplayMDS==1
        pause()
    end;
    
    Index=GetLowestfConsistentNodeInOpenset(V);
    x=V(Index).Node;
    if x==goal
        Path=ReconstructPath(V,Index,[]);
        break;
    end;
    
    V(Index).ClosedSet=1;
    V(Index).OpenSet=0;   
    NodeToPlot=V(Index).Node;
    if DisplayMDS==1
        PlotNewVNode(V,Index,MDScoords(NodeToPlot,:),FigNum);
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
        %pause()
        y=NeighborNodes(j);
        TermVector2=GetTermVector(s_TermVectorMatrix{y},EntityList);
        tentative_gScore=V(Index).gScore+GetDistance(TermVector1,TermVector2,TermWt,dist.opt);
        
        O=[V(logical([V.OpenSet]==1)).Node]   % Open Set
        C=[V(logical([V.ClosedSet]==1)).Node] % Closed Set
        OgScore=[V(logical([V.OpenSet]==1)).gScore]; % Open Set gScore
        CfScore=[V(logical([V.ClosedSet]==1)).fScore]; % Closed Set fScore
        
        % Check If y is consistent with its new predecessor x
        yAncestry=UpdateAncestry(x,xAncestry,NodeSequence);
        %NeighborIsConsistent=IsNeighborConsistent(y,goal,NodeSequence,xAncestry) 
        NeighborIsConsistent=IsNeighborConsistent(y,goal,NodeSequence,yAncestry) 
  
        if sum(O==y)>0 % If y is already in OpenSet. Hence y is already consistent with its current predecessor
            CurrgScore=OgScore(O==y);
            CurrAncestry=V(logical([V.Node]==y)).Ancestry;
            if tentative_gScore<=CurrgScore || (tentative_gScore>CurrgScore && length(yAncestry)>length(CurrAncestry))
                % tentative gScore is less than its current gScore
                x
                y
                
                fprintf(2,'\n Consistent, BUT in open set \n');
                if NeighborIsConsistent==1
                    V(logical([V.Node]==y)).gScore=tentative_gScore;
                    h=CalcHeuristicDistViaNodes(s_TermVectorMatrix,y,goal,yAncestry,NodeSequence,EntityList,TermWt,dist.opt);
                    
                    V(logical([V.Node]==y)).Ancestry=yAncestry;
                    V(logical([V.Node]==y)).hScore=h;
                    V(logical([V.Node]==y)).fScore=tentative_gScore+h;
                    yPredecessorIndex=V(logical([V.Node]==y)).Predecessor;
                    V(yPredecessorIndex).NNSuccessorSet=...
                        setdiff(V(yPredecessorIndex).NNSuccessorSet,y);
                    V(logical([V.Node]==y)).Predecessor=Index;
                    V(logical([V.Node]==y)).IsConsistentWithAncestry=NeighborIsConsistent;
                    xNNSuccessorSet=[xNNSuccessorSet y];
                else
                    % tentative gScore for neighbor y is less than its
                    % current gScore, but y is inconsistent with respect to
                    % the ancestry for x. Hence gScore and predecessor assignment
                    % remains unchanged.
                    x
                    y
                
                fprintf(2,'\n InConsistent, BUT in open set \n');
                
                    continue;
                end;
            end;
            % If tentative gScore is NOT less than its current gScore.
            % Hence gScore and predecessor assignment remains unchanged.
        elseif sum(C==y)>0 % If y is already in ClosedSet
            % If y is already in ClosedSet ignore the node
            % This seems to be the idea in some versions
            % Some versions incporporate try to incorporate a new path to y
            % via x :
            % http://www.edenwaith.com/products/pige/tutorials/a-star.php
            x
            y
            fprintf(2,'\n In Closed set \n');
           if x==y
                continue;
            else
                if NeighborIsConsistent==1
                    
                    h=CalcHeuristicDistViaNodes(s_TermVectorMatrix,y,goal,yAncestry,NodeSequence,EntityList,TermWt,dist.opt);
                    tentative_fScore=tentative_gScore+h;
                    CurrfScore=CfScore(C==y);
                    
                    if tentative_fScore<CurrfScore
                        CurrAncestry=V(logical([V.Node]==y)).Ancestry;
                        ScoreAdj=tentative_fScore-CurrfScore;
                        V(logical([V.Node]==y)).gScore=tentative_gScore;
                        V(logical([V.Node]==y)).hScore=h;
                        V(logical([V.Node]==y)).fScore=tentative_fScore;
                        % Change all g and hence f scores for all nodes which
                        % are successors of y
                        V(logical([V.Node]==y)).Ancestry=yAncestry;
                        yPredecessorIndex=V(logical([V.Node]==y)).Predecessor;
                        V(yPredecessorIndex).NNSuccessorSet=...
                            setdiff(V(yPredecessorIndex).NNSuccessorSet,y);
                        V(logical([V.Node]==y)).Predecessor=Index;
                        V(logical([V.Node]==y)).IsConsistentWithAncestry=NeighborIsConsistent;
                        xNNSuccessorSet=[xNNSuccessorSet y];
                        
                        V=BreadthFirstUpdateScore(V,y,ScoreAdj,CurrAncestry,yAncestry);
                    else
                        continue;
                    end;
                else
                    continue;
                end;
            end;
        else
            if NeighborIsConsistent==1
                x
                y
                
                fprintf(2,'\n Consistent, not in open or closed set \n');
                t.Node=y;
                t.gScore=tentative_gScore;
                %yAncestry=UpdateAncestry(x,xAncestry,NodeSequence);
                h=CalcHeuristicDistViaNodes(s_TermVectorMatrix,y,goal,yAncestry,NodeSequence,EntityList,TermWt,dist.opt);

                t.Ancestry=yAncestry;
                t.hScore=h;
                t.fScore=tentative_gScore+h;
                t.Predecessor=Index;  % The predecessor index (not node value) in V
                t.ClosedSet=0;        % ClosetSet is the set of nodes already evaluated.
                t.OpenSet=1;          % Openset is the set of tentative nodes to be evaluated.
                t.IsConsistentWithAncestry=NeighborIsConsistent;
                t.NNSuccessorSet=[];
                V=[V t];
                xNNSuccessorSet=[xNNSuccessorSet y];
                
                NodeToPlot=y; % Plot the last node inserted to V
                if DisplayMDS==1
                    PlotNewVNode(V,length(V),MDScoords(NodeToPlot,:),FigNum);
                end;
            else
                x
                y
                fprintf(2,'\n InConsistent, not in open or closed set \n');
                continue;
            end;
        end;
        xNNSuccessorSet
        V(Index).NNSuccessorSet=xNNSuccessorSet;
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











