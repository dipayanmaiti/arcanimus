function [s_TermVectorMatrix,DocList,EntityList,NumUniqueEntities,NumDocs]=...
    ReadSparseTextData()

% This file creates sparse text data structure based on Shahriar's text
% file

fid = fopen('/Users/cvelasco28/Dipayan/StorytellingMay31/StoryTelling_Apr30_2012/bava/Storytelling/data/tfFile.txt');

i=1;
DocList=[];
s_TermVectorMatrix=[];
count=1;
tic
while (1)
    tline = fgetl(fid);
    if ~ischar(tline)
        break;
    end;
    C = textscan(tline, '%s');
    filename=C{1}{i};
    DocList{count}=strrep(filename,'_','');
    NumEntities=0.5*(length(C{:})-1);
    
    % temp structure to store the current entity and its normalized term
    % frequency
    s_temp=struct('tf',{},'Entity',{});
    for j=1:NumEntities
        s_temp(1,j).tf=str2double(C{1}{2*j+1});
        s_temp(1,j).Entity=C{1}{2*j};
    end;
    
    s_TermVectorMatrix{count}=s_temp;
    count=count+1;
end;
NumDocs=count-1;
frewind(fid);

% Create dictionary of terms
[EntityList, NumUniqueEntities] = CreateDictionary(NumDocs, s_TermVectorMatrix); 

return;

%fid=fopen('/Users/dipayanm/Matlab/StoryTelling_Apr30_2012/bava/Storytelling/data/pubmed/tfFile_original.txt');
%fid = fopen('/Users/statmac3/Matlab/bava/StoryTelling/data/tfFile_crescent.txt');
%fid = fopen('/Users/statmac3/Matlab/bava/StoryTelling/data/tfFile_atlstorm_crescent.txt');
%fid = fopen('/Users/statmac3/Matlab/bava/StoryTelling/data/weightedTermFile_original.txt');