
&AtServer
&ChangeAndValidate("SetParametersDynamicList")
Procedure Расш1_SetParametersDynamicList()
	vBalancesAreVisible = Not cmCheckUserPermissions("DoNotShowBalancesInLists");

	// Set columns appearance
	Items.DocumentListAllSumBalance.Visible = vBalancesAreVisible;
	Items.DocumentListAllSumBalanceCustomer.Visible = vBalancesAreVisible;
	Items.DocumentListIsInHouseSumBalance.Visible = vBalancesAreVisible;
	Items.DocumentListIsInHouseSumBalanceCustomer.Visible = vBalancesAreVisible;
	Items.DocumentListReservationClientSumBalance.Visible = vBalancesAreVisible;
	Items.DocumentListReservationCustomerSumBalance.Visible = vBalancesAreVisible;

	// Set parameters
	DocumentListALL.Parameters.SetParameterValue("qHotel",SelHotel);
	DocumentListALL.Parameters.SetParameterValue("qShowAllGuests", SelShowAllGuests);
	DocumentListALL.Parameters.SetParameterValue("qBalancesAreVisible", vBalancesAreVisible);

	DocumentListIsInHouse.Parameters.SetParameterValue("qHotel",SelHotel);
	DocumentListIsInHouse.Parameters.SetParameterValue("qShowAllGuests", SelShowAllGuests);
	DocumentListIsInHouse.Parameters.SetParameterValue("qBalancesAreVisible", vBalancesAreVisible);
	DocumentListIsInHouse.Parameters.SetParameterValue("qAccountingDate", BegOfDay(CurrentSessionDate()));
	DocumentListIsInHouse.Parameters.SetParameterValue("qShowExpectedRoomMovesOnly", ShowExpectedRoomMovesOnly);

	DocumentListReservation.Parameters.SetParameterValue("qHotel",SelHotel);
	DocumentListReservation.Parameters.SetParameterValue("qShowAllGuests", SelShowAllGuests);
	DocumentListReservation.Parameters.SetParameterValue("qBalancesAreVisible", vBalancesAreVisible);
	#Вставка
	ThisForm.Title = NStr("en='Front office console: '; ru='Проживающие сотрудники'; de='Front-Office-Konsole: '");
	//ThisForm.Title = NStr("en='Front office console: '; ru=''; de='Front-Office-Konsole: '") + ?(ValueIsFilled(ThisForm.SelHotel), ThisForm.SelHotel.GetObject().pmGetHotelPrintName(SessionParameters.CurrentLanguage), "");
	DocumentListIsInHouse.Parameters.SetParameterValue("ТекущаяДата", ТекущаяДата());
	#КонецВставки
	#Удаление
	ThisForm.Title = NStr("en='Front office console: '; ru='Фронт-офис: '; de='Front-Office-Konsole: '") + ?(ValueIsFilled(ThisForm.SelHotel), ThisForm.SelHotel.GetObject().pmGetHotelPrintName(SessionParameters.CurrentLanguage), "");
	#КонецУдаления
EndProcedure

&AtClient
&ChangeAndValidate("CheckOut")
Procedure Расш1_CheckOut(pCommand)
	vPage = "";
	If SelFilterStatus = 0 Or SelFilterStatus = 3 Then
		vPage = "DocumentListIsInHouse";
	ElsIf SelFilterStatus = 1 Then
		vPage = "DocumentListAll";
	Else
		Return;
	EndIf;
	vSelDocRef = Items[vPage].CurrentRow;
	If vSelDocRef <> Undefined Then
		If SelShowAllGuests = 0 Then
			MainRoomDoc = GetMainDocRef(vSelDocRef);
		Else
			OpenForm("CommonForm.tcChangeRoomWizard", New Structure("DocRef, OperationType", vSelDocRef, 2), ThisForm);
			Return;
		EndIf;
		// Give warning if current date is less then expected check-out date
		vCheckInDate = tcOnServer.cmGetAttributeByRef(MainRoomDoc, "CheckInDate");
		vExpectedCheckOutDate = tcOnServer.cmGetAttributeByRef(MainRoomDoc, "CheckOutDate");
		#Удаление
		If BegOfDay(vExpectedCheckOutDate) > BegOfDay(CurrentDate()) Then
			Message(NStr("en='Expected check-out date " + Format(vExpectedCheckOutDate, "DF=dd.MM.yyyy") + " is in the future!'; 
				         |de='Expected check-out date " + Format(vExpectedCheckOutDate, "DF=dd.MM.yyyy") + " is in the future!'; 
				         |ru='Дата планируемого выезда " + Format(vExpectedCheckOutDate, "DF=dd.MM.yyyy") + " в будущем!'"), MessageStatus.Important);
		EndIf;
		#КонецУдаления		
		// Get check-out date
		CheckOutDateTime = '00010101';
		If Not tcOnServer.cmCheckUserPermissionsAtServer("HavePermissionToCheckOutOnExpectedCheckOutTime") Then
			GetCheckOutDate(vCheckInDate, vExpectedCheckOutDate);
			AttachIdleHandler("CheckIfCheckOutDateTimeIsFilled", 1, False);
		Else
			CheckOutDateTime = vExpectedCheckOutDate;
			AttachIdleHandler("CheckIfCheckOutDateTimeIsFilled", 0.1, True);
		EndIf;
	EndIf;
EndProcedure //CheckOu