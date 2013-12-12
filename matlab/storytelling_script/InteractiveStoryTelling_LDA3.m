%% Using the topic model 

clc;
close all;
clear all;
SetPath();
TextOptions={};

%% Read Shahriar's dataset to read count data / data not normalized

[s_TermVectorMatrix,DocList,EntityList,NumUniqueEntities,NumDocs]=...
    ReadSparseTextData();
% Remove terms and data based on Gini cutoff
[s_TermVectorMatrix,EntityList,NumUniqueEntities,DocList,NumDocs]=...
    GetTermDocFreqMatrix(s_TermVectorMatrix,EntityList,NumUniqueEntities,NumDocs,DocList);

% Create term document matrix based on raw term counts
TermDocumentDataMatrix = copyTermDocumentMatrixFromStruct(NumDocs,NumUniqueEntities, s_TermVectorMatrix, EntityList);

OldTermDocumentDataMatrix=TermDocumentDataMatrix;
Old_s_TermVectorMatrix=s_TermVectorMatrix;

% Create neighborhood/binary distance matrix based on overlapping terms
NUMENTMATCHIFADJ=1; % number of entities to match to consider adjacent
dist.option=5;
BinaryDMatrix = getBinaryNeighborMatrix(NumDocs, EntityList, s_TermVectorMatrix);

% Define adjacency matrix based on distance or based on if terms are shared

%dist.option=dist.opt; % use the distance function and thresholding for Adjacency matrix
dist.option=5;
if dist.option==5
    TermBasedAdj=~logical(BinaryDMatrix);
else
    TermBasedAdj=(D<=EdgeThreshold);
end;

[phi, theta, TopicWordDistr, DocTopicDistr, DocTermDist] = ...
topicModelLDA_Gibbs(NN, NumDocs, NumUniqueEntities, TermDocumentDataMatrix);
zinit=Z;
phiWithoutFeedback=phi;
thetaWithoutFeedback=theta;
TopicWordDistrWithoutFeedback=TopicWordDistr;
DocTopicDistrWithoutFeedback=DocTopicDistr;
DocTermDistWithoutFeedback=DocTermDist;


%% Once topics have been identified, use topics as words and redefine vector space
% EntityList still has list of original entities

NumUniqueEntities=T;
% TopicList is now list of topics
TopicList=cell(1,NumUniqueEntities);
for i=1:NumUniqueEntities
    TopicList{i}=strcat('T',num2str(i));
end;

% Redefine termvector matrix 
% term freq=tf is now theta or topic weight
% terms=topics

s_TopicVectorMatrix=cell(1,NumDocs);
count=1;
for i=1:NumDocs
    s_temp=struct('tf',{},'Entity',{});
    for j=1:NumUniqueEntities
        s_temp(1,j).tf=theta(i,j);
        s_temp(1,j).Entity=TopicList{j};
    end;
    s_TopicVectorMatrix{i}=s_temp;
end; 

s_TermVectorMatrix=s_TopicVectorMatrix;
TermDocumentDataMatrix=zeros(NumDocs,NumUniqueEntities);
for i=1:NumDocs
    TermVector=GetTermVector(s_TermVectorMatrix{i},TopicList);
    TermDocumentDataMatrix(i,:)=TermVector;
end;

%% Create distance matrix
% Use old Adjacency matrix based on termvector
EdgeThreshold=Inf;
%EdgeThreshold=0.3;
dist.opt=3;
TermWt=ones(1,NumUniqueEntities)./NumUniqueEntities;
verbose=1;

Adj=TermBasedAdj;
D=CreateDistanceMatrix(s_TermVectorMatrix,TopicList,TermWt,NumDocs,dist.opt);

% Create MDS of documents based on distance matrix
dims=2; % 2-D MDS
MDScoords=GetMDSCoords(D,NumDocs,dims);
cfprintf(2,'\n Output the terms in the Original Path documents \n');
for i=1:length(PathWithoutFeedback)
    n=PathWithoutFeedback(i);
    EntityList(OldTermDocumentDataMatrix(n,:)>0)
end;


%%  Shortest path from start to goal via FeedbackNodeSequence
FeedbackNodeSequence=[8 96];

