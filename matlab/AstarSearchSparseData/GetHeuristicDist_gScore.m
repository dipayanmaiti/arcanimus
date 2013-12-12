function HeuristicDist_gScore=...
    GetHeuristicDist_gScore(TermVector1,TermVector2,UnitVector,betag,s_RadialBasisObj,TermWt,option)

% This function calculates the heuristic distance from TermVector1 to
% TermVector2 along the direction given by UnitVector. Distance estimates
% along a small distance is based on gScore

radxy=s_RadialBasisObj.radxy;
s=s_RadialBasisObj.s;
nrad=s_RadialBasisObj.nrad;

epsilon=0.0001;
StepSize=0.0001;
CurrStep=TermVector1;
NextStep=CurrStep+StepSize*UnitVector;

DVector1=zeros(1,nrad); % Design Vector based on Radial Basis functions
for i=1:nrad
    mu=radxy(i,:);
    z=sum((CurrStep-mu).*(CurrStep-mu).*sqrt(TermWt));
    DVector1(i)=1/(sqrt(2*pi*s))*exp(-0.5/s*sum(z));
end;
DVector1=[1 DVector1];

DVector2=zeros(1,nrad); % Design Vector based on Basis functions
for i=1:nrad
    mu=radxy(i,:);
    z=sum((NextStep-mu).*(NextStep-mu).*sqrt(TermWt));
    DVector2(i)=1/(sqrt(2*pi*s))*exp(-0.5/s*sum(z));
end;
DVector2=[1 DVector2];

HeuristicDist_gScore=abs(DVector1*betag-DVector2*betag);

while GetDistance(NextStep,TermVector2,TermWt,option)>epsilon
    
    CurrStep=NextStep;
    NextStep=CurrStep+StepSize*UnitVector;
    
    DVector1=zeros(1,nrad); % Design Vector based on Radial Basis functions
    for i=1:nrad
        mu=radxy(i,:);
        z=sum((CurrStep-mu).*(CurrStep-mu).*sqrt(TermWt));
        DVector1(i)=1/(sqrt(2*pi*s))*exp(-0.5/s*sum(z));
    end;
    DVector1=[1 DVector1];
    
    DVector2=zeros(1,nrad); % Design Vector based on Basis functions
    for i=1:nrad
        mu=radxy(i,:);
        z=sum((NextStep-mu).*(NextStep-mu).*sqrt(TermWt));
        DVector2(i)=1/(sqrt(2*pi*s))*exp(-0.5/s*sum(z));
    end;
    DVector2=[1 DVector2];
    
    HeuristicDist_gScore=HeuristicDist_gScore+...
        abs(DVector1*betag-DVector2*betag);
end;
return;