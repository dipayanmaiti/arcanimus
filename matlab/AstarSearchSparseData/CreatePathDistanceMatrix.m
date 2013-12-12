function D=CreatePathDistanceMatrix(Adj,s_TermVectorMatrix,EntityList,TermWt,NumDocs,option,ImpactNodes)

D=zeros(NumDocs,NumDocs);

for i=1:NumDocs
    D(i,i)=0;
    if any(i==ImpactNodes)
        for j=i+1:NumDocs
            if any(j==ImpactNodes)
                NeighborEdgeThreshold=Inf; % for Astar search expansion
                [Path,V,fignum]=AstarSearch(Adj,[],EntityList, ...
                    s_TermVectorMatrix,[],i,j,TermWt,NeighborEdgeThreshold,option);
                D(i,j)=...
                    CalcPathLen(Path,s_TermVectorMatrix,EntityList,TermWt,option);
                D(j,i)=D(i,j);
            end;
        end;
    end;
end;

return;