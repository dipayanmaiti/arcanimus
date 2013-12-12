function [VNodes,VPredNodes,O,V]=VNodesAndPredecessors(V,VNodes,VPredNodes,tag)
% Get the Nodes and their predecessors if tag=get
% Sets Nodes and their predecessors to what has been specified if tag=reset

if strcmp(tag,'get')
    VNodes=[V.Node];
    VPredNodes=zeros(1,length(V));
    O=zeros(1,length(V));
    
    for i=1:length(V)
        VPredNodeIndex=V(i).Predecessor;
        O(i)=V(i).ClosedSet;
        if VPredNodeIndex==-1
            VPredNodes(i)=-1;
        else
            VPredNodes(i)=V(VPredNodeIndex).Node;
        end;
    end;
    V=[];
elseif strcmp(tag,'reset')
    O=[];
    for i=1:length(V)
        VNodeToCompare=V(i).Node;
        VPredNodeToCompare=VPredNodes(VNodes==VNodeToCompare);
        if VPredNodeToCompare==-1
            V(i).Predecessor=-1;
        else
            NewPredIndex=find([V.Node]==VPredNodeToCompare);
            V(i).Predecessor=NewPredIndex;
        end;
    end;
end;
return;

