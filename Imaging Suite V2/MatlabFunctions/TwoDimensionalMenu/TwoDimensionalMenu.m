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

%  Two dimesional Viewing Panel

function [] = TwoDimensionalMenu(~,~)

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
    
    
    %%%%%%%%%%%%%%%%%
    % Make a figure %
    %%%%%%%%%%%%%%%%%
    FigureNumber = Create2DDisplayFigure();
    if(FigureNumber == 0)
        ErrorPanel('Could not create a two dimensional imaging panel'); %This is actually already caught
        return;
    end
end

function [FigureNumber] = Create2DDisplayFigure()
    
    %Preallocation
    FigureNumber = 0;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    %Identify what panel Number we are up too
    if(isempty(MainMenu.UserData.TwoDMenu.GlobalProperties.Handles))
        FigureNumber = 1;
    else
        %Search through the list to identify the last, or a free spot
        for FigureNumber = 1:MainMenu.UserData.TwoDMenu.MaximumFigures         
            %Check the size
            if(size(MainMenu.UserData.TwoDMenu.GlobalProperties.Handles,2)<FigureNumber)
                break; %Volume number is set to the size (which is larger then the know listing
            elseif(~isvalid(MainMenu.UserData.TwoDMenu.GlobalProperties.Handles(FigureNumber)))
                break; %VolumeNumber is set to the free space found
            else
                FigureNumber = 0; %Null result causing an error 
            end
        end
    end
    if(FigureNumber == 0)
        %Catch the Error
        MessagePanel('Too Many Figures','Too many figures are active, please remove some');
        return;
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%
    % Make the Figure %
    FigurePosition = MainMenu.UserData.TwoDMenu.SimplePosition; FigurePosition(1) = FigurePosition(1) + FigurePosition(3) * (FigureNumber-1);
    TwoDMenu = figure('Name','','units','Pixel','InnerPosition',FigurePosition ,'Tag',sprintf('ImageDisplay(%i)',FigureNumber),'MenuBar','none','NumberTitle','off','Color',[1 1 1]);        
    MainMenu.UserData.TwoDMenu.GlobalProperties.Handles(FigureNumber) = TwoDMenu;
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).Handle = TwoDMenu;
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CurrentPoint = [0, 0, 0];
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).ColourMap = 'bone';
    
    %%%%%%%%%%%%%%
    % Display UI %
    %%%%%%%%%%%%%%
        
        uiXOffset = MainMenu.UserData.TwoDMenu.uiXOffset;
        uiYOffset = MainMenu.UserData.TwoDMenu.uiYOffset;
        uiHeight = MainMenu.UserData.TwoDMenu.uiHeight;
        ui2Width = (MainMenu.UserData.TwoDMenu.SimplePosition(3)-3*uiXOffset)./2;
        ui3Width = (MainMenu.UserData.TwoDMenu.SimplePosition(3)-5*uiXOffset)./3;
        ui4Width = (MainMenu.UserData.TwoDMenu.SimplePosition(3)-7*uiXOffset)./4;
        FigureHeight = MainMenu.UserData.TwoDMenu.SimplePosition(4);
        FigureWidth = MainMenu.UserData.TwoDMenu.SimplePosition(3);
        
        uiXROIOffset = MainMenu.UserData.TwoDMenu.uiXROIOffset;
        uiYROIOffset = MainMenu.UserData.TwoDMenu.uiYROIOffset;
        uiROIWidth = MainMenu.UserData.TwoDMenu.ROIToolsPosition(3) - FigureWidth - 2* uiXROIOffset;
        uiROI2Width = (MainMenu.UserData.TwoDMenu.ROIToolsPosition(3) - FigureWidth - 3* uiXROIOffset)./2;
        uiROIHeight = MainMenu.UserData.TwoDMenu.uiROIHeight;
        
        %%%%%%%%%%%%
        % SETTINGS %
        %%%%%%%%%%%%
            %Advanced Setting Checkbox
            uiAdvSettingsCheckBox = uicontrol('Style','checkbox','Units','pixel','position',[uiXOffset FigureHeight-uiYOffset(1) ui4Width uiHeight-2],'Value',0,'BackgroundColor',[1 1 1],'String','Advanced Settings','Tag',sprintf('AdvSettingsCheckBox(%i)',FigureNumber),'CallBack',@AdvSettingsOverlaysandROIToolsCheckBoxCallback);
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiAdvSettingsCheckBox = uiAdvSettingsCheckBox;

            %Add CrossHair Checkbox
            uiAddCrossHairCheckBox = uicontrol('Style','checkbox','Units','pixel','position',[2*uiXOffset+ui4Width FigureHeight-uiYOffset(1) ui4Width uiHeight-2],'Value',0,'BackgroundColor',[1 1 1],'String','Add Crosshair','Tag',sprintf('AddCrosshairCheckBox(%i)',FigureNumber),'CallBack',@AddCrossHairCallback);
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiAddCrossHairCheckBox = uiAddCrossHairCheckBox;

            %Add Overlays Checkbox
            uiAddOverlaysCheckBox = uicontrol('Style','checkbox','Units','pixel','position',[3*uiXOffset+2*ui4Width FigureHeight-uiYOffset(1) ui4Width uiHeight-2],'Value',0,'BackgroundColor',[1 1 1],'String','Add Overlays','Tag',sprintf('AddOverlaysCheckBox(%i)',FigureNumber),'CallBack',@AdvSettingsOverlaysandROIToolsCheckBoxCallback);
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiAddOverlaysCheckBox = uiAddOverlaysCheckBox;

            %ROI Tools Checkbox
            uiAddROIToolsCheckBox = uicontrol('Style','checkbox','Units','pixel','position',[4*uiXOffset+3*ui4Width FigureHeight-uiYOffset(1) ui4Width uiHeight-2],'Value',0,'BackgroundColor',[1 1 1],'String','Add ROI Tools','Tag',sprintf('AddROIToolsCheckBox(%i)',FigureNumber),'CallBack',@AdvSettingsOverlaysandROIToolsCheckBoxCallback);
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiAddROIToolsCheckBox = uiAddROIToolsCheckBox;

            %Draw a rectangle around these to separate them
            uiCheckBoxRectangle = axes('Units','pixels','position',[uiXOffset./2, FigureHeight-uiYOffset(1)-2, FigureWidth - uiXOffset, uiHeight+2],'XTick',[],'YTick',[]);
            plot([0 0 1 1 0],[0 1 1 0 0],'k','LineWidth',3); axis('tight');uiCheckBoxRectangle.Visible = 'off';uiCheckBoxRectangle.Layer = 'top';
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiCheckBoxRectangle = uiCheckBoxRectangle;

        %%%%%%%%%%
        %Volumes % 
        %%%%%%%%%%
            %VolumeSelector
            uiVolumeSelectionText = uicontrol('Style','text','units','pixel','position',[uiXOffset FigureHeight-uiYOffset(2) ui2Width uiHeight],'String','Volume to Display','BackgroundColor',[1 1 1],'HorizontalAlignment','Left');
            VolumeSelectionText = strcat('(',{MainMenu.UserData.SubjectStructure.Volumes.FileName},{')   '} ,{MainMenu.UserData.SubjectStructure.Volumes.Type});
            uiVolumeSelectionPopUp = uicontrol('Style','popupmenu','Units','pixel','position',[uiXOffset FigureHeight-uiYOffset(3) ui2Width uiHeight],'String',VolumeSelectionText,'Value',1,'Tag',sprintf('VolumeSelectionPopUp(%i)',FigureNumber),'CallBack',@VolumeSelectionPopupCallback);
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeSelectionPopUp = uiVolumeSelectionPopUp;
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeSelectionText = uiVolumeSelectionText;

            %ColourMap
            uiVolumeColourMapText = uicontrol('Style','text','units','pixel','position',[uiXOffset-FigureWidth MainMenu.UserData.TwoDMenu.AdvSettingPosition(4)-uiYOffset(4) ui2Width uiHeight],'String','Colour map','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible',false);
            ColourMapText = MainMenu.UserData.TwoDMenu.GlobalProperties.ColourMaps;
            uiVolumeColourMapPopUp = uicontrol('Style','popupmenu','Units','pixel','position',[uiXOffset-FigureWidth MainMenu.UserData.TwoDMenu.AdvSettingPosition(4)-uiYOffset(5) ui2Width uiHeight],'String',ColourMapText,'Value',1,'Visible',true,'Tag',sprintf('VolumeColourMapPopUp(%i)',FigureNumber),'CallBack',@VolumeColourMapPopupCallback);
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeColourMapPopUp = uiVolumeColourMapPopUp;
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeColourMapText = uiVolumeColourMapText;
            
            %Zoom
            uiVolumeZoomText =  uicontrol('Style','text','units','pixel','position',[uiXOffset-FigureWidth MainMenu.UserData.TwoDMenu.AdvSettingPosition(4)-uiYOffset(6) ui2Width uiHeight],'String','Volume Zoom','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible',false);
            ZoomText = {'x1','x2','x3','x4','x5'};
            uiVolumeZoomPopUp = uicontrol('Style','popupmenu','Units','pixel','position',[uiXOffset-FigureWidth MainMenu.UserData.TwoDMenu.AdvSettingPosition(4)-uiYOffset(7) ui2Width uiHeight],'String',ZoomText,'Value',1,'Visible',false,'Tag',sprintf('VolumeZoomPopUp(%i)',FigureNumber),'CallBack',@VolumeZoomPopupCallback);
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeZoomPopUp = uiVolumeZoomPopUp;
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeZoomText = uiVolumeZoomText;
            
            %Rangeslider (VOLUME RANGE)
            uiVolumeRangeSliderText = uicontrol('Style','text','units','pixel','position',[uiXOffset-FigureWidth MainMenu.UserData.TwoDMenu.AdvSettingPosition(4)-uiYOffset(8) ui2Width uiHeight],'String','Volume Range','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible',false);
            Range = round(GetVolumeRange(MainMenu.UserData.SubjectStructure.Volumes(uiVolumeSelectionPopUp.Value).FileAddress));
            MainMenu.UserData.TwoDMenu.Volumes(uiVolumeSelectionPopUp.Value).Range = Range;
            uiVolumeRangeSlider = com.jidesoft.swing.RangeSlider(Range(1), Range(2), Range(1), Range(2));
            [uiVolumeRangeSlider,uiVolumeRangeSliderContainer] = javacomponent(uiVolumeRangeSlider, [uiXOffset-FigureWidth,MainMenu.UserData.TwoDMenu.AdvSettingPosition(4)-uiYOffset(10),ui2Width,2*uiHeight], gcf);
            set(uiVolumeRangeSlider,'MajorTickSpacing',round(diff(Range)/4),...
                'MinorTickSpacing',round(diff(Range)/16),...
                'PaintTicks',true, 'PaintLabels',true,...
                'Background',java.awt.Color.white,...
                'Visible',0,...
                'Name',sprintf('uiVolumeRangeSlider(%i)',FigureNumber),...
                'MouseReleasedCallback',@VolumeRangeUpdateCallback);%'StateChangedCallback',@VolumeRangeChangeCallback);
            uiVolumeRangeSliderContainer.BackgroundColor = [1 1 1];
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeRangeSliderContainer = uiVolumeRangeSliderContainer;
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeRangeSlider = uiVolumeRangeSlider;
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeRangeSliderText = uiVolumeRangeSliderText;
            
        %%%%%%%%%%
        %OVERLAY % 
        %%%%%%%%%%   
            %Overlay Selector
            uiOverlaySelectionText = uicontrol('Style','text','units','pixel','position',[uiXOffset+ui2Width+uiXOffset-FigureWidth MainMenu.UserData.TwoDMenu.OverlayPosition(4)-uiYOffset(1) ui2Width uiHeight],'String','Overlay','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible',false);
            OverlaySelectionText = strcat('(',{MainMenu.UserData.SubjectStructure.Volumes.FileName},{')   '} ,{MainMenu.UserData.SubjectStructure.Volumes.Type});
            uiOverlaySelectionPopUp = uicontrol('Style','popupmenu','Units','pixel','position',[uiXOffset+ui2Width+uiXOffset-FigureWidth MainMenu.UserData.TwoDMenu.OverlayPosition(4)-uiYOffset(2) ui2Width uiHeight],'String',OverlaySelectionText,'Value',1,'Visible',false,'Tag',sprintf('OverlaySelectionPopUp(%i)',FigureNumber),'CallBack',@OverlaySelectionPopupCallback);
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlaySelectionPopUp = uiOverlaySelectionPopUp;
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlaySelectionText = uiOverlaySelectionText;
            %Uncheck all Overlays
            [MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,1:size(MainMenu.UserData.SubjectStructure.Volumes,2)).Visible] = deal(false);

            %Overlay on/off option
            uiOverlayVisibleText = uicontrol('Style','text','units','pixel','position',[uiXOffset+ui2Width+uiXOffset-FigureWidth MainMenu.UserData.TwoDMenu.OverlayPosition(4)-uiYOffset(3) ui2Width uiHeight],'String','Visible','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible',false);
            uiOverlayVisibleCheckBox = uicontrol('Style','checkbox','Units','pixel','position',[uiXOffset+ui2Width+uiXOffset-FigureWidth MainMenu.UserData.TwoDMenu.OverlayPosition(4)-uiYOffset(4) ui2Width uiHeight],'Value',0,'BackgroundColor',[1 1 1],'Visible',false,'Tag',sprintf('OverlayVisibleCheckBox(%i)',FigureNumber),'CallBack',@OverlayVisibleCheckBoxCallback);
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayVisibleCheckBox = uiOverlayVisibleCheckBox;
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayVisibleText = uiOverlayVisibleText;
            
            %ColourMap
            uiOverlayColourMapText = uicontrol('Style','text','units','pixel','position',[uiXOffset+ui2Width+uiXOffset-FigureWidth MainMenu.UserData.TwoDMenu.OverlayPosition(4)-uiYOffset(5) ui2Width uiHeight],'String','Colour Map','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible',false);
            ColourMapText = MainMenu.UserData.TwoDMenu.GlobalProperties.ColourMaps;
            uiOverlayColourMapPopUp = uicontrol('Style','popupmenu','Units','pixel','position',[uiXOffset+ui2Width+uiXOffset-FigureWidth MainMenu.UserData.TwoDMenu.OverlayPosition(4)-uiYOffset(6) ui2Width uiHeight],'String',ColourMapText,'Value',8,'Visible',false,'Tag',sprintf('OverlayColourMapPopUp(%i)',FigureNumber),'CallBack',@OverlayColourMapPopupCallback);
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayColourMapPopUp = uiOverlayColourMapPopUp;
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayColourMapText = uiOverlayColourMapText;

            %Slider (OVERLAY OPACITY)
            uiOverlayOpacitySliderText = uicontrol('Style','text','units','pixel','position',[uiXOffset+ui2Width+uiXOffset-FigureWidth MainMenu.UserData.TwoDMenu.OverlayPosition(4)-uiYOffset(7) ui2Width uiHeight],'String','Overlay Opacity','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible',false);
            [uiOverlayOpacitySlider,uiOverlayOpacitySliderContainer] = javacomponent(javax.swing.JSlider(0, 100, 50), [uiXOffset+ui2Width+uiXOffset-FigureWidth, MainMenu.UserData.TwoDMenu.OverlayPosition(4)-uiYOffset(9),ui2Width,2*uiHeight], gcf);
            set(uiOverlayOpacitySlider, 'MajorTickSpacing',25,...round(diff(Range)/4),...
                                        'MinorTickSpacing',5,...round(diff(Range)/16),...
                                        'PaintTicks',true, 'PaintLabels',true,...
                                        'Background',java.awt.Color.white,...
                                        'Visible',0,...
                                        'Name',sprintf('uiOverlayOpacitySlider(%i)',FigureNumber),...
                                        'MouseReleasedCallback',@OverlayOpacitySliderCallback);
            uiOverlayOpacitySliderContainer.BackgroundColor = [1 1 1];
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayOpacitySliderContainer = uiOverlayOpacitySliderContainer;
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayOpacitySlider = uiOverlayOpacitySlider;
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayOpacitySliderText = uiOverlayOpacitySliderText;

            %Rangeslider (OVERLAY RANGE)
            uiOverlayRangeSliderText = uicontrol('Style','text','units','pixel','position',[uiXOffset+ui2Width+uiXOffset-FigureWidth MainMenu.UserData.TwoDMenu.OverlayPosition(4)-uiYOffset(10) ui2Width uiHeight],'String','Overlay Range','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible',false);
            uiOverlayRangeSlider = com.jidesoft.swing.RangeSlider(0, 100, 0, 100); 
            [uiOverlayRangeSlider,uiOverlayRangeSliderContainer] = javacomponent(uiOverlayRangeSlider, [uiXOffset+ui2Width+uiXOffset-FigureWidth, MainMenu.UserData.TwoDMenu.OverlayPosition(4)-uiYOffset(12),ui2Width,2*uiHeight], gcf);
            set(uiOverlayRangeSlider,'MajorTickSpacing',250,...round(diff(Range)/4),...
                                    'MinorTickSpacing',50,...round(diff(Range)/16),...
                                    'PaintTicks',true, 'PaintLabels',true,...
                                    'Background',java.awt.Color.white,...
                                    'Visible',0,...
                                    'Name',sprintf('uiOverlayRangeSlider(%i)',FigureNumber),...
                                    'MouseReleasedCallback',@OverlayRangeUpdateCallback);%'StateChangedCallback',@OverlayRangeChangeCallback);
            uiOverlayRangeSliderContainer.BackgroundColor = [1 1 1];
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayRangeSliderContainer = uiOverlayRangeSliderContainer;
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayRangeSlider = uiOverlayRangeSlider;
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayRangeSliderText = uiOverlayRangeSliderText;

        %%%%%%%%%%%%%
        % ROI Tools %
        %%%%%%%%%%%%%
            %Save ROI List
            uiROISaveButton = uicontrol('Style', 'pushbutton','units','pixel','Position',[uiXOffset+FigureWidth, uiYROIOffset(20), uiROI2Width, uiROIHeight],'String','Save ROIs','Visible',false,'Callback',@SaveROIs);
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROISaveButton = uiROISaveButton;
            
            %Visibility
            uiROIVisibleCheckbox = uicontrol('Style', 'Checkbox','units','pixel','Position',[uiXOffset+FigureWidth, uiYROIOffset(17), uiROIWidth, uiROIHeight],'String','ROIs Visible','Value',1,'BackgroundColor',[1 1 1],'Tag',sprintf('ROIsVisibleCheckbox(%i)',FigureNumber),'HorizontalAlignment','Left','Visible',true,'Callback',@ROIsVisible);
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIVisibleCheckbox = uiROIVisibleCheckbox;
            
            %Colour
            uiROIColourPopupText = uicontrol('Style', 'Text','units','pixel','Position',[uiXOffset+FigureWidth, uiYROIOffset(16), uiROI2Width, uiROIHeight],'String','ROI Colour','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible',true);
            uiROIColourPopup = uicontrol('Style', 'Popupmenu','units','pixel','Position',[2*uiXOffset+FigureWidth+uiROI2Width, uiYROIOffset(16), uiROI2Width, uiROIHeight],'Value',1,'String',{'Red','Blue','Green','White','Yellow'},'Tag',sprintf('ROIColour(%i)',FigureNumber),'BackgroundColor',[1 1 1],'Visible',true,'Callback',@ROIColourChange);
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIColourPopupText = uiROIColourPopupText;
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIColourPopup = uiROIColourPopup;
            
            %Size
            uiROISizeText = uicontrol('Style', 'Text','units','pixel','Position',[uiXOffset+FigureWidth, uiYROIOffset(15), uiROI2Width, uiROIHeight],'String','ROI Size (mm)','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible',true);
            uiROISize = uicontrol('Style', 'edit','units','pixel','Position',[2*uiXOffset+FigureWidth+uiROI2Width, uiYROIOffset(15), uiROI2Width, uiROIHeight],'String','5','BackgroundColor',[1 1 1],'Tag',sprintf('ROISize(%i)',FigureNumber),'Visible',true,'Callback',@CheckROISize);
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROISizeText = uiROISizeText;
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROISize = uiROISize;
            
            %Delete ROI 
            uiROIDeleteButton = uicontrol('Style', 'pushbutton','units','pixel','Position',[2*uiXOffset+FigureWidth+uiROI2Width, uiYROIOffset(13), uiROI2Width, uiROIHeight],'Tag',sprintf('ROIDelete(%i)',FigureNumber),'String','Delete Selected ROIs','Visible',false, 'Callback', @ROIDelete);
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIDeleteButton = uiROIDeleteButton;
            
            %ROI List
            uiROIListText = uicontrol('Style', 'Text','units','pixel','Position',[uiXOffset+FigureWidth, uiYROIOffset(13), uiROI2Width, uiROIHeight],'String','Regions of Interest','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible',false);
            uiROIList = uicontrol('Style', 'List','units','pixel','Position',[uiXOffset+FigureWidth, uiYROIOffset(7), uiROIWidth, 6*uiROIHeight],'String',{''},'Min',1,'Max',3,'Value',[],'Tag',sprintf('ROIList(%i)',FigureNumber),'Visible',false,'CallBack',@ROIListSelection);
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIListText = uiROIListText;
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIList = uiROIList;
            
            %XYZ position
            uiROIXYZText = uicontrol('Style', 'Text','units','pixel','Position',[uiXOffset+FigureWidth, uiYROIOffset(6), uiROIWidth, uiROIHeight],'String','Position','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible',false);
            uiROIXYZ = uicontrol('Style', 'edit','units','pixel','Position',[uiXOffset+FigureWidth, uiYROIOffset(5), uiROIWidth, uiROIHeight],'String',sprintf('[%3.1f, %3.1f, %3.1f]',MainMenu.UserData.TwoDMenu.GlobalProperties.CurrentPoint),'Tag',sprintf('uiROIXYZ(%i)',FigureNumber),'BackgroundColor',[1 1 1],'HorizontalAlignment','Center','Visible',false,'Callback',@ROIUserXYZInput);
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIXYZText = uiROIXYZText;
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIXYZ = uiROIXYZ;
            
            %Designator
            uiROIDesignatorText = uicontrol('Style', 'Text','units','pixel','Position',[uiXOffset+FigureWidth, uiYROIOffset(4), uiROI2Width, uiROIHeight],'String','Designator','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible',false);
            uiROIDesignator = uicontrol('Style', 'edit','units','pixel','Position',[uiXOffset+FigureWidth, uiYROIOffset(3), uiROI2Width, uiROIHeight],'String','D','BackgroundColor',[1 1 1],'HorizontalAlignment','Center','Visible',false);
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIDesignatorText = uiROIDesignatorText;
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIDesignator = uiROIDesignator;
            
            %Number
            uiROINumberText = uicontrol('Style', 'Text','units','pixel','Position',[2*uiXOffset+FigureWidth+uiROI2Width, uiYROIOffset(4), uiROI2Width, uiROIHeight],'String','Number','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible',false);
            uiROINumber = uicontrol('Style', 'edit','units','pixel','Position',[2*uiXOffset+FigureWidth+uiROI2Width, uiYROIOffset(3), uiROI2Width, uiROIHeight],'String','1','BackgroundColor',[1 1 1],'HorizontalAlignment','Center','Tag',sprintf('ROINumber(%i)',FigureNumber),'Visible',false,'Callback',@CheckROINumber);
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROINumberText = uiROINumberText;
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROINumber = uiROINumber;
            
            %Capture ROI
            uiROICaptureButton = uicontrol('Style', 'pushbutton','units','pixel','Position',[uiXOffset+FigureWidth, uiYROIOffset(1), uiROIWidth, 1.8*uiROIHeight],'String','Capture ROI','Tag',sprintf('ROICapture(%i)',FigureNumber),'Visible',false,'Callback',@ROICapture);
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROICaptureButton = uiROICaptureButton;
            
    %%%%%%%%%%%%%%%%%%%%%%%%
    % Load the Volume data %
    %%%%%%%%%%%%%%%%%%%%%%%%
    LoadDisplayVolume(FigureNumber,1); %Creation of the axes and display is performed in the same function
    
    %Display Something
    %CreateDisplayAxes(FigureNumber);
    
    %Display an image so that it isn't blank
    %ChangeDisplayPosition(FigureNumber);
    
