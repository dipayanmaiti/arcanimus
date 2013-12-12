function D=CreateDistanceMatrix(s_TermVectorMatrix,EntityList,TermWt,NumDocs,option)

D=zeros(NumDocs,NumDocs);
if option==0 || option==2 || option==3 % Euclidean distance / Squared Euclidean / Manhattan
    for i=1:NumDocs
        D(i,i)=0; % for Euclidean case
        for j=i+1:NumDocs
            TermVector1=GetTermVector(s_TermVectorMatrix{i},EntityList);
            TermVector2=GetTermVector(s_TermVectorMatrix{j},EntityList);
            D(i,j)=...
                GetDistance(TermVector1,TermVector2,TermWt,option);
            D(j,i)=D(i,j);
        end;
    end;
    
elseif option==1 % Soergel distance
    for i=1:NumDocs
        D(i,i)=1; % Maximum Soergel distance
        for j=i+1:NumDocs
            TermVector1=GetTermVector(s_TermVectorMatrix{i},EntityList);
            TermVector2=GetTermVector(s_TermVectorMatrix{j},EntityList);
            D(i,j)=...
                GetDistance(TermVector1,TermVector2,TermWt,option);
            D(j,i)=D(i,j);
        end;
    end;
end;
return;