fprintf(2,'\n The Feedback Documents \n');
disp(char(DocList{FeedbackNodeSequence}))
fprintf(2,'\n Output the terms in the Feedback documents \n');
for i=1:length(FeedbackNodeSequence)
    n=FeedbackNodeSequence(i);
    EntityList(OldTermDocumentDataMatrix(n,:)>0)
end;

[Path,V,FigNum]=AstarSearchViaNodes2(Adj,DocList,TopicList, ...
    s_TermVectorMatrix,FeedbackNodeSequence,MDScoords,start,goal,TermWt,NeighborEdgeThreshold,dist.opt);

PathViaFeedback=Path; VViaFeedback=V;

fprintf(1,'Path from start to goal: %s \n', num2str(PathViaFeedback));
fprintf(2,'\n The Feedback Path Documents \n');
disp(char(DocList{PathViaFeedback}))
fprintf(2,'\n Output the terms in the Feedback Path documents \n');
for i=1:length(PathViaFeedback)
    n=PathViaFeedback(i);
    EntityList(OldTermDocumentDataMatrix(n,:)>0)
end;

%% Obtain relationships based on paths

O=[VWithoutFeedback(logical([VWithoutFeedback.OpenSet]==1)).Node];   % Open Set/ includes goal
NumRelationships=length(O); % since Pstar will be compared with each path corresponding to an O element
RelationshipMatrix=zeros(NumDocs,NumDocs,NumRelationships);
for i=1:length(O)
    l=O(i);
    if l==goal
        d_s_l=GetPathforOpenNode(VWithoutFeedback,l);
    else
        d_s_l=[GetPathforOpenNode(VWithoutFeedback,l) goal]; % complete heuristic path via the open node
    end;

    for j=1:length(PathViaFeedback)-1
        %defining an edge on the right of the relationship
        startnode=PathViaFeedback(j);
        endnode=PathViaFeedback(j+1);
        RelationshipMatrix(startnode,endnode,i)=1;
    end;
    
    for j=1:length(d_s_l)-1
        %defining an edge on the left of the relationship
        startnode=d_s_l(j);
        endnode=d_s_l(j+1);
        RelationshipMatrix(startnode,endnode,i)=-1;
    end;
    
end;

%% 
close all
T=20;       % Set the number of topics
ALPHA=0.050/T;
BETA=0.01;
iterations = 5000;   % The number of iterations
SEED = 3;   % The random seed
OUTPUT = 1; % What output to show (0=no output; 1=iterations; 2=all output)

zinit=randsample(T,length(Z),true)';
[phi,L,thetamcmc,linearizedtheta,zmode,ztrace,RelationshipMatrixNEW] = GibbsSamplerLDA_Feedback5_7( WS, DS, T, zinit, ...
    iterations, ALPHA, BETA, RelationshipMatrix, D);

TopicWordDistr=cell(1,T);
for t=1:T
    topic=phi(:,t);
    [sortedwt, index]=sort(-topic);
    for i=1:size(phi,1)
        if topic(index(i))>0
        TopicWordDistr{t}=strcat(TopicWordDistr{t},',', EntityList(index(i)),num2str(sortedwt(i)));
        end;
    end;
    fprintf(2,'\n\n Topic %d %s',t,char(TopicWordDistr{t}));
end;
fprintf(2,'\n');

theta=zeros(NumDocs,T);
for d=1:NumDocs
    t=reshape(thetamcmc(d,:,:),T,iterations);
    theta(d,:)=mean(t,2);
end;

DocTopicDistr=cell(1,NumDocs);
for d=1:NumDocs
    theta(d,:)=theta(d,:)./sum(theta(d,:));
    index=find(theta(d,:)>0);
    DocTopicDistr{d}=char(strrep([DocList{d},',',num2str([index,-99,theta(d,index)])],char('-99'),','));
    disp(DocTopicDistr{d})
end;

phiWithFeedback=phi;
thetaWithFeedback=theta;
TopicWordDistrWithFeedback=TopicWordDistr;
DocTopicDistrWithFeedback=DocTopicDistr;
DocTermDistWithFeedback=DocTermDist;

