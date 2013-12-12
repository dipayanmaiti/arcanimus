function Delta=CreateDeltaMatrix(RelationshipMatrix,TermVectorMatrix)

NumDocs=size(RelationshipMatrix,1);
NumRels=size(RelationshipMatrix,3);
dim=size(TermVectorMatrix,2);

Delta=zeros(NumRels,dim);  % each row for a relationship

for i=1:NumRels
    r=RelationshipMatrix(:,:,i);  % gives the +1 and -1 edges in the relationship
    % we are creating Delta(r,:)
    [r1,c1,v1]=find(r==1);
    [r2,c2,v2]=find(r==-1);
    
    for j=1:length(r1)
        u=abs(TermVectorMatrix(r1(j),:)-TermVectorMatrix(c1(j),:));
        Delta(i,:)=Delta(i,:)+u;
    end;
    
    
    for j=1:length(r2)
        u=-abs(TermVectorMatrix(r2(j),:)-TermVectorMatrix(c2(j),:));
        Delta(i,:)=Delta(i,:)+u;
    end;
    
    % same code with length loop
    %{
    for j=1:NumDocs
        for k=1:NumDocs
            if r(j,k,1)==1
                startnode=j;
                endnode=k;
                u=abs(TermVectorMatrix(startnode,:)-TermVectorMatrix(endnode,:));    
                Delta(i,:)=Delta(i,:)+u;
            elseif r(j,k,1)==-1
                startnode=j;
                endnode=k;
                u=-abs(TermVectorMatrix(startnode,:)-TermVectorMatrix(endnode,:));    
                Delta(i,:)=Delta(i,:)+u;
            end;
        end
    end;
    %}
end;

return;