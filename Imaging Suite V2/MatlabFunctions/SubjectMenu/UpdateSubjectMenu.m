function [] = UpdateSubjectMenu()

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the MainMenu      %
    MainMenu = FindMainMenu; % 
    if(isempty(MainMenu))    %
        QuitFunction();      %
        return;              %
    end                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%

   %The details in the Subjectstructure need to be added to the SubjectMenu
   MainMenu.UserData.SubjectMenuProperties.uiSubjectID.String = MainMenu.UserData.SubjectStructure.ID;
   MainMenu.UserData.SubjectMenuProperties.uiSubjectDIR.String = MainMenu.UserData.SubjectStructure.DIR;
   MainMenu.UserData.SubjectMenuProperties.uiAllImages.String = {MainMenu.UserData.SubjectStructure.Volumes.FileAddress};

   
   if(~isempty(MainMenu.UserData.SubjectStructure.DIR))
       %Activate the other buttons
       MainMenu.UserData.SubjectMenuProperties.uiSaveSubjectButton.Visible = true;
       MainMenu.UserData.SubjectMenuProperties.uiImportDICOMButton.Visible = true;
       MainMenu.UserData.SubjectMenuProperties.uiImportVolumeButton.Visible = true;
       MainMenu.UserData.SubjectMenuProperties.uiRemoveVolumeButton.Visible = true;
       
        %Provide explanation of the new options
        MainMenu.UserData.SubjectMenuProperties.uiHELPMessage.String = sprintf('New Subject: This will create a new folder for subject given in "subject ID"\nLoad Subject: This loads a previously create subject\nSave Subject: This option will save the changes made\nImport DICOM: This allows the importation of DICOM images into the subjects folder\nImport Volume: This allows the importation of other image types (.img and .nii) into the subjects folder\nRemove Volume: This removes selected volumes from the subject folder');
   end
end