fprintf(2,'\n\n Mu Estimates from Supervised Topic Model');
Delta=CreateDeltaMatrix(RelationshipMatrixNEW,theta);
Delta*TermWt'


%% Once topics have been identified, use topics as words and redefine vector space

s_TopicVectorMatrixPostFeedback=cell(1,NumDocs);
count=1;
for i=1:NumDocs
    s_temp=struct('tf',{},'Entity',{});
    for j=1:NumUniqueEntities
        s_temp(1,j).tf=theta(i,j);
        s_temp(1,j).Entity=TopicList{j};
    end;
    s_TopicVectorMatrixPostFeedback{i}=s_temp;
end; 

% Create term document matrix based on raw term counts
TermDocumentDataMatrixPostFeedback=zeros(NumDocs,NumUniqueEntities);
for i=1:NumDocs
    TermVector=GetTermVector(s_TopicVectorMatrixPostFeedback{i},TopicList);
    TermDocumentDataMatrixPostFeedback(i,:)=TermVector;
end;

%% Visualize new MDS graph
DReWeight=CreateDistanceMatrix(s_TopicVectorMatrixPostFeedback,TopicList,TermWt,NumDocs,dist.opt);
% Create MDS of documents based on distance matrix
dims=2; % 2-D MDS
NewMDScoords=GetMDSCoords(DReWeight,NumDocs,dims);

% Display 2-D visualization of graph based on MDS coordinates
fignum=DisplayMDSGraph(NewMDScoords,TermBasedAdj,DocList,NumDocs);

%% Astar Search from start to goal with new weights
NeighborEdgeThreshold=Inf; % for Astar search expansion 
[NewPath,NewV,fignum]=AstarSearch(TermBasedAdj,DocList,TopicList, ...
    s_TopicVectorMatrixPostFeedback,NewMDScoords,start,goal,TermWt,NeighborEdgeThreshold,dist.opt);


fprintf(2,'Path from start to goal Without Feedback:\n'); disp(char(DocList{PathWithoutFeedback}))
fprintf(2,'\n Output the terms in the WithoutFeedback Path documents \n');
for i=1:length(PathWithoutFeedback)
    n=PathWithoutFeedback(i);
    EntityList(OldTermDocumentDataMatrix(n,:)>0)
end;
fprintf('\n');

fprintf(2,'\n The Feedback Documents \n'); disp(char(DocList{FeedbackNodeSequence}))
fprintf(2,'\n Output the terms in the Feedback documents \n');
for i=1:length(FeedbackNodeSequence)
    n=FeedbackNodeSequence(i);
    EntityList(OldTermDocumentDataMatrix(n,:)>0)
end;
fprintf('\n');
fprintf('\n');

fprintf(2,'Path from start to goal Via Feedback:\n'); disp(char(DocList{PathViaFeedback}))
fprintf(2,'\n Output the terms in the WithoutFeedback Path documents \n');
for i=1:length(PathViaFeedback)
    n=PathViaFeedback(i);
    EntityList(OldTermDocumentDataMatrix(n,:)>0)
end;
fprintf('\n');

fprintf(2,'Path from start to goal in New Topic space:\n'); disp(char(DocList{NewPath}))
fprintf(2,'\n Output the terms in the New Path documents \n');
for i=1:length(NewPath)
    n=NewPath(i);
    EntityList(OldTermDocumentDataMatrix(n,:)>0)
end;
fprintf('\n');

%% Calculate word associations p(row word | col word)

wordAssoBeforeFeedback=zeros(length(EntityList),length(EntityList));
for w1=1:length(EntityList)
    p1=phiWithoutFeedback(w1,:)./sum(phiWithoutFeedback(w1,:));
    for w2=1:length(EntityList)
        p2=phiWithoutFeedback(w2,:);
        wordAssoBeforeFeedback(w1,w2)=sum(p1.*p2);
    end;
end;
        
wordAssoWithFeedback=zeros(length(EntityList),length(EntityList));
for w1=1:length(EntityList)
    p1=phiWithFeedback(w1,:)./sum(phiWithFeedback(w1,:));
    for w2=1:length(EntityList)
        p2=phiWithFeedback(w2,:);
        wordAssoWithFeedback(w1,w2)=sum(p1.*p2);
    end;
end;


