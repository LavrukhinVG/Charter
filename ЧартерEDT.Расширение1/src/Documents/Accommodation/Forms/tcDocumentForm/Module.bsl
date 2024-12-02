
&AtClient
&ChangeAndValidate("CheckIfCheckOutDateTimeIsFilled")
Procedure Расш1_CheckIfCheckOutDateTimeIsFilled()
	If ValueIsFilled(CheckOutDateTime) Then
		DetachIdleHandler("CheckIfCheckOutDateTimeIsFilled");
		// Check balances for selected accommodations
		vResultMessage = "";
		vResult = CheckAccommodationsBalances(AccList, vResultMessage);
		If Not IsBlankString(vResultMessage) Then
			Message(vResultMessage, MessageStatus.Important);
			tcOnServer.cmWriteLogEventAtServer(NStr("en='Accommodation.CheckBalances';ru='Размещение.ПроверкаБаланса';de='Accommodation.CheckBalances'"), Undefined, "Documents.Folio", , vResultMessage);
			If Not vResult Then
				Return;
			EndIf;
		EndIf;
		// Check if advances were cleared
		vResultMessage = "";
		vResult = CheckIfAdvancesWereCleared(AccList, vResultMessage);
		If Not IsBlankString(vResultMessage) Then
			Message(vResultMessage, MessageStatus.Important);
			tcOnServer.cmWriteLogEventAtServer(NStr("en='Accommodation.CheckIfAdvancesWereCleared';ru='Размещение.ПроверкаЗачетаАванса';de='Accommodation.CheckIfAdvancesWereCleared'"), Undefined, "Documents.Folio", , vResultMessage);
			If Not vResult Then
				Return;
			EndIf;
		EndIf;
		// Check future reservations
		vMessage = CheckFutureReservationsAtServer(Object.Ref, CheckOutDateTime);
		If Not IsBlankString(vMessage) Then
			Message(vMessage, MessageStatus.Information);
		EndIf;
		// Do check-out
		vResult = CheckOutAtServer(Object.Ref, AccList, CheckOutDateTime, False);
		If ValueIsFilled(vResult) Then
			If vResult = "SendNotifications" Then
				// Send notification to all open forms
				Notify("Subsystem.Accounts.Changed", Object.Ref, ThisForm);
				Notify("Document.ResourceReservation.Write", , ThisForm);
				// Notify that accommodation is changed
				Notify("Document.Accommodation.Write", Object.Ref, ThisForm);
				// Close document form if possible
				If Not ThisForm.Modified And ThisForm.IsOpen() Then
					// Refresh document data
					ThisForm.Read();
					// Open folios list
					#Удаление
					OpenFolios(Undefined);
					#КонецУдаления
					// Close form
					ThisForm.Close();
				Else
					// Refresh document data
					ThisForm.Read();
				EndIf;
			Else
				ShowMessageBox(, vResult);
				// Refresh document data
				ThisForm.Read();
			EndIf;
		Else
			// Notify that accommodation is changed
			Notify("Document.Accommodation.Write", Object.Ref, ThisForm);
			// Close document form if possible
			If Not ThisForm.Modified And ThisForm.IsOpen() Then
				// Refresh document data
				ThisForm.Read();
				// Open folios list
				#удаление
				OpenFolios(Undefined);
				#КонецУдаления
				// Close form
				ThisForm.Close();
			Else
				// Refresh document data
				ThisForm.Read();
			EndIf;
			// Check if we have to print customer folios automatically
			If tcOnServer.cmGetAttributeByRef(Object.Hotel, "PrintCustomerFolioAfterCheckout") Then
				PrintCustomerFolios();
			EndIf;
		EndIf;
	Else
		Return;
	EndIf;
EndProcedure

&AtClient
&ChangeAndValidate("PostAndClose")
Procedure Расш1_PostAndClose(pCommand)
	If ThisForm.ReadOnly Then
		Return;
	EndIf;
	// Clear messages left from previous run
	ClearMessages();
	#Вставка
	Если ThisForm.IsNew Тогда
		
		If ValueIsFilled(Object.Guest) Then
			
			ДанныеПроверки = ПроверитьАктуальностьСотрудника(Object.Guest);
			Если ДанныеПроверки.Уволен Тогда 
				ShowMessageBox(, СтрШаблон(NStr("en='Сотрудник уволен %1. Размещение сотрудника невозможно.';ru='Сотрудник уволен %1. Размещение сотрудника невозможно.';de='Сотрудник уволен %1. Размещение сотрудника невозможно.'"), Формат(ДанныеПроверки.ДатаУвольнения,"ДФ=dd.MM.yyyy")));
				Return;	
			КонецЕсли;
			
			ТекущийДокументРазмещенияСотрудника = ПолучитьТекущийДокументРазмещенияСотрудника(Object.Guest);
			Если Не ТекущийДокументРазмещенияСотрудника = Неопределено Тогда
				ShowMessageBox(, NStr("en='Сотрудник уже размещен! Документ размещения: ';ru='Сотрудник уже размещен! Документ размещения: ';de='Сотрудник уже размещен! Документ размещения: '") + ТекущийДокументРазмещенияСотрудника);
				Return;	
			КонецЕсли;
		Иначе
			ShowMessageBox(, NStr("en='Не заполнен сотрудник, размещение не возможно!';ru='Не заполнен сотрудник, размещение не возможно!';de='Не заполнен сотрудник, размещение не возможно!'") + ТекущийДокументРазмещенияСотрудника);
			Возврат;
		КонецЕсли; 
		
		//+Шершнев 20220921		             
		Если ValueIsFilled(ThisObject.Guest2) Тогда
			СтруктураПроверки = Новый Структура;
			СтруктураПроверки.Вставить("Гость", ThisObject.Guest2);
			ГостьУволен = ПроверитьАктуальностьГостя(СтруктураПроверки);
			Если ГостьУволен тогда
				возврат;
			КонецЕсли;	
		КонецЕсли;
		//-Шершнев 20220921
		
	Иначе
		
		If ValueIsFilled(Object.Guest) Then  
						
			ТекущийДокументРазмещенияСотрудника = ПолучитьДокументРазмещенияСотрудникаНеРавныйТекущему(Object.Guest, Object.Ref);
			Если ТекущийДокументРазмещенияСотрудника <>  Неопределено Тогда
				ShowMessageBox(, NStr("en='Сотрудник уже размещен! Документ размещения: ';ru='Сотрудник уже размещен! Документ размещения: ';de='Сотрудник уже размещен! Документ размещения: '") + ТекущийДокументРазмещенияСотрудника);
				Return;	
			КонецЕсли;
		Иначе
			ShowMessageBox(, NStr("en='Не заполнен сотрудник, размещение не возможно!';ru='Не заполнен сотрудник, размещение не возможно!';de='Не заполнен сотрудник, размещение не возможно!'") + ТекущийДокументРазмещенияСотрудника);
			Возврат;	
		КонецЕсли; 
		
		//+Шершнев 20220921
		ДанныеПроверки = ПроверитьАктуальностьСотрудника(Object.Guest);
			Если ДанныеПроверки.Уволен Тогда 
				ShowMessageBox(, СтрШаблон(NStr("en='Сотрудник уволен %1. Размещение сотрудника невозможно.';ru='Сотрудник уволен %1. Размещение сотрудника невозможно.';de='Сотрудник уволен %1. Размещение сотрудника невозможно.'"), Формат(ДанныеПроверки.ДатаУвольнения,"ДФ=dd.MM.yyyy")));
				Return;	
			КонецЕсли;
		//-Шершнев 20220921
		
		//+Шершнев 20220921		             
		Если ValueIsFilled(ThisObject.Guest2) Тогда
			СтруктураПроверки = Новый Структура;
			СтруктураПроверки.Вставить("Гость", ThisObject.Guest2);
			ГостьУволен = ПроверитьАктуальностьГостя(СтруктураПроверки);
			Если ГостьУволен тогда
				возврат;
			КонецЕсли;	
		КонецЕсли;
		//-Шершнев 20220921
		
	КонецЕсли;
	#КонецВставки
	// Check attributes
	If Not CheckAttributes() Then
		Return;
	EndIf;
	// Check user PIN if necessary
	If Not EmployeePINCodeChecked And tcOnServer.NeedToCheckEmployeePINCode() Then
		OpenForm("CommonForm.tcEmployeePINCheck", New Structure("ModeAfterCheck", "WriteAndClose"), ThisForm, , , , , FormWindowOpeningMode.LockOwnerWindow);
		Return;
	EndIf;
	EmployeePINCodeChecked = False;
	// Do write procedure
	#If Not WebClient And Not MobileClient Then
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 10, NStr("en='Posting...';ru='Проводка документа...';de='Ausführen des Dokuments...'"), PictureLib.LongOperation); 
	#EndIf
	vWasModified = ThisForm.Modified Or WasNew;
	vWarning = "";
	vResult = WriteAtServer(, vWarning);
	If Not IsBlankString(vWarning) Then
		If ValueIsFilled(vResult) Then
			Message(vWarning);
		Else
			ShowMessageBox(, vWarning);
		EndIf;
	EndIf;		
	If ValueIsFilled(vResult) And vResult <> "Error" Then
		#If ThickClientOrdinaryApplication Then
			ShowMessageBox(, NStr("en='Documents posting error! ';ru='Ошибка проводки документа! ';de='Fehler bei der Durchführung des Dokuments! '") + vResult);
		#Else
			Message(NStr("en='Documents posting error! ';ru='Ошибка проводки документа! ';de='Fehler bei der Durchführung des Dokuments! '") + vResult);
		#EndIf
	ElsIf Not ValueIsFilled(vResult) Then
		#If Not WebClient And Not MobileClient Then
			Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 90, NStr("en='Posting...';ru='Проводка документа...';de='Ausführen des Dokuments...'"), PictureLib.LongOperation); 
		#EndIf
		AfterWrite(New Structure());
		IsOnCloseForm = True;
		// Notify changes in the accounts subsystem
		Notify("Subsystem.Accounts.Changed", Object.Ref, ThisForm);
		Notify("Document.Accommodation.Write", Object.Ref, ThisForm);
		// Open folios list
		If vWasModified Then
			#Удаление
			OpenFolios(Undefined);
			#КонецУдаления
		EndIf;
		If GuestsToCheckInList.Count()>0 Then
			Notify("CheckIn", Object.Ref, ThisForm);
		EndIf;
		Close();
	Else
		Message(NStr("en='Documents posting error!';ru='Ошибка проводки документа!';de='Fehler bei der Durchführung des Dokuments!'"));
	EndIf;
	#If ThickClientOrdinaryApplication Then
		// Write to last visited objects
		cmWriteToLastVisitedObjects(amPersistentObjects, Object.Ref);
	#EndIf
