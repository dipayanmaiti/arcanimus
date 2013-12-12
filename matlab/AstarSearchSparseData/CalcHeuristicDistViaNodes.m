function h=CalcHeuristicDistViaNodes(s_TermVectorMatrix,start,goal,Ancestry,NodeSequence,EntityList,TermWt,distopt)
h=0;
s=setdiff(NodeSequence,Ancestry);
T=[start s goal];
[junk,index] = unique(T,'first');        % Capture the index, ignore junk
T=T(sort(index));
L=length(T);
for i=1:L-1
    node1=T(i);
    node2=T(i+1);
    h=h+CalcHeuristicDist(s_TermVectorMatrix,node1,node2,EntityList,TermWt,distopt);
end;
return;