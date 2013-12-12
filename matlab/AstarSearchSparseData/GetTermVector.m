function TermVector=GetTermVector(s_TermVector,EntityList)

NumUniqueEntities=size(EntityList,2);
TermVector=zeros(1,NumUniqueEntities);
NumEntitiesInDoc=size(s_TermVector,2);

for i=1:NumEntitiesInDoc
    EntityToCompare=s_TermVector(i).Entity;
    I=logical(strcmp(EntityList,EntityToCompare));
    TermVector(I)=s_TermVector(i).tf;
end;

return;