for i=1:100
    fprintf('\n\n %s :',char(EntityList(i)));
    temp=wordAssoWithFeedback(i,:);
    [val,index]=sort(temp,'descend');
    for j=1:10
        fprintf(' %s(%f)',char(EntityList(index(j))),val(j));
    end;
    fprintf(' \n         ');
    
    temp=wordAssoBeforeFeedback(i,:);
    [val,index]=sort(temp,'descend');
    for j=1:10
        fprintf(' %s(%f)',char(EntityList(index(j))),val(j));
    end;
end;


DiffInWordAsso=wordAssoWithFeedback-wordAssoBeforeFeedback;
CUTOFF=(max(DiffInWordAsso(:))+min(DiffInWordAsso(:)))/2;
[r,c,v]=find(DiffInWordAsso>=CUTOFF);
temp=[r c];
v=diag(DiffInWordAsso(r,c)); % values of word asso for all r vs c combinations
EntityPairsofInterest=[ r c v];

EntityPairsofInterest=sortrows(EntityPairsofInterest,3);
for i=1:size(EntityPairsofInterest,1)
    fprintf('\n %s %s %d',char(EntityList(EntityPairsofInterest(i,1))),...
    char(EntityList(EntityPairsofInterest(i,2))),EntityPairsofInterest(i,3));
end;
fprintf('\n');

%Calculate word associations p(rowword in doc1| colword in doc2) 
%|WS(k)| contains the word indices for the kth token.
%|DS(k)| contains the document indices for the kth token.

doc1=NewPath(1); % start
wordAsso_w2doc2_w1doc1=zeros(length(EntityList),length(EntityList),length(NewPath)-1);
for i=2:length(NewPath)
    doc2=NewPath(i);
    for w1=1:length(EntityList)  % word in doc1
        probtopic=phiWithFeedback(w1,:).*thetaWithFeedback(doc1,:); % posterior predictive prob(topic=t|w1 in doc1)
        probtopic=probtopic./sum(probtopic);
        for w2=1:length(EntityList)     % word in doc2
            wordAsso_w2doc2_w1doc1(w1,w2,i)=sum(phiWithFeedback(w2,:).*...
                probtopic);
        end;
    end;  
    EntitiesInDoc1=find(OldTermDocumentDataMatrix(doc1,:)>0);
    [r,c,v]=find(wordAsso_w2doc2_w1doc1(:,:,i)>0);
    for j=1:length(r)
        if ismember(r(j),EntitiesInDoc1)
            fprintf('\n Doc%d -  %s %s %d',NewPath(i),char(EntityList(r(j))), ...
                char(EntityList(c(j))),wordAsso_w2doc2_w1doc1(r(j),c(j),i));
        end
    end;
end;


%% Calculate word associations p(row word | col word) for a specific document
doc1=NewPath(2); % start
EntitiesInDoc1=find(OldTermDocumentDataMatrix(doc1,:)>0);
wordAssoWithFeedback_DocSpecific=zeros(length(EntitiesInDoc1),length(EntityList));
wordAssoBeforeFeedback_DocSpecific=zeros(length(EntitiesInDoc1),length(EntityList));

