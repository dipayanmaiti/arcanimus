% =================================================================
% a theme is a group of terms which together carry a meaning.
% =================================================================



function [ThemeMap] = CreateThemeMap2(NumDocs, NumThemes)
ThemeSet1=[2 3 4]; ThemeSet2=[5 6 7 8];
ThemeSet3a=[1 2]; ThemeSet3b=[1 5];
ThemeSet4a=[9 4]; ThemeSet4b=[9 8];
for i=1:NumDocs
    u=unifrnd(0,1);
    if u<0.45
        u=unifrnd(0,1);
        if u<0.8
            ThemeMap{i}=num2cell(randsample(ThemeSet1,2));
        else
            ThemeMap{i}=num2cell(randsample(ThemeSet1,1));
        end;
    elseif u<0.88
        u=unifrnd(0,1);
        if u<0.8
            ThemeMap{i}=num2cell(randsample(ThemeSet2,2));
        else
            ThemeMap{i}=num2cell(randsample(ThemeSet2,1));
        end;
    elseif u<0.96
        u=unifrnd(0,1);
        if u<0.5
            ThemeMap{i}=num2cell(randsample(ThemeSet3a,2));
        else
            ThemeMap{i}=num2cell(randsample(ThemeSet3b,2));
        end;
    else
        u=unifrnd(0,1);
        if u<0.5
            ThemeMap{i}=num2cell(randsample(ThemeSet4a,2));
        else
            ThemeMap{i}=num2cell(randsample(ThemeSet4b,2));
        end;
    end;
end;

return;



% create theme data based on dummy terms.

function [T, NumThemes]=CreateThemeData1()

NumThemes=9;
T=cell(1,NumThemes); % Number of themes
T{1}=sort({'1A','1B','1C','1D'});
T{2}=sort({'2A','2B','2C','2D'});
T{3}=sort({'3A','3B','3C','3D',});
T{4}=sort({'4A','4B','4C','4D'});
T{5}=sort({'5A','5B','5C','5D'});
T{6}=sort({'6A','6B','6C','6D'});
T{7}=sort({'7A','7B','7C','7D'});
T{8}=sort({'8A','8B','8C','8D'});
T{9}=sort({'9A','9B','9C','9D'});
%T{10}=sort({'10A','10B','10C','10D'});

return;



% create theme data based on hypothetical stories.

function [T, NumThemes]=CreateThemeData2()

NumThemes=9;
T=cell(1,NumThemes); % Number of themes
T{1}=sort({'powder','anthrax','terror','Loc1'}); % Anthrax powder terror in Loc1
T{2}=sort({'powder','ski','winter','Loc1'}); % Loc1 a ski resort with good powder this winter
T{3}=sort({'truck','alert','orange','Loc2',}); % orange alert for a bomb in a truck in Loc2
T{4}=sort({'season','rain','orange','demand'}); % orange demand due to seasonal rain
T{5}=sort({'bank','river','rain','alert'}); % rain caused alert in river banks
T{6}=sort({'bank','risky','loan','defaulting'}); % defaults on risky bank loans
T{7}=sort({'bank','robbery','truck','Loc2'});
T{8}=sort({'weather','frost','impact','produce'});
T{9}=sort({'apple','farmer','local','frost'});
%T{10}=sort({'protest','farmer','fair','apple'});

return;



% create noisy entities. these entitities are what would be in the corpus
% in addition to the theme entities.

function [NumNoiseEntities, NoiseEntities] = CreateNoiseEntities()

NumNoiseEntities=26^3;
NoiseEntities=cell(NumNoiseEntities,2);
count=1;
for i=1:26
    for j=1:26
        for k=1:26
            NoiseEntities{count,1}=0;
            NoiseEntities{count,2}=char(96+[i j k]);
            count=count+1;
        end;
    end;
end;

return;



% create a themap for the documents.

function [ThemeMap] = CreateThemeMap(NumDocs, NumThemes)

ThemeMap=cell(1,NumDocs);
for i=1:NumDocs
    u=unifrnd(0,1);
    if u<0.8
        ThemeMap{i}=num2cell(randsample(NumThemes,2)');
    else
        ThemeMap{i}=num2cell(randsample(NumThemes,1)');
    end;
end;

return;
                             
                                          
                             
% create a list of document names with corresponding themes.
                                          
function [DocList] = CreateDocs(ThemeMap, NumDocs)
                                          
DocList=cell(1,NumDocs);
for i=1:NumDocs
    DocList{i}=strcat(' D',num2str(i),'-',...
    strrep(num2str(sort(cell2mat(ThemeMap{i}))),' ','.'));
end;
return;
                                          
                                          

% Create dictionary of terms
                                          
function [EntityList, NumUniqueEntities] = CreateDictionary(NumDocs, s_TermVectorMatrix)
EntityList={};
count=1;
for i=1:NumDocs
    % Number of entities in the document
    NumEntities=size(s_TermVectorMatrix{i},2);
    for j=1:NumEntities
       t=s_TermVectorMatrix{i}(j).Entity;
        if ~isalreadyinlist(t,EntityList)
            EntityList{count}=t;
            count=count+1;
        end;
    end;
end;
EntityList=sort(EntityList);
NumUniqueEntities=size(EntityList,2);
return;
                             
                             

% create Term-vector matrix
function [s_TermVectorMatrix] = CreateTermVectorMatrix(NumDocs, ThemeMap, NoiseEntities, NumNoiseVector)
                             
s_TermVectorMatrix=cell(1,NumDocs);
count=1;
for i=1:NumDocs
    ThemeIndices=cell2mat(ThemeMap{i}); % Theme indices for the document based on ThemeMap
                             
    % Obtain theme entities for document
    Entities_temp=[];
    for j=1:size(ThemeIndices,2)
        Entities_temp=[Entities_temp T{ThemeIndices(j)}];
    end;
                             
    % Obtain noise entities for document
    for j=1:NumNoiseVector(i)
        Entities_temp=[Entities_temp NoiseEntities{count,2}];
        count=count+1;
    end;
                             
    s_temp=struct('tf',{},'Entity',{});
                             
    % Specify with what count you would like to sample the term counts
    % along with their sampling weights. Higher counts have to be samped
    % with lower weights.
                             
    for j=1:size(Entities_temp,2)
        % s_temp(1,j).tf=randsample([1:10],1,true,[10:-1:1].^10);
        s_temp(1,j).tf=randsample([3:12],1,true,[10:-1:1].^10);
        s_temp(1,j).Entity=Entities_temp{j};
    end;
    s_TermVectorMatrix{i}=s_temp;
end;
                             
return;