end

function [] = ROIDelete(src,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; %
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Collect the figure number that is being adjusted
    %Instantiation: sprintf('ROIDelete(%i)',FigureNumber)
    FigureNumber = str2double(src.Tag(11:end-1));
    VolumeNumber = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeSelectionPopUp.Value;

    %Make sure one is selected
    sz = length(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIList.Value);
    if(sz == 0)
        return;
    end
    
    %Remove the ROI
    MainMenu.UserData.SubjectStructure.Volumes(VolumeNumber).ROIs = MainMenu.UserData.SubjectStructure.Volumes(VolumeNumber).ROIs(setdiff(1:size(MainMenu.UserData.SubjectStructure.Volumes(VolumeNumber).ROIs,2), MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIList.Value));
    
    %Update the List
    UpdateROIList(FigureNumber, VolumeNumber)
    
    %Update the Display
    ChangeDisplayPosition(FigureNumber);
   
end

function [] = ROIListSelection(src,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; %
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Collect the figure number that is being adjusted
    %Instantiation: sprintf('ROIList(%i)',FigureNumber)
    FigureNumber = str2double(src.Tag(9:end-1));
    VolumeNumber = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeSelectionPopUp.Value;
    
    %Make sure only one is selected
    sz = length(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIList.Value);
    if(sz == 0)
        return;
    elseif(sz >1)
        %Reduce to the lowest value
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIList.Value = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIList.Value(1);
    end
    
    if(strcmp(src.String{src.Value},''))
        %Ignor this selection
        src.Value = [];
        return;
    end
    
    %Change the position of the Cursor to the selected point
    XYZ = MainMenu.UserData.SubjectStructure.Volumes(VolumeNumber).ROIs(1,MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIList.Value).XYZ;
    if(MainMenu.UserData.TwoDMenu.GlobalProperties.GlobalLink)
        MainMenu.UserData.TwoDMenu.GlobalProperties.CurrentPoint = XYZ;
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CurrentPoint = XYZ;
    else
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CurrentPoint = XYZ;
    end
    
    %Update Figure
    ChangeDisplayPosition(FigureNumber);
    
    %Update ROI Information
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIXYZ.String = sprintf('[%3.1f, %3.1f, %3.1f]',XYZ(1),XYZ(2),XYZ(3));
    
end

function [] = SaveROIs(~,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; %
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
   
    SaveSubject([],[]);
    
end
   
function [] = ROIColourChange(src, ~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; %
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Collect the figure number that is being adjusted
    %Instantiation: sprintf('ROIColour(%i)',FigureNumber)
    FigureNumber = str2double(src.Tag(11:end-1));
    
    %Update
    ChangeDisplayPosition(FigureNumber);

end

function [] = CheckROISize(src,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; %
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Collect the figure number that is being adjusted
    %Instantiation: sprintf('ROISize(%i)',FigureNumber)
    FigureNumber = str2double(src.Tag(9:end-1));
    
    %Check that the value is numeric
    if(isempty(regexp(src.String,'^[ ]*[0-9]*([.]?[0-9]*)?[ ]*$','ONCE')))
        MessagePanel('Non Numeric Value','The Value entered is not numeric');
        src.String = '5';
    end
    
    %Update the Display
    ChangeDisplayPosition(FigureNumber);
end

function [] = CheckROINumber(src,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; %
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Collect the figure number that is being adjusted
    %Instantiation: sprintf('ROINumber(%i)',FigureNumber)
    FigureNumber = str2double(src.Tag(11:end-1));
    
    %Check that the value is numeric
    if(isempty(regexp(src.String,'^[ ]*[0-9]*[ ]*$','ONCE')))
        MessagePanel('Non integer value','The value entered is not an integer');
        src.String = '1';
    end
end

function [] = ROIsVisible(src,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; %
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Collect the figure number that is being adjusted
    %Instantiation: sprintf('ROIsVisibleCheckbox(%i)',FigureNumber)
    FigureNumber = str2double(src.Tag(21:end-1));
    
    %Create New Axes
    CreateROIAxes(FigureNumber);
    
    %Update the figure
    ChangeDisplayPosition(FigureNumber);
    
end

function [] = ROICapture(src,~)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; %
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    %Collect the figure number that is being adjusted
    %Instantiation: sprintf('ROICapture(%i)',FigureNumber)
    FigureNumber = str2double(src.Tag(12:end-1));
    VolumeNumber = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeSelectionPopUp.Value;
    
    %Check that the designator has not already been placed
    Designator = strcat(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIDesignator.String,'_',MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROINumber.String);
    if(isempty(MainMenu.UserData.SubjectStructure.Volumes(VolumeNumber).ROIs))
        %Do Nothing Here, it is to catch the next statement before
        %cancelling
       Designator = strcat(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIDesignator.String,'_',MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROINumber.String);
    elseif(any(strcmp({MainMenu.UserData.SubjectStructure.Volumes(VolumeNumber).ROIs.Label},Designator)))
        MessagePanel('Designator already Taken',sprintf('The Designator and Number combonation chosen has already been used\nThe ROI has not been captured'));
        return;
    end

    %Save the Designator to the SubjectStructure
    if(~isfield(MainMenu.UserData.SubjectStructure.Volumes(VolumeNumber).ROIs,'Label'))  %Has a ROI stucture been made?
        IDX = 1;
    elseif(size(MainMenu.UserData.SubjectStructure.Volumes(VolumeNumber).ROIs,2)==0) %It hasn't been deconstructed
        IDX = 1;
    elseif(isempty(MainMenu.UserData.SubjectStructure.Volumes(VolumeNumber).ROIs(1).Label)) %Is it the defualt/empty structure
        IDX = 1;
    else
        IDX = size(MainMenu.UserData.SubjectStructure.Volumes(VolumeNumber).ROIs,2) + 1;    %Its been populated already, Add to it
    end
    
    MainMenu.UserData.SubjectStructure.Volumes(VolumeNumber).ROIs(IDX).Label = Designator;
    MainMenu.UserData.SubjectStructure.Volumes(VolumeNumber).ROIs(IDX).XYZ = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CurrentPoint;
    
    %Update the ROI List
    UpdateROIList(FigureNumber, VolumeNumber);
    
    %Update Display
    ChangeDisplayPosition(FigureNumber);
    
    %Increment the Number
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROINumber.String = num2str(str2double(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROINumber.String) + 1);
    
end

function [] = UpdateROIList(FigureNumber, VolumeNumber)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; %
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if(isempty(MainMenu.UserData.SubjectStructure.Volumes(VolumeNumber).ROIs))
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIList.String = {''};
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIList.Value = [];
        return;
    end
    
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIList.String = {MainMenu.UserData.SubjectStructure.Volumes(VolumeNumber).ROIs.Label};
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIList.Value = [];
end

function [] = ROIUserXYZInput(src,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; %
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Figure Number
    %Instantiation: sprintf('uiROIXYZ(%i)',FigureNumber)
    FigureNumber = str2double(src.Tag(10:end-1));
    
    %Identify is the User Input was a valid input
    InputXYZ = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIXYZ.String;
    s = regexp(InputXYZ,'^\[[ ]*-?[0-9]+([.]{1,1}[0-9]+)?,[ ]*-?[0-9]+([.]{1,1}[0-9]+)?,[ ]*-?[0-9]+([.]{1,1}[0-9]+)?[ ]*]','Once');
    
    %Error Check
    if(isempty(s))
        MessagePanel('Incorrect format for user input',sprintf('Please enter the XYZ in the format\n\n[x,y,z]\n\nwhere x,y and z are integers or decimal'));
        return;
    end
    
    NewXYZ = sscanf(InputXYZ,'[%f, %f, %f]')';
    
    %Update the CurrentPointer
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CurrentPoint = NewXYZ;
    if(MainMenu.UserData.TwoDMenu.GlobalProperties.GlobalLink)
        MainMenu.UserData.TwoDMenu.GlobalProperties.CurrentPoint = NewXYZ;
    end
    
    %Update the Display
    ChangeDisplayPosition(FigureNumber);
    
    

end

function [] = AddCrossHairCallback(src,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; %
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    %Collect the figure number that is being adjusted
    %Instantiation: sprintf('AddCrosshairCheckBox(%i)',FigureNumber)
    FigureNumber = str2double(src.Tag(22:end-1));
    
    if(src.Value)
        %Create Crosshair Axes
        CreateCrossHairAxes(FigureNumber);
    else
        %remove the axes
        delete(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CrossHairCoronalAxes);
        delete(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CrossHairSagittalAxes);
        delete(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CrossHairAxialAxes);
    end
        
    
    %Update the pane
    ChangeDisplayPosition(FigureNumber);
    
end

function [] = AdvSettingsOverlaysandROIToolsCheckBoxCallback(src,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; %
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %Collect the figure number that is being adjusted
    %Instantiation  1) sprintf('AdvSettingsCheckBox(%i)',FigureNumber)
    %               2) sprintf('AddOverlaysCheckBox(%i)',FigureNumber)
    %               3) sprintf('AddROIToolsCheckBox(%i)',FigureNumber)
    FigureNumber = str2double(src.Tag(21:end-1));
    VolumeNumber = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeSelectionPopUp.Value;
    OverlayNumber = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlaySelectionPopUp.Value;
    
    %Work out the New size of the figure
    FigurePosition = MainMenu.UserData.TwoDMenu.SimplePosition;
    if(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiAdvSettingsCheckBox.Value);FigurePosition(3:4) = max([FigurePosition(3:4);MainMenu.UserData.TwoDMenu.AdvSettingPosition(3:4)]);end
    if(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiAddOverlaysCheckBox.Value);FigurePosition(3:4) = max([FigurePosition(3:4);MainMenu.UserData.TwoDMenu.OverlayPosition(3:4)]);end
    if(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiAddROIToolsCheckBox.Value);FigurePosition(3:4) = max([FigurePosition(3:4);MainMenu.UserData.TwoDMenu.ROIToolsPosition(3:4)]);end

    %Update with the new size
    MainMenu.UserData.TwoDMenu.GlobalProperties.Handles(FigureNumber).Position = FigurePosition;
    
    %Adjust all other figure positions to suit
    ValidFigures = isvalid(MainMenu.UserData.TwoDMenu.GlobalProperties.Handles);
    for i = 2:size(ValidFigures,2)
        MainMenu.UserData.TwoDMenu.GlobalProperties.Handles(ValidFigure(i)).Position(3:4) = sum( [MainMenu.UserData.TwoDMenu.GlobalProperties.Handles(ValidFigure(1:i-1)).Position(3:4)]);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Based on what is selected Redraw/Remove all uicontrols %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    uiXOffset = MainMenu.UserData.TwoDMenu.uiXOffset;
    uiYOffset = MainMenu.UserData.TwoDMenu.uiYOffset;
    uiHeight = MainMenu.UserData.TwoDMenu.uiHeight;
    ui2Width = (MainMenu.UserData.TwoDMenu.SimplePosition(3)-3*uiXOffset)./2;
    %ui3Width = (MainMenu.UserData.TwoDMenu.SimplePosition(3)-5*uiXOffset)./3;
    ui4Width = (MainMenu.UserData.TwoDMenu.SimplePosition(3)-7*uiXOffset)./4;
    FigureWidth = MainMenu.UserData.TwoDMenu.SimplePosition(3);
    
    uiXROIOffset = MainMenu.UserData.TwoDMenu.uiXROIOffset;
    uiYROIOffset = MainMenu.UserData.TwoDMenu.uiYROIOffset;
    %uiROIWidth = MainMenu.UserData.TwoDMenu.ROIToolsPosition(3) - FigureWidth - 2* uiXROIOffset;
    uiROI2Width = (MainMenu.UserData.TwoDMenu.ROIToolsPosition(3) - FigureWidth - 3* uiXROIOffset)./2;
    %uiROIHeight = MainMenu.UserData.TwoDMenu.uiROIHeight;
    
    %%%%%%%%%%%%%%%%%%%%%%%
    % Settings Checkboxes %
    %%%%%%%%%%%%%%%%%%%%%%%
    %Advanced Setting Checkbox
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiAdvSettingsCheckBox.Position(1:2) = [uiXOffset, FigurePosition(4)-uiYOffset(1)];
    
    %Add Crosshairs
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiAddCrossHairCheckBox.Position(1:2) = [2*uiXOffset + ui4Width, FigurePosition(4)-uiYOffset(1)];
    
    %Add Overlays Checkbox
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiAddOverlaysCheckBox.Position(1:2) = [3*uiXOffset+2*ui4Width, FigurePosition(4)-uiYOffset(1)];
    
    %ROI Tools Checkbox
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiAddROIToolsCheckBox.Position(1:2) = [4*uiXOffset+3*ui4Width, FigurePosition(4)-uiYOffset(1)];
    
    %Draw a rectangle around these to separate them
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiCheckBoxRectangle.Position = [uiXOffset./2, FigurePosition(4)-uiYOffset(1)-2, FigurePosition(3)-uiXOffset, uiHeight+2];

    %Move the VolumeSelector
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeSelectionText.Position = [uiXOffset, FigurePosition(4)-uiYOffset(2), ui2Width, uiHeight];
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeSelectionPopUp.Position = [uiXOffset, FigurePosition(4)-uiYOffset(3), ui2Width, uiHeight];
        
    
    %%%%%%%%%%%%%%%%%%%%
    %Advanced Settings %
    %%%%%%%%%%%%%%%%%%%%
    if(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiAdvSettingsCheckBox.Value)
        %Volume Settings - Make Visible
        %ColourMap
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeColourMapText.Visible = true;
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeColourMapText.Position(1:2) = [uiXOffset, FigurePosition(4)-uiYOffset(4)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeColourMapPopUp.Visible = true;
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeColourMapPopUp.Position(1:2) = [uiXOffset, FigurePosition(4)-uiYOffset(5)];
        
        %Zoom
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeZoomText.Visible = true;
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeZoomText.Position(1:2) = [uiXOffset, FigurePosition(4)-uiYOffset(6)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeZoomPopUp.Visible = true;
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeZoomPopUp.Position(1:2) = [uiXOffset, FigurePosition(4)-uiYOffset(7)];
        
        %Rangeslider (VOLUME RANGE)
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeRangeSliderText.Visible = true;
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeRangeSliderText.Position(1:2) = [uiXOffset, FigurePosition(4)-uiYOffset(8)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeRangeSlider.Visible = true;
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeRangeSliderContainer.Position(1:2) = [uiXOffset, FigurePosition(4)-uiYOffset(10)];

    else
         %Volume Settings - Make INvisible
        %ColourMap
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeColourMapText.Visible = false;
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeColourMapText.Position(1:2) = [uiXOffset-FigurePosition(3), FigurePosition(4)-uiYOffset(4)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeColourMapPopUp.Visible = false;
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeColourMapPopUp.Position(1:2) = [uiXOffset-FigurePosition(3), FigurePosition(4)-uiYOffset(5)];
        
        %Zoom
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeZoomText.Visible = false;
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeZoomText.Position(1:2) = [uiXOffset-FigurePosition(3), FigurePosition(4)-uiYOffset(6)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeZoomPopUp.Visible = false;
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeZoomPopUp.Position(1:2) = [uiXOffset-FigurePosition(3), FigurePosition(4)-uiYOffset(7)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeZoomPopUp.Value = 1;
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).Zoom = 1;
        
        %Rangeslider (VOLUME RANGE)
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeRangeSliderText.Visible = false;
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeRangeSliderText.Position(1:2) = [uiXOffset-FigurePosition(3), FigurePosition(4)-uiYOffset(8)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeRangeSlider.Visible = false;
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeRangeSliderContainer.Position(1:2) = [uiXOffset-FigurePosition(3), FigurePosition(4)-uiYOffset(10)];
    end
      
    %%%%%%%%%%%%%%%
    % Add Overlay %
    %%%%%%%%%%%%%%%
    if(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiAddOverlaysCheckBox.Value)
        %Overlay Settings - Visible
        %Overlay volume
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlaySelectionText.Position(1:2) = [uiXOffset+ui2Width+uiXOffset, FigurePosition(4)-uiYOffset(2)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlaySelectionText.Visible = true;
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlaySelectionPopUp.Position(1:2) = [uiXOffset+ui2Width+uiXOffset, FigurePosition(4)-uiYOffset(3)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlaySelectionPopUp.Visible = true;
        
        %Overlay on/off option
        if(MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,OverlayNumber).Visible); MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayVisibleCheckBox.Value = 1; else; MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayVisibleCheckBox.Value = 0; end
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayVisibleText.Position(1:2) = [uiXOffset+ui2Width+uiXOffset, FigurePosition(4)-uiYOffset(4)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayVisibleText.Visible = true;
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayVisibleCheckBox.Position(1:2) = [uiXOffset+ui2Width+uiXOffset, FigurePosition(4)-uiYOffset(5)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayVisibleCheckBox.Visible = true;
        
        %ColourMap
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayColourMapText.Position(1:2) = [uiXOffset+ui2Width+uiXOffset, FigurePosition(4)-uiYOffset(6)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayColourMapPopUp.Position(1:2) = [uiXOffset+ui2Width+uiXOffset, FigurePosition(4)-uiYOffset(7)];
        
        %Slider (OVERLAY OPACITY)
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayOpacitySliderText.Position(1:2) = [uiXOffset+ui2Width+uiXOffset, FigurePosition(4)-uiYOffset(8)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayOpacitySliderContainer.Position(1:2) = [uiXOffset+ui2Width+uiXOffset, FigurePosition(4)-uiYOffset(10)];
        
        %Rangeslider (OVERLAY RANGE)
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayRangeSliderText.Position(1:2) = [uiXOffset+ui2Width+uiXOffset, FigurePosition(4)-uiYOffset(11)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayRangeSliderContainer.Position(1:2) = [uiXOffset+ui2Width+uiXOffset, FigurePosition(4)-uiYOffset(13)];
        
        
        if(MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,OverlayNumber).Visible)
            %Overlay Advanceds Settings -Visible
            %ColourMap
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayColourMapText.Visible = true;
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayColourMapPopUp.Visible = true;

            %Slider (OVERLAY OPACITY)
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayOpacitySliderText.Visible = true;
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayOpacitySliderContainer.Visible = true;
            
            %Rangeslider (OVERLAY RANGE)
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayRangeSliderText.Visible = true;
            MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayRangeSliderContainer.Visible = true;
        end
    else
        %Overlay Advanceds Settings -INvisible
        %Overlay volume
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlaySelectionText.Position(1:2) = [uiXOffset+ui2Width+uiXOffset-FigurePosition(3), FigurePosition(4)-uiYOffset(2)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlaySelectionText.Visible = false;
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlaySelectionPopUp.Position(1:2) = [uiXOffset+ui2Width+uiXOffset-FigurePosition(3), FigurePosition(4)-uiYOffset(3)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlaySelectionPopUp.Visible = false;
        
        %Overlay on/off option
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayVisibleText.Position(1:2) = [uiXOffset+ui2Width+uiXOffset-FigurePosition(3), FigurePosition(4)-uiYOffset(4)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayVisibleText.Visible = false;
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayVisibleCheckBox.Position(1:2) = [uiXOffset+ui2Width+uiXOffset-FigurePosition(3), FigurePosition(4)-uiYOffset(5)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayVisibleCheckBox.Visible = false;
        
        %ColourMap
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayColourMapText.Position(1:2) = [uiXOffset+ui2Width+uiXOffset-FigurePosition(3), FigurePosition(4)-uiYOffset(6)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayColourMapText.Visible = false;
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayColourMapPopUp.Position(1:2) = [uiXOffset+ui2Width+uiXOffset-FigurePosition(3), FigurePosition(4)-uiYOffset(7)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayColourMapPopUp.Visible = false;
        
        %Slider (OVERLAY OPACITY)
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayOpacitySliderText.Position(1:2) = [uiXOffset+ui2Width+uiXOffset-FigurePosition(3), FigurePosition(4)-uiYOffset(8)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayOpacitySliderText.Visible = false;
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayOpacitySliderContainer.Position(1:2) = [uiXOffset+ui2Width+uiXOffset-FigurePosition(3), FigurePosition(4)-uiYOffset(10)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayOpacitySliderContainer.Visible = false;
        
        %Rangeslider (OVERLAY RANGE)
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayRangeSliderText.Position(1:2) = [uiXOffset+ui2Width+uiXOffset-FigurePosition(3), FigurePosition(4)-uiYOffset(11)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayRangeSliderText.Visible = false;
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayRangeSliderContainer.Position(1:2) = [uiXOffset+ui2Width+uiXOffset-FigurePosition(3), FigurePosition(4)-uiYOffset(13)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayRangeSliderContainer.Visible = false;
        
        %Make all overlays invisible
        [MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,:).Visible] = deal(false);
        
        %Remove any axes on the figure
        delete([MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,:).AxialAxes]);
        delete([MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,:).CoronalAxes]);
        delete([MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,:).SagittalAxes]);

    end
   
    %%%%%%%%%%%%%
    % ROI TOOLS %
    %%%%%%%%%%%%%
    if(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiAddROIToolsCheckBox.Value)
        %ROI TOOLs
        %Capture Button
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROICaptureButton.Visible = true;
        %MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROICaptureButton.Position(1:2) = [uiXOffset+FigureWidth, uiYROIOffset(1)];
        
        %ROI number
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROINumberText.Visible = true;
        %MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROINumberText.Position(1:2) = [2*uiXOffset+FigureWidth+uiROI2Width, uiYROIOffset(4)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROINumber.Visible = true;
        %MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROINumber.Position(1:2) = [2*uiXOffset+FigureWidth+uiROI2Width, uiYROIOffset(3)];
        
        %ROI Designator
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIDesignatorText.Visible = true;
        %MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIDesignatorText.Position(1:2) = [uiXOffset+FigureWidth, uiYROIOffset(4)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIDesignator.Visible = true;
        %MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIDesignator.Position(1:2) = [uiXOffset+FigureWidth, uiYROIOffset(3)];
        
        %ROI XYZ position
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIXYZText.Visible = true;
        %MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIXYZText.Position(1:2) = [uiXOffset+FigureWidth, uiYROIOffset(6)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIXYZ.Visible = true;
        %MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIXYZ.Position(1:2) = [uiXOffset+FigureWidth, uiYROIOffset(5)];
        
        %ROI Listing
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIListText.Visible = true;
        %MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIListText.Position(1:2) = [uiXOffset+FigureWidth, uiYROIOffset(13)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIList.Visible = true;
        %MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIList.Position(1:2) = [uiXOffset+FigureWidth, uiYROIOffset(7)];
        
        %Save And Delete
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIDeleteButton.Visible = true;
        %MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIDeleteButton.Position(1:2) = [uiXOffset+FigureWidth, uiYROIOffset(14)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROISaveButton.Visible = true;
        %MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROISaveButton.Position(1:2) = [2*uiXOffset+FigureWidth+uiROI2Width, uiYROIOffset(14)];

        %Create the ROI Axes
        CreateROIAxes(FigureNumber);
        
        %Show the list of ROIs
        UpdateROIList(FigureNumber, VolumeNumber);
        
        
    else
        %ROI TOOLs
        %Capture Button
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROICaptureButton.Visible = true;
        %MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROICaptureButton.Position(1:2) = [uiXOffset+FigureWidth-FigurePosition(3), uiYROIOffset(1)];
        
        %ROI number
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROINumberText.Visible = true;
        %MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROINumberText.Position(1:2) = [2*uiXOffset+FigureWidth+uiROI2Width-FigurePosition(3), uiYROIOffset(4)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROINumber.Visible = true;
        %MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROINumber.Position(1:2) = [2*uiXOffset+FigureWidth+uiROI2Width-FigurePosition(3), uiYROIOffset(3)];
        
        %ROI Designator
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIDesignatorText.Visible = true;
        %MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIDesignatorText.Position(1:2) = [uiXOffset+FigureWidth-FigurePosition(3), uiYROIOffset(4)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIDesignator.Visible = true;
        %MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIDesignator.Position(1:2) = [uiXOffset+FigureWidth-FigurePosition(3), uiYROIOffset(3)];
        
        %ROI XYZ position
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIXYZText.Visible = true;
        %MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIXYZText.Position(1:2) = [uiXOffset+FigureWidth-FigurePosition(3), uiYROIOffset(6)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIXYZ.Visible = true;
        %MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIXYZ.Position(1:2) = [uiXOffset+FigureWidth-FigurePosition(3), uiYROIOffset(5)];
        
        %ROI Listing
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIListText.Visible = true;
        %MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIListText.Position(1:2) = [uiXOffset+FigureWidth-FigurePosition(3), uiYROIOffset(13)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIList.Visible = true;
        %MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIList.Position(1:2) = [uiXOffset+FigureWidth-FigurePosition(3), uiYROIOffset(7)];
        
        %Save And Delete
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIDeleteButton.Visible = true;
        %MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIDeleteButton.Position(1:2) = [uiXOffset+FigureWidth-FigurePosition(3), uiYROIOffset(14)];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROISaveButton.Visible = true;
        %MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROISaveButton.Position(1:2) = [2*uiXOffset+FigureWidth+uiROI2Width-FigurePosition(3), uiYROIOffset(14)];

        %Delete the ROI Axes
        delete([MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).ROIAxialAxes]);
        delete([MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).ROICoronalAxes]);
        delete([MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).ROISagittalAxes]);
            
    end

    
    ChangeDisplayPosition(FigureNumber);
end

function [] = OverlayOpacitySliderCallback(src,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Instantiation: sprintf('uiOverlayOpacitySlider(%i)',FigureNumber)
    Name = char(src.getName);
    FigureNumber = str2double(Name(24:end-1));
    VolumeNumber = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlaySelectionPopUp.Value;

    %Extract the Position of the sliders and save it as the range
    MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).Opacity = [MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayOpacitySlider.getValue()];
    
    %Update the figures
    ChangeDisplayPosition(FigureNumber);
    
end

function [] = OverlayColourMapPopupCallback(src,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    FigureNumber = str2double(src.Tag(23:end-1));
    VolumeNumber = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlaySelectionPopUp.Value;
    
    %Save Colourmap choice
    MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).ColourMap = MainMenu.UserData.TwoDMenu.GlobalProperties.ColourMaps{MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayColourMapPopUp.Value};
    
    %Update the Display
    ChangeDisplayPosition(FigureNumber);
    
end

function [] = OverlayVisibleCheckBoxCallback(src,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Obtain the Figure number
    %Instantiation: 'Tag',sprintf('OverlayVisibleCheckBox(%i)',FigureNumber)
    FigureNumber = str2double(src.Tag(24:end-1));
    VolumeNumber = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlaySelectionPopUp.Value;
    
    %Identify if we are applying or removing the overlay
    if(src.Value)
        %%%%%%%%%%%
        %Applying %
        %%%%%%%%%%%
        
        %Set the Apply Flag
        MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).Visible = true;
        
        %SetVisiblity of the options
        OverlayOptionsVisible(FigureNumber);
        
        %Create the Axes for the Volume
        CreateOverlayAxes(FigureNumber,VolumeNumber);
        
        %Load the Data
        LoadOverlayVolume(FigureNumber,VolumeNumber);
        
    else
        %%%%%%%%%%%
        %Removing %
        %%%%%%%%%%%
        %Remove the Apply Flag
        MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).Visible = false;
        
        %Hide the Options
        OverlayOptionsInvisible(FigureNumber);
        
        %Remove Active Overlay Axes
        delete(MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).AxialAxes);
        delete(MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).CoronalAxes);
        delete(MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).SagittalAxes);
        
        %Reload the pane
        ChangeDisplayPosition(FigureNumber);
    end

end

function [] = OverlaySelectionPopupCallback(src,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    
    %Obtain the Figure number
    %Instantiation: 'Tag',sprintf('OverlaySelectionPopUp(%i)',FigureNumber)
    FigureNumber = str2double(src.Tag(23:end-1));
    VolumeNumber = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlaySelectionPopUp.Value;
    
    %Correct the Visible checkbox
    if(MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).Visible)
        
        %Tick the Checkbox
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayVisibleCheckBox.Value = true;
        
        %Show the options
        OverlayOptionsVisible(FigureNumber);

    else
        %Remove the Checkbox
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayVisibleCheckBox.Value = false;
        
        %Hide the options
        OverlayOptionsInvisible(FigureNumber);
    end
end

function [] = OverlayRangeUpdateCallback(src,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    %Instantiation: sprintf('uiOverlayRangeSlider(%i)',FigureNumber)
    Name = char(src.getName);
    FigureNumber = str2double(Name(22:end-1));
    VolumeNumber = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlaySelectionPopUp.Value;
    
    %Collect the Range Slider
    uiOverlayRangeSlider = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayRangeSlider;
    
    %Check that the Range is not ontop of one another
    if(uiOverlayRangeSlider.getLowValue() == uiOverlayRangeSlider.getHighValue)
        %Move the sliders fractionally apart
        Modifier = eps; %Matt you are here trying to modify the ticks so that they do not be the same
    else
        Modifier = 0;
        %uiOverlayRangeSlider.setLowValue(uiOverlayRangeSlider.getLowValue() - eps);
        %uiOverlayRangeSlider.setHighValue(uiOverlayRangeSlider.getHighValue() + eps);
    end
    
    %Extract the Position of the sliders and save it as the range
    MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).DisplayRange = [uiOverlayRangeSlider.getLowValue()-Modifier uiOverlayRangeSlider.getHighValue()+Modifier];

    
    %Update the figures
    ChangeDisplayPosition(FigureNumber);
    
end

function [] = VolumeRangeUpdateCallback(src,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Only Two possible modes to have this callback.
    % VolumeRangeSelector - uicontrol('Popup') to swap between 'Automatic' and 'Manual'
    % VolumeRangeSlider   - javacomponent('swing.RangeSlider') Change the
    %                       'manual' values
    
    %Get the FigureNumber
    FigureNumber = nan;
    switch class(src)
        case 'matlab.ui.control.UIControl' %Matlab UI 
            %This must have been the popup selector
            %Instantiation: sprintf('VolumeRangeSelectorPopUp(%i)',FigureNumber)
            FigureNumber = str2double(src.Tag(26:end-1));
            
            %Collect the Range Slider
            uiVolumeRangeSlider = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeRangeSlider;
            uiVolumeRangeSliderText = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeRangeSliderText;
            uiVolumeRangeSelectorPopUp = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeRangeSelectorPopUp;

            if(uiVolumeRangeSelectorPopUp.Value == 1) %'Automatic'

                %Ensure that the Slider is invisible
                uiVolumeRangeSlider.setVisible(0);
                uiVolumeRangeSliderText.Visible = 0;

                %Set Range to MaximumViewable
                MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).DisplayRange = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).Range;

            else %'Manual'

                %Enable the visibility of the RangeSlider
                uiVolumeRangeSliderText.Visible = 1;
                uiVolumeRangeSlider.setVisible(1);

                %Update the New Range
                VolumeNumber = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeSelectionPopUp.Value;    
                MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).DisplayRange = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).Range;
                
                %maximums
                uiVolumeRangeSlider.setMinimum(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).DisplayRange(1));
                uiVolumeRangeSlider.setMaximum(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).DisplayRange(2));
                
                %Current Values
                uiVolumeRangeSlider.setLowValue(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).DisplayRange(1));
                uiVolumeRangeSlider.setHighValue(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).DisplayRange(2));
                
                %UpdateTicks
                uiVolumeRangeSlider.setMajorTickSpacing(round(diff(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).DisplayRange)./4));
                uiVolumeRangeSlider.setLabelTable(uiVolumeRangeSlider.createStandardLabels(round(diff(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).DisplayRange)./4)));
                uiVolumeRangeSlider.setMinorTickSpacing(round(diff(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).DisplayRange)./16));
   
                

                
                
                
            end
        case 'javahandle_withcallbacks.com.jidesoft.swing.RangeSlider'  %RangeSlider
            %Name instantiation: sprintf('uiVolumeRangeSlider(%i)',FigureNumber)
            Name = char(src.getName);
            FigureNumber = str2double(Name(21:end-1));
            
            %Collect the Range Slider
            uiVolumeRangeSlider = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeRangeSlider;
            uiVolumeRangeSliderText = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeRangeSliderText;
            uiVolumeRangeSelectorPopUp = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeRangeSelectorPopUp;
            
            %Check that the Range is not ontop of one another
            if(src.getLowValue() == src.getHighValue)
                %Move the sliders fractionally apart
                src.setLowValue(src.getLowValue() - eps);
                src.setHighValue(src.getHighValue() + eps);
                MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).DisplayRange = [src.getLowValue() src.getHighValue()];
             
            else
                %Extract the Position of the sliders and save it as the range
                MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).DisplayRange = [src.getLowValue() src.getHighValue()];
            end    
    end
    
    %Update the figures
    ChangeDisplayPosition(FigureNumber);
    
end

function [MinMaxRange] = GetVolumeRange(FileAddress)

    volume = spm_read_vols(spm_vol(FileAddress));
    Minimum = min(volume(:));
    Maximum = max(volume(:));
    MinMaxRange = [Minimum, Maximum];
    
end

function [] = VolumeZoomPopupCallback(src,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    %Work out what figure has been used to call this function
    FigureNumber = nan;
    for FigureNumber = 1:size(MainMenu.UserData.TwoDMenu.GlobalProperties.Handles,2)
        if(strcmp(src.Parent.Tag,MainMenu.UserData.TwoDMenu.GlobalProperties.Handles(FigureNumber).Tag))
            FigureNumber = FigureNumber;
            break;
        end
    end
    
    if(isnan(FigureNumber))
        MessagePanel('Unknown Volume Selection','Unknown Volume Selection');
        return;
    end
    
    %Update the current Details
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).Zoom = str2double(src.String{src.Value}(2:end));
    
    %Update the figures
    ChangeDisplayPosition(FigureNumber);
    
end

function [] = VolumeColourMapPopupCallback(src,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    %Work out what figure has been used to call this function
    FigureNumber = nan;
    for FigureNumber = 1:size(MainMenu.UserData.TwoDMenu.GlobalProperties.Handles,2)
        if(strcmp(src.Parent.Tag,MainMenu.UserData.TwoDMenu.GlobalProperties.Handles(FigureNumber).Tag))
            FigureNumber = FigureNumber;
            break;
        end
    end
    
    if(isnan(FigureNumber))
        MessagePanel('Unknown Volume Selection','Unknown Volume Selection');
        return;
    end
    
    %Update the current Details
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).ColourMap = src.String{src.Value};
    
    %Update the figures
    ChangeDisplayPosition(FigureNumber);
    
end

function [] = VolumeSelectionPopupCallback(src,~)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    %Work out what figure has been used to call this function
    %Instantiation: sprintf('VolumeSelectionPopUp(%i)',FigureNumber)
    FigureNumber = str2double(src.Tag(22:end-1));
    VolumeNumber = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeSelectionPopUp.Value;

    %Load the Data that has been selected
    LoadDisplayVolume(FigureNumber, VolumeNumber); 
    
    %Display Something
    CreateDisplayAxes(FigureNumber);
    
    %Uncheck all overlays
    [MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,:).Visible] = deal(false);  

    %Delete OverlayAxes
    delete([MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,:).AxialAxes]);
    delete([MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,:).CoronalAxes]);
    delete([MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,:).SagittalAxes]);
    
    %Remove crosshair if available
    %MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiAddCrossHairCheckBox.Value = 0;      
    %delete([MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CrossHairAxialAxes]);
    %delete([MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CrossHairCoronalAxes]);
    %delete([MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CrossHairSagittalAxes]);
    
    %Remove ROIs if available
    if(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiAddROIToolsCheckBox.Value)
        delete([MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).ROIAxialAxes]);
        delete([MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).ROICoronalAxes]);
        delete([MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).ROISagittalAxes]);
        CreateROIAxes(FigureNumber);
    end
    
    %Display an image so that it isn't blank
    ChangeDisplayPosition(FigureNumber);
    
    %Update the possible ROIs
    UpdateROIList(FigureNumber, VolumeNumber);

end

function [] = OverlayOptionsVisible(FigureNumber)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    VolumeNumber = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlaySelectionPopUp.Value;
    
    %%%%%%%%%%%%%%%%%%%%%%%
    % ColourMap %%%%%%%%%%%
    ColourMapIDX = find(strcmp(MainMenu.UserData.TwoDMenu.GlobalProperties.ColourMaps,MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).ColourMap));
    if(isempty(ColourMapIDX))
        ColourMapIDX = 8;
        MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).ColourMap = MainMenu.UserData.TwoDMenu.GlobalProperties.ColourMaps{ColourMapIDX};
    end
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayColourMapPopUp.Value = ColourMapIDX;
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayColourMapPopUp.Visible = true;
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayColourMapText.Visible = true;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Overlay RANGE SLIDER %%%%%%%%
    uiOverlayRangeSlider = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayRangeSlider;
    
    %Check that we know the Range and display range
    if( any(isnan(MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).Range)) || isempty(MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).Range) )
        MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).Range = GetVolumeRange(MainMenu.UserData.SubjectStructure.Volumes(VolumeNumber).FileAddress);
    end
    if( any(isnan(MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).DisplayRange)) || isempty(MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).DisplayRange) )
        MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).DisplayRange = MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).Range;
    end
    
    %
    %MULTIPLY = 10;
    %L = MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).Range(1);
    %H = MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).Range(2);

    %uiOverlayRangeSlider.setLabelTable({1,'1'})
    
    %Update Maximums
    uiOverlayRangeSlider.setMinimum(MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).Range(1));
    uiOverlayRangeSlider.setMaximum(MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).Range(2));
    %
    %Current Values
    uiOverlayRangeSlider.setLowValue(MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).DisplayRange(1));
    uiOverlayRangeSlider.setHighValue(MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).DisplayRange(2));
    %
    %UpdateTicks
    uiOverlayRangeSlider.setMajorTickSpacing(round(diff(MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).Range)./4));
    uiOverlayRangeSlider.setLabelTable(uiOverlayRangeSlider.createStandardLabels(diff(MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).Range)./4));
    uiOverlayRangeSlider.setMinorTickSpacing(round(diff(MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).Range)./16));
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayRangeSlider = uiOverlayRangeSlider;
    %
    %Set Visible
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayRangeSliderContainer.Visible = true;
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayRangeSlider.setVisible(true);
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayRangeSliderText.Visible = true;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Opacity SLIDER %%%%%%%%%%%%%%
    if(isempty(MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).Opacity))
        MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).Opacity = 50;
    end
    
    %Update Current Value
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayOpacitySlider.setValue(MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).Opacity);

    %Set Visible
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayOpacitySliderContainer.Visible = true;
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayOpacitySlider.setVisible(true);
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayOpacitySliderText.Visible = true;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

