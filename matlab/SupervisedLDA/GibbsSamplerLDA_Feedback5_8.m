function [phi,L,thetamcmc,linearizedtheta,zmode,z,RelationshipMatrix] = GibbsSamplerLDA_Feedback5_8( WS, DS, T, zinit, ...
    iterations, ALPHA, BETA, RelationshipMatrix, DistMatrix,epsilon)

% same as 5_1 but with the simpled to real normal proposal step

%|WS(k)| contains the word indices for the kth token.
%|DS(k)| contains the document indices for the kth token.
NN=length(WS); % total term count in the corpus
D=length(unique(DS)); % D=max(DS); % number of documents in the corpus
W=length(unique(WS)); % W=max(WS); % number of unique tokens in corpus
NumRels=size(RelationshipMatrix,3);
NumDocs=size(RelationshipMatrix,1);

phi=zeros(W,T);  % word topic weight matrix
thetamcmc=zeros(D,T,iterations); % mcmc samples of theta
z=zeros(iterations,NN); % mcmc samples for z. z is latent topic assignment.
linearizedtheta=zeros(D*T,iterations);
WT=1/T*ones(T,1);

% Add individual edges

temp=[];
for i=1:NumRels
    r=RelationshipMatrix(:,:,i);  % gives the +1 and -1 edges in the relationship
    % we are creating Delta(r,:)
    [r1,c1,v1]=find(r==1);
    [r2,c2,v2]=find(r==-1);
    
    if i==1
        temp=[temp; r1 c1; r2 c2];
    else
        temp=[temp; r2 c2];
    end;
end;


NumEdges=size(temp,1);
temp=[temp repmat(0,NumEdges,1)];
UniqueEdges=[];
for i=1:NumEdges
    edge=temp(i,1:2);
    if temp(i,3)==0
        UniqueEdges=[UniqueEdges; [edge DistMatrix(edge(1),edge(2))]];
    end;
    
    for j=i:NumEdges
        if temp(j,1)==edge(1) && temp(j,2)==edge(2)
            temp(j,3)=1;
        end
    end;
end;

NumUniqueEdges=size(UniqueEdges,1);
[numr,numc,NumRels]=size(RelationshipMatrix);
for i=1:NumUniqueEdges
    r=zeros(numr,numc,1);
    r(UniqueEdges(i,1),UniqueEdges(i,2))=1;
    RelationshipMatrix(:,:,NumRels+i)=r;
end;

%offset - offset is the user defined response
offset=zeros(NumRels+NumUniqueEdges,1);
for i=1:NumRels+NumUniqueEdges
    if i<=NumRels
        offset(i)=unifrnd(-epsilon,-epsilon);
    else
        offset(i)=UniqueEdges(i-NumRels,3);  % the cost of the edge
    end;
    %offset(i)=0;
end;

offset'
NumRels=NumRels+NumUniqueEdges; % redefine the new number of relationships
L=zeros(NumRels,iterations);
mutracemcmc=zeros(NumRels,iterations);
DeltaTrace=zeros(NumRels,T,iterations);


% initialization, proposls and prior parameters

for i=1:NN
    %z(1,i)=randsample(T,1); % initialize to NN topics chosen randomly from T topics
    z(1,i)=zinit(i);
end;

for d=1:D
    thetamcmc(d,:,1)=drchrnd(ones(1,T),1);
end;
linearizedtheta(:,1)=reshape(thetamcmc(:,:,1),D*T,1);
L(1:NumRels-NumUniqueEdges,1)=-abs(normrnd(0,1,NumRels-NumUniqueEdges,1));
L(NumRels-NumUniqueEdges+1:end,1)=abs(normrnd(0,1,NumUniqueEdges,1));

tic
wordIndicatorMatrix=zeros(W,NN);
for i=1:NN
    word=i;
    wordIndicatorMatrix(i,:)=logical(WS==word);
end;
wordIndicatorMatrix=logical(wordIndicatorMatrix);
toc

