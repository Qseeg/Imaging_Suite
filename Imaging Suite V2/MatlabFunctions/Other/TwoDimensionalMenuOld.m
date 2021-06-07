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
    FigureNumber = CreateDisplayFigure();
    if(FigureNumber == 0)
        ErrorPanel('Could not create a two dimensional imaging panel');
        return;
    end
    
    
    %Display the origin
    ChangeDisplayPosition(FigureNumber);

end



function [FigureNumber] = CreateDisplayFigure()
    
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
            elseif(~ishandle(MainMenu.UserData.TwoDMenu.GlobalProperties.Handles(FigureNumber)))
                break; %VolumeNumber is set to the free space found
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
    FigurePosition = MainMenu.UserData.TwoDMenu.Position; FigurePosition(1) = FigurePosition(1) + FigurePosition(3) * (FigureNumber-1);
    TwoDMenu = figure('Name','','units','Pixel','InnerPosition',FigurePosition ,'Tag',sprintf('ImageDisplay(%i)',FigureNumber),'MenuBar','none','NumberTitle','off','Color',[1 1 1]);        
    MainMenu.UserData.TwoDMenu.GlobalProperties.Handles(FigureNumber) = TwoDMenu;
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).Handle = TwoDMenu;
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).CurrentPoint = [0, 0, 0];
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).ColourMap = 'bone';
    
    %%%%%%%%%%%%%%
    % Display UI %
    %%%%%%%%%%%%%%
        %%%%%%%%%%
        %Volumes % 
        %%%%%%%%%%
        uiXOffset = 20;
        uiYOffset = 20:20:300;
        uiHeight = 20;
        ui2Width = (MainMenu.UserData.TwoDMenu.Position(3)-3*uiXOffset)./2;
        %ui3Width = (MainMenu.UserData.TwoDMenu.Position(3)-5*uiXOffset)./3;
        
        %VolumeSelector
        uicontrol('Style','text','units','pixel','position',[uiXOffset MainMenu.UserData.TwoDMenu.Position(4)-uiYOffset(1) ui2Width uiHeight],'String','Volume to Display','BackgroundColor',[1 1 1],'HorizontalAlignment','Left');
        VolumeSelectionText = strcat('(',{MainMenu.UserData.SubjectStructure.Volumes.FileName},{')   '} ,{MainMenu.UserData.SubjectStructure.Volumes.Type});
        uiVolumeSelectionPopUp = uicontrol('Style','popupmenu','Units','pixel','position',[uiXOffset MainMenu.UserData.TwoDMenu.Position(4)-uiYOffset(2) ui2Width uiHeight],'String',VolumeSelectionText,'Value',1,'Tag',sprintf('VolumeSelectionPopUp(%i)',FigureNumber),'CallBack',@VolumeSelectionPopupCallback);
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeSelectionPopup = uiVolumeSelectionPopUp;
        
        %ColourMap
        uicontrol('Style','text','units','pixel','position',[uiXOffset MainMenu.UserData.TwoDMenu.Position(4)-uiYOffset(3) ui2Width uiHeight],'String','Volume colourmap','BackgroundColor',[1 1 1],'HorizontalAlignment','Left');
        ColourMapText = MainMenu.UserData.TwoDMenu.GlobalProperties.ColourMaps;
        uiVolumeColourMapPopUp = uicontrol('Style','popupmenu','Units','pixel','position',[uiXOffset MainMenu.UserData.TwoDMenu.Position(4)-uiYOffset(4) ui2Width uiHeight],'String',ColourMapText,'Value',1,'Tag',sprintf('VolumeColourMapPopUp(%i)',FigureNumber),'CallBack',@VolumeColourMapPopupCallback);
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeColourMapPopup = uiVolumeColourMapPopUp;
        
        %Zoom
        uicontrol('Style','text','units','pixel','position',[uiXOffset MainMenu.UserData.TwoDMenu.Position(4)-uiYOffset(5) ui2Width uiHeight],'String','Volume Zoom','BackgroundColor',[1 1 1],'HorizontalAlignment','Left');
        ZoomText = {'x1','x2','x3','x4','x5'};
        uiVolumeZoomPopUp = uicontrol('Style','popupmenu','Units','pixel','position',[uiXOffset MainMenu.UserData.TwoDMenu.Position(4)-uiYOffset(6) ui2Width uiHeight],'String',ZoomText,'Value',1,'Tag',sprintf('VolumeZoomPopUp(%i)',FigureNumber),'CallBack',@VolumeZoomPopupCallback);
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeZoomPopup = uiVolumeZoomPopUp;
        
        %Range Selector
        uicontrol('Style','text','units','pixel','position',[uiXOffset MainMenu.UserData.TwoDMenu.Position(4)-uiYOffset(7) ui2Width uiHeight],'String','Volume Range','BackgroundColor',[1 1 1],'HorizontalAlignment','Left');
        RangeText = {'Automatic','Manual'};
        uiVolumeRangeSelectorPopUp = uicontrol('Style','popupmenu','Units','pixel','position',[uiXOffset MainMenu.UserData.TwoDMenu.Position(4)-uiYOffset(8) ui2Width uiHeight],'String',RangeText,'Value',1,'Tag',sprintf('VolumeRangeSelectorPopUp(%i)',FigureNumber),'CallBack',@VolumeRangeUpdateCallback);
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeRangeSelectorPopUp = uiVolumeRangeSelectorPopUp;
        
        %Rangeslider (VOLUME RANGE)
        uiVolumeRangeSliderText = uicontrol('Style','text','units','pixel','position',[uiXOffset MainMenu.UserData.TwoDMenu.Position(4)-uiYOffset(9) ui2Width uiHeight],'String','Volume Range','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible',false);
        Range = round(GetVolumeRange(MainMenu.UserData.SubjectStructure.Volumes(uiVolumeSelectionPopUp.Value).FileAddress));
        MainMenu.UserData.TwoDMenu.Volumes(uiVolumeSelectionPopUp.Value).Range = Range;
        uiVolumeRangeSlider = com.jidesoft.swing.RangeSlider(Range(1), Range(2), Range(1), Range(2)); 
        [uiVolumeRangeSlider,uiVolumeRangeSliderContainer] = javacomponent(uiVolumeRangeSlider, [uiXOffset,MainMenu.UserData.TwoDMenu.Position(4)-uiYOffset(11),ui2Width,2*uiHeight], gcf);
        set(uiVolumeRangeSlider,'MajorTickSpacing',250,...round(diff(Range)/4),...
                                'MinorTickSpacing',50,...round(diff(Range)/16),...
                                'PaintTicks',true, 'PaintLabels',true,...
                                'Background',java.awt.Color.white,...
                                'Visible',0,...
                                'Name',sprintf('uiVolumeRangeSlider(%i)',FigureNumber),...
                                'MouseReleasedCallback',@VolumeRangeUpdateCallback);%'StateChangedCallback',@VolumeRangeChangeCallback);
        uiVolumeRangeSliderContainer.BackgroundColor = [1 1 1];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeRangeSlider = uiVolumeRangeSlider;
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeRangeSliderText = uiVolumeRangeSliderText;
        
        
        
        %%%%%%%%%%
        %OVERLAY % 
        %%%%%%%%%%   
        %Overlay Selector
        uicontrol('Style','text','units','pixel','position',[uiXOffset+ui2Width+uiXOffset MainMenu.UserData.TwoDMenu.Position(4)-uiYOffset(1) ui2Width uiHeight],'String','Overlay','BackgroundColor',[1 1 1],'HorizontalAlignment','Left');
        OverlaySelectionText = strcat('(',{MainMenu.UserData.SubjectStructure.Volumes.FileName},{')   '} ,{MainMenu.UserData.SubjectStructure.Volumes.Type});
        uiOverlaySelectionPopUp = uicontrol('Style','popupmenu','Units','pixel','position',[uiXOffset+ui2Width+uiXOffset MainMenu.UserData.TwoDMenu.Position(4)-uiYOffset(2) ui2Width uiHeight],'String',OverlaySelectionText,'Value',1,'Tag',sprintf('OverlaySelectionPopUp(%i)',FigureNumber),'CallBack',@OverlaySelectionPopupCallback);
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlaySelectionPopUp = uiOverlaySelectionPopUp;
        %Uncheck all Overlays
        [MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,1:size(MainMenu.UserData.SubjectStructure.Volumes,2)).Visible] = deal(false);

        %Overlay on/off option
        uicontrol('Style','text','units','pixel','position',[uiXOffset+ui2Width+uiXOffset MainMenu.UserData.TwoDMenu.Position(4)-uiYOffset(3) ui2Width uiHeight],'String','Visible','BackgroundColor',[1 1 1],'HorizontalAlignment','Left');
        uiOverlayVisibleCheckBox = uicontrol('Style','checkbox','Units','pixel','position',[uiXOffset+ui2Width+uiXOffset MainMenu.UserData.TwoDMenu.Position(4)-uiYOffset(4) ui2Width uiHeight],'Value',0,'BackgroundColor',[1 1 1],'Tag',sprintf('OverlayVisibleCheckBox(%i)',FigureNumber),'CallBack',@OverlayVisibleCheckBoxCallback);
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayVisibleCheckBox = uiOverlayVisibleCheckBox;
    
        %ColourMap
        uiOverlayColourMapText = uicontrol('Style','text','units','pixel','position',[uiXOffset+ui2Width+uiXOffset MainMenu.UserData.TwoDMenu.Position(4)-uiYOffset(5) ui2Width uiHeight],'String','Overlay colourmap','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible',false);
        ColourMapText = MainMenu.UserData.TwoDMenu.GlobalProperties.ColourMaps;
        uiOverlayColourMapPopUp = uicontrol('Style','popupmenu','Units','pixel','position',[uiXOffset+ui2Width+uiXOffset MainMenu.UserData.TwoDMenu.Position(4)-uiYOffset(6) ui2Width uiHeight],'String',ColourMapText,'Value',8,'Visible',false,'Tag',sprintf('OverlayColourMapPopUp(%i)',FigureNumber),'CallBack',@OverlayColourMapPopupCallback);
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayColourMapPopUp = uiOverlayColourMapPopUp;
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayColourMapText = uiOverlayColourMapText;
        
        %Slider (OVERLAY OPACITY)
        uiOverlayOpacitySliderText = uicontrol('Style','text','units','pixel','position',[uiXOffset+ui2Width+uiXOffset MainMenu.UserData.TwoDMenu.Position(4)-uiYOffset(7) ui2Width uiHeight],'String','Overlay Opacity','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible',false);
        [uiOverlayOpacitySlider,uiOverlayOpacitySliderContainer] = javacomponent(javax.swing.JSlider(0, 100, 50), [uiXOffset+ui2Width+uiXOffset,MainMenu.UserData.TwoDMenu.Position(4)-uiYOffset(9),ui2Width,2*uiHeight], gcf);
        set(uiOverlayOpacitySlider, 'MajorTickSpacing',25,...round(diff(Range)/4),...
                                    'MinorTickSpacing',5,...round(diff(Range)/16),...
                                    'PaintTicks',true, 'PaintLabels',true,...
                                    'Background',java.awt.Color.white,...
                                    'Visible',0,...
                                    'Name',sprintf('uiOverlayOpacitySlider(%i)',FigureNumber),...
                                    'MouseReleasedCallback',@OverlayOpacitySliderCallback);
        uiOverlayOpacitySliderContainer.BackgroundColor = [1 1 1];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayOpacitySlider = uiOverlayOpacitySlider;
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayOpacitySliderText = uiOverlayOpacitySliderText;
        
        %Rangeslider (OVERLAY RANGE)
        uiOverlayRangeSliderText = uicontrol('Style','text','units','pixel','position',[uiXOffset+ui2Width+uiXOffset MainMenu.UserData.TwoDMenu.Position(4)-uiYOffset(10) ui2Width uiHeight],'String','Overlay Range','BackgroundColor',[1 1 1],'HorizontalAlignment','Left','Visible',false);
        uiOverlayRangeSlider = com.jidesoft.swing.RangeSlider(0, 100, 0, 100); 
        [uiOverlayRangeSlider,uiOverlayRangeSliderContainer] = javacomponent(uiOverlayRangeSlider, [uiXOffset+ui2Width+uiXOffset,MainMenu.UserData.TwoDMenu.Position(4)-uiYOffset(12),ui2Width,2*uiHeight], gcf);
        set(uiOverlayRangeSlider,'MajorTickSpacing',250,...round(diff(Range)/4),...
                                'MinorTickSpacing',50,...round(diff(Range)/16),...
                                'PaintTicks',true, 'PaintLabels',true,...
                                'Background',java.awt.Color.white,...
                                'Visible',0,...
                                'Name',sprintf('uiOverlayRangeSlider(%i)',FigureNumber),...
                                'MouseReleasedCallback',@OverlayRangeUpdateCallback);%'StateChangedCallback',@OverlayRangeChangeCallback);
        uiOverlayRangeSliderContainer.BackgroundColor = [1 1 1];
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayRangeSlider = uiOverlayRangeSlider;
        MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayRangeSliderText = uiOverlayRangeSliderText;
        

        
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    % Load the Volume data %
    %%%%%%%%%%%%%%%%%%%%%%%%
    LoadDisplayVolume(FigureNumber,1)
    
    %Display Something
    CreateDisplayAxes(FigureNumber);
    
    %Display an image so that it isn't blank
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
                VolumeNumber = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeSelectionPopup.Value;    
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
    FigureNumber = nan;
    VolumeNumber = nan;
    for FN = 1:size(MainMenu.UserData.TwoDMenu.GlobalProperties.Handles,2)
        if(strcmp(src.Parent.Tag,MainMenu.UserData.TwoDMenu.GlobalProperties.Handles(FN).Tag))
            FigureNumber = FN;
            VolumeNumber = MainMenu.UserData.TwoDMenu.Volumes(FN).uiVolumeSelectionPopup.Value;
            break;
        end
    end
    
    if(isnan(VolumeNumber) || isnan(FigureNumber))
        MessagePanel('Unknown Volume Selection','Unknown Volume Selection');
        return;
    end

    %Load the Data that has been selected
    LoadDisplayVolume(FigureNumber, VolumeNumber); 
    
    %Display Something
    CreateDisplayAxes(FigureNumber);
    
    %Uncheck all overlays
    [MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,:).Visible] = deal(false);
    %Hide all Overlay options
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayColourMapPopUp.Visible = false;
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayColourMapText.Visible = false;
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayOpacitySlider.setVisible(0);
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayOpacitySliderText.Visible = false;
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayRangeSlider.setVisible(0);
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayRangeSliderText.Visible = false;
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlayVisibleCheckBox.Value = 0;    
    %Delete OverlayAxes
    delete([MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,:).AxialAxes]);
    delete([MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,:).CoronalAxes]);
    delete([MainMenu.UserData.TwoDMenu.Overlays(FigureNumber,:).SagittalAxes]);
    
    %Display an image so that it isn't blank
    ChangeDisplayPosition(FigureNumber);

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
        ColourMapIDX = 1;
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
    
    VolumeNumber = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiOverlaySelectionPopUp.Value;
    
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
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeZoomPopup.Value = 1;
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).Zoom = 1;
    
    %Range Settings
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeRangeSelectorPopUp.Value = 1;  %Set to automatic
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeRangeSlider.setVisible(0);     %Hide the RangeSlider
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeRangeSliderText.Visible = 0;   %Hide the text above the slider
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).Range = GetVolumeRange(MainMenu.UserData.SubjectStructure.Volumes(VolumeNumber).FileAddress);                     %Remove the range details
    MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).DisplayRange = MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).Range;            
                
    %Update the Global Details
    UpdateGlobalDetails();
    
    %CreateAxes
    CreateDisplayAxes(FigureNumber);
    
    %Display an image so that it isn't blank
    ChangeDisplayPosition(FigureNumber);
    
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

        %Manual Range calibration
        if(MainMenu.UserData.TwoDMenu.Volumes(FigureNumber).uiVolumeRangeSelectorPopUp.Value == 2) %Manual Range
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
        
        %Plot a cross hair
        
        
    end