function [] = OverlayOptionsInvisible(FigureNumber)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    OverlayNumber = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlaySelectionPopUp.Value;
    
    %%%%%%%%%%%%%%%%%%%%%%%
    % ColourMap %%%%%%%%%%%
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayColourMapPopUp.Visible = false;
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayColourMapText.Visible = false;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %RANGE SLIDER %%%%%%%%%%%%%%%%
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayRangeSlider.setVisible(false);
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayRangeSliderText.Visible = false;
    
  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Opacity SLIDER %%%%%%%%%%%%%%
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayOpacitySlider.setVisible(false);
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayOpacitySliderText.Visible = false;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Remove the Axes
    delete(MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,OverlayNumber).AxialAxes);
    delete(MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,OverlayNumber).CoronalAxes);
    delete(MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,OverlayNumber).SagittalAxes);
end

function [] = LoadOverlayVolume(FigureNumber, VolumeNumber)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    
    %Load the volume information
    MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).VolumeStructure = spm_vol(MainMenu.UserData.SubjectStructure.Volumes(VolumeNumber).FileAddress);
    MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).VolumeStructure.premul = eye(4);
   
    %Apply the Overlay
    ChangeDisplayPosition(FigureNumber);
    
end

function [] = LoadDisplayVolume(FigureNumber, VolumeNumber)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    
    %Load the volume information
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).VolumeStructure = spm_vol(MainMenu.UserData.SubjectStructure.Volumes(VolumeNumber).FileAddress);
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).VolumeStructure.premul = eye(4);
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).BoundingBox = spm_get_bbox(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).VolumeStructure);
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).WorldDimensions = round(diff(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).BoundingBox)'+1);
    
    %Zoom Settings
    %MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeZoomPopup.Value = 1;
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).Zoom = 1;
    
    %Range Settings
    %MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeRangeSelectorPopUp.Value = 1;  %Set to automatic
    %MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeRangeSlider.setVisible(0);     %Hide the RangeSlider
    %MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeRangeSliderText.Visible = 0;   %Hide the text above the slider
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).Range = GetVolumeRange(MainMenu.UserData.SubjectStructure.Volumes(VolumeNumber).FileAddress);                     %Remove the range details
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).DisplayRange = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).Range;            
                
    %Update the Global Details
    UpdateGlobalDetails();
    
    %CreateAxes
    CreateDisplayAxes(FigureNumber);
    
    %Display an image so that it isn't blank
    ChangeDisplayPosition(FigureNumber);
    