EndProcedure

&AtServer
&ChangeAndValidate("OnCreateAtServer")
Procedure Расш1_OnCreateAtServer(pCancel, pStandardProcessing)
	#Вставка
	If Parameters.Key.IsEmpty() Then
		If Parameters.Property("Сотрудник") Then
			Object.Guest = Parameters.Сотрудник;	
		КонецЕсли;
		
		If Parameters.Property("Номер") Then
			Object.Room = Parameters.Номер;	
		КонецЕсли;
	КонецЕсли;
	#КонецВставки
	// Initialization
	WasNew = False;
	WasAlreadyPrint = False;
	LastKidsNumber = 0;
	LastNumberOfAdults = 1;
	NumberOfAdults = 1;
	NumberOfGuestFields = 5;
	NumberOfKidAgeFields = 4;
	FunctionsAndPrintFormsWereLoaded = False;
	
	// Save current user
	CurrentUser = SessionParameters.CurrentUser;
	
	// Agent is not permitted to open accommodations
	If ValueIsFilled(SessionParameters.CurrentUser) Then
		If ValueIsFilled(SessionParameters.CurrentUser.Customer) Then
			pCancel = True;
			Return;
		EndIf;
	Else
		pCancel = True;
		Return;
	EndIf;
	
	// Custom fields
	AddCustomFields();
	
	// Apply custom form settings
	If Parameters.Property("AvtoTest") Then
		If Parameters.AvtoTest Then
			Return;
		EndIf;	
	EndIf;
	
	// Process parameters
	If Parameters.Property("GuestGroup") Then
		If ValueIsFilled(Parameters.GuestGroup) Then
			Object.GuestGroup = Parameters.GuestGroup; 
		EndIf;
	EndIf;
	If Parameters.Property("RoomType") Then
		If ValueIsFilled(Parameters.RoomType) Then
			Object.RoomType = Parameters.RoomType; 
			If ValueIsFilled(Object.RoomType) And ValueIsFilled(Object.RoomType.BaseRoomType) Then
				Object.RoomTypeUpgrade = Object.RoomType;
				Object.RoomType = Object.RoomType.BaseRoomType;
				RoomPrice = 0;
				IsManualRoomPrice = 2;
				Items.RoomPrice.Visible = False;
				Items.RoomTypeUpgrade.Visible = True;
			EndIf;
		EndIf;
	EndIf;
	If Parameters.Property("CheckInDate") Then
		Object.CheckInDate = Parameters.CheckInDate;
	EndIf;
	If Parameters.Property("CheckOutDate") Then
		Object.CheckOutDate = Parameters.CheckOutDate;
	EndIf;
	If Parameters.Property("RoomQuota") Then
		If ValueIsFilled(Parameters.RoomQuota) Then
			Object.RoomQuota = Parameters.RoomQuota;
		EndIf;
	EndIf;
	If Parameters.Property("RoomRate") Then
		If ValueIsFilled(Parameters.RoomRate) Then
			Object.RoomRate = Parameters.RoomRate; 
			Object.RoomRateType = Object.RoomRate.RoomRateType;
			SetDurationCaption();
		EndIf;
	EndIf;
	If Parameters.Property("ClientType") Then
		If ValueIsFilled(Parameters.ClientType) Then
			Object.ClientType = Parameters.ClientType; 
		EndIf;
	EndIf;
	If Parameters.Property("Template") Then
		If ValueIsFilled(Parameters.Template) Then
			For each vAccType in Parameters.Template.AccommodationTypes Do
				vAge = Undefined;
				If ValueIsFilled(vAccType.AccommodationType) And vAccType.AccommodationType.AllowedClientAgeTo <> 0 Then
					vAge = BegOfDay(CurrentDate()) - (vAccType.AccommodationType.AllowedClientAgeTo - 1)*365*24*60*60;
				EndIf;
				
				vStructure = New Structure("AccommodationType, Amount, GuestName, GuestRef, DateOfBirth, Phone, Email, HotelProduct, LegalRepresentative, RelationType", vAccType.AccommodationType, Undefined, Undefined, Undefined, vAge, Undefined, Undefined, Undefined); 
				
				DocsList.Add(vStructure,vAccType.AccommodationType.SortCode);
			EndDo;
		EndIf;
	EndIf;
	If Parameters.Property("GuestsToCheckInList") And TypeOf(Parameters.GuestsToCheckInList) = Type("ValueList") Then
		GuestsToCheckInList.LoadValues(Parameters.GuestsToCheckInList.UnloadValues());
	EndIf;
	// Phone2
	If IsBlankString(Object.Fax) Then
		Items.AddPhone2.Visible = True;
		Items.Fax.Visible = false;
	Else
		Items.AddPhone2.Visible = False;
		Items.Fax.Visible = True;
	EndIf;

	vKeyParameter = ThisForm.Parameters.Key;
	If ValueIsFilled(vKeyParameter) Then
		If TypeOf(vKeyParameter) = Type("DocumentRef.Accommodation") Then
			ValueToFormAttribute(vKeyParameter.GetObject(), "Object");
		EndIf;
	EndIf;
	
	OneGuestModeWasNotSet = False;
	If Not Parameters.Property("OneGuestMode", OneGuestMode) Then
		OneGuestMode = False;
		OneGuestModeWasNotSet = True;
	EndIf;
	If Parameters.Property("IsForFolioSplit") Then
		IsForFolioSplit = Parameters.IsForFolioSplit;
	EndIf;
	
	If ThisForm.Parameters.Property("ParentAccommodation") And Not OneGuestMode Then
		vParentDoc = ThisForm.Parameters.ParentAccommodation;
		If ValueIsFilled(vParentDoc) And TypeOf(vParentDoc) = Type("DocumentRef.Accommodation") Then
			vNewObj = Documents.Accommodation.CreateDocument();
			vNewObj.Fill(vParentDoc);
			vNewObj.Room = vParentDoc.Room;
			ValueToFormAttribute(vNewObj, "Object");
		EndIf;
	EndIf;
	
	// Fill check-in/check-out day of week names
	If ValueIsFilled(Object.CheckInDate) Then
		CheckInDayOfWeek = Title(cmGetDayOfWeekName(WeekDay(Object.CheckInDate)));
	Else
		CheckInDayOfWeek = "";
	EndIf;
	If ValueIsFilled(Object.CheckOutDate) Then
		CheckOutDayOfWeek = Title(cmGetDayOfWeekName(WeekDay(Object.CheckOutDate)));
	Else
		CheckOutDayOfWeek = "";
	EndIf;
	
	// Fill Accommodation Statuses
	FillAccommodationStatusListChoice();
	
	// Fill parameters
	Items.ClientType.ChoiceList.LoadValues(GetArrayOfAllClientTypes());
	Items.SourceOfBusiness.ChoiceList.LoadValues(GetArrayOfAllSourceOfBusiness());
	Items.PriceChangeReason.ChoiceList.LoadValues(GetArrayOfAllPriceChangeReasons());
	
	// Fill room properties
	ThisForm.RoomProperties = GetRoomPropertiesValueList();
	
	If Not tcOnServer.cmCheckUserPermissionsAtServer("HavePermissionToAddManualDiscounts") Then
		Items.DiscountCard.Enabled = True;
		Items.DiscountType.Enabled = True;
		Items.Discount.Enabled = False;
		Items.DiscountServiceGroup.Enabled = False;
	EndIf;
	If Not tcOnServer.cmCheckUserPermissionsAtServer("HavePermissionToInputDiscountCardNumberManually") Then
		Items.DiscountCard.TextEdit = False;
		Items.DiscountCard.ChoiceButton = False;
		Items.DiscountCard.OpenButton = False;
	Else
		Items.DiscountCard.TextEdit = True;
		Items.DiscountCard.ChoiceButton = True;
		Items.DiscountCard.OpenButton = True;
	EndIf;
	
	// Price calculation date
	If Not tcOnServer.cmCheckUserPermissionsAtServer("HavePermissionToEditRoomRateServices") Then
		Items.PriceCalculationDate.ReadOnly = True;
	EndIf;
	
	// Register foreigners action availability
	vRegForeignerObjectFormAction = Catalogs.ObjectFormActions.AccommodationOpenForeignerRegistryRecord;
	If vRegForeignerObjectFormAction.DeletionMark Or Not vRegForeignerObjectFormAction.IsActive Then
		Items.FormOpenForeignerRegistryRecord.Visible = False;
	EndIf;
	
	// Scan documents action availability
	vScansObjectFormAction = Catalogs.ObjectFormActions.AccommodationScanClientData;
	If vScansObjectFormAction.DeletionMark Or Not vScansObjectFormAction.IsActive Then
		//Items.FormScanDocuments.Visible = False;
	EndIf;
	
	// Services availability
	If Not cmCheckUserPermissions("HavePermissionToEditRoomRateServices") Then
		Items.ServicesGroup.ReadOnly = True;
		Items.ServicesClearServicesManualChanges.Enabled = False;
	EndIf;
	Items.ServicesGroup.Visible = True;
	
	// Show properties
	If Not ValueIsFilled(Object.Ref) Then
		If Not cmCheckUserPermissions("HavePermissionToSkipInputOfAccommodationMarketingCode") Or 
		   Not cmCheckUserPermissions("HavePermissionToSkipInputOfAccommodationSourceOfBusiness") Or
		   Not cmCheckUserPermissions("HavePermissionToSkipInputOfClientType") Or
		   Not cmCheckUserPermissions("HavePermissionToSkipInputOfGuestTripPurpose") Then
			Items.GroupProperties.Show();
		EndIf;
	EndIf;
	
	// Charging rules
	If Not cmCheckUserPermissions("HavePermissionToEditChargingRules") Then
		Items.GroupChargingRules.ReadOnly = True;
		Items.ChargingRulesLoadDefaultChargingRules.Enabled = False;
	EndIf;
	
	// Document parameters
	If Not tcOnServer.cmIsInRole("Administrator") Then
		Items.GroupParameters.Visible = False;
	EndIf;
	
	// Check if this document is still being posted in the background
	DocumentBackgroundJobsCount = CheckForExistingBackgroundJobs().Count();
	
	// List of planned payment methods
	Items.PlannedPaymentMethod.ChoiceList.LoadValues(FillArrayOfPaymentMethods());

	// Fill functions and print forms list
	If ValueIsFilled(Object.Ref) Then
		FillFunctionsButton();
		FillPrintingButton();
		FunctionsAndPrintFormsWereLoaded = True;
	Else
		WasNew = True;
	EndIf;
	
	// Copy reservation function with new group creation
	vCopiedAcc = Undefined;
	If Parameters.Property("CopiedDocument") Then
		vCopiedAcc = Parameters.CopiedDocument;
		If ValueIsFilled(vCopiedAcc) Then
			vNewObj = vCopiedAcc.Copy();
			vNewObj.pmFillAuthorAndDate();
			vNewObj.pmCreateGuestGroup();
			vNewObj.RoomRates.Clear();
			vNewObj.Services.Clear();
			vNewObj.OccupationPercents.Clear();
			vNewObj.Guest = Undefined;
			vNewObj.GuestFullName = Undefined;
			vNewObj.Room = Undefined;
			vNewObj.CheckInDate = cm1SecondShift(CurrentSessionDate());
			vNewObj.CheckOutDate = vNewObj.pmCalculateCheckOutDate();
			vNewObj.NumberOfPersons = 1;
			vNewObj.NumberOfAdults = 1;
			vNewObj.NumberOfTeenagers = 0;
			vNewObj.NumberOfChildren = 0;
			vNewObj.NumberOfInfants = 0;
			vNewObj.AccommodationTemplate = Catalogs.AccommodationTemplates.EmptyRef();
			vNewObj.Phone = "";
			vNewObj.EMail = "";
			vNewObj.Car = "";
			ValueToFormAttribute(vNewObj, "Object");
		EndIf;
	EndIf;
	
	If ValueIsFilled(Object.Guest) Then
		SelGuest1 = TrimAll(Object.Guest.FullName);
		LastGuestFullName = SelGuest1;
	EndIf;
	
	// Check customer
	If ValueIsFilled(Object.Customer) Then
		Items.Contract.ReadOnly = False;
	Else
		Items.Contract.ReadOnly = True;
	EndIf;
	
	Items.FormOpenBlockForm.Enabled = Not WasNew;
	Items.FormCheckOut.Enabled = Not WasNew;
	
	// Fill document tasks button
	If ValueIsFilled(Object.Ref) Then
		vCount = GetNumberOfMessagesForObject(Object.Ref);
		If vCount = 0 Then
			Items.FormMessage.Title = NStr("en='Tasks';ru='Задачи';de='Aufgaben'");
		Else
			Items.FormMessage.Title = NStr("ru = 'Задачи - " + vCount + "'; en = 'Tasks - " + vCount + "'; de = 'Aufgaben - " + vCount + "'");
		EndIf;
	Else
		Items.FormMessage.Title = NStr("en='Tasks';ru='Задачи';de='Aufgaben'");
	EndIf;
	
	// Split services to 2 tables: rate charges and fixed charges
	vSrvFilter = New Structure("IsManual", False);
	Items.Services.RowFilter = New FixedStructure(vSrvFilter);	
	vFixFilter = New Structure("IsManual", True);
	Items.FixedCharges.RowFilter = New FixedStructure(vFixFilter);
	
	// Main form processing
	OnOpenForm(Object.Posted);
	
	// Hotel products
	UseHotelProducts = GetVauchersFunctionalOption();
	Items.HotelProduct.Visible = UseHotelProducts;
	Items.HotelProduct2.Visible = UseHotelProducts;
	Items.HotelProduct3.Visible = UseHotelProducts;
	Items.HotelProduct4.Visible = UseHotelProducts;
	Items.HotelProduct5.Visible = UseHotelProducts;
	
	// Check permissions
	OnOpenCheckPermissionsResult = BeforeOpenCheckPermissions();
	
	// Terms choice list
	FillServicePackageChoiceList();
	
	// Check if resort fee is used
	If Not ValueIsFilled(Object.Hotel.Region) Then
		Items.FormAddResortFeeExemption.Visible = False;
		Items.FormClearResortFeeExemption.Visible = False;
	EndIf;
	
	// Show room rate by default
	If Items.ServicePackage.Visible Then
		Items.GroupRoomRate.Show();
	EndIf;
	
	// Check protection system
	tcProtection.cmCheckForm(ThisForm);
	
	// Let's set the properties of the form
	tcOnServer.cmSetFormProperties(ThisForm);