for i=1:length(EntitiesInDoc1)  % only words in doc1
    w1=EntitiesInDoc1(i); % w1 is a word in doc1
    probtopic=phiWithFeedback(w1,:).*thetaWithFeedback(doc1,:); % posterior predictive prob(topic=t|w1 in doc1)
    probtopic=probtopic./sum(probtopic);
    for w2=1:length(EntityList)     % word in doc2
        wordAssoWithFeedback_DocSpecific(i,w2)=sum(phiWithFeedback(w2,:).*...
            probtopic);
    end;
    
    fprintf('\n\n %s :',char(EntityList(w1)));
    temp=wordAssoWithFeedback_DocSpecific(i,:);
    [val,index]=sort(temp,'descend');
    for j=1:10
        if ismember(index(j),EntitiesInDoc1) && index(j)~=w1
            fprintf(' %s(%f)',char(EntityList(index(j))),val(j));
        end;    
    end;
    fprintf(' ----');
    for j=1:10
        if ~ismember(index(j),EntitiesInDoc1) && index(j)~=w1
            fprintf(' %s(%f)',char(EntityList(index(j))),val(j));
        end;
    end;
    
    fprintf('\n         ');
    
    probtopic=phiWithoutFeedback(w1,:).*thetaWithoutFeedback(doc1,:); % posterior predictive prob(topic=t|w1 in doc1)
    probtopic=probtopic./sum(probtopic);
    for w2=1:length(EntityList)     % word in doc2
        wordAssoBeforeFeedback_DocSpecific(i,w2)=sum(phiWithoutFeedback(w2,:).*...
            probtopic);
    end;
    
    fprintf('\n      ');
    temp=wordAssoBeforeFeedback_DocSpecific(i,:);
    [val,index]=sort(temp,'descend');
    for j=1:10
        if ismember(index(j),EntitiesInDoc1) && index(j)~=w1
            fprintf(' %s(%f)',char(EntityList(index(j))),val(j));
        end;
    end;
    fprintf(' ----');
    for j=1:10
        if ~ismember(index(j),EntitiesInDoc1) && index(j)~=w1
            fprintf(' %s(%f)',char(EntityList(index(j))),val(j));
        end;
    end;
    
    fprintf('\n         ');
    
end;
fprintf('\n');



%% Calculating importance values for words post feedback
% show closer doc pairs have similar importance weights for overlapping
% terms
 
IVf=zeros(NumDocs,length(EntityList));  % importance value matrix
NormalizedIVf=zeros(NumDocs,length(EntityList));  % normalized importance value matrix
 
for d=1:NumDocs
    doc1=d; % start
    wordAsso=zeros(length(EntityList),length(EntityList)); % word association for document doc1
 
    for w1=1:length(EntityList)  % word in doc1
        probtopic=phiWithFeedback(w1,:).*thetaWithFeedback(doc1,:); % posterior predictive prob(topic=t|w1 in doc1)
        probtopic=probtopic./sum(probtopic);
        for w2=1:length(EntityList)     % word in doc2
            wordAsso(w1,w2)=sum(phiWithFeedback(w2,:).*...
                probtopic);
        end;
    end;
    
    wordsindoc1=find(OldTermDocumentDataMatrix(doc1,:)>0);
    wordsNOTindoc1=setdiff(1:length(EntityList),wordsindoc1);
    IVf(doc1,wordsindoc1)=sum(wordAsso(wordsindoc1,wordsNOTindoc1),2)+1;
    NormalizedIVf(doc1,:)=IVf(doc1,:)./sum(IVf(doc1,:));
    
    fprintf(1,'\n %s - ',char(DocList(doc1)));
    for i=1:length(wordsindoc1)
        fprintf(' %s ',char(EntityList(wordsindoc1(i))));
    end;
    fprintf(' %f ',IVf(doc1,wordsindoc1));
    fprintf(' -');
    fprintf(' %f ',NormalizedIVf(doc1,wordsindoc1));
    fprintf('\n');
end;
 
 
IVfplot=zeros((sum(TermBasedAdj(:))-NumDocs),5);
count=1;
for doc1=1:NumDocs
    wordsindoc1=find(OldTermDocumentDataMatrix(doc1,:)>0);
    for doc2=doc1+1:NumDocs
        if TermBasedAdj(doc1,doc2)==1
            wordsindoc2=find(OldTermDocumentDataMatrix(doc2,:)>0);
            CommonTerms=intersect(wordsindoc1,wordsindoc2);
            UnCommonTerms=unique(setdiff(union(wordsindoc1,wordsindoc2),CommonTerms));
            temp1=mean(abs(IVf(doc1,CommonTerms)-IVf(doc2,CommonTerms)));
            temp2=mean(abs(IVf(doc1,UnCommonTerms)-IVf(doc2,UnCommonTerms)));
            
            %temp1=sum(abs(IVf(doc1,:)-IVf(doc2,:)));
            
            %temp=sum(abs(NormalizedIVf(doc1,:)-NormalizedIVf(doc2,:)));
            %temp=sum(abs(NormalizedIVf(doc1,CommonTerms)-NormalizedIVf(doc2,CommonTerms)));
            
            %temp1=sum(abs(NormalizedIVf(doc1,CommonTerms)-NormalizedIVf(doc2,CommonTerms)));
            %temp2=sum(abs(NormalizedIVf(doc1,UnCommonTerms)-NormalizedIVf(doc2,UnCommonTerms)));
            IVfplot(count,:)=[doc1 doc2 DReWeight(doc1,doc2) temp1 temp2];
            count=count+1;
            
            
            if DReWeight(doc1,doc2)<0.02 && temp1<0.1
                char(DocList(doc1))
                char(DocList(doc2))
            end;
            
        end;
    end;
