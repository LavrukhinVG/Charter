
&ChangeAndValidate("tcDesktop_GetRoomStatusesTable")
Procedure Расш1_tcDesktop_GetRoomStatusesTable(pTempStorageAddress, pCurrentHotel) Export
	
	#Вставка
	НомернойФонд = pCurrentHotel.НомернойФонд;
	pCurrentHotel = pCurrentHotel.CurrentHotel;
	
	Если НомернойФонд.Пустая() Тогда
		vQuery = New Query;
		vQuery.Text = 
		"SELECT Разрешенные
		|	Rooms.RoomStatus,
		|	SUM(1) AS RoomQuantity
		|FROM
		|	Catalog.Rooms AS Rooms
		|WHERE
		|	NOT Rooms.DeletionMark
		|	AND NOT Rooms.IsFolder
		|	AND NOT Rooms.IsVirtual
		|	AND Rooms.OperationStartDate <= &qDate
		|	AND (Rooms.OperationEndDate >= &qDate
		|			OR Rooms.OperationEndDate = DATETIME(1, 1, 1, 0, 0, 0))
		|	AND Rooms.Owner IN HIERARCHY (&qHotel)
		|
		|GROUP BY
		|	Rooms.RoomStatus
		|
		|ORDER BY
		|	Rooms.RoomStatus.SortCode";
		
	Иначе
		vQuery = New Query;
		vQuery.Text =
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	Rooms.RoomStatus КАК RoomStatus,
		|	СУММА(1) КАК RoomQuantity
		|ИЗ
		|	Справочник.Rooms КАК Rooms
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.Расш1_СоставНомерногоФонда КАК Расш1_СоставНомерногоФонда
		|		ПО (Rooms.Ссылка = Расш1_СоставНомерногоФонда.Номер
		|				И Расш1_СоставНомерногоФонда.НомернойФонд = &НомернойФонд)
		|ГДЕ
		|	НЕ Rooms.ПометкаУдаления
		|	И НЕ Rooms.ЭтоГруппа
		|	И НЕ Rooms.IsVirtual
		|	И Rooms.OperationStartDate <= &qDate
		|	И (Rooms.OperationEndDate >= &qDate
		|			ИЛИ Rooms.OperationEndDate = ДАТАВРЕМЯ(1, 1, 1, 0, 0, 0))
		|	И Rooms.Владелец В ИЕРАРХИИ(&qHotel)
		|
		|СГРУППИРОВАТЬ ПО
		|	Rooms.RoomStatus
		|
		|УПОРЯДОЧИТЬ ПО
		|	Rooms.RoomStatus.SortCode";
		
		vQuery.SetParameter("НомернойФонд", НомернойФонд);
	КонецЕсли;
	#КонецВставки
	
	#Удаление
	vQuery = New Query;
	vQuery.Text = 
	"SELECT
	|	Rooms.RoomStatus,
	|	SUM(1) AS RoomQuantity
	|FROM
	|	Catalog.Rooms AS Rooms
	|WHERE
	|	NOT Rooms.DeletionMark
	|	AND NOT Rooms.IsFolder
	|	AND NOT Rooms.IsVirtual
	|	AND Rooms.OperationStartDate <= &qDate
	|	AND (Rooms.OperationEndDate >= &qDate
	|			OR Rooms.OperationEndDate = DATETIME(1, 1, 1, 0, 0, 0))
	|	AND Rooms.Owner IN HIERARCHY (&qHotel)
	|
	|GROUP BY
	|	Rooms.RoomStatus
	|
	|ORDER BY
	|	Rooms.RoomStatus.SortCode";
	#КонецУдаления
	
	vQuery.SetParameter("qDate", CurrentSessionDate());
	vQuery.SetParameter("qHotel", pCurrentHotel);
	vQueryResult = vQuery.Execute().Unload();
	PutToTempStorage(vQueryResult,pTempStorageAddress);
EndProcedure