end

function [] = CreateROIAxes(FigureNumber)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; %
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Get the Global Bounding box so that multiple images can be displayed
    WorldDimensions = MainMenu.UserData.TwoDMenu.GlobalProperties.WorldDimensions;
    %WorldDimensions = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).WorldDimensions;

    %Based on the Volume cut up the axes space accordingly
    Gutter = MainMenu.UserData.TwoDMenu.AxesGutter;
    AxesArea = MainMenu.UserData.TwoDMenu.AxesArea;
    AxesArea(3:4) = AxesArea(3:4) - 3*Gutter;
    
    Width = WorldDimensions(1) + WorldDimensions(2); %X + Y
    Height = WorldDimensions(2) + WorldDimensions(3); %Y + Z

    %Modulate the Width and Hight so that only 1 is at maximum and the other
    %is at its (althought not maximum) largest
    WidthMod = AxesArea(3)./Width;
    HeightMod = AxesArea(4)./Height;

    if(WidthMod<=HeightMod)
        %Wider then tall
        DimensionsMod = WorldDimensions.*WidthMod;

    else
        %Taller then high
        DimensionsMod = WorldDimensions.*HeightMod;

    end
    
    %Offsets
    XOffset = [Gutter, Gutter+DimensionsMod(1)+Gutter] + AxesArea(1);
    YOffset = [Gutter, Gutter+DimensionsMod(2)+Gutter] + AxesArea(2);
    
    %%%%%%%%%%%%%%%%%%%
    % Create the Axes %
    %%%%%%%%%%%%%%%%%%%
    %Coronal (Across X,Z Dim) Y shifts anteriorly/posteriorly
    if(ishandle(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).ROICoronalAxes)); delete(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).ROICoronalAxes); end
    ROICoronalAxes = axes('units','pixel','position',[XOffset(1) YOffset(2) DimensionsMod(1) DimensionsMod(3)],'Visible','off','Hittest','off','XTick',[],'YTick',[],'Tag',sprintf('ROICoronalAxes(%i)',FigureNumber),'Parent',MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).Handle);
    hold(ROICoronalAxes,'on');
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).ROICoronalAxes = ROICoronalAxes;
    
    %Sagittal (Across Y,Z Dim) X shifts across the face
    if(ishandle(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).ROISagittalAxes)); delete(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).ROISagittalAxes); end
    ROISagittalAxes = axes('units','pixel','position',[XOffset(2) YOffset(2) DimensionsMod(2) DimensionsMod(3)],'Visible','off','Hittest','off','XTick',[],'YTick',[],'XDir','reverse','Tag',sprintf('ROISagittalAxes(%i)',FigureNumber),'Parent',MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).Handle);
    hold(ROISagittalAxes,'on');
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).ROISagittalAxes = ROISagittalAxes;
    
    %Axial (Images from the X,Y plane) Shifts in Z move up/Down the brain (Superiorly)
    if(ishandle(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).ROIAxialAxes)); delete(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).ROIAxialAxes); end
    ROIAxialAxes = axes('units','pixel','position',[XOffset(1) YOffset(1) DimensionsMod(1) DimensionsMod(2)],'Visible','off','Hittest','off','XTick',[],'YTick',[],'Tag',sprintf('ROIAxialAxes(%i)',FigureNumber),'Parent',MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).Handle);
    hold(ROIAxialAxes,'on');
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).ROIAxialAxes = ROIAxialAxes;
        
