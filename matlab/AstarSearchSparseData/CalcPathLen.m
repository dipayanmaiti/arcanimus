function PathLen=CalcPathLen(Path,s_TermVectorMatrix,EntityList,TermWt,distopt)
L=length(Path);
PathLen=0;
for i=1:L-1
    TermVector1=GetTermVector(s_TermVectorMatrix{Path(i)},EntityList);
    TermVector2=GetTermVector(s_TermVectorMatrix{Path(i+1)},EntityList);
    PathLen=PathLen+GetDistance(TermVector1,TermVector2,TermWt,distopt);
end;

return;