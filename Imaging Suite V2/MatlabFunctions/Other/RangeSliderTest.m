close all;
clc;
figure;
clear;

%Volume X limits
RangeSlider = com.jidesoft.swing.RangeSlider(0, 100, 0, 100);
[RangeSlider,RangeSliderContainer] = javacomponent(RangeSlider, [10, 10, 500, 40], gcf);
set(RangeSlider,'MajorTickSpacing',25,...
    'MinorTickSpacing',5,...
    'Inverted',false,...
    'PaintTicks',true, 'PaintLabels',true,...
    'Background',java.awt.Color.white,...
    'Visible',1,...
    'Name','XCUT',...
    'MouseReleasedCallback',@ChangeScale,...
    'KeyReleasedCallback','');
RangeSliderContainer.BackgroundColor = [1 1 1];


function [] = ChangeScale(RangeSlider,~)


    Low = 1;
    High = 100;
    Steps = 0.5;
    MinorSpacing = High/Steps ./ 10;
    MajorSpacing = MinorSpacing.*4;
    
    %Update the time range
    RangeSlider.setMinimum(Low);
    RangeSlider.setMaximum(High/Steps);
    RangeSlider.setLowValue(Low);
    RangeSlider.setHighValue(High);
    
    RangeSlider.setMinorTickSpacing(MinorSpacing);
    RangeSlider.setMinorTickSpacing(MajorSpacing);
    
    %%%%%% This was close but didn't solve the problem
% % % % % % % % % % % % %     
% % % % % % % % % % % % %     Hash = RangeSlider.getLabelTable();
% % % % % % % % % % % % %     CurrentSetting = Hash.keys;
% % % % % % % % % % % % %     
% % % % % % % % % % % % %     while CurrentSetting.hasMoreElements,
% % % % % % % % % % % % %         
% % % % % % % % % % % % %         Data = CurrentSetting.nextElement;
% % % % % % % % % % % % %         
% % % % % % % % % % % % %         disp(Data);
% % % % % % % % % % % % %         
% % % % % % % % % % % % %         Hash.containsKey(Data)
% % % % % % % % % % % % %         
% % % % % % % % % % % % %         %Current
% % % % % % % % % % % % %         
% % % % % % % % % % % % %         %CurrentSetting.nextElement();
% % % % % % % % % % % % %     end
% % % % % % % % % % % % %     
% % % % % % % % % % % % %     RangeSlider.setLabelTable(Hash)
    
    
    
    
    
    %RangeSlider.setLabelTable(containers.Map());
    %RangeSlider.createStandardLabels(containers.Map());
    
% %     HashTable = java.util.Dictionary()
% %     java.lang.util.Dictionary()
% %     RangeSlider.setLabelTable([]);        %setLabelTable();
% %     javax.swing.JSlider.getLabelTable .Hashtable(int16(1),'String')
% %     java.util.Dictionary(int16(1),'Value')
% %     com.java.util.Dictionary()
    



    Hash = RangeSlider.LabelTable;
    
    for i = Low:High
        Hash.containsValue('151')
        Hash.get(151)
        
    end

    for i = Low:MajorSpacing:High
        
        RangeSlider.LabelTable.put(int16(i),'1');
        
    end
       
    hashtable = java.util.Hashtable;
    hashtable.put("1","1");
    hashtable.put('10',int16(5));
    
    RangeSlider.setLabelTable(hashtable);
    
    HashTable = RangeSlider.createStandardLabels(10);
    HashTable.contains('1')
    
    RangeSlider.setLabelTable(RangeSlider.createStandardLabels(1/RangeMultiplier));
    
    
    %NewLabelTabel = RangeSlider.createStandardLabels(1);
    %NewLabelTabel.
    %RangeSlider.setLabelTable(
    %RangeSlider.setLabelTable(RangeSlider.createStandardLabels(1/RangeMultiplier));
   
    
    
    
    
end