end

function [] = CreateCrossHairAxes(FigureNumber)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; %
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Get the Global Bounding box so that multiple images can be displayed
    WorldDimensions = MainMenu.UserData.TwoDMenu.GlobalProperties.WorldDimensions;
    %WorldDimensions = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).WorldDimensions;

    %Based on the Volume cut up the axes space accordingly
    Gutter = MainMenu.UserData.TwoDMenu.AxesGutter;
    AxesArea = MainMenu.UserData.TwoDMenu.AxesArea;
    AxesArea(3:4) = AxesArea(3:4) - 3*Gutter;
    
    Width = WorldDimensions(1) + WorldDimensions(2); %X + Y
    Height = WorldDimensions(2) + WorldDimensions(3); %Y + Z

    %Modulate the Width and Hight so that only 1 is at maximum and the other
    %is at its (althought not maximum) largest
    WidthMod = AxesArea(3)./Width;
    HeightMod = AxesArea(4)./Height;

    if(WidthMod<=HeightMod)
        %Wider then tall
        DimensionsMod = WorldDimensions.*WidthMod;

    else
        %Taller then high
        DimensionsMod = WorldDimensions.*HeightMod;

    end
    
    %Offsets
    XOffset = [Gutter, Gutter+DimensionsMod(1)+Gutter] + AxesArea(1);
    YOffset = [Gutter, Gutter+DimensionsMod(2)+Gutter] + AxesArea(2);
    
    %%%%%%%%%%%%%%%%%%%
    % Create the Axes %
    %%%%%%%%%%%%%%%%%%%
    %Coronal (Across X,Z Dim) Y shifts anteriorly/posteriorly
    if(ishandle(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CrossHairCoronalAxes)); delete(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CrossHairCoronalAxes); end
    CrossHairCoronalAxes = axes('units','pixel','position',[XOffset(1) YOffset(2) DimensionsMod(1) DimensionsMod(3)],'Visible','off','Hittest','off','XTick',[],'YTick',[],'Tag',sprintf('CrossHairCoronalAxes(%i)',FigureNumber),'Parent',MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).Handle);
    hold(CrossHairCoronalAxes,'on');
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CrossHairCoronalAxes = CrossHairCoronalAxes;
    
    %Sagittal (Across Y,Z Dim) X shifts across the face
    if(ishandle(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CrossHairSagittalAxes)); delete(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CrossHairSagittalAxes); end
    CrossHairSagittalAxes = axes('units','pixel','position',[XOffset(2) YOffset(2) DimensionsMod(2) DimensionsMod(3)],'Visible','off','Hittest','off','XTick',[],'YTick',[],'XDir','reverse','Tag',sprintf('CrossHairSagittalAxes(%i)',FigureNumber),'Parent',MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).Handle);
    hold(CrossHairSagittalAxes,'on');
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CrossHairSagittalAxes = CrossHairSagittalAxes;
    
    %Axial (Images from the X,Y plane) Shifts in Z move up/Down the brain (Superiorly)
    if(ishandle(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CrossHairAxialAxes)); delete(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CrossHairAxialAxes); end
    CrossHairAxialAxes = axes('units','pixel','position',[XOffset(1) YOffset(1) DimensionsMod(1) DimensionsMod(2)],'Visible','off','Hittest','off','XTick',[],'YTick',[],'Tag',sprintf('CrossHairAxialAxes(%i)',FigureNumber),'Parent',MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).Handle);
    hold(CrossHairAxialAxes,'on');
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CrossHairAxialAxes = CrossHairAxialAxes;
        
