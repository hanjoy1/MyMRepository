%%
ax = gca;

%%
ax.FontName = 'Î¢ÈíÑÅºÚ';


%% Grid
set(ax,'yminorgrid','on');
set(ax,'xminorgrid','on');
set(ax,'ygrid','on');
set(ax,'xgrid','on');
% set(gca,'yminorgrid','off');
% set(gca,'xminorgrid','off');
% set(gca,'ygrid','off');
% set(gca,'xgrid','off');

%Íø¸ñÑÕÉ«
ax.GridColor = 'k';
%Íø¸ñÍ¸Ã÷¶È
ax.GridAlpha = 0.7; 
%Íø¸ñÏßÐÔ
ax.GridLineStyle='-';

ax.MinorGridColor = 'k';
ax.MinorGridAlpha = 0.4;
ax.MinorGridLineStyle = ':';

%% Label
set(ax.XLabel, 'FontSize', 14, 'FontName', 'Î¢ÈíÑÅºÚ')
set(ax.YLabel, 'FontSize', 14, 'FontName', 'Î¢ÈíÑÅºÚ')