tic
docIndicatorMatrix=zeros(D,NN);
for j=1:D
    doc=j;
    docIndicatorMatrix(doc,:)=logical(DS==doc);
end;
docIndicatorMatrix=logical(docIndicatorMatrix);
toc

f1=GetNextFigureNumber(); figure(f1);
f2=GetNextFigureNumber(); figure(f2);
f3=GetNextFigureNumber(); figure(f3);
f4=GetNextFigureNumber(); figure(f4);
f5=GetNextFigureNumber(); figure(f5);
f6=GetNextFigureNumber(); figure(f6);


temp=[];
for i=1:NumRels
    r=RelationshipMatrix(:,:,i);  % gives the +1 and -1 edges in the relationship
    % we are creating Delta(r,:)
    [r1,c1,v1]=find(r==1);
    [r2,c2,v2]=find(r==-1);
    
    temp=[temp unique([r1' r2' c1' c2'])];
end;
temp=unique(temp);
DocsNotInRel=setdiff(1:NumDocs,temp);
 

tic
modnum=500;
for n=2:iterations
    if mod(n,modnum)==0
        n
        toc
        tic
        
%         % plot the topic-wise weights 
%         figure(f1);
%         plot(wt(:,1:n-1)');
%         
        % plot the user defined observed response (truncated but not fixed)
        figure(f2);
        hold on;
        for i=1:NumRels
            plot(L(i,1:n-1),'k');
            ylim([-50,50]);
        end;
        hold off;
        
        % plot the theta for each document
        figure(f3);
        for d=1:NumDocs
            subplot(ceil(NumDocs/10)+1,10,d)
            plot(reshape(thetamcmc(d,:,2:n-1),T,n-1-2+1)');
        end;
        
%         % plot the last 10 Delta matrix values
%         figure(f4); colorbar; hold on;
%         for i=1:modnum
%             subplot(1,modnum+2,i);
%             imagesc(DeltaTrace(:,:,n-i+1));
%         end;
%         hold off;
        
        figure(f5);
        subplot(1,2,1)
        plot(mutracemcmc(1:NumRels-NumUniqueEdges,2:n-1)','-');
        subplot(1,2,2)
        plot(mutracemcmc(NumRels-NumUniqueEdges+1:end,2:n-1)','-');        
    end;
    
    
    
    % mcmc step for z
    zprev=z(n-1,:);
    for i=1:NN
        word=WS(i); % word for ith token in corpus
        doc=DS(i);  % doc for ith token in corpus
        
        % topic freq for current token
        I=wordIndicatorMatrix(word,:); % I=logical(WS==word);
        I(i)=0;
        topics=zprev(I); % topics for word
        topicfreq_w=[(1:T)' zeros(T,2)];
        ft=tabulate(topics); % topic ID, topic freq, topic proportion
        %if ~isempty(ft)
        topicfreq_w(ft(:,1),2:3)=ft(:,2:3); % topic freq for token word
        %end;
        
        % topic freq across all tokens, excluding current token
        topicfreq=[(1:T)' zeros(T,2)];
        ft=tabulate(zprev([1:i-1,i+1:end])); % exclude current word
        %if ~isempty(ft)
        topicfreq(ft(:,1),2:3)=ft(:,2:3); % topic freq for all tokens
        %end;
        
        % topic freq for all tokens in doc, excluding current token
        I=docIndicatorMatrix(doc,:); % I=logical(DS==doc);
        I(i)=0;
        numwordsindoc=sum(I);
        topics=zprev(I); % topics for doc
        topicfreq_doc=[(1:T)' zeros(T,2)];
        ft=tabulate(topics); % topic ID, topic freq, topic proportion
        %if ~isempty(ft)
        topicfreq_doc(ft(:,1),2:3)=ft(:,2:3); % topic freq for token word
        %end;
        
        % sample topic for word based on posterior dictribution for z
        p1=(topicfreq_w(:,2)+BETA)./(topicfreq(:,2)+W*BETA);
        %p2=(topicfreq_doc(:,2)+ALPHA)./(numwordsindoc+T*ALPHA);
        p2=thetamcmc(doc,:,n-1)';
        SamplingWts=p1.*p2; % sampling weights for the full conditional sampling distribution for z
        SamplingWts=SamplingWts./sum(SamplingWts);
        randtopic=randsample(T,1,true,SamplingWts);
        zprev(i)=randtopic;
    end;
    z(n,:)=zprev;
    
    
    % mcmc sampling for theta
    % p(L|delta(theta)) x p(theta|z)
    % p(theta|z) is dirichlet
    % p(L|delta(theta)) is normal
    
    % calc dirichlet parameters for rowwise theta in p(theta|z)
    dirichletparams=ALPHA*ones(NumDocs,T);
    for d=1:NumDocs
        topics=z(n,docIndicatorMatrix(d,:));
        ft=tabulate(topics);
        dirichletparams(d,ft(:,1)')=ft(:,2)'+ALPHA;
    end;
    
    thetaprev=thetamcmc(:,:,n-1); % theta is D x T x iter
    LL=L(:,n-1);
    for d=1:NumDocs
        thetanew=thetaprev;
        
        % MH step for theta for doc d
        % propose dirichlet rv using stick breaking process

        if ~ismember(d,DocsNotInRel)
            
            PROPSIGMA=0.01;  % PROPSIGMA=0.1, hence variance=0.01
            muprev=zeros(1,T-1);
            uu=zeros(1,T-1);
            logSS1=0;
            for i=1:T-1
                if i==1
                    SS1=1;
                else
                    SS1=1-sum(thetaprev(d,1:i-1,1));
                end;
                logSS1=logSS1+log(SS1);
                muprev(i)=thetaprev(d,i,1)/SS1;  % mu for truncated normal, limits are (0,1)
                lowL=0;    % limits for truncated standard normal
                highL=1;
                uu(i)=randraw('normaltrunc', [lowL,highL,muprev(i),PROPSIGMA],1);
            end;
            
            % propose new theta
            for i=1:T-1
                if i==1 
                    thetanew(d,i,1)=uu(i);
                else
                    thetanew(d,i,1)=uu(i)*prod((1-uu(1:i-1)));
                end;
            end;
            thetanew(d,T,1)=1-sum(thetanew(d,1:T-1,1));

            munew=zeros(1,T-1);
            logSS2=0;
            for i=1:T-1
                if i==1
                    SS2=1;
                else
                    SS2=1-sum(thetanew(d,1:i-1,1));
                end;
                logSS2=logSS2+log(SS2);
                munew(i)=thetanew(d,i,1)/SS2;  % mu for truncated normal, limits are (0,1)
            end;
            
            proposal=sum(log(normcdf((1-muprev)./PROPSIGMA,0,1)-normcdf(-muprev./PROPSIGMA,0,1)))-...
                sum(log(normcdf((1-munew)./PROPSIGMA,0,1)-normcdf(-munew./PROPSIGMA,0,1)))+...
                logSS1-logSS2;

            Delta=zeros(NumRels,T);  % each row for a relationship
            
            for i=1:NumRels
                r=RelationshipMatrix(:,:,i);  % gives the +1 and -1 edges in the relationship
                % we are creating Delta(r,:)
                [r1,c1,v1]=find(r==1);
                [r2,c2,v2]=find(r==-1);
                
                if ismember(d,unique([r1' r2' c1' c2']))
                    for j=1:length(r1)
                        u=abs(thetaprev(r1(j),:)-thetaprev(c1(j),:));
                        Delta(i,:)=Delta(i,:)+u;
                    end;
                    
                    for j=1:length(r2)
                        u=-abs(thetaprev(r2(j),:)-thetaprev(c2(j),:));
                        Delta(i,:)=Delta(i,:)+u;
                    end;
                end
            end;
            Deltaprev=Delta;

            
            Delta=zeros(NumRels,T);  % each row for a relationship
            
            for i=1:NumRels
                r=RelationshipMatrix(:,:,i);  % gives the +1 and -1 edges in the relationship
                % we are creating Delta(r,:)
                [r1,c1,v1]=find(r==1);
                [r2,c2,v2]=find(r==-1);
                
                if ismember(d,unique([r1' r2' c1' c2']))
                    for j=1:length(r1)
                        u=abs(thetanew(r1(j),:)-thetanew(c1(j),:));
                        Delta(i,:)=Delta(i,:)+u;
                    end;
                    
                    for j=1:length(r2)
                        u=-abs(thetanew(r2(j),:)-thetanew(c2(j),:));
                        Delta(i,:)=Delta(i,:)+u;
                    end;
                end
            end;
            Deltanew=Delta;
            
            topics=z(n,DS==d);
            p1=sum(log(thetanew(d,topics,1)))-...
                sum(log(thetaprev(d,topics,1)));  % p(z|theta)
            p2=(-0.5*(LL-Deltanew*WT)'*(LL-Deltanew*WT))-...
                (-0.5*(LL-Deltaprev*WT)'*(LL-Deltaprev*WT)); % p(lambda|theta)
            p3=sum((ALPHA-1)*log(thetanew(d,:,1)))-...
                sum((ALPHA-1)*log(thetaprev(d,:,1)));   % prior for theta
            logMHR=p1+p2+p3+proposal;
            logu=log(rand());
            if logu<logMHR % accept new theta
                %fprintf(2,'\n (1) Accept ');
                thetaprev=thetanew;
            end;
        else
            thetaprev(d,:,1)=drchrnd(dirichletparams(d,:),1);
        end;
    end;
    thetamcmc(:,:,n)=thetaprev;
    Delta=CreateDeltaMatrix(RelationshipMatrix,thetaprev);
    linearizedtheta(:,n)=reshape(thetamcmc(:,:,n),D*T,1);
    
    % mcmc step for L (or slack variable lambda)
    mu=Delta*WT;
    for i=1:NumRels
        if i<=NumRels-NumUniqueEdges  % surplus variables
            lowL=-Inf;    % limits for truncated standard normal
            highL=-mu(i)+offset(i);
            %L(i,n)=randraw('normaltrunc', [lowL,highL,mu(i),1],1);
            L(i,n)=mu(i)+norminv(normcdf(lowL,0,1)+rand()*(normcdf(highL,0,1)-normcdf(lowL,0,1)));
        else                          % slack variables
            lowL=-mu(i)+offset(i);    % limits for truncated standard normal
            highL=Inf;
            %L(i,n)=randraw('normaltrunc', [lowL,highL,mu(i),1],1);
            L(i,n)=mu(i)+norminv(normcdf(lowL,0,1)+rand()*(normcdf(highL,0,1)-normcdf(lowL,0,1)));
        end;
    end;

    DeltaTrace(:,:,n)=Delta;
    mutracemcmc(:,n)=Delta(:,:)*WT;
    
end;

burnin=iterations/5;
thinning=10;
zmode=mode(z(burnin:thinning:end,:)); % modal topic assigned to each token

% obtain word topic freq distribution

for t=1:T
    topic=t;
    words=WS(zmode==topic);
    wordfreq=tabulate(words); % tabulates percentages in each group
    phi(wordfreq(:,1),topic)=wordfreq(:,3);
    
    % to obtain posterior distribution parameter values use equation
    % below with BETA
%     phi(wordfreq(:,1),topic)=wordfreq(:,2);
%     s=sum(phi(:,topic));
%     phi(:,topic)=(phi(:,topic)+BETA)./(s+W*BETA);
end;
phi=phi./100;


%{
% obtain doc topic distribution

for d=1:D
    doc=d;
    topics=zmode(DS==doc);
    topicfreq=tabulate(topics);
    theta(d,topicfreq(:,1))=topicfreq(:,3)';
    
    % to obtain posterior distribution parameter values use equation
    % below with ALPHA
%     theta(d,topicfreq(:,1))=topicfreq(:,2)';
%     s=sum(theta(d,:));
%     theta(d,:)=(theta(d,:)+ALPHA)./(s+T*ALPHA);
end;
%}

return;