end

function [] = CreateOverlayAxes(FigureNumber,VolumeNumber)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; %
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Get the Global Bounding box so that multiple images can be displayed
    WorldDimensions = MainMenu.UserData.TwoDMenu.GlobalProperties.WorldDimensions;
    %WorldDimensions = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).WorldDimensions;

    %Based on the Volume cut up the axes space accordingly
    Gutter = MainMenu.UserData.TwoDMenu.AxesGutter;
    AxesArea = MainMenu.UserData.TwoDMenu.AxesArea;
    AxesArea(3:4) = AxesArea(3:4) - 3*Gutter;
    
    Width = WorldDimensions(1) + WorldDimensions(2); %X + Y
    Height = WorldDimensions(2) + WorldDimensions(3); %Y + Z

    %Modulate the Width and Hight so that only 1 is at maximum and the other
    %is at its (althought not maximum) largest
    WidthMod = AxesArea(3)./Width;
    HeightMod = AxesArea(4)./Height;

    if(WidthMod<=HeightMod)
        %Wider then tall
        DimensionsMod = WorldDimensions.*WidthMod;

    else
        %Taller then high
        DimensionsMod = WorldDimensions.*HeightMod;

    end
    
    %Offsets
    XOffset = [Gutter, Gutter+DimensionsMod(1)+Gutter] + AxesArea(1);
    YOffset = [Gutter, Gutter+DimensionsMod(2)+Gutter] + AxesArea(2);
    
    %%%%%%%%%%%%%%%%%%%
    % Create the Axes %
    %%%%%%%%%%%%%%%%%%%
    
    %Coronal (Across X,Z Dim) Y shifts anteriorly/posteriorly
    if(ishandle(MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).CoronalAxes)); delete(MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).CoronalAxes); end
    CoronalAxes = axes('units','pixel','position',[XOffset(1) YOffset(2) DimensionsMod(1) DimensionsMod(3)],'Visible','off','Hittest','off','Tag',sprintf('CoronalAxes(%i)',FigureNumber),'XTick',[],'YTick',[],'Parent',MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).Handle);
    MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).CoronalAxes = CoronalAxes;
    
    %Sagittal (Across Y,Z Dim) X shifts across the face
    if(ishandle(MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).SagittalAxes)); delete(MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).SagittalAxes); end
    SagittalAxes = axes('units','pixel','position',[XOffset(2) YOffset(2) DimensionsMod(2) DimensionsMod(3)],'Visible','off','Hittest','off','Tag',sprintf('SagittalAxes(%i)',FigureNumber),'XTick',[],'YTick',[],'Parent',MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).Handle);
    MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).SagittalAxes = SagittalAxes;
    
    %Axial (Images from the X,Y plane) Shifts in Z move up/Down the brain (Superiorly)
    if(ishandle(MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).AxialAxes)); delete(MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).AxialAxes); end
    AxialAxes = axes('units','pixel','position',[XOffset(1) YOffset(1) DimensionsMod(1) DimensionsMod(2)],'Visible','off','Hittest','off','Tag',sprintf('AxialAxes(%i)',FigureNumber),'XTick',[],'YTick',[],'Parent',MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).Handle);
    MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,VolumeNumber).AxialAxes = AxialAxes;
        
end

function [] = CreateDisplayAxes(FigureNumber)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; %
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Get the Global Bounding box so that multiple images can be displayed
    WorldDimensions = MainMenu.UserData.TwoDMenu.GlobalProperties.WorldDimensions;
    %WorldDimensions = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).WorldDimensions;

    %Based on the Volume cut up the axes space accordingly
    Gutter = MainMenu.UserData.TwoDMenu.AxesGutter;
    AxesArea = MainMenu.UserData.TwoDMenu.AxesArea;
    AxesArea(3:4) = AxesArea(3:4) - 3*Gutter;
    
    Width = WorldDimensions(1) + WorldDimensions(2); %X + Y
    Height = WorldDimensions(2) + WorldDimensions(3); %Y + Z

    %Modulate the Width and Hight so that only 1 is at maximum and the other
    %is at its (althought not maximum) largest
    WidthMod = AxesArea(3)./Width;
    HeightMod = AxesArea(4)./Height;

    if(WidthMod<=HeightMod)
        %Wider then tall
        DimensionsMod = WorldDimensions.*WidthMod;

    else
        %Taller then high
        DimensionsMod = WorldDimensions.*HeightMod;

    end
    
    %Offsets
    XOffset = [Gutter, Gutter+DimensionsMod(1)+Gutter] + AxesArea(1);
    YOffset = [Gutter, Gutter+DimensionsMod(2)+Gutter] + AxesArea(2);
    
    %%%%%%%%%%%%%%%%%%%
    % Create the Axes %
    %%%%%%%%%%%%%%%%%%%
    
    %Coronal (Across X,Z Dim) Y shifts anteriorly/posteriorly
    if(ishandle(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CoronalAxes)); delete(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CoronalAxes); end
    CoronalAxes = axes('units','pixel','position',[XOffset(1) YOffset(2) DimensionsMod(1) DimensionsMod(3)],'Tag',sprintf('CoronalAxes(%i)',FigureNumber),'XTick',[],'YTick',[],'ButtonDownFcn',@CollectClick,'Parent',MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).Handle);
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CoronalAxes = CoronalAxes;
    
    %Sagittal (Across Y,Z Dim) X shifts across the face
    if(ishandle(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).SagittalAxes)); delete(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).SagittalAxes); end
    SagittalAxes = axes('units','pixel','position',[XOffset(2) YOffset(2) DimensionsMod(2) DimensionsMod(3)],'Tag',sprintf('SagittalAxes(%i)',FigureNumber),'XTick',[],'YTick',[],'ButtonDownFcn',@CollectClick,'Parent',MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).Handle);
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).SagittalAxes = SagittalAxes;
    
    %Axial (Images from the X,Y plane) Shifts in Z move up/Down the brain (Superiorly)
    if(ishandle(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).AxialAxes)); delete(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).AxialAxes); end
    AxialAxes = axes('units','pixel','position',[XOffset(1) YOffset(1) DimensionsMod(1) DimensionsMod(2)],'Tag',sprintf('AxialAxes(%i)',FigureNumber),'XTick',[],'YTick',[],'ButtonDownFcn',@CollectClick,'Parent',MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).Handle);
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).AxialAxes = AxialAxes;
        
end

