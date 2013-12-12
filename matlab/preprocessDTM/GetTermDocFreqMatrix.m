% filtering criteria
MINENTITYCT=2; % entities that occur at least MINENTITYCT times in the corpus
DOCENTITYCT=1; % docs with at least DOCENTITYCT entities


function [new_s_TermVectorMatrix,newEntityList,NumUniqueEntities,newDocList,NumDocs]=...
    GetTermDocFreqMatrix(s_TermVectorMatrix,EntityList,NumUniqueEntities,NumDocs,DocList)

% create entity data matrix
TermDocumentDataMatrix = copyTermDocumentMatrixFromStruct(s_TermVectorMatrix, NumDocs, NumUniqueEntities, EntityList);

% create list of ginis
s_EntityList_P = getGiniForEntities(TermDocumentDataMatrix, EntityList, NumUniqueEntities);

[GSorted, index] = ...
    sort([s_EntityList_P.Gini],'descend');  % high-to-low : high-gini means inequality, low-gini means equality
%[GSorted, index] = sort([s_EntityList_P.Gini],'ascend');
% define top proportion of terms to be taken

alpha=0.9;
RankRange=1:floor(alpha*NumUniqueEntities);
%RankRange=floor(0*NumUniqueEntities)+1:floor(0.85*NumUniqueEntities);

figure(GetNextFigureNumber);
subplot(1,2,1);
plot(GSorted,'ko-'); hold on;
for k=1:NumUniqueEntities
    text(k,GSorted(k),s_EntityList_P(index(k)).Entity,'Rotation',90);
end;
subplot(1,2,2);
plot(RankRange,GSorted(RankRange)); 
hold on;
for k=1:length(RankRange)
    text(k,GSorted(k),s_EntityList_P(index(k)).Entity,'Rotation',90);
end;

% filter entities and documents based on minimum count cutoffs
new_s_TermVectorMatrix = filterTermDocumentFrequencyMatrix(DocsWithZeroEntities, newEntityList, s_TermVectorMatrix, NumDocs);

NumDocs=length(newDocList);
NumUniqueEntities=length(newEntityList);

return;



%% Create neighborhood/binary distance matrix based on overlapping terms
function [BinaryDMatrix] = getBinaryNeighborMatrix(NumDocs, EntityList, s_TermVectorMatrix)

BinaryDMatrix=zeros(NumDocs,NumDocs);
for i=1:NumDocs
for j=i+1:NumDocs
TermVector1=GetTermVector(s_TermVectorMatrix{i},EntityList);
TermVector2=GetTermVector(s_TermVectorMatrix{j},EntityList);
% TermVectorIndices1=find(TermVector1>0);
% TermVectorIndices2=find(TermVector2>0);
t=TermVector1.*TermVector2;
BinaryDMatrix(i,j)=1-logical(sum(t>=1));
BinaryDMatrix(j,i)=BinaryDMatrix(i,j);
end;
end;

return;



%% create entity data matrix
function [TermDocumentDataMatrix] = copyTermDocumentMatrixFromStruct(NumDocs,NumUniqueEntities, s_TermVectorMatrix, EntityList)
TermDocumentDataMatrix = zeros(NumDocs,NumUniqueEntities);
for i=1:NumDocs
    TermVector=GetTermVector(s_TermVectorMatrix{i},EntityList);
    TermDocumentDataMatrix(i,:)=TermVector;
end;

return;



%% create list of ginis
function [s_EntityList_P] = getGiniForEntities(TermDocumentDataMatrix, EntityList, NumUniqueEntities)

G=zeros(1,NumUniqueEntities);
s_temp=struct('Entity',[],'Gini',[]);
s_EntityList_P=repmat(s_temp,1,NumUniqueEntities);
for i=1:NumUniqueEntities
    A=TermDocumentDataMatrix(:,i)';
    G(i)=GetGini(A);
    s_EntityList_P(i).Entity=EntityList{i};
    s_EntityList_P(i).Gini=G(i);
end;

return;



%% filter entities and documents based on minimum count cutoffs
function [DocsWithZeroEntities, newDocList, newEntityList] = filterDocsEntities(RankRange, NumDocs, TermDocumentDataMatrix)

NumUniqueEntities=max(RankRange)-min(RankRange)+1;
check=1;
T=zeros(NumDocs+1,NumUniqueEntities+1);
T(1,2:end)=index(RankRange); % Entity index header
T(2:end,1)=1:NumDocs; % Doc index column
T(2:end,2:end)=TermDocumentDataMatrix(:,index(RankRange));

% keep filtering till condition is not satisfied
while check
    validentities=find(sum(T(2:end,2:end))>=MINENTITYCT)+1;
    temp=T(:,[1 validentities]);
    clear T; T=temp; clear temp;
    validdocs=find(sum(T(2:end,2:end)')'>=DOCENTITYCT)+1; 
    temp=T([1 validdocs'],:);
    clear T; T=temp; clear temp;
    v=find(sum(T(2:end,2:end))<MINENTITYCT); % find entities which break condition
    d=find(sum(T(2:end,2:end)')'<DOCENTITYCT); % find docs which break condition

    if ~isempty(v) || ~isempty(d)
        check=1;
    else
        check=0;
    end;
end;

%{
EntitiesWithFewCounts=find(sum(TermDocumentDataMatrix)<MINENTITYCT);
I=setdiff(index(RankRange),EntitiesWithFewCounts);
newTermDocumentDataMatrix=TermDocumentDataMatrix(:,I);
DocsWithZeroEntities=find(sum(newTermDocumentDataMatrix')'<DOCENTITYCT); 
%}

DocsWithZeroEntities=setdiff(1:NumDocs,T(2:end,1));
newDocList=DocList(T(2:end,1));
newEntityList=sort(EntityList(T(1,2:end)));

return;



%% Get new Term Document Frequency struct matrix
function [new_s_TermVectorMatrix] = filterTermDocumentFrequencyMatrix(DocsWithZeroEntities, newEntityList, s_TermVectorMatrix, NumDocs)

index1=1;
for i=1:NumDocs
    if ~ismember(i,DocsWithZeroEntities)
        
        % k=number of entities in document
        K=size(s_TermVectorMatrix{i},2);
        ValidEntityIndexList=[];
        for k=1:K
            e=s_TermVectorMatrix{i}(k).Entity;
            eIndex=find(strcmp(newEntityList,e));
            if ~isempty(eIndex)
                ValidEntityIndexList=[ValidEntityIndexList k];
            end;
        end;
        
        new_s_TermVectorMatrix{index1}=s_TermVectorMatrix{i}(ValidEntityIndexList);
        index1=index1+1;
    end;
end;

return;



