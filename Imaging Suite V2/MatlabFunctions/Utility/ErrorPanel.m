% Copyright 2020 QIMR Berghofer Medical Research Institute
% Author: Matthew Woolfe
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.

% Error Panel
% Input: Text for display
%

function [] = ErrorPanel(Input)

        %%%%%%%%%%%%%%%%%
        %Make a figure and display error message
        figure('Name','Error','NumberTitle','off','units','normalized','InnerPosition',[0.4 0.4 0.2 0.2],'Color',[1 1 1],'MenuBar','none');
        axes('Units','Normalized','Position',[0 0 1 1],'Visible','off','XLim',[-1 1],'YLim',[-1 1]);
        text(0, 0, Input,'HorizontalAlignment','center');
        
end
