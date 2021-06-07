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

%RemoveVolume function for the subject submenu
%
% 

function [] = RemoveVolume(~,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; %
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Check that somethign is supposed to be removed
    if(isempty(MainMenu.UserData.SubjectMenuProperties.uiAllImages.Value))
        return;
    end
   
    %Create a Figure to ask where the user is keen to actually remove the files they have suggested
    figure('Name','REMOVE Volume','NumberTitle','off','units','normalized','InnerPosition',[0.4 0.4 0.2 0.2],'Color',[1 1 1],'MenuBar','none','Tag','removeVOLUMEFigure');
    STR = 'Are you sure you want to remove';
    for V = MainMenu.UserData.SubjectMenuProperties.uiAllImages.Value
       STR = compose('%s\n%s',STR,MainMenu.UserData.SubjectStructure.Volumes(V).FileName);
    end
    uicontrol('Style','text','units','normalized','Position',[0.1 0.3 0.8 0.6],'String',STR,'BackgroundColor',[1 1 1]);

    %Yes button
    uiYesButton = uicontrol('Style','Pushbutton','units','normalized','Position',[0.1 0.1 0.35 0.15],'String','Yes','Callback',@DoRemoveVolume);
    
    %No Button
    uiNoButton = uicontrol('Style','Pushbutton','units','normalized','Position',[0.55 0.1 0.35 0.15],'String','No',...
                           'callback',sprintf(  '%s%s',...
                                                'F = findobj(''Tag'',''removeVOLUMEFigure'');',...
                                                'close(F)')); 
end


function [] = DoRemoveVolume(~,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; %
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    
    %Find the RemoveFigure
    F = findobj('Tag','removeVOLUMEFigure');
    if(numel(F)~=1)
        ErrorPanel('Error removing, please try again');
        return;
    end
    
   
    %Find the Selection
    SelectedVolumes = MainMenu.UserData.SubjectMenuProperties.uiAllImages.Value;
    KeepVolumes = setdiff(1:size(MainMenu.UserData.SubjectStructure.Volumes,2),SelectedVolumes);
    
    %Remove thier existance from the Subject structure
    MainMenu.UserData.SubjectStructure.Volumes = MainMenu.UserData.SubjectStructure.Volumes(KeepVolumes);
    
    %Remove thier alignment properties from the alignment matrix
    MainMenu.UserData.SubjectStructure.AlignmentMatrix = MainMenu.UserData.SubjectStructure.AlignmentMatrix(:,KeepVolumes);
    MainMenu.UserData.SubjectStructure.AlignmentMatrix = MainMenu.UserData.SubjectStructure.AlignmentMatrix(KeepVolumes,:);
    
    %Close the figure
    if(ishandle(F))
        close(F);
    end
    
    %Remove the selection of the uiAllImages box
    MainMenu.UserData.SubjectMenuProperties.uiAllImages.Value = [];
    
    %Update the listing
    UpdateSubjectMenu();
    
    %Create a message
    MessagePanel('Volumes Removed',sprintf('The selected volumes have been\nremoved from this subject. The\nactual files however remain in the directory'));
    
    
end
