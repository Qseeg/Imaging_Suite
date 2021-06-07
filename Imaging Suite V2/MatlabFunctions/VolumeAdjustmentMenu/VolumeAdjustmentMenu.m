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

% VolumeAdjustment function
% Opens a new submenu
% The new submenu allows the reorientation (automatic and manual) then
% options to have each image coregistered to any other image.



function [] = VolumeAdjustmentMenu(~,~)


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
    
    %Check if there are any volumes to actually align
    if(isempty(MainMenu.UserData.SubjectStructure.Volumes(1).FileAddress))
        ErrorPanel('No Volumes loaded');
        return;
    end
    
    
    %Collect the structures
    SubjectStructure = MainMenu.UserData.SubjectStructure;
    VolumeAdjustmentMenuProperties = MainMenu.UserData.VolumeAdjustmentMenuProperties;

    
    %%%%%%%%%%%%%%%%%%%%%%%%
    % Make the Alignment Panel
    VolumeAdjustmentFigure = figure('Name',        MainMenu.UserData.VolumeAdjustmentMenuProperties.Name,...
                                    'units',        MainMenu.UserData.VolumeAdjustmentMenuProperties.Units,...
                                    'InnerPosition',MainMenu.UserData.VolumeAdjustmentMenuProperties.Position,...
                                    'Tag',          MainMenu.UserData.VolumeAdjustmentMenuProperties.Tag,...
                                    'Color',        MainMenu.UserData.VolumeAdjustmentMenuProperties.Colour,...
                                    'MenuBar','none','NumberTitle','off');     
    VolumeAdjustmentMenuProperties.Handle = VolumeAdjustmentFigure;                    
    
        
        
        %%%%%%%%%%%%%
        % Data Display
        %List Box for all the known volumes
        Button = 1;
        uiAllVolumesText = uicontrol('Style','text','units','pixel','position',[VolumeAdjustmentMenuProperties.XOffset, VolumeAdjustmentMenuProperties.ButtonPosition(Button,2), VolumeAdjustmentMenuProperties.Width-2*VolumeAdjustmentMenuProperties.Clearence, VolumeAdjustmentMenuProperties.HeadingTextBoxHeight],'String','Volumes:','BackgroundColor',VolumeAdjustmentMenuProperties.Colour,'FontSize',VolumeAdjustmentMenuProperties.HeadingTextSize,'HorizontalAlignment','Left');
        Button = 3;
        uiAllVolumes = uicontrol('Style','List','Units','pixel','position',    [VolumeAdjustmentMenuProperties.XOffset, VolumeAdjustmentMenuProperties.ButtonPosition(Button,2), VolumeAdjustmentMenuProperties.Width-2*VolumeAdjustmentMenuProperties.Clearence, 2*(VolumeAdjustmentMenuProperties.ButtonHeight+VolumeAdjustmentMenuProperties.ButtonClearence)],'String',{''},'Value',[],'Max',100,'Tag','AllImages','BackgroundColor',VolumeAdjustmentMenuProperties.Colour,'HorizontalAlignment','Left','CallBack',@VolumeSelection_AlignSubmenu); 
        
        %List Box for all the known volumes
        Button = 5;
        uiCoregVolumePopUpText = uicontrol('Style','text','units','pixel','position',[VolumeAdjustmentMenuProperties.XOffset, VolumeAdjustmentMenuProperties.ButtonPosition(Button,2), VolumeAdjustmentMenuProperties.Width-2*VolumeAdjustmentMenuProperties.Clearence, VolumeAdjustmentMenuProperties.HeadingTextBoxHeight],'String','Coregister volumes to:','BackgroundColor',VolumeAdjustmentMenuProperties.Colour,'FontSize',VolumeAdjustmentMenuProperties.HeadingTextSize,'HorizontalAlignment','Left','Visible',false); 
        Button = 6;
        uiCoregVolumePopUp = uicontrol('Style','popupmenu','Units','pixel','position',   [VolumeAdjustmentMenuProperties.XOffset, VolumeAdjustmentMenuProperties.ButtonPosition(Button,2), VolumeAdjustmentMenuProperties.Width-2*VolumeAdjustmentMenuProperties.Clearence, VolumeAdjustmentMenuProperties.ButtonHeight+VolumeAdjustmentMenuProperties.ButtonClearence],'String',horzcat(strcat('(',{MainMenu.UserData.SubjectStructure.Volumes.FileName},{')   '} ,{MainMenu.UserData.SubjectStructure.Volumes.Type}),{' '}),'Value',size(MainMenu.UserData.SubjectStructure.Volumes,2)+1,'Tag','CoregVolumePopUp','Visible',false,'CallBack',@CoregisterVolumes); 
        
       
        %%%%%%%%%%
        % UI Control Buttons
        
        %Automatic Registration Button
        Button = 1;
        uiAutomaticACSelectionButton = uicontrol('Style','pushbutton','units',VolumeAdjustmentMenuProperties.Units,'OuterPosition',VolumeAdjustmentMenuProperties.ButtonPosition(Button,:),'String','<html>Automatically<br>Select AC','Tag','AutomaticACSelectionButton','Visible',false,'CallBack',@AutomaticACSelection); 
        
        %Manual Registration Button
        Button = 2;
        uiManualACSelectionButton = uicontrol('Style','pushbutton','units',VolumeAdjustmentMenuProperties.Units,'OuterPosition',VolumeAdjustmentMenuProperties.ButtonPosition(Button,:),'String','<html>Manual<br>AC Selection','Tag','ManualACSelectionButton','Visible',false,'CallBack',@ManualACSelection); 
        
        %Save Button
        Button = 3;
        uiSaveSubjectButton = uicontrol('Style','pushbutton','units',VolumeAdjustmentMenuProperties.Units,'OuterPosition',VolumeAdjustmentMenuProperties.ButtonPosition(Button,:),'String','<html>Save<br>Changes','Tag','SaveSubjectButton','Visible',false,'CallBack',@SaveSubject); 
        
        %Remove Alignment
        Button = 5;
        uiRemoveAlignmentButton = uicontrol('Style','pushbutton','units',VolumeAdjustmentMenuProperties.Units,'OuterPosition',VolumeAdjustmentMenuProperties.ButtonPosition(Button,:),'String','<html>Remove<br>Alignment','Tag','RemoveAlignmentButton','Visible',false,'CallBack',@RemoveAlignment); 
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        % Place some helper text
        Button = 7;
        uiHelperText = uicontrol('Style','text','units','pixel','position',[VolumeAdjustmentMenuProperties.XOffset, VolumeAdjustmentMenuProperties.ButtonPosition(Button,2)-8*VolumeAdjustmentMenuProperties.HeadingTextBoxHeight, VolumeAdjustmentMenuProperties.Width-2*VolumeAdjustmentMenuProperties.Clearence, 8*VolumeAdjustmentMenuProperties.HeadingTextBoxHeight],'String',sprintf('Select a Volume to begin alignment'),'BackgroundColor',VolumeAdjustmentMenuProperties.Colour,'FontSize',VolumeAdjustmentMenuProperties.TextSize,'HorizontalAlignment','Left');
        
        
        %Place these buttons on the Menu
        MainMenu.UserData.VolumeAdjustmentMenuProperties =                               VolumeAdjustmentMenuProperties;
        MainMenu.UserData.VolumeAdjustmentMenuProperties.uiAllVolumes =                  uiAllVolumes;
        MainMenu.UserData.VolumeAdjustmentMenuProperties.uiAutomaticACSelectionButton =  uiAutomaticACSelectionButton;
        MainMenu.UserData.VolumeAdjustmentMenuProperties.uiManualACSelectionButton =     uiManualACSelectionButton;
        MainMenu.UserData.VolumeAdjustmentMenuProperties.uiCoregVolumePopUpText =        uiCoregVolumePopUpText;
        MainMenu.UserData.VolumeAdjustmentMenuProperties.uiCoregVolumePopUp =            uiCoregVolumePopUp;
        MainMenu.UserData.VolumeAdjustmentMenuProperties.uiSaveSubjectButton =           uiSaveSubjectButton;
        MainMenu.UserData.VolumeAdjustmentMenuProperties.uiRemoveAlignmentButton =       uiRemoveAlignmentButton;
        MainMenu.UserData.VolumeAdjustmentMenuProperties.uiHelperText =                  uiHelperText;
        
        %Update The known information
        UpdateAlignSubmenu();