&ChangeAndValidate("tcDesktop_GetSummaryPercent")
Procedure Расш1_tcDesktop_GetSummaryPercent(pTempStorageAddress, pCurrentHotel) Export
		
	Var TotalPerDay;
	
	#Вставка
	НомернойФонд = pCurrentHotel.НомернойФонд;
	pCurrentHotel = pCurrentHotel.CurrentHotel;
	
	Если Не НомернойФонд.Пустая() Тогда
		
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
		
	КонецЕсли;
	#КонецВставки

	Occupation = 0;
	vDate = tcOnServer.GetForecastStartDate(pCurrentHotel);
	vBegOfPeriod = BegOfDay(vDate);
	vEndOfPeriod = EndOfDay(vDate);
	// Initialize typesof data to show
	vInRooms = True;
	vWithVAT = True;
	If ValueIsFilled(pCurrentHotel) Then
		vInRooms = Not pCurrentHotel.ShowReportsInBeds;
		vWithVAT = pCurrentHotel.ShowSalesInReportsWithVAT;
	EndIf;

	// Run query to get total number of rooms, rooms blocked, vacant number of rooms
	#Вставка
	Если НомернойФонд.Пустая() Тогда
		vQry = New Query();
		vQry.Text = 
		"SELECT разрешенные
		|	RoomInventoryBalanceAndTurnovers.Period AS Period,
		|	SUM(RoomInventoryBalanceAndTurnovers.CounterClosingBalance) AS CounterClosingBalance,
		|	SUM(RoomInventoryBalanceAndTurnovers.TotalRoomsClosingBalance) AS TotalRoomsClosingBalance,
		|	SUM(RoomInventoryBalanceAndTurnovers.TotalBedsClosingBalance) AS TotalBedsClosingBalance,
		|	-SUM(RoomInventoryBalanceAndTurnovers.RoomsBlockedClosingBalance) AS RoomsBlockedClosingBalance,
		|	-SUM(RoomInventoryBalanceAndTurnovers.BedsBlockedClosingBalance) AS BedsBlockedClosingBalance
		|FROM
		|	AccumulationRegister.RoomInventory.BalanceAndTurnovers(&qPeriodFrom, &qPeriodTo, Day, RegisterRecordsAndPeriodBoundaries, Hotel IN HIERARCHY (&qHotel)) AS RoomInventoryBalanceAndTurnovers
		|GROUP BY
		|	RoomInventoryBalanceAndTurnovers.Period
		|ORDER BY
		|	Period";
		
	Иначе
		vQry = New Query();
		vQry.МенеджерВременныхТаблиц = МенеджерВТ;
		vQry.Text = 
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	RoomInventoryBalanceAndTurnovers.Период КАК Period,
		|	СУММА(RoomInventoryBalanceAndTurnovers.CounterКонечныйОстаток) КАК CounterClosingBalance,
		|	СУММА(RoomInventoryBalanceAndTurnovers.TotalRoomsКонечныйОстаток) КАК TotalRoomsClosingBalance,
		|	СУММА(RoomInventoryBalanceAndTurnovers.TotalBedsКонечныйОстаток) КАК TotalBedsClosingBalance,
		|	-СУММА(RoomInventoryBalanceAndTurnovers.RoomsBlockedКонечныйОстаток) КАК RoomsBlockedClosingBalance,
		|	-СУММА(RoomInventoryBalanceAndTurnovers.BedsBlockedКонечныйОстаток) КАК BedsBlockedClosingBalance
		|ИЗ
		|	РегистрНакопления.RoomInventory.ОстаткиИОбороты(
		|			&qPeriodFrom,
		|			&qPeriodTo,
		|			Day,
		|			RegisterRecordsAndPeriodBoundaries,
		|			Hotel В ИЕРАРХИИ (&qHotel)
		|				И Room В
		|					(ВЫБРАТЬ
		|						ВТ_Номера.Номер КАК Номер
		|					ИЗ
		|						ВТ_Номера КАК ВТ_Номера)) КАК RoomInventoryBalanceAndTurnovers
		//|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_Номера КАК ВТ_Номера
		//|		ПО RoomInventoryBalanceAndTurnovers.Room = ВТ_Номера.Номер
		|
		|СГРУППИРОВАТЬ ПО
		|	RoomInventoryBalanceAndTurnovers.Период
		|
		|УПОРЯДОЧИТЬ ПО
		|	Period";
	КонецЕсли;
	#КонецВставки
	
	#Удаление
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	RoomInventoryBalanceAndTurnovers.Period AS Period,
	|	SUM(RoomInventoryBalanceAndTurnovers.CounterClosingBalance) AS CounterClosingBalance,
	|	SUM(RoomInventoryBalanceAndTurnovers.TotalRoomsClosingBalance) AS TotalRoomsClosingBalance,
	|	SUM(RoomInventoryBalanceAndTurnovers.TotalBedsClosingBalance) AS TotalBedsClosingBalance,
	|	-SUM(RoomInventoryBalanceAndTurnovers.RoomsBlockedClosingBalance) AS RoomsBlockedClosingBalance,
	|	-SUM(RoomInventoryBalanceAndTurnovers.BedsBlockedClosingBalance) AS BedsBlockedClosingBalance
	|FROM
	|	AccumulationRegister.RoomInventory.BalanceAndTurnovers(&qPeriodFrom, &qPeriodTo, Day, RegisterRecordsAndPeriodBoundaries, Hotel IN HIERARCHY (&qHotel)) AS RoomInventoryBalanceAndTurnovers
	|GROUP BY
	|	RoomInventoryBalanceAndTurnovers.Period
	|ORDER BY
	|	Period";
	#КонецУдаления
	vQry.SetParameter("qPeriodFrom", vBegOfPeriod);
	vQry.SetParameter("qPeriodTo", vEndOfPeriod);
	vQry.SetParameter("qHotel", pCurrentHotel);
	vQryResult = vQry.Execute().Unload();

	vResources = "TotalRoomsClosingBalance, TotalBedsClosingBalance, RoomsBlockedClosingBalance, BedsBlockedClosingBalance";
	TotalPerDay = tcDesktop_GetQResultTableTotals(TotalPerDay, vQryResult, vQryResult, vResources);
	vTotalRooms = cmCastToNumber(TotalPerDay.TotalRoomsClosingBalance);
	vTotalBeds = cmCastToNumber(TotalPerDay.TotalBedsClosingBalance);	
	vBlockedRooms = cmCastToNumber(TotalPerDay.RoomsBlockedClosingBalance);
	vBlockedBeds = cmCastToNumber(TotalPerDay.BedsBlockedClosingBalance);
	vRoomsForSale = vTotalRooms - vBlockedRooms;
	vBedsForSale = vTotalBeds - vBlockedBeds;
	
	// Run query to get number of blocked rooms per room block types
	
	#Вставка
	Если НомернойФонд.Пустая() Тогда
		vQry = New Query();
		vQry.Text = 
		"SELECT Разрешенные
		|	RoomBlocksBalanceAndTurnovers.RoomBlockType AS RoomBlockType,
		|	RoomBlocksBalanceAndTurnovers.Period AS Period,
		|	SUM(RoomBlocksBalanceAndTurnovers.RoomsBlockedClosingBalance) AS RoomsBlockedClosingBalance,
		|	SUM(RoomBlocksBalanceAndTurnovers.BedsBlockedClosingBalance) AS BedsBlockedClosingBalance
		|FROM
		|	AccumulationRegister.RoomBlocks.BalanceAndTurnovers(&qPeriodFrom, &qPeriodTo, Day, RegisterRecordsAndPeriodBoundaries, Hotel IN HIERARCHY (&qHotel)) AS RoomBlocksBalanceAndTurnovers
		|
		|GROUP BY
		|	RoomBlocksBalanceAndTurnovers.RoomBlockType,
		|	RoomBlocksBalanceAndTurnovers.Period
		|
		|ORDER BY
		|	RoomBlocksBalanceAndTurnovers.RoomBlockType.SortCode,
		|	Period";
	Иначе
		vQry = New Query();
		vQry.МенеджерВременныхТаблиц = МенеджерВТ;
		vQry.Text = 
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	RoomBlocksBalanceAndTurnovers.RoomBlockType КАК RoomBlockType,
		|	RoomBlocksBalanceAndTurnovers.Период КАК Period,
		|	СУММА(RoomBlocksBalanceAndTurnovers.RoomsBlockedКонечныйОстаток) КАК RoomsBlockedClosingBalance,
		|	СУММА(RoomBlocksBalanceAndTurnovers.BedsBlockedКонечныйОстаток) КАК BedsBlockedClosingBalance
		|ИЗ
		|	РегистрНакопления.RoomBlocks.ОстаткиИОбороты(
		|			&qPeriodFrom,
		|			&qPeriodTo,
		|			Day,
		|			RegisterRecordsAndPeriodBoundaries,
		|			Hotel В ИЕРАРХИИ (&qHotel)
		|				И Room В
		|					(ВЫБРАТЬ
		|						Т.Номер
		|					ИЗ
		|						ВТ_Номера КАК Т)) КАК RoomBlocksBalanceAndTurnovers
		//|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_Номера КАК ВТ_Номера
		//|		ПО RoomBlocksBalanceAndTurnovers.Room = ВТ_Номера.Номер
		|
		|СГРУППИРОВАТЬ ПО
		|	RoomBlocksBalanceAndTurnovers.RoomBlockType,
		|	RoomBlocksBalanceAndTurnovers.Период
		|
		|УПОРЯДОЧИТЬ ПО
		|	RoomBlocksBalanceAndTurnovers.RoomBlockType.SortCode,
		|	Period";
		
	КонецЕсли;
	#КонецВставки
	
	#Удаление
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	RoomBlocksBalanceAndTurnovers.RoomBlockType AS RoomBlockType,
	|	RoomBlocksBalanceAndTurnovers.Period AS Period,
	|	SUM(RoomBlocksBalanceAndTurnovers.RoomsBlockedClosingBalance) AS RoomsBlockedClosingBalance,
	|	SUM(RoomBlocksBalanceAndTurnovers.BedsBlockedClosingBalance) AS BedsBlockedClosingBalance
	|FROM
	|	AccumulationRegister.RoomBlocks.BalanceAndTurnovers(&qPeriodFrom, &qPeriodTo, Day, RegisterRecordsAndPeriodBoundaries, Hotel IN HIERARCHY (&qHotel)) AS RoomBlocksBalanceAndTurnovers
	|
	|GROUP BY
	|	RoomBlocksBalanceAndTurnovers.RoomBlockType,
	|	RoomBlocksBalanceAndTurnovers.Period
	|
	|ORDER BY
	|	RoomBlocksBalanceAndTurnovers.RoomBlockType.SortCode,
	|	Period";
	#КонецУдаления
	vQry.SetParameter("qPeriodFrom", vBegOfPeriod);
	vQry.SetParameter("qPeriodTo", vEndOfPeriod);
	vQry.SetParameter("qHotel", pCurrentHotel);
	vQryResult = vQry.Execute().Unload();

	// Get list of room block types
	vSpecRoomsBlocked = 0;
	vSpecBedsBlocked = 0;
	vRoomBlockTypes = vQryResult.Copy();
	vRoomBlockTypes.GroupBy("RoomBlockType", );
	If vQryResult.Count()>0 Then
		// Put room blocks per room block type
		For Each vRow In vRoomBlockTypes Do
			vRoomBlockType = vRow.RoomBlockType;

			// Get records for the current room block type only
			vQrySubresult = vQryResult.FindRows(New Structure("RoomBlockType", vRoomBlockType));
			TotalPerDay = tcDesktop_GetQResultTableTotals(TotalPerDay, vQrySubresult, vQryResult, "RoomsBlockedClosingBalance, BedsBlockedClosingBalance");

			If vInRooms Then
				vBlockedRooms = cmCastToNumber(TotalPerDay.RoomsBlockedClosingBalance);					
				If vRoomBlockType.AddToRoomsRentedInSummaryIndexes Then
					vSpecRoomsBlocked = vSpecRoomsBlocked + cmCastToNumber(TotalPerDay.RoomsBlockedClosingBalance);
				EndIf;
			Else
				vBlockedBeds = cmCastToNumber(TotalPerDay.BedsBlockedClosingBalance);				
				If vRoomBlockType.AddToRoomsRentedInSummaryIndexes Then
					vSpecBedsBlocked = vSpecBedsBlocked + cmCastToNumber(TotalPerDay.BedsBlockedClosingBalance);
				EndIf;
			EndIf;
		EndDo;
	EndIf;	

	// Run query to get room sales
	#Вставка
	Если НомернойФонд.Пустая() Тогда
		vQry = New Query();
		vQry.Text = 
		"SELECT разрешенные
		|	RoomSalesTurnovers.Period AS Period,
		|	RoomSalesTurnovers.RoomRate.IsComplimentary AS RoomRateIsComplimentary,
		|	RoomSalesTurnovers.RoomRate.IsHouseUse AS RoomRateIsHouseUse,
		|	SUM(RoomSalesTurnovers.SalesTurnover) AS SalesTurnover,
		|	SUM(RoomSalesTurnovers.SalesWithoutVATTurnover) AS SalesWithoutVATTurnover,
		|	SUM(RoomSalesTurnovers.RoomRevenueTurnover) AS RoomRevenueTurnover,
		|	SUM(RoomSalesTurnovers.RoomRevenueWithoutVATTurnover) AS RoomRevenueWithoutVATTurnover,
		|	SUM(RoomSalesTurnovers.RoomsRentedTurnover) AS RoomsRentedTurnover,
		|	SUM(RoomSalesTurnovers.BedsRentedTurnover) AS BedsRentedTurnover
		|FROM
		|	AccumulationRegister.Sales.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Hotel IN HIERARCHY (&qHotel)) AS RoomSalesTurnovers
		|GROUP BY
		|	RoomSalesTurnovers.Period,
		|	RoomSalesTurnovers.RoomRate.IsComplimentary,
		|	RoomSalesTurnovers.RoomRate.IsHouseUse
		|ORDER BY
		|	Period,
		|	RoomRateIsComplimentary,
		|	RoomRateIsHouseUse";
	Иначе
		vQry = New Query();
		vQry.МенеджерВременныхТаблиц = МенеджерВТ;
		vQry.Text = 
		"SELECT разрешенные
		|	RoomSalesTurnovers.Period AS Period,
		|	RoomSalesTurnovers.RoomRate.IsComplimentary AS RoomRateIsComplimentary,
		|	RoomSalesTurnovers.RoomRate.IsHouseUse AS RoomRateIsHouseUse,
		|	SUM(RoomSalesTurnovers.SalesTurnover) AS SalesTurnover,
		|	SUM(RoomSalesTurnovers.SalesWithoutVATTurnover) AS SalesWithoutVATTurnover,
		|	SUM(RoomSalesTurnovers.RoomRevenueTurnover) AS RoomRevenueTurnover,
		|	SUM(RoomSalesTurnovers.RoomRevenueWithoutVATTurnover) AS RoomRevenueWithoutVATTurnover,
		|	SUM(RoomSalesTurnovers.RoomsRentedTurnover) AS RoomsRentedTurnover,
		|	SUM(RoomSalesTurnovers.BedsRentedTurnover) AS BedsRentedTurnover
		|FROM
		|	AccumulationRegister.Sales.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Hotel IN HIERARCHY (&qHotel)
		|				И Room В
		|					(ВЫБРАТЬ
		|						Т.Номер
		|					ИЗ
		|						ВТ_Номера КАК Т)) AS RoomSalesTurnovers
		//|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_Номера КАК ВТ_Номера
		//|		ПО RoomSalesTurnovers.Room = ВТ_Номера.Номер
		|GROUP BY
		|	RoomSalesTurnovers.Period,
		|	RoomSalesTurnovers.RoomRate.IsComplimentary,
		|	RoomSalesTurnovers.RoomRate.IsHouseUse
		|ORDER BY
		|	Period,
		|	RoomRateIsComplimentary,
		|	RoomRateIsHouseUse";
	КонецЕсли;	
	#КонецВставки
	
	#Удаление
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	RoomSalesTurnovers.Period AS Period,
	|	RoomSalesTurnovers.RoomRate.IsComplimentary AS RoomRateIsComplimentary,
	|	RoomSalesTurnovers.RoomRate.IsHouseUse AS RoomRateIsHouseUse,
	|	SUM(RoomSalesTurnovers.SalesTurnover) AS SalesTurnover,
	|	SUM(RoomSalesTurnovers.SalesWithoutVATTurnover) AS SalesWithoutVATTurnover,
	|	SUM(RoomSalesTurnovers.RoomRevenueTurnover) AS RoomRevenueTurnover,
	|	SUM(RoomSalesTurnovers.RoomRevenueWithoutVATTurnover) AS RoomRevenueWithoutVATTurnover,
	|	SUM(RoomSalesTurnovers.RoomsRentedTurnover) AS RoomsRentedTurnover,
	|	SUM(RoomSalesTurnovers.BedsRentedTurnover) AS BedsRentedTurnover
	|FROM
	|	AccumulationRegister.Sales.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Hotel IN HIERARCHY (&qHotel)) AS RoomSalesTurnovers
	|GROUP BY
	|	RoomSalesTurnovers.Period,
	|	RoomSalesTurnovers.RoomRate.IsComplimentary,
	|	RoomSalesTurnovers.RoomRate.IsHouseUse
	|ORDER BY
	|	Period,
	|	RoomRateIsComplimentary,
	|	RoomRateIsHouseUse";
	#КонецУдаления
	
	vQry.SetParameter("qPeriodFrom", vBegOfPeriod);
	vQry.SetParameter("qPeriodTo", vEndOfPeriod);
	vQry.SetParameter("qHotel", pCurrentHotel);
	vQryResult = vQry.Execute().Unload();

	// Add forecast sales if period is set in the future
	If vEndOfPeriod >= EndOfDay(CurrentSessionDate() - 24*3600) Then
		
		#Вставка
		Если НомернойФонд.Пустая() Тогда
			vQry = New Query();
			vQry.Text = 
			"SELECT Разрешенные
			|	RoomSalesForecastTurnovers.Period AS Period,
			|	RoomSalesForecastTurnovers.RoomRate.IsComplimentary AS RoomRateIsComplimentary,
			|	RoomSalesForecastTurnovers.RoomRate.IsHouseUse AS RoomRateIsHouseUse,
			|	SUM(RoomSalesForecastTurnovers.SalesTurnover) AS SalesTurnover,
			|	SUM(RoomSalesForecastTurnovers.SalesWithoutVATTurnover) AS SalesWithoutVATTurnover,
			|	SUM(RoomSalesForecastTurnovers.RoomRevenueTurnover) AS RoomRevenueTurnover,
			|	SUM(RoomSalesForecastTurnovers.RoomRevenueWithoutVATTurnover) AS RoomRevenueWithoutVATTurnover,
			|	SUM(RoomSalesForecastTurnovers.RoomsRentedTurnover) AS RoomsRentedTurnover,
			|	SUM(RoomSalesForecastTurnovers.BedsRentedTurnover) AS BedsRentedTurnover
			|FROM
			|	AccumulationRegister.SalesForecast.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Hotel IN HIERARCHY (&qHotel)) AS RoomSalesForecastTurnovers
			|GROUP BY
			|	RoomSalesForecastTurnovers.Period,
			|	RoomSalesForecastTurnovers.RoomRate.IsComplimentary,
			|	RoomSalesForecastTurnovers.RoomRate.IsHouseUse
			|ORDER BY
			|	Period,
			|	RoomRateIsComplimentary,
			|	RoomRateIsHouseUse";
			
		Иначе
			vQry = New Query();
			vQry.МенеджерВременныхТаблиц = МенеджерВТ;
			vQry.Text = 
			"SELECT  Разрешенные
			|	RoomSalesForecastTurnovers.Period AS Period,
			|	RoomSalesForecastTurnovers.RoomRate.IsComplimentary AS RoomRateIsComplimentary,
			|	RoomSalesForecastTurnovers.RoomRate.IsHouseUse AS RoomRateIsHouseUse,
			|	SUM(RoomSalesForecastTurnovers.SalesTurnover) AS SalesTurnover,
			|	SUM(RoomSalesForecastTurnovers.SalesWithoutVATTurnover) AS SalesWithoutVATTurnover,
			|	SUM(RoomSalesForecastTurnovers.RoomRevenueTurnover) AS RoomRevenueTurnover,
			|	SUM(RoomSalesForecastTurnovers.RoomRevenueWithoutVATTurnover) AS RoomRevenueWithoutVATTurnover,
			|	SUM(RoomSalesForecastTurnovers.RoomsRentedTurnover) AS RoomsRentedTurnover,
			|	SUM(RoomSalesForecastTurnovers.BedsRentedTurnover) AS BedsRentedTurnover
			|FROM
			|	AccumulationRegister.SalesForecast.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Hotel IN HIERARCHY (&qHotel)
			|				И Room В
			|					(ВЫБРАТЬ
			|						Т.Номер
			|					ИЗ
			|						ВТ_Номера КАК Т)) AS RoomSalesForecastTurnovers
			//|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_Номера КАК ВТ_Номера
			//|		ПО RoomSalesForecastTurnovers.Room = ВТ_Номера.Номер
			|GROUP BY
			|	RoomSalesForecastTurnovers.Period,
			|	RoomSalesForecastTurnovers.RoomRate.IsComplimentary,
			|	RoomSalesForecastTurnovers.RoomRate.IsHouseUse
			|ORDER BY
			|	Period,
			|	RoomRateIsComplimentary,
			|	RoomRateIsHouseUse";			
		КонецЕсли;	
		#КонецВставки
		
		#Удаление
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	RoomSalesForecastTurnovers.Period AS Period,
		|	RoomSalesForecastTurnovers.RoomRate.IsComplimentary AS RoomRateIsComplimentary,
		|	RoomSalesForecastTurnovers.RoomRate.IsHouseUse AS RoomRateIsHouseUse,
		|	SUM(RoomSalesForecastTurnovers.SalesTurnover) AS SalesTurnover,
		|	SUM(RoomSalesForecastTurnovers.SalesWithoutVATTurnover) AS SalesWithoutVATTurnover,
		|	SUM(RoomSalesForecastTurnovers.RoomRevenueTurnover) AS RoomRevenueTurnover,
		|	SUM(RoomSalesForecastTurnovers.RoomRevenueWithoutVATTurnover) AS RoomRevenueWithoutVATTurnover,
		|	SUM(RoomSalesForecastTurnovers.RoomsRentedTurnover) AS RoomsRentedTurnover,
		|	SUM(RoomSalesForecastTurnovers.BedsRentedTurnover) AS BedsRentedTurnover
		|FROM
		|	AccumulationRegister.SalesForecast.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Hotel IN HIERARCHY (&qHotel)) AS RoomSalesForecastTurnovers
		|GROUP BY
		|	RoomSalesForecastTurnovers.Period,
		|	RoomSalesForecastTurnovers.RoomRate.IsComplimentary,
		|	RoomSalesForecastTurnovers.RoomRate.IsHouseUse
		|ORDER BY
		|	Period,
		|	RoomRateIsComplimentary,
		|	RoomRateIsHouseUse";
		#КонецУдаления
		
		vQry.SetParameter("qPeriodFrom", vBegOfPeriod);
		vQry.SetParameter("qPeriodTo", vEndOfPeriod);
		vQry.SetParameter("qHotel", pCurrentHotel);
		vForecastQryResult = vQry.Execute().Unload();

		// Merge forecast sales with real ones
		For Each vForecastRow In vForecastQryResult Do
			vFound = False;
			For Each vRow In vQryResult Do
				If vRow.Period = vForecastRow.Period And
					vRow.RoomRateIsComplimentary = vForecastRow.RoomRateIsComplimentary And 
					vRow.RoomRateIsHouseUse = vForecastRow.RoomRateIsHouseUse Then
					vFound = True;
					Break;
				EndIf;
			EndDo;
			If Not vFound Then
				vRow = vQryResult.Add();
				vRow.Period = vForecastRow.Period;
				vRow.RoomRateIsComplimentary = vForecastRow.RoomRateIsComplimentary;
				vRow.RoomRateIsHouseUse = vForecastRow.RoomRateIsHouseUse;
				vRow.SalesTurnover = 0;
				vRow.SalesWithoutVATTurnover = 0;
				vRow.RoomRevenueTurnover = 0;
				vRow.RoomRevenueWithoutVATTurnover = 0;
				vRow.RoomsRentedTurnover = 0;
				vRow.BedsRentedTurnover = 0;
			EndIf;
			vRow.SalesTurnover = vRow.SalesTurnover + vForecastRow.SalesTurnover;
			vRow.SalesWithoutVATTurnover = vRow.SalesWithoutVATTurnover + vForecastRow.SalesWithoutVATTurnover;
			vRow.RoomRevenueTurnover = vRow.RoomRevenueTurnover + vForecastRow.RoomRevenueTurnover;
			vRow.RoomRevenueWithoutVATTurnover = vRow.RoomRevenueWithoutVATTurnover + vForecastRow.RoomRevenueWithoutVATTurnover;
			vRow.RoomsRentedTurnover = vRow.RoomsRentedTurnover + vForecastRow.RoomsRentedTurnover;
			vRow.BedsRentedTurnover = vRow.BedsRentedTurnover + vForecastRow.BedsRentedTurnover;
		EndDo;
	EndIf;	

	vResources = "SalesTurnover, SalesWithoutVATTurnover, RoomRevenueTurnover, RoomRevenueWithoutVATTurnover, RoomsRentedTurnover, BedsRentedTurnover";

	// Split table to total and complimentary only
	vQryResultComplArray = vQryResult.Copy().FindRows(New Structure("RoomRateIsComplimentary", True));
	vQryResult.GroupBy("Period", vResources);
	vQryResultCompl = vQryResult.CopyColumns();
	For Each vRow In vQryResultComplArray Do
		vTabRow = vQryResultCompl.Add();
		FillPropertyValues(vTabRow, vRow);
	EndDo;
	vQryResultCompl.GroupBy("Period", vResources);

	// Put rooms rented
	TotalPerDay = tcDesktop_GetQResultTableTotals(TotalPerDay, vQryResult, vQryResult, vResources);
	If vInRooms Then
		vRoomsRented = cmCastToNumber(TotalPerDay.RoomsRentedTurnover);
	Else
		vBedsRented = cmCastToNumber(TotalPerDay.BedsRentedTurnover);
	EndIf;	
	// Put occupation percents	
	If vInRooms Then
		vResult = Round(?((vRoomsForSale + vSpecRoomsBlocked) <> 0, 100*(vRoomsRented + vSpecRoomsBlocked)/(vRoomsForSale + vSpecRoomsBlocked), 0), 2);
	Else
		vResult = Round(?((vBedsForSale + vSpecBedsBlocked) <> 0, 100*(vBedsRented + vSpecBedsBlocked)/(vBedsForSale + vSpecBedsBlocked), 0), 2);
	EndIf;

	PutToTempStorage(vResult,pTempStorageAddress);
