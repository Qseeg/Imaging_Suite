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

%ImportDicom function for the subject submenu

function [] = ImportDICOM(~,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; %
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    if(~isfield(MainMenu.UserData.SubjectMenuProperties,'tempDICOMname'))
        %This is where a question need to be asked. The result should then
        %be stored in the TempDICOMname place and this function should be
        %requested again.
        
        figure('Name','DICOM Import','NumberTitle','off','units','normalized','InnerPosition',[0.4 0.4 0.2 0.2],'Color',[1 1 1],'MenuBar','none','Tag','NewDICOMnameFigure');
        uicontrol('Style','text','units','normalized','Position',[0.1 0.85 0.8 0.10],'String','New DICOM Name:','BackgroundColor',[1 1 1]);
        uicontrol('Style','edit','units','normalized','Position',[0.1 0.7 0.8 0.15],'String','NewDICOM','Tag','uiDICOMname')  
                                    
        uicontrol('Style','text','units','normalized','Position',[0.1 0.55 0.8 0.10],'String','Image type:','BackgroundColor',[1 1 1]);
        uicontrol('Style','edit','units','normalized','Position',[0.1 0.4 0.8 0.15],'String','MRI_CT_PET','Tag','uiDICOMtype')
            
        
                                    
        uicontrol('Style','Pushbutton','units','normalized','Position',[0.1 0.1 0.35 0.15],'String','Continue',...
                        'callback',sprintf('%s%s%s%s%s%s%s%s%s%s%s%s',...
                                        'F = findobj(''Tag'',''NewDICOMnameFigure'');',...
                                        'if(numel(F) ~= 1);return;end;',...
                                        'uiname = findall(F,''Tag'',''uiDICOMname'');',...
                                        'if(numel(uiname) ~= 1);return;end;',...
                                        'uitype = findall(F,''Tag'',''uiDICOMtype'');',...
                                        'if(numel(uitype) ~= 1);return;end;',...
                                        'MainMenu = findobj(''Tag'',''ImagingMainMenuV2'');',...
                                        'if(numel(MainMenu) ~= 1);return;end;',...
                                        'MainMenu.UserData.SubjectMenuProperties.tempDICOMname = uiname.String;',...
                                        'MainMenu.UserData.SubjectMenuProperties.tempDICOMtype = uitype.String;',...
                                        'ImportDICOM()'));
                                    
        uicontrol('Style','Pushbutton','units','normalized','Position',[0.55 0.1 0.35 0.15],'String','Cancel',...
            'callback',sprintf('%s%s',...
                                        'F = findobj(''Tag'',''NewDICOMnameFigure'');',...
                                        'close(F)'));   
        
%         %find the figure
%         F = findobj('Tag','NewDICOMnameFigure');
%             %Error checking;
%             if(numel(F) ~= 1);return;end;
%             
%         %Find the edit box
%         uiname = findall(F,'Tag','uiDICOMname');
%             %Error checking;
%             if(numel(uiname) ~= 1);return;end;
%         
%         %Find the edit box
%         uitype = findall(F,'Tag','uiDICOMtype');
%             %Error checking;
%             if(numel(uitype) ~= 1);return;end;
%             
%         %Find the Menu
%         MainMenu = findobj('Tag','ImagingMainMenuV2');
%             %Error checking;
%             if(numel(MainMenu) ~= 1);return;end;
%             
%         %Make the new field in the structure from the ui string
%         MainMenu.UserData.SubjectMenuProperties.TempDICOMname = uiname.String;
%         MainMenu.UserData.SubjectMenuProperties.TempDICOMtype = uitype.String;
        
    else
        
        %This means that two fields are filled in MainMenu.UserData.SubjectMenuProperties
        %                           tempDICOMname
        %                           tempDICOMtype
        % They need to be removed
        % and the figure that created them has to be deleted, the tag is:
        %                           'NewDICOMnameFigure'
        
        
      
        
        
        %Extract the filename and remove the tempDICOMname addition
        NewName = MainMenu.UserData.SubjectMenuProperties.tempDICOMname;
        NewType = MainMenu.UserData.SubjectMenuProperties.tempDICOMtype;
        MainMenu.UserData.SubjectMenuProperties = rmfield(MainMenu.UserData.SubjectMenuProperties,{'tempDICOMname','tempDICOMtype'});
        
        %Close the collecting panel
        F = findobj('Tag','NewDICOMnameFigure');
        if(~isempty(F))
            close(F);
        end
        
        %Check that the new name isn't blank
        if(isempty(NewName))
            ErrorPanel('Cannot have a blank name');
            return;
        end
        
        %Check that the new type isnt blank
        if(isempty(NewType))
            ErrorPanel('Cannot have a blank type');
            return;
        end
        
        %Check if this type of file already exists
        SaveDirectory = fullfile(MainMenu.UserData.SubjectStructure.DIR,NewType);
        if(~exist(SaveDirectory,'dir'))
            
            %Create a new directory for this type of file
            mkdir(SaveDirectory);
            
        end
        
        if(exist(fullfile(SaveDirectory,strcat(NewName,'nii')),'file'))
            ErrorPanel(sprintf('A file already has that name in the Subjects\n directory'));
            return;
        end
        
        
        %Request the files to be converted
        [Files, Path] = uigetfile('*.*','Select DICOM files','multiselect','on');
        DICOMFiles = strcat(Path,Files);
        
        MF = MessagePanel('Importing Volume','Please wait while the DICOM is imported');
        drawnow;
   
        %SPM batch function to import Dicoms
        matlabbatch{1}.spm.util.import.dicom.data = DICOMFiles';
        matlabbatch{1}.spm.util.import.dicom.root = 'flat';
        matlabbatch{1}.spm.util.import.dicom.outdir = {SaveDirectory};
        matlabbatch{1}.spm.util.import.dicom.protfilter = '.*';
        matlabbatch{1}.spm.util.import.dicom.convopts.format = 'nii';
        matlabbatch{1}.spm.util.import.dicom.convopts.icedims = 0;
        spm_jobman('run', matlabbatch); 
    
        
        %%%%%%%%%%%%%%%%%%
        %Rename the dicoms->now in Nifti(.nii) format
        
        %Find the newest file made
        files = dir(SaveDirectory);
        files = files(~[files.isdir]); %Remove directories
        files = files(cellfun(@isempty, regexp({files.name},'^[.]','ONCE')));%Remove files begining with '.'
        %Find largest datenum = newest
        [~,Idx] = max([files.datenum]);
        
        
        CurrentFile = fullfile(SaveDirectory,files(Idx).name);
        NewFile = fullfile(SaveDirectory,strcat(NewName,'.nii'));
        
        %Rename
        movefile(CurrentFile,NewFile);

        %Get the current size of the SubjectStructure
        sz = size(MainMenu.UserData.SubjectStructure.Volumes,2);
        if(sz == 0)
            IDX = 1;
        elseif(sz == 1)
            if(isempty(MainMenu.UserData.SubjectStructure.Volumes(1).FileAddress))
                IDX = 1;
            else
                IDX = sz+1;
            end
        else
            IDX = sz+1;
        end
        
        %The new files need to be added to the internal structure
        MainMenu.UserData.SubjectStructure.Volumes(IDX).FileAddress = NewFile;
        MainMenu.UserData.SubjectStructure.Volumes(IDX).FileName = strcat(NewName,'.nii'); 
        MainMenu.UserData.SubjectStructure.Volumes(IDX).Type = NewType;
        MainMenu.UserData.SubjectStructure.Volumes(IDX).Space = 'WORLD';
        MainMenu.UserData.SubjectStructure.Volumes(IDX).SurfaceAddress = '';
        MainMenu.UserData.SubjectStructure.Volumes(IDX).SurfaceMaskAddress = '';
        MainMenu.UserData.SubjectStructure.Volumes(IDX).ACSelected = false;
        MainMenu.UserData.SubjectStructure.AlignmentMatrix = [MainMenu.UserData.SubjectStructure.AlignmentMatrix, zeros(size(MainMenu.UserData.SubjectStructure.AlignmentMatrix,2),1);zeros(1,size(MainMenu.UserData.SubjectStructure.AlignmentMatrix,2)+1)];
        
        
        %Update the Subject submenu
        UpdateSubjectMenu();
        
        if(ishandle(MF))
            close(MF);
        end
        
    end
end
