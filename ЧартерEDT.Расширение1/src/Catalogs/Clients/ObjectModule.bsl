
&ChangeAndValidate("pmCountNumberOfCheckIns")
Function Расш1_pmCountNumberOfCheckIns(pPeriodFrom, pPeriodTo, pUseResourcesPayedAsIndividual, pUseResourcesPayedByRackRates)
	vNumberOfCheckIns = 0;
	// Run query
	
	#Вставка
	vQry = New Query();
	vQry.Text = 
	"SELECT Разрешенные
	|	SUM(ISNULL(SalesTurnovers.GuestsCheckedInTurnover, 0)) AS GuestsCheckedIn
	|FROM
	|	AccumulationRegister.Sales.Turnovers(
	|			&qPeriodFrom,
	|			&qPeriodTo,
	|			Period,
	|			Client = &qClient
	|				AND (NOT &qUseResourcesPayedAsIndividual
	|					OR &qUseResourcesPayedAsIndividual
	|						AND (Customer = &qEmptyCustomer
	|							OR Customer <> &qEmptyCustomer AND Customer.IsIndividual))
	|				AND (NOT &qUseResourcesPayedByRackRates
	|					OR &qUseResourcesPayedByRackRates
	|						AND ISNULL(RoomRate.IsRackRate, FALSE))) AS SalesTurnovers";
	#КонецВставки
	
	#Удаление
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	SUM(ISNULL(SalesTurnovers.GuestsCheckedInTurnover, 0)) AS GuestsCheckedIn
	|FROM
	|	AccumulationRegister.Sales.Turnovers(
	|			&qPeriodFrom,
	|			&qPeriodTo,
	|			Period,
	|			Client = &qClient
	|				AND (NOT &qUseResourcesPayedAsIndividual
	|					OR &qUseResourcesPayedAsIndividual
	|						AND (Customer = &qEmptyCustomer
	|							OR Customer <> &qEmptyCustomer AND Customer.IsIndividual))
	|				AND (NOT &qUseResourcesPayedByRackRates
	|					OR &qUseResourcesPayedByRackRates
	|						AND ISNULL(RoomRate.IsRackRate, FALSE))) AS SalesTurnovers";
	#КонецУдаления
	vQry.SetParameter("qClient", Ref);
	vQry.SetParameter("qPeriodFrom", pPeriodFrom);
	vQry.SetParameter("qPeriodTo", pPeriodTo);
	vQry.SetParameter("qUseResourcesPayedAsIndividual", pUseResourcesPayedAsIndividual);
	vQry.SetParameter("qUseResourcesPayedByRackRates", pUseResourcesPayedByRackRates);
	vQry.SetParameter("qEmptyCustomer", Catalogs.Customers.EmptyRef());
	vQryRes = vQry.Execute().Select();
	While vQryRes.Next() Do
		If vQryRes.GuestsCheckedIn <> NULL Then
			vNumberOfCheckIns = vQryRes.GuestsCheckedIn;
		EndIf;
		Break;
	EndDo;
	Return vNumberOfCheckIns;
EndFunction

&ChangeAndValidate("FillCheckProcessing")
Procedure Расш1_FillCheckProcessing(Cancel, CheckedAttributes)
	If AdditionalProperties.Property("CheckedAttributes") Then
		For Each vId In AdditionalProperties.CheckedAttributes Do
			CheckedAttributes.Add(vId);       
		EndDo;	
	EndIf;
	#Вставка
		CheckedAttributes.Add("Citizenship");
		CheckedAttributes.Add("DateOfBirth");
		CheckedAttributes.Add("Sex");
		CheckedAttributes.Add("LastName");
		CheckedAttributes.Add("FirstName");
		CheckedAttributes.Add("SecondName");
		
		Если КатегорияПроживающего = Перечисления.Расш1_КатегорииПроживающих.ЧленСемьи Тогда 
			CheckedAttributes.Add("Relationship");
		КонецЕсли;
	#КонецВставки
EndProcedure

