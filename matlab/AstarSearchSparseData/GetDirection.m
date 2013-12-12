function UnitVector=GetDirection(TermVector1,TermVector2,TermWt,option)
% Finds the Unit Vector from TermVector1 to TermVector1
p=size(TermVector1,2);
UnitVector=(TermVector2-TermVector1);
LenUnitVector=GetDistance(zeros(1,p),UnitVector,TermWt,option);
UnitVector=UnitVector./LenUnitVector;
return;