function stress=CalcStress(DUnif,D,ImpactNodes)
L=length(ImpactNodes);
stress=0;
s=0;
for i=1:L
    for j=i+1:L
        stress=stress+(DUnif(ImpactNodes(i),ImpactNodes(j))-D(ImpactNodes(i),ImpactNodes(j)))^2;
        s=s+D(ImpactNodes(i),ImpactNodes(j))^2;
    end;
end;
stress=stress;
return;