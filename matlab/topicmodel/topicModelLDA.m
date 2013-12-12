%|WS(k)| and |DS(k)| contain the word and document indices for the kth token respectively
function [WS] = getWS(NN, NumDocs, NumUniqueEntities, TermDocumentDataMatrix)

WS=zeros(1,NN); 
% WS has entity indices as a vector
index=1;
for i=1:NumDocs
    for j=1:NumUniqueEntities
        count=TermDocumentDataMatrix(i,j);
        if count>0
            WS(index:index+count-1)=j;
            index=index+count;
        end;
    end;
end;

return;



% DS has document indices as a vector
function [DS] = getDS(NN, NumDocs, NumUniqueEntities, TermDocumentDataMatrix)

DS=zeros(1,NN);
index=1;
for i=1:NumDocs
    for j=1:NumUniqueEntities
        count=TermDocumentDataMatrix(i,j);
        if count>0
            DS(index:index+count-1)=i;
            index=index+count;
        end;
    end;
end;

return;



% Gibbs sampling topic modeling algorithm
function [phi, theta, TopicWordDistr, DocTopicDistr, DocTermDist] = ...
topicModelLDA_Gibbs(NN, NumDocs, NumUniqueEntities, TermDocumentDataMatrix)

NN=sum(sum(TermDocumentDataMatrix)); % Number of terms/tokens in the corpus (i.e. word count)
WS = getWS(NN, NumDocs, NumUniqueEntities, TermDocumentDataMatrix);
DS = getDS(NN, NumDocs, NumUniqueEntities, TermDocumentDataMatrix);

%% topic modeling
T=20;       % Set the number of topics
BETA=0.01;  % Set the hyperparameters
ALPHA=0.050/T;
iterations = 5000;   % The number of iterations
SEED = 3;   % The random seed
OUTPUT = 1; % What output to show (0=no output; 1=iterations; 2=all output)

%% Gibbs sampler for topic selection in C++
[ WP,DP,Z ] = GibbsSamplerLDA( WS , DS , T , iterations , ALPHA , BETA , SEED , OUTPUT );
TopicWordDistr = getTopicWordDist(WP, T, EntityList);
DocTopicDistr = getDocTopicDistr(NumDocs, DP, DocList);
DocTermDist = getDocTermDistr(NumDocs,NumUniqueEntities, phi, theta);

return;



% normalized word topic counts from matrix of raw counts
function [phi] = getPhiFromWP(WP, T)
phi=full(WP);
for t=1:T
    phi(:,t)=phi(:,t)./sum(phi(:,t));
end;
return;



% get normalized topic word matrix
function [theta] = getthetaFromDP(DP, NumDocs)
theta=full(DP);
for d=1:NumDocs
    theta(d,:)=theta(d,:)./sum(theta(d,:));
end;
return;



% get topic-word distribution
function [TopicWordDistr, phi] = getTopicWordDist(WP, T, EntityList)

phi = getPhiFromWP(WP)
TopicWordDistr=cell(1,T);
for t=1:T
    topic=phi(:,t);
    [sortedwt, index]=sort(-topic);
    for i=1:size(phi,1)
        if topic(index(i))>0
            TopicWordDistr{t}=strcat(TopicWordDistr{t},',', EntityList(index(i)),num2str(sortedwt(i)));
        end;
    end;
    %fprintf(2,'\n Topic %d %s',t,char(TopicWordDistr{t}));
end;

return;



% get the document-topic distribution
function [DocTopicDistr] = getDocTopicDistr(NumDocs, DP, DocList)

theta = getthetaFromDP(DP, NumDocs)
DocTopicDistr=cell(1,NumDocs);
for d=1:NumDocs
    index=find(theta(d,:)>0);
    DocTopicDistr{d}=char(strrep([DocList{d},',',num2str([index,-99,theta(d,index)])],char('-99'),','));
    %disp(DocTopicDistr{d})
end;

return;



% Estimated doc-term distribution
function [DocTermDist] = getDocTermDistr(NumDocs,NumUniqueEntities, phi, theta)

DocTermDist=zeros(NumDocs,NumUniqueEntities);
for d=1:NumDocs
    DocTermDist(d,:)=phi*theta(d,:)';
end;

return;