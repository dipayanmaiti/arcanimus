function true=isalreadyinlist(t,EntityList)
true=0;
NumEntities=size(EntityList,2);
for i=1:NumEntities
    if strcmp(t,EntityList{i})
        true=1;
        break;
    end;
end;

return;