&ChangeAndValidate("pmCountNumberOfNights")
Function Расш1_pmCountNumberOfNights(pPeriodFrom, pPeriodTo, pUseResourcesPayedAsIndividual, pUseResourcesPayedByRackRates)
	vNumberOfNights = 0;
	// Run query
	vQry = New Query();
	vQry.Text =
	#Вставка
	"SELECT разрешенные
	|	SUM(ISNULL(SalesTurnovers.GuestDaysTurnover, 0)) AS GuestDaysTurnover
	|FROM
	|	AccumulationRegister.Sales.Turnovers(
	|			&qPeriodFrom,
	|			&qPeriodTo,
	|			Period,
	|			Client = &qClient
	|				AND (NOT &qUseResourcesPayedAsIndividual
	|					OR &qUseResourcesPayedAsIndividual
	|						AND (Customer = &qEmptyCustomer
	|							OR Customer <> &qEmptyCustomer AND Customer.IsIndividual))
	|				AND (NOT &qUseResourcesPayedByRackRates
	|					OR &qUseResourcesPayedByRackRates
	|						AND ISNULL(RoomRate.IsRackRate, FALSE))) AS SalesTurnovers";
	#КонецВставки
	#Удаление
	"SELECT
	|	SUM(ISNULL(SalesTurnovers.GuestDaysTurnover, 0)) AS GuestDaysTurnover
	|FROM
	|	AccumulationRegister.Sales.Turnovers(
	|			&qPeriodFrom,
	|			&qPeriodTo,
	|			Period,
	|			Client = &qClient
	|				AND (NOT &qUseResourcesPayedAsIndividual
	|					OR &qUseResourcesPayedAsIndividual
	|						AND (Customer = &qEmptyCustomer
	|							OR Customer <> &qEmptyCustomer AND Customer.IsIndividual))
	|				AND (NOT &qUseResourcesPayedByRackRates
	|					OR &qUseResourcesPayedByRackRates
	|						AND ISNULL(RoomRate.IsRackRate, FALSE))) AS SalesTurnovers";
	#КонецУдаления
	vQry.SetParameter("qClient", Ref);
	vQry.SetParameter("qPeriodFrom", pPeriodFrom);
	vQry.SetParameter("qPeriodTo", pPeriodTo);
	vQry.SetParameter("qUseResourcesPayedAsIndividual", pUseResourcesPayedAsIndividual);
	vQry.SetParameter("qUseResourcesPayedByRackRates", pUseResourcesPayedByRackRates);
	vQry.SetParameter("qEmptyCustomer", Catalogs.Customers.EmptyRef());
	vQryRes = vQry.Execute().Select();
	While vQryRes.Next() Do
		If vQryRes.GuestDaysTurnover <> NULL Then
			vNumberOfNights = vQryRes.GuestDaysTurnover;
		EndIf;
		Break;
	EndDo;
	Return vNumberOfNights;
EndFunction

&ChangeAndValidate("pmGetClientLastAccommodation")
Function Расш1_pmGetClientLastAccommodation()
	vLastAcc = Undefined;
	// Run query
	vQry = New Query();
	vQry.Text =
	#Вставка
	"SELECT разрешенные TOP 1
	|	Accommodation.Ref
	|FROM
	|	Document.Accommodation AS Accommodation
	|WHERE
	|	Accommodation.Posted
	|	AND Accommodation.Guest = &qGuest
	|	AND Accommodation.AccommodationStatus.IsCheckOut
	|	AND Accommodation.AccommodationStatus.IsActive
	|ORDER BY
	|	Accommodation.PointInTime DESC";
	#КонецВставки
	#Удаление
	"SELECT TOP 1
	|	Accommodation.Ref
	|FROM
	|	Document.Accommodation AS Accommodation
	|WHERE
	|	Accommodation.Posted
	|	AND Accommodation.Guest = &qGuest
	|	AND Accommodation.AccommodationStatus.IsCheckOut
	|	AND Accommodation.AccommodationStatus.IsActive
	|ORDER BY
	|	Accommodation.PointInTime DESC";
	#КонецУдаления
	vQry.SetParameter("qGuest", Ref);
	vQryRes = vQry.Execute().Select();
	While vQryRes.Next() Do
		vLastAcc = vQryRes.Ref;
		Break;
	EndDo;
	Return vLastAcc;
EndFunction

&ChangeAndValidate("pmGetClientFirstAccommodation")
Function Расш1_pmGetClientFirstAccommodation()
	vFirstAcc = Undefined;
	// Run query
	vQry = New Query();
	vQry.Text =
	#Вставка
	"SELECT разрешенные TOP 1
	|	Accommodation.Ref
	|FROM
	|	Document.Accommodation AS Accommodation
	|WHERE
	|	Accommodation.Posted
	|	AND Accommodation.Guest = &qGuest
	|	AND Accommodation.AccommodationStatus.IsCheckIn
	|	AND Accommodation.AccommodationStatus.IsActive
	|ORDER BY
	|	Accommodation.PointInTime";
	#КонецВставки
	#Удаление
	"SELECT TOP 1
	|	Accommodation.Ref
	|FROM
	|	Document.Accommodation AS Accommodation
	|WHERE
	|	Accommodation.Posted
	|	AND Accommodation.Guest = &qGuest
	|	AND Accommodation.AccommodationStatus.IsCheckIn
	|	AND Accommodation.AccommodationStatus.IsActive
	|ORDER BY
	|	Accommodation.PointInTime";
	#КонецУдаления
	vQry.SetParameter("qGuest", Ref);
	vQryRes = vQry.Execute().Select();
	While vQryRes.Next() Do
		vFirstAcc = vQryRes.Ref;
		Break;
	EndDo;
	Return vFirstAcc;
EndFunction
