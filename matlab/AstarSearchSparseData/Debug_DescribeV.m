function Debug_DescribeV(V)
for i=1:length(V)
    fprintf(2,'\n --------------------- \n');
    Node=V(i).Node
    p=V(i).Predecessor;
    if p==-1
        Predecessor=-1
    else
        Predecessor=V(p).Node
    end;
    Successors=V(i).NNSuccessorSet
    Ancestry=V(i).Ancestry
    Closed=V(i).ClosedSet
    Open=V(i).OpenSet
end;
return;