EndProcedure

&AtServer
&ChangeAndValidate("OnOpenForm")
Procedure Расш1_OnOpenForm(pIsOnOpenMode)
	If IsOnCloseForm Then
		Return;
	EndIf;

	IsOnOpenForm = True;

	// Get object value
	vObj = FormAttributeToValue("Object");

	// Check guest value
	If ValueIsFilled(vObj.Guest) Then
		SelGuest1 = vObj.Guest.FullName;
		Items.SelGuest1.TextEdit = False;
	EndIf;

	// Get one room accommodations
	If OneGuestMode Then
		vAddOtherOneRoomGuests = False;
		Items.NumberOfAdultsKids.Visible = False;
	Else
		vAddOtherOneRoomGuests = True;
	EndIf;
	vAccommodationsArray = New Array;
	If Not vObj.IsNew() And vAddOtherOneRoomGuests Then
		WasPosted = True;
		IsNew = False;
		// Fill one room guests
		vQry = New Query;
		vQry.Text = "SELECT
		|	Accommodation.Ref AS Ref,
		|	Accommodation.Guest AS GuestRef,
		|	Accommodation.Guest.FullName AS Guest,
		|	Accommodation.AccommodationType AS AccommodationType,
		|	Accommodation.HotelProduct AS HotelProduct,
		|	FALSE AS IsStatusChanged,
		|	FALSE AS IsAnnulation,
		|	TRUE AS IsGuest,
		|	FALSE AS IsNoResortFee,
		|	&qEmptyAccommodationStatusRef AS AccommodationStatus,
		|	Accommodation.Guest.FullName AS LastGuestFullName,
		|	Accommodation.GuestCitizenship AS GuestCitizenship,
		|	FALSE AS RoomRateIsDifferent,
		|	FALSE AS DiscountsAreDifferent,
		|	FALSE AS ManualPricesAreDifferent,
		|	FALSE AS ServicePackagesAreDifferent,
		|	FALSE AS RoomRatesAreDifferent,
		|	FALSE AS CheckInDateIsDifferent,
		|	FALSE AS CheckOutDateIsDifferent,
		|	&qEmptyString AS ChangesDescription,
		|	Accommodation.LegalRepresentative AS LegalRepresentative,
		|	Accommodation.RelationType AS RelationType
		|FROM
		|	Document.Accommodation AS Accommodation
		|WHERE
		|	Accommodation.GuestGroup = &qGroup
		|	AND Accommodation.Number = &qNumber
		|	AND Accommodation.Ref <> &qAccRef
		|	AND Accommodation.Posted
		|	AND (Accommodation.AccommodationStatus.IsActive
		|			OR Accommodation.AccommodationStatus = &qAccStatus)
		|	AND Accommodation.CheckOutDate > &qAccCheckIn
		|	AND Accommodation.CheckInDate < &qAccCheckOut
		|
		|ORDER BY
		|	Accommodation.AccommodationType.SortCode";
		vQry.SetParameter("qGroup", vObj.GuestGroup);
		vQry.SetParameter("qAccRef", vObj.Ref);
		vQry.SetParameter("qAccCheckIn", vObj.CheckInDate);
		vQry.SetParameter("qAccCheckOut", vObj.CheckOutDate);
		vQry.SetParameter("qAccStatus", vObj.AccommodationStatus);
		vQry.SetParameter("qNumber", vObj.Number);
		vQry.SetParameter("qEmptyAccommodationStatusRef", Catalogs.AccommodationStatuses.EmptyRef());
		vQry.SetParameter("qEmptyString", "");
		vQryResult = vQry.Execute().Unload();

		vAccommodationsArray = vQryResult.UnloadColumn("Ref");
		vAccommodationsArray.Insert(0, vObj.Ref);

		ValueToFormAttribute(vQryResult, "GuestsInGroup");

		vGuestsList = New ValueTable();
		vGuestsList.Columns.Add("Guest", cmGetCatalogTypeDescription("Clients"));
		vGuestsList.Columns.Add("GuestAge", cmGetNumberTypeDescription(3, 0, True));
		For Each vGiGRow In GuestsInGroup Do
			// Check if guests have differences from main room guest
			vGuestDocRef = vGiGRow.Ref;
			If vGuestDocRef = vObj.Ref Then
				Continue;
			EndIf;
			If vGuestDocRef.CheckInDate <> vObj.CheckInDate Then
				vGiGRow.CheckInDateIsDifferent = True;
				vGiGRow.ChangesDescription = TrimAll(vGiGRow.ChangesDescription) + ?(IsBlankString(vGiGRow.ChangesDescription), "", ", ") + NStr("en='Check-in: '; ru='Заезд: '; de='Anreise: '") + Format(vGuestDocRef.CheckInDate, "DF='dd.MM.yyyy HH:mm'");
			EndIf;
			If vGuestDocRef.CheckOutDate <> vObj.CheckOutDate Then
				vGiGRow.CheckOutDateIsDifferent = True;
				vGiGRow.ChangesDescription = TrimAll(vGiGRow.ChangesDescription) + ?(IsBlankString(vGiGRow.ChangesDescription), "", ", ") + NStr("en='Check-out: '; ru='Выезд: '; de='Abreise: '") + Format(vGuestDocRef.CheckOutDate, "DF='dd.MM.yyyy HH:mm'");
			EndIf;
			If vGuestDocRef.RoomRate <> vObj.RoomRate Then
				vGiGRow.RoomRateIsDifferent = True;
				vGiGRow.ChangesDescription = TrimAll(vGiGRow.ChangesDescription) + ?(IsBlankString(vGiGRow.ChangesDescription), "", ", ") + NStr("en='Room rate: '; ru='Тариф: '; de='Tariff: '") + TrimAll(vGuestDocRef.RoomRate);
			EndIf;
			If vGuestDocRef.ServicePackage <> vObj.ServicePackage Or vGuestDocRef.ServicePackages.Count() <> vObj.ServicePackages.Count() Then
				vGiGRow.ServicePackagesAreDifferent = True;
				vGiGRow.ChangesDescription = TrimAll(vGiGRow.ChangesDescription) + ?(IsBlankString(vGiGRow.ChangesDescription), "", ", ") + NStr("en='Packages: '; ru='Пакеты: '; de='Pakete: '") + TrimAll(vGuestDocRef.ServicePackage);
				For Each vSPRow In vGuestDocRef.ServicePackages Do
					vGiGRow.ChangesDescription = TrimAll(vGiGRow.ChangesDescription) + ?(IsBlankString(vGiGRow.ChangesDescription), "", ", ") + TrimAll(vSPRow.ServicePackage);
				EndDo;
			EndIf;
			If vGuestDocRef.DiscountType <> vObj.DiscountType Or vGuestDocRef.Discount <> vObj.Discount Or vGuestDocRef.DiscountCard <> vObj.DiscountCard Then
				vGiGRow.DiscountsAreDifferent = True;
				vGiGRow.ChangesDescription = TrimAll(vGiGRow.ChangesDescription) + ?(IsBlankString(vGiGRow.ChangesDescription), "", ", ") + NStr("en='Discount type: '; ru='Тип скидки: '; de='Rabatttyp: '") + TrimAll(vGuestDocRef.DiscountType);
			EndIf;
			If vGuestDocRef.Discount <> vObj.Discount Then
				vGiGRow.DiscountsAreDifferent = True;
				vGiGRow.ChangesDescription = TrimAll(vGiGRow.ChangesDescription) + ?(IsBlankString(vGiGRow.ChangesDescription), "", ", ") + NStr("en='Discount %: '; ru='Скидка %: '; de='Rabatt %: '") + Format(vGuestDocRef.Discount, "ND=5; NFD=2");
			EndIf;
			If vGuestDocRef.DiscountCard <> vObj.DiscountCard Then
				vGiGRow.DiscountsAreDifferent = True;
				vGiGRow.ChangesDescription = TrimAll(vGiGRow.ChangesDescription) + ?(IsBlankString(vGiGRow.ChangesDescription), "", ", ") + NStr("en='Discount card: '; ru='Дисконтная карта: '; de='Rabattkarte: '") + TrimAll(vGuestDocRef.DiscountCard);
			EndIf;
			If vGuestDocRef.Prices.Count() <> 0 And (vGuestDocRef.Prices.Count() <> vObj.Prices.Count() Or vObj.Prices.Count() > 0 And vGuestDocRef.Prices.Get(0).Price <> vObj.Prices.Get(0).Price) Then
				vGiGRow.ManualPricesAreDifferent = True;
				For Each vPRow In vGuestDocRef.Prices Do
					If vPRow.Price = 0 And IsManualRoomPrice = 1 Then
						Continue;
					EndIf;
					vGiGRow.ChangesDescription = TrimAll(vGiGRow.ChangesDescription) + ?(IsBlankString(vGiGRow.ChangesDescription), "", ", ") + NStr("en='Manual price for: '; ru='Ручная цена за: '; de='Manuelle Preis für: '") + TrimAll(vPRow.Service) + " = " + cmFormatSum(vPRow.Price, vPRow.Currency, "NZ=");
				EndDo;
			EndIf;
			For Each vRRRow In vGuestDocRef.RoomRates Do
				If ValueIsFilled(vRRRow.RoomRate) And vRRRow.RoomRate <> vGuestDocRef.RoomRate Or 
					ValueIsFilled(vRRRow.AccommodationType) And vRRRow.AccommodationType <> vGuestDocRef.AccommodationType Then
					vGiGRow.RoomRatesAreDifferent = True;
					vGiGRow.ChangesDescription = TrimAll(vGiGRow.ChangesDescription) + ?(IsBlankString(vGiGRow.ChangesDescription), "", ", ") + Format(vRRRow.AccountingDate, "DF=dd.MM.yyyy") + " " + TrimAll(TrimAll(vRRRow.RoomRate) + " " + TrimAll(vRRRow.AccommodationType) + " " + TrimAll(vRRRow.Room) + " " + TrimAll(vRRRow.RoomType));
					Break;
				EndIf;
			EndDo;

			// Fill guests ages
			vAccType = vGiGRow.AccommodationType;
			If (ValueIsFilled(vGuestDocRef) And vGuestDocRef.GuestAge = 0 Or Not ValueIsFilled(vGuestDocRef)) And 
				(vAccType.AllowedClientAgeTo = 0 Or vAccType.AllowedClientAgeTo >= 18) Then
				NumberOfAdults = NumberOfAdults + 1;
			Else
				NumberOfKids = NumberOfKids + 1;
				vGuest = vGiGRow.GuestRef;
				vGuestsListRow = vGuestsList.Add();
				vGuestsListRow.Guest = vGuest;
				vKidAge = 0;
				If ValueIsFilled(vGuest) And ValueIsFilled(vGuest.DateOfBirth) Then
					vKidAge = GetClientAge(vGuest, vObj.CheckInDate);
				ElsIf ValueIsFilled(vGuestDocRef) Then
					vKidAge = vGuestDocRef.GuestAge;
				EndIf;
				If vKidAge = 0 And vAccType.AllowedClientAgeTo <> 0 Then
					vKidAge = vAccType.AllowedClientAgeTo - 1;
				EndIf;
				vGuestsListRow.GuestAge = vKidAge;
				Try
					ThisForm["KidAge"+String(NumberOfKids)] = vKidAge;
				Except
				EndTry;
			EndIf;
		EndDo;
		If NumberOfKids > 0 Then
			NumberOfKidsOnChangeAtServer(True, vGuestsList, vObj);
		EndIf;
		// Synchronize current accommodation room rates and document attributes
		vRoomRateWasChanged = False;
		vAccommodationTypeWasChanged = False;
		vRoomAttributesWereChanged = False;
		vOldRoomRate = vObj.RoomRate;
		vOldAccommodationType = vObj.AccommodationType;
		vOldRoom = vObj.Room;
		vOldRoomType = vObj.RoomType;
		vRoomRates = vObj.RoomRates.Unload();
		vRoomRates.Sort("AccountingDate Desc");
		For Each vRRRow In vRoomRates Do
			vLastRoomRate = vRRRow.RoomRate;
			vLastAccommodationType = vRRRow.AccommodationType;
			vLastRoom = vRRRow.Room;
			vLastRoomType = vRRRow.RoomType;
			If vRRRow.AccountingDate <= BegOfDay(CurrentSessionDate()) Then
				If ValueIsFilled(vLastRoomRate) And vLastRoomRate <> vObj.RoomRate Then
					vObj.RoomRate = vLastRoomRate;
					vObj.RoomRateType = vLastRoomRate.RoomRateType;
					SetDurationCaption(vObj);
					vRoomRateWasChanged = True;
					ThisForm.Modified = True;
				EndIf;
				If ValueIsFilled(vLastAccommodationType) And vLastAccommodationType <> vObj.AccommodationType Then
					vObj.AccommodationType = vLastAccommodationType;
					vAccommodationTypeWasChanged = True;
					ThisForm.Modified = True;
				EndIf;
				Break;
			EndIf;
		EndDo;
		If vRoomRateWasChanged Or vAccommodationTypeWasChanged Or vRoomAttributesWereChanged Then
			// Check if there is row for the check-in date in room rates
			If vObj.RoomRates.Find(BegOfDay(vObj.CheckInDate), "AccountingDate") = Undefined Then
				vCIRRRow = vObj.RoomRates.Add();
				vCIRRRow.AccountingDate = BegOfDay(vObj.CheckInDate);
				If vRoomRateWasChanged Then
					vCIRRRow.RoomRate = vOldRoomRate;
				EndIf;
				If vAccommodationTypeWasChanged Then
					vCIRRRow.AccommodationType = vOldAccommodationType;
				EndIf;
				If vRoomAttributesWereChanged Then
					vCIRRRow.Room = vOldRoom;
					vCIRRRow.RoomType = vOldRoomType;
				EndIf;
				vObj.RoomRates.Sort("AccountingDate, ChangeTime");
			EndIf;
		EndIf;
	Else
		If vObj.IsNew() Then
			ThisForm.Modified = True;
		EndIf;
		vRef = vObj.pmGetThisDocumentRef();
		vAccommodationsArray.Add(vRef);

		// Check number of persons
		If vObj.NumberOfPersons > 1 Then
			vObj.NumberOfPersons = 1;
		EndIf;
		// If check-in is in progress
		If GuestsToCheckInList.Count() = 0 And Not OneGuestMode Then
			If ValueIsFilled(vObj.ParentDoc) And vAddOtherOneRoomGuests Then
				vSelResList = GetOneRoomGuests(vObj.ParentDoc);
				If vSelResList.Count() > 0 Then
					GuestsToCheckInList = vSelResList.Copy();
				EndIf;
			EndIf;
		EndIf;
		If GuestsToCheckInList.Count() > 0 Then
			i = 0;
			For Each vGuestItem In GuestsToCheckInList Do
				vGuestItemValue = vGuestItem.Value;
				// Lock reservation
				LockDataForEdit(vGuestItemValue, , ThisForm.UUID);
				// Process reservations
				If i = 0 Then
					If vObj.ParentDoc <> vGuestItemValue Then
						vObj.Fill(vGuestItemValue);
					EndIf;
					SelGuest1 = vGuestItemValue.Guest.FullName;
					If ValueIsFilled(vGuestItemValue.Guest) Then
						Items.SelGuest1.TextEdit = False;
					EndIf;
					// Fill room properties
					ThisForm.RoomProperties = GetRoomPropertiesValueList(vObj);
				Else
					vNewRow = GuestsInGroup.Add();
					vNewRow.Guest = vGuestItemValue.Guest.FullName;
					vNewRow.AccommodationType = vGuestItemValue.AccommodationType;
					vNewRow.GuestRef = vGuestItemValue.Guest;
					vNewRow.IsGuest = True;
					vNewRow.HotelProduct = vGuestItemValue.HotelProduct;
					vNewRow.LegalRepresentative = vGuestItemValue.LegalRepresentative;
					vNewRow.RelationType = vGuestItemValue.RelationType;
				EndIf;
				i = i + 1;
			EndDo;
			// check GiG
			vGuestsList = New ValueTable();
			vGuestsList.Columns.Add("Guest", cmGetCatalogTypeDescription("Clients"));
			vGuestsList.Columns.Add("GuestAge", cmGetNumberTypeDescription(3, 0, True));
			For Each vGiGRow In GuestsInGroup Do
				vGuestDocRef = vGiGRow.Ref;
				If Not ValueIsFilled(vGuestDocRef) Then
					vGuestDocRef = GuestsToCheckInList.Get(GuestsInGroup.IndexOf(vGiGRow) + 1).Value;
				EndIf;
				vAccType = vGiGRow.AccommodationType;
				If (ValueIsFilled(vGuestDocRef) And vGuestDocRef.GuestAge = 0 Or Not ValueIsFilled(vGuestDocRef)) And 
					(vAccType.AllowedClientAgeTo = 0 Or vAccType.AllowedClientAgeTo >= 18) Then
					NumberOfAdults = NumberOfAdults + 1;
				Else
					NumberOfKids = NumberOfKids + 1;
					vGuest = vGiGRow.GuestRef;
					vGuestsListRow = vGuestsList.Add();
					vGuestsListRow.Guest = vGuest;
					vKidAge = 0;
					If ValueIsFilled(vGuest) And ValueIsFilled(vGuest.DateOfBirth) Then
						vKidAge = GetClientAge(vGuest, vObj.CheckInDate);
						If vKidAge = 0 And vAccType.AllowedClientAgeTo <> 0 Then
							vKidAge = vAccType.AllowedClientAgeTo - 1;
						EndIf;
						Try
							ThisForm["KidAge"+String(NumberOfKids)] = vKidAge;
						Except
						EndTry;
					ElsIf ValueIsFilled(vGuestDocRef) Then
						vKidAge = vGuestDocRef.GuestAge;
					EndIf;
					vGuestsListRow.GuestAge = vKidAge;
				EndIf;
			EndDo;
			If NumberOfKids > 0 Then
				NumberOfKidsOnChangeAtServer(True, vGuestsList, vObj);
			EndIf;
		EndIf;
	EndIf;

	// Add guests from "Available rooms" report selection. This code is applied for the new document form only
	If DocsList.Count() > 0 And Not OneGuestMode Then
		NumberOfKids = 0;
		DocsList.SortByPresentation();
		NumberOfAdults = DocsList.Count();
		For vDocInd = 0 to DocsList.Count()-1 Do
			vDocIndRef = DocsList.Get(vDocInd).Value;
			If vDocInd = 0 Then
				vObj.Phone = vDocIndRef.Phone;
				vObj.Email = vDocIndRef.Email;
				vObj.Guest = vDocIndRef.GuestRef;
				SelGuest1 = vDocIndRef.GuestName;
				If ValueIsFilled(vObj.Guest) Then
					Items.SelGuest1.TextEdit = False;
				EndIf;
			Else
				vNewGuest = GuestsInGroup.Add();
				vNewGuest.AccommodationType = vDocIndRef.AccommodationType;
				vNewGuest.Guest = vDocIndRef.GuestName;
				vNewGuest.GuestRef= vDocIndRef.GuestRef;
				vNewGuest.IsAnnulation = False;
				vNewGuest.IsGuest = True;
				vNewGuest.HotelProduct = vDocIndRef.HotelProduct;
				vNewGuest.LegalRepresentative = vDocIndRef.LegalRepresentative;
				vNewGuest.RelationType = vDocIndRef.RelationType;
				If ValueIsFilled(vDocIndRef.DateOfBirth) Then
					vAge = GetClientAge( , vObj.CheckInDate, vDocIndRef.DateOfBirth);
					If vAge <> 0 And vAge<18 Then
						NumberOfKids = NumberOfKids + 1;
						Try
							Items["KidAge"+String(NumberOfKids)].Visible = True;
							ThisForm["KidAge"+String(NumberOfKids)] = vAge;
						Except
						EndTry;
					EndIf;					
				EndIf;
			EndIf;
		EndDo;
		NumberOfAdults = NumberOfAdults - NumberOfKids;
	EndIf;

	// Main room guest accommodation type is editable if he is the only guest in the room
	If NumberOfAdults = 1 And NumberOfKids = 0 Then
		Items.AccommodationType.TextEdit = True;
		Items.AccommodationType.Enabled = True;
	Else
		Items.AccommodationType.TextEdit = False;
		Items.AccommodationType.Enabled = False;
	EndIf;

	// Manual prices
	If Not vObj.IsNew() Then
		ManualPriceAppearance(vObj);
	EndIf;

	// Apply form appearance according to the room guests and guest ages
	CheckGuestFieldCount(vObj, True);

	// Hide or show guest changes
	For Each vGiGRow In GuestsInGroup Do
		vInd = GuestsInGroup.IndexOf(vGiGRow) + 2;
		ThisForm["GuestChangesDescription" + String(vInd)] = vGiGRow.ChangesDescription;
		vCDItem = Items["Guest" + String(vInd) + "ChangesGroup"];
		If Not IsBlankString(vGiGRow.ChangesDescription) Then
			vCDItem.Visible = True;
		Else
			vCDItem.Visible = False;
		EndIf;
		ThisForm["LegalRepresentative" + String(vInd)] 	= vGiGRow.LegalRepresentative;
		ThisForm["RelationType" + String(vInd)] 		= vGiGRow.RelationType;
	EndDo;

	// Get current user customer and allotment
	vAuthorCustomer = SessionParameters.CurrentUser.Customer;
	vAuthorRoomQuota = SessionParameters.CurrentUser.RoomQuota;

	// Set default attributes if is new
	If vObj.IsNew() Then
		WasPosted = False;
		IsNew = True;
		// Use current time
		vObj.SetTime(AutoTimeMode.CurrentOrLast);
		// Fill attributes with default values
		If Not ValueIsFilled(vObj.Author) Then
			vObj.pmFillAttributesWithDefaultValues();
		Else
			vObj.pmFillAuthorAndDate();
		EndIf;
		If Parameters.Property("Event") And ValueIsFilled(Parameters.Event) Then
			vObjvGGObj = vObj.GuestGroup.GetObject();
			vObjvGGObj.Event = Parameters.Event;
			vObjvGGObj.Write();
		EndIf;
		If ValueIsFilled(vObj.AccommodationTemplate) And vObj.AccommodationTemplate.IsForFolioSplit Then
			IsForFolioSplit = True;
		ElsIf ValueIsFilled(vObj.AccommodationType) And vObj.AccommodationType.Type = Enums.AccomodationTypes.Beds Then
			If ValueIsFilled(vObj.RoomType) And ValueIsFilled(vObj.RoomType.AccommodationType) And vObj.RoomType.AccommodationType.Type = Enums.AccomodationTypes.Beds Then
				IsForFolioSplit = True;
			ElsIf ValueIsFilled(vObj.Hotel) And ValueIsFilled(vObj.Hotel.AccommodationType) And vObj.Hotel.AccommodationType.Type = Enums.AccomodationTypes.Beds Then
				IsForFolioSplit = True;
			EndIf;
		ElsIf ValueIsFilled(vObj.Hotel) And ValueIsFilled(vObj.Hotel.AccommodationType) And vObj.Hotel.AccommodationType.Type = Enums.AccomodationTypes.Beds Then
			IsForFolioSplit = True;
		EndIf;
		// Calculate resources
		vObj.pmCalculateResources();
		// Set is by reservation flag
		vObj.pmSetIsByReservation();
		// Check and show room status if this is accommodation based on reservation
		If ValueIsFilled(vObj.Room) And ValueIsFilled(vObj.Room.RoomStatus) Then
			If ValueIsFilled(vObj.ParentDoc) And TypeOf(vObj.ParentDoc) = Type("DocumentRef.Reservation") Then
				// Check room status
				vCurRoomStatus = vObj.Room.RoomStatus;
				If vCurRoomStatus <> vObj.Hotel.VacantRoomStatus And
					Not vCurRoomStatus.RoomIsVacantClear And 
					vCurRoomStatus <> vObj.Hotel.OccupiedRoomStatus And
					vCurRoomStatus <> vObj.Hotel.ReservedRoomStatus Then
					ChangeRoomMessageText = NStr("ru='Статус забронированного номера: " + TrimAll(vCurRoomStatus) + "!'; 
					|de='Room reserved status is " + TrimAll(vCurRoomStatus) + "!';
					|en='Room reserved status is " + TrimAll(vCurRoomStatus) + "!'");
					Items.ChangeRoomMessageTextGroup.Visible = True;
					Items.ChangeRoomMessageText.TextColor = WebColors.Red;
				EndIf;
			EndIf;
		EndIf;
	Else
		ChangeRoomMessageText = "";
		vChangeRoomMessageTextColor = WebColors.Blue;
		vPrevRoom = Undefined;
		vDoNotChangeAvailabilityInfo = False;
		vRoomRates = vObj.pmGetAccommodationPeriods();
		For Each vRRRow In vRoomRates Do
			If ValueIsFilled(vRRRow.Room) And vRRRow.Room <> vPrevRoom Then
				If vPrevRoom <> Undefined And ValueIsFilled(vRRRow.Room) And ValueIsFilled(vRRRow.RoomType) Then
					If IsBlankString(ChangeRoomMessageText) Then
						ChangeRoomMessageText = NStr("en='Room change '; ru='Переселение '; de='Umzug '") + TrimAll(vPrevRoom) + " " + TrimAll(vPrevRoom.RoomType.Code) + " -> " + TrimAll(vRRRow.Room) + " " + TrimAll(vRRRow.RoomType.Code);
					Else
						ChangeRoomMessageText = TrimAll(ChangeRoomMessageText) + " -> " + TrimAll(vRRRow.Room) + " " + TrimAll(vRRRow.RoomType.Code);
					EndIf;
				EndIf;
				vPrevRoom = vRRRow.Room;
			EndIf;
			If vRRRow.DoNotChangeAvailability And Not vDoNotChangeAvailabilityInfo Then
				vDoNotChangeAvailabilityInfo = True;
				vMessageText = Format(vRRRow.AccountingDate, "DF=dd.MM.yyyy") + " - " + NStr("en='Availability is not changed!'; ru='Доступность не изменяется!'; de='Verfügbarkeit wird nicht geändert!'");
				If IsBlankString(ChangeRoomMessageText) Then
					ChangeRoomMessageText = vMessageText;
				Else
					ChangeRoomMessageText = ChangeRoomMessageText + Chars.LF + vMessageText;
				EndIf;
			EndIf;
		EndDo;
		If IsBlankString(ChangeRoomMessageText) Then
			If ValueIsFilled(vObj.Reservation) Then
				vReservation = vObj.Reservation;
				If vReservation.RoomType <> vObj.RoomType And ValueIsFilled(vReservation.RoomType) And ValueIsFilled(vObj.RoomType) Then
					ChangeRoomMessageText = ChangeRoomMessageText + Chars.LF + NStr("en='Upsell '; ru='Ап-селл '; de='Upsell '") + TrimAll(vReservation.RoomType.Code) + " -> " + TrimAll(vObj.RoomType.Code);
					vChangeRoomMessageTextColor = WebColors.Blue;
				EndIf;
			EndIf;
		EndIf;
		If ValueIsFilled(vObj.RoomTypeUpgrade) And vObj.RoomType <> vObj.RoomTypeUpgrade Then
			ChangeRoomMessageText = ChangeRoomMessageText + ?(IsBlankString(ChangeRoomMessageText), "", ", ") + NStr("en='Prices by '; ru='Цены по '; de='Preise nach '") + TrimAll(vObj.RoomTypeUpgrade.Code);
		EndIf;
		ChangeRoomMessageText = TrimAll(ChangeRoomMessageText);
		If Not IsBlankString(ChangeRoomMessageText) Then
			Items.ChangeRoomMessageTextGroup.Visible = True;
			Items.ChangeRoomMessageText.TextColor = vChangeRoomMessageTextColor;
		EndIf;
	EndIf;
	If ValueIsFilled(vAuthorCustomer) Then
		Items.Customer.ClearButton = False;
		Items.Customer.ChoiceButton = False;
		Items.Customer.ReadOnly = True;
		If Not IsNew Then
			Items.CheckInDate.ReadOnly = True;
		EndIf;
		Items.Room.ClearButton = False;
		Items.Room.ChoiceButton = False;
		Items.Room.ReadOnly = True;
	EndIf;
	If ValueIsFilled(vAuthorRoomQuota) Then
		Items.RoomQuota.ClearButton = False;
		Items.RoomQuota.ChoiceButton = False;
		Items.RoomQuota.OpenButton = False;
		Items.RoomQuota.ReadOnly = True;
	EndIf;

	// Read foreigner registry documents
	ReadForeignerRegistryDocuments(vObj);

	// Manual prices
	If vObj.IsNew() Then
		ManualPriceAppearance(vObj);
	EndIf;

	// Check edit prohibited date
	If ValueIsFilled(vObj.Hotel) Then
		If ValueIsFilled(vObj.Hotel.EditProhibitedDate) And 
			BegOfDay(vObj.Hotel.EditProhibitedDate) >= BegOfDay(vObj.CheckOutDate) Then
			DoFormReadOnly();
		EndIf;
	EndIf;

	// Check user permissions
	CheckPermissions(vObj);

	// Fill times 
	#Удаление
	CheckInTime = cmExtractTime(vObj.CheckInDate); 
	CheckOutTime = cmExtractTime(vObj.CheckOutDate);
	#КонецУдаления	
	#Вставка
	SecondsPerHour = 60 * 60;	
	CheckInTime = cmExtractTime(НачалоДня(vObj.CheckInDate) + SecondsPerHour *8);
	CheckOutTime = cmExtractTime(НачалоДня(vObj.CheckInDate) + SecondsPerHour *8);
	
	If not vObj.IsNew() and Not tcOnServer.cmIsInRole("Administrator") Then
		Items.Room.ReadOnly = True;
	EndIf;	
	
	#КонецВставки                                   
	// Fill check-in/check-out day of week names
	If ValueIsFilled(vObj.CheckInDate) Then
		CheckInDayOfWeek = Title(cmGetDayOfWeekName(WeekDay(vObj.CheckInDate)));
	Else
		CheckInDayOfWeek = "";
	EndIf;
	If ValueIsFilled(vObj.CheckOutDate) Then
		CheckOutDayOfWeek = Title(cmGetDayOfWeekName(WeekDay(vObj.CheckOutDate)));
	Else
		CheckOutDayOfWeek = "";
	EndIf;

	// Set discounts if is based on operation template
	If vObj.IsNew() And IsBasedOnOperationTemplate Then
		vObj.pmSetDiscounts();
	EndIf;

	// Fill list of rooms in reservation
	FillReservationRoomsList(vObj);

	// Load customer contact persons list
	LoadCustomerContactPersonsList(vObj);

	// Set room quota appearance
	SetRoomQuotaAppearance(vObj);

	// Save current guest group and room rate values
	SavGuestGroup = vObj.GuestGroup;
	SavRoomRate = vObj.RoomRate;
	SavRoomType = vObj.RoomType;

	// Check if all document charges are closed by settlements
	If vObj.Posted Then
		If ValueIsFilled(vObj.Hotel) And vObj.Hotel.DoNotEditSettledDocs And 
			(vObj.Services.Total("Sum") <> 0 Or vObj.Services.Total("Quantity") <> 0) And 
			ValueIsFilled(vObj.AccommodationStatus) And vObj.AccommodationStatus.IsActive And Not vObj.AccommodationStatus.IsInHouse And 
			cmGetDocumentCharges(vObj.Ref, Undefined, Undefined, vObj.Hotel, Undefined, True).Count() > 0 Then
			vDocBalanceIsZero = False;
			vDocBalancesRow = cmGetDocumentCurrentAccountsReceivableBalance(vObj.Ref);
			If vDocBalancesRow <> Undefined Then
				If vDocBalancesRow.SumBalance = 0 And vDocBalancesRow.QuantityBalance = 0 Then
					vDocBalanceIsZero = True;
				EndIf;
			Else
				vDocBalanceIsZero = True;
			EndIf;
			If vDocBalanceIsZero Then
				DoFormReadOnly();
				If Not IsInRestoreFromHistoryMode Then
					Message(NStr("ru='Все начисления размещения уже закрыты актами об оказании услуг! Редактирование такого размещения запрещено.';en='All accommodation charges are closed by settlements! Accommodation will be opened read only.';de='All accommodation charges are closed by settlements! Accommodation will be opened read only.'"));
				EndIf;
			EndIf;
		EndIf;
	EndIf;

	// Check if we have to rebuild guest folios
	vObj.pmCheckRoomMainFolios();

	// Update planned payment method if necessary
	Payer = vObj.pmSetPlannedPaymentMethod(TPayer);
	If Payer = Enums.WhoPays.ChargingRules Then
		Items.GroupChargingRules.Show();
	Else
		Items.GroupChargingRules.Hide();
	EndIf;

	// Fill guest group description
	If ValueIsFilled(vObj.GuestGroup) Then
		vGuestGroup = vObj.GuestGroup;
		Items.GuestGroupDescription.Enabled = True;
		GuestGroupDescription = TrimAll(vGuestGroup.Description);
		Items.GuestGroupID.Enabled = True;
		GuestGroupID = TrimAll(vGuestGroup.ID);
		Items.GuestGroupCreateDate.Enabled = True;
		GuestGroupCreateDate = vGuestGroup.CreateDate;
	Else
		Items.GuestGroupDescription.Enabled = False;
		GuestGroupDescription = "";
		Items.GuestGroupID.Enabled = False;
		GuestGroupID = "";
		Items.GuestGroupCreateDate.Enabled = False;
		GuestGroupCreateDate = '00010101';
	EndIf;

	SetDurationCaption(vObj);

	// Room interface commands list
	SetRoomInterfacesFilter(vObj);

	// Set object value
	ValueToFormAttribute(vObj, "Object");

	// Custom fields
	FillCustomFields();

	IsOnOpenForm = False;

	// Calculate totals
	TotalSum = CalculateTotalServices(, pIsOnOpenMode, False, False);

	// Fill presentation
	ThisForm.RoomPropertiesPresentation = GetRoomPropertiesPresentation();

	// Fill service packages presentation
	FillServicePackagesPresentation();

	// Check charging mode
	If ValueIsFilled(vObj.Hotel) And vObj.Hotel.CloseOfPeriodDoChargeServices Then
		Items.DoChargingToDate.Visible = True;
	Else
		If ValueIsFilled(vObj.RoomRate) And vObj.RoomRate.CloseOfPeriodDoChargeServices Then
			Items.DoChargingToDate.Visible = True;
		Else
			Items.DoChargingToDate.Visible = False;
		EndIf;
	EndIf;

	// Credit card presentation
	If ValueIsFilled(vObj.CreditCard) Then
		CreditCardPresentation = TrimAll(vObj.CreditCard);
		Items.ClearCreditCard.Visible = True;
	Else
		CreditCardPresentation = NStr("en='<Credit card>'; ru='<Кредитная карта>'; de='<Kreditkarte>'");
		Items.ClearCreditCard.Visible = False;
	EndIf;
	If Not cmCheckUserPermissions("HavePermissionToEditGuestGroup") Then
		Items.GuestGroup.ReadOnly = True;
		Items.GuestGroup.ChoiceButton = False;
	EndIf;
	If Not cmCheckUserPermissions("HavePermissionToViewCreditCardsData") Then
		Items.CreditCardPresentation.Visible = False;
		Items.ClearCreditCard.Visible = False;
	EndIf;

	// Window views
	vViews = cmGetWindowViews(Object.Hotel);
	vRoomTypesWithViews = cmGetRoomTypesWithViews(Object.Hotel);
	If vViews.Count() > 0 And vRoomTypesWithViews.Count() > 0 Then
		Items.RoomType.Visible = False;
		Items.GroupRoomType.Visible = True;
		If ValueIsFilled(Object.RoomType) Then
			WindowView = Object.RoomType.WindowView;
			RoomTypeFolder = Object.RoomType.Parent;
		Else
			WindowView = Undefined;
			RoomTypeFolder = Undefined;
		EndIf;
	Else
		Items.RoomType.Visible = True;
		Items.GroupRoomType.Visible = False;
		WindowView = Undefined;
		RoomTypeFolder = Undefined;
	EndIf;

	// Meal board terms
	vTerms = cmGetAllMealBoardTerms(Object.Hotel);
	If vTerms.Count() > 0 Then
		Items.ServicePackage.Visible = True;
		Items.ServicePackage.ChoiceList.LoadValues(GetMealBoardTermsList(Object.Hotel, Object.Contract).UnloadValues());
	Else
		Items.ServicePackage.Visible = False;
	EndIf;

	// Form actions availability
	If Not Object.AccommodationStatus.IsInHouse Then
		vAccountingDate = tcOnServer.GetForecastStartDate(Object.Hotel);
		If BegOfDay(vAccountingDate) = BegOfDay(Object.CheckOutDate) Then
			Items.FormCheckOutReversal.Visible = True;
			Items.FormCheckOutReversal.Enabled = True;
		Else
			If Not cmCheckUserPermissions("HavePermissionToEditCheckedOutAccommodations") Then
				Items.FormCheckOutReversal.Visible = True;
				Items.FormCheckOutReversal.Enabled = False;
			Else
				Items.FormCheckOutReversal.Visible = True;
				Items.FormCheckOutReversal.Enabled = True;
			EndIf;
		EndIf;
		Items.FormCheckOut.Visible = False;
		Items.FormCheckOut.Enabled = False;
		#Удаление	
		Items.ButtonPay.Enabled = False;
		Items.ButtonKey.Enabled = False;
		#КонецУдаления
	Else
		Items.FormCheckOutReversal.Visible = False;
		Items.FormCheckOutReversal.Enabled = False;
	EndIf;

	// Build form caption
	BuildThisFormCaption();

	// Build remarks group hidden title
	BuildThisFormRemarksDataDecoration();

	// Build client's decoration
	BuildThisFormClientDataDecoration();

	// Commission group hidden title
	BuildCommissionGroupCollapsedTitle();

	// Build accounting group hidden title
	BuildAccountingGroupCollapsedTitle();

	// Build room rate group hidden title
	BuildRoomRateGroupCollapsedTitle();

	// Build discounts group hidden title
	BuildDiscountsGroupCollapsedTitle();

	// Build discounts group hidden title
	BuildStatusGroupCollapsedTitle();

	// Build guest group group hidden title
	BuildGuestGroupGroupCollapsedTitle();

	// Fill orders
	FillOrders();

	// Fill document tasks presentation
	FillTasksPresentation();
EndProcedure

&НаСервере
Функция ПолучитьТекущийДокументРазмещенияСотрудника(Сотрудник)
	
	ДокументРазмещения =Неопределено;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ ПЕРВЫЕ 1
		|	Accommodation.Ссылка КАК Document
		|ИЗ
		|	Документ.Accommodation КАК Accommodation
		|ГДЕ
		|	Accommodation.Guest = &qClient
		|	И Accommodation.AccommodationStatus.IsActive
		|	И Accommodation.AccommodationStatus.IsInHouse
		|	И Accommodation.Проведен
		|
		|УПОРЯДОЧИТЬ ПО
		|	Accommodation.Дата";
	
	Запрос.УстановитьПараметр("qClient", Сотрудник);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		ДокументРазмещения = ВыборкаДетальныеЗаписи.Document;
	КонецЦикла;
	
	Возврат ДокументРазмещения
	
КонецФункции

Функция ПолучитьДокументРазмещенияСотрудникаНеРавныйТекущему(Сотрудник, Документ)
	
	ДокументРазмещения = Неопределено;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ ПЕРВЫЕ 1
		|	Accommodation.Ссылка КАК Document
		|ИЗ
		|	Документ.Accommodation КАК Accommodation
		|ГДЕ
		|	Accommodation.Guest = &qClient
		|	И Accommodation.AccommodationStatus.IsActive
		|	И Accommodation.AccommodationStatus.IsInHouse
		|	И Accommodation.Проведен
		|	И Accommodation.Ссылка <> &Ссылка
		|
		|УПОРЯДОЧИТЬ ПО
		|	Accommodation.Дата";
	
	Запрос.УстановитьПараметр("qClient", Сотрудник);
	Запрос.УстановитьПараметр("Ссылка", Документ);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		ДокументРазмещения = ВыборкаДетальныеЗаписи.Document;
	КонецЦикла;
	
	Возврат ДокументРазмещения
	
КонецФункции

&AtClient
&ChangeAndValidate("Post")
Procedure Расш1_Post(pCommand)
	If ThisForm.ReadOnly Then
		Return;
	EndIf;
	// Clear messages left from previous run
	ClearMessages();
	#Вставка
	Если ThisForm.IsNew Тогда
		
		If ValueIsFilled(Object.Guest) Then
			
			ДанныеПроверки = ПроверитьАктуальностьСотрудника(Object.Guest);
			Если ДанныеПроверки.Уволен Тогда 
				ShowMessageBox(, СтрШаблон(NStr("en='Сотрудник уволен %1. Размещение сотрудника невозможно.';ru='Сотрудник уволен %1. Размещение сотрудника невозможно.';de='Сотрудник уволен %1. Размещение сотрудника невозможно.'"), Формат(ДанныеПроверки.ДатаУвольнения,"ДФ=dd.MM.yyyy")));
				Return;	
			КонецЕсли;
			
			ТекущийДокументРазмещенияСотрудника = ПолучитьТекущийДокументРазмещенияСотрудника(Object.Guest);
			Если Не ТекущийДокументРазмещенияСотрудника = Неопределено Тогда
				ShowMessageBox(, NStr("en='Сотрудник уже размещен! Документ размещения: ';ru='Сотрудник уже размещен! Документ размещения: ';de='Сотрудник уже размещен! Документ размещения: '") + ТекущийДокументРазмещенияСотрудника);
				Return;	
			КонецЕсли;
		Иначе
			ShowMessageBox(, NStr("en='Не заполнен сотрудник, размещение не возможно!';ru='Не заполнен сотрудник, размещение не возможно!';de='Не заполнен сотрудник, размещение не возможно!'") + ТекущийДокументРазмещенияСотрудника);
			Возврат;
		КонецЕсли; 
		
		//+Шершнев 20220921		             
		Если ValueIsFilled(ThisObject.Guest2) Тогда
			СтруктураПроверки = Новый Структура;
			СтруктураПроверки.Вставить("Гость", ThisObject.Guest2);
			ГостьУволен = ПроверитьАктуальностьГостя(СтруктураПроверки);
			Если ГостьУволен тогда
				возврат;
			КонецЕсли;	
		КонецЕсли;
		//-Шершнев 20220921
		
	Иначе
		
		If ValueIsFilled(Object.Guest) Then
			
			//+Шершнев 20220921
			ДанныеПроверки = ПроверитьАктуальностьСотрудника(Object.Guest);
			Если ДанныеПроверки.Уволен Тогда 
				ShowMessageBox(, СтрШаблон(NStr("en='Сотрудник уволен %1. Размещение сотрудника невозможно.';ru='Сотрудник уволен %1. Размещение сотрудника невозможно.';de='Сотрудник уволен %1. Размещение сотрудника невозможно.'"), Формат(ДанныеПроверки.ДатаУвольнения,"ДФ=dd.MM.yyyy")));
				Return;	
			КонецЕсли;
			//-Шершнев 20220921
			
			ТекущийДокументРазмещенияСотрудника = ПолучитьДокументРазмещенияСотрудникаНеРавныйТекущему(Object.Guest, Object.Ref);
			Если ТекущийДокументРазмещенияСотрудника <>  Неопределено Тогда
				ShowMessageBox(, NStr("en='Сотрудник уже размещен! Документ размещения: ';ru='Сотрудник уже размещен! Документ размещения: ';de='Сотрудник уже размещен! Документ размещения: '") + ТекущийДокументРазмещенияСотрудника);
				Return;	
			КонецЕсли;
		Иначе
			ShowMessageBox(, NStr("en='Не заполнен сотрудник, размещение не возможно!';ru='Не заполнен сотрудник, размещение не возможно!';de='Не заполнен сотрудник, размещение не возможно!'") + ТекущийДокументРазмещенияСотрудника);
			Возврат;	
			
		КонецЕсли;   
		
		//+Шершнев 20220921		             
		Если ValueIsFilled(ThisObject.Guest2) Тогда
			СтруктураПроверки = Новый Структура;
			СтруктураПроверки.Вставить("Гость", ThisObject.Guest2);
			ГостьУволен = ПроверитьАктуальностьГостя(СтруктураПроверки);
			Если ГостьУволен тогда
				возврат;
			КонецЕсли;	
		КонецЕсли;
		//-Шершнев 20220921
		
	КонецЕсли;
	#КонецВставки
	// Check attributes
	If Not CheckAttributes() Then
		Return;
	EndIf;
	// Check user PIN if necessary
	If Not EmployeePINCodeChecked And tcOnServer.NeedToCheckEmployeePINCode() Then
		OpenForm("CommonForm.tcEmployeePINCheck", New Structure("ModeAfterCheck", "Write"), ThisForm, , , , , FormWindowOpeningMode.LockOwnerWindow);
		Return;
	EndIf;
	EmployeePINCodeChecked = False;
	// Do write procedure
	#If Not WebClient And Not MobileClient Then
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 10, NStr("en='Posting...';ru='Проводка документа...';de='Ausführen des Dokuments...'"), PictureLib.LongOperation); 
	#EndIf
	vWarning = "";
	vResult = WriteAtServer(, vWarning, True);
	If Not IsBlankString(vWarning) Then
		Message(vWarning);
	EndIf;		
	If ValueIsFilled(vResult) And vResult <> "Error" Then
		#If ThickClientOrdinaryApplication Then
			ShowMessageBox(, NStr("en='Documents posting error! ';ru='Ошибка проводки документа! ';de='Fehler bei der Durchführung des Dokuments! '") + vResult);
		#Else
			Message(NStr("en='Documents posting error! ';ru='Ошибка проводки документа! ';de='Fehler bei der Durchführung des Dokuments! '") + vResult);
		#EndIf
	ElsIf Not ValueIsFilled(vResult) Then
		#If Not WebClient And Not MobileClient Then
			Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 90, NStr("en='Posting...';ru='Проводка документа...';de='Ausführen des Dokuments...'"), PictureLib.LongOperation); 
		#EndIf
		AfterWrite(New Structure());
		// Notify changes
		Notify("Subsystem.Accounts.Changed", Object.Ref, ThisForm);
		Notify("Document.Accommodation.Write", Object.Ref, ThisForm);
		If GuestsToCheckInList.Count()>0 Then
			Notify("CheckIn", Object.Ref, ThisForm);
		EndIf;
		Items.FormOpenBlockForm.Enabled = True;
		Items.FormCheckOut.Enabled = True;
		If ThisForm.IsNew Then
			ThisForm.IsNew = False;
		EndIf;
	Else
		Message(NStr("en='Documents posting error!';ru='Ошибка проводки документа!';de='Fehler bei der Durchführung des Dokuments!'"));
	EndIf;