function [] = CollectClick(src,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; %
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Find the axes
    FigureNumbers = arrayfun(@(x) isvalid(x.Handle), MainMenu.UserData.TwoDMenu.Volumes);
    AxialAxes = [MainMenu.UserData.TwoDMenu.Volumes(FigureNumbers).AxialAxes];
    CoronalAxes = [MainMenu.UserData.TwoDMenu.Volumes(FigureNumbers).CoronalAxes];
    SagittalAxes = [MainMenu.UserData.TwoDMenu.Volumes(FigureNumbers).SagittalAxes];
    
    
    %Preallocation
    CurrentPoint = nan(1,3);
    
    %Work out what Axes has been used to call this function
    for FigureNumber = 1:size(AxialAxes,2)
        if(strcmp(src.Tag, AxialAxes(FigureNumber).Tag))        %Check if an Axial axes called
            CurrentPoint(1:2) = AxialAxes(FigureNumber).CurrentPoint(1,1:2); break;
        elseif(strcmp(src.Tag, CoronalAxes(FigureNumber).Tag))  %Check if an Coronal axes called
            CurrentPoint([1 3]) = CoronalAxes(FigureNumber).CurrentPoint(1,1:2); break;
        elseif(strcmp(src.Tag, SagittalAxes(FigureNumber).Tag)) %Check if an Sagittal axes called
            CurrentPoint([2 3]) = SagittalAxes(FigureNumber).CurrentPoint(1,1:2); break;
        end
    end
    
    if(all(isnan(CurrentPoint)))
        MessagePanel('Axes unknown','Failure to establish the axes that called callback');
        return;
    end
    
    
    if(MainMenu.UserData.TwoDMenu.GlobalProperties.GlobalLink)
        %Global adjustment
       CurrentPoint(isnan(CurrentPoint)) = MainMenu.UserData.TwoDMenu.GlobalProperties.CurrentPoint(isnan(CurrentPoint));
       MainMenu.UserData.TwoDMenu.GlobalProperties.CurrentPoint = CurrentPoint;
       MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CurrentPoint = CurrentPoint;
    else
        %Local Adjustment
       CurrentPoint(isnan(CurrentPoint)) = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CurrentPoint(isnan(CurrentPoint));
       MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CurrentPoint = CurrentPoint;
    end
    
    %Update ROI Information
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIXYZ.String = sprintf('[%3.1f, %3.1f, %3.1f]',CurrentPoint(1),CurrentPoint(2),CurrentPoint(3));
    
    %Perform update
    ChangeDisplayPosition(FigureNumber);
end

function [] = UpdateGlobalDetails()

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; %
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    %Identify which displayfigures are available
    FigureNumbers = arrayfun(@(x) isvalid(x.Handle), MainMenu.UserData.TwoDMenu.Volumes);%FigureNumber = arrayfun(@(x) ishandle(x.Handle), MainMenu.UserData.TwoDMenu.Volumes)
    
    %Update the Global referencelist
    MainMenu.UserData.TwoDMenu.GlobalProperties.Handles = [MainMenu.UserData.TwoDMenu.Volumes(FigureNumbers).Handle];
    
    %Collect the maximum bounding box
    bb = cat(3,MainMenu.UserData.TwoDMenu.Volumes(FigureNumbers).BoundingBox);
    BoundingBox(1,1:3) = min(bb(1,:,:),[],3);
    BoundingBox(2,1:3) = max(bb(2,:,:),[],3);
    MainMenu.UserData.TwoDMenu.GlobalProperties.BoundingBox = BoundingBox;

    %Collect the WorldDimensions
    MainMenu.UserData.TwoDMenu.GlobalProperties.WorldDimensions = round(diff(BoundingBox)'+1);
end

function [] = ChangeDisplayPosition(FigureNumbers)


    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    %If all volumes are displayed with a worldspace link
    if(MainMenu.UserData.TwoDMenu.GlobalProperties.GlobalLink)
        FigureNumbers = find(arrayfun(@(x) isvalid(x.Handle), MainMenu.UserData.TwoDMenu.Volumes));
        [MainMenu.UserData.TwoDMenu.Volumes(FigureNumbers).CurrentPoint] = deal(MainMenu.UserData.TwoDMenu.GlobalProperties.CurrentPoint);
    end
    
    %Display the Volumes
    for FigureNumber = FigureNumbers
    
        %Find the axes
        AxialAxes = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).AxialAxes;
        CoronalAxes = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CoronalAxes;
        SagittalAxes = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).SagittalAxes;

    
        %Error checking
        if(~isvalid(AxialAxes) || ~isvalid(CoronalAxes) || ~isvalid(SagittalAxes))
            CreateDisplayAxes(FigureNumber);
        end
    
        %Update the Known Current point
        %MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CurrentPoint = CurrentPoint;
        
        %Obtain CurrentPoint
        CurrentPoint = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CurrentPoint;
        
        %Work out the maximum bounding box of all images considered for viewing
        GlobalBoundingBox = MainMenu.UserData.TwoDMenu.GlobalProperties.BoundingBox;

        %Get the number of slices in each dimension
        Dimensions = MainMenu.UserData.TwoDMenu.GlobalProperties.WorldDimensions;
        VolumeStructure = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).VolumeStructure;

        %Interpolation Method
        InterpolationMethod = 1; %Trilinear

        %World or Voxel space scaling 
        Space = eye(4);         %World Space
        %is   = inv(Space);      %idk
        %mmcentre     = mean(Space*[BoundingBox';1 1],2)';
        %Centre    = mmcentre(1:3);

        %Update depending on the BoundingBox
        Dimensions = ceil(Dimensions./MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).Zoom);
        BoundingBox = CurrentPoint + (GlobalBoundingBox./MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).Zoom);
        
        %Make sure that the boundingbox is fixed from escaping the global maximum
        for d = 1:3
            %Less than Global Axes
            if(BoundingBox(1,d) < GlobalBoundingBox(1,d))
                BoundingBox(2,d) = BoundingBox(2,d) + GlobalBoundingBox(1,d)-BoundingBox(1,d);
                BoundingBox(1,d) = GlobalBoundingBox(1,d);
            end
            
            %Greater than Global Axes
            if(BoundingBox(2,d) > GlobalBoundingBox(2,d))
                BoundingBox(1,d) = BoundingBox(1,d) + GlobalBoundingBox(2,d)-BoundingBox(2,d);
                BoundingBox(2,d) = GlobalBoundingBox(2,d);
            end
        end
        
        
        M = Space\VolumeStructure.premul*VolumeStructure.mat;
        %Transverse (Axial)
        TM0 = [ 1 0 0 -BoundingBox(1,1)+1
                0 1 0 -BoundingBox(1,2)+1
                0 0 1 -CurrentPoint(3)
                0 0 0 1];
        TM = inv(TM0*M);
        TD = Dimensions([1 2]);
        %Coronal
        CM0 = [ 1 0 0 -BoundingBox(1,1)+1
                0 0 1 -BoundingBox(1,3)+1
                0 1 0 -CurrentPoint(2)
                0 0 0 1];
        CM = inv(CM0*M);
        CD = Dimensions([1 3]);
        %Sagittal
        SM0 = [ 0 -1 0 +BoundingBox(2,2)+1
                0  0 1 -BoundingBox(1,3)+1
                1  0 0 -CurrentPoint(1)
                0  0 0 1];
        SM = inv(SM0*M);
        SD = Dimensions([2 3]);

        
        
        %Cut Images
        imgt = spm_slice_vol(VolumeStructure,TM,TD,InterpolationMethod)';
        imgc = spm_slice_vol(VolumeStructure,CM,CD,InterpolationMethod)';
        imgs = spm_slice_vol(VolumeStructure,SM,SD,InterpolationMethod)';

        XTick = linspace(BoundingBox(1,1),BoundingBox(2,1),size(imgt,1));
        YTick = linspace(BoundingBox(1,2),BoundingBox(2,2),size(imgt,2));
        ZTick = linspace(BoundingBox(1,3),BoundingBox(2,3),size(imgc,2));
        
        %display Images
        ia = imagesc(XTick,YTick,imgt,'Parent',AxialAxes);                
        ic = imagesc(XTick,ZTick,imgc,'Parent',CoronalAxes);      
        is = imagesc(fliplr(YTick),ZTick,imgs,'Parent',SagittalAxes);  

        %Check for Manual Range calibration
        if(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiAdvSettingsCheckBox.Value)   %Manual Range
            caxis(AxialAxes, MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).DisplayRange);
            caxis(CoronalAxes, MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).DisplayRange);
            caxis(SagittalAxes, MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).DisplayRange);
        end
        
        
        %Update Colourmap
        colormap(AxialAxes,MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).ColourMap);
        colormap(CoronalAxes,MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).ColourMap);
        colormap(SagittalAxes,MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).ColourMap);
        
        %Correct for the YAxis
        AxialAxes.YDir = 'normal';
        CoronalAxes.YDir = 'normal';
        SagittalAxes.YDir = 'normal';
        SagittalAxes.XDir = 'reverse';
        
        %Remove the Ticks
        AxialAxes.XTick = [];AxialAxes.YTick = [];
        CoronalAxes.XTick = [];  CoronalAxes.YTick = [];
        SagittalAxes.XTick = []; SagittalAxes.YTick = [];
        
        %Pass control back to the axes
        ia.HitTest = 'off';
        ic.HitTest = 'off';
        is.HitTest = 'off';
        ia.PickableParts = 'none';
        ic.PickableParts = 'none';
        is.PickableParts = 'none';

        %Restore the Callbacks
        AxialAxes.ButtonDownFcn = @CollectClick;
        CoronalAxes.ButtonDownFcn = @CollectClick;
        SagittalAxes.ButtonDownFcn = @CollectClick;

        %Restore Tags
        AxialAxes.Tag = sprintf('AxialAxes(%i)',FigureNumber);
        CoronalAxes.Tag = sprintf('CoronalAxes(%i)',FigureNumber);
        SagittalAxes.Tag = sprintf('SagittalAxes(%i)',FigureNumber);
    
    
        %%%%%%%%%%%%
        % OVERLAYS %
        %%%%%%%%%%%%
        if(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiAddOverlaysCheckBox.Value)
            if(any([MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,:).Visible]))

                %Overlays to display
                OverlayVolumes = find([MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,:).Visible]);

                for OverlayNumber = OverlayVolumes

                    %Find the Overlay axes
                    AxialAxes = MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,OverlayNumber).AxialAxes;
                    CoronalAxes = MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,OverlayNumber).CoronalAxes;
                    SagittalAxes = MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,OverlayNumber).SagittalAxes;

                    %Error checking
                    if(~isvalid(AxialAxes) || ~isvalid(CoronalAxes) || ~isvalid(SagittalAxes))
                        CreateOverlayAxes(FigureNumber,OverlayNumber);
                    end

                    %Prepare the Data to display
                    OverlayVolumeStructure = MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,OverlayNumber).VolumeStructure;
                    M = Space\OverlayVolumeStructure.premul*OverlayVolumeStructure.mat;

                    %Transverse (Axial)
                    TM0 = [ 1 0 0 -BoundingBox(1,1)+1
                        0 1 0 -BoundingBox(1,2)+1
                        0 0 1 -CurrentPoint(3)
                        0 0 0 1];
                    TM = inv(TM0*M);
                    TD = Dimensions([1 2]);
                    %Coronal
                    CM0 = [ 1 0 0 -BoundingBox(1,1)+1
                        0 0 1 -BoundingBox(1,3)+1
                        0 1 0 -CurrentPoint(2)
                        0 0 0 1];
                    CM = inv(CM0*M);
                    CD = Dimensions([1 3]);
                    %Sagittal
                    SM0 = [ 0 -1 0 +BoundingBox(2,2)+1
                        0  0 1 -BoundingBox(1,3)+1
                        1  0 0 -CurrentPoint(1)
                        0  0 0 1];
                    SM = inv(SM0*M);
                    SD = Dimensions([2 3]);


                    %Cut Images
                    imgt = spm_slice_vol(OverlayVolumeStructure,TM,TD,InterpolationMethod)';
                    imgc = spm_slice_vol(OverlayVolumeStructure,CM,CD,InterpolationMethod)';
                    imgs = spm_slice_vol(OverlayVolumeStructure,SM,SD,InterpolationMethod)';

                    %Axis Ticks
                    XTick = linspace(BoundingBox(1,1),BoundingBox(2,1),size(imgt,1));
                    YTick = linspace(BoundingBox(1,2),BoundingBox(2,2),size(imgt,2));
                    ZTick = linspace(BoundingBox(1,3),BoundingBox(2,3),size(imgc,2));

                    %Display Overlays
                    %AlphaLevel = MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,OverlayNumber).Opacity./100;
                    if(~all ( MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,OverlayNumber).DisplayRange == MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,OverlayNumber).Range ))
                        %The DisplayRange is not the same as the Total Range
                        AlphaMapt = zeros(size(imgt)); AlphaMapt(imgt>MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,OverlayNumber).DisplayRange(1) & imgt<MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,OverlayNumber).DisplayRange(2)) = MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,OverlayNumber).Opacity./100;
                        AlphaMapc = zeros(size(imgc)); AlphaMapc(imgc>MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,OverlayNumber).DisplayRange(1) & imgc<MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,OverlayNumber).DisplayRange(2)) = MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,OverlayNumber).Opacity./100;
                        AlphaMaps = zeros(size(imgs)); AlphaMaps(imgs>MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,OverlayNumber).DisplayRange(1) & imgs<MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,OverlayNumber).DisplayRange(2)) = MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,OverlayNumber).Opacity./100;
                    else
                        AlphaMapt = MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,OverlayNumber).Opacity./100;
                        AlphaMapc = MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,OverlayNumber).Opacity./100;
                        AlphaMaps = MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,OverlayNumber).Opacity./100;
                    end


                    oa = imagesc(XTick,YTick,imgt,'Parent',AxialAxes);                
                    oc = imagesc(XTick,ZTick,imgc,'Parent',CoronalAxes);      
                    os = imagesc(fliplr(YTick),ZTick,imgs,'Parent',SagittalAxes);  

                    AxialAxes.Visible = 'off';
                    CoronalAxes.Visible = 'off';
                    SagittalAxes.Visible = 'off';

                    oa.AlphaData = AlphaMapt;
                    oc.AlphaData = AlphaMapc;
                    os.AlphaData = AlphaMaps;

                    %Correct for the YAxis
                    AxialAxes.YDir = 'normal';
                    CoronalAxes.YDir = 'normal';
                    SagittalAxes.YDir = 'normal';
                    SagittalAxes.XDir = 'reverse';

                    %Manual Range calibration
                    caxis(AxialAxes, MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,OverlayNumber).DisplayRange);
                    caxis(CoronalAxes, MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,OverlayNumber).DisplayRange);
                    caxis(SagittalAxes, MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,OverlayNumber).DisplayRange);

                    %Update Colourmap
                    colormap(AxialAxes,MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,OverlayNumber).ColourMap);
                    colormap(CoronalAxes,MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,OverlayNumber).ColourMap);
                    colormap(SagittalAxes,MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,OverlayNumber).ColourMap);

                    %Remove the Ticks
                    AxialAxes.XTick = [];AxialAxes.YTick = [];
                    CoronalAxes.XTick = [];  CoronalAxes.YTick = [];
                    SagittalAxes.XTick = []; SagittalAxes.YTick = [];
                    
                    %Restore Tags
                    AxialAxes.Tag = sprintf('Overlay(%i)AxialAxes(%i)',OverlayNumber,FigureNumber);
                    CoronalAxes.Tag = sprintf('Overlay(%i)CoronalAxes(%i)',OverlayNumber,FigureNumber);
                    SagittalAxes.Tag = sprintf('Overlay(%i)SagittalAxes(%i)',OverlayNumber,FigureNumber);

                    %Pass control back to the axes
                    ia.HitTest = 'off';
                    ic.HitTest = 'off';
                    is.HitTest = 'off';
                    AxialAxes.HitTest = 'off';
                    CoronalAxes.HitTest = 'off';
                    SagittalAxes.HitTest = 'off';
                    ia.PickableParts = 'none';
                    ic.PickableParts = 'none';
                    is.PickableParts = 'none';
                    AxialAxes.PickableParts = 'none';
                    CoronalAxes.PickableParts = 'none';
                    SagittalAxes.PickableParts = 'none';

                end
            end
        end
        
        %%%%%%%%%%%%%
        %   ROIs    %
        %%%%%%%%%%%%%
        if(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIVisibleCheckbox.Value && MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiAddROIToolsCheckBox.Value)
            
            %Find the ROI axes
            ROIAxialAxes = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).ROIAxialAxes;
            ROICoronalAxes = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).ROICoronalAxes;
            ROISagittalAxes = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).ROISagittalAxes;
            
            %Set the Axes
            ROIAxialAxes.XLim = [BoundingBox(1,1), BoundingBox(2,1)];
            ROIAxialAxes.YLim = [BoundingBox(1,2), BoundingBox(2,2)];
            ROICoronalAxes.XLim = [BoundingBox(1,1), BoundingBox(2,1)];
            ROICoronalAxes.YLim = [BoundingBox(1,3), BoundingBox(2,3)];
            ROISagittalAxes.XLim = [BoundingBox(1,2), BoundingBox(2,2)];
            ROISagittalAxes.YLim = [BoundingBox(1,3), BoundingBox(2,3)];
            
            %Clear any old itmes on the axes
            cla(ROIAxialAxes);hold(ROIAxialAxes,'on');
            cla(ROISagittalAxes);hold(ROISagittalAxes,'on');
            cla(ROICoronalAxes);hold(ROICoronalAxes,'on');
            
            %Draw blobs if they are in visibility
            ROISize = round(str2double(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROISize.String),2)./2;
            XLimits = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CurrentPoint(1) + [ -ROISize, ROISize];
            YLimits = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CurrentPoint(2) + [ -ROISize, ROISize];
            ZLimits = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CurrentPoint(3) + [ -ROISize, ROISize];
            
            VolumeNumber = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeSelectionPopUp.Value;
            ROIs = vertcat(MainMenu.UserData.SubjectStructure.Volumes(VolumeNumber).ROIs.XYZ);
            ROIColour = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIColourPopup.String{MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiROIColourPopup.Value};
            
            %Make sure some ROIs are kept
            if(~isempty(ROIs))

                %Check the axial Views
                SagittalROIs = ROIs( [ROIs(:,1) < XLimits(2) & ROIs(:,1) > XLimits(1)], :);
                CoronalROIs = ROIs( [ROIs(:,2) < YLimits(2) & ROIs(:,2) > YLimits(1)], :);
                AxialROIs = ROIs( [ROIs(:,3) < ZLimits(2) & ROIs(:,3) > ZLimits(1)], :);

                if(~isempty(AxialROIs))
                    for R = 1:size(AxialROIs,1)
                        FilledCircle(AxialROIs(R,1), AxialROIs(R,2), ROISize, ROIColour, ROIAxialAxes);
                    end
                end

                if(~isempty(CoronalROIs))
                    for R = 1:size(CoronalROIs,1)
                        FilledCircle(CoronalROIs(R,1), CoronalROIs(R,3), ROISize, ROIColour, ROICoronalAxes);
                    end
                end

                if(~isempty(SagittalROIs))
                    for R = 1:size(SagittalROIs,1)
                        FilledCircle(SagittalROIs(R,2), SagittalROIs(R,3), ROISize, ROIColour, ROISagittalAxes);
                    end
                end
                
                
                %Make sure the axes are at Second Top (CrossHairs are top
                AxIDX = find( [MainMenu.UserData.TwoDMenu.GlobalProperties.Handles(FigureNumber).Children] == ROIAxialAxes);
                CoIDX = find( [MainMenu.UserData.TwoDMenu.GlobalProperties.Handles(FigureNumber).Children] == ROICoronalAxes);
                SaIDX = find( [MainMenu.UserData.TwoDMenu.GlobalProperties.Handles(FigureNumber).Children] == ROISagittalAxes);
                
                if(~any([isempty(AxIDX),isempty(CoIDX),isempty(SaIDX)])) %Check that we have axes
                    FirstAxes = find(arrayfun(@(x) strcmp(x.Type,'axes'), MainMenu.UserData.TwoDMenu.GlobalProperties.Handles(FigureNumber).Children),1);
                    NewOrder = [1:(FirstAxes-1), AxIDX, CoIDX, SaIDX, setdiff(FirstAxes:size(MainMenu.UserData.TwoDMenu.GlobalProperties.Handles(FigureNumber).Children,1),[AxIDX, SaIDX, CoIDX])];
                    MainMenu.UserData.TwoDMenu.GlobalProperties.Handles(FigureNumber).Children = MainMenu.UserData.TwoDMenu.GlobalProperties.Handles(FigureNumber).Children(NewOrder);
                end
                
            end
        end
        
        %%%%%%%%%%%%%%
        % Cross Hair %
        %%%%%%%%%%%%%%
        if(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiAddCrossHairCheckBox.Value)
            
            %Find the crosshair axes
            CrossHairAxialAxes = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CrossHairAxialAxes;
            CrossHairCoronalAxes = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CrossHairCoronalAxes;
            CrossHairSagittalAxes = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CrossHairSagittalAxes;
            
            %Set the Axes
            CrossHairAxialAxes.XLim = [BoundingBox(1,1), BoundingBox(2,1)];
            CrossHairAxialAxes.YLim = [BoundingBox(1,2), BoundingBox(2,2)];
            CrossHairCoronalAxes.XLim = [BoundingBox(1,1), BoundingBox(2,1)];
            CrossHairCoronalAxes.YLim = [BoundingBox(1,3), BoundingBox(2,3)];
            CrossHairSagittalAxes.XLim = [BoundingBox(1,2), BoundingBox(2,2)];
            CrossHairSagittalAxes.YLim = [BoundingBox(1,3), BoundingBox(2,3)];
            
            %Clear any old itmes on the axes
            cla(CrossHairAxialAxes);
            cla(CrossHairSagittalAxes);
            cla(CrossHairCoronalAxes);

            %Work out the size of the crosshair
            XLength = diff([BoundingBox(1,1), BoundingBox(2,1)])/32;
            YLength = diff([BoundingBox(1,2), BoundingBox(2,2)])/32;
            ZLength = diff([BoundingBox(1,3), BoundingBox(2,3)])/32;
            
            %plot a set of crosshairs
            %Axial
            plot([-XLength-XLength, -XLength]+CurrentPoint(1), [CurrentPoint(2) CurrentPoint(2)],'r','LineWidth',2,'PickableParts','none','HitTest','off','parent',CrossHairAxialAxes);
            plot([+XLength+XLength, +XLength]+CurrentPoint(1), [CurrentPoint(2) CurrentPoint(2)],'r','LineWidth',2,'PickableParts','none','HitTest','off','parent',CrossHairAxialAxes);
            plot([CurrentPoint(1) CurrentPoint(1)], CurrentPoint(2)+[+YLength+YLength, +YLength],'r','LineWidth',2,'PickableParts','none','HitTest','off','parent',CrossHairAxialAxes);
            plot([CurrentPoint(1) CurrentPoint(1)], CurrentPoint(2)+[-YLength-YLength, -YLength],'r','LineWidth',2,'PickableParts','none','HitTest','off','parent',CrossHairAxialAxes);

            %Coronal
            plot([-XLength-XLength, -XLength]+CurrentPoint(1), [CurrentPoint(3) CurrentPoint(3)],'r','LineWidth',2,'PickableParts','none','HitTest','off','parent',CrossHairCoronalAxes);
            plot([+XLength+XLength, +XLength]+CurrentPoint(1), [CurrentPoint(3) CurrentPoint(3)],'r','LineWidth',2,'PickableParts','none','HitTest','off','parent',CrossHairCoronalAxes);
            plot([CurrentPoint(1) CurrentPoint(1)], CurrentPoint(3)+[+ZLength+ZLength, +ZLength],'r','LineWidth',2,'PickableParts','none','HitTest','off','parent',CrossHairCoronalAxes);
            plot([CurrentPoint(1) CurrentPoint(1)], CurrentPoint(3)+[-ZLength-ZLength, -ZLength],'r','LineWidth',2,'PickableParts','none','HitTest','off','parent',CrossHairCoronalAxes);
            
            %Sagittal
            plot([-YLength-YLength, -YLength]+CurrentPoint(2), [CurrentPoint(3) CurrentPoint(3)],'r','LineWidth',2,'PickableParts','none','HitTest','off','parent',CrossHairSagittalAxes);
            plot([+YLength+YLength, +YLength]+CurrentPoint(2), [CurrentPoint(3) CurrentPoint(3)],'r','LineWidth',2,'PickableParts','none','HitTest','off','parent',CrossHairSagittalAxes);
            plot([CurrentPoint(2) CurrentPoint(2)], CurrentPoint(3)+[+ZLength+ZLength, +ZLength],'r','LineWidth',2,'PickableParts','none','HitTest','off','parent',CrossHairSagittalAxes);
            plot([CurrentPoint(2) CurrentPoint(2)], CurrentPoint(3)+[-ZLength-ZLength, -ZLength],'r','LineWidth',2,'PickableParts','none','HitTest','off','parent',CrossHairSagittalAxes);

            %Make sure the axes are at the top
            AxIDX = find( [MainMenu.UserData.TwoDMenu.GlobalProperties.Handles(FigureNumber).Children] == CrossHairAxialAxes);
            CoIDX = find( [MainMenu.UserData.TwoDMenu.GlobalProperties.Handles(FigureNumber).Children] == CrossHairCoronalAxes);
            SaIDX = find( [MainMenu.UserData.TwoDMenu.GlobalProperties.Handles(FigureNumber).Children] == CrossHairSagittalAxes);
            
            if(~any([isempty(AxIDX),isempty(CoIDX),isempty(SaIDX)])) %Check that we have axes
                FirstAxes = find(arrayfun(@(x) strcmp(x.Type,'axes'), MainMenu.UserData.TwoDMenu.GlobalProperties.Handles(FigureNumber).Children),1);
                NewOrder = [1:(FirstAxes-1), AxIDX, CoIDX, SaIDX, setdiff(FirstAxes:size(MainMenu.UserData.TwoDMenu.GlobalProperties.Handles(FigureNumber).Children,1),[AxIDX, SaIDX, CoIDX])];
                MainMenu.UserData.TwoDMenu.GlobalProperties.Handles(FigureNumber).Children = MainMenu.UserData.TwoDMenu.GlobalProperties.Handles(FigureNumber).Children(NewOrder);           
            end
        end
        
        
        
    end
end