end;
 
figure(1005)
clf(1001);
plot(IVfplot(:,3),IVfplot(:,4),'.'); hold on;
plot(IVplot(:,3),IVplot(:,5),'r.');

%% Calculating importance values for words before feedback
% show closer doc pairs have similar importance weights for overlapping
% terms
 
IV=zeros(NumDocs,length(EntityList));  % importance value matrix
NormalizedIV=zeros(NumDocs,length(EntityList));  % normalized importance value matrix
 
for d=1:NumDocs
    doc1=d; % start
    wordAsso=zeros(length(EntityList),length(EntityList)); % word association for document doc1
 
    for w1=1:length(EntityList)  % word in doc1
        probtopic=phiWithoutFeedback(w1,:).*thetaWithoutFeedback(doc1,:); % posterior predictive prob(topic=t|w1 in doc1)
        probtopic=probtopic./sum(probtopic);
        for w2=1:length(EntityList)     % word in doc2
            wordAsso(w1,w2)=sum(phiWithoutFeedback(w2,:).*...
                probtopic);
        end;
    end;
    
    wordsindoc1=find(OldTermDocumentDataMatrix(doc1,:)>0);
    wordsNOTindoc1=setdiff(1:length(EntityList),wordsindoc1);
    IV(doc1,wordsindoc1)=sum(wordAsso(wordsindoc1,wordsNOTindoc1),2)+1;
    NormalizedIV(doc1,:)=IV(doc1,:)./sum(IV(doc1,:));
    
    fprintf(1,'\n %s - ',char(DocList(doc1)));
    for i=1:length(wordsindoc1)
        fprintf(' %s ',char(EntityList(wordsindoc1(i))));
    end;
    fprintf(' %f ',IV(doc1,wordsindoc1));
    fprintf(' -');
    fprintf(' %f ',NormalizedIV(doc1,wordsindoc1));
    fprintf('\n');
end;
 
 
IVplot=zeros((sum(TermBasedAdj(:))-NumDocs),5);
count=1;
for doc1=1:NumDocs
    wordsindoc1=find(OldTermDocumentDataMatrix(doc1,:)>0);
    for doc2=doc1+1:NumDocs
        if TermBasedAdj(doc1,doc2)==1
            wordsindoc2=find(OldTermDocumentDataMatrix(doc2,:)>0);
            CommonTerms=intersect(wordsindoc1,wordsindoc2);
            UnCommonTerms=unique(setdiff(union(wordsindoc1,wordsindoc2),CommonTerms));
            temp1=mean(abs(IV(doc1,CommonTerms)-IV(doc2,CommonTerms)));
            temp2=mean(abs(IV(doc1,UnCommonTerms)-IV(doc2,UnCommonTerms)));
            
            %temp=sum(abs(IV(doc1,:)-IV(doc2,:)));
            
            %temp=sum(abs(NormalizedIV(doc1,:)-NormalizedIV(doc2,:)));
            %temp=sum(abs(NormalizedIV(doc1,CommonTerms)-NormalizedIV(doc2,CommonTerms)));
            
            %temp1=sum(abs(NormalizedIV(doc1,CommonTerms)-NormalizedIV(doc2,CommonTerms)));
            %temp2=sum(abs(NormalizedIV(doc1,UnCommonTerms)-NormalizedIV(doc2,UnCommonTerms)));
            IVplot(count,:)=[doc1 doc2 D(doc1,doc2) temp1 temp2];
            count=count+1;
        end;
    end;
end;

 
figure(1001)
clf(1001);
plot(IVplot(:,3),IVplot(:,4),'.'); hold on;
plot(IVplot(:,3),IVplot(:,5),'r.');
