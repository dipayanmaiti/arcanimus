function fignum=DisplayMDSWithoutGraph(MDScoords,Adj,ObsTagList,N)

% Visualize the MDScoords in 2-D, also tag each observation in 2-D using
% ObsTagList
% return figure handle

fignum=GetNextFigureNumber();
figure(fignum);
plot(MDScoords(:,1),MDScoords(:,2),'.'); hold on;

% text tag data points
figure(fignum);
TextOptions={};
for i = 1:N  
        text('Position', [MDScoords(i,1)+normrnd(0,0.0001),...
            MDScoords(i,2)+normrnd(0,0.0001)], ...
            'String', ObsTagList{i}, ...
            'HorizontalAlignment','right', ...
            'VerticalAlignment','top', ...
            'FontSize',12,...
            TextOptions{:});
end
hold off;

return;