EndProcedure

&НаСервере
Функция ПроверитьАктуальностьСотрудника(Сотрудник)
	
	СтруктураВозврата = Новый Структура;
	СтруктураВозврата.Вставить("Уволен", Ложь);
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	Clients.ДатаУвольнения КАК ДатаУвольнения
		|ИЗ
		|	Справочник.Clients КАК Clients
		|ГДЕ
		|	Clients.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Сотрудник);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	ВыборкаДетальныеЗаписи.Следующий();
	ДатаУвольнения = ВыборкаДетальныеЗаписи.ДатаУвольнения;
	Если ДатаУвольнения <= ТекущаяДата() и ДатаУвольнения <> дата(1,1,1) Тогда
		СтруктураВозврата.Уволен = Истина;
		СтруктураВозврата.Вставить("ДатаУвольнения", ВыборкаДетальныеЗаписи.ДатаУвольнения);
	КонецЕсли;
	
	Возврат СтруктураВозврата;
	
КонецФункции

&AtServer
&ChangeAndValidate("BuildThisFormCaption")
Procedure Расш1_BuildThisFormCaption(pGuest)
	vFormCaption = "";
	// Get guest full name and number of check-ins
	vGuestFullName = "";
	vGuestCountryCode = "";
	vGuestNumberOfCheckIns = 0;
	If ValueIsFilled(Object.Guest) Then
		vGuestFullName = TrimAll(Object.Guest.FullName);
		If ValueIsFilled(Object.Guest.Citizenship) Then
			vGuestCountryCode = " (" + TrimAll(Object.Guest.Citizenship.ISOCode) + ")";
		EndIf;
		vGuestNumberOfCheckIns = Object.Guest.GetObject().pmCountNumberOfCheckIns();
	Else
		vGuestFullName = TrimAll(pGuest);
	EndIf;
	If Not IsBlankString(vGuestFullName) Then
		#Вставка
		vFormCaption = NStr("en='Check-in ';ru='Поселение сотрудника ';de='Check-in '") + vGuestFullName;
		#КонецВставки
		#Удаление
		vFormCaption = NStr("en='Check-in ';ru='Размещ. ';de='Check-in '") + vGuestFullName;
		#КонецУдаления
	Else
		#Вставка
		vFormCaption = NStr("en='Check-in ';ru='Поселение сотрудника ';de='Check-in '") + TrimAll(Object.Number);
		#КонецВставки
		#Удаление
		vFormCaption = NStr("en='Check-in ';ru='Размещ. ';de='Check-in '") + TrimAll(Object.Number);
		#КонецУдаления
	EndIf;
	If Not IsBlankString(vGuestCountryCode) Then
		vFormCaption = vFormCaption + vGuestCountryCode;
	EndIf;
	If ValueIsFilled(Object.Room) Then
		vFormCaption = vFormCaption + ", " + TrimAll(Object.Room);
	EndIf;
	If ValueIsFilled(Object.RoomType) Then
		vFormCaption = vFormCaption + " " + TrimAll(Object.RoomType.Code);
	EndIf;
	If vGuestNumberOfCheckIns > 0 Then
		vFormCaption = vFormCaption + NStr("en=', check-ins: ';ru=', заездов: ';de=', check-ins: '") + vGuestNumberOfCheckIns;
	EndIf;
	#Вставка
	vFormCaption = vFormCaption + ?(IsBlankString(vGuestFullName), "", ", " + NStr("en='N'; ru='№'; de='N'") + TrimAll(Object.Number));
	#КонецВставки
	#Удаление
	vFormCaption = vFormCaption + ?(IsBlankString(vGuestFullName), "", ", " + NStr("en='N'; ru='№'; de='N'") + TrimAll(Object.Number)) + ", " + TrimAll(Object.Hotel);	
	vFormCaption = vFormCaption + ", " + Trimall(Object.Author);
	#КонецУдаления
	ThisForm.Title = vFormCaption;
	ThisForm.AutoTitle = False;
