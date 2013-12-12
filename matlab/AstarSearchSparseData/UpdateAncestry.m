function yAncestry=UpdateAncestry(x,xAncestry,NodeSequence)

% Update ancestry for neighbor node y. If predecessor x for
% Neighbor y is an element of NodeSequence, then the ancestry
% for Neighbor y will be ancestry of its predecessor x
% followed by x itself. If the predecessor for
% Neighbor node y is not an element of NodeSequence, then
% ancestry for y is the same as the ancestry for its
% predecessor x.

if isempty(setdiff(x,NodeSequence)) % x is in NodeSequence
    yAncestry=[xAncestry x];
elseif ~isempty(setdiff(x,NodeSequence))
    yAncestry=xAncestry;
end;

return;