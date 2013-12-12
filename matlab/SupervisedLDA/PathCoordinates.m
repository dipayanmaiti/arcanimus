function X=PathCoordinates(Path,s_TermVectorMatrix,EntityList,TermWt,option)

precision=0.5;
L=length(Path);
NumUniqueEntities=size(EntityList,2);
X=[];
for i=1:L-1
    a=GetTermVector(s_TermVectorMatrix{Path(i)},EntityList);
    b=GetTermVector(s_TermVectorMatrix{Path(i+1)},EntityList);
    %d=GetDistance(a,b,TermWt,option);
    %lambda=precision/d;
    
    lambda=0.1;
    
    k=ceil(1/lambda)-1;
    temp=zeros(NumUniqueEntities,k);
    for j=0:k
        temp(:,j+1)=(1-lambda*j)*a'+(lambda*j)*b';
    end;
    X=[X temp];
end
X=[X b'];
return;