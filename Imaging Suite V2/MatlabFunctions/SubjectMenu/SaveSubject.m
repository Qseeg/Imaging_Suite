
function [] = SaveSubject(~,~)

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    SubjectStructure = MainMenu.UserData.SubjectStructure;
    
    %Check that the save dir is still availble
    if(~exist(SubjectStructure.DIR,'dir'))
        ErrorPanel('Save directory is missing\nCancelling save operation');
        return;
    end
    
    %Save a .MatFile with the SubjectStructure in it.
    save(fullfile(SubjectStructure.DIR,'SubjectStructure.mat'),'SubjectStructure');

    MessagePanel('Save','Saving Complete');
end
