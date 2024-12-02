//-----------------------------------------------------------------------------
&AtServer
Function CheckUserPermission()
	If ValueIsFilled(SessionParameters.CurrentUser) Then
		If Not ValueIsFilled(SessionParameters.CurrentUser.Customer) Then
			Return True;
		EndIf;
	EndIf;
	Return False;
EndFunction //CheckUserPermission

//-----------------------------------------------------------------------------
&AtClient
Procedure CommandProcessing(CommandParameter, CommandExecuteParameters)
	If amPersistentObjects.Property("IsLockApplication") Then
		If amPersistentObjects.IsLockApplication Then
			Return;	
		EndIf;	
	EndIf;
	If Not CheckUserPermission() Then
		Raise NStr("en='You do not have rights to this function!';ru='У вас нет прав на эту функцию!';de='Sie haben keine Rechte für diese Funktion!'");
		Return;
	EndIf;
	#IF NOT MobileClient THEN 
		OpenForm("Document.Accommodation.Form.tcAccommodationListForm", New Structure("SelFilterStatus", 0));
	#ELSE
		OpenForm("Document.Accommodation.Form.mcAccommodationListForm", New Structure("SelFilterStatus", 0));	
	#ENDIF
	Notify("Document.Accommodation.ListForm.InHouseGuests");
EndProcedure //CommandProcessing
