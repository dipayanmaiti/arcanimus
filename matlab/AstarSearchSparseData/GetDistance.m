function d=GetDistance(TermVector1,TermVector2,TermWt,option)
% option controls what distance function is used

if option==0 % Euclidean distance
    d=pdist([TermVector1.*sqrt(TermWt); TermVector2.*sqrt(TermWt)],'euclidean');
elseif option==2 % Squared Euclidean distance
    d=pdist([TermVector1.*sqrt(TermWt); TermVector2.*sqrt(TermWt)],'euclidean');
    d=d*d;
elseif option==3 % Manhattan distance
    %d=pdist([TermVector1.*sqrt(TermWt); TermVector2.*sqrt(TermWt)],'cityblock');
    d=pdist([TermVector1.*TermWt; TermVector2.*TermWt],'cityblock');
elseif option==1 %Soergel distance
    NumUniqueEntities=size(TermVector1,2);
    s1=0; s2=0;
    for i=1:NumUniqueEntities
        s1=s1+TermWt(i)*abs(TermVector1(i)-TermVector2(i));
        s2=s2+TermWt(i)*max(TermVector1(i),TermVector2(i));
    end;
    d=s1/s2;
elseif option==4 %Cosine distance: a real value between 0 1nd 1 if they have some terms in common and, 1 otherwise.
    d=1-sum(TermVector1.*TermVector2)/...
        sqrt(sum(TermVector1.*TermVector1)*sum(TermVector2.*TermVector2));
elseif option==5 % Binary distance: 0 if at least one word in common, 1 otherwise
    t=TermVector1.*TermVector2;
    d=1-logical(sum(t>0));
end;

if isnan(d) || isinf(d)
    d
    TermWt
    TermVector1
    TermVector2
end;
return;