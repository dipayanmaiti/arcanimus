function [T, ThemeMap, DocList, NumDocs, EntityList, NumUniqueEntities, s_TermVectorMatrix]=...
    CreateDiagnosticData()

% create theme data.
[T, NumThemes] = CreateThemeData1();

% create noisy entities.
[NumNoiseEntities, NoiseEntities] = CreateNoiseEntities();

%%
% Generate ThemeMap
NumDocs=50;
ThemeMap = CreateThemeMap2(NumDocs, NumThemes)

% create list of documents (i.e. names of docs)
DocList = CreateDocs(ThemeMap, NumDocs);

% create Term-vector matrix
NumNoiseVector=2*ones(1,NumDocs);  % Noise entities count for every document
[s_TermVectorMatrix] = CreateTermVectorMatrix(NumDocs, ThemeMap, NoiseEntities, NumNoiseVector);

% Create dictionary of terms
[EntityList, NumUniqueEntities] = CreateDictionary(NumDocs, s_TermVectorMatrix);

return;








