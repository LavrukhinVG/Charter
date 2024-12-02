
&AtServer
&ChangeAndValidate("BuildList")
Procedure Расш1_BuildList()
	RoomTypesList.Clear();
	Items.RoomTypesListSumPresentation.Visible = False;
	Items.RoomTypesListAvgPricePresentation.Visible = False;
	For i = 1 To 9 Do
		Items["RoomTypesListSumPresentation" + i].Visible = False;
		Items["RoomTypesListAvgPricePresentation" + i].Visible = False;
	EndDo;
	
	// Check periods
	If CheckInDate >= CheckOutDate Then
		CheckOutDate = CheckInDate + 86400;	
		Duration = 1;
	EndIf;
	
	// Build array of kid ages
	vAgeValueTable = New ValueTable();
	vAgeValueTable.Columns.Add("Age", cmGetNumberTypeDescription(3, 0));
	vAgeValueTable.Columns.Add("IsUsed", cmGetBooleanTypeDescription());
	vAgeArray = New Array;
	For vInd = 1 To NumberOfKids Do
		Try
			vAge = ThisForm["KidAge"+String(vInd)];
			
			vAgeRow = vAgeValueTable.Add();
			vAgeRow.Age = vAge;
			vAgeRow.IsUsed = False;
			
			vAgeArray.Add(vAge);
		Except
		EndTry;
	EndDo;
	
	// Build structure with children ages
	vChildrenAgesStruct = Undefined;
	If ValueIsFilled(RoomQuota) And ValueIsFilled(RoomQuota.Contract) Then
		vAllotmentContract = RoomQuota.Contract;
		If vAllotmentContract.TeenagersMaxAge <> 0 Or vAllotmentContract.ChildrenMaxAge <> 0 Or vAllotmentContract.InfantsMaxAge <> 0 Then
			vChildrenAgesStruct = vAllotmentContract;
		EndIf;
	EndIf;
	
	// Get available room types
	vGuestsQuantity = NumberOfAdults + NumberOfKids;
	vRoomTypes = cmGetRoomTypesByGuestQuantity(vGuestsQuantity, Catalogs.RoomTypes.EmptyRef(), Hotel);
	
	// Build and run query with room inventory balances
	#Вставка
	Если НомернойФонд.Пустая() Тогда
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	ExpectedGuestGroupsTurnovers.Hotel AS Hotel,
		|	ExpectedGuestGroupsTurnovers.RoomType AS RoomType,
		|	MAX(ISNULL(ExpectedGuestGroupsTurnovers.RoomsReservedTurnover, 0)) AS PreliminaryRooms,
		|	MAX(ISNULL(ExpectedGuestGroupsTurnovers.BedsReservedTurnover, 0)) AS PreliminaryBeds
		|INTO PreliminaryTotals
		|FROM
		|	AccumulationRegister.ExpectedGuestGroups.Turnovers(
		|			&qTentativeDateTimeFrom,
		|			&qTentativeDateTimeTo,
		|			DAY,
		|			(Hotel = &qHotel
		|				OR &qHotelIsEmpty)
		|				AND (&qRoomQuotaIsSet
		|						AND RoomQuota = &qRoomQuota
		|					OR NOT &qRoomQuotaIsSet)) AS ExpectedGuestGroupsTurnovers
		|
		|GROUP BY
		|	ExpectedGuestGroupsTurnovers.Hotel,
		|	ExpectedGuestGroupsTurnovers.RoomType
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT разрешенные
		|	BEGINOFPERIOD(RoomInventoryBalance.Period, DAY) AS Period,
		|	RoomInventoryBalance.Hotel AS Hotel,
		|	RoomInventoryBalance.RoomType AS RoomType,
		|	RoomInventoryBalance.CounterClosingBalance AS CounterClosingBalance,
		|	CASE
		|		WHEN &qRoomQuotaIsSet
		|				AND &qDoWriteOff
		|			THEN ISNULL(RoomQuotaBalances.RoomsRemains, 0)
		|		WHEN &qRoomQuotaIsSet
		|				AND NOT &qDoWriteOff
		|				AND ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0) < ISNULL(RoomQuotaBalances.RoomsRemains, 0)
		|			THEN ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0)
		|		WHEN &qRoomQuotaIsSet
		|				AND NOT &qDoWriteOff
		|				AND ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0) >= ISNULL(RoomQuotaBalances.RoomsRemains, 0)
		|			THEN ISNULL(RoomQuotaBalances.RoomsRemains, 0)
		|		ELSE ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0)
		|	END AS RoomsVacant,
		|	CASE
		|		WHEN &qRoomQuotaIsSet
		|				AND &qDoWriteOff
		|			THEN ISNULL(RoomQuotaBalances.BedsRemains, 0)
		|		WHEN &qRoomQuotaIsSet
		|				AND NOT &qDoWriteOff
		|				AND ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0) < ISNULL(RoomQuotaBalances.BedsRemains, 0)
		|			THEN ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0)
		|		WHEN &qRoomQuotaIsSet
		|				AND NOT &qDoWriteOff
		|				AND ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0) >= ISNULL(RoomQuotaBalances.BedsRemains, 0)
		|			THEN ISNULL(RoomQuotaBalances.BedsRemains, 0)
		|		ELSE ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0)
		|	END AS BedsVacant,
		|	RoomInventoryBalance.Hotel.SortCode AS HotelSortCode,
		|	RoomInventoryBalance.RoomType.SortCode AS RoomTypeSortCode
		|INTO RoomInventoryBalanceByDays
		|FROM
		|	AccumulationRegister.RoomInventory.BalanceAndTurnovers(
		|			&qDateTimeFrom,
		|			&qDateTimeTo,
		|			Minute,
		|			RegisterRecordsAndPeriodBoundaries,
		|			&qHotelIsEmpty
		|				OR Hotel IN HIERARCHY (&qHotel)) AS RoomInventoryBalance
		|		LEFT JOIN (SELECT
		|			BEGINOFPERIOD(RoomQuotaSalesBalanceAndTurnovers.Period, DAY) AS Period,
		|			RoomQuotaSalesBalanceAndTurnovers.Hotel AS Hotel,
		|			RoomQuotaSalesBalanceAndTurnovers.RoomType AS RoomType,
		|			RoomQuotaSalesBalanceAndTurnovers.CounterClosingBalance AS CounterClosingBalance,
		|			RoomQuotaSalesBalanceAndTurnovers.RoomsInQuotaClosingBalance AS RoomsInQuota,
		|			RoomQuotaSalesBalanceAndTurnovers.BedsInQuotaClosingBalance AS BedsInQuota,
		|			RoomQuotaSalesBalanceAndTurnovers.RoomsRemainsClosingBalance AS RoomsRemains,
		|			RoomQuotaSalesBalanceAndTurnovers.BedsRemainsClosingBalance AS BedsRemains
		|		FROM
		|			AccumulationRegister.RoomQuotaSales.BalanceAndTurnovers(
		|					&qDateTimeFrom,
		|					&qDateTimeTo,
		|					Day,
		|					RegisterRecordsAndPeriodBoundaries,
		|					(&qHotelIsEmpty
		|						OR Hotel = &qHotel)
		|						AND &qRoomQuotaIsSet
		|						AND RoomQuota = &qRoomQuota) AS RoomQuotaSalesBalanceAndTurnovers) AS RoomQuotaBalances
		|		ON RoomInventoryBalance.Hotel = RoomQuotaBalances.Hotel
		|			AND RoomInventoryBalance.RoomType = RoomQuotaBalances.RoomType
		|			AND (BEGINOFPERIOD(RoomInventoryBalance.Period, DAY) = BEGINOFPERIOD(RoomQuotaBalances.Period, DAY))
		|WHERE
		|	RoomInventoryBalance.RoomType IN(&qRoomTypesList)
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT
		|	RoomInventoryBalanceByDays.Hotel AS Hotel,
		|	RoomInventoryBalanceByDays.RoomType AS RoomType,
		|	MIN(RoomInventoryBalanceByDays.RoomsVacant) AS RoomsAvailable,
		|	MIN(RoomInventoryBalanceByDays.BedsVacant) AS BedsAvailable
		|INTO RoomInventoryBalance
		|FROM
		|	RoomInventoryBalanceByDays AS RoomInventoryBalanceByDays
		|
		|GROUP BY
		|	RoomInventoryBalanceByDays.Hotel,
		|	RoomInventoryBalanceByDays.RoomType
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT
		|	RoomInventoryBalance.Hotel AS Hotel,
		|	RoomInventoryBalance.RoomType AS RoomType,
		|	RoomInventoryBalance.RoomsAvailable AS RoomsAvailable,
		|	RoomInventoryBalance.BedsAvailable AS BedsAvailable,
		|	RoomInventoryBalance.RoomsAvailable - ISNULL(PreliminaryTotals.PreliminaryRooms, 0) AS RoomsAvailableWithTentative,
		|	RoomInventoryBalance.BedsAvailable - ISNULL(PreliminaryTotals.PreliminaryBeds, 0) AS BedsAvailableWithTentative
		|INTO RoomInventoryBalanceWithTentative
		|FROM
		|	RoomInventoryBalance AS RoomInventoryBalance
		|		LEFT JOIN PreliminaryTotals AS PreliminaryTotals
		|		ON RoomInventoryBalance.Hotel = PreliminaryTotals.Hotel
		|			AND RoomInventoryBalance.RoomType = PreliminaryTotals.RoomType
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT
		|	RoomInventory.RoomType AS RoomType,
		|	RoomInventory.RoomType AS Ref,
		|	RoomInventory.RoomsAvailable AS RoomsAvailable,
		|	RoomInventory.BedsAvailable AS BedsAvailable,
		|	RoomInventory.RoomsAvailableWithTentative AS RoomsAvailableWithTentative,
		|	RoomInventory.BedsAvailableWithTentative AS BedsAvailableWithTentative,
		|	&qEmptyCurrency AS Currency,
		|	&qEmptyNumber AS Sum,
		|	&qEmptyString AS SumPresentation,
		|	&qEmptyNumber AS AvgPrice,
		|	&qEmptyString AS AvgPricePresentation,
		|	&qRoomRate AS RoomRate,
		|	&qEmptyCurrency AS Currency1,
		|	&qEmptyNumber AS Sum1,
		|	&qEmptyString AS SumPresentation1,
		|	&qEmptyNumber AS AvgPrice1,
		|	&qEmptyString AS AvgPricePresentation1,
		|	&qEmptyRoomRate AS RoomRate1,
		|	&qEmptyCurrency AS Currency2,
		|	&qEmptyNumber AS Sum2,
		|	&qEmptyString AS SumPresentation2,
		|	&qEmptyNumber AS AvgPrice2,
		|	&qEmptyString AS AvgPricePresentation2,
		|	&qEmptyRoomRate AS RoomRate2,
		|	&qEmptyCurrency AS Currency3,
		|	&qEmptyNumber AS Sum3,
		|	&qEmptyString AS SumPresentation3,
		|	&qEmptyNumber AS AvgPrice3,
		|	&qEmptyString AS AvgPricePresentation3,
		|	&qEmptyRoomRate AS RoomRate3,
		|	&qEmptyCurrency AS Currency4,
		|	&qEmptyNumber AS Sum4,
		|	&qEmptyString AS SumPresentation4,
		|	&qEmptyNumber AS AvgPrice4,
		|	&qEmptyString AS AvgPricePresentation4,
		|	&qEmptyRoomRate AS RoomRate4,
		|	&qEmptyCurrency AS Currency5,
		|	&qEmptyNumber AS Sum5,
		|	&qEmptyString AS SumPresentation5,
		|	&qEmptyNumber AS AvgPrice5,
		|	&qEmptyString AS AvgPricePresentation5,
		|	&qEmptyRoomRate AS RoomRate5,
		|	&qEmptyCurrency AS Currency6,
		|	&qEmptyNumber AS Sum6,
		|	&qEmptyString AS SumPresentation6,
		|	&qEmptyNumber AS AvgPrice6,
		|	&qEmptyString AS AvgPricePresentation6,
		|	&qEmptyRoomRate AS RoomRate6,
		|	&qEmptyCurrency AS Currency7,
		|	&qEmptyNumber AS Sum7,
		|	&qEmptyString AS SumPresentation7,
		|	&qEmptyNumber AS AvgPrice7,
		|	&qEmptyString AS AvgPricePresentation7,
		|	&qEmptyRoomRate AS RoomRate7,
		|	&qEmptyCurrency AS Currency8,
		|	&qEmptyNumber AS Sum8,
		|	&qEmptyString AS SumPresentation8,
		|	&qEmptyNumber AS AvgPrice8,
		|	&qEmptyString AS AvgPricePresentation8,
		|	&qEmptyRoomRate AS RoomRate8,
		|	&qEmptyCurrency AS Currency9,
		|	&qEmptyNumber AS Sum9,
		|	&qEmptyString AS SumPresentation9,
		|	&qEmptyNumber AS AvgPrice9,
		|	&qEmptyString AS AvgPricePresentation9,
		|	&qEmptyRoomRate AS RoomRate9,
		|	RoomInventory.RoomType.IsVirtual AS IsVirtual,
		|	&qEmptyString AS RoomsAvailableWithTentativePresentation,
		|	&qEmptyString AS BedsAvailableWithTentativePresentation,
		|	CASE
		|		WHEN StopSales.StopSale IS NULL
		|			THEN FALSE
		|		ELSE TRUE
		|	END AS StopSale
		|FROM
		|	(SELECT
		|		RoomInventoryBalanceWithTentative.Hotel AS Hotel,
		|		RoomInventoryBalanceWithTentative.RoomType AS RoomType,
		|		RoomInventoryBalanceWithTentative.RoomsAvailable AS RoomsAvailable,
		|		RoomInventoryBalanceWithTentative.BedsAvailable AS BedsAvailable,
		|		RoomInventoryBalanceWithTentative.RoomsAvailableWithTentative AS RoomsAvailableWithTentative,
		|		RoomInventoryBalanceWithTentative.BedsAvailableWithTentative AS BedsAvailableWithTentative
		|	FROM
		|		RoomInventoryBalanceWithTentative AS RoomInventoryBalanceWithTentative
		|	
		|	UNION ALL
		|	
		|	SELECT
		|		VirtualRoomTypes.Owner,
		|		VirtualRoomTypes.Ref,
		|		0,
		|		0,
		|		0,
		|		0
		|	FROM
		|		Catalog.RoomTypes AS VirtualRoomTypes
		|	WHERE
		|		VirtualRoomTypes.IsVirtual
		|		AND NOT VirtualRoomTypes.IsFolder
		|		AND (&qHotelIsEmpty
		|				OR VirtualRoomTypes.Owner IN HIERARCHY (&qHotel))) AS RoomInventory
		|		LEFT JOIN (SELECT
		|			RoomTypesStopSalePeriods.Ref AS StopSale
		|		FROM
		|			Catalog.RoomTypes.StopSalePeriods AS RoomTypesStopSalePeriods
		|		WHERE
		|			RoomTypesStopSalePeriods.StopSale
		|			AND RoomTypesStopSalePeriods.PeriodFrom < &qDateTimeTo
		|			AND RoomTypesStopSalePeriods.PeriodTo > &qDateTimeFrom
		|			AND NOT RoomTypesStopSalePeriods.Ref.DeletionMark
		|			AND NOT RoomTypesStopSalePeriods.Ref.IsFolder
		|		
		|		GROUP BY
		|			RoomTypesStopSalePeriods.Ref) AS StopSales
		|		ON RoomInventory.RoomType = StopSales.StopSale
		|WHERE
		|	NOT RoomInventory.RoomType.DeletionMark
		|	AND (NOT &qWindowViewIsFilled
		|			OR &qWindowViewIsFilled
		|				AND RoomInventory.RoomType.WindowView = &qWindowView)
		|	AND CASE
		|			WHEN &qCUCustomer <> VALUE(Catalog.Customers.EmptyRef)
		|				THEN RoomInventory.RoomsAvailable <> 0
		|						AND RoomInventory.BedsAvailable <> 0
		|			ELSE TRUE
		|		END
		|
		|ORDER BY
		|	RoomInventory.RoomType.SortCode";
	Иначе		
		МенеджерВТ = Новый МенеджерВременныхТаблиц;
		
		Запрос = Новый Запрос;
		Запрос.МенеджерВременныхТаблиц = МенеджерВТ;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	Расш1_СоставНомерногоФонда.Номер КАК Номер
		|ПОМЕСТИТЬ ВТ_Номера
		|ИЗ
		|	РегистрСведений.Расш1_СоставНомерногоФонда КАК Расш1_СоставНомерногоФонда
		|ГДЕ
		|	Расш1_СоставНомерногоФонда.НомернойФонд = &НомернойФонд
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	Номер";
		
		Запрос.УстановитьПараметр("НомернойФонд", НомернойФонд);		
		РезультатЗапроса = Запрос.Выполнить();
				
		vQry = New Query();
		vQry.МенеджерВременныхТаблиц = МенеджерВТ;
		vQry.Text = 
		"SELECT
		|	ExpectedGuestGroupsTurnovers.Hotel AS Hotel,
		|	ExpectedGuestGroupsTurnovers.RoomType AS RoomType,
		|	MAX(ISNULL(ExpectedGuestGroupsTurnovers.RoomsReservedTurnover, 0)) AS PreliminaryRooms,
		|	MAX(ISNULL(ExpectedGuestGroupsTurnovers.BedsReservedTurnover, 0)) AS PreliminaryBeds
		|INTO PreliminaryTotals
		|FROM
		|	AccumulationRegister.ExpectedGuestGroups.Turnovers(
		|			&qTentativeDateTimeFrom,
		|			&qTentativeDateTimeTo,
		|			DAY,
		|			(Hotel = &qHotel
		|				OR &qHotelIsEmpty)
		|				AND (&qRoomQuotaIsSet
		|						AND RoomQuota = &qRoomQuota
		|					OR NOT &qRoomQuotaIsSet)) AS ExpectedGuestGroupsTurnovers
		|
		|GROUP BY
		|	ExpectedGuestGroupsTurnovers.Hotel,
		|	ExpectedGuestGroupsTurnovers.RoomType
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT разрешенные
		|	BEGINOFPERIOD(RoomInventoryBalance.Period, DAY) AS Period,
		|	RoomInventoryBalance.Hotel AS Hotel,
		|	RoomInventoryBalance.RoomType AS RoomType,
		|	RoomInventoryBalance.CounterClosingBalance AS CounterClosingBalance,
		|	CASE
		|		WHEN &qRoomQuotaIsSet
		|				AND &qDoWriteOff
		|			THEN ISNULL(RoomQuotaBalances.RoomsRemains, 0)
		|		WHEN &qRoomQuotaIsSet
		|				AND NOT &qDoWriteOff
		|				AND ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0) < ISNULL(RoomQuotaBalances.RoomsRemains, 0)
		|			THEN ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0)
		|		WHEN &qRoomQuotaIsSet
		|				AND NOT &qDoWriteOff
		|				AND ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0) >= ISNULL(RoomQuotaBalances.RoomsRemains, 0)
		|			THEN ISNULL(RoomQuotaBalances.RoomsRemains, 0)
		|		ELSE ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0)
		|	END AS RoomsVacant,
		|	CASE
		|		WHEN &qRoomQuotaIsSet
		|				AND &qDoWriteOff
		|			THEN ISNULL(RoomQuotaBalances.BedsRemains, 0)
		|		WHEN &qRoomQuotaIsSet
		|				AND NOT &qDoWriteOff
		|				AND ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0) < ISNULL(RoomQuotaBalances.BedsRemains, 0)
		|			THEN ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0)
		|		WHEN &qRoomQuotaIsSet
		|				AND NOT &qDoWriteOff
		|				AND ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0) >= ISNULL(RoomQuotaBalances.BedsRemains, 0)
		|			THEN ISNULL(RoomQuotaBalances.BedsRemains, 0)
		|		ELSE ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0)
		|	END AS BedsVacant,
		|	RoomInventoryBalance.Hotel.SortCode AS HotelSortCode,
		|	RoomInventoryBalance.RoomType.SortCode AS RoomTypeSortCode
		|INTO RoomInventoryBalanceByDays
		|FROM
		|	AccumulationRegister.RoomInventory.BalanceAndTurnovers(
		|			&qDateTimeFrom,
		|			&qDateTimeTo,
		|			Minute,
		|			RegisterRecordsAndPeriodBoundaries,
		|			&qHotelIsEmpty
		|				OR Hotel IN HIERARCHY (&qHotel) и Room в (Выбрать Т.Номер Из ВТ_Номера как Т)) AS RoomInventoryBalance
		|		LEFT JOIN (SELECT
		|			BEGINOFPERIOD(RoomQuotaSalesBalanceAndTurnovers.Period, DAY) AS Period,
		|			RoomQuotaSalesBalanceAndTurnovers.Hotel AS Hotel,
		|			RoomQuotaSalesBalanceAndTurnovers.RoomType AS RoomType,
		|			RoomQuotaSalesBalanceAndTurnovers.CounterClosingBalance AS CounterClosingBalance,
		|			RoomQuotaSalesBalanceAndTurnovers.RoomsInQuotaClosingBalance AS RoomsInQuota,
		|			RoomQuotaSalesBalanceAndTurnovers.BedsInQuotaClosingBalance AS BedsInQuota,
		|			RoomQuotaSalesBalanceAndTurnovers.RoomsRemainsClosingBalance AS RoomsRemains,
		|			RoomQuotaSalesBalanceAndTurnovers.BedsRemainsClosingBalance AS BedsRemains
		|		FROM
		|			AccumulationRegister.RoomQuotaSales.BalanceAndTurnovers(
		|					&qDateTimeFrom,
		|					&qDateTimeTo,
		|					Day,
		|					RegisterRecordsAndPeriodBoundaries,
		|					(&qHotelIsEmpty
		|						OR Hotel = &qHotel)
		|						AND &qRoomQuotaIsSet
		|						AND RoomQuota = &qRoomQuota) AS RoomQuotaSalesBalanceAndTurnovers) AS RoomQuotaBalances
		|		ON RoomInventoryBalance.Hotel = RoomQuotaBalances.Hotel
		|			AND RoomInventoryBalance.RoomType = RoomQuotaBalances.RoomType
		|			AND (BEGINOFPERIOD(RoomInventoryBalance.Period, DAY) = BEGINOFPERIOD(RoomQuotaBalances.Period, DAY))
		|WHERE
		|	RoomInventoryBalance.RoomType IN(&qRoomTypesList)
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT 
		|	RoomInventoryBalanceByDays.Hotel AS Hotel,
		|	RoomInventoryBalanceByDays.RoomType AS RoomType,
		|	MIN(RoomInventoryBalanceByDays.RoomsVacant) AS RoomsAvailable,
		|	MIN(RoomInventoryBalanceByDays.BedsVacant) AS BedsAvailable
		|INTO RoomInventoryBalance
		|FROM
		|	RoomInventoryBalanceByDays AS RoomInventoryBalanceByDays
		|
		|GROUP BY
		|	RoomInventoryBalanceByDays.Hotel,
		|	RoomInventoryBalanceByDays.RoomType
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT
		|	RoomInventoryBalance.Hotel AS Hotel,
		|	RoomInventoryBalance.RoomType AS RoomType,
		|	RoomInventoryBalance.RoomsAvailable AS RoomsAvailable,
		|	RoomInventoryBalance.BedsAvailable AS BedsAvailable,
		|	RoomInventoryBalance.RoomsAvailable - ISNULL(PreliminaryTotals.PreliminaryRooms, 0) AS RoomsAvailableWithTentative,
		|	RoomInventoryBalance.BedsAvailable - ISNULL(PreliminaryTotals.PreliminaryBeds, 0) AS BedsAvailableWithTentative
		|INTO RoomInventoryBalanceWithTentative
		|FROM
		|	RoomInventoryBalance AS RoomInventoryBalance
		|		LEFT JOIN PreliminaryTotals AS PreliminaryTotals
		|		ON RoomInventoryBalance.Hotel = PreliminaryTotals.Hotel
		|			AND RoomInventoryBalance.RoomType = PreliminaryTotals.RoomType
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT
		|	RoomInventory.RoomType AS RoomType,
		|	RoomInventory.RoomType AS Ref,
		|	RoomInventory.RoomsAvailable AS RoomsAvailable,
		|	RoomInventory.BedsAvailable AS BedsAvailable,
		|	RoomInventory.RoomsAvailableWithTentative AS RoomsAvailableWithTentative,
		|	RoomInventory.BedsAvailableWithTentative AS BedsAvailableWithTentative,
		|	&qEmptyCurrency AS Currency,
		|	&qEmptyNumber AS Sum,
		|	&qEmptyString AS SumPresentation,
		|	&qEmptyNumber AS AvgPrice,
		|	&qEmptyString AS AvgPricePresentation,
		|	&qRoomRate AS RoomRate,
		|	&qEmptyCurrency AS Currency1,
		|	&qEmptyNumber AS Sum1,
		|	&qEmptyString AS SumPresentation1,
		|	&qEmptyNumber AS AvgPrice1,
		|	&qEmptyString AS AvgPricePresentation1,
		|	&qEmptyRoomRate AS RoomRate1,
		|	&qEmptyCurrency AS Currency2,
		|	&qEmptyNumber AS Sum2,
		|	&qEmptyString AS SumPresentation2,
		|	&qEmptyNumber AS AvgPrice2,
		|	&qEmptyString AS AvgPricePresentation2,
		|	&qEmptyRoomRate AS RoomRate2,
		|	&qEmptyCurrency AS Currency3,
		|	&qEmptyNumber AS Sum3,
		|	&qEmptyString AS SumPresentation3,
		|	&qEmptyNumber AS AvgPrice3,
		|	&qEmptyString AS AvgPricePresentation3,
		|	&qEmptyRoomRate AS RoomRate3,
		|	&qEmptyCurrency AS Currency4,
		|	&qEmptyNumber AS Sum4,
		|	&qEmptyString AS SumPresentation4,
		|	&qEmptyNumber AS AvgPrice4,
		|	&qEmptyString AS AvgPricePresentation4,
		|	&qEmptyRoomRate AS RoomRate4,
		|	&qEmptyCurrency AS Currency5,
		|	&qEmptyNumber AS Sum5,
		|	&qEmptyString AS SumPresentation5,
		|	&qEmptyNumber AS AvgPrice5,
		|	&qEmptyString AS AvgPricePresentation5,
		|	&qEmptyRoomRate AS RoomRate5,
		|	&qEmptyCurrency AS Currency6,
		|	&qEmptyNumber AS Sum6,
		|	&qEmptyString AS SumPresentation6,
		|	&qEmptyNumber AS AvgPrice6,
		|	&qEmptyString AS AvgPricePresentation6,
		|	&qEmptyRoomRate AS RoomRate6,
		|	&qEmptyCurrency AS Currency7,
		|	&qEmptyNumber AS Sum7,
		|	&qEmptyString AS SumPresentation7,
		|	&qEmptyNumber AS AvgPrice7,
		|	&qEmptyString AS AvgPricePresentation7,
		|	&qEmptyRoomRate AS RoomRate7,
		|	&qEmptyCurrency AS Currency8,
		|	&qEmptyNumber AS Sum8,
		|	&qEmptyString AS SumPresentation8,
		|	&qEmptyNumber AS AvgPrice8,
		|	&qEmptyString AS AvgPricePresentation8,
		|	&qEmptyRoomRate AS RoomRate8,
		|	&qEmptyCurrency AS Currency9,
		|	&qEmptyNumber AS Sum9,
		|	&qEmptyString AS SumPresentation9,
		|	&qEmptyNumber AS AvgPrice9,
		|	&qEmptyString AS AvgPricePresentation9,
		|	&qEmptyRoomRate AS RoomRate9,
		|	RoomInventory.RoomType.IsVirtual AS IsVirtual,
		|	&qEmptyString AS RoomsAvailableWithTentativePresentation,
		|	&qEmptyString AS BedsAvailableWithTentativePresentation,
		|	CASE
		|		WHEN StopSales.StopSale IS NULL
		|			THEN FALSE
		|		ELSE TRUE
		|	END AS StopSale
		|FROM
		|	(SELECT
		|		RoomInventoryBalanceWithTentative.Hotel AS Hotel,
		|		RoomInventoryBalanceWithTentative.RoomType AS RoomType,
		|		RoomInventoryBalanceWithTentative.RoomsAvailable AS RoomsAvailable,
		|		RoomInventoryBalanceWithTentative.BedsAvailable AS BedsAvailable,
		|		RoomInventoryBalanceWithTentative.RoomsAvailableWithTentative AS RoomsAvailableWithTentative,
		|		RoomInventoryBalanceWithTentative.BedsAvailableWithTentative AS BedsAvailableWithTentative
		|	FROM
		|		RoomInventoryBalanceWithTentative AS RoomInventoryBalanceWithTentative
		|	
		|	UNION ALL
		|	
		|	SELECT
		|		VirtualRoomTypes.Owner,
		|		VirtualRoomTypes.Ref,
		|		0,
		|		0,
		|		0,
		|		0
		|	FROM
		|		Catalog.RoomTypes AS VirtualRoomTypes
		|	WHERE
		|		VirtualRoomTypes.IsVirtual
		|		AND NOT VirtualRoomTypes.IsFolder
		|		AND (&qHotelIsEmpty
		|				OR VirtualRoomTypes.Owner IN HIERARCHY (&qHotel))) AS RoomInventory
		|		LEFT JOIN (SELECT
		|			RoomTypesStopSalePeriods.Ref AS StopSale
		|		FROM
		|			Catalog.RoomTypes.StopSalePeriods AS RoomTypesStopSalePeriods
		|		WHERE
		|			RoomTypesStopSalePeriods.StopSale
		|			AND RoomTypesStopSalePeriods.PeriodFrom < &qDateTimeTo
		|			AND RoomTypesStopSalePeriods.PeriodTo > &qDateTimeFrom
		|			AND NOT RoomTypesStopSalePeriods.Ref.DeletionMark
		|			AND NOT RoomTypesStopSalePeriods.Ref.IsFolder
		|		
		|		GROUP BY
		|			RoomTypesStopSalePeriods.Ref) AS StopSales
		|		ON RoomInventory.RoomType = StopSales.StopSale
		|WHERE
		|	NOT RoomInventory.RoomType.DeletionMark
		|	AND (NOT &qWindowViewIsFilled
		|			OR &qWindowViewIsFilled
		|				AND RoomInventory.RoomType.WindowView = &qWindowView)
		|	AND CASE
		|			WHEN &qCUCustomer <> VALUE(Catalog.Customers.EmptyRef)
		|				THEN RoomInventory.RoomsAvailable <> 0
		|						AND RoomInventory.BedsAvailable <> 0
		|			ELSE TRUE
		|		END
		|
		|ORDER BY
		|	RoomInventory.RoomType.SortCode"; 
	КонецЕсли;
	#КонецВставки
	
	#Удаление
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ExpectedGuestGroupsTurnovers.Hotel AS Hotel,
	|	ExpectedGuestGroupsTurnovers.RoomType AS RoomType,
	|	MAX(ISNULL(ExpectedGuestGroupsTurnovers.RoomsReservedTurnover, 0)) AS PreliminaryRooms,
	|	MAX(ISNULL(ExpectedGuestGroupsTurnovers.BedsReservedTurnover, 0)) AS PreliminaryBeds
	|INTO PreliminaryTotals
	|FROM
	|	AccumulationRegister.ExpectedGuestGroups.Turnovers(
	|			&qTentativeDateTimeFrom,
	|			&qTentativeDateTimeTo,
	|			DAY,
	|			(Hotel = &qHotel
	|				OR &qHotelIsEmpty)
	|				AND (&qRoomQuotaIsSet
	|						AND RoomQuota = &qRoomQuota
	|					OR NOT &qRoomQuotaIsSet)) AS ExpectedGuestGroupsTurnovers
	|
	|GROUP BY
	|	ExpectedGuestGroupsTurnovers.Hotel,
	|	ExpectedGuestGroupsTurnovers.RoomType
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	BEGINOFPERIOD(RoomInventoryBalance.Period, DAY) AS Period,
	|	RoomInventoryBalance.Hotel AS Hotel,
	|	RoomInventoryBalance.RoomType AS RoomType,
	|	RoomInventoryBalance.CounterClosingBalance AS CounterClosingBalance,
	|	CASE
	|		WHEN &qRoomQuotaIsSet
	|				AND &qDoWriteOff
	|			THEN ISNULL(RoomQuotaBalances.RoomsRemains, 0)
	|		WHEN &qRoomQuotaIsSet
	|				AND NOT &qDoWriteOff
	|				AND ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0) < ISNULL(RoomQuotaBalances.RoomsRemains, 0)
	|			THEN ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0)
	|		WHEN &qRoomQuotaIsSet
	|				AND NOT &qDoWriteOff
	|				AND ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0) >= ISNULL(RoomQuotaBalances.RoomsRemains, 0)
	|			THEN ISNULL(RoomQuotaBalances.RoomsRemains, 0)
	|		ELSE ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0)
	|	END AS RoomsVacant,
	|	CASE
	|		WHEN &qRoomQuotaIsSet
	|				AND &qDoWriteOff
	|			THEN ISNULL(RoomQuotaBalances.BedsRemains, 0)
	|		WHEN &qRoomQuotaIsSet
	|				AND NOT &qDoWriteOff
	|				AND ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0) < ISNULL(RoomQuotaBalances.BedsRemains, 0)
	|			THEN ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0)
	|		WHEN &qRoomQuotaIsSet
	|				AND NOT &qDoWriteOff
	|				AND ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0) >= ISNULL(RoomQuotaBalances.BedsRemains, 0)
	|			THEN ISNULL(RoomQuotaBalances.BedsRemains, 0)
	|		ELSE ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0)
	|	END AS BedsVacant,
	|	RoomInventoryBalance.Hotel.SortCode AS HotelSortCode,
	|	RoomInventoryBalance.RoomType.SortCode AS RoomTypeSortCode
	|INTO RoomInventoryBalanceByDays
	|FROM
	|	AccumulationRegister.RoomInventory.BalanceAndTurnovers(
	|			&qDateTimeFrom,
	|			&qDateTimeTo,
	|			Minute,
	|			RegisterRecordsAndPeriodBoundaries,
	|			&qHotelIsEmpty
	|				OR Hotel IN HIERARCHY (&qHotel)) AS RoomInventoryBalance
	|		LEFT JOIN (SELECT
	|			BEGINOFPERIOD(RoomQuotaSalesBalanceAndTurnovers.Period, DAY) AS Period,
	|			RoomQuotaSalesBalanceAndTurnovers.Hotel AS Hotel,
	|			RoomQuotaSalesBalanceAndTurnovers.RoomType AS RoomType,
	|			RoomQuotaSalesBalanceAndTurnovers.CounterClosingBalance AS CounterClosingBalance,
	|			RoomQuotaSalesBalanceAndTurnovers.RoomsInQuotaClosingBalance AS RoomsInQuota,
	|			RoomQuotaSalesBalanceAndTurnovers.BedsInQuotaClosingBalance AS BedsInQuota,
	|			RoomQuotaSalesBalanceAndTurnovers.RoomsRemainsClosingBalance AS RoomsRemains,
	|			RoomQuotaSalesBalanceAndTurnovers.BedsRemainsClosingBalance AS BedsRemains
	|		FROM
	|			AccumulationRegister.RoomQuotaSales.BalanceAndTurnovers(
	|					&qDateTimeFrom,
	|					&qDateTimeTo,
	|					Day,
	|					RegisterRecordsAndPeriodBoundaries,
	|					(&qHotelIsEmpty
	|						OR Hotel = &qHotel)
	|						AND &qRoomQuotaIsSet
	|						AND RoomQuota = &qRoomQuota) AS RoomQuotaSalesBalanceAndTurnovers) AS RoomQuotaBalances
	|		ON RoomInventoryBalance.Hotel = RoomQuotaBalances.Hotel
	|			AND RoomInventoryBalance.RoomType = RoomQuotaBalances.RoomType
	|			AND (BEGINOFPERIOD(RoomInventoryBalance.Period, DAY) = BEGINOFPERIOD(RoomQuotaBalances.Period, DAY))
	|WHERE
	|	RoomInventoryBalance.RoomType IN(&qRoomTypesList)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	RoomInventoryBalanceByDays.Hotel AS Hotel,
	|	RoomInventoryBalanceByDays.RoomType AS RoomType,
	|	MIN(RoomInventoryBalanceByDays.RoomsVacant) AS RoomsAvailable,
	|	MIN(RoomInventoryBalanceByDays.BedsVacant) AS BedsAvailable
	|INTO RoomInventoryBalance
	|FROM
	|	RoomInventoryBalanceByDays AS RoomInventoryBalanceByDays
	|
	|GROUP BY
	|	RoomInventoryBalanceByDays.Hotel,
	|	RoomInventoryBalanceByDays.RoomType
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	RoomInventoryBalance.Hotel AS Hotel,
	|	RoomInventoryBalance.RoomType AS RoomType,
	|	RoomInventoryBalance.RoomsAvailable AS RoomsAvailable,
	|	RoomInventoryBalance.BedsAvailable AS BedsAvailable,
	|	RoomInventoryBalance.RoomsAvailable - ISNULL(PreliminaryTotals.PreliminaryRooms, 0) AS RoomsAvailableWithTentative,
	|	RoomInventoryBalance.BedsAvailable - ISNULL(PreliminaryTotals.PreliminaryBeds, 0) AS BedsAvailableWithTentative
	|INTO RoomInventoryBalanceWithTentative
	|FROM
	|	RoomInventoryBalance AS RoomInventoryBalance
	|		LEFT JOIN PreliminaryTotals AS PreliminaryTotals
	|		ON RoomInventoryBalance.Hotel = PreliminaryTotals.Hotel
	|			AND RoomInventoryBalance.RoomType = PreliminaryTotals.RoomType
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	RoomInventory.RoomType AS RoomType,
	|	RoomInventory.RoomType AS Ref,
	|	RoomInventory.RoomsAvailable AS RoomsAvailable,
	|	RoomInventory.BedsAvailable AS BedsAvailable,
	|	RoomInventory.RoomsAvailableWithTentative AS RoomsAvailableWithTentative,
	|	RoomInventory.BedsAvailableWithTentative AS BedsAvailableWithTentative,
	|	&qEmptyCurrency AS Currency,
	|	&qEmptyNumber AS Sum,
	|	&qEmptyString AS SumPresentation,
	|	&qEmptyNumber AS AvgPrice,
	|	&qEmptyString AS AvgPricePresentation,
	|	&qRoomRate AS RoomRate,
	|	&qEmptyCurrency AS Currency1,
	|	&qEmptyNumber AS Sum1,
	|	&qEmptyString AS SumPresentation1,
	|	&qEmptyNumber AS AvgPrice1,
	|	&qEmptyString AS AvgPricePresentation1,
	|	&qEmptyRoomRate AS RoomRate1,
	|	&qEmptyCurrency AS Currency2,
	|	&qEmptyNumber AS Sum2,
	|	&qEmptyString AS SumPresentation2,
	|	&qEmptyNumber AS AvgPrice2,
	|	&qEmptyString AS AvgPricePresentation2,
	|	&qEmptyRoomRate AS RoomRate2,
	|	&qEmptyCurrency AS Currency3,
	|	&qEmptyNumber AS Sum3,
	|	&qEmptyString AS SumPresentation3,
	|	&qEmptyNumber AS AvgPrice3,
	|	&qEmptyString AS AvgPricePresentation3,
	|	&qEmptyRoomRate AS RoomRate3,
	|	&qEmptyCurrency AS Currency4,
	|	&qEmptyNumber AS Sum4,
	|	&qEmptyString AS SumPresentation4,
	|	&qEmptyNumber AS AvgPrice4,
	|	&qEmptyString AS AvgPricePresentation4,
	|	&qEmptyRoomRate AS RoomRate4,
	|	&qEmptyCurrency AS Currency5,
	|	&qEmptyNumber AS Sum5,
	|	&qEmptyString AS SumPresentation5,
	|	&qEmptyNumber AS AvgPrice5,
	|	&qEmptyString AS AvgPricePresentation5,
	|	&qEmptyRoomRate AS RoomRate5,
	|	&qEmptyCurrency AS Currency6,
	|	&qEmptyNumber AS Sum6,
	|	&qEmptyString AS SumPresentation6,
	|	&qEmptyNumber AS AvgPrice6,
	|	&qEmptyString AS AvgPricePresentation6,
	|	&qEmptyRoomRate AS RoomRate6,
	|	&qEmptyCurrency AS Currency7,
	|	&qEmptyNumber AS Sum7,
	|	&qEmptyString AS SumPresentation7,
	|	&qEmptyNumber AS AvgPrice7,
	|	&qEmptyString AS AvgPricePresentation7,
	|	&qEmptyRoomRate AS RoomRate7,
	|	&qEmptyCurrency AS Currency8,
	|	&qEmptyNumber AS Sum8,
	|	&qEmptyString AS SumPresentation8,
	|	&qEmptyNumber AS AvgPrice8,
	|	&qEmptyString AS AvgPricePresentation8,
	|	&qEmptyRoomRate AS RoomRate8,
	|	&qEmptyCurrency AS Currency9,
	|	&qEmptyNumber AS Sum9,
	|	&qEmptyString AS SumPresentation9,
	|	&qEmptyNumber AS AvgPrice9,
	|	&qEmptyString AS AvgPricePresentation9,
	|	&qEmptyRoomRate AS RoomRate9,
	|	RoomInventory.RoomType.IsVirtual AS IsVirtual,
	|	&qEmptyString AS RoomsAvailableWithTentativePresentation,
	|	&qEmptyString AS BedsAvailableWithTentativePresentation,
	|	CASE
	|		WHEN StopSales.StopSale IS NULL
	|			THEN FALSE
	|		ELSE TRUE
	|	END AS StopSale
	|FROM
	|	(SELECT
	|		RoomInventoryBalanceWithTentative.Hotel AS Hotel,
	|		RoomInventoryBalanceWithTentative.RoomType AS RoomType,
	|		RoomInventoryBalanceWithTentative.RoomsAvailable AS RoomsAvailable,
	|		RoomInventoryBalanceWithTentative.BedsAvailable AS BedsAvailable,
	|		RoomInventoryBalanceWithTentative.RoomsAvailableWithTentative AS RoomsAvailableWithTentative,
	|		RoomInventoryBalanceWithTentative.BedsAvailableWithTentative AS BedsAvailableWithTentative
	|	FROM
	|		RoomInventoryBalanceWithTentative AS RoomInventoryBalanceWithTentative
	|	
	|	UNION ALL
	|	
	|	SELECT
	|		VirtualRoomTypes.Owner,
	|		VirtualRoomTypes.Ref,
	|		0,
	|		0,
	|		0,
	|		0
	|	FROM
	|		Catalog.RoomTypes AS VirtualRoomTypes
	|	WHERE
	|		VirtualRoomTypes.IsVirtual
	|		AND NOT VirtualRoomTypes.IsFolder
	|		AND (&qHotelIsEmpty
	|				OR VirtualRoomTypes.Owner IN HIERARCHY (&qHotel))) AS RoomInventory
	|		LEFT JOIN (SELECT
	|			RoomTypesStopSalePeriods.Ref AS StopSale
	|		FROM
	|			Catalog.RoomTypes.StopSalePeriods AS RoomTypesStopSalePeriods
	|		WHERE
	|			RoomTypesStopSalePeriods.StopSale
	|			AND RoomTypesStopSalePeriods.PeriodFrom < &qDateTimeTo
	|			AND RoomTypesStopSalePeriods.PeriodTo > &qDateTimeFrom
	|			AND NOT RoomTypesStopSalePeriods.Ref.DeletionMark
	|			AND NOT RoomTypesStopSalePeriods.Ref.IsFolder
	|		
	|		GROUP BY
	|			RoomTypesStopSalePeriods.Ref) AS StopSales
	|		ON RoomInventory.RoomType = StopSales.StopSale
	|WHERE
	|	NOT RoomInventory.RoomType.DeletionMark
	|	AND (NOT &qWindowViewIsFilled
	|			OR &qWindowViewIsFilled
	|				AND RoomInventory.RoomType.WindowView = &qWindowView)
	|	AND CASE
	|			WHEN &qCUCustomer <> VALUE(Catalog.Customers.EmptyRef)
	|				THEN RoomInventory.RoomsAvailable <> 0
	|						AND RoomInventory.BedsAvailable <> 0
	|			ELSE TRUE
	|		END
	|
	|ORDER BY
	|	RoomInventory.RoomType.SortCode"; 
	#КонецУдаления
	vQry.SetParameter("qHotel", Hotel);
	vQry.SetParameter("qHotelIsEmpty", Not ValueIsFilled(Hotel));
	vQry.SetParameter("qRoomQuota", RoomQuota);
	vQry.SetParameter("qRoomQuotaIsSet", ValueIsFilled(RoomQuota));
	vQry.SetParameter("qDoWriteOff", ?(ValueIsFilled(RoomQuota), RoomQuota.DoWriteOff, False));
	vQry.SetParameter("qDateTimeFrom", cm1SecondShift(CheckInDate));
	vQry.SetParameter("qDateTimeTo", cm0SecondShift(CheckOutDate));
	vQry.SetParameter("qTentativeDateTimeFrom", BegOfDay(CheckInDate));
	vQry.SetParameter("qTentativeDateTimeTo", EndOfDay(CheckOutDate) - 24*3600);
	vQry.SetParameter("qRoomTypesList", vRoomTypes.UnloadColumn("RoomType"));
	vQry.SetParameter("qEmptyNumber", 0);
	vQry.SetParameter("qEmptyString", "");
	vQry.SetParameter("qEmptyDate", '00010101');
	vQry.SetParameter("qEmptyCurrency", Catalogs.Currencies.EmptyRef());
	vQry.SetParameter("qRoomRate", RoomRate);
	vQry.SetParameter("qEmptyRoomRate", Catalogs.RoomRates.EmptyRef());
	vQry.SetParameter("qWindowViewIsFilled", ValueIsFilled(WindowView));
	vQry.SetParameter("qWindowView", WindowView);
	vQry.SetParameter("qCUCustomer", SessionParameters.CurrentUser.Customer);
	vRoomTypes = vQry.Execute().Unload();
	
	ValueToFormAttribute(vRoomTypes, "RoomTypesList");
	
	For Each vItem In RoomTypesList Do
		vItem.RoomsAvailableWithTentativePresentation = Format(vItem.RoomsAvailable, "NFD=0; NZ=; NG=") + ?(vItem.RoomsAvailable <> vItem.RoomsAvailableWithTentative, " / " + Format(vItem.RoomsAvailableWithTentative, "NFD=0; NZ=; NG="), "");	
		vItem.BedsAvailableWithTentativePresentation = Format(vItem.BedsAvailable, "NFD=0; NZ=; NG=") + ?(vItem.BedsAvailable <> vItem.BedsAvailableWithTentative, " / " + Format(vItem.BedsAvailableWithTentative, "NFD=0; NZ=; NG="), "");
	EndDo;
	
	// Fill totals
	vRoomsAvailableTotal = vRoomTypes.Total("RoomsAvailable"); 
	vBedsAvailableTotal = vRoomTypes.Total("BedsAvailable");
	vRoomsAvailableWithTentativeTotal = vRoomTypes.Total("RoomsAvailableWithTentative");
	vBedsAvailableWithTentativeTotal = vRoomTypes.Total("BedsAvailableWithTentative");
	Items.RoomTypesListRoomsAvailableWithTentativePresentation.FooterText = Format(vRoomsAvailableTotal, "NFD=0; NZ=; NG=") + ?(vRoomsAvailableTotal <> vRoomsAvailableWithTentativeTotal, " / " + Format(vRoomsAvailableWithTentativeTotal, "NFD=0; NZ=; NG="), "");
	Items.RoomTypesListBedsAvailableWithTentativePresentation.FooterText = Format(vBedsAvailableTotal, "NFD=0; NZ=; NG=") + ?(vBedsAvailableTotal <> vBedsAvailableWithTentativeTotal, " / " + Format(vBedsAvailableWithTentativeTotal, "NFD=0; NZ=; NG="), "");
	
	// Get default customer
	vCustomer = Undefined;
	vCurUser = SessionParameters.CurrentUser;
	If ValueIsFilled(vCurUser.Customer) Then
		vCustomer = vCurUser.Customer;
	EndIf;
	If IsFromObject Then
		// Get room type prices for default room rate and other room rates available for the given guest 
		vRoomRatesList = New ValueList();
		// Get allowed room rates for the case
		vCustomerRoomRatesAreUsed = False; 
		If ValueIsFilled(SelContract) And SelContract.RoomRates.Count() > 0 Then
			vRoomRatesList.LoadValues(SelContract.RoomRates.UnloadColumn("RoomRate"));
		ElsIf ValueIsFilled(SelCustomer) And SelCustomer.RoomRates.Count() > 0 Then
			vRoomRatesList.LoadValues(SelCustomer.RoomRates.UnloadColumn("RoomRate"));
		EndIf;
		r = 0;
		While r < vRoomRatesList.Count() Do
			If Not ValueIsFilled(vRoomRatesList.Get(r).Value) Then
				vRoomRatesList.Delete(r);
			Else
				r = r + 1;
			EndIf;
		EndDo;
		vRoomRatesAllowed = cmGetAllowedRoomRates(CheckInDate, CheckOutDate, CurrentSessionDate(), , Hotel);
		If vRoomRatesAllowed.Count() > 0 Then
			If vRoomRatesList.Count() > 0 Then
				vCustomerRoomRatesAreUsed = True; 
				If vRoomRatesAllowed.Count() > 0 Then
					i = 0;
					While i < vRoomRatesList.Count() Do
						vRoomRateItem = vRoomRatesList.Get(i);
						If vRoomRatesAllowed.FindByValue(vRoomRateItem.Value) = Undefined Then
							If RoomRate <> vRoomRateItem.Value Then
								vRoomRatesList.Delete(i);
								Continue;
							EndIf;
						EndIf;
						i = i + 1;
					EndDo;
				EndIf;
			Else
				vRoomRatesList.LoadValues(vRoomRatesAllowed.UnloadValues());
			EndIf;
		EndIf;
		If Not vCustomerRoomRatesAreUsed Then
			i = 0;
			While i < vRoomRatesList.Count() Do
				vRoomRateRef = vRoomRatesList.Get(i).Value;
				If RoomRate <> vRoomRateRef And 
					Not vRoomRateRef.IsRackRate And 
					Not vRoomRateRef.IsOnlineRate And 
					Not vRoomRateRef.IsHiddenRateForAuthorizedClients And  
					Not vRoomRateRef.IsRateForCRS Then
					vRoomRatesList.Delete(i);
					Continue;
				EndIf;
				i = i + 1;
			EndDo;
		EndIf;
		If ValueIsFilled(RoomRate) And Not ValueIsFilled(RoomRate.PriceTagType) Then
			// Force current room rate be the first in the list
			vRoomRateItem = vRoomRatesList.FindByValue(RoomRate);
			If vRoomRateItem <> Undefined Then
				vRoomRatesList.Delete(vRoomRateItem);
			EndIf;
			vRoomRatesList.Insert(0, RoomRate);
			
			// Process room rates with price cache filled only 
			If cmRoomRatePricesCacheIsFilled(Hotel, vRoomRatesList, ClientType, CheckInDate, CheckOutDate) Then
				// Get accommodation templates suitable for each room rate / room type
				vAccTemplates = cmGetAccommodationTemplateDetailsByGuestsQuantity(NumberOfAdults, NumberOfKids, vAgeArray, Hotel, True, vChildrenAgesStruct);
				vAccTemplatesList = New ValueList();
				vAccTemplatesList.LoadValues(vAccTemplates.UnloadColumn("AccommodationTemplate"));
				
				// Get prices for each suitable template
				vPrices = cmGetCachedPrices(Hotel, ClientType, BegOfDay(CheckInDate), BegOfDay(CheckOutDate), Catalogs.PriceTags.EmptyRef(), vRoomRatesList, vAccTemplatesList);
				
				vRatesCount = Min(vRoomRatesList.Count(), 10);
				i = 0;
				While i < vRatesCount Do
					vRoomRate = vRoomRatesList.Get(i).Value;
					vRoomRatePresentation = TrimAll(vRoomRate);
					
					// Check room rate is valid period
					If ValueIsFilled(vRoomRate.DateValidFrom) Or ValueIsFilled(vRoomRate.DateValidTo) Then
						If ValueIsFilled(vRoomRate.DateValidFrom) And CheckInDate < vRoomRate.DateValidFrom Then
							i = i + 1;
							Continue;
						EndIf;
						If ValueIsFilled(vRoomRate.DateValidTo) And CheckOutDate > EndOfDay(vRoomRate.DateValidTo) Then
							i = i + 1;
							Continue;
						EndIf;
					EndIf;
					
					vCurAccommodationTemplate = Undefined;
					vRoomTypesToSkip = New ValueList();
					
					For Each vRoomTypesRow In RoomTypesList Do
						vCurRoomType = vRoomTypesRow.RoomType;
						
						// Check room rate restrictions
						If vRoomTypesToSkip.FindByValue(vCurRoomType) <> Undefined Then
							vCurRoomType = Undefined;
							Continue;
						EndIf;
						If Not cmCheckRoomRateRestrictions(Hotel, vRoomRate, vCurRoomType, cm1SecondShift(CheckInDate), cm0SecondShift(CheckOutDate), cmCalculateDuration(vRoomRate, cm1SecondShift(CheckInDate), cm0SecondShift(CheckOutDate))) Then
							vRoomTypesToSkip.Add(vCurRoomType);
							vCurRoomType = Undefined;
							Continue;
						EndIf;
						
						// Get prices for current room rate, room type
						j = 0;
						vGoToOutput = False;
						
						// Filter prices by price tags
						vRoomRateRoomTypePrices = Undefined;
						If ValueIsFilled(vRoomRate.PriceTagType) Then
							vRoomRatePrices = cmGetCachedPricesForPriceTags(Hotel, ClientType, BegOfDay(CheckInDate), BegOfDay(CheckOutDate), vRoomRate, vCurRoomType, vAccTemplatesList);
							vRoomRateRoomTypePrices = vRoomRatePrices.FindRows(New Structure("RoomRate, RoomType", vRoomRate, vCurRoomType));
						Else
							// Get prices for current room rate and room type
							vRoomRateRoomTypePrices = vPrices.FindRows(New Structure("RoomRate, RoomType", vRoomRate, vCurRoomType));
						EndIf;
						If vRoomRateRoomTypePrices <> Undefined And vRoomRateRoomTypePrices.Count() > 0 Then
							vAgeValueTable.FillValues(False, "IsUsed");
							
							vCurAccommodationTemplate = Undefined;
							vCurrency = Catalogs.Currencies.EmptyRef();
							vSum = 0;
							For Each vRoomRateRoomTypePricesRow In vRoomRateRoomTypePrices Do
								j = j + 1;
								vWrkAccommodationTemplate = vRoomRateRoomTypePricesRow.AccommodationTemplate;
								If ValueIsFilled(vWrkAccommodationTemplate) Then
									If vWrkAccommodationTemplate.RoomTypes.Count() <> 0 And vWrkAccommodationTemplate.RoomTypes.Find(vCurRoomType, "RoomType") = Undefined Then
										Continue;
									EndIf;
								EndIf;
								If ValueIsFilled(vCurAccommodationTemplate) And vCurAccommodationTemplate <> vRoomRateRoomTypePricesRow.AccommodationTemplate Then
									vGoToOutput = True;
								EndIf;
								If Not vGoToOutput Then
									vCurAccommodationTemplate = vRoomRateRoomTypePricesRow.AccommodationTemplate;
									vCurAccommodationType = vRoomRateRoomTypePricesRow.AccommodationType;
									
									For Each vAgeRow In vAgeValueTable Do
										If Not vAgeRow.IsUsed And vAgeRow.Age > vCurAccommodationType.AllowedClientAgeFrom And vAgeRow.Age < vCurAccommodationType.AllowedClientAgeTo Then
											vAgeRow.IsUsed = True;
											Break;
										EndIf;
									EndDo;
									
									If Not ValueIsFilled(vCurrency) Then
										vCurrency = vRoomRateRoomTypePricesRow.Currency;
									EndIf;
									vSum = vSum + vRoomRateRoomTypePricesRow.Amount;
								EndIf;
							EndDo; // By prices
							
							If vGoToOutput Or j = vRoomRateRoomTypePrices.Count() Or j < vRoomRateRoomTypePrices.Count() And vRoomRateRoomTypePrices.Get(j).AccommodationTemplate <> vCurAccommodationTemplate Then 
								If i = 0  Then
									vRoomTypesRow.Currency = vCurrency;
									vRoomTypesRow.Sum = vSum;
									vRoomTypesRow.SumPresentation = cmFormatSum(vSum, vCurrency);
									vRoomTypesRow.AvgPrice = ?(Duration <> 0, Round(vSum/Duration, 2), 0);
									vRoomTypesRow.AvgPricePresentation = cmFormatSum(vRoomTypesRow.AvgPrice, vCurrency);
									Items.RoomTypesListSumPresentation.Title = vRoomRatePresentation;
									Items.RoomTypesListSumPresentation.Visible = True;
								Else
									vRoomTypesRow["RoomRate" + i] = vRoomRate;
									vRoomTypesRow["Currency" + i] = vCurrency;
									vRoomTypesRow["Sum" + i] = vSum;
									vRoomTypesRow["SumPresentation" + i] = cmFormatSum(vSum, vCurrency);
									vRoomTypesRow["AvgPrice" + i] = ?(Duration <> 0, Round(vSum/Duration, 2), 0);
									vRoomTypesRow["AvgPricePresentation" + i] = cmFormatSum(vRoomTypesRow["AvgPrice" + i], vCurrency);
									Items["RoomTypesListSumPresentation" + i].Title = vRoomRatePresentation;
									Items["RoomTypesListSumPresentation" + i].Visible = True;
								EndIf;
								
								vSum = 0;
								vCurrency = Undefined;
							EndIf;
						EndIf; // Room rate/Room type prices found
					EndDo; // By room types
					i = i + 1;
				EndDo; // By room rates	
			Else
				IsFromObject = False;
			EndIf; // Prices cache is filled
		EndIf; // Room rate is filled
	EndIf; // Is from object	
