function Constraint = CalcConstraint(ImpactNodes,Adj,DocList,EntityList, ...
    s_TermVectorMatrix,MDScoords,TermWt,NeighborEdgeThreshold,distopt,ArbConst)

dist.opt=distopt;
L=length(ImpactNodes);
Constraint=0;

for i=1:L-2
    A=ImpactNodes(i);
    for j=i+1:L-1
        B=ImpactNodes(j); C=ImpactNodes(j+1);
        % Obtain shortest path from A to B
        [P,V,FigNum]=AstarSearch(Adj,DocList,EntityList, ...
            s_TermVectorMatrix,MDScoords,A,B,TermWt,NeighborEdgeThreshold,dist.opt);
        dAB=CalcPathLen(P,s_TermVectorMatrix,EntityList,TermWt,dist.opt);
        
        [P,V,FigNum]=AstarSearch(Adj,DocList,EntityList, ...
            s_TermVectorMatrix,MDScoords,B,C,TermWt,NeighborEdgeThreshold,dist.opt);
        dBC=CalcPathLen(P,s_TermVectorMatrix,EntityList,TermWt,dist.opt);
        
        [P,V,FigNum]=AstarSearch(Adj,DocList,EntityList, ...
            s_TermVectorMatrix,MDScoords,A,C,TermWt,NeighborEdgeThreshold,dist.opt);
        dAC=CalcPathLen(P,s_TermVectorMatrix,EntityList,TermWt,dist.opt);
        
        err=(dAB+dBC)-dAC;
        if err <= 0
            Constraint=Constraint+0;
        else
            Constraint=Constraint+err*err;
        end;
    end;
end;

return;
