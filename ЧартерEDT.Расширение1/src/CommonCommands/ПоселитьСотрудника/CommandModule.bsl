//-----------------------------------------------------------------------------
&AtClient
Procedure CommandProcessing(CommandParameter, CommandExecuteParameters)
	OpenForm("CommonForm.tcDesktop", , CommandExecuteParameters.Source, CommandExecuteParameters.Uniqueness, CommandExecuteParameters.Window);
	#If Not WebClient Then
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 10, NStr("en='Opening...';ru='Открытие формы...';de='Öffnen des Formulars...'"), PictureLib.LongOperation); 
	#EndIf
	vDocFormParameters = New Structure;
	vDocFormParameters.Insert("Document", tcOnServer.cmGetDocumentItemRefByDocNumber("Accommodation", "", True) );
	vFrm = GetForm("Document.Accommodation.ObjectForm", vDocFormParameters);
	#If Not WebClient Then
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 30, NStr("en='Opening...';ru='Открытие формы...';de='Öffnen des Formulars...'"), PictureLib.LongOperation); 
	#EndIf	
	vFrm.Open();
EndProcedure //CommandProcessing