EndProcedure

&НаСервере
Функция ПолучитьМассивДоступныхНомерныхФондов()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	PermissionGroupsДоступныеНомерныеФонды.НомернойФонд КАК Ссылка
	|ИЗ
	|	Справочник.Employees КАК Employees
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.PermissionGroups.ДоступныеНомерныеФонды КАК PermissionGroupsДоступныеНомерныеФонды
	|		ПО Employees.PermissionGroup = PermissionGroupsДоступныеНомерныеФонды.Ссылка
	|ГДЕ
	|	Employees.Ссылка = &Ref";
	
	Запрос.УстановитьПараметр("Ref", SessionParameters.CurrentUser);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	МассивНомерныхФондов = Новый Массив;
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		МассивНомерныхФондов.Добавить(ВыборкаДетальныеЗаписи.Ссылка);
	КонецЦикла;
	
	Возврат МассивНомерныхФондов;
	
КонецФункции

&НаКлиенте
Процедура Расш1_НомернойФондНачалоВыбораПосле(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ДоступныВсеНомера = ПроверитьДоступностьВсегоНомерногоФонда();
	
	Если ДоступныВсеНомера Тогда
		Возврат;
	КонецЕсли;
	
	СтандартнаяОбработка = Ложь;
	
	Массив = ПолучитьМассивДоступныхНомерныхФондов();
	
	Настройки = Новый НастройкиКомпоновкиДанных;
	
	ЭлементОтбора = Настройки.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.Использование = Истина;
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Ссылка");
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.ВСписке;
	ЭлементОтбора.ПравоеЗначение = Массив;
	ЭлементОтбора.РежимОтображения = РежимОтображенияЭлементаНастройкиКомпоновкиДанных.Обычный;
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ФиксированныеНастройки", Настройки);
	
	ОткрытьФорму("Справочник.Расш1_НомерныеФонды.ФормаВыбора", ПараметрыФормы, Элемент);
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПроверитьДоступностьВсегоНомерногоФонда()
	Возврат SessionParameters.ВсеНомераДоступны; 	
КонецФункции

&НаКлиенте
Процедура Расш1_НомернойФондПриИзмененииПосле(Элемент)
	
	BuildList();
	
КонецПроцедуры
