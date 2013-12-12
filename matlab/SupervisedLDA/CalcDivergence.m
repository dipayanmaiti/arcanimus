function PathDivergence=CalcDivergence(PShortest,PViaFeedback,FeedbackNodeSequence,binary)

% FeedbackNodeSequence has start and goal at the head and end
% binary=true means we have binary measure for divergence
% Divergence=0 if PShortest has FeedbackNodeSequence in the required order
% Divergence=1 if PShortest does not have at least node in FeedbackNodeSequence or
%              the order of nodes in PShortest is not the same as in FeedbackNodeSequence
             
if binary==true
    if isempty(setdiff(FeedbackNodeSequence,PShortest))
        Index=zeros(1,length(FeedbackNodeSequence));
        for i=1:length(FeedbackNodeSequence)
            Index(i)=find(PShortest==FeedbackNodeSequence(i));
        end; 
        if isempty(find((Index(2:end)-Index(1:end-1))<0))
            PathDivergence=0;
        else
            PathDivergence=1;
        end;
    else
        PathDivergence=1;
    end;
end;

return