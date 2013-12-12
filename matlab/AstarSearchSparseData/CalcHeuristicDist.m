function h=CalcHeuristicDist(s_TermVectorMatrix,start,goal,EntityList,TermWt,distopt)

TermVector1=GetTermVector(s_TermVectorMatrix{start},EntityList);
TermVector2=GetTermVector(s_TermVectorMatrix{goal},EntityList);
h=GetDistance(TermVector1,TermVector2,TermWt,distopt);

return;