
%{
Given w there is a shortest path, PShortest, between START and END. 
For the same w there is a 'stitched' path, PViaFeedback, between START and END via FeedbackNodeSequence.
PViaFeedback is obtained by stitching piecewise Shortest paths between any two consecutive nodes from
START to END via FeedbackNodeSequence.

Questions.

1) What is the objective function that we are trying to minimize?

        Given START and END, and FeedbackNodeSequence, what is the w and corresponding PShortest that agrees
        with user's feedback. Hence we have to define a measure of divergence between two paths, PShortest 
        and PViaFeedback given w.
        The objective function is this measure of divergence between PShortest and PViaFeedback over w. Hence 
        we search for w* where:
        w* = argmin(w) { divergence(PShortest,PViaFeedback) }

        A possible measure of divergence is the Fr?chet distance between two paths. 

        Points that I need to understand:
        What does this similarity of paths entail?
        Is it easily extendable to higher dimensions for piecewise linear edge connections?
        Is the minimum distance zero if and only if the two paths have the same sequence of nodes?
        Are there any simplifications because of the fact that both the paths (PShortest and PViaFeedback)
        have the same START and END. Note that Fr?chet distance is the distance between two paths of arbitrary lengths.

2) Does there exist a solution region for w for which PShortest and PViaFeedback are the same?
3) What is the unique w such that PShortest=PViaFeedback and PShortest=PShortest*, where PShortest* is the 
shortest path over all shortest paths between START to END over all possible values of w.
4) Is w unique by default? i.e. is the objective function convex in terms of w? i.e. is it that there exists 
a unique w such that divergence between PShortest and PViaFeedback is minimum? We have to put in the condition that
we are interested in only the dimensions of w corresponding to terms that are in the documents in FeedbackNodeSequence.

FOR now, we ignore if the w otained is the one corresponding to PShortest*. We are only interested in minimizing 
the divergence. We will run the algorithm multiple times to check if it converges to a unique w.


%% ALGORITHM

currw=initw; % initialize w to equal weights for all dimensions
Get PShortest for currw
Get PViaFeedback for currw
Calculate divergence

PShortest*=Inf (initialize the shortest path from START to END that has FeedbackNodeSequence)

while divergence>tolerance
    
    Get direction of steepest descent (minimize divergence), u
    Get steplength along the direction u, s, such that you decrease the objective function
    Move in direction u from currw with steplength s. Define neww
    neww=currw+s*u

    Get PShortest for neww
    Get PViaFeedback for neww
    Calculate divergence

    currw=neww;
end;


%% SIMPLER VERSION OF THE ALGORITHM

Define divergence as binary:
Divergence=0 if PShortest has FeedbackNodeSequence in the required order
Divergence=1 if PShortest does not have at least node in FeedbackNodeSequence or
             the order of nodes in PShortest is not the same as in FeedbackNodeSequence

We will do a contrained minimization of PShortest, under the constraint that Divergence=0;
Minimize PShortest over w such that PShortest has the nodes in FeedbackNodeSequence
in the correct order.

This is the same as the previous objective function if there exists at least one w such that
PShortest=PViaFeedback. If no such w exists we will never get a solution with a binary Divergence.
The previous algorithm addresses that problem.





currw=initw; % initialize w to equal weights for all dimensions
Get PShortest for currw, PShortestcurr
Calculate divergence

relativeerror=Inf
PShortest*=Inf (initialize the shortest path from START to END that has FeedbackNodeSequence)
tolerance=epsilon

while divergence==1 || relativeerror>tolerance
    
    neww=Propose neww;  
         % independent proposal for neww
         % Propose new w by choosing a dimension at random and upweighting
         % or downweighting it at random and adjust other dimension weights 
         % such that the total weight is one. We choose a dimension of w 
         % corresponding to a term that is in one of the documents in in 
         % FeedbackNodeSequence.

    Get PShortest for neww, PShortestnew
    Calculate divergence
    Calculate relativeerror=(PShortestcurr-PShortestnew)/PShortestcurr
    PShortestcurr=PShortestnew
end;


%}
