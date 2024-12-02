
&Вместо("SetDesktop")
Procedure чартер_SetDesktop(pMobileClientMode = False) Export
	//vHomePageSettings = New HomePageSettings;
	//vDefaultDesignerForm = vHomePageSettings.GetForms().LeftColumn;
	//vForms = New HomePageForms;
	//vArrForms = vForms.LeftColumn;
	//// Load user settings
	//vHomePageSettingsUser = SystemSettingsStorage.Load("Common/HomePageSettings");
	//// Get default form for user
	//vDefaultForm = GetActualFormDesktop(pMobileClientMode);
	//If vHomePageSettingsUser = Undefined Then
	//	// Set default settings 
	//	vArrForms.Add(vDefaultForm);
	//Else
	//	If vDefaultDesignerForm.Find(vDefaultForm) = Undefined Then
	//		// Set default settings 
	//		vArrForms.Add(vDefaultForm);
	//	Else
	//		// Get user settings forms
	//		vTempForms = SystemSettingsStorage.Load("Common/UserDesktopForms");
	//		If vTempForms <> Undefined And vTempForms.Count() > 2 Then
	//			vTempForms = Undefined;
	//		EndIf;
	//		If vTempForms <> Undefined Then
	//			// Apply user settings
	//			For Each vInd In vTempForms Do
	//				If Not vDefaultDesignerForm.Find(vInd) = Undefined Then
	//					vArrForms.Add(vInd);	
	//				EndIf;
	//			EndDo;
	//		EndIf;	
	//		If vArrForms.Count() = 0 Then
	//			vArrForms.Add(vDefaultForm);
	//		EndIf; 
	//	EndIf;
	//EndIf; 
	// Set new settings
	//Если IsInRole("чартер_ОсновнаяРоль") Or IsInRole("чартер_Подрядчик") Тогда
	//	vForms.LeftColumn[0] = "CommonForm.чартер_Desktop";	
	//КонецЕсли;
	
	//vHomePageSettings.SetForms(vForms); 
	// Save user settings
	//SystemSettingsStorage.Save("Common/HomePageSettings",,vHomePageSettings);
EndProcedure //SetDesktop