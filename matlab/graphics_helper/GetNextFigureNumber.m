function NextFigure=GetNextFigureNumber()

handles= findobj('type','figure');
if size(handles,1)==0
    NextFigure=1;
else
    NextFigure=handles(1)+1;
end;

return;