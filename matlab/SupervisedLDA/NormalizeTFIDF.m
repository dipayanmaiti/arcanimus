function [s_TermVectorMatrix,TermDocumentDataMatrix]=...
    NormalizeTFIDF(s_TermVectorMatrix,EntityList,NumUniqueEntities,NumDocs)


% Create df and idf vector for entities
df=zeros(1,NumUniqueEntities);
for i=1:NumUniqueEntities
    Entity2Compare=EntityList{i};
    count=0;
    for j=1:NumDocs
        % k=number of entities in document
        K=size(s_TermVectorMatrix{j},2);
        for k=1:K
            if strcmp(Entity2Compare,s_TermVectorMatrix{j}(k).Entity)
                count=count+1;
                break;
            end;
        end;
    end;
    df(i)=count;
end;

if var(df)==0
    idf=ones(1,NumUniqueEntities);
else
    idf=-log(df./NumDocs);
end;

% Apply tf-idf weighting to documents entities

for i=1:NumDocs
    % k=number of entities in document
    K=size(s_TermVectorMatrix{i},2);
    w=0;
    for k=1:K
        idfIndex=find(strcmp(EntityList,s_TermVectorMatrix{i}(k).Entity)>0);
        s_TermVectorMatrix{i}(k).tf=s_TermVectorMatrix{i}(k).tf*...
            idf(idfIndex);
        w=w+s_TermVectorMatrix{i}(k).tf*s_TermVectorMatrix{i}(k).tf;
    end;   
    w=sqrt(w);
    for k=1:K
        s_TermVectorMatrix{i}(k).tf=s_TermVectorMatrix{i}(k).tf/w;
    end;
end;

% Visualize the term vector data for documents
TermDocumentDataMatrix=zeros(NumDocs,NumUniqueEntities);
for i=1:NumDocs
    TermVector=GetTermVector(s_TermVectorMatrix{i},EntityList);
    TermDocumentDataMatrix(i,:)=TermVector;
end;

return;