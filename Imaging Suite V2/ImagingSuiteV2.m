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

% Imaging suite V2
% MainMenu


function [] = ImagingSuiteV2()

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Add to the path
    addpath(pwd);
    addpath('MatlabFunctions');
    addpath(fullfile('MatlabFunctions','spm12'));
    addpath(fullfile('MatlabFunctions','VolumeAdjustmentMenu'));
    addpath(fullfile('MatlabFunctions','SubjectMenu'));
    addpath(fullfile('MatlabFunctions','TwoDimensionalMenu'));
    addpath(fullfile('MatlabFunctions','ThreeDimensionalMenu'));
    addpath(fullfile('MatlabFunctions','Utility'));

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      
    MainMenu = findobj('Tag','ImagingMainMenuV2');
    if(~isempty(MainMenu))   
        QuitFunction();                 
    end                      

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Constants
    %MENU FIGURE
    MenuProperties.Name = 'Imaging Suite V2';
    MenuProperties.Tag = 'ImagingMainMenuV2';
    MenuProperties.Width = 200;
    MenuProperties.Height = 500;
    MenuProperties.Position = [ 0, 300, MenuProperties.Width, MenuProperties.Height];
    MenuProperties.Units = 'pixels';
    MenuProperties.Colour = [ 1 1 1 ];
    MenuProperties.Handle = [];
      
    %MENU BUTTONS
    MenuButtonProperties.NumButtons = 5;
    MenuButtonProperties.Clearence = 10;
    MenuButtonProperties.Units = 'pixels';
    MenuButtonProperties.Width = MenuProperties.Width - MenuButtonProperties.Clearence*2;
    MenuButtonProperties.Height = (MenuProperties.Height - MenuButtonProperties.Clearence*MenuButtonProperties.NumButtons - MenuButtonProperties.Clearence)./MenuButtonProperties.NumButtons;
    MenuButtonProperties.Position = [repmat(MenuButtonProperties.Clearence,1,MenuButtonProperties.NumButtons);...         X
                                    MenuProperties.Height-MenuButtonProperties.Clearence-MenuButtonProperties.Height:-(MenuButtonProperties.Clearence+MenuButtonProperties.Height):MenuButtonProperties.Clearence;... Y
                                    repmat(MenuButtonProperties.Width,1,MenuButtonProperties.NumButtons);... Width
                                    repmat(MenuButtonProperties.Height,1,MenuButtonProperties.NumButtons)]'; %Height
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SUBJECT MENU PROPERTIES
    SubjectMenuProperties.Name = 'Subject Details';
    SubjectMenuProperties.Tag =  'SubjectDetails';
    SubjectMenuProperties.Width = 600;
    SubjectMenuProperties.Height = 500;
    SubjectMenuProperties.Units = 'pixels';
    SubjectMenuProperties.Colour = [ 1 1 1 ];
    SubjectMenuProperties.ButtonReservedWidth = 100;
    SubjectMenuProperties.ButtonReservedHeight = 300;
    SubjectMenuProperties.ButtonClearence = 10;
    SubjectMenuProperties.Clearence = 10;
    SubjectMenuProperties.NumButtons = 7;
    SubjectMenuProperties.ButtonWidth = 80;
    SubjectMenuProperties.ButtonHeight = 30;
    SubjectMenuProperties.ButtonPosition = [repmat(SubjectMenuProperties.ButtonClearence,1,SubjectMenuProperties.NumButtons);...         X
                                    (SubjectMenuProperties.Height) - [1:SubjectMenuProperties.NumButtons] * (SubjectMenuProperties.ButtonHeight + SubjectMenuProperties.ButtonClearence);... Y
                                    repmat(SubjectMenuProperties.ButtonWidth,1,SubjectMenuProperties.NumButtons);... Width
                                    repmat(SubjectMenuProperties.ButtonHeight,1,SubjectMenuProperties.NumButtons)]'; %Height           
    SubjectMenuProperties.TextBoxHeight = 20;
    SubjectMenuProperties.TextSize = 12;
    SubjectMenuProperties.HeadingTextBoxHeight = 22;
    SubjectMenuProperties.HeadingTextSize = 16;
    SubjectMenuProperties.XOffset = SubjectMenuProperties.ButtonReservedWidth + SubjectMenuProperties.Clearence;                                     
    SubjectMenuProperties.Position = [ sum(MenuProperties.Position([1 3])), MenuProperties.Position(2), sum([SubjectMenuProperties.ButtonReservedWidth,SubjectMenuProperties.Width]), SubjectMenuProperties.Height];
    SubjectMenuProperties.Handle = [];
    SubjectMenuProperties.uiHELPMessage = [];
    
    
    %%%%%%%%%%%%%%%%%%%%
    % ALIGNVOLUMES MENU
    VolumeAdjustmentMenuProperties.Name = 'Align Volumes';
    VolumeAdjustmentMenuProperties.Tag =  'AlignVolumes';
    VolumeAdjustmentMenuProperties.Width = 500;
    VolumeAdjustmentMenuProperties.Height = 500;
    VolumeAdjustmentMenuProperties.Units = 'pixels';
    VolumeAdjustmentMenuProperties.Colour = [ 1 1 1 ];
    VolumeAdjustmentMenuProperties.ButtonReservedWidth = 100;
    VolumeAdjustmentMenuProperties.ButtonReservedHeight = 250;
    VolumeAdjustmentMenuProperties.ButtonClearence = 10;
    VolumeAdjustmentMenuProperties.Clearence = 10;
    VolumeAdjustmentMenuProperties.NumButtons = 7;
    VolumeAdjustmentMenuProperties.ButtonWidth = 80;
    VolumeAdjustmentMenuProperties.ButtonHeight = 30;
    VolumeAdjustmentMenuProperties.ButtonPosition = [repmat(VolumeAdjustmentMenuProperties.ButtonClearence,1,VolumeAdjustmentMenuProperties.NumButtons);...         X
                                    (VolumeAdjustmentMenuProperties.Height) - [1:VolumeAdjustmentMenuProperties.NumButtons] * (VolumeAdjustmentMenuProperties.ButtonHeight + VolumeAdjustmentMenuProperties.ButtonClearence);... Y
                                    repmat(VolumeAdjustmentMenuProperties.ButtonWidth,1,VolumeAdjustmentMenuProperties.NumButtons);... Width
                                    repmat(VolumeAdjustmentMenuProperties.ButtonHeight,1,VolumeAdjustmentMenuProperties.NumButtons)]'; %Height            
    VolumeAdjustmentMenuProperties.TextBoxHeight = 20;
    VolumeAdjustmentMenuProperties.TextSize = 12;
    VolumeAdjustmentMenuProperties.HeadingTextBoxHeight = 22;
    VolumeAdjustmentMenuProperties.HeadingTextSize = 16;
    VolumeAdjustmentMenuProperties.XOffset = VolumeAdjustmentMenuProperties.ButtonReservedWidth + VolumeAdjustmentMenuProperties.Clearence;                                     
    VolumeAdjustmentMenuProperties.Position = [ sum(MenuProperties.Position([1 3])), MenuProperties.Position(2), sum([VolumeAdjustmentMenuProperties.ButtonReservedWidth,VolumeAdjustmentMenuProperties.Width]), VolumeAdjustmentMenuProperties.Height];
    VolumeAdjustmentMenuProperties.Handle = [];
    VolumeAdjustmentMenuProperties.uiHelperText = [];
    
    %%%%%%%%%%%%%%%%%%%
    % TwoDMenu
    TwoDMenu.AxesGutter = 10;
    TwoDMenu.uiXOffset = 20;
    TwoDMenu.uiYOffset = [20, 50:20:300];
    TwoDMenu.uiHeight = 20;
    TwoDMenu.AxesArea = [0, 0, 550, 550];  %Position(4)-240
    TwoDMenu.SimplePosition = [200, 300, TwoDMenu.AxesArea(3), TwoDMenu.AxesArea(4)+3*TwoDMenu.uiHeight+TwoDMenu.AxesGutter];
    TwoDMenu.AdvSettingPosition = [200, 300, TwoDMenu.AxesArea(3), TwoDMenu.AxesArea(4)+10*TwoDMenu.uiHeight+TwoDMenu.AxesGutter];
    TwoDMenu.OverlayPosition = [200, 300, TwoDMenu.AxesArea(3), TwoDMenu.AxesArea(4)+13*TwoDMenu.uiHeight+TwoDMenu.AxesGutter];
    TwoDMenu.ROIToolsPosition = [200, 300, TwoDMenu.AxesArea(3)+300, TwoDMenu.AxesArea(4)+3*TwoDMenu.uiHeight+TwoDMenu.AxesGutter];
    
    TwoDMenu.uiXROIOffset = 20;
    TwoDMenu.uiYROIOffset = [20:25:550];
    TwoDMenu.uiROIHeight = 25; %Must be greater then 22
    
    InvalidHandle = figure('Visible','off');close(InvalidHandle);
    TwoDMenu.MaximumFigures = 3;
    TwoDMenu.MaximumOverlays = 2;
    TwoDMenu.GlobalProperties = struct( 'GlobalLink',true,...
                                        'BoundingBox',[],...
                                        'WorldDimensions',[],...
                                        'CurrentPoint',[0, 0, 0],...
                                        'ColourMaps',{{'bone','hot','jet','hsv','cool','spring','summer','autumn','winter','gray','copper','lines','white'}},...
                                        'Handles',InvalidHandle);
                                    
    TwoDMenu.Volumes(1:TwoDMenu.MaximumFigures) = deal(...
                                        struct( 'VolumeStructure',struct(),...
                                                'BoundingBox',[],...
                                                'WorldDimensions',[],...
                                                'CurrentPoint',[0, 0, 0],...
                                                'ColourMap','bone',...          initial selection performed in Colourmap constructor
                                                'uiAdvSettingsCheckBox',[],...
                                                'uiAddCrossHairCheckBox',[],...
                                                'uiAddOverlaysCheckBox',[],...
                                                'uiAddROIToolsCheckBox',[],...
                                                'uiCheckBoxRectangle',[],...
                                                ...
                                                'uiVolumeSelectionPopUp',[],...
                                                'uiVolumeSelectionText',[],...
                                                'uiVolumeColourMapPopUp',[],...
                                                'uiVolumeColourMapText',[],...
                                                'uiVolumeZoomPopUp',[],...
                                                'uiVolumeZoomText',[],...
                                                'uiVolumeRangeSlider',[],...
                                                'uiVolumeRangeSliderText',[],...
                                                'uiVolumeRangeSliderContainer',[],...
                                                'uiVolumeRangeSelectorPopUp',[],...
                                                ...
                                                'uiOverlaySelectionPopUp',[],...
                                                'uiOverlaySelectionText',[],...
                                                'uiOverlayVisibleCheckBox',[],...
                                                'uiOverlayVisibleText',[],...
                                                'uiOverlayColourMapPopUp',[],...
                                                'uiOverlayColourMapText',[],...
                                                'uiOverlayOpacitySlider',[],...
                                                'uiOverlayOpacitySliderContainer',[],...
                                                'uiOverlayOpacitySliderText',[],...
                                                'uiOverlayRangeSliderContainer',[],...
                                                ...
                                                'uiROICaptureButton',[],...
                                                'uiROINumberText',[],...
                                                'uiROINumber',[],...
                                                'uiROIDesignatorText',[],...
                                                'uiROIDesignator',[],...
                                                'uiROIXYZText',[],...
                                                'uiROIXYZ',[],...
                                                'uiROIListText',[],...
                                                'uiROIList',[],...
                                                'uiROIDeleteButton',[],...
                                                'uiROISaveButton',[],...
                                                'uiROISize',[],...
                                                'uiROISizeText',[],...
                                                'uiROIColourPopup',[],...
                                                'uiROIColourPopupText',[],...
                                                'uiROIVisibleCheckbox',[],...
                                                ...
                                                'DisplayRange',[nan nan],...
                                                'Range',[nan nan],...
                                                'Zoom',1,...
                                                ...
                                                'Handle',InvalidHandle,...
                                                'CoronalAxes',[],...
                                                'SagittalAxes',[],...
                                                'AxialAxes',[],...
                                                ...
                                                'CrossHairCoronalAxes',[],...
                                                'CrossHairSagittalAxes',[],...
                                                'CrossHairAxialAxes',[],...
                                                ...
                                                'ROICoronalAxes',[],...
                                                'ROISagittalAxes',[],...
                                                'ROIAxialAxes',[]));
                                            
    TwoDMenu.Overlays(1:TwoDMenu.MaximumFigures,1) = deal(...
                                                struct( 'VolumeStructure',struct(),...
                                                        'Visible',false,...
                                                        'ColourMap','autumn',...    Initial selection of the popup for the overlays
                                                        'Range',[nan nan],...
                                                        'DisplayRange',[nan nan],...
                                                        'Opacity',[50],...
                                                        'CoronalAxes',InvalidHandle,...
                                                        'SagittalAxes',InvalidHandle,...
                                                        'AxialAxes',InvalidHandle));
                                            
    %%%%%%%%%%%%%%%%%%%%%%
    % 3 Dimensional Menu %
    ThreeDMenu.AxesGutter = 10;
    ThreeDMenu.RectangleRelief = 4;
    
    ThreeDMenu.uiHeight = 25;
    ThreeDMenu.uiHeightSpacing = 27;
    ThreeDMenu.uiDisplayHeight = 25;
    ThreeDMenu.uiDisplayHeightSpacing = 27;
    ThreeDMenu.uiCutHeight = 25;
    ThreeDMenu.uiCutHeightSpacing = 27;
    
    ThreeDMenu.AxesArea = [0,0,550,550]; %[ThreeDMenu.AxesGutter, ThreeDMenu.AxesGutter, 550, 550];
    ThreeDMenu.TopToolsHeight = 200;
    ThreeDMenu.SideToolsWidth = 300;
    ThreeDMenu.SimplePosition = [200, 300, ThreeDMenu.AxesArea(3), ThreeDMenu.AxesArea(4)+2*(ThreeDMenu.uiDisplayHeightSpacing+ThreeDMenu.RectangleRelief)];
    ThreeDMenu.FullPosition = [200, 300, ThreeDMenu.AxesArea(3)+ThreeDMenu.SideToolsWidth, ThreeDMenu.AxesArea(4)+ThreeDMenu.TopToolsHeight];
    ThreeDMenu.Handle = [];
    
    ThreeDMenu.uiWidth = [ThreeDMenu.SideToolsWidth - 2*ThreeDMenu.AxesGutter, (ThreeDMenu.SideToolsWidth - 3*ThreeDMenu.AxesGutter)./2];
    ThreeDMenu.uiXOffset = ThreeDMenu.AxesArea(3) + [ ThreeDMenu.AxesGutter, 2*ThreeDMenu.AxesGutter + ThreeDMenu.uiWidth(2)]; 
    ThreeDMenu.uiYOffset = (ThreeDMenu.FullPosition(4) - ThreeDMenu.uiHeight-2*ThreeDMenu.RectangleRelief):-ThreeDMenu.uiHeightSpacing : 0;

    ThreeDMenu.uiDisplayFullWidth = (ThreeDMenu.SimplePosition(3) - 2*ThreeDMenu.AxesGutter);
    ThreeDMenu.uiDisplayWidth = (ThreeDMenu.SimplePosition(3) - 5*ThreeDMenu.AxesGutter)./4;
    ThreeDMenu.uiDisplayXOffset = ThreeDMenu.AxesGutter:(ThreeDMenu.uiDisplayWidth+ThreeDMenu.AxesGutter):ThreeDMenu.SimplePosition(3);
    ThreeDMenu.uiDisplayYOffset = (ThreeDMenu.SimplePosition(4) - ThreeDMenu.uiDisplayHeight-2*ThreeDMenu.RectangleRelief): -ThreeDMenu.uiDisplayHeightSpacing : 0; 
    ThreeDMenu.uiDisplayFullYOffset = (ThreeDMenu.FullPosition(4) - ThreeDMenu.uiDisplayHeight-2*ThreeDMenu.RectangleRelief): -ThreeDMenu.uiDisplayHeightSpacing : 0; 
    
    ThreeDMenu.uiCutFullWidth = (ThreeDMenu.SimplePosition(3) - 2*ThreeDMenu.AxesGutter);
    ThreeDMenu.uiCutWidth = (ThreeDMenu.SimplePosition(3) - 4*ThreeDMenu.AxesGutter)./3;
    ThreeDMenu.uiCutXOffset = ThreeDMenu.AxesGutter:(ThreeDMenu.uiCutWidth+ThreeDMenu.AxesGutter):ThreeDMenu.SimplePosition(3);
    ThreeDMenu.uiCutYOffset = (ThreeDMenu.FullPosition(4) - ThreeDMenu.uiCutHeight-2*ThreeDMenu.RectangleRelief): -ThreeDMenu.uiCutHeightSpacing : 0; 
    
    ThreeDMenu.ColourMaps = {'bone','hot','jet','hsv','cool','spring','summer','autumn','winter','gray','copper','lines','white'};
    ThreeDMenu.BoundingBox = [];
    ThreeDMenu.uiDisplayRectangle = [];
    ThreeDMenu.ui2DVolumeCheckBox = [];
    ThreeDMenu.ui3DSurfaceCheckBox = [];
    ThreeDMenu.uiROICheckBox = [];
    ThreeDMenu.uiROILabelsCheckBox = [];
    ThreeDMenu.uiExternalDataCheckBox = [];
    ThreeDMenu.uiVolumeSelectionPopUp = [];
    ThreeDMenu.uiVolumeSelectionText = [];
    ThreeDMenu.uiVolumeColourMapPopUp = [];
    ThreeDMenu.uiVolumeColourMapText = [];
    ThreeDMenu.uiVolumeOpacitiyPopUp = [];
    ThreeDMenu.uiVolumeOpacitiyText = [];
    ThreeDMenu.uiSurfacePopUpText = [];
    ThreeDMenu.uiSurfacePopUpButton = [];
    ThreeDMenu.uiSurfaceColourMapPopUp = [];
    ThreeDMenu.uiSurfaceColourMapText = [];
    ThreeDMenu.uiSurfaceOpacitiyPopUp = [];
    ThreeDMenu.uiSurfaceOpacitiyText = [];
    ThreeDMenu.uiROIPopUpText = [];
    ThreeDMenu.uiROIPopUp = [];
    ThreeDMenu.uiROILabelsCheckBox = [];
    ThreeDMenu.uiROIColourMapPopUp = [];
    ThreeDMenu.uiROIColourMapText = [];
    ThreeDMenu.uiROISizeText = [];
    ThreeDMenu.uiROISize = [];
    ThreeDMenu.uiROIConnectionPopUp = [];
    ThreeDMenu.uiROIConnectionText = [];
    ThreeDMenu.uiROIOpacitiyPopUp = [];
    ThreeDMenu.uiROIOpacitiyText = [];
    ThreeDMenu.uiDataImportText = [];
    ThreeDMenu.uiDataImportButton = [];
    ThreeDMenu.uiDataColourMapPopUp = [];
    ThreeDMenu.uiDataColourMapText = [];
    ThreeDMenu.uiDataOpacitiyPopUp = [];
    ThreeDMenu.uiDataOpacitiyText = [];
    ThreeDMenu.uiDataIndexSliderContainer = [];
    ThreeDMenu.uiDataIndexSlider = [];
    ThreeDMenu.uiDataIndexSliderText = [];
    ThreeDMenu.Axes = [];
    ThreeDMenu.SurfaceCreationPanel = [];
    ThreeDMenu.Volume.VolumeStructure = [];
    ThreeDMenu.Volume.premul = [];
    ThreeDMenu.Volume.BoundingBox = [];
    ThreeDMenu.Volume.WorldDimensions = [];
    ThreeDMenu.Volume.MaskVolumeStructure = [];
    ThreeDMenu.Volume.Maskpremul = [];
    ThreeDMenu.Volume.Range = [0 1];
    ThreeDMenu.DataStructure = [];
    ThreeDMenu.DisplayStructure = [];
    ThreeDMenu.ColourMap = [0 0 0;
                            0.5 0.5 0.5;
                            1 1 1;];
            
        
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                            
    %Subject Structure        % This is reproduced in the NewSubject
    %function and updated in ImportDICOM and ImportVolume
    SubjectStructure = struct('ID','',...
                            'DIR','',...
                            'Volumes',struct(   'FileAddress','',...
                                                'FileName','',...
                                                'Type','',...
                                                'Space','',...
                                                'SurfaceAddress','',...
                                                'SurfaceMaskAddress','',...
                                                'ROIs',struct(  'Label','',...
                                                                'XYZ',[]),...
                                                'ACSelected',false),...
                            'AlignmentMatrix',[]);
   
                        
                            
                            
    %%%%%%%%%%%%%%%%%%%%%%%
    % Check for duplicates
    MainMenu = findobj('Tag','ImagingMainMenuV2');
    if(~isempty(MainMenu))
        close(MainMenu);
    end


    
    %%%%%%%%%%%%%%%%%%%%%%%
    % Make the MainMenu FIGURE
    %%% PUT WARNING WHEN CLOSING 
    MainMenu = figure('Name',MenuProperties.Name,'units',MenuProperties.Units,'InnerPosition',MenuProperties.Position,'Tag',MenuProperties.Tag,'MenuBar','none','NumberTitle','off','Color',MenuProperties.Colour);        
    
    
        %%%%%%%%%%%%%%%%%
        % SubjectID 
        Button = 1;
        PatientButton = uicontrol('Style','pushbutton','units',MenuButtonProperties.Units,'Position',MenuButtonProperties.Position(Button,:),'String','Subject Details','Tag','SubjectButton','CallBack',@SubjectMenu); 
        
        %%%%%%%%%%%%%%%%%
        % Volume Adjustment
        Button = Button+1;
        VolumeAdjustmentButton = uicontrol(  'Style','pushbutton','units',MenuButtonProperties.Units,'Position',MenuButtonProperties.Position(Button,:),'String','Volume Adjustment','Tag','VolumeAdjustmentButton','CallBack',@VolumeAdjustmentMenu); 
        
        %%%%%%%%%%%%%%%%%
        % 2D Imaging
        Button = Button+1;
        TwoDImagingButton = uicontrol(  'Style','pushbutton','units',MenuButtonProperties.Units,'Position',MenuButtonProperties.Position(Button,:),'String','<html>2 Dimensional<br>Imaging','Tag','TwoDImagingButton','CallBack',@TwoDimensionalMenu); 

        %%%%%%%%%%%%%%%%%
        % 3D Imaging
        Button = Button+1;
        ThreeDImagingButton = uicontrol(  'Style','pushbutton','units',MenuButtonProperties.Units,'Position',MenuButtonProperties.Position(Button,:),'String','<html>3 Dimensional<br>Imaging','Tag','ThreeDImagingButton','CallBack',@ThreeDimensionalMenu); 

