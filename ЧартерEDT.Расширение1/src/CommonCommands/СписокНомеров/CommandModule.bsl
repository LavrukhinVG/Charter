&AtClient
Procedure CommandProcessing(pCommandParameter, pCommandExecuteParameters)
	vParams = New Structure;
	#IF MobileClient THEN 
		OpenForm("Catalog.Rooms.Form.mcHousekeepingForm", vParams, pCommandExecuteParameters.Source, pCommandExecuteParameters.Uniqueness, pCommandExecuteParameters.Window, pCommandExecuteParameters.URL);	
	#ELSE
		OpenForm("Catalog.Rooms.Form.tcHousekeepingForm", vParams, pCommandExecuteParameters.Source, pCommandExecuteParameters.Uniqueness, pCommandExecuteParameters.Window, pCommandExecuteParameters.URL);
	#ENDIF
EndProcedure //CommandProcessing
