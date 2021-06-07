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

% Subject details Panel

function [] = SubjectMenu(~,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Check for active submenus      %
    ActivePanels = CheckPanelsOpen();%
    if(ActivePanels)                 %
        return;                      %
    end                              %   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    
    
    %SubjectDetailsButtons
    SubjectMenuProperties = MainMenu.UserData.SubjectMenuProperties;
    Visibility = false; if(~isempty(MainMenu.UserData.SubjectStructure.ID)); Visibility = true;end

    
    %%%%%%%%%%%%%%%%%%%%%%%%
    % Make the Subject Panel
    SubjectFigure = figure('Name',MainMenu.UserData.SubjectMenuProperties.Name,'units',MainMenu.UserData.SubjectMenuProperties.Units,'InnerPosition',MainMenu.UserData.SubjectMenuProperties.Position,'Tag',MainMenu.UserData.SubjectMenuProperties.Tag,'MenuBar','none','NumberTitle','off','Color',MainMenu.UserData.SubjectMenuProperties.Colour);        
    SubjectMenuProperties.Handle = SubjectFigure;
    
        %%%%%%%%%%%%%%%%%%%%%
        % Create the Buttons
        %NewSubject
        Button = 1;
        uiNewSubjectButton = uicontrol('Style','pushbutton','units',SubjectMenuProperties.Units,'OuterPosition',SubjectMenuProperties.ButtonPosition(Button,:),'String','New Subject','Tag','NewSubjectButton','CallBack',@NewSubject); 
        
        %LoadSubject
        Button = Button + 1;
        uiLoadSubjectButton = uicontrol('Style','pushbutton','units',SubjectMenuProperties.Units,'OuterPosition',SubjectMenuProperties.ButtonPosition(Button,:),'String','Load Subject','Tag','LoadSubjectButton','CallBack',@LoadSubject); 
        
        %SaveSubject
        Button = Button + 1;
        uiSaveSubjectButton = uicontrol('Style','pushbutton','units',SubjectMenuProperties.Units,'OuterPosition',SubjectMenuProperties.ButtonPosition(Button,:),'String','Save Subject','Tag','SaveSubjectButton','Visible',Visibility,'CallBack',@SaveSubject);     
        
        %ImportDICOM
        Button = Button + 1;
        uiImportDICOMButton = uicontrol('Style','pushbutton','units',SubjectMenuProperties.Units,'OuterPosition',SubjectMenuProperties.ButtonPosition(Button,:),'String','Import DICOM','Tag','ImportDICOMButton','Visible',Visibility,'CallBack',@ImportDICOM); 
        
        %ImportVolume
        Button = Button + 1;
        uiImportVolumeButton = uicontrol('Style','pushbutton','units',SubjectMenuProperties.Units,'OuterPosition',SubjectMenuProperties.ButtonPosition(Button,:),'String','Import Volume','Tag','ImportVolumeButton','Visible',Visibility,'CallBack',@ImportVolume); 
        
        %RemoveVolume
        Button = Button + 1;
        uiRemoveVolumeButton = uicontrol('Style','pushbutton','units',SubjectMenuProperties.Units,'OuterPosition',SubjectMenuProperties.ButtonPosition(Button,:),'String','Remove Volume','Tag','RemoveVolumeButton','Visible',Visibility,'CallBack',@RemoveVolume); 
        
    
        %%%%%%%%%%%%%%%%%%%%%%
        % Organise data for input boxes
        SubjectID = 'P 001';if(~isempty(MainMenu.UserData.SubjectStructure.ID));SubjectID = MainMenu.UserData.SubjectStructure.ID;else;MainMenu.UserData.SubjectStructure.ID = SubjectID;end
        SubjectDIR = '';    if(~isempty(MainMenu.UserData.SubjectStructure.DIR));SubjectDIR = MainMenu.UserData.SubjectStructure.DIR;else;MainMenu.UserData.SubjectStructure.DIR = SubjectDIR;end
        AllImages = {''};
        
        
        %%%%%%%%%%%%%%%%%%%%%%%
        % Create the InputBoxes
        
        %Subject ID
        uiSubjectIDText = uicontrol('Style','text','units','pixel','position',[SubjectMenuProperties.XOffset, SubjectMenuProperties.Height - SubjectMenuProperties.Clearence - SubjectMenuProperties.HeadingTextBoxHeight, SubjectMenuProperties.Width-SubjectMenuProperties.Clearence-SubjectMenuProperties.Clearence, SubjectMenuProperties.HeadingTextBoxHeight],'String','Subject ID:','BackgroundColor',SubjectMenuProperties.Colour,'FontSize',SubjectMenuProperties.HeadingTextSize,'HorizontalAlignment','Left'); 
        uiSubjectID = uicontrol('Style','edit','Units','pixel','position',    [SubjectMenuProperties.XOffset, SubjectMenuProperties.Height - SubjectMenuProperties.Clearence - SubjectMenuProperties.HeadingTextBoxHeight - SubjectMenuProperties.TextBoxHeight, SubjectMenuProperties.Width-SubjectMenuProperties.Clearence-SubjectMenuProperties.Clearence, SubjectMenuProperties.TextBoxHeight],'String',SubjectID,'Tag','SubjectID','BackgroundColor',SubjectMenuProperties.Colour,'HorizontalAlignment','Left','CallBack',@ChangeSubjectID); 
        
        %SaveDIR
        uiSubjectDIRText = uicontrol('Style','text','units','pixel','position',[SubjectMenuProperties.XOffset, SubjectMenuProperties.Height - SubjectMenuProperties.Clearence - SubjectMenuProperties.TextBoxHeight - 2*SubjectMenuProperties.HeadingTextBoxHeight, SubjectMenuProperties.Width-SubjectMenuProperties.Clearence-SubjectMenuProperties.Clearence, SubjectMenuProperties.HeadingTextBoxHeight],'String','Subject Folder:','BackgroundColor',SubjectMenuProperties.Colour,'FontSize',SubjectMenuProperties.HeadingTextSize,'HorizontalAlignment','Left'); 
        uiSubjectDIR = uicontrol('Style','edit','Units','pixel','position',    [SubjectMenuProperties.XOffset, SubjectMenuProperties.Height - SubjectMenuProperties.Clearence - 2*SubjectMenuProperties.HeadingTextBoxHeight - 2*SubjectMenuProperties.TextBoxHeight, SubjectMenuProperties.Width-SubjectMenuProperties.Clearence-SubjectMenuProperties.Clearence, SubjectMenuProperties.TextBoxHeight],'String',SubjectDIR,'Tag','SubjectDIR','BackgroundColor',SubjectMenuProperties.Colour,'HorizontalAlignment','Left'); 
        
        %All Images
        uiAllImagesText = uicontrol('Style','text','units','pixel','position',[SubjectMenuProperties.XOffset, SubjectMenuProperties.Height - SubjectMenuProperties.Clearence - 2*SubjectMenuProperties.TextBoxHeight - 3*SubjectMenuProperties.HeadingTextBoxHeight, SubjectMenuProperties.Width-SubjectMenuProperties.Clearence-SubjectMenuProperties.Clearence, SubjectMenuProperties.HeadingTextBoxHeight],'String','Images for Subject:','BackgroundColor',SubjectMenuProperties.Colour,'FontSize',SubjectMenuProperties.HeadingTextSize,'HorizontalAlignment','Left'); 
        uiAllImages = uicontrol('Style','List','Units','pixel','position',    [SubjectMenuProperties.XOffset, SubjectMenuProperties.Height - SubjectMenuProperties.Clearence - 4*SubjectMenuProperties.HeadingTextBoxHeight - 5*SubjectMenuProperties.TextBoxHeight, SubjectMenuProperties.Width-SubjectMenuProperties.Clearence-SubjectMenuProperties.Clearence, 4*SubjectMenuProperties.TextBoxHeight],'String',AllImages,'Value',[],'Max',2,'Tag','AllImages','BackgroundColor',SubjectMenuProperties.Colour,'HorizontalAlignment','Left'); 
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%
        % Put some HELP messages
        uiHELPMessage = uicontrol('Style','text','units','pixel','position', [SubjectMenuProperties.XOffset, SubjectMenuProperties.Height - SubjectMenuProperties.Clearence - 8*SubjectMenuProperties.HeadingTextBoxHeight - 9*SubjectMenuProperties.TextBoxHeight, SubjectMenuProperties.Width-SubjectMenuProperties.Clearence-SubjectMenuProperties.Clearence, 6*SubjectMenuProperties.TextBoxHeight],'String',sprintf('New Subject: This will create a new folder for subject given in "subject ID"\nLoad Subject: This loads a previously create subject'),'BackgroundColor',SubjectMenuProperties.Colour,'FontSize',SubjectMenuProperties.TextSize,'HorizontalAlignment','Left'); 
        
        SubjectMenuProperties.uiNewSubjectButton = uiNewSubjectButton;
        SubjectMenuProperties.uiLoadSubjectButton = uiLoadSubjectButton;
        SubjectMenuProperties.uiSaveSubjectButton = uiSaveSubjectButton;
        SubjectMenuProperties.uiImportDICOMButton = uiImportDICOMButton;
        SubjectMenuProperties.uiImportVolumeButton = uiImportVolumeButton;
        SubjectMenuProperties.uiRemoveVolumeButton = uiRemoveVolumeButton;
        SubjectMenuProperties.uiSubjectID = uiSubjectID;
        SubjectMenuProperties.uiSubjectDIR = uiSubjectDIR;
        SubjectMenuProperties.uiAllImages = uiAllImages;
        SubjectMenuProperties.uiHELPMessage = uiHELPMessage;

        
        %Upload the details
        MainMenu.UserData.SubjectMenuProperties = SubjectMenuProperties;
        
        %Update Help information
        UpdateSubjectMenu();
end



function [] = ChangeSubjectID(~,~)

        %Change the known SubjectID in the SubjectStructure

        %%%%%%%%%%%%%%%%%%%%%%%%%%
        % Find the MainMenu      %
        MainMenu = FindMainMenu; %
        if(isempty(MainMenu))    %
            QuitFunction();      %
            return;              %
        end                      %
        %%%%%%%%%%%%%%%%%%%%%%%%%%
    
        %Save the data to the subjectstructure
        MainMenu.UserData.SubjectStructure.ID = MainMenu.UserData.SubjectMenuProperties.uiSubjectID.String;
        UpdateSubjectMenu();
            
end

function [] = NewSubject(~,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    %Make a new Directory
    [NewPath] = uigetdir('','Select folder for the new subject');
    
    %Check if they cancelled
    if(isnumeric(NewPath))
        return;
    end
    
    %Append the SubjectID
    NewPath = fullfile(NewPath,MainMenu.UserData.SubjectMenuProperties.uiSubjectID.String);
    
    %Check if the folder already exists
    if(exist(NewPath,'dir'))
        ErrorPanel(sprintf('A directory with the same name already exists\nCancelling new Folder creation'));
        return;
    end
    
    %Make a new directory with the SubjectID in the submenu
    mkdir(NewPath);
    
    %Clean held information
    %Keeping just the Patient ID and DIR
    MainMenu.UserData.SubjectStructure = struct('ID',MainMenu.UserData.SubjectMenuProperties.uiSubjectID.String,...
                            'DIR',NewPath,...
                            'Volumes',struct(   'FileAddress','',...
                                                'FileName','',...
                                                'Type','',...
                                                'Space','',...
                                                'SurfaceAddress','',...
                                                'ROIs',struct(  'Label','',...
                                                                'XYZ',[]),...
                                                'ACSelected',false),...
                            'AlignmentMatrix',[]);

    UpdateSubjectMenu();
    
end

function [] = LoadSubject(~,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    %Find the SubjectDir
    [SubjectPath] = uigetdir('','Select the subjects directory');
    
    %Check if they cancelled
    if(isnumeric(SubjectPath))
        return;
    end
    
    %Append the File nae to be loaded
    SubjectStructurePath = fullfile(SubjectPath,'SubjectStructure.mat');
    
    %Check that the file exists
    if(~exist(SubjectStructurePath,'file'))
        ErrorPanel('Cannot find the subject details');
        return;
    end
    
    %Begin Loading the details from the directory
    SubjectStructure = load(SubjectStructurePath,'SubjectStructure');
    MainMenu.UserData.SubjectStructure = SubjectStructure.SubjectStructure;
    UpdateSubjectMenu();
    
end