% %         %%%%%%%%%%%%%%%%%
% %         % External Data
% %         Button = Button+1;
% %         ExternalDataButton = uicontrol(  'Style','pushbutton','units',MenuButtonProperties.Units,'Position',MenuButtonProperties.Position(Button,:),'String','External Data','Tag','ExternalDataButton','CallBack','fprintf(''@ExternalDataButton Not created yet\n'');'); 
    
        %%%%%%%%%%%%%%%%%
        % Quit Data
        Button = Button+1;
        QuitButton = uicontrol(  'Style','pushbutton','units',MenuButtonProperties.Units,'Position',MenuButtonProperties.Position(Button,:),'String','Quit','Tag','QuitButton','CallBack',@QuitFunction);

        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %Place the Variables on the Main Menu
    %Handles
    MenuProperties.Handle = MainMenu;
    
    %Menus and Button properties
    MainMenu.UserData.MenuProperties = MenuProperties;
    MainMenu.UserData.MenuButtonProperties = MenuButtonProperties;
    MainMenu.UserData.SubjectMenuProperties = SubjectMenuProperties;
    
    %Subject Details
    MainMenu.UserData.SubjectStructure = SubjectStructure;
    
    %Align Volume Menu
    MainMenu.UserData.VolumeAdjustmentMenuProperties = VolumeAdjustmentMenuProperties;
    
    %TwoDMenu properties
    MainMenu.UserData.TwoDMenu = TwoDMenu;
    
    %ThreeDMenu properties
    MainMenu.UserData.ThreeDMenu = ThreeDMenu;
        
end

