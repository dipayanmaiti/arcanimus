function PlotNewVNode(V,Index,ArrowTailCoords,ArrowHeadCoords,FigNum)

figure(FigNum);
if V(Index).ClosedSet==1
    plot(ArrowHeadCoords(1),ArrowHeadCoords(2),'r.','Markersize',20);
    if ~isempty(ArrowTailCoords)
        ArrowCoords=[ArrowTailCoords; ArrowHeadCoords];
        line(ArrowCoords(:,1),ArrowCoords(:,2),'LineWidth',2,'Color','y','MarkerFaceColor','none');
        arrowh(ArrowCoords(:,1),ArrowCoords(:,2),'k');
    end;
elseif V(Index).OpenSet==1
    plot(ArrowHeadCoords(1),ArrowHeadCoords(2),'g.','Markersize',20);
    if ~isempty(ArrowTailCoords)
        ArrowCoords=[ArrowTailCoords; ArrowHeadCoords];
        line(ArrowCoords(:,1),ArrowCoords(:,2),'LineWidth',2,'Color','y','MarkerFaceColor','none');
        arrowh(ArrowCoords(:,1),ArrowCoords(:,2),'k');
    end;
end;

return;

