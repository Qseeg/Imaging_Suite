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

% ClosePanels
% This function checks to see if any panels are open 
% If they are open it close them
%
% 

function [] = ClosePanels()

   

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %SubjectSubmenu
    if(ishandle(MainMenu.UserData.SubjectMenuProperties.Handle))
        close(MainMenu.UserData.SubjectMenuProperties.Handle);
    end
    
    %AlignVolume SubSubmenu
    if(ishandle(MainMenu.UserData.VolumeAdjustmentMenuProperties.Handle))
        close(MainMenu.UserData.VolumeAdjustmentMenuProperties.Handle);
    end

end
