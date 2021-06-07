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

% Conflict resolution for Coregistration

% A selection has been made that upsets a aligned volume.
% This function attempts to solve this problem

function [] = CoregistrationConflictResolution()

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; %
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    
    %Figure for message
    figure('Name','Coregistration Conflict','NumberTitle','off','units','normalized','InnerPosition',[0.4 0.4 0.2 0.2],'Color',[1 1 1],'MenuBar','none','Tag','CoregistrationConflict');
        
        %Message to be displayed mentioning the conflict
        STR = sprintf('Some Volumes are in alignment, or are the source\nfor alignment, editing these volumes will remove\nthe alignments. Volumes affected:\n');
        
        %Volumes in Alignment
        AlignmentConflict = intersect(MainMenu.UserData.AlignVolumeMenuProperties.uiAllVolumes.Value ,find(~strcmp([MainMenu.UserData.SubjectStructure.Volumes.InAlignment],'none')));  
        for V = AlignmentConflict
            STR = compose('%s%s (In alignment)\n',STR{1},MainMenu.UserData.SubjectStructure.Volumes(V).FileName);
        end

        %Volumes as source
        SourceConflict =  intersect(MainMenu.UserData.AlignVolumeMenuProperties.uiAllVolumes.Value ,find(~strcmp([MainMenu.UserData.SubjectStructure.Volumes.SourceAlignment],'none')));  
        for V = SourceConflict
            STR = compose('%s%s (As a source)\n',STR,MainMenu.UserData.SubjectStructure.Volumes(V).FileName);
        end
        STR = compose('%s\n\nRemove Source Alignment and proceed with the coregistration?',STR{1});

        
        %Display the text
        uicontrol('Style','text','units','normalized','Position', [0.2, 0.3, 0.6, 0.6], 'String', STR, 'BackgroundColor',[1 1 1]);
        
        %Resolve problem
        uicontrol('Style','Pushbutton','units','normalized','Position',[0.1 0.1 0.35 0.15],'String','Yes',...
                        'callback',@CoregistrationConflictCallback);
        
        %Keep problem
        uicontrol('Style','Pushbutton','units','normalized','Position',[0.55 0.1 0.35 0.15],'String','No',...
                                        'callback',sprintf('%s%s',...
                                        'F = findobj(''Tag'',''NewVOLUMEnameFigure'');',...
                                        'close(F)'));
                                    
        
        
end



%Callback function
function [] = CoregistrationConflictCallback(~,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; %
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%

   SelectedVolumes = MainMenu.UserData.AlignVolumeMenuProperties.uiAllVolumes.Value;
   
   
    %MainMenu.UserData.SubjectStructure.Volumes(
   
    for S = SelectedVolumes
        
        %Remove the Source field
        MainMenu.UserData.SubjectStructure.Volumes(S).SourceAlignment = {'none'}; 
        
        %Find all volumes which are in alignment 
        %Find Volumes that were inAlignment with the Conflicting source
        %strcmp(
    
    end
    
    


end