EndProcedure

&ChangeAndValidate("tcDesktop_GetInHouse")
Procedure Расш1_tcDesktop_GetInHouse(pTempStorageAddress, pCurrentHotel, pDate) Export
	
	#Вставка
	НомернойФонд = pCurrentHotel.НомернойФонд;
	pCurrentHotel = pCurrentHotel.CurrentHotel;
	
	Если НомернойФонд.Пустая() Тогда
		vQry = New Query();
		vQry.Text = 
		"SELECT разрешенные
		|	COUNT(DISTINCT Accommodation.Room) AS Rooms
		|FROM
		|	Document.Accommodation AS Accommodation
		|WHERE
		|	Accommodation.Posted
		|	AND Accommodation.AccommodationStatus.IsInHouse
		|	AND Accommodation.AccommodationStatus.IsActive
		|	AND Accommodation.Hotel = &qHotel";
		
	Иначе
		vQry = New Query();
		vQry.Text = 
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ Accommodation.Room) КАК Rooms
		|ИЗ
		|	Документ.Accommodation КАК Accommodation
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.Расш1_СоставНомерногоФонда КАК Расш1_СоставНомерногоФонда
		|		ПО (Accommodation.Room = Расш1_СоставНомерногоФонда.Номер
		|				И Расш1_СоставНомерногоФонда.НомернойФонд = &НомернойФонд)
		|ГДЕ
		|	Accommodation.Проведен
		|	И Accommodation.AccommodationStatus.IsInHouse
		|	И Accommodation.AccommodationStatus.IsActive
		|	И Accommodation.Hotel = &qHotel";
		vQry.SetParameter("НомернойФонд", НомернойФонд);
	КонецЕсли;
	#КонецВставки

	#Удаление
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	COUNT(DISTINCT Accommodation.Room) AS Rooms
	|FROM
	|	Document.Accommodation AS Accommodation
	|WHERE
	|	Accommodation.Posted
	|	AND Accommodation.AccommodationStatus.IsInHouse
	|	AND Accommodation.AccommodationStatus.IsActive
	|	AND Accommodation.Hotel = &qHotel";
	#КонецУдаления

	vQry.SetParameter("qHotel", pCurrentHotel);
	vInvResult = vQry.Execute();

	vResult = New Structure("InHouseGuests, InHouseRooms",0 ,0);

	If Not vInvResult.IsEmpty() Then
		vRes = vInvResult.Select();
		vRes.Next();
		vResult.InHouseRooms 	= vRes.Rooms;
	EndIf;

	PutToTempStorage(vResult,pTempStorageAddress);