end


function [] = RemoveAlignment(~,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; %
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    %Check that something is selected
    SelectedVolumes = MainMenu.UserData.VolumeAdjustmentMenuProperties.uiAllVolumes.Value;
    if(isempty(SelectedVolumes))
        return;
    end
    
    %Get the Alignment Matrix
    AMat = logical(MainMenu.UserData.SubjectStructure.AlignmentMatrix);
        
    %Remove the selected Alignments
    MF = MessagePanel('Removing Alignments',sprintf('This removes the known alignments but does not\nphysically adjust the volumes'));
    for V = SelectedVolumes
        
        %Remove the Source->Alignment Link
        MainMenu.UserData.SubjectStructure.AlignmentMatrix(AMat(:,V),V) = false;
        
        %Remove the Alignment->Source Link
        MainMenu.UserData.SubjectStructure.AlignmentMatrix(V,AMat(V,:)) = false;

    end
    
    UpdateAlignSubmenu();
end


%update the list box in alignment menu
function [] = UpdateAlignSubmenu()

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; %
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %Update based on the Alignment Matrix
    AMat = logical(MainMenu.UserData.SubjectStructure.AlignmentMatrix);
        
    %Update the Alignment Volume List
    MaxTypeSpace = max(arrayfun(@(x) length(x.Type),MainMenu.UserData.SubjectStructure.Volumes)) + 3;
    MaxNameSpace = max(arrayfun(@(x) length(x.FileName),MainMenu.UserData.SubjectStructure.Volumes)) + 3;
    for V = 1:size(MainMenu.UserData.SubjectStructure.Volumes,2)

            if(any(AMat(:,V)))
                InAlignment = strjoin({MainMenu.UserData.SubjectStructure.Volumes(AMat(:,V)).FileName},', ');
            else
                InAlignment = 'none';
            end
            
            if(any(AMat(V,:)))
                SourceAlignment = strjoin({MainMenu.UserData.SubjectStructure.Volumes(AMat(V,:)).FileName},', ');
            else
                SourceAlignment = 'none';
            end

        
        MainMenu.UserData.VolumeAdjustmentMenuProperties.uiAllVolumes.String{V} = ...
            sprintf('(%s)%s%s%s In alignment with: %s    Alignment source for: %s',...
            MainMenu.UserData.SubjectStructure.Volumes(V).Type,...
            repmat(' ',1,MaxTypeSpace - length(MainMenu.UserData.SubjectStructure.Volumes(V).Type)),...
            MainMenu.UserData.SubjectStructure.Volumes(V).FileName,...
            repmat(' ',1,MaxNameSpace - length(MainMenu.UserData.SubjectStructure.Volumes(V).FileName)),...
            InAlignment,...
            SourceAlignment);
        
        
    end
end


function [] = VolumeSelection_AlignSubmenu(~,~)

    %Function that is a callback from the Alignment subsub menu
    %A selection has been made. 
    %The available buttons need to be made visible
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; %
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if(isempty(MainMenu.UserData.VolumeAdjustmentMenuProperties.uiAllVolumes.Value))
        MainMenu.UserData.VolumeAdjustmentMenuProperties.uiAutomaticACSelectionButton.Visible = false;
        MainMenu.UserData.VolumeAdjustmentMenuProperties.uiManualACSelectionButton.Visible = false;
        MainMenu.UserData.VolumeAdjustmentMenuProperties.uiCoregVolumePopUpText.Visible = false;
        MainMenu.UserData.VolumeAdjustmentMenuProperties.uiCoregVolumePopUp.Visible = false;
        MainMenu.UserData.VolumeAdjustmentMenuProperties.uiSaveSubjectButton.Visible = false;
        MainMenu.UserData.VolumeAdjustmentMenuProperties.uiRemoveAlignmentButton.Visible = false;
        MainMenu.UserData.VolumeAdjustmentMenuProperties.uiHelperText.String = sprintf('Select a Volume to begin alignment');
    else
        MainMenu.UserData.VolumeAdjustmentMenuProperties.uiAutomaticACSelectionButton.Visible = true;
        MainMenu.UserData.VolumeAdjustmentMenuProperties.uiManualACSelectionButton.Visible = true;
        MainMenu.UserData.VolumeAdjustmentMenuProperties.uiCoregVolumePopUpText.Visible = true;
        MainMenu.UserData.VolumeAdjustmentMenuProperties.uiCoregVolumePopUp.Visible = true;
        MainMenu.UserData.VolumeAdjustmentMenuProperties.uiSaveSubjectButton.Visible = true;
        MainMenu.UserData.VolumeAdjustmentMenuProperties.uiRemoveAlignmentButton.Visible = true;
        MainMenu.UserData.VolumeAdjustmentMenuProperties.uiHelperText.String = sprintf('Automatically Select AC: For the selected volumes (MRI only) this automatically identifies the Anterior Commissure\n\nManually Select AC: This provides and interface to select the AC for selected volumes\nSave Changes: Stores to the alignment of volumes to file\nRemove Alignment: This removes alignment properties from the selected volumes\nCoregister volumes: This reslices the selected volumes to match the dropdown volume (AC''s must be sleceted for each volume)');
    end
end


%Automatic selection of the AC
function [] = AutomaticACSelection(~,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; %
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    
    %Work out which images are going to be automatically reoriented
    SelectedFiles = MainMenu.UserData.VolumeAdjustmentMenuProperties.uiAllVolumes.Value;
    
    %Check that all the files are availble
    for F = SelectedFiles
        if(~exist(MainMenu.UserData.SubjectStructure.Volumes(F).FileAddress,'file'))
            ErrorPanel('One or more selected files cannot be found');
            return;
        end
    end
    
    MF = MessagePanel('Processing',sprintf('Automatic selection of the AC may\nTake some time. Please wait'));
    drawnow();
    
    %Set some SPM variable
    spmDir=which('spm');
    spmDir=spmDir(1:end-5);
    tmpl=fullfile(spmDir, 'canonical','avg152T1.nii');%A average of 152 T1 MRIs
    flags.regtype='rigid';
    
    %A functino burried in SPM
    addpath(fullfile(spmDir,'toolbox','OldNorm'));
    
    %Load Template MRI
    TemplateVolume=spm_vol(tmpl);
    
    
    
    %Begin the automatic orientation process
    for F = SelectedFiles

        %Load File for reorientation
        FilePath = strtrim(strcat(MainMenu.UserData.SubjectStructure.Volumes(F).FileAddress,',1')); %1 to indicate the position in SPM's volume structure
        
        % Make a smoothed version of the input volume to make it quick and better
        spm_smooth(FilePath,fullfile(MainMenu.UserData.SubjectStructure.DIR,'SmoothedTemplate.nii'),[12 12 12]);
        SmoothedVolume=spm_vol(fullfile(MainMenu.UserData.SubjectStructure.DIR,'SmoothedTemplate.nii'));
        %Prepare Transforms
        [M,~] = spm_affreg(TemplateVolume,SmoothedVolume,flags);
        M3=M(1:3,1:3);
        [u, ~, v]=svd(M3);
        M3=u*v';
        M(1:3,1:3)=M3;

        %Create Nifti structure with updated origin
        N=nifti(FilePath);
        N.mat=M*N.mat;

        %Save the data
        create(N);

        %Remove the smoothed version
        if(exist(fullfile(MainMenu.UserData.SubjectStructure.DIR,'SmoothedTemplate.nii'),'file'))
            delete(fullfile(MainMenu.UserData.SubjectStructure.DIR,'SmoothedTemplate.nii'));
        end
        
        %Update the knowledge of the AC selection
        MainMenu.UserData.SubjectStructure.Volumes(F).ACSelected = true;
    end
    
    %Idicate that the files have now been oriented
    if(ishandle(MF))
        close(MF);
    end
    MessagePanel('Success','AC automatically selected');
    
end
    

%Manual AC Selection
function [] = ManualACSelection(~,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; %
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    %Work out which images are going to be Manually reoriented
    SelectedFiles = MainMenu.UserData.VolumeAdjustmentMenuProperties.uiAllVolumes.Value;
    
    if(length(SelectedFiles)~=1)
        
        ErrorPanel('Only one file at a time for manual selection of the AC');
        return;
    end
    
    %Check that all the files are availble
    for F = SelectedFiles
        if(~exist(MainMenu.UserData.SubjectStructure.Volumes(F).FileAddress,'file'))
            ErrorPanel('One or more selected files cannot be found');
            return;
        end
    end
    
    %Begin the automatic orientation process
    for F = SelectedFiles
        
        %Display the image
        spm_image('init',MainMenu.UserData.SubjectStructure.Volumes(F).FileAddress);
        
        %Move Origin to [0,0,0]
        % spm_orthviews('Reposition',[x,y,z])
        spm_orthviews('Reposition',[0 0 0])
        
        %Tell the people what they have to do
        MessagePanel('Select AC',sprintf('Please do the following:\n\n1) Select the AC onscreen\n2) Click ''Set Origin''\n3) Click ''Reorient''\n4) Click done on the selection box (it is pre-filled)\n\nThis will save the AC point selected\nThere is no need to save the reorientation matrix\nClose the AC Selection window whwn complete'));
    

    end
    
    
    %Update the knowledge of the AC selection
    MainMenu.UserData.SubjectStructure.Volumes(F).ACSelected = true;
    
end




%Coregistration function   
function [] = CoregisterVolumes(~,~)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; %
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    %Check that the blank choice wasnt selected
    CoregSelected = MainMenu.UserData.VolumeAdjustmentMenuProperties.uiCoregVolumePopUp.Value;
    if(isempty(MainMenu.UserData.VolumeAdjustmentMenuProperties.uiCoregVolumePopUp.String{CoregSelected}))
        %The blank (Null) option was selected
        MainMenu.UserData.VolumeAdjustmentMenuProperties.uiCoregVolumePopUp.Value = size(MainMenu.UserData.VolumeAdjustmentMenuProperties.uiCoregVolumePopUp.String,2);
        return;
    end
    
    
    %Double check the impossible
    SelectedVolumes = MainMenu.UserData.VolumeAdjustmentMenuProperties.uiAllVolumes.Value;
    if(isempty(SelectedVolumes))
        MainMenu.UserData.VolumeAdjustmentMenuProperties.uiCoregVolumePopUp.Value = size(MainMenu.UserData.VolumeAdjustmentMenuProperties.uiCoregVolumePopUp.String,1);
        return;
    end
    
    %Check if the selected volumes match the coregistervolume
    if(any(SelectedVolumes == CoregSelected))
        MessagePanel('Warning',sprintf('Cannot register an image to itself\nRemoving selection'));
        MainMenu.UserData.VolumeAdjustmentMenuProperties.uiAllVolumes.Value = setdiff(MainMenu.UserData.VolumeAdjustmentMenuProperties.uiAllVolumes.Value,MainMenu.UserData.VolumeAdjustmentMenuProperties.uiCoregVolumePopUp.Value );
        
    end
    
    %Remove the CoregVolume from the SelectedVolumes 
    SelectedVolumes = setdiff(SelectedVolumes,CoregSelected);
    if(isempty(SelectedVolumes))
        MainMenu.UserData.VolumeAdjustmentMenuProperties.uiCoregVolumePopUp.Value = size(MainMenu.UserData.VolumeAdjustmentMenuProperties.uiCoregVolumePopUp.String,1);
        return;
    end  
    
    %Check that the volumes have set origins and therefor have had their AC
    %manually, or automatically selected
    if(any(~[MainMenu.UserData.SubjectStructure.Volumes([SelectedVolumes, CoregSelected]).ACSelected]))
        temp = MainMenu.UserData.SubjectStructure.Volumes(unique([SelectedVolumes, CoregSelected]));
        temp = temp([temp.ACSelected]);
        msg = compose('Coregistration cannot operate without correctly\nselected AC''s for all volumes\n\nThese volumes have not had their AC selected:\n');
        for i = 1:size(temp,2)
            msg = compose('%s%s',msg{1},sprintf('(%s)   %s\n',temp(i).Type,temp(i).FileName));
        end
        ErrorPanel(sprintf('%s',msg{1}));
        MainMenu.UserData.VolumeAdjustmentMenuProperties.uiCoregVolumePopUp.Value = size(MainMenu.UserData.VolumeAdjustmentMenuProperties.uiCoregVolumePopUp.String,1);
        return;
    end
    
    
    %Check that all images exist
    for i = [CoregSelected SelectedVolumes]
        if(~exist(MainMenu.UserData.SubjectStructure.Volumes(i).FileAddress,'file'))
            %Cannot locate file
            ErrorPanel(compose('Cannot locate : %s\nExisting Coregistration',MainMenu.UserData.SubjectStructure.Volumes(i).FileAddress));
            return;
        end
    end
    
    
    
    
    
    %Begin Coregistration process
    SubjectStructure = MainMenu.UserData.SubjectStructure;
    AMat = logical(MainMenu.UserData.SubjectStructure.AlignmentMatrix);
    
    
    
    %Work out which jobs need to be performed
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %This is the simple case, no dependancies                             %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if(~any(any(AMat(SelectedVolumes,:))) && ~any(any(AMat(:,SelectedVolumes))))
        %Volumes selected have no Dependancies
        
        
        ReferenceIDX = CoregSelected;
        SourceIDX = SelectedVolumes;
        OtherIDX = [];
       
        
        Count = 1;
        for S = SourceIDX
            
            MF = MessagePanel('Coregistering Images',sprintf('Please wait while the images are coregistered\n\n(%i/%i)',Count,size(SourceIDX,2)));
            drawnow(); 
                
            matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {strcat(SubjectStructure.Volumes(ReferenceIDX).FileAddress,',1')};
            matlabbatch{1}.spm.spatial.coreg.estwrite.source = {strcat(SubjectStructure.Volumes(S).FileAddress,',1')};
            matlabbatch{1}.spm.spatial.coreg.estwrite.other = {''};
            matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
            matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
            matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
            matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
            matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
            matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
            matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
            matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = '_';
            spm_jobman('run', matlabbatch); 
            Count = Count+1;
            
            
            %The (now coregistered volume) is placed into the source files
            %directory. Find the Source directory and rename the (now 
            % coregistered file) the orignal name. 
            [SourceDirectory] = fileparts(SubjectStructure.Volumes(S).FileAddress);
            
            %The new coregistered file is called _'filename.nii'
            NewFilePath = fullfile(SourceDirectory,strcat('_',SubjectStructure.Volumes(S).FileName));
            OldFilePath = SubjectStructure.Volumes(S).FileAddress;
            
            %Error checking
            if(~exist(NewFilePath,'file') || ~exist(OldFilePath,'file'))
                ErrorPanel('Missing files in coregistration');
                return;
            end
            
            %overwrite the old file
            movefile(NewFilePath,OldFilePath);

            %Close the messages
            if(ishandle(MF))
                close(MF);
            end
            
            %Indicate the new Alignment
            MainMenu.UserData.SubjectStructure.AlignmentMatrix(ReferenceIDX,SourceIDX) = true;
        end
        
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Moving a set of images that are in alignment, but we are not moving
    % any SourceAlignment Volumes
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                 Sources                              %InAlignment
    elseif(~any(any(AMat(SelectedVolumes,:))) && any(any(AMat(:,SelectedVolumes))))
        
        %For allvolumes (As we are not touching the Sources) we need to
        %remove the Source->Volume alignment (Warning Not finished)
        % Then simply coregister
        
        
        %Find Alignments to remove
        MF = MessagePanel('Removing Alignments','Removing Alignments');
        for V = SelectedVolumes
            
            %Remove the Source->Alignment Link
            MainMenu.UserData.SubjectStructure.AlignmentMatrix(AMat(:,V),V) = false;
            
        end
            
        
        %Continue Like a simple Coregistration
        ReferenceIDX = CoregSelected;
        SourceIDX = SelectedVolumes;
        OtherIDX = [];
        

        
        Count = 1;
        for S = SourceIDX
            
            MF = MessagePanel('Coregistering Images',sprintf('Please wait while the images are coregistered\n\n(%i/%i)',Count,size(SourceIDX,2)));
            drawnow(); 
                
            matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {strcat(SubjectStructure.Volumes(ReferenceIDX).FileAddress,',1')};
            matlabbatch{1}.spm.spatial.coreg.estwrite.source = {strcat(SubjectStructure.Volumes(S).FileAddress,',1')};
            matlabbatch{1}.spm.spatial.coreg.estwrite.other = {''};
            matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
            matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
            matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
            matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
            matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
            matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
            matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
            matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = '_';
            spm_jobman('run', matlabbatch); 
            Count = Count+1;
            
            
            %The (now coregistered volume) is placed into the source files
            %directory. Find the Source directory and rename the (now 
            % coregistered file) the orignal name. 
            [SourceDirectory] = fileparts(SubjectStructure.Volumes(S).FileAddress);
            
            %The new coregistered file is called _'filename.nii'
            NewFilePath = fullfile(SourceDirectory,strcat('_',SubjectStructure.Volumes(S).FileName));
            OldFilePath = SubjectStructure.Volumes(S).FileAddress;
            
            %Error checking
            if(~exist(NewFilePath,'file') || ~exist(OldFilePath,'file'))
                ErrorPanel('Missing files in coregistration');
                return;
            end
            
            %overwrite the old file
            movefile(NewFilePath,OldFilePath);

            
            if(ishandle(MF))
                close(MF);
            end
            
            MainMenu.UserData.SubjectStructure.AlignmentMatrix(ReferenceIDX,SourceIDX) = true;
            

        end
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Moving a set of images that are The sources only
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                 Sources                              %InAlignment
    elseif(any(any(AMat(SelectedVolumes,:))) && ~any(any(AMat(:,SelectedVolumes))))
        
        %Identify the 'InAlignment' Volumes and remove thier links

        
        %Find SourceAlignments to remove
        MF = MessagePanel('Removing Alignments','Removing Source Alignments');
        for V = SelectedVolumes
            
            %Remove the Source->Alignment Link
            MainMenu.UserData.SubjectStructure.AlignmentMatrix(V,AMat(V,:)) = false;
            
        end
            
        
        %Continue Like a simple Coregistration
        ReferenceIDX = CoregSelected;
        SourceIDX = SelectedVolumes;
        OtherIDX = [];
        

        
        Count = 1;
        for S = SourceIDX
            
            MF = MessagePanel('Coregistering Images',sprintf('Please wait while the images are coregistered\n\n(%i/%i)',Count,size(SourceIDX,2)));
            drawnow(); 
                
            matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {strcat(SubjectStructure.Volumes(ReferenceIDX).FileAddress,',1')};
            matlabbatch{1}.spm.spatial.coreg.estwrite.source = {strcat(SubjectStructure.Volumes(S).FileAddress,',1')};
            matlabbatch{1}.spm.spatial.coreg.estwrite.other = {''};
            matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
            matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
            matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
            matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
            matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
            matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
            matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
            matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = '_';
            spm_jobman('run', matlabbatch); 
            Count = Count+1;
            
            
            %The (now coregistered volume) is placed into the source files
            %directory. Find the Source directory and rename the (now 
            % coregistered file) the orignal name. 
            [SourceDirectory] = fileparts(SubjectStructure.Volumes(S).FileAddress);
            
            %The new coregistered file is called _'filename.nii'
            NewFilePath = fullfile(SourceDirectory,strcat('_',SubjectStructure.Volumes(S).FileName));
            OldFilePath = SubjectStructure.Volumes(S).FileAddress;
            
            %Error checking
            if(~exist(NewFilePath,'file') || ~exist(OldFilePath,'file'))
                ErrorPanel('Missing files in coregistration');
                return;
            end
            
            %overwrite the old file
            movefile(NewFilePath,OldFilePath);

            
            if(ishandle(MF))
                close(MF);
            end
            
            MainMenu.UserData.SubjectStructure.AlignmentMatrix(ReferenceIDX,SourceIDX) = true;
        end

        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Moving a set of images that are in alignment, And we are moving
    % ourceAlignment Volumes
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                 Sources                              %InAlignment
    elseif(any(any(AMat(SelectedVolumes,:))) && any(any(AMat(:,SelectedVolumes))))
        
        %For all volumes we need to identify any source links, and remove
        %the non-moved files from those links.
        %Then the linked files need to be the OtherIDX files where the
        %source needs to be in the Source and corresponding referenceIDX
        %files

        %Separate this opteration into several steps. First Identify any
        %Source relationships
        Relationships = struct('Reference',[],'Source',[],'InAlignment',[]);
        R = 1;
        for V = SelectedVolumes
            if( any(AMat(V,SelectedVolumes)))
                %This volume is a source
                Relationships(R).Source = V;
                Relationships(R).InAlignment = find(AMat(V,:));
                Relationships(R).Reference = CoregSelected;
                
                %If a relationship exists but has not been selected, the
                %Alignment must be removed
                %Remove the Source->Alignment Link
                MainMenu.UserData.SubjectStructure.AlignmentMatrix(Relationships(R).Source,setdiff(Relationships(R).InAlignment,SelectedVolumes)) = false;
                R = R+1;
            end
        end
            
        
        CoregOperations = sum(arrayfun(@(x) length(x.Source), Relationships));
        
        Count = 1;
       
        for R = 1:size(Relationships,2)
            %Using the Relationships Identified Coregister the images
            
            
            %Continue Like a simple Coregistration
            ReferenceIDX = Relationships(R).Reference;
            SourceIDX = Relationships(R).Source;
            OtherIDX = Relationships(R).InAlignment;




            MF = MessagePanel('Coregistering Images',sprintf('Please wait while the images are coregistered\n\n(%i/%i)',Count,CoregOperations));
            drawnow();
            
            matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {strcat(SubjectStructure.Volumes(ReferenceIDX).FileAddress,',1')};
            matlabbatch{1}.spm.spatial.coreg.estwrite.source = {strcat(SubjectStructure.Volumes(SourceIDX).FileAddress,',1')};
            matlabbatch{1}.spm.spatial.coreg.estwrite.other = strcat({SubjectStructure.Volumes(OtherIDX).FileAddress},',1')';
            matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
            matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
            matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
            matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
            matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
            matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
            matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
            matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = '_';
            spm_jobman('run', matlabbatch);
            Count = Count+1;
            
            
            for S = [SourceIDX OtherIDX]
                %The (now coregistered volume) is placed into the source files
                %directory. Find the Source directory and rename the (now 
                % coregistered file) the orignal name. 
                [SourceDirectory] = fileparts(SubjectStructure.Volumes(S).FileAddress);

                %The new coregistered file is called _'filename.nii'
                NewFilePath = fullfile(SourceDirectory,strcat('_',SubjectStructure.Volumes(S).FileName));
                OldFilePath = SubjectStructure.Volumes(S).FileAddress;

                %Error checking
                if(~exist(NewFilePath,'file') || ~exist(OldFilePath,'file'))
                    ErrorPanel('Missing files in coregistration');
                    return;
                end

                %overwrite the old file
                movefile(NewFilePath,OldFilePath);
            end
            
            if(ishandle(MF))
                close(MF);
            end
            
            MainMenu.UserData.SubjectStructure.AlignmentMatrix(ReferenceIDX,SourceIDX) = true;



        end
    end
    
    %Update Data in visible menu
    UpdateAlignSubmenu();
    
    %Remove the selection of the Images
    MainMenu.UserData.VolumeAdjustmentMenuProperties.uiAllVolumes.Value = [];
    
    %reset the coregistration selection
    MainMenu.UserData.VolumeAdjustmentMenuProperties.uiCoregVolumePopUp.Value = size(MainMenu.UserData.VolumeAdjustmentMenuProperties.uiCoregVolumePopUp.String,1);
    
    %Indicate completion
    MessagePanel('Success','Coregistration Complete');
end


        
        
        
        
        
        
        

