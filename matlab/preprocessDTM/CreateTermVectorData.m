function [T, ThemeMap, DocList, NumDocs, EntityList, NumUniqueEntities, s_TermVectorMatrix]=...
    CreateTermVectorData()

% create theme data.
[T, NumThemes] = CreateThemeData1();

% create noisy entities.
[NumNoiseEntities, NoiseEntities] = CreateNoiseEntities();

% Create ThemeMap. A ThemeMap corresponds to a
% mixture of themes being assigned to a document.
NumDocs=50;
[ThemeMap] = CreateThemeMap(NumDocs, NumThemes);

% create list of documents (i.e. names of docs)
DocList = CreateDocs(ThemeMap, NumDocs);

% create Term-vector matrix
NumNoiseVector=2*ones(1,NumDocs);  % Noise entities count for every document
[s_TermVectorMatrix] = CreateTermVectorMatrix(NumDocs, ThemeMap, NoiseEntities, NumNoiseVector);

% Create dictionary of terms
[EntityList, NumUniqueEntities] = CreateDictionary(NumDocs, s_TermVectorMatrix);

return;