end












% %Function to take in two ranges and find the addition and multiplication
% %operations to make range2 equal to range1.
% %(Range2 * MUL) + ADD = Range1
% function [ADD, MUL] = ReRange(Range1, Range2)
% 
% 
%     ADD = Range1(1) - Range2(1);
%     MUL = diff(Range1)./diff(Range2);
%     return;
% 
% end




% % % % % 
% % % % %     %Collect the Volume we are working with
% % % % %     VOLADDR = MainMenu.UserData.SubjectStructure.Volumes(MainMenu.UserData.TwoDMenu.uiVolumeSelectionPopup.Value).FileAddress;
% % % % %     VOL = spm_vol(VOLADDR);
% % % % % 
% % % % %     %Preallocation
% % % % %     VOL.premul = eye(4);
% % % % %     
% % % % %     %Work out the maximum bounding box of all images considered for viewing
% % % % %     BoundingBox = spm_get_bbox(VOL);
% % % % %    
% % % % %     %Get the number of slices in each dimension
% % % % %     Dimensions = round(diff(BoundingBox)'+1);
% % % % %     
% % % % %     %Interpolation Method
% % % % %     InterpolationMethod = 1; %Trilinear
% % % % %     
% % % % %     %World or Voxel space scaling 
% % % % %     Space = eye(4);         %World Space
% % % % %     is   = inv(Space);      
% % % % %     %Centre = is(1:3,1:3)*st.centre(:) + is(1:3,4);
% % % % %     %Centre = is(1:3,1:3)*[0; 0; 0;] + is(1:3,4);
% % % % %     
% % % % %     mmcentre     = mean(Space*[BoundingBox';1 1],2)';
% % % % %     Centre    = mmcentre(1:3);
% % % % % 
% % % % % 
% % % % %     M = Space\VOL.premul*VOL.mat;
% % % % %     %Transverse (Axial)
% % % % %     TM0 = [ 1 0 0 -BoundingBox(1,1)+1
% % % % %             0 1 0 -BoundingBox(1,2)+1
% % % % %             0 0 1 -XYZ(3)
% % % % %             0 0 0 1];
% % % % %     TM = inv(TM0*M);
% % % % %     TD = Dimensions([1 2]);
% % % % %     %Coronal
% % % % %     CM0 = [ 1 0 0 -BoundingBox(1,1)+1
% % % % %             0 0 1 -BoundingBox(1,3)+1
% % % % %             0 1 0 -XYZ(2)
% % % % %             0 0 0 1];
% % % % %     CM = inv(CM0*M);
% % % % %     CD = Dimensions([1 3]);
% % % % %     %Sagittal
% % % % %     SM0 = [ 0 -1 0 +BoundingBox(2,2)+1
% % % % %         0  0 1 -BoundingBox(1,3)+1
% % % % %         1  0 0 -XYZ(1)
% % % % %         0  0 0 1];
% % % % %     SM = inv(SM0*M);
% % % % %     SD = Dimensions([2 3]);
% % % % % 
% % % % %     
% % % % %     %Cut Images
% % % % %     imgt = spm_slice_vol(VOL,TM,TD,InterpolationMethod)';
% % % % %     imgc = spm_slice_vol(VOL,CM,CD,InterpolationMethod)';
% % % % %     imgs = spm_slice_vol(VOL,SM,SD,InterpolationMethod)';
% % % % %     
% % % % %     %display Images
% % % % %     imagesc(AxialAxes,imgt);AxialAxes.YDir = 'normal';
% % % % %     imagesc(CoronalAxes,imgc);CoronalAxes.YDir = 'normal';
% % % % %     imagesc(SagittalAxes,imgs);SagittalAxes.YDir = 'normal';
% % % % %     
% % % % %     


% 
% function [] = InitaliseAxes(varargin)
%     
%     %%%%%%%%%%%%%%%%%%%%%%%%%%
%     % Find the MainMenu      %
%     MainMenu = FindMainMenu; %
%     if(isempty(MainMenu))    %
%         QuitFunction();      %
%         return;              %
%     end                      %
%     %%%%%%%%%%%%%%%%%%%%%%%%%%
%     
%     %Load the volume
%     VOL = spm_vol(MainMenu.UserData.SubjectStructure.Volumes(MainMenu.UserData.TwoDMenu.uiVolumeSelectionPopup.Value).FileAddress);
%     VOL.premul = eye(4);
%     
%     %Bounding box
%     BoundingBox = spm_get_bbox(VOL);
%     
%     %Get the number of slices in each dimension
%     Dimensions = round(diff(BoundingBox)'+1);
%     
%     %Based on the Volume cut up the axes space accordingly
%     Gutter = MainMenu.UserData.TwoDMenu.AxesGutter;
%     AxesArea = MainMenu.UserData.TwoDMenu.AxesArea;
%     AxesArea(3:4) = AxesArea(3:4)-3*Gutter;
%     
%     W = Dimensions(1) + Dimensions(2); %X + Y
%     H = Dimensions(2) + Dimensions(3); %Y + Z
%     
%    %Modulate the Width and Hight so that only 1 is at maximum and the other
%    %is at its (althought not maximum) largest
%    Wm = AxesArea(3)./W;
%    Hm = AxesArea(4)./H;
%    
%    WH = min([Wm Hm]);
% 
% 
% end
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%
% % UpdateAxesDimensions %
% %%%%%%%%%%%%%%%%%%%%%%%%
% % Update the size of the axes based on the maximum of the bounding boxes of
% % all input images
% function [] = UpdateAxesDimensions(VOL)
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%
%     % Find the MainMenu      %
%     MainMenu = FindMainMenu; % 
%     if(isempty(MainMenu))    %
%         QuitFunction();      %
%         return;              %
%     end                      %
%     %%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %Update the Axes based on the maximum size of the images loaded
%     BoundingBox =  [0 0 0;
%                     1 1 1];
%                
%     %Collect the Axes handles
%     AxialAxes = MainMenu.UserData.TwoDMenu.AxialAxes;
%     CoronalAxes = MainMenu.UserData.TwoDMenu.CoronalAxes;
%     SagittalAxes = MainMenu.UserData.TwoDMenu.SagittalAxes;
%     
%     %Error checking
%     if(~numel(AxialAxes) || ~numel(CoronalAxes) || ~numel(SagittalAxes))
%         ErrorPanel('Cannot find all three orthogonal views for displaying');
%         return;
%     end
%     
%     
%     
%     %STEP 1) Get the bounding box 
%     for i = 1:size(VOL,2)
%         temp = spm_get_bbox(VOL(i));
%         
%         %Find the maximum
%         %%%%%%%%%%%%%
%         % THIS IS NOT COMPLETE, PROVIDE ACCESS FOR MULTIPLE VOLUMES
%         %BoundingBox = max(temp,BoundingBox);
% 
%         %Single Image
%         BoundingBox = temp;
%     end
%     
%     %Calculate the size od the volume dimensions
%     VolumeDimensions = round(diff(BoundingBox)+1);
%     
%     
% 
% end

% 
% function [] = UpdateDisplayAxes(~,~)
% 
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%
%     % Find the MainMenu      %
%     MainMenu = FindMainMenu; % 
%     if(isempty(MainMenu))    %
%         QuitFunction();      %
%         return;              %
%     end                      %
%     %%%%%%%%%%%%%%%%%%%%%%%%%%
%     
%     %If the null selection has been made
%     if(MainMenu.UserData.TwoDMenu.uiVolumeSelectionPopup.Value == size(MainMenu.UserData.SubjectStructure.Volumes,2)+1)
%         %The blank choice has been made
%         return;
%     end
% 
%     %Find the axes
%     AxialAxes = MainMenu.UserData.TwoDMenu.AxialAxes;
%     CoronalAxes = MainMenu.UserData.TwoDMenu.CoronalAxes;
%     SagittalAxes = MainMenu.UserData.TwoDMenu.SagittalAxes;
% 
%     
%     %Error checking
%     if(~numel(AxialAxes) || ~numel(CoronalAxes) || ~numel(SagittalAxes))
%         
%         ErrorPanel('Cannot find all three orthogonal views for displaying');
%         return;
%         
%     end
%     
%     %Collect the Volume we are working with
%     VOLADDR = MainMenu.UserData.SubjectStructure.Volumes(MainMenu.UserData.TwoDMenu.uiVolumeSelectionPopup.Value).FileAddress;
%     VOL = spm_vol(VOLADDR);
%     
%     
%     %New volume = new Axes dimension
%     UpdateAxesDimensions(VOL);
%     
%     %Preallocation
%     VOL.premul = eye(4);
%     
%     
%     
%     %Work out the maximum bounding box of all images considered for viewing
%     BoundingBox = spm_get_bbox(VOL);
%    
%     %Get the number of slices in each dimension
%     Dimensions = round(diff(BoundingBox)'+1);
%     
%     %Interpolation Method
%     InterpolationMethod = 1; %Trilinear
%     
%     %World or Voxel space scaling 
%     Space = eye(4);         %World Space
%     is   = inv(Space);      
%     %Centre = is(1:3,1:3)*st.centre(:) + is(1:3,4);
%     %Centre = is(1:3,1:3)*[0; 0; 0;] + is(1:3,4);
%     
%     mmcentre     = mean(Space*[BoundingBox';1 1],2)';
%     Centre    = mmcentre(1:3);
% 
%     %MATT YOU ARE HERE. You need to work out the centre so that the affine
%     %transformation can operate.
% 
%     M = Space\VOL.premul*VOL.mat;
%     %Transverse (Axial)
%     TM0 = [ 1 0 0 -BoundingBox(1,1)+1
%             0 1 0 -BoundingBox(1,2)+1
%             0 0 1 -Centre(3)
%             0 0 0 1];
%     TM = inv(TM0*M);
%     TD = Dimensions([1 2]);
%     %Coronal
%     CM0 = [ 1 0 0 -BoundingBox(1,1)+1
%             0 0 1 -BoundingBox(1,3)+1
%             0 1 0 -Centre(2)
%             0 0 0 1];
%     CM = inv(CM0*M);
%     CD = Dimensions([1 3]);
%     %Sagittal
%     SM0 = [ 0 -1 0 +BoundingBox(2,2)+1
%         0  0 1 -BoundingBox(1,3)+1
%         1  0 0 -Centre(1)
%         0  0 0 1];
%     SM = inv(SM0*M);
%     SD = Dimensions([2 3]);
% 
%     
%     %Cut Images
%     imgt = spm_slice_vol(VOL,TM,TD,InterpolationMethod)';
%     imgc = spm_slice_vol(VOL,CM,CD,InterpolationMethod)';
%     imgs = spm_slice_vol(VOL,SM,SD,InterpolationMethod)';
%     
%     %display Images
%     imagesc(AxialAxes,imgt);AxialAxes.YDir = 'normal';
%     imagesc(CoronalAxes,imgc);CoronalAxes.YDir = 'normal';
%     imagesc(SagittalAxes,imgs);SagittalAxes.YDir = 'normal';
% end


%Other function items
% Resolution      = 1; %Preset 1mm resolution
% Resolution      = min([Resolution,sqrt(sum((VOL.mat(1:3,1:3)).^2))]);
% res             = Resolution/mean(svd(st.Space(1:3,1:3)));
% Mat             = diag([Resolution Resolution Resolution 1]);
% Space           = Space*Mat;
% BoundingBox     = BoundingBox/Resolution;



%%%%%%%%%
% Button pressed
%%%%%%%%%%%%%%%%%%

%==========================================================================
% % function centre = findcent
% %==========================================================================
% function centre = findcent
% global st
% obj    = get(st.fig,'CurrentObject');
% centre = [];
% cent   = [];
% cp     = [];
% for i=valid_handles
%     for j=1:3
%         if ~isempty(obj)
%             if (st.vols{i}.ax{j}.ax == obj)
%                 cp = get(obj,'CurrentPoint');
%             end
%         end
%         if ~isempty(cp)
%             cp   = cp(1,1:2);
%             is   = inv(st.Space);
%             cent = is(1:3,1:3)*st.centre(:) + is(1:3,4);
%             switch j
%                 case 1
%                     cent([1 2])=[cp(1)+st.bb(1,1)-1 cp(2)+st.bb(1,2)-1];
%                 case 2
%                     cent([1 3])=[cp(1)+st.bb(1,1)-1 cp(2)+st.bb(1,3)-1];
%                 case 3
%                     if st.mode ==0
%                         cent([3 2])=[cp(1)+st.bb(1,3)-1 cp(2)+st.bb(1,2)-1];
%                     else
%                         cent([2 3])=[st.bb(2,2)+1-cp(1) cp(2)+st.bb(1,3)-1];
%                     end
%             end
%             break;
%         end
%     end
%     if ~isempty(cent), break; end
% end
% if ~isempty(cent), centre = st.Space(1:3,1:3)*cent(:) + st.Space(1:3,4); end


        %BelowXdim
%         if(BoundingBox(1,1) < GlobalBoundingBox(1,1))   
%             BoundingBox(2,1) = BoundingBox(2,1) + (GlobalBoundingBox(1,1)-BoundingBox(1,1));
%             BoundingBox(1,1) = GlobalBoundingBox(1,1);
%         end
%         
%         %AboveXDim
%         if(BoundingBox(2,1) > GlobalBoundingBox(2,1))   
%             BoundingBox(1,1) = BoundingBox(1,1) + (GlobalBoundingBox(2,1)-BoundingBox(2,1));
%             BoundingBox(2,1) = GlobalBoundingBox(2,1);
%         end
%         
%         %BelowYdim
%         if(BoundingBox(1,2) < GlobalBoundingBox(1,2))   
%             BoundingBox(2,2) = BoundingBox(2,2) + (GlobalBoundingBox(1,2)-BoundingBox(1,2));
%             BoundingBox(1,2) = GlobalBoundingBox(1,2);
%         end
%         
%         %AboveYDim
%         if(BoundingBox(2,2) > GlobalBoundingBox(2,2))   
%             BoundingBox(1,2) = BoundingBox(1,2) + (GlobalBoundingBox(2,2)-BoundingBox(2,2));
%             BoundingBox(2,2) = GlobalBoundingBox(2,2);
%         end
%         
%         %BelowZdim
%         if(BoundingBox(1,3) < GlobalBoundingBox(1,3))   
%             BoundingBox(2,3) = BoundingBox(2,3) + (GlobalBoundingBox(1,3)-BoundingBox(1,3));
%             BoundingBox(1,3) = GlobalBoundingBox(1,3);
%         end
%         
%         %AboveZDim
%         if(BoundingBox(2,3) > GlobalBoundingBox(2,3))   
%             BoundingBox(1,3) = BoundingBox(1,3) + (GlobalBoundingBox(2,3)-BoundingBox(2,3));
%             BoundingBox(2,3) = GlobalBoundingBox(2,3);
%         end
