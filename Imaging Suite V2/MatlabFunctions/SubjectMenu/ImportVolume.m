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

%ImportVolume function for the subject submenu
%
% Only accepting .nii single files
%                .img & .hdr pairs      -> this is routed to a converter
%                                       resulting in a .nii file
% 

function [] = ImportVolume(~,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; %
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    if(~isfield(MainMenu.UserData.SubjectMenuProperties,'tempVOLUMEname'))
        %This is where a question need to be asked. The result should then
        %be stored in the tempVOLUMEname place and this function should be
        %requested again.
        
        figure('Name','VOLUME Import','NumberTitle','off','units','normalized','InnerPosition',[0.4 0.4 0.2 0.2],'Color',[1 1 1],'MenuBar','none','Tag','NewVOLUMEnameFigure');
        uicontrol('Style','text','units','normalized','Position',[0.1 0.85 0.8 0.10],'String','New VOLUME Name:','BackgroundColor',[1 1 1]);
        uicontrol('Style','edit','units','normalized','Position',[0.1 0.7 0.8 0.15],'String','NewVOLUME','Tag','uiVOLUMEname')  
                                    
        uicontrol('Style','text','units','normalized','Position',[0.1 0.55 0.8 0.10],'String','Image type:','BackgroundColor',[1 1 1]);
        uicontrol('Style','edit','units','normalized','Position',[0.1 0.4 0.8 0.15],'String','MRI_CT_PET','Tag','uiVOLUMEtype')
            
        
                                    
        uicontrol('Style','Pushbutton','units','normalized','Position',[0.1 0.1 0.35 0.15],'String','Continue',...
                        'callback',sprintf('%s%s%s%s%s%s%s%s%s%s%s%s',...
                                        'F = findobj(''Tag'',''NewVOLUMEnameFigure'');',...
                                        'if(numel(F) ~= 1);return;end;',...
                                        'uiname = findall(F,''Tag'',''uiVOLUMEname'');',...
                                        'if(numel(uiname) ~= 1);return;end;',...
                                        'uitype = findall(F,''Tag'',''uiVOLUMEtype'');',...
                                        'if(numel(uitype) ~= 1);return;end;',...
                                        'MainMenu = findobj(''Tag'',''ImagingMainMenuV2'');',...
                                        'if(numel(MainMenu) ~= 1);return;end;',...
                                        'MainMenu.UserData.SubjectMenuProperties.tempVOLUMEname = uiname.String;',...
                                        'MainMenu.UserData.SubjectMenuProperties.tempVOLUMEtype = uitype.String;',...
                                        'ImportVolume()'));
                                    
        uicontrol('Style','Pushbutton','units','normalized','Position',[0.55 0.1 0.35 0.15],'String','Cancel',...
            'callback',sprintf('%s%s',...
                                        'F = findobj(''Tag'',''NewVOLUMEnameFigure'');',...
                                        'close(F)'));   
        

    else
        
        %This means that two fields are filled in MainMenu.UserData.SubjectMenuProperties
        %                           tempVOLUMEname
        %                           tempVOLUMEtype
        % They need to be removed
        % and the figure that created them has to be deleted, the tag is:
        %                           'NewVOLUMEnameFigure'
        
        
      
        
        
        %Extract the filename and remove the tempVOLUMEname addition
        NewName = MainMenu.UserData.SubjectMenuProperties.tempVOLUMEname;
        NewType = MainMenu.UserData.SubjectMenuProperties.tempVOLUMEtype;
        MainMenu.UserData.SubjectMenuProperties = rmfield(MainMenu.UserData.SubjectMenuProperties,{'tempVOLUMEname','tempVOLUMEtype'});
        
        %Close the collecting panel
        F = findobj('Tag','NewVOLUMEnameFigure');
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
        

        
        %Request the files to be converted
        [File, Path] = uigetfile({'*.img;*.nii'},'Select Volume','multiselect','off');
        
        if(isnumeric(File))
            return;
        end
        
        %Work out what file was selcted
        [~,~,Ext] = fileparts(File);
        
        
        %Make sure we are not overwriting another file
        if(exist(fullfile(SaveDirectory,strcat(NewName,'.nii')),'file'))
            ErrorPanel('A file already exists with that name');
            return;
        end
        
        MF = MessagePanel('Importing Volume','Importing ... ');
        drawnow();
        
        %.img of .hdr
        if(strcmp(Ext,'.img'))
            
            %This needs to be converted to .nii
            matlabbatch{1}.spm.util.imcalc.input = {strcat(fullfile(Path,File),',1')};
            matlabbatch{1}.spm.util.imcalc.output = strcat(NewName,'.nii');
            matlabbatch{1}.spm.util.imcalc.outdir = {SaveDirectory};
            matlabbatch{1}.spm.util.imcalc.expression = 'i1';
            matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
            matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
            matlabbatch{1}.spm.util.imcalc.options.mask = 0;
            matlabbatch{1}.spm.util.imcalc.options.interp = 1;
            matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
            spm_jobman('run', matlabbatch); 

        else
            % .nii file
            copyfile(fullfile(Path,File),fullfile(SaveDirectory,strcat(NewName,Ext)));

        end
        
        NewFile = fullfile(SaveDirectory,strcat(NewName,'.nii'));


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
