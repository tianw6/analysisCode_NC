function TextLabels =  getTextLabel(hTick, textLabels, tickColors)
% TextLabels =  getTextLabel(hTick, textLabels, tickColors)
% Returns a text label structure which is in turn passed to the fancy axes
% that Mark wrote.
% 
% see also plotAxes


% hTick:  vector, specify the location of marks
% textLabels: cell, specify the text of the marks on each hTick
% tickColors: cell, specify the color of the marks on each hTick
TextLabels.hTick = hTick;
TextLabels.textLabel = textLabels;
TextLabels.tickColor = tickColors;
