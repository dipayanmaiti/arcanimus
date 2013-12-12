function P=ReconstructPath(V,Index,Path)
if V(Index).Predecessor==-1
    P=[V(Index).Node Path];
else
    Path=[V(Index).Node Path];
    Index=V(Index).Predecessor;
    P=ReconstructPath(V,Index,Path);
end;
return;