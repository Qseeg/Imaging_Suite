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

% CheckPanelsOpen
% This function checks to see if any panels are open for other functions
% If they are open it prompts the user to save and close them before
% continuing;
%
% Returns ActivePanels = true, when 1 or more panels were identified. 
%                              Will prompt users to save and close those
%                              panels

function [ActivePanels] = CheckPanelsOpen()

    %Preallocation
    ActivePanels = false;

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Subject Submenu
    if(ishandle(MainMenu.UserData.SubjectMenuProperties.Handle))
        ActivePanels = true;
    end
    
    %VolumeAdjustment Submenu
    if(ishandle(MainMenu.UserData.VolumeAdjustmentMenuProperties.Handle))
        ActivePanels = true;
    end
    

    
    if(ActivePanels)
        %%%%%%%%%%%%%%%%%
        %Make a figure and display error message
        ErrorPanel(sprintf('A sub-menu panel is still active\nPlease save and close all \nsub-menu panels before continuing'));
        
    end
end
