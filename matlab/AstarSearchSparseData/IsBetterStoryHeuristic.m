function I=IsBetterStoryHeuristic(y,V,tentative_gScore,CurrgScore,...
    tentative_fScore,CurrfScore,yAncestry,CurrAncestry,Index)

if isempty(tentative_fScore) % Open Set node Heuristic
    if length(yAncestry)>length(CurrAncestry)
        I=1;
    elseif length(yAncestry)==length(CurrAncestry)
        if tentative_gScore<=CurrgScore
            I=1;
        else
            I=0;
        end;
    else
        I=0;
    end;
else  % Closed Set node Heuristic

    Path=ReconstructPath(V,Index,[]);
    if ~any(Path==y)
        if length(yAncestry)>length(CurrAncestry)
            I=1;
        elseif length(yAncestry)==length(CurrAncestry)
            if tentative_fScore<=CurrfScore
                I=1;
            else
                I=0;
            end;
        else
            I=0;
        end;
    else
        I=0;
    end;
end;
return;