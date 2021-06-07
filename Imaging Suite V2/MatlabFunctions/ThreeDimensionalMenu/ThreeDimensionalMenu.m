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

function [] = ThreeDimensionalMenu(~,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%% Not Actually doing anything
    % Check for active submenus      %
    ActivePanels = CheckPanelsOpen();%
    if(ActivePanels)                 %
        return;                      %
    end                              %   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Check if there are any volumes loaded
    if(isempty(MainMenu.UserData.SubjectStructure.Volumes(1).FileAddress))
        ErrorPanel('No Volumes loaded');
        return;
    end
    
    
    %%%%%%%%%%%%%%%%%
    % Make a figure %
    %%%%%%%%%%%%%%%%%
    if(isempty(MainMenu.UserData.ThreeDMenu.Handle ))
        Create3DDisplayFigure();
    elseif(~isvalid(MainMenu.UserData.ThreeDMenu.Handle ))
        Create3DDisplayFigure();
    else
        ErrorPanel('Three Dimensional Panel already created');
        return;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Previously loaded data should be removed %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    MainMenu.UserData.ThreeDMenu.Surface = [];
end


function [] = Create3DDisplayFigure()
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    
    %%%%%%%%%%%%%%%%%%%
    % Make the Figure %
    ThreeDMenu = figure('Name','','units','Pixel','InnerPosition',MainMenu.UserData.ThreeDMenu.SimplePosition,'Tag','ThreeDImageDisplay','MenuBar','none','NumberTitle','off','Color',[1 1 1]);        
    MainMenu.UserData.ThreeDMenu.Handle = ThreeDMenu;
    
    %%%%%%%%%%%%%%
    % Display UI %
    %%%%%%%%%%%%%%
    
   
    uiWidth = MainMenu.UserData.ThreeDMenu.uiWidth;
    uiXOffset = MainMenu.UserData.ThreeDMenu.uiXOffset; 
    uiHeight = MainMenu.UserData.ThreeDMenu.uiHeight;
    uiHeightSpacing = MainMenu.UserData.ThreeDMenu.uiHeightSpacing;
    uiYOffset = MainMenu.UserData.ThreeDMenu.uiYOffset;
    
    uiDisplayWidth = MainMenu.UserData.ThreeDMenu.uiDisplayWidth;
    uiDisplayFullWidth = MainMenu.UserData.ThreeDMenu.uiDisplayFullWidth;
    uiDisplayXOffset = MainMenu.UserData.ThreeDMenu.uiDisplayXOffset;
    uiDisplayHeight = MainMenu.UserData.ThreeDMenu.uiDisplayHeight;
    uiDisplayHeightSpacing = MainMenu.UserData.ThreeDMenu.uiDisplayHeightSpacing;
    uiDisplayYOffset = MainMenu.UserData.ThreeDMenu.uiDisplayYOffset;
    
    uiCutWidth = MainMenu.UserData.ThreeDMenu.uiCutWidth;
    uiCutFullWidth = MainMenu.UserData.ThreeDMenu.uiCutFullWidth;
    uiCutXOffset = MainMenu.UserData.ThreeDMenu.uiCutXOffset;
    uiCutHeight = MainMenu.UserData.ThreeDMenu.uiCutHeight;
    uiCutHeightSpacing = MainMenu.UserData.ThreeDMenu.uiCutHeightSpacing;
    uiCutYOffset = MainMenu.UserData.ThreeDMenu.uiCutYOffset;
 
    RectangleRelief = MainMenu.UserData.ThreeDMenu.RectangleRelief;
        %%%%%%%%%%%%
        % SETTINGS %
        %%%%%%%%%%%%
            %Draw a rectangle around these to separate them
            uiDisplayRectangle = axes('Units','pixels','position',[uiDisplayXOffset(1)-RectangleRelief, uiDisplayYOffset(2)-RectangleRelief, uiDisplayFullWidth+2*RectangleRelief, 2*uiDisplayHeightSpacing+2*RectangleRelief],'XTick',[],'YTick',[],'PickableParts','none','Hittest','off');
            plot([0 0 1 1 0],[0 1 1 0 0],'k','LineWidth',3); axis('tight');uiDisplayRectangle.Visible = 'off';uiDisplayRectangle.Layer = 'top';uiDisplayRectangle.HitTest = 'off';
            MainMenu.UserData.ThreeDMenu.uiDisplayRectangle = uiDisplayRectangle;
            
            %Text to indicate the options
            uiDisplayText  = uicontrol('Style','text','units','Pixels','Position',[uiDisplayXOffset(1), uiDisplayYOffset(1), uiDisplayWidth, uiDisplayHeight],'String','Items for display:','BackgroundColor',[1 1 1],'HorizontalAlignment','Left');
            MainMenu.UserData.ThreeDMenu.uiDisplayText = uiDisplayText;
            
            %2D Volume Checkbox
            ui2DVolumeCheckBox = uicontrol('Style','checkbox','Units','pixel','position',[uiDisplayXOffset(2), uiDisplayYOffset(1), uiDisplayWidth uiDisplayHeight],'Value',0,'BackgroundColor',[1 1 1],'String','2D Volume','Tag','2DVolumeDisplayCheckBox','CallBack',@TwoDVolumeCheckboxCallback);
            MainMenu.UserData.ThreeDMenu.ui2DVolumeCheckBox = ui2DVolumeCheckBox;

            %3D Surface Checkbox
            ui3DSurfaceCheckBox = uicontrol('Style','checkbox','Units','pixel','position',[uiDisplayXOffset(2), uiDisplayYOffset(2), uiDisplayWidth uiDisplayHeight],'Value',0,'BackgroundColor',[1 1 1],'String','3D Surface','Tag','3DSurfaceDisplayCheckBox','CallBack',@ThreeDSurfaceCheckboxCallback);
            MainMenu.UserData.ThreeDMenu.ui3DSurfaceCheckBox = ui3DSurfaceCheckBox;

            %ROI Checkbox
            uiROICheckBox = uicontrol('Style','checkbox','Units','pixel','position',[uiDisplayXOffset(3), uiDisplayYOffset(1), uiDisplayWidth uiDisplayHeight],'Value',0,'BackgroundColor',[1 1 1],'String','ROI''s','Tag','ROIDisplayCheckBox','CallBack',@ROICheckBoxCallback);
            MainMenu.UserData.ThreeDMenu.uiROICheckBox = uiROICheckBox;
            
            %ROI Lables Checkbox
            uiROILabelsCheckBox = uicontrol('Style','checkbox','Units','pixel','position',[uiDisplayXOffset(3), uiDisplayYOffset(2), uiDisplayWidth uiDisplayHeight],'Value',0,'BackgroundColor',[1 1 1],'String','ROI Labels','Tag','ROILabelsDisplayCheckBox','CallBack',@ROILabelsCheckBoxCallback);
            MainMenu.UserData.ThreeDMenu.uiROILabelsCheckBox = uiROILabelsCheckBox;
         
            %External Data Checkbox
            uiExternalDataCheckBox = uicontrol('Style','checkbox','Units','pixel','position',[uiDisplayXOffset(4), uiDisplayYOffset(1), uiDisplayWidth uiDisplayHeight],'Value',0,'BackgroundColor',[1 1 1],'String','External Data','Tag','ExternalDataDisplayCheckBox','CallBack',@ExternalDataCheckBoxCallback);
            MainMenu.UserData.ThreeDMenu.uiExternalDataCheckBox = uiExternalDataCheckBox;
            
            % Axes Settings Checkbox
            uiAxesSettingsCheckBox = uicontrol('Style','checkbox','Units','pixel','position',[uiDisplayXOffset(4), uiDisplayYOffset(2), uiDisplayWidth uiDisplayHeight],'Value',0,'BackgroundColor',[1 1 1],'String','Axes Settings','Tag','AxesSettingsCheckBox','CallBack',@AxesSettingsCheckBoxCallback);
            MainMenu.UserData.ThreeDMenu.uiAxesSettingsCheckBox = uiAxesSettingsCheckBox;
            
        %%%%%%%%%%%
        % Volumes % 
        %%%%%%%%%%%
            
            %VolumeSelector
            i = 1;
            uiVolumeSelectionText = uicontrol('Style','text','units','pixel','position',[uiXOffset(1), uiYOffset(i), uiWidth(2), uiHeight],'String','Volume to Display','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible','off');
            VolumeSelectionText = strcat('(',{MainMenu.UserData.SubjectStructure.Volumes.FileName},{')   '} ,{MainMenu.UserData.SubjectStructure.Volumes.Type}); VolumeSelectionText{size(VolumeSelectionText,2) +1} = 'none';
            uiVolumeSelectionPopUp = uicontrol('Style','popupmenu','Units','pixel','position',[uiXOffset(2), uiYOffset(i), uiWidth(2), uiHeight],'String',VolumeSelectionText,'Value',size(VolumeSelectionText,2),'Tag','VolumeSelectionPopUp','Visible','off','CallBack',@VolumeSelectionCallback);
            MainMenu.UserData.ThreeDMenu.uiVolumeSelectionPopUp = uiVolumeSelectionPopUp;
            MainMenu.UserData.ThreeDMenu.uiVolumeSelectionText = uiVolumeSelectionText;
            
            %Volume ColourMap
            i=i+1;
            uiVolumeColourMapText = uicontrol('Style','text','units','pixel','position',[uiXOffset(1), uiYOffset(i), uiWidth(2), uiHeight],'String','Volume Colour Map','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible','off');
            uiVolumeColourMapPopUp = uicontrol('Style','popupmenu','Units','pixel','position',[uiXOffset(2), uiYOffset(i), uiWidth(2), uiHeight],'String',MainMenu.UserData.ThreeDMenu.ColourMaps,'Value',1,'Tag','VolumeColourMapPopUp','Visible','off','CallBack',@UpdateDisplay);
            MainMenu.UserData.ThreeDMenu.uiVolumeColourMapPopUp = uiVolumeColourMapPopUp;
            MainMenu.UserData.ThreeDMenu.uiVolumeColourMapText = uiVolumeColourMapText;
            
            %Volume Opacitiy
            i=i+1;
            uiVolumeOpacitiyText = uicontrol('Style','text','units','pixel','position',[uiXOffset(1), uiYOffset(i), uiWidth(2), uiHeight],'String','Volume Opacity','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible','off');
            uiVolumeOpacitiyPopUp = uicontrol('Style','popupmenu','Units','pixel','position',[uiXOffset(2), uiYOffset(i), uiWidth(2), uiHeight],'String',{'100%','80%','60%','40%','20%','0%'},'Value',1,'Tag','VolumeOpacitiyPopUp','Visible','off','CallBack',@UpdateDisplay);
            MainMenu.UserData.ThreeDMenu.uiVolumeOpacitiyPopUp = uiVolumeOpacitiyPopUp;
            MainMenu.UserData.ThreeDMenu.uiVolumeOpacitiyText = uiVolumeOpacitiyText;
            
            %Volume Range
            i=i+1;
            uiVolumeRangeText = uicontrol('Style','text','units','pixel','position',[uiXOffset(1), uiYOffset(i), uiWidth(2), uiHeight],'String','Volume Range','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible','off');
            uiVolumeRangePopUp = uicontrol('Style','popupmenu','Units','pixel','position',[uiXOffset(2), uiYOffset(i), uiWidth(2), uiHeight],'String',{'0 - 100%','0.5 - 99.5%','1 - 99%','2 - 98%','3 - 97%','5 - 95%', '10 - 90%','20 - 80%','30 - 70%','40 - 60%'},'Value',1,'Tag','VolumeRangePopUp','Visible','off','CallBack',@UpdateDisplay);
            MainMenu.UserData.ThreeDMenu.uiVolumeRangePopUp = uiVolumeRangePopUp;
            MainMenu.UserData.ThreeDMenu.uiVolumeRangeText = uiVolumeRangeText;
            
            %Draw a rectangle around these to separate them
            uiVolumeRectangle = axes('Units','pixels','position',[uiXOffset(1)-RectangleRelief, uiYOffset(i)-RectangleRelief, uiWidth(1)+2*RectangleRelief, 4*uiHeightSpacing+2*RectangleRelief],'XTick',[],'YTick',[],'PickableParts','none','Hittest','off');
            plot([0 0 1 1 0],[0 1 1 0 0],'k','LineWidth',3); axis('tight');uiVolumeRectangle.Visible = 'off';uiVolumeRectangle.Layer = 'top';uiVolumeRectangle.HitTest = 'off';
            MainMenu.UserData.ThreeDMenu.uiVolumeRectangle = uiVolumeRectangle;
            MainMenu.UserData.ThreeDMenu.uiVolumeRectangle.Children(1).Visible = 'off';
            i=i+1;
            
        %%%%%%%%%%%
        % Surface % 
        %%%%%%%%%%%
        
            %Surface Popup
            i=i+1;
            uiSurfacePopUpText = uicontrol('Style','text','units','pixel','position',[uiXOffset(1), uiYOffset(i), uiWidth(2), uiHeight],'String','Surface','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible','off');
            SurfaceSelectionText = strcat('(',{MainMenu.UserData.SubjectStructure.Volumes.FileName},{')   '} ,{MainMenu.UserData.SubjectStructure.Volumes.Type}); SurfaceSelectionText{size(SurfaceSelectionText,2)+1} =  'None';
            uiSurfacePopUp = uicontrol('Style','popupmenu','Units','pixel','position',[uiXOffset(2), uiYOffset(i), uiWidth(2), uiHeight],'String',SurfaceSelectionText,'Value',size(SurfaceSelectionText,2),'Tag','SurfaceCreationButton','Visible','off','CallBack',@SurfaceSelectionCallback);
            MainMenu.UserData.ThreeDMenu.uiSurfacePopUpText = uiSurfacePopUpText;
            MainMenu.UserData.ThreeDMenu.uiSurfacePopUp = uiSurfacePopUp;
            
            %Surface ColourMap
            i=i+1;
            uiSurfaceColourMapText = uicontrol('Style','text','units','pixel','position',[uiXOffset(1), uiYOffset(i), uiWidth(2), uiHeight],'String','Surface Colour Map','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible','off');
            uiSurfaceColourMapPopUp = uicontrol('Style','popupmenu','Units','pixel','position',[uiXOffset(2), uiYOffset(i), uiWidth(2), uiHeight],'String',{'Black','Red','Blue','Green','Yellow','Magenta','Cyan'},'Value',1,'Tag','SurfaceColourMapPopUp','Visible','off','CallBack',@UpdateDisplay);
            MainMenu.UserData.ThreeDMenu.uiSurfaceColourMapPopUp = uiSurfaceColourMapPopUp;
            MainMenu.UserData.ThreeDMenu.uiSurfaceColourMapText = uiSurfaceColourMapText;
            
            %Surface Opacitiy
            i=i+1;
            uiSurfaceOpacitiyText = uicontrol('Style','text','units','pixel','position',[uiXOffset(1), uiYOffset(i), uiWidth(2), uiHeight],'String','Surface Opacity','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible','off');
            uiSurfaceOpacitiyPopUp = uicontrol('Style','popupmenu','Units','pixel','position',[uiXOffset(2), uiYOffset(i), uiWidth(2), uiHeight],'String',{'100%','90%','80%','70%','60%','50%','40%','30%','20%','10%','5%','2%','1%','0%'},'Value',6,'Tag','SurfaceOpacitiyPopUp','Visible','off','CallBack',@UpdateDisplay);
            MainMenu.UserData.ThreeDMenu.uiSurfaceOpacitiyPopUp = uiSurfaceOpacitiyPopUp;
            MainMenu.UserData.ThreeDMenu.uiSurfaceOpacitiyText = uiSurfaceOpacitiyText;
    
            %Draw a rectangle around these to separate them
            uiSurfaceRectangle = axes('Units','pixels','position',[uiXOffset(1)-RectangleRelief, uiYOffset(i)-RectangleRelief, uiWidth(1)+2*RectangleRelief, 3*uiHeightSpacing+2*RectangleRelief],'XTick',[],'YTick',[],'PickableParts','none','Hittest','off');
            plot([0 0 1 1 0],[0 1 1 0 0],'k','LineWidth',3); axis('tight');uiSurfaceRectangle.Visible = 'off';uiSurfaceRectangle.Layer = 'top';uiSurfaceRectangle.HitTest = 'off';
            MainMenu.UserData.ThreeDMenu.uiSurfaceRectangle = uiSurfaceRectangle;
            MainMenu.UserData.ThreeDMenu.uiSurfaceRectangle.Children(1).Visible = 'off';
            i=i+1;
            
        %%%%%%%%
        % ROIs %
        %%%%%%%%
       
            %ROI Popup
            i=i+1;
            uiROIPopUpText = uicontrol('Style','text','units','pixel','position',[uiXOffset(1), uiYOffset(i), uiWidth(2), uiHeight],'String','ROIs to Display','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible','off');
            ROISelectionText = strcat('(',{MainMenu.UserData.SubjectStructure.Volumes.FileName},{')   '} ,{MainMenu.UserData.SubjectStructure.Volumes.Type});
            uiROIPopUp = uicontrol('Style','popupmenu','Units','pixel','position',[uiXOffset(2), uiYOffset(i), uiWidth(2), uiHeight],'String',ROISelectionText,'Value',1,'Tag','ROIPopUp','Visible','off','CallBack',@ROISeletionCallback);
            MainMenu.UserData.ThreeDMenu.uiROIPopUpText = uiROIPopUpText;
            MainMenu.UserData.ThreeDMenu.uiROIPopUp = uiROIPopUp;
            
            %ROI Colour
            i=i+1;
            uiROIColourMapText = uicontrol('Style','text','units','pixel','position',[uiXOffset(1), uiYOffset(i), uiWidth(2), uiHeight],'String','ROI Colour','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible','off');
            uiROIColourMapPopUp = uicontrol('Style','popupmenu','Units','pixel','position',[uiXOffset(2), uiYOffset(i), uiWidth(2), uiHeight],'String',{'Red','Blue','Green','White','Yellow'},'Value',1,'Tag','ROIColourMapPopUp','Visible','off','CallBack',@UpdateDisplay);
            MainMenu.UserData.ThreeDMenu.uiROIColourMapPopUp = uiROIColourMapPopUp;
            MainMenu.UserData.ThreeDMenu.uiROIColourMapText = uiROIColourMapText;
            
            %ROI Size
            i=i+1;
            uiROISizeText = uicontrol('Style','text','units','pixel','position',[uiXOffset(1), uiYOffset(i), uiWidth(2), uiHeight],'String','ROI Size(mm)','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible','off');
            uiROISize = uicontrol('Style','edit','Units','pixel','position',[uiXOffset(2), uiYOffset(i), uiWidth(2), uiHeight],'String','5','Tag','ROIsize','Visible','off','CallBack',@UpdateDisplay);
            MainMenu.UserData.ThreeDMenu.uiROISizeText = uiROISizeText;
            MainMenu.UserData.ThreeDMenu.uiROISize = uiROISize;
            
            %ROI Connection
            i=i+1;
            uiROIConnectionText = uicontrol('Style','text','units','pixel','position',[uiXOffset(1), uiYOffset(i), uiWidth(2), uiHeight],'String','ROI Connections','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible','off');
            uiROIConnectionPopUp = uicontrol('Style','popupmenu','Units','pixel','position',[uiXOffset(2), uiYOffset(i), uiWidth(2), uiHeight],'String',{'None'},'Value',1,'Tag','ROIConnectionPopUp','Visible','off','CallBack',@UpdateDisplay);
            %uiROIConnectionPopUp = uicontrol('Style','popupmenu','Units','pixel','position',[uiXOffset(2), uiYOffset(i), uiWidth(2), uiHeight],'String',{'None','Designator','All'},'Value',1,'Tag','ROIConnectionPopUp','Visible','off','CallBack',@UpdateDisplay);
            MainMenu.UserData.ThreeDMenu.uiROIConnectionPopUp = uiROIConnectionPopUp;
            MainMenu.UserData.ThreeDMenu.uiROIConnectionText = uiROIConnectionText;
            
            %ROI Opacitiy
            i=i+1;
            uiROIOpacitiyText = uicontrol('Style','text','units','pixel','position',[uiXOffset(1), uiYOffset(i), uiWidth(2), uiHeight],'String','ROI Opacity','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible','off');
            uiROIOpacitiyPopUp = uicontrol('Style','popupmenu','Units','pixel','position',[uiXOffset(2), uiYOffset(i), uiWidth(2), uiHeight],'String',{'100%','80%','60%','40%','20%','0%'},'Value',1,'Tag','ROIOpacitiyPopUp','Visible','off','CallBack',@UpdateDisplay);
            MainMenu.UserData.ThreeDMenu.uiROIOpacitiyPopUp = uiROIOpacitiyPopUp;
            MainMenu.UserData.ThreeDMenu.uiROIOpacitiyText = uiROIOpacitiyText;
            
            %Draw a rectangle around these to separate them   
            uiROIRectangle = axes('Units','pixels','position',[uiXOffset(1)-RectangleRelief, uiYOffset(i)-RectangleRelief, uiWidth(1)+2*RectangleRelief, 5*uiHeightSpacing+2*RectangleRelief],'XTick',[],'YTick',[],'PickableParts','none','Hittest','off');
            plot([0 0 1 1 0],[0 1 1 0 0],'k','LineWidth',3); axis('tight');uiROIRectangle.Visible = 'off';uiROIRectangle.Layer = 'top';uiROIRectangle.HitTest = 'off';
            MainMenu.UserData.ThreeDMenu.uiROIRectangle = uiROIRectangle;
            MainMenu.UserData.ThreeDMenu.uiROIRectangle.Children(1).Visible = 'off';
            i=i+1;
            
        %%%%%%%%%%%%%%
        % ROI Labels %
        %%%%%%%%%%%%%%
            
            %ROI Label Colour
            i=i+1;
            uiROILabelColourMapText = uicontrol('Style','text','units','pixel','position',[uiXOffset(1), uiYOffset(i), uiWidth(2), uiHeight],'String','ROI label colour','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible','off');
            uiROILabelColourMapPopUp = uicontrol('Style','popupmenu','Units','pixel','position',[uiXOffset(2), uiYOffset(i), uiWidth(2), uiHeight],'String',{'Black','Red','Blue','Green','Yellow','White','Cyan','Magenta'},'Value',1,'Tag','ROILabelColourMapPopUp','Visible','off','CallBack',@UpdateDisplay);
            MainMenu.UserData.ThreeDMenu.uiROILabelColourMapPopUp = uiROILabelColourMapPopUp;
            MainMenu.UserData.ThreeDMenu.uiROILabelColourMapText = uiROILabelColourMapText;
            
            
            %ROI Label Size
            i=i+1;
            uiROILabelSizeText = uicontrol('Style','text','units','pixel','position',[uiXOffset(1), uiYOffset(i), uiWidth(2), uiHeight],'String','ROI label font size','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible','off');
            uiROILabelSize = uicontrol('Style','edit','Units','pixel','position',[uiXOffset(2), uiYOffset(i), uiWidth(2), uiHeight],'String','12','Tag','ROILabelsize','Visible','off','CallBack',@UpdateDisplay);
            MainMenu.UserData.ThreeDMenu.uiROILabelSizeText = uiROILabelSizeText;
            MainMenu.UserData.ThreeDMenu.uiROILabelSize = uiROILabelSize;
            
            
%             %ROI Label Position
%             i=i+1;
%             uiROILabelPositionText = uicontrol('Style','text','units','pixel','position',[uiXOffset(1), uiYOffset(i), uiWidth(2), uiHeight],'String','ROI label position','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible','off');
%             uiROILabelPositionPopUp = uicontrol('Style','popupmenu','Units','pixel','position',[uiXOffset(2), uiYOffset(i), uiWidth(2), uiHeight],'String',{'North','North East','East','South East','South','South West','West','North West'},'Value',1,'Tag','ROILabelPositionPopUp','Visible','off','CallBack',@UpdateDisplay);
%             MainMenu.UserData.ThreeDMenu.uiROILabelPositionPopUp = uiROILabelPositionPopUp;
%             MainMenu.UserData.ThreeDMenu.uiROILabelPositionText = uiROILabelPositionText;
            
            %Draw a rectangle around these to separate them
            uiROILabelRectangle = axes('Units','pixels','position',[uiXOffset(1)-RectangleRelief, uiYOffset(i)-RectangleRelief, uiWidth(1)+2*RectangleRelief, 2*uiHeightSpacing+2*RectangleRelief],'XTick',[],'YTick',[],'PickableParts','none','Hittest','off');
            plot([0 0 1 1 0],[0 1 1 0 0],'k','LineWidth',3); axis('tight');uiROILabelRectangle.Visible = 'off';uiROILabelRectangle.Layer = 'top';uiROILabelRectangle.HitTest = 'off';
            MainMenu.UserData.ThreeDMenu.uiROILabelRectangle = uiROILabelRectangle;
            MainMenu.UserData.ThreeDMenu.uiROILabelRectangle.Children(1).Visible = 'off';
            i=i+1;
            
        %%%%%%%%
        % Data %
        %%%%%%%%
        
            %Data Import
            i=i+1;
            uiDataImportText = uicontrol('Style','text','units','pixel','position',[uiXOffset(1), uiYOffset(i), uiWidth(2), uiHeight],'String','Data Import','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible','off');
            uiDataImportButton = uicontrol('Style','pushbutton','Units','pixel','position',[uiXOffset(2), uiYOffset(i), uiWidth(2), uiHeight],'String','Load','Tag','DataLoadButton','Visible','off','CallBack',@DataImport);
            MainMenu.UserData.ThreeDMenu.uiDataImportText = uiDataImportText;
            MainMenu.UserData.ThreeDMenu.uiDataImportButton = uiDataImportButton;
            
            %Data Colour Map
            i=i+1;
            uiDataColourMapText = uicontrol('Style','text','units','pixel','position',[uiXOffset(1), uiYOffset(i), uiWidth(2), uiHeight],'String','Data Colour Map','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible','off');
            uiDataColourMapPopUp = uicontrol('Style','popupmenu','Units','pixel','position',[uiXOffset(2), uiYOffset(i), uiWidth(2), uiHeight],'String',MainMenu.UserData.ThreeDMenu.ColourMaps,'Value',1,'Tag','DataColourMapPopUp','Visible','off','CallBack',@UpdateDataColourMap);
            MainMenu.UserData.ThreeDMenu.uiDataColourMapPopUp = uiDataColourMapPopUp;
            MainMenu.UserData.ThreeDMenu.uiDataColourMapText = uiDataColourMapText;
            
            %Data Opacitiy
            i=i+1;
            uiDataOpacitiyText = uicontrol('Style','text','units','pixel','position',[uiXOffset(1), uiYOffset(i), uiWidth(2), uiHeight],'String','Data Opacity','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible','off');
            uiDataOpacitiyPopUp = uicontrol('Style','popupmenu','Units','pixel','position',[uiXOffset(2), uiYOffset(i), uiWidth(2), uiHeight],'String',{'100%','80%','60%','40%','20%','0%'},'Value',1,'Tag','DataOpacitiyPopUp','Visible','off','CallBack',@UpdateDisplay);
            MainMenu.UserData.ThreeDMenu.uiDataOpacitiyPopUp = uiDataOpacitiyPopUp;
            MainMenu.UserData.ThreeDMenu.uiDataOpacitiyText = uiDataOpacitiyText;
            
            %Data Index Slider
            i=i+1;
            uiDataIndexSliderText = uicontrol('Style','text','units','pixel','position',[uiXOffset(1), uiYOffset(i), uiWidth(2), uiHeight],'String','Data Index','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible','off');
            i=i+1;i=i+1;
            [uiDataIndexSlider,uiDataIndexSliderContainer] = javacomponent(javax.swing.JSlider(1, 101, 50), [uiXOffset(1), uiYOffset(i), uiWidth(1), 2*uiHeight], gcf);
            set(uiDataIndexSlider, 'MajorTickSpacing',25,...
                                        'MinorTickSpacing',5,...
                                        'PaintTicks',true, 'PaintLabels',true,...
                                        'Background',java.awt.Color.white,...
                                        'Visible',1,...
                                        'Name','uiDataIndexSlider',...
                                        'MouseReleasedCallback',@UpdateDisplay,...
                                        'KeyReleasedCallback',@UpdateDisplay);
            uiDataIndexSliderContainer.BackgroundColor = [1 1 1];
            uiDataIndexSliderContainer.Visible = false;
            MainMenu.UserData.ThreeDMenu.uiDataIndexSliderContainer = uiDataIndexSliderContainer;
            MainMenu.UserData.ThreeDMenu.uiDataIndexSlider = uiDataIndexSlider;
            MainMenu.UserData.ThreeDMenu.uiDataIndexSliderText = uiDataIndexSliderText;
            
            %Draw a rectangle around these to separate them
            uiDataRectangle = axes('Units','pixels','position',[uiXOffset(1)-RectangleRelief, uiYOffset(i)-RectangleRelief, uiWidth(1)+2*RectangleRelief, 6*uiHeightSpacing+2*RectangleRelief],'XTick',[],'YTick',[],'PickableParts','none','Hittest','off');
            plot([0 0 1 1 0],[0 1 1 0 0],'k','LineWidth',3); axis('tight');uiDataRectangle.Visible = 'off';uiDataRectangle.Layer = 'top';uiDataRectangle.HitTest = 'off';
            MainMenu.UserData.ThreeDMenu.uiDataRectangle = uiDataRectangle;
            MainMenu.UserData.ThreeDMenu.uiDataRectangle.Children(1).Visible = 'off';
            i=i+1;
       %%%%%%%%%%%%%%%%
       % X, Y, Z Cuts %
       %%%%%%%%%%%%%%%%

           %Draw a rectangle around these to separate them
           uiCutRectangle = axes('Units','pixels','position',[uiCutXOffset(1)-RectangleRelief, uiCutYOffset(6)-RectangleRelief, uiCutFullWidth+2*RectangleRelief, 3*uiCutHeightSpacing+2*RectangleRelief],'XTick',[],'YTick',[],'PickableParts','none','Hittest','off');
           plot([0 0 1 1 0],[0 1 1 0 0],'k','LineWidth',3); axis('tight');uiCutRectangle.Visible = 'off';uiCutRectangle.Layer = 'top';uiCutRectangle.HitTest = 'off';
           MainMenu.UserData.ThreeDMenu.uiCutRectangle = uiCutRectangle;
           MainMenu.UserData.ThreeDMenu.uiCutRectangle.Children(1).Visible = 'off';

           %Volume X limits
           uiVolumeXRangeSliderText = uicontrol('Style','text','units','pixel','position',[uiCutXOffset(1), uiCutYOffset(4), uiCutWidth(1), uiCutHeight],'String','X Plane Limits','BackgroundColor',[1 1 1],'HorizontalAlignment','Center','Visible','off');
           uiVolumeXRangeSlider = com.jidesoft.swing.RangeSlider(0, 100, 0, 100);
           [uiVolumeXRangeSlider,uiVolumeXRangeSliderContainer] = javacomponent(uiVolumeXRangeSlider, [uiCutXOffset(1), uiCutYOffset(6), uiCutWidth(1), 2*uiCutHeight], gcf);
           set(uiVolumeXRangeSlider,'MajorTickSpacing',25,...
               'MinorTickSpacing',5,...
               'Inverted',true,...
               'PaintTicks',true, 'PaintLabels',true,...
               'Background',java.awt.Color.white,...
               'Visible',1,...
               'Name','XCUT',...
               'MouseReleasedCallback',@UpdateDisplay,...
               'KeyReleasedCallback',@UpdateDisplay);
           uiVolumeXRangeSliderContainer.BackgroundColor = [1 1 1];
           uiVolumeXRangeSliderContainer.Visible = false;
           MainMenu.UserData.ThreeDMenu.uiVolumeXRangeSliderText = uiVolumeXRangeSliderText;
           MainMenu.UserData.ThreeDMenu.uiVolumeXRangeSlider = uiVolumeXRangeSlider;
           MainMenu.UserData.ThreeDMenu.uiVolumeXRangeSliderContainer = uiVolumeXRangeSliderContainer;
           
           %Volume Y limits
           uiVolumeYRangeSliderText = uicontrol('Style','text','units','pixel','position',[uiCutXOffset(2), uiCutYOffset(4), uiCutWidth(1), uiCutHeight],'String','Y Plane Limits','BackgroundColor',[1 1 1],'HorizontalAlignment','Center','Visible','off');
           uiVolumeYRangeSlider = com.jidesoft.swing.RangeSlider(0, 100, 0, 100);
           [uiVolumeYRangeSlider,uiVolumeYRangeSliderContainer] = javacomponent(uiVolumeYRangeSlider, [uiCutXOffset(2), uiCutYOffset(6), uiCutWidth(1), 2*uiCutHeight], gcf);
           set(uiVolumeYRangeSlider,'MajorTickSpacing',25,...
               'MinorTickSpacing',5,...
               'Inverted',true,...
               'PaintTicks',true, 'PaintLabels',true,...
               'Background',java.awt.Color.white,...
               'Visible',1,...
               'Name','YCUT',...
               'MouseReleasedCallback',@UpdateDisplay,...
               'KeyReleasedCallback',@UpdateDisplay);
           uiVolumeYRangeSliderContainer.BackgroundColor = [1 1 1];
           uiVolumeYRangeSliderContainer.Visible = false;
           MainMenu.UserData.ThreeDMenu.uiVolumeYRangeSliderText = uiVolumeYRangeSliderText;
           MainMenu.UserData.ThreeDMenu.uiVolumeYRangeSlider = uiVolumeYRangeSlider;
           MainMenu.UserData.ThreeDMenu.uiVolumeYRangeSliderContainer = uiVolumeYRangeSliderContainer;
           
           %Volume Y limits
           uiVolumeZRangeSliderText = uicontrol('Style','text','units','pixel','position',[uiCutXOffset(3), uiCutYOffset(4), uiCutWidth(1), uiCutHeight],'String','Z Plane Limits','BackgroundColor',[1 1 1],'HorizontalAlignment','Center','Visible','off');
           uiVolumeZRangeSlider = com.jidesoft.swing.RangeSlider(0, 100, 0, 100);
           [uiVolumeZRangeSlider,uiVolumeZRangeSliderContainer] = javacomponent(uiVolumeZRangeSlider, [uiCutXOffset(3), uiCutYOffset(6), uiCutWidth(1), 2*uiCutHeight], gcf);
           set(uiVolumeZRangeSlider,'MajorTickSpacing',25,...
               'MinorTickSpacing',5,...
               'Inverted',true,...
               'PaintTicks',true, 'PaintLabels',true,...
               'Background',java.awt.Color.white,...
               'Visible',1,...
               'Name','ZCUT',...
               'MouseReleasedCallback',@UpdateDisplay,...
               'KeyReleasedCallback',@UpdateDisplay);
           uiVolumeZRangeSliderContainer.BackgroundColor = [1 1 1];
           uiVolumeZRangeSliderContainer.Visible = false;
           MainMenu.UserData.ThreeDMenu.uiVolumeZRangeSliderText = uiVolumeZRangeSliderText;
           MainMenu.UserData.ThreeDMenu.uiVolumeZRangeSlider = uiVolumeZRangeSlider;
           MainMenu.UserData.ThreeDMenu.uiVolumeZRangeSliderContainer = uiVolumeZRangeSliderContainer;
            
            
       %%%%%%%%%%
       % Axes %
       %%%%%%%%%%           
            %Figure Background
            i=i+1;
            uiAxesSettingsText = uicontrol('Style','text','units','pixel','position',[uiXOffset(1), uiYOffset(i), uiWidth(2), uiHeight],'String','Axes background','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible','off');
            uiAxesSettingsPopUp = uicontrol('Style','popupmenu','Units','pixel','position',[uiXOffset(2), uiYOffset(i), uiWidth(2), uiHeight],'String',{'White','Black','Red','Blue','Green','Yellow'},'Value',1,'Tag','AxesBackGroundPopUp','Visible','off','CallBack',@AxesBackGroundCallback);
            MainMenu.UserData.ThreeDMenu.uiAxesSettingsPopUp = uiAxesSettingsPopUp;
            MainMenu.UserData.ThreeDMenu.uiAxesSettingsText = uiAxesSettingsText;
            
            %Draw a rectangle around these to separate them
            uiAxesSettingsRectangle = axes('Units','pixels','position',[uiXOffset(1)-RectangleRelief, uiYOffset(i)-RectangleRelief, uiWidth(1)+2*RectangleRelief, 1*uiHeightSpacing+2*RectangleRelief],'XTick',[],'YTick',[],'PickableParts','none','Hittest','off');
            plot([0 0 1 1 0],[0 1 1 0 0],'k','LineWidth',3); axis('tight');uiAxesSettingsRectangle.Visible = 'off';uiAxesSettingsRectangle.Layer = 'top';uiAxesSettingsRectangle.HitTest = 'off';
            MainMenu.UserData.ThreeDMenu.uiAxesSettingsRectangle = uiAxesSettingsRectangle;
            MainMenu.UserData.ThreeDMenu.uiAxesSettingsRectangle.Children(1).Visible = 'off';
            
    %Create the Central Axes and display something
    CreateThreeDAxes(1);
end

%%%%%%%%
% Data %
%%%%%%%%
function [] = DataImport(~,~)

     %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    [File, Path] = uigetfile({'*.mat'},'Select Data','multiselect','off');
    if(isnumeric(File))
        return;
    end
    
    %Information 
    MF = MessagePanel('Loading Data','Loading Data');
    
    %Load the data
    TempData = load(strcat(Path,File));
    
    %Remove loading sign
    if(isvalid(MF))
        close(MF);
    end
    
    %Check that is has the correct field
    if(~isfield(TempData,{'DataStructure'}))
        MessagePanel('Incorrect Data file',sprintf('The data file did not have the correct Name\n"DataStructure"'));
        return;
    end
    
    %Extract just the DataStructure
    DataStructure = TempData.DataStructure;
    
    %Check that is has the correct fields
    if(~isfield(DataStructure,{'Label','Data'}))
        MessagePanel('Incorrect Data file',sprintf('The DataStructure did not have the correct fields\n"Label" and "Data"'));
        return;
    end
    
    %If the file did load a correct structure
    MainMenu.UserData.ThreeDMenu.DataStructure = DataStructure;
    
    %Update the time range
    MainMenu.UserData.ThreeDMenu.uiDataIndexSlider.setValue(1);
    MainMenu.UserData.ThreeDMenu.uiDataIndexSlider.setMinimum(1);
    MainMenu.UserData.ThreeDMenu.uiDataIndexSlider.setMaximum(length(DataStructure(1).Data));
    MainMenu.UserData.ThreeDMenu.uiDataIndexSlider.setMinorTickSpacing(round(length(DataStructure(1).Data)./16));
    MainMenu.UserData.ThreeDMenu.uiDataIndexSlider.setLabelTable(MainMenu.UserData.ThreeDMenu.uiDataIndexSlider.createStandardLabels(round(length(DataStructure(1).Data)./4)));
   
    %Update the Display
    UpdateExternalDataStructure();
    UpdateDataColourMap();
    UpdateBoundingBox();
    UpdateDisplay();
    
end

function [] = UpdateDataColourMap(~,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    cla(MainMenu.UserData.ThreeDMenu.Axes);
    MainMenu.UserData.ThreeDMenu.ColourMap = colormap(MainMenu.UserData.ThreeDMenu.Axes,MainMenu.UserData.ThreeDMenu.uiDataColourMapPopUp.String{MainMenu.UserData.ThreeDMenu.uiDataColourMapPopUp.Value});
            
    UpdateDisplay();
end

%%%%%%%%%%
% Volume %
%%%%%%%%%%
function [] = VolumeSelectionCallback(src,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    %Check that the selection is not the NULL ('None') Selection
    if(src.Value > size(MainMenu.UserData.SubjectStructure.Volumes,2))
        %Remove the volume
        MainMenu.UserData.ThreeDMenu.Volume.VolumeStructure = [];
        MainMenu.UserData.ThreeDMenu.Volume.premul = [];
        MainMenu.UserData.ThreeDMenu.Volume.BoundingBox = [];
        MainMenu.UserData.ThreeDMenu.Volume.WorldDimensions = [];
        %MainMenu.UserData.ThreeDMenu.Volume.Range = [0 1];
        UpdateBoundingBox();
        UpdateDisplay();
        return;
    end
    
    %Load the Volume
    MainMenu.UserData.ThreeDMenu.Volume.VolumeStructure = spm_vol(MainMenu.UserData.SubjectStructure.Volumes(src.Value).FileAddress);
    MainMenu.UserData.ThreeDMenu.Volume.premul = eye(4);
    MainMenu.UserData.ThreeDMenu.Volume.BoundingBox = spm_get_bbox(MainMenu.UserData.ThreeDMenu.Volume.VolumeStructure);
    MainMenu.UserData.ThreeDMenu.Volume.WorldDimensions = round(diff(MainMenu.UserData.ThreeDMenu.Volume.BoundingBox)'+1);
    
    %Collect the True Range
    %VolumeData = spm_read_vols(MainMenu.UserData.ThreeDMenu.Volume.VolumeStructure);
    %MainMenu.UserData.ThreeDMenu.Volume.Range = prctile(VolumeData(:),[0 100]);
    
    
    %Update the Display
    UpdateBoundingBox();
    UpdateDisplay();
end

%%%%%%%%%%%%%%%%%
% ROI Callbacks %
%%%%%%%%%%%%%%%%%
function [] = ROISeletionCallback(~,~)

    %If the ROIs are used with External Data update due to the change
    UpdateExternalDataStructure();

    %Update the Display
    UpdateBoundingBox();
    UpdateDisplay();
    
end

%%%%%%%%%%%%%%%%%%%
% Axes Settings %
%%%%%%%%%%%%%%%%%%%
function [] = AxesBackGroundCallback(src, ~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    %Recolour the Axes Background to match the selection
    MainMenu.UserData.ThreeDMenu.Axes.Color = src.String{src.Value};
    
    
end

%%%%%%%%%%%%%%%%%%%%%
% Surface Callbacks %
%%%%%%%%%%%%%%%%%%%%%
function [] = SurfaceSelectionCallback(src,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Check that the selection is not the NULL ('None') Selection
    if(src.Value > size(MainMenu.UserData.SubjectStructure.Volumes,2))
        %Remove all surfaces
        MainMenu.UserData.ThreeDMenu.Surface = [];
        %Remove the SurfaceMask
        MainMenu.UserData.ThreeDMenu.Volume.MaskVolumeStructure = [];
        MainMenu.UserData.ThreeDMenu.Volume.Maskpremul = [];

        UpdateBoundingBox();
        UpdateDisplay();
        return;
    end
    
    %Check if the selection has a surface and surface mask created
    if( exist(  MainMenu.UserData.SubjectStructure.Volumes(src.Value).SurfaceAddress, 'file' ) && exist(  MainMenu.UserData.SubjectStructure.Volumes(src.Value).SurfaceMaskAddress, 'file' ))
        
        %The file exists - Load the GIFTI
        MainMenu.UserData.ThreeDMenu.Surface = gifti(MainMenu.UserData.SubjectStructure.Volumes(src.Value).SurfaceAddress);
        
        MainMenu.UserData.ThreeDMenu.Volume.MaskVolumeStructure = spm_vol(MainMenu.UserData.SubjectStructure.Volumes(src.Value).SurfaceMaskAddress);
        MainMenu.UserData.ThreeDMenu.Volume.Maskpremul = eye(4);
        
        %Update Display
        UpdateBoundingBox();
        UpdateDisplay();
        
    else
        
        %The file does not exist
        %Warn the user that the process can take some time and should only
        %be performed on MRI's
        SurfaceCreationPanel = figure('Name','Surface Creation','NumberTitle','off','units','normalized','InnerPosition',[0.4 0.4 0.2 0.2],'Color',[1 1 1],'MenuBar','none','Tag','SurfaceCreationWindow');         
        uicontrol('Style','text','units','normalized','Position',[0.1 0.3 0.8 0.60],'String',sprintf('A surface for the selected volume does not exist\nWould you like to create one now?\n\n If yes, please ensure that the volume is a MRI before continuing'),'BackgroundColor',[1 1 1],'horizontalAlignment','center');
        uicontrol('Style','Pushbutton','units','normalized','Position',[0.1 0.1 0.35 0.15],'String','Create Surface','Callback',@CreateSurface);
        uicontrol('Style','Pushbutton','units','normalized','Position',[0.55 0.1 0.35 0.15],'String','Cancel','callback',@CloseSurfaceCreationWindow);
        MainMenu.UserData.ThreeDMenu.SurfaceCreationPanel = SurfaceCreationPanel;
    end
end

function [] = CloseSurfaceCreationWindow(~,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    if(isvalid(MainMenu.UserData.ThreeDMenu.SurfaceCreationPanel))
        close(MainMenu.UserData.ThreeDMenu.SurfaceCreationPanel);
    end
    
    MainMenu.UserData.ThreeDMenu.uiSurfacePopUp.Value = size(MainMenu.UserData.ThreeDMenu.uiSurfacePopUp.String,1);

end

function [] = CreateSurface(~,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    %Close the request panel
    if(ishandle(MainMenu.UserData.ThreeDMenu.SurfaceCreationPanel))
        if(isvalid(MainMenu.UserData.ThreeDMenu.SurfaceCreationPanel))
            close(MainMenu.UserData.ThreeDMenu.SurfaceCreationPanel);
        end
    end
    
    %Work out what volume is to be made into a surface
    VolumeAddress = MainMenu.UserData.SubjectStructure.Volumes(MainMenu.UserData.ThreeDMenu.uiSurfacePopUp.Value).FileAddress;
    FileName = MainMenu.UserData.SubjectStructure.Volumes(MainMenu.UserData.ThreeDMenu.uiSurfacePopUp.Value).FileName;
    [ParentFolder,Name] = fileparts(VolumeAddress);    
    
    %Design the job
    temp = which('ImagingSuiteV2'); temp=temp(1:end-16);
    ProbabilityMapAddress = fullfile(temp,'MatlabFunctions','spm12','tpm','TPM.nii');
    Segment{1}.spm.spatial.preproc.channel.vols = {VolumeAddress};
    Segment{1}.spm.spatial.preproc.channel.biasreg = 0.001;
    Segment{1}.spm.spatial.preproc.channel.biasfwhm = 60;
    Segment{1}.spm.spatial.preproc.channel.write = [0 0];
    Segment{1}.spm.spatial.preproc.tissue(1).tpm = {strcat(ProbabilityMapAddress,',1')};
    Segment{1}.spm.spatial.preproc.tissue(1).ngaus = 2;
    Segment{1}.spm.spatial.preproc.tissue(1).native = [1 0];
    Segment{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
    Segment{1}.spm.spatial.preproc.tissue(2).tpm = {strcat(ProbabilityMapAddress,',2')};
    Segment{1}.spm.spatial.preproc.tissue(2).ngaus = 2;
    Segment{1}.spm.spatial.preproc.tissue(2).native = [1 0];
    Segment{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
    Segment{1}.spm.spatial.preproc.tissue(3).tpm = {strcat(ProbabilityMapAddress,',3')};
    Segment{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
    Segment{1}.spm.spatial.preproc.tissue(3).native = [1 0];
    Segment{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
    Segment{1}.spm.spatial.preproc.tissue(4).tpm = {strcat(ProbabilityMapAddress,',4')};
    Segment{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
    Segment{1}.spm.spatial.preproc.tissue(4).native = [1 0];
    Segment{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
    Segment{1}.spm.spatial.preproc.tissue(5).tpm = {strcat(ProbabilityMapAddress,',5')};
    Segment{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
    Segment{1}.spm.spatial.preproc.tissue(5).native = [1 0];
    Segment{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
    Segment{1}.spm.spatial.preproc.tissue(6).tpm = {strcat(ProbabilityMapAddress,',6')};
    Segment{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
    Segment{1}.spm.spatial.preproc.tissue(6).native = [1 0];
    Segment{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
    Segment{1}.spm.spatial.preproc.warp.mrf = 1;
    Segment{1}.spm.spatial.preproc.warp.cleanup = 1;
    Segment{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
    Segment{1}.spm.spatial.preproc.warp.affreg = 'mni';
    Segment{1}.spm.spatial.preproc.warp.fwhm = 0;
    Segment{1}.spm.spatial.preproc.warp.samp = 3;
    Segment{1}.spm.spatial.preproc.warp.write = [0 0];
        
    MF = MessagePanel('Processing',sprintf('Process (1/2): MRI Segmentation\nThis may take some time. Please wait'));
    drawnow();
    
    %run the job
    spm_jobman('run', Segment, cell(0, 1));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %This has now dropped 7 new files into the directory where the source
    %is
    %c1FILENAME.nii Grey Matter
    %c2FILENAME.nii White Matter
    %c3FILENAME.nii CSF
    %c4FILENAME.nii Bone
    %c5FILENAME.nii Other
    %c6FILENAME.nii Air
    %FILENAME_seg8.mat Unknown  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    if(ishandle(MF))
        close(MF);
    end
    
    %Begin creating the surface
    MF = MessagePanel('Processing',sprintf('Process (2/2): Skull removal and surface generation\nThis may take some time. Please wait'));
    drawnow();
    
    %%%%%%%%
    % MASK %
    %%%%%%%%
    %Create a Volume mask for showning the 3D surface with a perfect 2D
    %volume insert
    ImageCalc{1}.spm.util.imcalc.input = { strcat(ParentFolder,filesep,'c1',FileName)
                                           strcat(ParentFolder,filesep,'c2',FileName)
                                           strcat(ParentFolder,filesep,'c3',FileName)};
    ImageCalc{1}.spm.util.imcalc.output = strcat('SurfaceMask',Name);
    ImageCalc{1}.spm.util.imcalc.outdir = {ParentFolder};
    ImageCalc{1}.spm.util.imcalc.expression = 'i1>0.3 | i2>0.3 | i3>0.3';
    ImageCalc{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    ImageCalc{1}.spm.util.imcalc.options.dmtx = 0;
    ImageCalc{1}.spm.util.imcalc.options.mask = 0;
    ImageCalc{1}.spm.util.imcalc.options.interp = 1;
    ImageCalc{1}.spm.util.imcalc.options.dtype = 4;
    
     %run the job
    spm_jobman('run', ImageCalc, cell(0, 1));
    

    %%%%%%%%%%%
    % SURFACE %
    %%%%%%%%%%%
    GreyMatterAddress = strcat(ParentFolder,filesep,'c1',FileName);
    WhiteMatterAddress = strcat(ParentFolder,filesep,'c2',FileName);
    
    %Merge Grey and White Matter and perform surface reconstruction
    Surface{1}.spm.util.render.extract.data = { strcat(ParentFolder,filesep,'c1',FileName)
                                                strcat(ParentFolder,filesep,'c2',FileName)};
    Surface{1}.spm.util.render.extract.mode = 2;
    Surface{1}.spm.util.render.extract.thresh = 0.5;
    
    %run the job
    spm_jobman('run', Surface, cell(0, 1));
    
    

    
    %%%%%%%%%%%%%%%
    % Cleaning Up %
    %%%%%%%%%%%%%%%
     
    %Remove the message
    if(ishandle(MF))
        close(MF);
    end
    
    %Collect the new items
    SurfaceAddress = strcat(ParentFolder,filesep,'c1',Name,'.surf.gii');
    SurfaceMaskAddress = strcat(ParentFolder,filesep,'SurfaceMask',Name,'.nii');
    
    %Check if there is a current Surface Directory
    if(~exist(strcat(MainMenu.UserData.SubjectStructure.DIR,filesep,'Surface'),'dir'))
        mkdir(strcat(MainMenu.UserData.SubjectStructure.DIR,filesep,'Surface'));
    end
    
    %Move the new surface items into the folder
    NewSurfaceAddress = strcat(MainMenu.UserData.SubjectStructure.DIR,filesep,'Surface',filesep,Name,'_Surface.gii');
    NewSurfaceMaskAddress = strcat(MainMenu.UserData.SubjectStructure.DIR,filesep,'Surface',filesep,Name,'_SurfaceMask.nii');
    movefile(SurfaceAddress,NewSurfaceAddress);
    movefile(SurfaceMaskAddress,NewSurfaceMaskAddress);

    %remove the unrequired files
    delete(strcat(ParentFolder,filesep,'c1',FileName));
    delete(strcat(ParentFolder,filesep,'c2',FileName));
    delete(strcat(ParentFolder,filesep,'c3',FileName));
    delete(strcat(ParentFolder,filesep,'c4',FileName));
    delete(strcat(ParentFolder,filesep,'c5',FileName));
    delete(strcat(ParentFolder,filesep,'c6',FileName));
    delete(strcat(ParentFolder,filesep,Name,'_seg8.mat'));
    
    
    %Update the SubjectStructure
    MainMenu.UserData.SubjectStructure.Volumes(MainMenu.UserData.ThreeDMenu.uiSurfacePopUp.Value).SurfaceAddress = NewSurfaceAddress;
    MainMenu.UserData.SubjectStructure.Volumes(MainMenu.UserData.ThreeDMenu.uiSurfacePopUp.Value).SurfaceMaskAddress = NewSurfaceMaskAddress;
    SaveSubject();
    
    %Update the display
    UpdateBoundingBox();
    UpdateDisplay();
end
    
%%%%%%%%%%%%%%%%%%%%%%%
% Check Box Callbacks %
%%%%%%%%%%%%%%%%%%%%%%%
function [] = AxesSettingsCheckBoxCallback(src, ~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Ensure the the size of the panel is appropiate
    Resize3DDisplayFigure();
    
    %Check if this is activating or inactivating the display panel features
    if(src.Value)
        
        %Draw a rectangle around these to separate them
        MainMenu.UserData.ThreeDMenu.uiAxesSettingsRectangle.Children(1).Visible = 'on';
        
        %Figure Background
        MainMenu.UserData.ThreeDMenu.uiAxesSettingsPopUp.Visible = true;
        MainMenu.UserData.ThreeDMenu.uiAxesSettingsText.Visible = true;
        
    else
        %Hide the options
        %Draw a rectangle around these to separate them
        MainMenu.UserData.ThreeDMenu.uiAxesSettingsRectangle.Children(1).Visible = 'off';
        
        %Figure Background
        MainMenu.UserData.ThreeDMenu.uiAxesSettingsPopUp.Visible = false;
        MainMenu.UserData.ThreeDMenu.uiAxesSettingsText.Visible = false;
    end

    %Update the display
    UpdateBoundingBox();
    UpdateDisplay();
end

function [] = ExternalDataCheckBoxCallback(src, ~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Ensure the the size of the panel is appropiate
    Resize3DDisplayFigure();
    
    %Check if this is activating or inactivating the display panel features
    if(src.Value)
        
        %Draw a rectangle around these to separate them
        MainMenu.UserData.ThreeDMenu.uiDataRectangle.Children(1).Visible = 'on';
        
        %Data Import
        MainMenu.UserData.ThreeDMenu.uiDataImportText.Visible = true;
        MainMenu.UserData.ThreeDMenu.uiDataImportButton.Visible = true;
        
        %Data Colour Map
        MainMenu.UserData.ThreeDMenu.uiDataColourMapPopUp.Visible = true;
        MainMenu.UserData.ThreeDMenu.uiDataColourMapText.Visible = true;
        
        %Data Opacitiy
        MainMenu.UserData.ThreeDMenu.uiDataOpacitiyPopUp.Visible = true;
        MainMenu.UserData.ThreeDMenu.uiDataOpacitiyText.Visible = true;
        
        %Data Index Slider
        MainMenu.UserData.ThreeDMenu.uiDataIndexSliderContainer.Visible = true;
        MainMenu.UserData.ThreeDMenu.uiDataIndexSliderText.Visible = true;
        
        %Activate the ROIs aswell
        if(~MainMenu.UserData.ThreeDMenu.uiROICheckBox.Value)
            MainMenu.UserData.ThreeDMenu.uiROICheckBox.Value = true;
            %Call the Appropiate function to instantiate this command
            ROICheckBoxCallback(MainMenu.UserData.ThreeDMenu.uiROICheckBox,MainMenu.UserData.ThreeDMenu.uiROICheckBox);
        end
        
    else
        %Hide the options
                %Draw a rectangle around these to separate them
        MainMenu.UserData.ThreeDMenu.uiDataRectangle.Children(1).Visible = 'off';
        
        %Data Import
        MainMenu.UserData.ThreeDMenu.uiDataImportText.Visible = false;
        MainMenu.UserData.ThreeDMenu.uiDataImportButton.Visible = false;
        
        %Data Colour Map
        MainMenu.UserData.ThreeDMenu.uiDataColourMapPopUp.Visible = false;
        MainMenu.UserData.ThreeDMenu.uiDataColourMapText.Visible = false;
        
        %Data Opacitiy
        MainMenu.UserData.ThreeDMenu.uiDataOpacitiyPopUp.Visible = false;
        MainMenu.UserData.ThreeDMenu.uiDataOpacitiyText.Visible = false;
        
        %Data Index Slider
        MainMenu.UserData.ThreeDMenu.uiDataIndexSliderContainer.Visible = false;
        MainMenu.UserData.ThreeDMenu.uiDataIndexSliderText.Visible = false;
        
        %Remove the Held data
        MainMenu.UserData.ThreeDMenu.DataStructure = [];
        
    end

    %Update the display
    UpdateExternalDataStructure();
    UpdateBoundingBox();
    UpdateDisplay();
end

function [] = ROILabelsCheckBoxCallback(src, ~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Ensure the the size of the panel is appropiate
    Resize3DDisplayFigure();
    
    %Check if this is activating or inactivating the display panel features
    if(src.Value)
        
        %Draw a rectangle around these to separate them
        MainMenu.UserData.ThreeDMenu.uiROILabelRectangle.Children(1).Visible = 'on';
        
        %ROI Label Colour
        MainMenu.UserData.ThreeDMenu.uiROILabelColourMapPopUp.Visible = true;
        MainMenu.UserData.ThreeDMenu.uiROILabelColourMapText.Visible = true;
        
        %ROI Label Size
        MainMenu.UserData.ThreeDMenu.uiROILabelSizeText.Visible = true;
        MainMenu.UserData.ThreeDMenu.uiROILabelSize.Visible = true;
        
%         %ROI Label Position
%         MainMenu.UserData.ThreeDMenu.uiROILabelPositionPopUp.Visible = true;
%         MainMenu.UserData.ThreeDMenu.uiROILabelPositionText.Visible = true;
        
        
    else
        %Hide the options
        %Draw a rectangle around these to separate them
        MainMenu.UserData.ThreeDMenu.uiROILabelRectangle.Children(1).Visible = 'off';
        
        %ROI Label Colour
        MainMenu.UserData.ThreeDMenu.uiROILabelColourMapPopUp.Visible = false;
        MainMenu.UserData.ThreeDMenu.uiROILabelColourMapText.Visible = false;
        
        %ROI Label Size
        MainMenu.UserData.ThreeDMenu.uiROILabelSizeText.Visible = false;
        MainMenu.UserData.ThreeDMenu.uiROILabelSize.Visible = false;
        
%         %ROI Label Position
%         MainMenu.UserData.ThreeDMenu.uiROILabelPositionPopUp.Visible = false;
%         MainMenu.UserData.ThreeDMenu.uiROILabelPositionText.Visible = false;
    end

    %Update the display
    UpdateBoundingBox();
    UpdateDisplay();
end

function [] = ROICheckBoxCallback(src, ~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Ensure the the size of the panel is appropiate
    Resize3DDisplayFigure();
    
    %Check if this is activating or inactivating the display panel features
    if(src.Value)
        
        %Draw a rectangle around these to separate them
        MainMenu.UserData.ThreeDMenu.uiROIRectangle.Children(1).Visible = 'on';
        
        %ROI Volume Selection
        MainMenu.UserData.ThreeDMenu.uiROIPopUpText.Visible = true;
        MainMenu.UserData.ThreeDMenu.uiROIPopUp.Visible = true;
        
        %ROI Colour
        MainMenu.UserData.ThreeDMenu.uiROIColourMapPopUp.Visible = true;
        MainMenu.UserData.ThreeDMenu.uiROIColourMapText.Visible = true;
        
        %ROI Size
        MainMenu.UserData.ThreeDMenu.uiROISizeText.Visible = true;
        MainMenu.UserData.ThreeDMenu.uiROISize.Visible = true;
        
        %ROI Connection
        MainMenu.UserData.ThreeDMenu.uiROIConnectionPopUp.Visible = true;
        MainMenu.UserData.ThreeDMenu.uiROIConnectionText.Visible = true;
        
        %ROI Opacitiy
        MainMenu.UserData.ThreeDMenu.uiROIOpacitiyPopUp.Visible = true;
        MainMenu.UserData.ThreeDMenu.uiROIOpacitiyText.Visible = true;
        
        
    else
        %Hide the options
        %Draw a rectangle around these to separate them
        MainMenu.UserData.ThreeDMenu.uiROIRectangle.Children(1).Visible = 'off';
        
        %ROI Volume Selection
        MainMenu.UserData.ThreeDMenu.uiROIPopUpText.Visible = false;
        MainMenu.UserData.ThreeDMenu.uiROIPopUp.Visible = false;
        
        %ROI Colour
        MainMenu.UserData.ThreeDMenu.uiROIColourMapPopUp.Visible = false;
        MainMenu.UserData.ThreeDMenu.uiROIColourMapText.Visible = false;
        
        %ROI Size
        MainMenu.UserData.ThreeDMenu.uiROISizeText.Visible = false;
        MainMenu.UserData.ThreeDMenu.uiROISize.Visible = false;
        
        %ROI Connection
        MainMenu.UserData.ThreeDMenu.uiROIConnectionPopUp.Visible = false;
        MainMenu.UserData.ThreeDMenu.uiROIConnectionText.Visible = false;
        
        %ROI Opacitiy
        MainMenu.UserData.ThreeDMenu.uiROIOpacitiyPopUp.Visible = false;
        MainMenu.UserData.ThreeDMenu.uiROIOpacitiyText.Visible = false;
        
        %If Externaldata is selected then now it needs to be deactivated
        if(MainMenu.UserData.ThreeDMenu.uiExternalDataCheckBox.Value)
           MainMenu.UserData.ThreeDMenu.uiExternalDataCheckBox.Value = false;
           %Run the deinstantiation script
           ExternalDataCheckBoxCallback(MainMenu.UserData.ThreeDMenu.uiExternalDataCheckBox,MainMenu.UserData.ThreeDMenu.uiExternalDataCheckBox);
        end
    end

    %Update the display
    UpdateBoundingBox();
    UpdateDisplay();
end

function [] = ThreeDSurfaceCheckboxCallback(src, ~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Ensure the the size of the panel is appropiate
    Resize3DDisplayFigure();
    
    %Check if this is activating or inactivating the display panel features
    if(src.Value)
        
        %Show the options
        %Rectangle 
        MainMenu.UserData.ThreeDMenu.uiSurfaceRectangle.Children(1).Visible = 'on';
        
        %Surface Creation
        MainMenu.UserData.ThreeDMenu.uiSurfacePopUpText.Visible = true;
        MainMenu.UserData.ThreeDMenu.uiSurfacePopUp.Visible = true;
        
        %Surface ColourMap
        MainMenu.UserData.ThreeDMenu.uiSurfaceColourMapPopUp.Visible = true;
        MainMenu.UserData.ThreeDMenu.uiSurfaceColourMapText.Visible = true;
        
        %Surface Opacitiy
        MainMenu.UserData.ThreeDMenu.uiSurfaceOpacitiyPopUp.Visible = true;
        MainMenu.UserData.ThreeDMenu.uiSurfaceOpacitiyText.Visible = true;
        
    else
        %Hide the options
        %Rectangle 
        MainMenu.UserData.ThreeDMenu.uiSurfaceRectangle.Children(1).Visible = 'off';
        
        %Surface Creation
        MainMenu.UserData.ThreeDMenu.uiSurfacePopUpText.Visible = false;
        MainMenu.UserData.ThreeDMenu.uiSurfacePopUp.Visible = false;
        
        %Surface ColourMap
        MainMenu.UserData.ThreeDMenu.uiSurfaceColourMapPopUp.Visible = false;
        MainMenu.UserData.ThreeDMenu.uiSurfaceColourMapText.Visible = false;
        
        %Surface Opacitiy
        MainMenu.UserData.ThreeDMenu.uiSurfaceOpacitiyPopUp.Visible = false;
        MainMenu.UserData.ThreeDMenu.uiSurfaceOpacitiyText.Visible = false;
        
        %Remove the Surface aswell
        MainMenu.UserData.ThreeDMenu.Surface = []; %Remove the surface from memory
        MainMenu.UserData.ThreeDMenu.uiSurfacePopUp.Value = size(MainMenu.UserData.ThreeDMenu.uiSurfacePopUp.String,1); %Reset the selector
        
        %Remove the SurfaceMask
        MainMenu.UserData.ThreeDMenu.Volume.MaskVolumeStructure = [];
        MainMenu.UserData.ThreeDMenu.Volume.Maskpremul = [];

        UpdateDisplay(); %Upadte the new changes
    end

    %Update the display
    UpdateBoundingBox();
    UpdateDisplay();
end

function [] = TwoDVolumeCheckboxCallback(src, ~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Ensure the the size of the panel is appropiate
    Resize3DDisplayFigure();
    
    %Check if this is activating or inactivating the display panel features
    if(src.Value)
        
        %Show the options
        %Rectangle
        MainMenu.UserData.ThreeDMenu.uiVolumeRectangle.Children(1).Visible = 'on';
            
        %VolumeSelector
        MainMenu.UserData.ThreeDMenu.uiVolumeSelectionPopUp.Visible = true;
        MainMenu.UserData.ThreeDMenu.uiVolumeSelectionText.Visible = true;
        
        %Volume ColourMap
        MainMenu.UserData.ThreeDMenu.uiVolumeColourMapPopUp.Visible = true;
        MainMenu.UserData.ThreeDMenu.uiVolumeColourMapText.Visible = true;
        
        %Volume Opacitiy
        MainMenu.UserData.ThreeDMenu.uiVolumeOpacitiyPopUp.Visible = true;
        MainMenu.UserData.ThreeDMenu.uiVolumeOpacitiyText.Visible = true;
        
        %Volume Range
        MainMenu.UserData.ThreeDMenu.uiVolumeRangePopUp.Visible = true;
        MainMenu.UserData.ThreeDMenu.uiVolumeRangeText.Visible = true;
    else
        %Hide the options
        %Rectangle
        MainMenu.UserData.ThreeDMenu.uiVolumeRectangle.Children(1).Visible = 'off';
            
        %VolumeSelector
        MainMenu.UserData.ThreeDMenu.uiVolumeSelectionPopUp.Visible = false;
        MainMenu.UserData.ThreeDMenu.uiVolumeSelectionText.Visible = false;
        
        %Volume ColourMap
        MainMenu.UserData.ThreeDMenu.uiVolumeColourMapPopUp.Visible = false;
        MainMenu.UserData.ThreeDMenu.uiVolumeColourMapText.Visible = false;
        
        %Volume Opacitiy
        MainMenu.UserData.ThreeDMenu.uiVolumeOpacitiyPopUp.Visible = false;
        MainMenu.UserData.ThreeDMenu.uiVolumeOpacitiyText.Visible = false;
        
        %Volume Range
        MainMenu.UserData.ThreeDMenu.uiVolumeRangePopUp.Visible = false;
        MainMenu.UserData.ThreeDMenu.uiVolumeRangeText.Visible = false;
        
        %Inactivate the Selection
        MainMenu.UserData.ThreeDMenu.uiVolumeSelectionPopUp.Value = size(MainMenu.UserData.ThreeDMenu.uiVolumeSelectionPopUp.String,1);
    end

    %Update the display
    UpdateBoundingBox();
    UpdateDisplay();
end

%%%%%%%%%%%
% Utility %
%%%%%%%%%%%
function [] = Resize3DDisplayFigure()

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Check if any of the options have been selected
    if(MainMenu.UserData.ThreeDMenu.ui2DVolumeCheckBox.Value || MainMenu.UserData.ThreeDMenu.ui3DSurfaceCheckBox.Value || MainMenu.UserData.ThreeDMenu.uiROICheckBox.Value || MainMenu.UserData.ThreeDMenu.uiROILabelsCheckBox.Value || MainMenu.UserData.ThreeDMenu.uiExternalDataCheckBox.Value || MainMenu.UserData.ThreeDMenu.uiAxesSettingsCheckBox.Value)
        
        %Resize the Figure
        MainMenu.UserData.ThreeDMenu.Handle.Position = MainMenu.UserData.ThreeDMenu.FullPosition;
        
        %Move the Settings rectangle and checkboxes
        uiDisplayFullYOffset = MainMenu.UserData.ThreeDMenu.uiDisplayFullYOffset;
        RectangleRelief = MainMenu.UserData.ThreeDMenu.RectangleRelief;
        MainMenu.UserData.ThreeDMenu.uiDisplayRectangle.Position(2) = uiDisplayFullYOffset(2)-RectangleRelief;
            
        %Text to indicate the options
        MainMenu.UserData.ThreeDMenu.uiDisplayText.Position(2) = uiDisplayFullYOffset(1);
        
        %2D Volume Checkbox
        MainMenu.UserData.ThreeDMenu.ui2DVolumeCheckBox.Position(2) = uiDisplayFullYOffset(1);
        
        %3D Surface Checkbox
        MainMenu.UserData.ThreeDMenu.ui3DSurfaceCheckBox.Position(2) = uiDisplayFullYOffset(2);
        
        %ROI Checkbox
        MainMenu.UserData.ThreeDMenu.uiROICheckBox.Position(2) = uiDisplayFullYOffset(1);
        
        %ROI Lables Checkbox
        MainMenu.UserData.ThreeDMenu.uiROILabelsCheckBox.Position(2) = uiDisplayFullYOffset(2);
        
        %External Data Checkbox
        MainMenu.UserData.ThreeDMenu.uiExternalDataCheckBox.Position(2) = uiDisplayFullYOffset(1);
        
        %Axes Settings Checkbox
        MainMenu.UserData.ThreeDMenu.uiAxesSettingsCheckBox.Position(2) = uiDisplayFullYOffset(2);
        
        %RangeSlider Rectangle
        MainMenu.UserData.ThreeDMenu.uiCutRectangle.Children(1).Visible = 'on';
        
        %X Range Slider
        MainMenu.UserData.ThreeDMenu.uiVolumeXRangeSliderText.Visible = true;
        MainMenu.UserData.ThreeDMenu.uiVolumeXRangeSliderContainer.Visible = true;
        
        %Y Range Slider
        MainMenu.UserData.ThreeDMenu.uiVolumeYRangeSliderText.Visible = true;
        MainMenu.UserData.ThreeDMenu.uiVolumeYRangeSliderContainer.Visible = true;
        
        %Z Range Slider
        MainMenu.UserData.ThreeDMenu.uiVolumeZRangeSliderText.Visible = true;
        MainMenu.UserData.ThreeDMenu.uiVolumeZRangeSliderContainer.Visible = true;
        
    else
        %Resize the Figure
        MainMenu.UserData.ThreeDMenu.Handle.Position = MainMenu.UserData.ThreeDMenu.SimplePosition;
        
        %Move the Settings rectangle and checkboxes
        uiDisplayYOffset = MainMenu.UserData.ThreeDMenu.uiDisplayYOffset;
        RectangleRelief = MainMenu.UserData.ThreeDMenu.RectangleRelief;
        MainMenu.UserData.ThreeDMenu.uiDisplayRectangle.Position(2) = uiDisplayYOffset(2)-RectangleRelief;
            
        %Text to indicate the options
        MainMenu.UserData.ThreeDMenu.uiDisplayText.Position(2) = uiDisplayYOffset(1);
        
        %2D Volume Checkbox
        MainMenu.UserData.ThreeDMenu.ui2DVolumeCheckBox.Position(2) = uiDisplayYOffset(1);
        
        %3D Surface Checkbox
        MainMenu.UserData.ThreeDMenu.ui3DSurfaceCheckBox.Position(2) = uiDisplayYOffset(2);
        
        %ROI Checkbox
        MainMenu.UserData.ThreeDMenu.uiROICheckBox.Position(2) = uiDisplayYOffset(1);
        
        %ROI Lables Checkbox
        MainMenu.UserData.ThreeDMenu.uiROILabelsCheckBox.Position(2) = uiDisplayYOffset(2);
        
        %External Data Checkbox
        MainMenu.UserData.ThreeDMenu.uiExternalDataCheckBox.Position(2) = uiDisplayYOffset(1);
        
        %Axes Settings Checkbox
        MainMenu.UserData.ThreeDMenu.uiAxesSettingsCheckBox.Position(2) = uiDisplayYOffset(2);
        
        %RangeSlider Rectangle
        MainMenu.UserData.ThreeDMenu.uiCutRectangle.Children(1).Visible = 'off';
        
        %X Range Slider
        MainMenu.UserData.ThreeDMenu.uiVolumeXRangeSliderText.Visible = false;
        MainMenu.UserData.ThreeDMenu.uiVolumeXRangeSliderContainer.Visible = false;
        
        %Y Range Slider
        MainMenu.UserData.ThreeDMenu.uiVolumeYRangeSliderText.Visible = false;
        MainMenu.UserData.ThreeDMenu.uiVolumeYRangeSliderContainer.Visible = false;
        
        %Z Range Slider
        MainMenu.UserData.ThreeDMenu.uiVolumeZRangeSliderText.Visible = false;
        MainMenu.UserData.ThreeDMenu.uiVolumeZRangeSliderContainer.Visible = false;
    end     

end

function [] = UpdateBoundingBox()

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Find all the possible items which may influence the bounding box
    GlobalBoundingBox = [  -1, -1, -1;
                           1, 1, 1];
                
   %Surface
   if(~isempty(MainMenu.UserData.ThreeDMenu.Surface))
       
       %Find the Largest XYZ poisitions
       minbb = double(min(MainMenu.UserData.ThreeDMenu.Surface.vertices));
       maxbb = double(max(MainMenu.UserData.ThreeDMenu.Surface.vertices));
       GlobalBoundingBox = [  min( [GlobalBoundingBox(1,:); minbb;]) ;
                              max( [GlobalBoundingBox(2,:); maxbb;]) ;];
   end
    
   %ROIs
   if(MainMenu.UserData.ThreeDMenu.uiROICheckBox.Value)
       ROIStruct = MainMenu.UserData.SubjectStructure.Volumes(MainMenu.UserData.ThreeDMenu.uiROIPopUp.Value).ROIs;
       if(~isempty(ROIStruct))
           
           %Find the Largest XYZ poisitions
           minbb = min(vertcat(ROIStruct.XYZ));
           maxbb = max(vertcat(ROIStruct.XYZ));
           GlobalBoundingBox = [min( [GlobalBoundingBox(1,:); minbb;]) ;
                                max( [GlobalBoundingBox(2,:); maxbb;]) ;];
           
       end
   end
   
   %Volume
   if(MainMenu.UserData.ThreeDMenu.ui2DVolumeCheckBox.Value)
       if(~isempty(MainMenu.UserData.ThreeDMenu.Volume.VolumeStructure))
           GlobalBoundingBox = [  min( [GlobalBoundingBox(1,:); MainMenu.UserData.ThreeDMenu.Volume.BoundingBox(1,:);]) ;
                                  max( [GlobalBoundingBox(2,:); MainMenu.UserData.ThreeDMenu.Volume.BoundingBox(2,:);]) ;];
       end     
   end
   
   %Load Sliders
   XRS = MainMenu.UserData.ThreeDMenu.uiVolumeXRangeSlider;
   YRS = MainMenu.UserData.ThreeDMenu.uiVolumeYRangeSlider;
   ZRS = MainMenu.UserData.ThreeDMenu.uiVolumeZRangeSlider;
    
   %Get Current Values
   XRSLcurrent = XRS.getLowValue();
   YRSLcurrent = YRS.getLowValue();
   ZRSLcurrent = ZRS.getLowValue();
   XRSHcurrent = XRS.getHighValue();
   YRSHcurrent = YRS.getHighValue();
   ZRSHcurrent = ZRS.getHighValue();
   
   %Move the Current Values to within the boundries ONLY if they are
   %outside
   if( XRSLcurrent<floor(GlobalBoundingBox(1,1)) || YRSLcurrent<floor(GlobalBoundingBox(1,2)) || ZRSLcurrent<floor(GlobalBoundingBox(1,3)) || XRSHcurrent>ceil(GlobalBoundingBox(2,1)) || YRSHcurrent>ceil(GlobalBoundingBox(2,2)) || ZRSHcurrent>ceil(GlobalBoundingBox(2,3)))
       XRS.setLowValue(floor(GlobalBoundingBox(1,1)));
       YRS.setLowValue(floor(GlobalBoundingBox(1,2)));
       ZRS.setLowValue(floor(GlobalBoundingBox(1,3)));
       XRS.setHighValue(ceil(GlobalBoundingBox(2,1)));
       YRS.setHighValue(ceil(GlobalBoundingBox(2,2)));
       ZRS.setHighValue(ceil(GlobalBoundingBox(2,3)));
   end
   
   %Update the XYZ Limits bounderies
   %Minimums
   XRS.setMinimum(floor(GlobalBoundingBox(1,1)));
   YRS.setMinimum(floor(GlobalBoundingBox(1,2)));
   ZRS.setMinimum(floor(GlobalBoundingBox(1,3)));
   %Maximums
   XRS.setMaximum(ceil(GlobalBoundingBox(2,1)));
   YRS.setMaximum(ceil(GlobalBoundingBox(2,2)));
   ZRS.setMaximum(ceil(GlobalBoundingBox(2,3)));
   %UpdateTicks
   XRS.setMajorTickSpacing(round(diff(GlobalBoundingBox(:,1))./4));
   YRS.setMajorTickSpacing(round(diff(GlobalBoundingBox(:,2))./4));
   ZRS.setMajorTickSpacing(round(diff(GlobalBoundingBox(:,3))./4));
   XRS.setMinorTickSpacing(round(diff(GlobalBoundingBox(:,1))./16));
   YRS.setMinorTickSpacing(round(diff(GlobalBoundingBox(:,2))./16));
   ZRS.setMinorTickSpacing(round(diff(GlobalBoundingBox(:,3))./16));
   XRS.setLabelTable(XRS.createStandardLabels(round(diff(GlobalBoundingBox(:,1))./4)));
   YRS.setLabelTable(YRS.createStandardLabels(round(diff(GlobalBoundingBox(:,1))./4)));
   ZRS.setLabelTable(ZRS.createStandardLabels(round(diff(GlobalBoundingBox(:,1))./4)));
   
   %Save Values
   MainMenu.UserData.ThreeDMenu.BoundingBox = GlobalBoundingBox;
   
end

function [] = UpdateLighting(src,event)

% %     %%%%%%%%%%%%%%%%%%%%%%%%%%
% %     % Find the MainMenu      %
% %     MainMenu = FindMainMenu; % 
% %     if(isempty(MainMenu))    %
% %         QuitFunction();      %
% %         return;              %
% %     end                      %
% %     %%%%%%%%%%%%%%%%%%%%%%%%%%
% %     
% %     if(isempty(MainMenu.UserData.ThreeDMenu.Camlight))
% %         MainMenu.UserData.ThreeDMenu.Camlight = camlight(MainMenu.UserData.ThreeDMenu.Axes,'headlight');
% %     else
% %         camlight(MainMenu.UserData.ThreeDMenu.Camlight,'headlight');
% %     end

end

function [] = UpdateExternalDataStructure()
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %if this function is not required
    if(isempty(MainMenu.UserData.ThreeDMenu.DataStructure))
        MainMenu.UserData.ThreeDMenu.DisplayStructure = MainMenu.UserData.SubjectStructure.Volumes(MainMenu.UserData.ThreeDMenu.uiROIPopUp.Value).ROIs;
        return;
    end
    
    %Collect the Imported Data
    DataStructure = MainMenu.UserData.ThreeDMenu.DataStructure;
    ROIStructure = MainMenu.UserData.SubjectStructure.Volumes(MainMenu.UserData.ThreeDMenu.uiROIPopUp.Value).ROIs;
    
    %Copy the True data
    DisplayStructure = ROIStructure;
    
    %Null choice: none of them are actually externaldata
    [DisplayStructure.External] = deal(false);
    [DisplayStructure.Data] = deal(0);
    
    %Mark those that are external and populate the data
    ROILabels = {ROIStructure.Label};
    for i = 1:size(DataStructure,2)
        ROIidx = find(strcmp(ROILabels,DataStructure(i).Label));
        
        %Copy data into the structure
        DisplayStructure(ROIidx).External = true;
        DisplayStructure(ROIidx).Data = DataStructure(i).Data;
        
    end
    
    %Save the data
    MainMenu.UserData.ThreeDMenu.DisplayStructure = DisplayStructure;
end

%%%%%%%%%%%%%%%%%
% Axes Creation %
%%%%%%%%%%%%%%%%%
function [] = CreateThreeDAxes(VolumeNumber)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Collect the World dimensions and Bounding Box from the volume input
    MainMenu.UserData.ThreeDMenu.VolumeStructure = spm_vol(MainMenu.UserData.SubjectStructure.Volumes(VolumeNumber).FileAddress);
    MainMenu.UserData.ThreeDMenu.VolumeStructure.premul = eye(4);
    MainMenu.UserData.ThreeDMenu.BoundingBox = spm_get_bbox(MainMenu.UserData.ThreeDMenu.VolumeStructure);
    MainMenu.UserData.ThreeDMenu.WorldDimensions = round(diff(MainMenu.UserData.ThreeDMenu.BoundingBox)'+1);

    Axes = axes('units','pixels','Position',MainMenu.UserData.ThreeDMenu.AxesArea, 'Visible',true,'PlotBoxAspectRatioMode','Manual',...
        'Box','on',...
        'XLim', MainMenu.UserData.ThreeDMenu.BoundingBox(:,1),...
        'YLim',MainMenu.UserData.ThreeDMenu.BoundingBox(:,2),...
        'ZLim',MainMenu.UserData.ThreeDMenu.BoundingBox(:,3));
    RotateObj = rotate3d; %Create Rotation point
    RotateObj.RotateStyle = 'box'; %Contains the image into the axes 
    %RotateObj.ActionPostCallback = @UpdateLighting;
    RotateObj.Enable = 'on';
    MainMenu.UserData.ThreeDMenu.Axes = Axes;
    MainMenu.UserData.ThreeDMenu.Camlight = [];
    
    xlabel(Axes,'X');
    ylabel(Axes,'Y');
    zlabel(Axes,'Z');
    
end

%%%%%%%%%%%%%%%%%%%%%
% Display Functions %
%%%%%%%%%%%%%%%%%%%%%
function [] = UpdateDisplay(~,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    cla(MainMenu.UserData.ThreeDMenu.Axes);
    hold(MainMenu.UserData.ThreeDMenu.Axes,'on');
    GlobalBoundingBox = MainMenu.UserData.ThreeDMenu.BoundingBox;
    
    axis(MainMenu.UserData.ThreeDMenu.Axes,GlobalBoundingBox(:)');
    
    XLIM = [MainMenu.UserData.ThreeDMenu.uiVolumeXRangeSlider.getLowValue(), MainMenu.UserData.ThreeDMenu.uiVolumeXRangeSlider.getHighValue()];
    YLIM = [MainMenu.UserData.ThreeDMenu.uiVolumeYRangeSlider.getLowValue(), MainMenu.UserData.ThreeDMenu.uiVolumeYRangeSlider.getHighValue()];
    ZLIM = [MainMenu.UserData.ThreeDMenu.uiVolumeZRangeSlider.getLowValue(), MainMenu.UserData.ThreeDMenu.uiVolumeZRangeSlider.getHighValue()];
    
  
    
    %%%%%%%%%%
    % Volume %
    %%%%%%%%%%
    if(~isempty(MainMenu.UserData.ThreeDMenu.Volume.VolumeStructure) && MainMenu.UserData.ThreeDMenu.ui2DVolumeCheckBox.Value)

        
        %Collect the six planes required
        % Right
        % Left
        % Superior
        % Inferior
        % Anterior
        % Posterior
        
        %Affine
        M = eye(4)\MainMenu.UserData.ThreeDMenu.Volume.premul*MainMenu.UserData.ThreeDMenu.VolumeStructure.mat;
                
        %Superior
        SM0 = [ 1 0 0 -GlobalBoundingBox(1,1)+1
                0 1 0 -GlobalBoundingBox(1,2)+1
                0 0 1 -ZLIM(2)
                0 0 0 1];
        SM = inv(SM0*M);
        SD = MainMenu.UserData.ThreeDMenu.Volume.WorldDimensions([1 2]);
        
        %Inferior
        IM0 = [ 1 0 0 -GlobalBoundingBox(1,1)+1
                0 1 0 -GlobalBoundingBox(1,2)+1
                0 0 1 -ZLIM(1)
                0 0 0 1];
        IM = inv(IM0*M);
        ID = MainMenu.UserData.ThreeDMenu.Volume.WorldDimensions([1 2]);
        
        %Anterior
        AM0 = [ 1 0 0 -GlobalBoundingBox(1,1)+1
                0 0 1 -GlobalBoundingBox(1,3)+1
                0 1 0 -YLIM(2)
                0 0 0 1];
        AM = inv(AM0*M);
        AD = MainMenu.UserData.ThreeDMenu.Volume.WorldDimensions([1 3]);
        
        %Posterior
        PM0 = [ 1 0 0 -GlobalBoundingBox(1,1)+1
                0 0 1 -GlobalBoundingBox(1,3)+1
                0 1 0 -YLIM(1)
                0 0 0 1];
        PM = inv(PM0*M);
        PD = MainMenu.UserData.ThreeDMenu.Volume.WorldDimensions([1 3]);
        
        %Right
        RM0 = [ 0 -1 0 +GlobalBoundingBox(2,2)+1
                0  0 1 -GlobalBoundingBox(1,3)+1
                1  0 0 -XLIM(2)
                0  0 0 1];
        RM = inv(RM0*M);
        RD = MainMenu.UserData.ThreeDMenu.Volume.WorldDimensions([2 3]);
        
        %Left
        LM0 = [ 0 -1 0 +GlobalBoundingBox(2,2)+1
                0  0 1 -GlobalBoundingBox(1,3)+1
                1  0 0 -XLIM(1)
                0  0 0 1];
        LM = inv(LM0*M);
        LD = MainMenu.UserData.ThreeDMenu.Volume.WorldDimensions([2 3]);     
        
        %Cut Images
        RIGHTimg = spm_slice_vol(MainMenu.UserData.ThreeDMenu.Volume.VolumeStructure,RM,RD,1)';
        ANTERIORimg = spm_slice_vol(MainMenu.UserData.ThreeDMenu.Volume.VolumeStructure,AM,AD,1)';
        SUPERIORimg = spm_slice_vol(MainMenu.UserData.ThreeDMenu.Volume.VolumeStructure,SM,SD,1)';
        LEFTimg = spm_slice_vol(MainMenu.UserData.ThreeDMenu.Volume.VolumeStructure,LM,LD,1)';
        POSTERIORimg = spm_slice_vol(MainMenu.UserData.ThreeDMenu.Volume.VolumeStructure,PM,PD,1)';
        INFERIORimg = spm_slice_vol(MainMenu.UserData.ThreeDMenu.Volume.VolumeStructure,IM,ID,1)';

        %Not actually doing anything
%         Maximum = max( vertcat(RIGHTimg(:), ANTERIORimg(:), SUPERIORimg(:), LEFTimg(:), POSTERIORimg(:), INFERIORimg(:)));
%         Minimum = min( vertcat(RIGHTimg(:), ANTERIORimg(:), SUPERIORimg(:), LEFTimg(:), POSTERIORimg(:), INFERIORimg(:)));
%         RIGHTimg =      (RIGHTimg - Minimum)./Maximum;
%         ANTERIORimg =   (ANTERIORimg - Minimum)./Maximum;
%         SUPERIORimg =   (SUPERIORimg - Minimum)./Maximum;
%         LEFTimg =       (LEFTimg - Minimum)./Maximum;
%         POSTERIORimg =  (POSTERIORimg - Minimum)./Maximum;
%         INFERIORimg =   (INFERIORimg - Minimum)./Maximum;
        
        %Interpolate spacing
        XTick = linspace(GlobalBoundingBox(1,1),GlobalBoundingBox(2,1),MainMenu.UserData.ThreeDMenu.Volume.WorldDimensions(1));
        YTick = linspace(GlobalBoundingBox(1,2),GlobalBoundingBox(2,2),MainMenu.UserData.ThreeDMenu.Volume.WorldDimensions(2));
        ZTick = linspace(GlobalBoundingBox(1,3),GlobalBoundingBox(2,3),MainMenu.UserData.ThreeDMenu.Volume.WorldDimensions(3));
        
        %Alpha
        Alpha = str2double(strrep(MainMenu.UserData.ThreeDMenu.uiVolumeOpacitiyPopUp.String{MainMenu.UserData.ThreeDMenu.uiVolumeOpacitiyPopUp.Value},'%',''))/100;
        
        
        %Mark if we are using a MASK
        if(~isempty(MainMenu.UserData.ThreeDMenu.Volume.MaskVolumeStructure))
            MASK = true;
        else
            MASK = false;
        end
        
        %Load the SurfaceMask if one exists
        if(MASK)
            %Use the Surface Mask to hide the exteriror of the surface
            MaskM = eye(4)\MainMenu.UserData.ThreeDMenu.Volume.Maskpremul*MainMenu.UserData.ThreeDMenu.Volume.MaskVolumeStructure.mat;
                
            %Superior
            SM = inv(SM0*MaskM);
            
            %Inferior
            IM = inv(IM0*MaskM);
            
            %Anterior
            AM = inv(AM0*MaskM);
            
            %Posterior
            PM = inv(PM0*MaskM);
            
            %Right
            RM = inv(RM0*MaskM);
            
            %Left
            LM = inv(LM0*MaskM);
            
            %Cut Images
            RIGHTMaskimg =      Alpha.*spm_slice_vol(MainMenu.UserData.ThreeDMenu.Volume.MaskVolumeStructure,RM,RD,1)';
            ANTERIORMaskimg =   Alpha.*spm_slice_vol(MainMenu.UserData.ThreeDMenu.Volume.MaskVolumeStructure,AM,AD,1)';
            SUPERIORMaskimg =   Alpha.*spm_slice_vol(MainMenu.UserData.ThreeDMenu.Volume.MaskVolumeStructure,SM,SD,1)';
            LEFTMaskimg =       Alpha.*spm_slice_vol(MainMenu.UserData.ThreeDMenu.Volume.MaskVolumeStructure,LM,LD,1)';
            POSTERIORMaskimg =  Alpha.*spm_slice_vol(MainMenu.UserData.ThreeDMenu.Volume.MaskVolumeStructure,PM,PD,1)';
            INFERIORMaskimg =   Alpha.*spm_slice_vol(MainMenu.UserData.ThreeDMenu.Volume.MaskVolumeStructure,IM,ID,1)';

        else
            RIGHTMaskimg =      Alpha;
            ANTERIORMaskimg =   Alpha;
            SUPERIORMaskimg =   Alpha;
            LEFTMaskimg =       Alpha;
            POSTERIORMaskimg =  Alpha;
            INFERIORMaskimg =   Alpha;

        end
      
        
        %%%%%%%%%%%%%%%%%%%%%%
        % Display the slices %
        %%%%%%%%%%%%%%%%%%%%%%
        
        %Right (XLIM(2) = Largest X)
        surface(repmat(XLIM(2),1,length(ZTick)),fliplr(YTick),repmat(ZTick,length(YTick),1),RIGHTimg','FaceColor','texturemap','FaceAlpha','texturemap','AlphaData',RIGHTMaskimg','AlphaDataMapping','none','EdgeColor','none','CDataMapping','scaled','Parent',MainMenu.UserData.ThreeDMenu.Axes);

        %Left (XLIM(1) = Smallest X)
        surface(repmat(XLIM(1),1,length(ZTick)),fliplr(YTick),repmat(ZTick,length(YTick),1),LEFTimg','FaceColor','texturemap','FaceAlpha','texturemap','AlphaData',LEFTMaskimg','AlphaDataMapping','none','EdgeColor','none','CDataMapping','scaled','Parent',MainMenu.UserData.ThreeDMenu.Axes);
        
        %Anterior
        surface(XTick,repmat(YLIM(2),1,length(ZTick)),repmat(ZTick,length(XTick),1)',ANTERIORimg,'FaceColor','texturemap','FaceAlpha','texturemap','AlphaData',ANTERIORMaskimg,'AlphaDataMapping','none','EdgeColor','none','CDataMapping','scaled','Parent',MainMenu.UserData.ThreeDMenu.Axes);
         
        %Posterior
        surface(XTick,repmat(YLIM(1),1,length(ZTick)),repmat(ZTick,length(XTick),1)',POSTERIORimg,'FaceColor','texturemap','FaceAlpha','texturemap','AlphaData',POSTERIORMaskimg,'AlphaDataMapping','none','EdgeColor','none','CDataMapping','scaled','Parent',MainMenu.UserData.ThreeDMenu.Axes);
         
        %Superior
        surface(XTick,YTick,repmat(ZLIM(2),length(YTick),length(XTick)),SUPERIORimg,'FaceColor','texturemap','FaceAlpha','texturemap','AlphaData',SUPERIORMaskimg,'AlphaDataMapping','none','EdgeColor','none','CDataMapping','scaled','Parent',MainMenu.UserData.ThreeDMenu.Axes);
         
        %Inferior
        surface(XTick,YTick,repmat(ZLIM(1),length(YTick),length(XTick)),INFERIORimg,'FaceColor','texturemap','FaceAlpha','texturemap','AlphaData',INFERIORMaskimg,'AlphaDataMapping','none','EdgeColor','none','CDataMapping','scaled','Parent',MainMenu.UserData.ThreeDMenu.Axes);
         
        
        %Colourmap
        colormap(MainMenu.UserData.ThreeDMenu.uiVolumeColourMapPopUp.String{MainMenu.UserData.ThreeDMenu.uiVolumeColourMapPopUp.Value});
        
        %Range
        RangePRC = MainMenu.UserData.ThreeDMenu.uiVolumeRangePopUp.String{MainMenu.UserData.ThreeDMenu.uiVolumeRangePopUp.Value}(1:end-1);
        RangePRC = strsplit(RangePRC,' - ');
        RangePRC = [str2double(RangePRC(1)) str2double(RangePRC(2))];
        
%         Range = MainMenu.UserData.ThreeDMenu.Volume.Range;
%         RangePRC = MainMenu.UserData.ThreeDMenu.uiVolumeRangePopUp.String{MainMenu.UserData.ThreeDMenu.uiVolumeRangePopUp.Value}(1:end-1);
%         RangePRC = strsplit(RangePRC,' - ');
%         RangePRC = str2double(RangePRC(1))./100;
%         DisplayRange = [Range(1)+RangePRC(1)*diff(Range), Range(2)-RangePRC(1)*diff(Range)];
        caxis(prctile( vertcat(RIGHTimg(:), LEFTimg(:), ANTERIORimg(:), POSTERIORimg(:), SUPERIORimg(:), INFERIORimg(:)),RangePRC));
        
    end
       
    %%%%%%%%%%%
    % Surface %
    %%%%%%%%%%%
    if(~isempty(MainMenu.UserData.ThreeDMenu.Surface))
        
        
        
        tmp = MainMenu.UserData.ThreeDMenu.Surface;
        
        %Find all faces who have there vertices outside the limits
        
        Vert1 = tmp.vertices(tmp.faces(:,1),:);
        Vert2 = tmp.vertices(tmp.faces(:,2),:);
        Vert3 = tmp.vertices(tmp.faces(:,3),:);
        
        %Check which have all three verticies outside
        Vert1 = Vert1(:,1) >= XLIM(1) & Vert1(:,1) <=XLIM(2) & ... X1 
                Vert1(:,2) >= YLIM(1) & Vert1(:,2) <=YLIM(2) & ... Y1 
                Vert1(:,3) >= ZLIM(1) & Vert1(:,3) <= ZLIM(2);%     Z1 
            
        Vert2 = Vert2(:,1) >= XLIM(1) & Vert2(:,1) <= XLIM(2) & ... X2
                Vert2(:,2) >= YLIM(1) & Vert2(:,2) <= YLIM(2) & ... Y2
                Vert2(:,3) >= ZLIM(1) & Vert2(:,3) <= ZLIM(2);%     Z2
        
        Vert3 = Vert3(:,1) >= XLIM(1) & Vert3(:,1) <= XLIM(2) & ... X3
                Vert3(:,2) >= YLIM(1) & Vert3(:,2) <= YLIM(2) & ... Y3
                Vert3(:,3) >= ZLIM(1) & Vert3(:,3) <= ZLIM(2);%     Z3
        
        %Retention of Faces completely outside the viewable range
        tmp.faces = tmp.faces(Vert1 | Vert2 | Vert3 ,:);
        
        %Clean up the verticies that are partially inside/outside
        tmp.vertices(tmp.vertices(:,1) < XLIM(1),1) = XLIM(1);
        tmp.vertices(tmp.vertices(:,1) > XLIM(2),1) = XLIM(2);
        tmp.vertices(tmp.vertices(:,2) < YLIM(1),2) = YLIM(1);
        tmp.vertices(tmp.vertices(:,2) > YLIM(2),2) = YLIM(2);
        tmp.vertices(tmp.vertices(:,3) < ZLIM(1),3) = ZLIM(1);
        tmp.vertices(tmp.vertices(:,3) > ZLIM(2),3) = ZLIM(2);
        
       
        patch(  'Faces',tmp.faces,...
                'Vertices',tmp.vertices,...
                'EdgeColor','none',...
                'LineStyle','none',...
                'FaceColor',MainMenu.UserData.ThreeDMenu.uiSurfaceColourMapPopUp.String{MainMenu.UserData.ThreeDMenu.uiSurfaceColourMapPopUp.Value},...
                'FaceAlpha',str2double(strrep(MainMenu.UserData.ThreeDMenu.uiSurfaceOpacitiyPopUp.String{MainMenu.UserData.ThreeDMenu.uiSurfaceOpacitiyPopUp.Value},'%',''))/100,...
                'Parent',MainMenu.UserData.ThreeDMenu.Axes);

        
        %%%%%%%%%%    
        %Paint a patch representing the cutout portion
        %%%%%%%%%%
        %Identify the X Plane points to establish the YZ
%         RIGHTvert = tmp.vertices(:,1) == XLIM(1);
%         RIGHTXYZ = tmp.vertices(RIGHTvert,:);
%         RIGHTYZmask = false(diff(YLIM)+1,diff(ZLIM)+1); %1mm 
%         YtoIDX = round(RIGHTXYZ(:,2)- min(YLIM) +1);
%         ZtoIDX = round(RIGHTXYZ(:,3)- min(ZLIM) +1);
%         RIGHTYZmask(sub2ind(size(RIGHTYZmask),YtoIDX, ZtoIDX)) = true;%figure;imagesc(RIGHTYZmask);
        
        %plot3(RIGHTXYZ(:,1),RIGHTXYZ(:,2),RIGHTXYZ(:,3),'b.')
    end
    
    %%%%%%%%%%%%%%
    % ROI Labels %
    %%%%%%%%%%%%%%
    if(MainMenu.UserData.ThreeDMenu.uiROILabelsCheckBox.Value)
        
        %Load the Data
        ROIStruct = MainMenu.UserData.SubjectStructure.Volumes(MainMenu.UserData.ThreeDMenu.uiROIPopUp.Value).ROIs;
        
        %Check if there are ROIs to display
        if(~isempty(ROIStruct))
            LabelColour = MainMenu.UserData.ThreeDMenu.uiROILabelColourMapPopUp.String{MainMenu.UserData.ThreeDMenu.uiROILabelColourMapPopUp.Value};
            FontSize = str2double(MainMenu.UserData.ThreeDMenu.uiROILabelSize.String);
            [az,el] = view();
            [XOffset,YOffset,ZOffset] = sph2cart(az,el,str2double(MainMenu.UserData.ThreeDMenu.uiROISize.String));
            for R = 1:size(ROIStruct,2)
                %Place text objects for the designators
                text(ROIStruct(R).XYZ(1)+XOffset,ROIStruct(R).XYZ(2)+YOffset,ROIStruct(R).XYZ(3)+ZOffset,ROIStruct(R).Label,'VerticalAlignment','middle','HorizontalAlignment','center','Color',LabelColour,'FontSize',FontSize,'Interpreter','none','Parent',MainMenu.UserData.ThreeDMenu.Axes);
            end
            
        end
    end
    
    %%%%%%%%%%%%%%%%%
    % External Data %
    %%%%%%%%%%%%%%%%%
    if(isfield(MainMenu.UserData.ThreeDMenu.DisplayStructure,'Data'))
        
        %Mask the ROIs to match on the DataStructure
        DisplayStructure = MainMenu.UserData.ThreeDMenu.DisplayStructure;
        
        %Check if there are ROIs to display
        if(~isempty(DisplayStructure))
        
            %Parameters for later
            Colour = MainMenu.UserData.ThreeDMenu.uiROIColourMapPopUp.String{MainMenu.UserData.ThreeDMenu.uiROIColourMapPopUp.Value};
            ColourMap = MainMenu.UserData.ThreeDMenu.ColourMap;
            ROIAlpha = str2double(strrep(MainMenu.UserData.ThreeDMenu.uiROIOpacitiyPopUp.String{MainMenu.UserData.ThreeDMenu.uiROIOpacitiyPopUp.Value},'%',''))/100;
            DataAlpha = str2double(strrep(MainMenu.UserData.ThreeDMenu.uiDataOpacitiyPopUp.String{MainMenu.UserData.ThreeDMenu.uiDataOpacitiyPopUp.Value},'%',''))/100;
            Size = str2double(MainMenu.UserData.ThreeDMenu.uiROISize.String)./2; %The created Sphere is -1 to 1, halving the size means unit size
            [X,Y,Z] = sphere(50);   
            X = X.*Size;
            Y = Y.*Size;
            Z = Z.*Size;
            
            %%%%%%%%%%%%%%%%
            % Regular ROIs %
            %%%%%%%%%%%%%%%%
            for R = 1:size(DisplayStructure,2)
                
                if(~DisplayStructure(R).External)
                    surf(X  +DisplayStructure(R).XYZ(1),...
                         Y  +DisplayStructure(R).XYZ(2),...
                         Z  +DisplayStructure(R).XYZ(3),...
                         'EdgeColor','none',...
                         'FaceColor',Colour,...
                         'FaceAlpha',ROIAlpha,...
                         'Parent',MainMenu.UserData.ThreeDMenu.Axes);
                end
            end
            
            %%%%%%%%%%%%%%%%%%%%%%
            % EXTERNAL DATA ROIs %
            %%%%%%%%%%%%%%%%%%%%%%
            IDX = MainMenu.UserData.ThreeDMenu.uiDataIndexSlider.getValue();
            %Identify Range
            Data = arrayfun(@(x) x.Data(IDX), DisplayStructure([DisplayStructure.External]));
            Range = prctile(Data, [0 100]);
            for R = 1:size(DisplayStructure,2)
                if(DisplayStructure(R).External)
                    if(isfinite(DisplayStructure(R).Data(IDX)))
                        surface(X  +DisplayStructure(R).XYZ(1),...
                                Y  +DisplayStructure(R).XYZ(2),...
                                Z  +DisplayStructure(R).XYZ(3),...
                                'EdgeColor','none',...
                                'FaceColor',ColourMap(1+ceil((size(ColourMap,1)-1) .* (DisplayStructure(R).Data(IDX)-Range(1))/Range(2)),:),...'interp',...'texturemap',...'r',...'texturemap',...'flat',...
                                'FaceAlpha',DataAlpha,...
                                'Parent',MainMenu.UserData.ThreeDMenu.Axes);
                    else
                        surface(X  +DisplayStructure(R).XYZ(1),...
                            Y  +DisplayStructure(R).XYZ(2),...
                            Z  +DisplayStructure(R).XYZ(3),...
                            'EdgeColor','none',...
                            'FaceColor','m',...
                            'FaceAlpha',DataAlpha,...
                            'Parent',MainMenu.UserData.ThreeDMenu.Axes);
                        
                    end
                end
            end
        end
    end
    
    
    %%%%%%%%
    % ROIs %
    %%%%%%%%
    %Only perform the ROIs if NO EXTERNAL DATA
    if(MainMenu.UserData.ThreeDMenu.uiROICheckBox.Value && ~isfield(MainMenu.UserData.ThreeDMenu.DisplayStructure,'Data'))
        
        %Load the Data
        ROIStruct = MainMenu.UserData.SubjectStructure.Volumes(MainMenu.UserData.ThreeDMenu.uiROIPopUp.Value).ROIs;
        
        %Check if there are ROIs to display
        if(~isempty(ROIStruct))
        
            %Parameters for later
            Colour = MainMenu.UserData.ThreeDMenu.uiROIColourMapPopUp.String{MainMenu.UserData.ThreeDMenu.uiROIColourMapPopUp.Value};
            Alpha = str2double(strrep(MainMenu.UserData.ThreeDMenu.uiROIOpacitiyPopUp.String{MainMenu.UserData.ThreeDMenu.uiROIOpacitiyPopUp.Value},'%',''))/100;
            Size = str2double(MainMenu.UserData.ThreeDMenu.uiROISize.String)./2; %The created Sphere is -1 to 1, halving the size means unit size
            [X,Y,Z] = sphere(50);   
            X = X.*Size;
            Y = Y.*Size;
            Z = Z.*Size;
            
            %This could possibly be made into a cylinder
            %Cyclinder???
            
            %%%%%%%%%%%%%%%%%%
            % Connectionless %
            %%%%%%%%%%%%%%%%%%
            if(MainMenu.UserData.ThreeDMenu.uiROIConnectionPopUp.Value == 1)
                
                %Just place ROIs on the page
                for R = 1:size(ROIStruct,2)
                    
                    surf(X  +ROIStruct(R).XYZ(1),...
                         Y  +ROIStruct(R).XYZ(2),...
                         Z  +ROIStruct(R).XYZ(3),...
                         'EdgeColor','none',...
                         'FaceColor',Colour,...
                         'FaceAlpha',Alpha,...
                         'Parent',MainMenu.UserData.ThreeDMenu.Axes);
                end
            end
        
        
        end
    end
      
    
    
    
    
    
    
%     %Always update the Lighting
%     light('Position',[mean(XLIM), mean(YLIM), ZLIM(1)]);
%     light('Position',[mean(XLIM), mean(YLIM), ZLIM(2)]);
%     light('Position',[mean(XLIM), YLIM(1), mean(ZLIM)]);
%     light('Position',[mean(XLIM), YLIM(2), mean(ZLIM)]);
%     light('Position',[mean(1), mean(YLIM), mean(ZLIM)]);
%     light('Position',[mean(2), mean(YLIM), mean(ZLIM)]);

    MainMenu.UserData.ThreeDMenu.Camlight = camlight;
    %light;
    lighting gouraud;
end
    
