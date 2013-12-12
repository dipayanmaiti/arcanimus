function NeighborIsConsistent=IsNeighborConsistent(y,start,goal,NodeSequence,yAncestry)

if ~any(logical(y==NodeSequence)) % y is not a node from NodeSequence
    if y==goal
        if isequal(yAncestry,NodeSequence)
            NeighborIsConsistent=1;
        else
            NeighborIsConsistent=0;
        end
    else
        if y==start
            NeighborIsConsistent=0;
        else
            NeighborIsConsistent=1;
        end;
    end
else                              % y is a node from NodeSequence
    if isempty(yAncestry)
        if y==NodeSequence(1)
            NeighborIsConsistent=1;
        else
            NeighborIsConsistent=0;
        end;
    else
        if find(y==NodeSequence)==find(yAncestry(end)==NodeSequence)+1
            NeighborIsConsistent=1;
        else
            NeighborIsConsistent=0;
        end;
    end;
end;

return;

%{
if neighbor belongs to NodeSequence

    if neighbor has empty ancestry
        if neighbor is first element of NodeSequence
            Consistent=1;
        else
            Consistent=0;
        end
    elseif neighbor has non-empty ancestry
        if neighbor is right next after yAncestry
            Consistent=1
        else
            Consistent=0;
        end;
    end;
    
else % neighbor Does not belong to NodeSequence

    if neighbor==goal
        if yAncestry==NodeSequence
            Consistent=1;
        else
            Consistent=0;
        end
    else
        if neighbor==start
            consistent=0;
        else
            Consistent=1;
        end;
    end
end
%}