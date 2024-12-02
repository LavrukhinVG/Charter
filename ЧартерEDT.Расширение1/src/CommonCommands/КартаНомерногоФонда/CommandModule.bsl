
//-----------------------------------------------------------------------------
&AtServer
Function CheckUserPermission(rShowFilters)
	rShowFilters = True;
	If ValueIsFilled(SessionParameters.CurrentHotel) Then
		rShowFilters = SessionParameters.CurrentHotel.ShowFiltersPageForGanttChart;
	EndIf;
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
	vShowFilters = True;
	If Not CheckUserPermission(vShowFilters) Then
		Raise NStr("en='You do not have rights to this function!';ru='У вас нет прав на эту функцию!';de='Sie haben keine Rechte für diese Funktion!'");
		Return;
	EndIf;
	If vShowFilters Then
		// Open filters for gantt chart form
		OpenForm("CommonForm.tcRoomsFolderAndRoomTypeChoiceForm", , CommandExecuteParameters.Source, CommandExecuteParameters.Uniqueness, CommandExecuteParameters.Window);
	Else
		// Open gantt chart form
		OpenForm("CommonForm.tcRoomsGanttChart");
	EndIf;
EndProcedure //CommandProcessing