EndProcedure

&НаКлиенте
Процедура Расш1_SelGuest2ОбработкаВыбораПосле(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	Если ValueIsFilled(ВыбранноеЗначение) Тогда
		
		СтруктураПроверки = Новый Структура;
		СтруктураПроверки.Вставить("Гость", ВыбранноеЗначение);
		СтруктураПроверки.Вставить("ПолеОчистки", 2);
		ПроверитьАктуальностьГостя(СтруктураПроверки);
			
	КонецЕсли;  
	
	
КонецПроцедуры

&НаСервере
Функция ПроверитьАктуальностьГостя(СтруктураПроверки)

	СотрудникУволен = ложь;	//Шершнев
	
	СтруктураВозврата = Новый Структура;
	СтруктураВозврата.Вставить("Уволен", Ложь);
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	Clients.ДатаУвольнения КАК ДатаУвольнения
		|ИЗ
		|	Справочник.Clients КАК Clients
		|ГДЕ
		|	Clients.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", СтруктураПроверки.Гость);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	ВыборкаДетальныеЗаписи.Следующий();
	ДатаУвольнения = ВыборкаДетальныеЗаписи.ДатаУвольнения;
	Если ДатаУвольнения <= ТекущаяДата() и ДатаУвольнения <> дата(1,1,1) Тогда
		
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = СтрШаблон(NStr("en='Сотрудник уволен %1. Размещение сотрудника невозможно.';ru='Сотрудник уволен %1. Размещение сотрудника невозможно.';de='Сотрудник уволен %1. Размещение сотрудника невозможно.'"), 
									Формат(ДатаУвольнения,"ДФ=dd.MM.yyyy"));
		Сообщение.Сообщить();
				
		//+Шершнев 20220921
		СотрудникУволен = истина;
		//Если СтруктураПроверки.ПолеОчистки = 2 Тогда 
		//	ЭтотОбъект.Guest2 = Справочники.Clients.ПустаяСсылка();
		//ИначеЕСли СтруктураПроверки.ПолеОчистки = 3	Тогда 
		//	ЭтотОбъект.Guest3 = Справочники.Clients.ПустаяСсылка();
		//ИначеЕСли СтруктураПроверки.ПолеОчистки = 4	Тогда 	
		//	ЭтотОбъект.Guest4 = Справочники.Clients.ПустаяСсылка();			
		//ИначеЕСли СтруктураПроверки.ПолеОчистки = 5	Тогда 	
		//	ЭтотОбъект.Guest5 = Справочники.Clients.ПустаяСсылка();			
		//КонецЕсли;					
		//-Шершнев 20220921
	КонецЕсли;      
		
	Возврат СотрудникУволен;
	
КонецФункции

&AtClient
&ChangeAndValidate("CheckOut")
Procedure Расш1_CheckOut(pCommand)
	If (WasPosted = False Or ThisForm.Modified) Then
		// Check attributes
		If Not CheckAttributes() Then
			Return;
		EndIf;
		// Check user PIN if necessary
		If Not EmployeePINCodeChecked And tcOnServer.NeedToCheckEmployeePINCode() Then
			OpenForm("CommonForm.tcEmployeePINCheck", New Structure("ModeAfterCheck", "CheckOut"), ThisForm, , , , , FormWindowOpeningMode.LockOwnerWindow);
			Return;
		EndIf;
		EmployeePINCodeChecked = False;
		// Save document first
		vWarning = "";
		vResult = WriteAtServer(, vWarning);
		If Not IsBlankString(vWarning) Then
			Message(vWarning);
		EndIf;		
		If ValueIsFilled(vResult) Then
			If vResult <> "Error" Then
				ShowMessageBox(, vResult);
			EndIf;
			Return;
		EndIf;         
	EndIf;
	// Check document form mode
	If OneGuestMode Then
		OpenForm("CommonForm.tcChangeRoomWizard", New Structure("DocRef, OperationType", Object.Ref, 2), ThisForm);
		Return;
	EndIf;
	// Build list of documents to be checked out
	AccList = New ValueList;
	AccList.Add(Object.Ref);
	If Not OneGuestMode Then
		For Each vRow In GuestsInGroup Do
			If ValueIsFilled(vRow.Ref) Then
				AccList.Add(vRow.Ref);
			Endif;
		EndDo;
	EndIf;
	// *** CURRENT DOCUMENT ***
	// Check if document is posted
	If IsNew Then
		ShowMessageBox(, NStr("ru='Процедура выселения не возможна для не проведенного размещения!';
		                      |de='Das Ausweisungsverfahren ist für nicht durchgeführte Unterbringungen nicht möglich!'; 
		                      |en='Check out procedure is not possible for the accommodation that is not posted!'"));
		Return;
	EndIf;
	// Check document form state. If document is open for read only then do 
	// message and cancel action
	If ThisForm.ReadOnly Then
		ShowMessageBox(, NStr("en='Action choosen is not permitted from the document opened for read only!';
		                      |ru='Действие не разрешено из документа открытого на просмотр!';
		                      |de='Die Aktion ist aus dem zur Ansicht geöffneten Dokument nicht erlaubt!'"));
		Return;
	EndIf;
	// Give warning if current date is less then expected check-out date 
	#Удаление
	If BegOfDay(Object.CheckOutDate) > BegOfDay(CurrentDate()) Then
		Message(NStr("en='Expected check-out date " + Format(Object.CheckOutDate, "DF=dd.MM.yyyy") + " is in the future!'; 
		             |de='Expected check-out date " + Format(Object.CheckOutDate, "DF=dd.MM.yyyy") + " is in the future!'; 
		             |ru='Дата планируемого выезда " + Format(Object.CheckOutDate, "DF=dd.MM.yyyy") + " в будущем!'"), MessageStatus.Important);
	EndIf;
	// Get check-out date
	CheckOutDateTime = '00010101';
	If Not tcOnServer.cmCheckUserPermissionsAtServer("HavePermissionToCheckOutOnExpectedCheckOutTime") Then
	#КонецУдаления	
		GetCheckOutDate(Object.CheckInDate, Object.CheckOutDate);
	#Удаление	
	Else
		CheckOutDateTime = Object.CheckOutDate;
	EndIf; 
	#КонецУдаления
	AttachIdleHandler("CheckIfCheckOutDateTimeIsFilled", 1, False);
EndProcedure //CheckOut

&AtClient
&ChangeAndValidate("GetCheckOutDateAfterUserInput")
Procedure Расш1_GetCheckOutDateAfterUserInput(pCheckOutDateTime, pExtraParameters) Export  
	#Вставка
	pCheckOutDateTime = ТекущаяДата();
	#КонецВставки
	CheckOutDateTime = '00010101';
	// Check check out date and time entered
	If Not ValueIsFilled(pCheckOutDateTime) Then
		ShowMessageBox(, NStr("ru='Процедура выселения отменена!';
		                      |de='Das Ausweisungsverfahren wurde abgebrochen'; 
						      |en='Check-out procedure is canceled!'"));
		Return;
	EndIf; 
	#Удаление
	If pCheckOutDateTime < pExtraParameters.CheckInDate Then
		ShowMessageBox(, NStr("ru='Вы ввели дату и время выселения, которые раньше чем дата и время заезда!';
		                  |de='Sie haben ein Abreisedatum und eine Abreisezeit eingegeben, die vor dem Anreisedatum und der Anreisezeit liegen!'; 
						  |en='You have entered check-out date and time that are earlier then check-in date and time!'"));
		Return;
	EndIf;
	#КонецУдаления	
	If Not tcOnServer.cmCheckUserPermissionsAtServer("HavePermissionToSetCheckOutDateInThePast") Then
		vAllowedCheckOutDelayTime = 1;
		If ValueIsFilled(tcOnServer.cmGetCurrentUserAttribute()) Then
			vPermissionGroup = tcOnServer.cmGetEmployeePermissionGroupAtServer(tcOnServer.cmGetCurrentUserAttribute());
			If ValueIsFilled(vPermissionGroup) Then
				If tcOnServer.cmGetAttributeByRef(vPermissionGroup, "AllowedCheckOutDelayTime") > 0 Then
					vAllowedCheckOutDelayTime = tcOnServer.cmGetAttributeByRef(vPermissionGroup, "AllowedCheckOutDelayTime");
				EndIf;
			EndIf;
		EndIf;
		vTimeDiff = Round((CurrentDate() - pCheckOutDateTime)/3600, 3);
		If vTimeDiff > vAllowedCheckOutDelayTime Then
			ShowMessageBox(, NStr("ru='Вы ввели дату выселения в прошлом. У вас есть права на выселение только текущей или будущей датой!';
			                      |de='Sie haben ein abreise Datum und Zeit angegeben, das in der Vergangenheit liegt. Sie sind berechtigt, eine Räumung nur am aktuellen oder künftigen Datum vorzunehmen!'; 
			                      |en='You have entered check-out date in the past. You have rights to do check-out by current or future dates only!'"));
			Return;
		EndIf;
	EndIf;
	CheckOutDateTime = pCheckOutDateTime;
EndProcedure //GetCheckOutDateAfterUserInpu