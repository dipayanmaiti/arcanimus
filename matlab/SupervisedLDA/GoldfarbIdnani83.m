


% Find unconstrained solution
x=-inv(G)*a;
f=0.5*a'*x;
H=inv(G);
A=[];  % sorted indices of the active set
q=0;


while TRUE  
    %% choose violated constrained if any
    
    s=C'*x-b; % compute s
    ViolatedIneqIndices=find(s<0); % find inequalities which have been violated
    IndicesNotInActiveSet=setdiff(K,A); % find inequalties which are not in active set
    V=setdiff(ViolatedIneqIndices,IndicesNotInActiveSet); % find violated inequalties not in active set
    
    if isempty(V)
        % current x is both feasible and optimal
        return;
    end;
    
    p=randsample(V,1);
    nPLUS=C(:,p);
    uPLUS=[u; 0];
    
    if q==0
        u=0;
        APLUS=sort([A p]);
    end;
    
    %% check for feasibility and determine a new S-pair
    
    % Determine step direction
    
    z=H*nPLUS; % step direction in the primal space
    if q>0
        r=NSTAR*nPLUS; % negative of the step direction in the dual space
    end;
    
    % Compute step length
    
    % 1) partial step-length t1 (maximum step in dual space without
    % violating dual feasibility)
    
    
    
    
end;
    
