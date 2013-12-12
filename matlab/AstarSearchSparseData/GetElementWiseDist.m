function d=GetElementWiseDist(TermVector1,TermVector2,option)

if option==0 % Euclidean distance
    d=(TermVector1-TermVector2).*(TermVector1-TermVector2);
elseif option==2 % Squared Euclidean distance
    d=(TermVector1-TermVector2).*(TermVector1-TermVector2);
elseif option==3 % Manhattan distance
    d=abs(TermVector1-TermVector2);
elseif option==1 %Soergel distance
    error('Soergel Distance does not have elementwise components');
end;

if logical(any(isnan(d)) || any(isinf(d)))
    d
    error('Elementwise Distance component Inf or NaN');
    TermVector1
    TermVector2
end;


return;