EndProcedure

&ChangeAndValidate("tcDesktop_GetCheckInOutCount")
Procedure Расш1_tcDesktop_GetCheckInOutCount(pTempStorageAddress, pCurrentHotel)
	
	#Вставка
	НомернойФонд = pCurrentHotel.НомернойФонд;
	pCurrentHotel = pCurrentHotel.CurrentHotel;
	#КонецВставки

	vResult = new Structure("CheckInGuests, CheckInRooms, CheckOutGuests, CheckOutRooms", 0, 0, 0, 0);

	vDate = tcOnServer.GetForecastStartDate(pCurrentHotel);
	
	#Вставка
	Если НомернойФонд.Пустая() Тогда
		vQry = New Query;
		vQry.Text =
		"SELECT  Разрешенные
		|	SUM(NestedSelect.CheckOutRooms) AS CheckOutRooms,
		|	SUM(NestedSelect.CheckOutGuests) AS CheckOutGuests,
		|	SUM(NestedSelect.CheckInGuests) AS CheckInGuests,
		|	SUM(NestedSelect.CheckInRooms) AS CheckInRooms
		|FROM
		|	(SELECT
		|		SUM(RoomInventory.InHouseRooms) AS CheckOutRooms,
		|		SUM(RoomInventory.InHouseGuests) AS CheckOutGuests,
		|		SUM(0) AS CheckInGuests,
		|		SUM(0) AS CheckInRooms
		|	FROM
		|		(SELECT
		|			CASE
		|				WHEN SUM(RoomInventoryMovements.ExpectedRoomsCheckedOut) < 0
		|					THEN 0
		|				ELSE SUM(RoomInventoryMovements.ExpectedRoomsCheckedOut)
		|			END AS InHouseRooms,
		|			SUM(RoomInventoryMovements.ExpectedBedsCheckedOut) AS InHouseBeds,
		|			SUM(RoomInventoryMovements.ExpectedGuestsCheckedOut) AS InHouseGuests
		|		FROM
		|			AccumulationRegister.RoomInventory AS RoomInventoryMovements
		|		WHERE
		|			RoomInventoryMovements.IsAccommodation
		|			AND RoomInventoryMovements.RecordType = VALUE(AccumulationRecordType.Receipt)
		|			AND RoomInventoryMovements.Hotel IN HIERARCHY(&qHotel)
		|			AND RoomInventoryMovements.Period <= &qPeriodTo
		|			AND RoomInventoryMovements.Period = RoomInventoryMovements.CheckOutDate
		|			AND RoomInventoryMovements.IsInHouse
		|			AND RoomInventoryMovements.IsCheckOut) AS RoomInventory
		|	
		|	UNION ALL
		|	
		|	SELECT
		|		0,
		|		0,
		|		SUM(ExpectedCheckInMovements.GuestsReserved),
		|		SUM(ExpectedCheckInMovements.RoomsReserved)
		|	FROM
		|		AccumulationRegister.RoomInventory AS ExpectedCheckInMovements
		|	WHERE
		|		ExpectedCheckInMovements.IsReservation
		|		AND ExpectedCheckInMovements.RecordType = VALUE(AccumulationRecordType.Expense)
		|		AND ExpectedCheckInMovements.Hotel IN HIERARCHY(&qHotel)
		|		AND ExpectedCheckInMovements.Period < &qPeriodTo
		|		AND ExpectedCheckInMovements.Period = ExpectedCheckInMovements.CheckInDate) AS NestedSelect";
		
	Иначе
		vQry = New Query;
		vQry.Text =
		"ВЫБРАТЬ разрешенные
		|	СУММА(NestedSelect.CheckOutRooms) КАК CheckOutRooms,
		|	СУММА(NestedSelect.CheckOutGuests) КАК CheckOutGuests,
		|	СУММА(NestedSelect.CheckInGuests) КАК CheckInGuests,
		|	СУММА(NestedSelect.CheckInRooms) КАК CheckInRooms
		|ИЗ
		|	(ВЫБРАТЬ
		|		СУММА(RoomInventory.InHouseRooms) КАК CheckOutRooms,
		|		СУММА(RoomInventory.InHouseGuests) КАК CheckOutGuests,
		|		СУММА(0) КАК CheckInGuests,
		|		СУММА(0) КАК CheckInRooms
		|	ИЗ
		|		(ВЫБРАТЬ
		|			ВЫБОР
		|				КОГДА СУММА(RoomInventoryMovements.ExpectedRoomsCheckedOut) < 0
		|					ТОГДА 0
		|				ИНАЧЕ СУММА(RoomInventoryMovements.ExpectedRoomsCheckedOut)
		|			КОНЕЦ КАК InHouseRooms,
		|			СУММА(RoomInventoryMovements.ExpectedBedsCheckedOut) КАК InHouseBeds,
		|			СУММА(RoomInventoryMovements.ExpectedGuestsCheckedOut) КАК InHouseGuests
		|		ИЗ
		|			РегистрНакопления.RoomInventory КАК RoomInventoryMovements
		|				ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.Расш1_СоставНомерногоФонда КАК Расш1_СоставНомерногоФонда
		|				ПО (RoomInventoryMovements.Room = Расш1_СоставНомерногоФонда.Номер
		|						И Расш1_СоставНомерногоФонда.НомернойФонд = &НомернойФонд)
		|		ГДЕ
		|			RoomInventoryMovements.IsAccommodation
		|			И RoomInventoryMovements.ВидДвижения = ЗНАЧЕНИЕ(AccumulationRecordType.Receipt)
		|			И RoomInventoryMovements.Hotel В ИЕРАРХИИ(&qHotel)
		|			И RoomInventoryMovements.Период <= &qPeriodTo
		|			И RoomInventoryMovements.Период = RoomInventoryMovements.CheckOutDate
		|			И RoomInventoryMovements.IsInHouse
		|			И RoomInventoryMovements.IsCheckOut) КАК RoomInventory
		|	
		|	ОБЪЕДИНИТЬ ВСЕ
		|	
		|	ВЫБРАТЬ
		|		0,
		|		0,
		|		СУММА(ExpectedCheckInMovements.GuestsReserved),
		|		СУММА(ExpectedCheckInMovements.RoomsReserved)
		|	ИЗ
		|		РегистрНакопления.RoomInventory КАК ExpectedCheckInMovements
		|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.Расш1_СоставНомерногоФонда КАК Расш1_СоставНомерногоФонда
		|			ПО (ExpectedCheckInMovements.Room = Расш1_СоставНомерногоФонда.Номер
		|					И Расш1_СоставНомерногоФонда.НомернойФонд = &НомернойФонд)
		|	ГДЕ
		|		ExpectedCheckInMovements.IsReservation
		|		И ExpectedCheckInMovements.ВидДвижения = ЗНАЧЕНИЕ(AccumulationRecordType.Expense)
		|		И ExpectedCheckInMovements.Hotel В ИЕРАРХИИ(&qHotel)
		|		И ExpectedCheckInMovements.Период < &qPeriodTo
		|		И ExpectedCheckInMovements.Период = ExpectedCheckInMovements.CheckInDate) КАК NestedSelect";
		vQry.SetParameter("НомернойФонд", НомернойФонд);
	КонецЕсли;
	#КонецВставки
	
	#Удаление
	vQry = New Query;
	vQry.Text =
	"SELECT
	|	SUM(NestedSelect.CheckOutRooms) AS CheckOutRooms,
	|	SUM(NestedSelect.CheckOutGuests) AS CheckOutGuests,
	|	SUM(NestedSelect.CheckInGuests) AS CheckInGuests,
	|	SUM(NestedSelect.CheckInRooms) AS CheckInRooms
	|FROM
	|	(SELECT
	|		SUM(RoomInventory.InHouseRooms) AS CheckOutRooms,
	|		SUM(RoomInventory.InHouseGuests) AS CheckOutGuests,
	|		SUM(0) AS CheckInGuests,
	|		SUM(0) AS CheckInRooms
	|	FROM
	|		(SELECT
	|			CASE
	|				WHEN SUM(RoomInventoryMovements.ExpectedRoomsCheckedOut) < 0
	|					THEN 0
	|				ELSE SUM(RoomInventoryMovements.ExpectedRoomsCheckedOut)
	|			END AS InHouseRooms,
	|			SUM(RoomInventoryMovements.ExpectedBedsCheckedOut) AS InHouseBeds,
	|			SUM(RoomInventoryMovements.ExpectedGuestsCheckedOut) AS InHouseGuests
	|		FROM
	|			AccumulationRegister.RoomInventory AS RoomInventoryMovements
	|		WHERE
	|			RoomInventoryMovements.IsAccommodation
	|			AND RoomInventoryMovements.RecordType = VALUE(AccumulationRecordType.Receipt)
	|			AND RoomInventoryMovements.Hotel IN HIERARCHY(&qHotel)
	|			AND RoomInventoryMovements.Period <= &qPeriodTo
	|			AND RoomInventoryMovements.Period = RoomInventoryMovements.CheckOutDate
	|			AND RoomInventoryMovements.IsInHouse
	|			AND RoomInventoryMovements.IsCheckOut) AS RoomInventory
	|	
	|	UNION ALL
	|	
	|	SELECT
	|		0,
	|		0,
	|		SUM(ExpectedCheckInMovements.GuestsReserved),
	|		SUM(ExpectedCheckInMovements.RoomsReserved)
	|	FROM
	|		AccumulationRegister.RoomInventory AS ExpectedCheckInMovements
	|	WHERE
	|		ExpectedCheckInMovements.IsReservation
	|		AND ExpectedCheckInMovements.RecordType = VALUE(AccumulationRecordType.Expense)
	|		AND ExpectedCheckInMovements.Hotel IN HIERARCHY(&qHotel)
	|		AND ExpectedCheckInMovements.Period < &qPeriodTo
	|		AND ExpectedCheckInMovements.Period = ExpectedCheckInMovements.CheckInDate) AS NestedSelect";
	#КонецУдаления
	
	vQry.SetParameter("qHotel", pCurrentHotel);
	vQry.SetParameter("qPeriodTo", EndOfDay(vDate));
	
	vResultQry = vQry.Execute().Select();
	While vResultQry.Next() Do
		//vResult.CheckInGuests		= vResultQry.CheckInGuests;
		vResult.CheckInRooms 		= vResultQry.CheckInRooms;
		//vResult.CheckOutGuests 		= vResultQry.CheckOutGuests;
		vResult.CheckOutRooms 		= vResultQry.CheckOutRooms;
	EndDo;

	PutToTempStorage(vResult,pTempStorageAddress);
EndProcedure
