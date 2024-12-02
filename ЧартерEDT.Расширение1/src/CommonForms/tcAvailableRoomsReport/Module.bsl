
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

&НаСервереБезКонтекста
Функция ПроверитьДоступностьВсегоНомерногоФонда()
	Возврат SessionParameters.ВсеНомераДоступны; 	
КонецФункции

&НаКлиенте
Процедура Расш1_НомернойФондПриИзмененииПосле(Элемент)
	
	BuildReport();
	
КонецПроцедуры

&AtServer
&ChangeAndValidate("FillAvailabilityBreakdownAtServer")
Procedure Расш1_FillAvailabilityBreakdownAtServer()
	
	#Вставка
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
	
	AvailabilityByHours.Clear();
	AvailabilityBreakdown.GetItems().Clear();
	// Do checks
	If Not ValueIsFilled(CurDate) Then
		Items.AvailabilityByHoursGroup.Visible = False;
		Items.AvailabilityBreakdownGroup.Visible = False;
		Return;
	EndIf;
	Items.AvailabilityByHoursGroup.Visible = True;
	Items.AvailabilityBreakdownGroup.Visible = True;
	// Reference hour
	vShiftInSeconds = ?(ValueIsFilled(RoomRate), -(RoomRate.ReferenceHour - BegOfDay(RoomRate.ReferenceHour)), -43200);
	vRoomQuotaIsSet = ValueIsFilled(RoomQuota);
	vDoWriteOff = ?(ValueIsFilled(RoomQuota), RoomQuota.DoWriteOff, False);
	vPeriodFrom = cm1SecondShift(BegOfDay(CurDate) - vShiftInSeconds);
	vPeriodTo = cm0SecondShift(vPeriodFrom + 24*3600);
	// Get data for the breakdown by hours
	
	#Вставка
	Если НомернойФонд.Пустая() Тогда
		vQry = New Query();
		vQry.Text = 
		"SELECT Разрешенные
		|	BEGINOFPERIOD(RoomInventoryBalanceAndTurnovers.Period, DAY) AS RealDate,
		|	HOUR(RoomInventoryBalanceAndTurnovers.Period) + 1 AS Hour,
		|	RoomInventoryBalanceAndTurnovers.RoomType AS RoomType,
		|	RoomInventoryBalanceAndTurnovers.CounterClosingBalance AS Counter,
		|	RoomInventoryBalanceAndTurnovers.TotalRoomsClosingBalance AS TotalRooms,
		|	RoomInventoryBalanceAndTurnovers.TotalBedsClosingBalance AS TotalBeds,
		|	RoomInventoryBalanceAndTurnovers.RoomsVacantClosingBalance AS RoomsVacant,
		|	RoomInventoryBalanceAndTurnovers.BedsVacantClosingBalance AS BedsVacant
		|FROM
		|	AccumulationRegister.RoomInventory.BalanceAndTurnovers(
		|			&qPeriodFrom,
		|			&qPeriodTo,
		|			HOUR,
		|			RegisterRecordsAndPeriodBoundaries,
		|			Hotel IN HIERARCHY (&qHotel)
		|				AND RoomType IN HIERARCHY (&qRoomType)
		|				AND NOT RoomType.IsVirtual
		|				AND NOT RoomType.DoesNotAffectRoomRevenueStatistics) AS RoomInventoryBalanceAndTurnovers
		|
		|ORDER BY
		|	RealDate,
		|	Hour";
		
	Иначе
		vQry = New Query();
		vQry.МенеджерВременныхТаблиц = МенеджерВТ;
		vQry.Text = 
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	НАЧАЛОПЕРИОДА(RoomInventoryBalanceAndTurnovers.Период, ДЕНЬ) КАК RealDate,
		|	ЧАС(RoomInventoryBalanceAndTurnovers.Период) + 1 КАК Hour,
		|	RoomInventoryBalanceAndTurnovers.RoomType КАК RoomType,
		|	RoomInventoryBalanceAndTurnovers.CounterКонечныйОстаток КАК Counter,
		|	RoomInventoryBalanceAndTurnovers.TotalRoomsКонечныйОстаток КАК TotalRooms,
		|	RoomInventoryBalanceAndTurnovers.TotalBedsКонечныйОстаток КАК TotalBeds,
		|	RoomInventoryBalanceAndTurnovers.RoomsVacantКонечныйОстаток КАК RoomsVacant,
		|	RoomInventoryBalanceAndTurnovers.BedsVacantКонечныйОстаток КАК BedsVacant
		|ИЗ
		|	РегистрНакопления.RoomInventory.ОстаткиИОбороты(
		|			&qPeriodFrom,
		|			&qPeriodTo,
		|			HOUR,
		|			RegisterRecordsAndPeriodBoundaries,
		|			Hotel В ИЕРАРХИИ (&qHotel)
		|				И RoomType В ИЕРАРХИИ (&qRoomType)
		|				И НЕ RoomType.IsVirtual
		|				И НЕ RoomType.DoesNotAffectRoomRevenueStatistics
		|				И Room В
		|					(ВЫБРАТЬ
		|						Т.Номер
		|					ИЗ
		|						ВТ_Номера КАК Т)) КАК RoomInventoryBalanceAndTurnovers
		|
		|УПОРЯДОЧИТЬ ПО
		|	RealDate,
		|	Hour";
	КонецЕсли;
	#КонецВставки
	
	#Удаление
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	BEGINOFPERIOD(RoomInventoryBalanceAndTurnovers.Period, DAY) AS RealDate,
	|	HOUR(RoomInventoryBalanceAndTurnovers.Period) + 1 AS Hour,
	|	RoomInventoryBalanceAndTurnovers.RoomType AS RoomType,
	|	RoomInventoryBalanceAndTurnovers.CounterClosingBalance AS Counter,
	|	RoomInventoryBalanceAndTurnovers.TotalRoomsClosingBalance AS TotalRooms,
	|	RoomInventoryBalanceAndTurnovers.TotalBedsClosingBalance AS TotalBeds,
	|	RoomInventoryBalanceAndTurnovers.RoomsVacantClosingBalance AS RoomsVacant,
	|	RoomInventoryBalanceAndTurnovers.BedsVacantClosingBalance AS BedsVacant
	|FROM
	|	AccumulationRegister.RoomInventory.BalanceAndTurnovers(
	|			&qPeriodFrom,
	|			&qPeriodTo,
	|			HOUR,
	|			RegisterRecordsAndPeriodBoundaries,
	|			Hotel IN HIERARCHY (&qHotel)
	|				AND RoomType IN HIERARCHY (&qRoomType)
	|				AND NOT RoomType.IsVirtual
	|				AND NOT RoomType.DoesNotAffectRoomRevenueStatistics) AS RoomInventoryBalanceAndTurnovers
	|
	|ORDER BY
	|	RealDate,
	|	Hour";
	#КонецУдаления
	vQry.SetParameter("qHotel", CurHotel);
	vQry.SetParameter("qRoomType", CurRoomType);
	vQry.SetParameter("qShiftInSeconds", vShiftInSeconds);
	vQry.SetParameter("qPeriodFrom", vPeriodFrom);
	vQry.SetParameter("qPeriodTo", New Boundary(vPeriodTo, BoundaryType.Excluding));
	vInventoryAvailability = vQry.Execute().Unload();
	
	vAllotmentAvailability = New ValueTable();
	If vRoomQuotaIsSet Then
		#Вставка
		Если НомернойФонд.Пустая() Тогда
			vQry = New Query();
			vQry.Text = 
			"SELECT разрешенные
			|	BEGINOFPERIOD(RoomQuotaSalesBalanceAndTurnovers.Period, DAY) AS RealDate,
			|	HOUR(RoomQuotaSalesBalanceAndTurnovers.Period) + 1 AS Hour,
			|	RoomQuotaSalesBalanceAndTurnovers.RoomType AS RoomType,
			|	RoomQuotaSalesBalanceAndTurnovers.CounterClosingBalance AS AllotmentCounter,
			|	RoomQuotaSalesBalanceAndTurnovers.RoomsInQuotaClosingBalance AS RoomsInQuota,
			|	RoomQuotaSalesBalanceAndTurnovers.BedsInQuotaClosingBalance AS BedsInQuota,
			|	RoomQuotaSalesBalanceAndTurnovers.RoomsRemainsClosingBalance AS RoomsRemains,
			|	RoomQuotaSalesBalanceAndTurnovers.BedsRemainsClosingBalance AS BedsRemains
			|FROM
			|	AccumulationRegister.RoomQuotaSales.BalanceAndTurnovers(
			|			&qPeriodFrom,
			|			&qPeriodTo,
			|			HOUR,
			|			RegisterRecordsAndPeriodBoundaries,
			|			Hotel IN HIERARCHY (&qHotel)
			|				AND RoomType IN HIERARCHY (&qRoomType)
			|				AND NOT RoomType.IsVirtual
			|				AND NOT RoomType.DoesNotAffectRoomRevenueStatistics
			|				AND RoomQuota = &qRoomQuota) AS RoomQuotaSalesBalanceAndTurnovers
			|ORDER BY
			|	RealDate,
			|	Hour";
		Иначе
			vQry = New Query();
			vQry.МенеджерВременныхТаблиц = МенеджерВТ;
			vQry.Text = 
			"ВЫБРАТЬ РАЗРЕШЕННЫЕ
			|	НАЧАЛОПЕРИОДА(RoomQuotaSalesBalanceAndTurnovers.Период, ДЕНЬ) КАК RealDate,
			|	ЧАС(RoomQuotaSalesBalanceAndTurnovers.Период) + 1 КАК Hour,
			|	RoomQuotaSalesBalanceAndTurnovers.RoomType КАК RoomType,
			|	RoomQuotaSalesBalanceAndTurnovers.CounterКонечныйОстаток КАК AllotmentCounter,
			|	RoomQuotaSalesBalanceAndTurnovers.RoomsInQuotaКонечныйОстаток КАК RoomsInQuota,
			|	RoomQuotaSalesBalanceAndTurnovers.BedsInQuotaКонечныйОстаток КАК BedsInQuota,
			|	RoomQuotaSalesBalanceAndTurnovers.RoomsRemainsКонечныйОстаток КАК RoomsRemains,
			|	RoomQuotaSalesBalanceAndTurnovers.BedsRemainsКонечныйОстаток КАК BedsRemains
			|ИЗ
			|	РегистрНакопления.RoomQuotaSales.ОстаткиИОбороты(
			|			&qPeriodFrom,
			|			&qPeriodTo,
			|			HOUR,
			|			RegisterRecordsAndPeriodBoundaries,
			|			Hotel В ИЕРАРХИИ (&qHotel)
			|				И RoomType В ИЕРАРХИИ (&qRoomType)
			|				И НЕ RoomType.IsVirtual
			|				И НЕ RoomType.DoesNotAffectRoomRevenueStatistics
			|				И RoomQuota = &qRoomQuota
			|				И Room В
			|					(ВЫБРАТЬ
			|						Т.Номер
			|					ИЗ
			|						ВТ_Номера КАК Т)) КАК RoomQuotaSalesBalanceAndTurnovers
			|
			|УПОРЯДОЧИТЬ ПО
			|	RealDate,
			|	Hour";
			
		КонецЕсли;
		#КонецВставки
		
		#Удаление
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	BEGINOFPERIOD(RoomQuotaSalesBalanceAndTurnovers.Period, DAY) AS RealDate,
		|	HOUR(RoomQuotaSalesBalanceAndTurnovers.Period) + 1 AS Hour,
		|	RoomQuotaSalesBalanceAndTurnovers.RoomType AS RoomType,
		|	RoomQuotaSalesBalanceAndTurnovers.CounterClosingBalance AS AllotmentCounter,
		|	RoomQuotaSalesBalanceAndTurnovers.RoomsInQuotaClosingBalance AS RoomsInQuota,
		|	RoomQuotaSalesBalanceAndTurnovers.BedsInQuotaClosingBalance AS BedsInQuota,
		|	RoomQuotaSalesBalanceAndTurnovers.RoomsRemainsClosingBalance AS RoomsRemains,
		|	RoomQuotaSalesBalanceAndTurnovers.BedsRemainsClosingBalance AS BedsRemains
		|FROM
		|	AccumulationRegister.RoomQuotaSales.BalanceAndTurnovers(
		|			&qPeriodFrom,
		|			&qPeriodTo,
		|			HOUR,
		|			RegisterRecordsAndPeriodBoundaries,
		|			Hotel IN HIERARCHY (&qHotel)
		|				AND RoomType IN HIERARCHY (&qRoomType)
		|				AND NOT RoomType.IsVirtual
		|				AND NOT RoomType.DoesNotAffectRoomRevenueStatistics
		|				AND RoomQuota = &qRoomQuota) AS RoomQuotaSalesBalanceAndTurnovers
		|ORDER BY
		|	RealDate,
		|	Hour";
		#КонецУдаления
		vQry.SetParameter("qHotel", CurHotel);
		vQry.SetParameter("qRoomType", CurRoomType);
		vQry.SetParameter("qRoomQuota", RoomQuota);
		vQry.SetParameter("qShiftInSeconds", vShiftInSeconds);
		vQry.SetParameter("qPeriodFrom", vPeriodFrom);
		vQry.SetParameter("qPeriodTo", New Boundary(vPeriodTo, BoundaryType.Excluding));
		vAllotmentAvailability = vQry.Execute().Unload();
	EndIf;
	
	// Fill table with balances
	vRow = AvailabilityByHours.Add();
	If ValueIsFilled(CurRoomType) Then
		vRow.RoomType = CurRoomType;
	ElsIf ValueIsFilled(CurHotel) Then
		vRow.RoomType = CurHotel;
	Else
		vRow.RoomType = Undefined;
	EndIf;
	vRow.AccountingDate = BegOfDay(CurDate);
	
	vCurAvailability = 0;
	vCurHour = Hour(vPeriodFrom) + 1;
	vVacant = 0;
	vRemains = 0;
	For i = 1 To 24 Do
		Items["AvailabilityByHoursHour" + i].Title = Format(vCurHour, "ND=2; NFD=0; NZ=; NLZ=; NG=") + ":00";
		
		vCurAvailability = 0;
		vInventoryAvailabilityRow = vInventoryAvailability.Find(vCurHour, "Hour");
		If vInventoryAvailabilityRow <> Undefined Then
			If ShowInBeds Then
				vVacant = vInventoryAvailabilityRow.BedsVacant;
			Else
				vVacant = vInventoryAvailabilityRow.RoomsVacant;
			EndIf;
		EndIf;
		If vRoomQuotaIsSet Then
			vAllotmentAvailabilityRow = vAllotmentAvailability.Find(vCurHour, "Hour");
			If vAllotmentAvailabilityRow <> Undefined Then
				If ShowInBeds Then
					vRemains = vAllotmentAvailabilityRow.BedsRemains;
				Else
					vRemains = vAllotmentAvailabilityRow.RoomsRemains;
				EndIf;
			EndIf;
			
			If vDoWriteOff Then
				vCurAvailability = vRemains;
			Else
				If vVacant < vRemains Then
					vCurAvailability = vVacant;
				Else
					vCurAvailability = vRemains;
				EndIf;
			EndIf;
		Else
			vCurAvailability = vVacant;
		EndIf;
		vRow["Hour" + i] = vCurAvailability;
		
		vCurHour = vCurHour + 1;
		If vCurHour = 25 Then
			vCurHour = 1;
		EndIf;
	EndDo;
	
	// Get breakdown details
	vPeriodTo = EndOfDay(CurDate);
	If CurTime <> 0 Then
		vFirstTime = Number(Left(Items.AvailabilityByHoursHour1.Title, 2));
		If vFirstTime > CurTime Then
			vPeriodTo = BegOfDay(CurDate) + (CurTime + 24)*3600 - 1;
		Else
			vPeriodTo = BegOfDay(CurDate) + CurTime*3600 - 1;
		EndIf;
	EndIf;
	
	#Вставка
	Если НомернойФонд.Пустая() Тогда
		
		vQry = New Query();
		vQry.Text = 
		"SELECT  Разрешенные
		|	RoomInventoryMovements.Recorder AS Recorder,
		|	MAX(RoomInventoryMovements.Period) AS PeriodFrom
		|INTO EffectivePeriodsByRecorders
		|FROM
		|	AccumulationRegister.RoomInventory AS RoomInventoryMovements
		|WHERE
		|	RoomInventoryMovements.RecordType = VALUE(AccumulationRecordType.Expense)
		|	AND RoomInventoryMovements.Period <= &qPeriodTo
		|	AND RoomInventoryMovements.PeriodFrom <= &qPeriodTo
		|	AND RoomInventoryMovements.PeriodTo > &qPeriodTo
		|	AND (RoomInventoryMovements.IsReservation
		|			OR RoomInventoryMovements.IsAccommodation)
		|	AND RoomInventoryMovements.Hotel IN HIERARCHY(&qHotel)
		|	AND (RoomInventoryMovements.RoomQuota IN HIERARCHY (&qRoomQuota)
		|			OR &qIsEmptyRoomQuota)
		|	AND RoomInventoryMovements.RoomType IN HIERARCHY(&qRoomType)
		|
		|GROUP BY
		|	RoomInventoryMovements.Recorder
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT
		|	ExpectedGuestGroupsTurnovers.GuestGroup AS GuestGroup,
		|	ExpectedGuestGroupsTurnovers.RoomsReservedTurnover AS PreliminaryRooms,
		|	ExpectedGuestGroupsTurnovers.BedsReservedTurnover AS PreliminaryBeds
		|INTO PreliminaryReservations
		|FROM
		|	AccumulationRegister.ExpectedGuestGroups.Turnovers(
		|			&qTentativePeriodFrom,
		|			&qTentativePeriodTo,
		|			Day,
		|			&qShowPreliminary
		|				AND Hotel = &qHotel
		|				AND RoomType IN HIERARCHY (&qRoomType)
		|				AND (NOT &qIsEmptyRoomQuota
		|						AND RoomQuota IN HIERARCHY (&qRoomQuota)
		|					OR &qIsEmptyRoomQuota)) AS ExpectedGuestGroupsTurnovers
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT разрешенные
		|	RoomInventory.RecordType AS Type,
		|	RoomInventory.Ref AS Ref,
		|	CASE
		|		WHEN RoomInventory.Ref REFS Catalog.Hotels
		|			THEN RoomInventory.Ref.SortCode
		|		WHEN RoomInventory.Ref REFS Catalog.RoomQuotas
		|			THEN RoomInventory.Ref.SortCode
		|		WHEN RoomInventory.Ref REFS Catalog.RoomBlockTypes
		|			THEN RoomInventory.Ref.SortCode
		|		WHEN RoomInventory.Ref REFS Catalog.GuestGroups
		|			THEN RoomInventory.Ref.Code
		|		ELSE """"
		|	END AS RefSortCode,
		|	CASE
		|		WHEN RoomInventory.Ref REFS Catalog.Hotels
		|			THEN RoomInventory.Ref.Description
		|		WHEN RoomInventory.Ref REFS Catalog.RoomQuotas
		|			THEN RoomInventory.Ref.Description
		|		WHEN RoomInventory.Ref REFS Catalog.RoomBlockTypes
		|			THEN RoomInventory.Ref.Description
		|		WHEN RoomInventory.Ref REFS Catalog.GuestGroups
		|			THEN """"
		|		ELSE """"
		|	END AS RefDescription,
		|	RoomInventory.Rooms AS Rooms,
		|	RoomInventory.Beds AS Beds,
		|	RoomInventory.PreliminaryRooms AS PreliminaryRooms,
		|	RoomInventory.PreliminaryBeds AS PreliminaryBeds,
		|	RoomInventory.NotPickedUpRooms AS NotPickedUpRooms,
		|	RoomInventory.NotPickedUpBeds AS NotPickedUpBeds
		|FROM
		|	(SELECT
		|		RoomInventoryMovements.Ref AS Ref,
		|		RoomInventoryMovements.RecordType AS RecordType,
		|		SUM(RoomInventoryMovements.Rooms) AS Rooms,
		|		SUM(RoomInventoryMovements.Beds) AS Beds,
		|		SUM(RoomInventoryMovements.PreliminaryRooms) AS PreliminaryRooms,
		|		SUM(RoomInventoryMovements.PreliminaryBeds) AS PreliminaryBeds,
		|		SUM(RoomInventoryMovements.NotPickedUpRooms) AS NotPickedUpRooms,
		|		SUM(RoomInventoryMovements.NotPickedUpBeds) AS NotPickedUpBeds
		|	FROM
		|		(SELECT
		|			AvailableRooms.Hotel AS Ref,
		|			1 AS RecordType,
		|			ISNULL(AvailableRooms.TotalRoomsBalance, 0) AS Rooms,
		|			ISNULL(AvailableRooms.TotalBedsBalance, 0) AS Beds,
		|			0 AS PreliminaryRooms,
		|			0 AS PreliminaryBeds,
		|			0 AS NotPickedUpRooms,
		|			0 AS NotPickedUpBeds
		|		FROM
		|			AccumulationRegister.RoomInventory.Balance(
		|					&qPeriodTo,
		|					&qIsEmptyRoomQuota
		|						AND RoomType IN HIERARCHY (&qRoomType)
		|						AND Hotel IN HIERARCHY (&qHotel)) AS AvailableRooms
		|		
		|		UNION ALL
		|		
		|		SELECT
		|			RoomBlocks.RoomBlockType,
		|			2,
		|			ISNULL(RoomBlocks.RoomsBlockedBalance, 0),
		|			ISNULL(RoomBlocks.BedsBlockedBalance, 0),
		|			0,
		|			0,
		|			0,
		|			0
		|		FROM
		|			AccumulationRegister.RoomBlocks.Balance(
		|					&qPeriodTo,
		|					&qIsEmptyRoomQuota
		|						AND RoomType IN HIERARCHY (&qRoomType)
		|						AND Hotel IN HIERARCHY (&qHotel)) AS RoomBlocks
		|		
		|		UNION ALL
		|		
		|		SELECT
		|			RoomQuotas.RoomQuota,
		|			3,
		|			ISNULL(RoomQuotas.RoomsRemainsBalance, 0),
		|			ISNULL(RoomQuotas.BedsRemainsBalance, 0),
		|			0,
		|			0,
		|			0,
		|			0
		|		FROM
		|			AccumulationRegister.RoomQuotaSales.Balance(
		|					&qPeriodTo,
		|					RoomQuota.DoWriteOff
		|						AND RoomType IN HIERARCHY (&qRoomType)
		|						AND Hotel IN HIERARCHY (&qHotel)
		|						AND (RoomQuota IN HIERARCHY (&qRoomQuota)
		|							OR &qIsEmptyRoomQuota)) AS RoomQuotas
		|		
		|		UNION ALL
		|		
		|		SELECT  
		|			Reservations.GuestGroup,
		|			CASE
		|				WHEN Reservations.GuestGroup.GroupType = VALUE(Catalog.GroupTypes.EmptyRef)
		|					THEN 5
		|				ELSE 4
		|			END,
		|			Reservations.RoomsVacant,
		|			Reservations.BedsVacant,
		|			0,
		|			0,
		|			CASE
		|				WHEN Reservations.Recorder.RoomQuantity > 1
		|					THEN Reservations.RoomsVacant
		|				ELSE 0
		|			END,
		|			CASE
		|				WHEN Reservations.Recorder.RoomQuantity > 1
		|					THEN Reservations.BedsVacant
		|				ELSE 0
		|			END
		|		FROM
		|			AccumulationRegister.RoomInventory AS Reservations
		|				INNER JOIN EffectivePeriodsByRecorders AS EffectivePeriodsByRecorders
		|				ON Reservations.Recorder = EffectivePeriodsByRecorders.Recorder
		|					AND Reservations.Period = EffectivePeriodsByRecorders.PeriodFrom
		|		WHERE
		|			Reservations.RecordType = VALUE(AccumulationRecordType.Expense)
		|			AND Reservations.RoomType IN HIERARCHY(&qRoomType)
		|			AND Reservations.IsReservation
		|			AND Reservations.Hotel IN HIERARCHY(&qHotel)
		|			AND (Reservations.RoomQuota IN HIERARCHY (&qRoomQuota)
		|					OR &qIsEmptyRoomQuota)
		|		
		|		UNION ALL
		|		
		|		SELECT
		|			PreliminaryReservations.GuestGroup,
		|			CASE
		|				WHEN PreliminaryReservations.GuestGroup.GroupType = VALUE(Catalog.GroupTypes.EmptyRef)
		|					THEN 5
		|				ELSE 4
		|			END,
		|			0,
		|			0,
		|			PreliminaryReservations.PreliminaryRooms,
		|			PreliminaryReservations.PreliminaryBeds,
		|			0,
		|			0
		|		FROM
		|			PreliminaryReservations AS PreliminaryReservations
		|		
		|		UNION ALL
		|		
		|		SELECT
		|			Accommodations.GuestGroup,
		|			CASE
		|				WHEN Accommodations.GuestGroup.GroupType = VALUE(Catalog.GroupTypes.EmptyRef)
		|					THEN 5
		|				ELSE 4
		|			END,
		|			Accommodations.RoomsVacant,
		|			Accommodations.BedsVacant,
		|			0,
		|			0,
		|			0,
		|			0
		|		FROM
		|			AccumulationRegister.RoomInventory AS Accommodations
		|				INNER JOIN EffectivePeriodsByRecorders AS EffectivePeriodsByRecorders
		|				ON Accommodations.Recorder = EffectivePeriodsByRecorders.Recorder
		|					AND Accommodations.Period = EffectivePeriodsByRecorders.PeriodFrom
		|		WHERE
		|			Accommodations.RecordType = VALUE(AccumulationRecordType.Expense)
		|			AND Accommodations.RoomType IN HIERARCHY(&qRoomType)
		|			AND Accommodations.IsAccommodation
		|			AND Accommodations.Hotel IN HIERARCHY(&qHotel)
		|			AND (Accommodations.RoomQuota IN HIERARCHY (&qRoomQuota)
		|					OR &qIsEmptyRoomQuota)) AS RoomInventoryMovements
		|	
		|	GROUP BY
		|		RoomInventoryMovements.RecordType,
		|		RoomInventoryMovements.Ref) AS RoomInventory
		|
		|ORDER BY
		|	Type,
		|	RefSortCode,
		|	RefDescription";
		
	Иначе
		vQry = New Query();
		vQry.МенеджерВременныхТаблиц = МенеджерВТ;
		vQry.Text = 
		"SELECT  Разрешенные
		|	RoomInventoryMovements.Recorder AS Recorder,
		|	MAX(RoomInventoryMovements.Period) AS PeriodFrom
		|INTO EffectivePeriodsByRecorders
		|FROM
		|	AccumulationRegister.RoomInventory AS RoomInventoryMovements
		|   Внутреннее соединение ВТ_Номера как ВТ_Номера
		|   по ВТ_Номера.Номер = RoomInventoryMovements.Room
		|WHERE
		|	RoomInventoryMovements.RecordType = VALUE(AccumulationRecordType.Expense)
		|	AND RoomInventoryMovements.Period <= &qPeriodTo
		|	AND RoomInventoryMovements.PeriodFrom <= &qPeriodTo
		|	AND RoomInventoryMovements.PeriodTo > &qPeriodTo
		|	AND (RoomInventoryMovements.IsReservation
		|			OR RoomInventoryMovements.IsAccommodation)
		|	AND RoomInventoryMovements.Hotel IN HIERARCHY(&qHotel)
		|	AND (RoomInventoryMovements.RoomQuota IN HIERARCHY (&qRoomQuota)
		|			OR &qIsEmptyRoomQuota)
		|	AND RoomInventoryMovements.RoomType IN HIERARCHY(&qRoomType)
		|
		|GROUP BY
		|	RoomInventoryMovements.Recorder
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT
		|	ExpectedGuestGroupsTurnovers.GuestGroup AS GuestGroup,
		|	ExpectedGuestGroupsTurnovers.RoomsReservedTurnover AS PreliminaryRooms,
		|	ExpectedGuestGroupsTurnovers.BedsReservedTurnover AS PreliminaryBeds
		|INTO PreliminaryReservations
		|FROM
		|	AccumulationRegister.ExpectedGuestGroups.Turnovers(
		|			&qTentativePeriodFrom,
		|			&qTentativePeriodTo,
		|			Day,
		|			&qShowPreliminary
		|				AND Hotel = &qHotel
		|				AND RoomType IN HIERARCHY (&qRoomType)
		|				AND (NOT &qIsEmptyRoomQuota
		|						AND RoomQuota IN HIERARCHY (&qRoomQuota)
		|					OR &qIsEmptyRoomQuota)) AS ExpectedGuestGroupsTurnovers
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT разрешенные
		|	RoomInventory.RecordType AS Type,
		|	RoomInventory.Ref AS Ref,
		|	CASE
		|		WHEN RoomInventory.Ref REFS Catalog.Hotels
		|			THEN RoomInventory.Ref.SortCode
		|		WHEN RoomInventory.Ref REFS Catalog.RoomQuotas
		|			THEN RoomInventory.Ref.SortCode
		|		WHEN RoomInventory.Ref REFS Catalog.RoomBlockTypes
		|			THEN RoomInventory.Ref.SortCode
		|		WHEN RoomInventory.Ref REFS Catalog.GuestGroups
		|			THEN RoomInventory.Ref.Code
		|		ELSE """"
		|	END AS RefSortCode,
		|	CASE
		|		WHEN RoomInventory.Ref REFS Catalog.Hotels
		|			THEN RoomInventory.Ref.Description
		|		WHEN RoomInventory.Ref REFS Catalog.RoomQuotas
		|			THEN RoomInventory.Ref.Description
		|		WHEN RoomInventory.Ref REFS Catalog.RoomBlockTypes
		|			THEN RoomInventory.Ref.Description
		|		WHEN RoomInventory.Ref REFS Catalog.GuestGroups
		|			THEN """"
		|		ELSE """"
		|	END AS RefDescription,
		|	RoomInventory.Rooms AS Rooms,
		|	RoomInventory.Beds AS Beds,
		|	RoomInventory.PreliminaryRooms AS PreliminaryRooms,
		|	RoomInventory.PreliminaryBeds AS PreliminaryBeds,
		|	RoomInventory.NotPickedUpRooms AS NotPickedUpRooms,
		|	RoomInventory.NotPickedUpBeds AS NotPickedUpBeds
		|FROM
		|	(SELECT
		|		RoomInventoryMovements.Ref AS Ref,
		|		RoomInventoryMovements.RecordType AS RecordType,
		|		SUM(RoomInventoryMovements.Rooms) AS Rooms,
		|		SUM(RoomInventoryMovements.Beds) AS Beds,
		|		SUM(RoomInventoryMovements.PreliminaryRooms) AS PreliminaryRooms,
		|		SUM(RoomInventoryMovements.PreliminaryBeds) AS PreliminaryBeds,
		|		SUM(RoomInventoryMovements.NotPickedUpRooms) AS NotPickedUpRooms,
		|		SUM(RoomInventoryMovements.NotPickedUpBeds) AS NotPickedUpBeds
		|	FROM
		|		(SELECT
		|			AvailableRooms.Hotel AS Ref,
		|			1 AS RecordType,
		|			ISNULL(AvailableRooms.TotalRoomsBalance, 0) AS Rooms,
		|			ISNULL(AvailableRooms.TotalBedsBalance, 0) AS Beds,
		|			0 AS PreliminaryRooms,
		|			0 AS PreliminaryBeds,
		|			0 AS NotPickedUpRooms,
		|			0 AS NotPickedUpBeds
		|		FROM
		|			AccumulationRegister.RoomInventory.Balance(
		|					&qPeriodTo,
		|					&qIsEmptyRoomQuota
		|						AND RoomType IN HIERARCHY (&qRoomType)
		|						AND Hotel IN HIERARCHY (&qHotel) и Room в (Выбрать Т.Номер Из ВТ_Номера как Т)) AS AvailableRooms
		|		
		|		UNION ALL
		|		
		|		SELECT
		|			RoomBlocks.RoomBlockType,
		|			2,
		|			ISNULL(RoomBlocks.RoomsBlockedBalance, 0),
		|			ISNULL(RoomBlocks.BedsBlockedBalance, 0),
		|			0,
		|			0,
		|			0,
		|			0
		|		FROM
		|			AccumulationRegister.RoomBlocks.Balance(
		|					&qPeriodTo,
		|					&qIsEmptyRoomQuota
		|						AND RoomType IN HIERARCHY (&qRoomType)
		|						AND Hotel IN HIERARCHY (&qHotel) и Room в (Выбрать Т.Номер Из ВТ_Номера как Т)) AS RoomBlocks
		|		
		|		UNION ALL
		|		
		|		SELECT
		|			RoomQuotas.RoomQuota,
		|			3,
		|			ISNULL(RoomQuotas.RoomsRemainsBalance, 0),
		|			ISNULL(RoomQuotas.BedsRemainsBalance, 0),
		|			0,
		|			0,
		|			0,
		|			0
		|		FROM
		|			AccumulationRegister.RoomQuotaSales.Balance(
		|					&qPeriodTo,
		|					RoomQuota.DoWriteOff
		|						AND RoomType IN HIERARCHY (&qRoomType)
		|						AND Hotel IN HIERARCHY (&qHotel)
		|						AND (RoomQuota IN HIERARCHY (&qRoomQuota)
		|							OR &qIsEmptyRoomQuota) и Room в (Выбрать Т.Номер Из ВТ_Номера как Т)) AS RoomQuotas
		|		
		|		UNION ALL
		|		
		|		SELECT  
		|			Reservations.GuestGroup,
		|			CASE
		|				WHEN Reservations.GuestGroup.GroupType = VALUE(Catalog.GroupTypes.EmptyRef)
		|					THEN 5
		|				ELSE 4
		|			END,
		|			Reservations.RoomsVacant,
		|			Reservations.BedsVacant,
		|			0,
		|			0,
		|			CASE
		|				WHEN Reservations.Recorder.RoomQuantity > 1
		|					THEN Reservations.RoomsVacant
		|				ELSE 0
		|			END,
		|			CASE
		|				WHEN Reservations.Recorder.RoomQuantity > 1
		|					THEN Reservations.BedsVacant
		|				ELSE 0
		|			END
		|		FROM
		|			AccumulationRegister.RoomInventory AS Reservations
		|				INNER JOIN EffectivePeriodsByRecorders AS EffectivePeriodsByRecorders
		|				ON Reservations.Recorder = EffectivePeriodsByRecorders.Recorder
		|					AND Reservations.Period = EffectivePeriodsByRecorders.PeriodFrom
		|  				Внутреннее соединение ВТ_Номера как ВТ_Номера
		|  				по ВТ_Номера.Номер = Reservations.Room
		|		WHERE
		|			Reservations.RecordType = VALUE(AccumulationRecordType.Expense)
		|			AND Reservations.RoomType IN HIERARCHY(&qRoomType)
		|			AND Reservations.IsReservation
		|			AND Reservations.Hotel IN HIERARCHY(&qHotel)
		|			AND (Reservations.RoomQuota IN HIERARCHY (&qRoomQuota)
		|					OR &qIsEmptyRoomQuota)
		|		
		|		UNION ALL
		|		
		|		SELECT
		|			PreliminaryReservations.GuestGroup,
		|			CASE
		|				WHEN PreliminaryReservations.GuestGroup.GroupType = VALUE(Catalog.GroupTypes.EmptyRef)
		|					THEN 5
		|				ELSE 4
		|			END,
		|			0,
		|			0,
		|			PreliminaryReservations.PreliminaryRooms,
		|			PreliminaryReservations.PreliminaryBeds,
		|			0,
		|			0
		|		FROM
		|			PreliminaryReservations AS PreliminaryReservations
		|		
		|		UNION ALL
		|		
		|		SELECT
		|			Accommodations.GuestGroup,
		|			CASE
		|				WHEN Accommodations.GuestGroup.GroupType = VALUE(Catalog.GroupTypes.EmptyRef)
		|					THEN 5
		|				ELSE 4
		|			END,
		|			Accommodations.RoomsVacant,
		|			Accommodations.BedsVacant,
		|			0,
		|			0,
		|			0,
		|			0
		|		FROM
		|			AccumulationRegister.RoomInventory AS Accommodations
		|				INNER JOIN EffectivePeriodsByRecorders AS EffectivePeriodsByRecorders
		|				ON Accommodations.Recorder = EffectivePeriodsByRecorders.Recorder
		|					AND Accommodations.Period = EffectivePeriodsByRecorders.PeriodFrom
		|               Внутреннее Соединение ВТ_Номера как ВТ_Номера 
		|				по ВТ_Номера.Номер = Accommodations.Room
		|		WHERE
		|			Accommodations.RecordType = VALUE(AccumulationRecordType.Expense)
		|			AND Accommodations.RoomType IN HIERARCHY(&qRoomType)
		|			AND Accommodations.IsAccommodation
		|			AND Accommodations.Hotel IN HIERARCHY(&qHotel)
		|			AND (Accommodations.RoomQuota IN HIERARCHY (&qRoomQuota)
		|					OR &qIsEmptyRoomQuota)) AS RoomInventoryMovements
		|	
		|	GROUP BY
		|		RoomInventoryMovements.RecordType,
		|		RoomInventoryMovements.Ref) AS RoomInventory
		|
		|ORDER BY
		|	Type,
		|	RefSortCode,
		|	RefDescription";
		
	КонецЕсли;
	#КонецВставки
	
	#Удаление
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	RoomInventoryMovements.Recorder AS Recorder,
	|	MAX(RoomInventoryMovements.Period) AS PeriodFrom
	|INTO EffectivePeriodsByRecorders
	|FROM
	|	AccumulationRegister.RoomInventory AS RoomInventoryMovements
	|WHERE
	|	RoomInventoryMovements.RecordType = VALUE(AccumulationRecordType.Expense)
	|	AND RoomInventoryMovements.Period <= &qPeriodTo
	|	AND RoomInventoryMovements.PeriodFrom <= &qPeriodTo
	|	AND RoomInventoryMovements.PeriodTo > &qPeriodTo
	|	AND (RoomInventoryMovements.IsReservation
	|			OR RoomInventoryMovements.IsAccommodation)
	|	AND RoomInventoryMovements.Hotel IN HIERARCHY(&qHotel)
	|	AND (RoomInventoryMovements.RoomQuota IN HIERARCHY (&qRoomQuota)
	|			OR &qIsEmptyRoomQuota)
	|	AND RoomInventoryMovements.RoomType IN HIERARCHY(&qRoomType)
	|
	|GROUP BY
	|	RoomInventoryMovements.Recorder
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	ExpectedGuestGroupsTurnovers.GuestGroup AS GuestGroup,
	|	ExpectedGuestGroupsTurnovers.RoomsReservedTurnover AS PreliminaryRooms,
	|	ExpectedGuestGroupsTurnovers.BedsReservedTurnover AS PreliminaryBeds
	|INTO PreliminaryReservations
	|FROM
	|	AccumulationRegister.ExpectedGuestGroups.Turnovers(
	|			&qTentativePeriodFrom,
	|			&qTentativePeriodTo,
	|			Day,
	|			&qShowPreliminary
	|				AND Hotel = &qHotel
	|				AND RoomType IN HIERARCHY (&qRoomType)
	|				AND (NOT &qIsEmptyRoomQuota
	|						AND RoomQuota IN HIERARCHY (&qRoomQuota)
	|					OR &qIsEmptyRoomQuota)) AS ExpectedGuestGroupsTurnovers
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	RoomInventory.RecordType AS Type,
	|	RoomInventory.Ref AS Ref,
	|	CASE
	|		WHEN RoomInventory.Ref REFS Catalog.Hotels
	|			THEN RoomInventory.Ref.SortCode
	|		WHEN RoomInventory.Ref REFS Catalog.RoomQuotas
	|			THEN RoomInventory.Ref.SortCode
	|		WHEN RoomInventory.Ref REFS Catalog.RoomBlockTypes
	|			THEN RoomInventory.Ref.SortCode
	|		WHEN RoomInventory.Ref REFS Catalog.GuestGroups
	|			THEN RoomInventory.Ref.Code
	|		ELSE """"
	|	END AS RefSortCode,
	|	CASE
	|		WHEN RoomInventory.Ref REFS Catalog.Hotels
	|			THEN RoomInventory.Ref.Description
	|		WHEN RoomInventory.Ref REFS Catalog.RoomQuotas
	|			THEN RoomInventory.Ref.Description
	|		WHEN RoomInventory.Ref REFS Catalog.RoomBlockTypes
	|			THEN RoomInventory.Ref.Description
	|		WHEN RoomInventory.Ref REFS Catalog.GuestGroups
	|			THEN """"
	|		ELSE """"
	|	END AS RefDescription,
	|	RoomInventory.Rooms AS Rooms,
	|	RoomInventory.Beds AS Beds,
	|	RoomInventory.PreliminaryRooms AS PreliminaryRooms,
	|	RoomInventory.PreliminaryBeds AS PreliminaryBeds,
	|	RoomInventory.NotPickedUpRooms AS NotPickedUpRooms,
	|	RoomInventory.NotPickedUpBeds AS NotPickedUpBeds
	|FROM
	|	(SELECT
	|		RoomInventoryMovements.Ref AS Ref,
	|		RoomInventoryMovements.RecordType AS RecordType,
	|		SUM(RoomInventoryMovements.Rooms) AS Rooms,
	|		SUM(RoomInventoryMovements.Beds) AS Beds,
	|		SUM(RoomInventoryMovements.PreliminaryRooms) AS PreliminaryRooms,
	|		SUM(RoomInventoryMovements.PreliminaryBeds) AS PreliminaryBeds,
	|		SUM(RoomInventoryMovements.NotPickedUpRooms) AS NotPickedUpRooms,
	|		SUM(RoomInventoryMovements.NotPickedUpBeds) AS NotPickedUpBeds
	|	FROM
	|		(SELECT
	|			AvailableRooms.Hotel AS Ref,
	|			1 AS RecordType,
	|			ISNULL(AvailableRooms.TotalRoomsBalance, 0) AS Rooms,
	|			ISNULL(AvailableRooms.TotalBedsBalance, 0) AS Beds,
	|			0 AS PreliminaryRooms,
	|			0 AS PreliminaryBeds,
	|			0 AS NotPickedUpRooms,
	|			0 AS NotPickedUpBeds
	|		FROM
	|			AccumulationRegister.RoomInventory.Balance(
	|					&qPeriodTo,
	|					&qIsEmptyRoomQuota
	|						AND RoomType IN HIERARCHY (&qRoomType)
	|						AND Hotel IN HIERARCHY (&qHotel)) AS AvailableRooms
	|		
	|		UNION ALL
	|		
	|		SELECT
	|			RoomBlocks.RoomBlockType,
	|			2,
	|			ISNULL(RoomBlocks.RoomsBlockedBalance, 0),
	|			ISNULL(RoomBlocks.BedsBlockedBalance, 0),
	|			0,
	|			0,
	|			0,
	|			0
	|		FROM
	|			AccumulationRegister.RoomBlocks.Balance(
	|					&qPeriodTo,
	|					&qIsEmptyRoomQuota
	|						AND RoomType IN HIERARCHY (&qRoomType)
	|						AND Hotel IN HIERARCHY (&qHotel)) AS RoomBlocks
	|		
	|		UNION ALL
	|		
	|		SELECT
	|			RoomQuotas.RoomQuota,
	|			3,
	|			ISNULL(RoomQuotas.RoomsRemainsBalance, 0),
	|			ISNULL(RoomQuotas.BedsRemainsBalance, 0),
	|			0,
	|			0,
	|			0,
	|			0
	|		FROM
	|			AccumulationRegister.RoomQuotaSales.Balance(
	|					&qPeriodTo,
	|					RoomQuota.DoWriteOff
	|						AND RoomType IN HIERARCHY (&qRoomType)
	|						AND Hotel IN HIERARCHY (&qHotel)
	|						AND (RoomQuota IN HIERARCHY (&qRoomQuota)
	|							OR &qIsEmptyRoomQuota)) AS RoomQuotas
	|		
	|		UNION ALL
	|		
	|		SELECT  
	|			Reservations.GuestGroup,
	|			CASE
	|				WHEN Reservations.GuestGroup.GroupType = VALUE(Catalog.GroupTypes.EmptyRef)
	|					THEN 5
	|				ELSE 4
	|			END,
	|			Reservations.RoomsVacant,
	|			Reservations.BedsVacant,
	|			0,
	|			0,
	|			CASE
	|				WHEN Reservations.Recorder.RoomQuantity > 1
	|					THEN Reservations.RoomsVacant
	|				ELSE 0
	|			END,
	|			CASE
	|				WHEN Reservations.Recorder.RoomQuantity > 1
	|					THEN Reservations.BedsVacant
	|				ELSE 0
	|			END
	|		FROM
	|			AccumulationRegister.RoomInventory AS Reservations
	|				INNER JOIN EffectivePeriodsByRecorders AS EffectivePeriodsByRecorders
	|				ON Reservations.Recorder = EffectivePeriodsByRecorders.Recorder
	|					AND Reservations.Period = EffectivePeriodsByRecorders.PeriodFrom
	|		WHERE
	|			Reservations.RecordType = VALUE(AccumulationRecordType.Expense)
	|			AND Reservations.RoomType IN HIERARCHY(&qRoomType)
	|			AND Reservations.IsReservation
	|			AND Reservations.Hotel IN HIERARCHY(&qHotel)
	|			AND (Reservations.RoomQuota IN HIERARCHY (&qRoomQuota)
	|					OR &qIsEmptyRoomQuota)
	|		
	|		UNION ALL
	|		
	|		SELECT
	|			PreliminaryReservations.GuestGroup,
	|			CASE
	|				WHEN PreliminaryReservations.GuestGroup.GroupType = VALUE(Catalog.GroupTypes.EmptyRef)
	|					THEN 5
	|				ELSE 4
	|			END,
	|			0,
	|			0,
	|			PreliminaryReservations.PreliminaryRooms,
	|			PreliminaryReservations.PreliminaryBeds,
	|			0,
	|			0
	|		FROM
	|			PreliminaryReservations AS PreliminaryReservations
	|		
	|		UNION ALL
	|		
	|		SELECT
	|			Accommodations.GuestGroup,
	|			CASE
	|				WHEN Accommodations.GuestGroup.GroupType = VALUE(Catalog.GroupTypes.EmptyRef)
	|					THEN 5
	|				ELSE 4
	|			END,
	|			Accommodations.RoomsVacant,
	|			Accommodations.BedsVacant,
	|			0,
	|			0,
	|			0,
	|			0
	|		FROM
	|			AccumulationRegister.RoomInventory AS Accommodations
	|				INNER JOIN EffectivePeriodsByRecorders AS EffectivePeriodsByRecorders
	|				ON Accommodations.Recorder = EffectivePeriodsByRecorders.Recorder
	|					AND Accommodations.Period = EffectivePeriodsByRecorders.PeriodFrom
	|		WHERE
	|			Accommodations.RecordType = VALUE(AccumulationRecordType.Expense)
	|			AND Accommodations.RoomType IN HIERARCHY(&qRoomType)
	|			AND Accommodations.IsAccommodation
	|			AND Accommodations.Hotel IN HIERARCHY(&qHotel)
	|			AND (Accommodations.RoomQuota IN HIERARCHY (&qRoomQuota)
	|					OR &qIsEmptyRoomQuota)) AS RoomInventoryMovements
	|	
	|	GROUP BY
	|		RoomInventoryMovements.RecordType,
	|		RoomInventoryMovements.Ref) AS RoomInventory
	|
	|ORDER BY
	|	Type,
	|	RefSortCode,
	|	RefDescription";
	#КонецУдаления	
	vQry.SetParameter("qHotel", CurHotel);
	vQry.SetParameter("qRoomType", CurRoomType);
	vQry.SetParameter("qRoomQuota", RoomQuota);
	vQry.SetParameter("qIsEmptyRoomQuota", Not ValueIsFilled(RoomQuota));
	vQry.SetParameter("qPeriodTo", vPeriodTo);
	vQry.SetParameter("qTentativePeriodFrom", BegOfDay(vPeriodTo));
	vQry.SetParameter("qTentativePeriodTo", EndOfDay(vPeriodTo));
	vQry.SetParameter("qShowPreliminary", ShowPreliminary);
	vDetails = vQry.Execute().Unload();
	// Fill table with details
	vCurType = 0;
	For Each vDetailsRow In vDetails Do
		If vCurType <> vDetailsRow.Type Then
			vCurType = vDetailsRow.Type;
			vRow = AvailabilityBreakdown.GetItems().Add();
			If vCurType = 1 Then
				vRow.Description = NStr("en='Total rooms for '; ru='Всего номеров на '; de='Total Zimmer für '") + Format(?(CurTime = 0 Or CurTime = 24, vPeriodTo, vPeriodTo + 1), "DF='HH:mm dd.MM.yyyy'");
			ElsIf vCurType = 2 Then
				vRow.Description = NStr("en='Blocked rooms'; ru='Блокировки'; de='Blockierte Zimmer'");
			ElsIf vCurType = 3 Then
				vRow.Description = NStr("en='Allotments'; ru='Квоты'; de='Allotments'");
			ElsIf vCurType = 4 Then
				vRow.Description = NStr("en='Groups'; ru='Группы'; de='Gruppen'");
			ElsIf vCurType = 5 Then
				vRow.Description = NStr("en='Reservations'; ru='Брони'; de='Reservierungen'");
			EndIf;
		EndIf;
		vRow.Quantity = vRow.Quantity + ?(ShowInBeds, vDetailsRow.Beds, vDetailsRow.Rooms);
		If vCurType = 4 Or vCurType = 5 Then
			vRow.TentativeQuantity = vRow.TentativeQuantity + ?(ShowInBeds, vDetailsRow.PreliminaryBeds, vDetailsRow.PreliminaryRooms);
		EndIf;
		vSubRow = vRow.GetItems().Add();
		vSubRow.Description = "";
		If vCurType = 1 Then
			vSubRow.Ref = ?(ValueIsFilled(CurRoomType), CurRoomType, ?(ValueIsFilled(CurHotel), CurHotel, vDetailsRow.Ref));
		Else
			vSubRow.Ref = vDetailsRow.Ref;
		EndIf;
		vSubRow.Quantity = vSubRow.Quantity + ?(ShowInBeds, vDetailsRow.Beds, vDetailsRow.Rooms);
		If vCurType = 4 Or vCurType = 5 Then
			vSubRow.GuestGroup = vDetailsRow.Ref;
			vSubRow.NotPickedUpQuantity = vSubRow.NotPickedUpQuantity + ?(ShowInBeds, vDetailsRow.NotPickedUpBeds, vDetailsRow.NotPickedUpRooms);
			vSubRow.TentativeQuantity = vSubRow.TentativeQuantity + ?(ShowInBeds, vDetailsRow.PreliminaryBeds, vDetailsRow.PreliminaryRooms);
		EndIf;
	EndDo;
EndProcedure

&AtServer
&ChangeAndValidate("GetOccupationPercent")
Function Расш1_GetOccupationPercent(pHotel, qPeriodFrom, qPeriodTo)
	vHotel = pHotel; 
	If vHotel = Undefined Then 
		vHotel = SessionParameters.CurrentHotel;
	EndIf;
	
	vForecastStartDate = tcOnServer.GetForecastStartDate(vHotel);
	
	vPeriodFrom = qPeriodFrom; 
	If vPeriodFrom = Undefined Then 
		vPeriodFrom = BegOfDay(CurrentSessionDate());
	EndIf;
	
	vPeriodTo = qPeriodTo; 
	If vPeriodTo = Undefined Then
		vPeriodTo = EndOfDay(CurrentSessionDate());
	EndIf;
	
	// Run query to get room inventory
	
	#Вставка	
	Если НомернойФонд.Пустая() Тогда
		vQry = New Query();
		vQry.Text = 
		"SELECT Разрешенные
		|	BEGINOFPERIOD(RoomInventoryBalance.Period, DAY) AS Period,
		|	ISNULL(RoomSalesTurnovers.RoomsRentedTurnover, 0) + ISNULL(RoomSalesForecastTurnovers.RoomsRentedTurnover, 0) AS RoomsRented,
		|	RoomInventoryBalance.TotalRoomsClosingBalance AS TotalRooms,
		|	RoomInventoryBalance.RoomsBlockedClosingBalance AS RoomsBlocked,
		|	RoomInventoryBalance.CounterClosingBalance AS Counter
		|FROM
		|	AccumulationRegister.RoomInventory.BalanceAndTurnovers(&qPeriodFrom, &qPeriodTo, DAY, , Hotel IN HIERARCHY (&qHotel)) AS RoomInventoryBalance
		|		LEFT JOIN AccumulationRegister.Sales.Turnovers(&qSalesPeriodFrom, &qSalesPeriodTo, Day, Hotel IN HIERARCHY (&qHotel)) AS RoomSalesTurnovers
		|		ON (BEGINOFPERIOD(RoomInventoryBalance.Period, DAY) = BEGINOFPERIOD(RoomSalesTurnovers.Period, DAY))
		|		LEFT JOIN AccumulationRegister.SalesForecast.Turnovers(&qForecastPeriodFrom, &qForecastPeriodTo, Day, Hotel IN HIERARCHY (&qHotel)) AS RoomSalesForecastTurnovers
		|		ON (BEGINOFPERIOD(RoomInventoryBalance.Period, DAY) = BEGINOFPERIOD(RoomSalesForecastTurnovers.Period, DAY))
		|
		|ORDER BY
		|	Period";
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
		"SELECT Разрешенные
		|	BEGINOFPERIOD(RoomInventoryBalance.Period, DAY) AS Period,
		|	ISNULL(RoomSalesTurnovers.RoomsRentedTurnover, 0) + ISNULL(RoomSalesForecastTurnovers.RoomsRentedTurnover, 0) AS RoomsRented,
		|	RoomInventoryBalance.TotalRoomsClosingBalance AS TotalRooms,
		|	RoomInventoryBalance.RoomsBlockedClosingBalance AS RoomsBlocked,
		|	RoomInventoryBalance.CounterClosingBalance AS Counter
		|FROM
		|	AccumulationRegister.RoomInventory.BalanceAndTurnovers(&qPeriodFrom, &qPeriodTo, DAY, , Hotel IN HIERARCHY (&qHotel) и Room в (выбрать т.Номер из ВТ_Номера как Т)) AS RoomInventoryBalance
		|		LEFT JOIN AccumulationRegister.Sales.Turnovers(&qSalesPeriodFrom, &qSalesPeriodTo, Day, Hotel IN HIERARCHY (&qHotel)) AS RoomSalesTurnovers
		|		ON (BEGINOFPERIOD(RoomInventoryBalance.Period, DAY) = BEGINOFPERIOD(RoomSalesTurnovers.Period, DAY))
		|		LEFT JOIN AccumulationRegister.SalesForecast.Turnovers(&qForecastPeriodFrom, &qForecastPeriodTo, Day, Hotel IN HIERARCHY (&qHotel)) AS RoomSalesForecastTurnovers
		|		ON (BEGINOFPERIOD(RoomInventoryBalance.Period, DAY) = BEGINOFPERIOD(RoomSalesForecastTurnovers.Period, DAY))
		|
		|ORDER BY
		|	Period";
	КонецЕсли;
	#КонецВставки
	
	#Удаление
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	BEGINOFPERIOD(RoomInventoryBalance.Period, DAY) AS Period,
	|	ISNULL(RoomSalesTurnovers.RoomsRentedTurnover, 0) + ISNULL(RoomSalesForecastTurnovers.RoomsRentedTurnover, 0) AS RoomsRented,
	|	RoomInventoryBalance.TotalRoomsClosingBalance AS TotalRooms,
	|	RoomInventoryBalance.RoomsBlockedClosingBalance AS RoomsBlocked,
	|	RoomInventoryBalance.CounterClosingBalance AS Counter
	|FROM
	|	AccumulationRegister.RoomInventory.BalanceAndTurnovers(&qPeriodFrom, &qPeriodTo, DAY, , Hotel IN HIERARCHY (&qHotel)) AS RoomInventoryBalance
	|		LEFT JOIN AccumulationRegister.Sales.Turnovers(&qSalesPeriodFrom, &qSalesPeriodTo, Day, Hotel IN HIERARCHY (&qHotel)) AS RoomSalesTurnovers
	|		ON (BEGINOFPERIOD(RoomInventoryBalance.Period, DAY) = BEGINOFPERIOD(RoomSalesTurnovers.Period, DAY))
	|		LEFT JOIN AccumulationRegister.SalesForecast.Turnovers(&qForecastPeriodFrom, &qForecastPeriodTo, Day, Hotel IN HIERARCHY (&qHotel)) AS RoomSalesForecastTurnovers
	|		ON (BEGINOFPERIOD(RoomInventoryBalance.Period, DAY) = BEGINOFPERIOD(RoomSalesForecastTurnovers.Period, DAY))
	|
	|ORDER BY
	|	Period";
	#КонецУдаления
	vQry.SetParameter("qPeriodFrom", vPeriodFrom);
	vQry.SetParameter("qPeriodTo", vPeriodTo);
	vQry.SetParameter("qSalesPeriodFrom", BegOfDay(vPeriodFrom));
	vQry.SetParameter("qSalesPeriodTo", EndOfDay(vPeriodTo));
	vQry.SetParameter("qForecastPeriodFrom", BegOfDay(Max(vForecastStartDate, vPeriodFrom)));
	vQry.SetParameter("qForecastPeriodTo", EndOfDay(Max(vForecastStartDate, vPeriodTo)));
	vQry.SetParameter("qHotel", vHotel);
	vInvResult = vQry.Execute().Unload();
	
	Return vInvResult;
EndFunction


&AtServer
&ChangeAndValidate("BuildReport")
Procedure Расш1_BuildReport(pTotalPriceTable)
	// Price tag visibility
	If ValueIsFilled(RoomRate) And (RoomRate.PriceTagType = Enums.PriceTagTypes.ByDurationOfStayByDays Or RoomRate.PriceTagType = Enums.PriceTagTypes.ByDurationOfStayByPeriod) Then
		Items.PriceTag.Visible = True;
	Else
		PriceTag = Catalogs.PriceTags.EmptyRef();
		Items.PriceTag.Visible = False;
	EndIf;
	// Initialize number of days to output and period
	If NumberOfDays <= 0 Then
		If ShowPrices Then
			NumberOfDays = 31;
		Else
			NumberOfDays = 62;
		EndIf;
	EndIf;
	vNumberOfDays = NumberOfDays;
	vDateFrom = BegOfDay(DateFrom);
	vCurrentDateTime = ?(vDateFrom = BegOfDay(CurrentSessionDate()), CurrentSessionDate(), vDateFrom);
	vCurrentDate = BegOfDay(vCurrentDateTime);
	vDateTimeFrom = ?(vDateFrom = vCurrentDate, vCurrentDateTime, vDateFrom);
	vDateTo = vDateFrom + 24*3600*(vNumberOfDays - 1);
	vDateTimeTo = EndOfDay(vDateTo);
	vShowReportsInBeds = ShowInBeds;

	vNextPeriod = DateFrom + (NumberOfDays-1)*86400;
	vPrevPeriod = DateFrom - (NumberOfDays-1)*86400;

	Items.FormPrevPeriodButton.Title = Format(vPrevPeriod, "DF=dd.MM.yyyy");
	Items.FormNextPeriodButton.Title = Format(vNextPeriod, "DF=dd.MM.yyyy");

	// Get active events
	vEvents = cmGetEvents(vDateTimeFrom, vDateTimeTo, Hotel);

	// Build and run query with room inventory balances 
	#Вставка     
	Если НомернойФонд.Пустая() Тогда
		vQry = New Query();
		vQry.Text =	
		"SELECT ALLOWED
		|	BEGINOFPERIOD(RoomInventoryBalance.Period, DAY) AS Period,
		|	RoomInventoryBalance.Hotel AS Hotel,
		|	RoomInventoryBalance.RoomType AS RoomType,
		|	MAX(CASE
		|			WHEN &qRoomQuotaIsSet
		|					AND &qDoWriteOff
		|				THEN ISNULL(RoomQuotaBalances.RoomsInQuota, 0)
		|			WHEN &qRoomQuotaIsSet
		|					AND NOT &qDoWriteOff
		|				THEN ISNULL(RoomInventoryBalance.TotalRoomsClosingBalance, 0)
		|			ELSE ISNULL(RoomInventoryBalance.TotalRoomsClosingBalance, 0)
		|		END) AS TotalRooms,
		|	MAX(CASE
		|			WHEN &qRoomQuotaIsSet
		|					AND &qDoWriteOff
		|				THEN ISNULL(RoomQuotaBalances.BedsInQuota, 0)
		|			WHEN &qRoomQuotaIsSet
		|					AND NOT &qDoWriteOff
		|				THEN ISNULL(RoomInventoryBalance.TotalBedsClosingBalance, 0)
		|			ELSE ISNULL(RoomInventoryBalance.TotalBedsClosingBalance, 0)
		|		END) AS TotalBeds,
		|	MIN(CASE
		|			WHEN &qRoomQuotaIsSet
		|					AND &qDoWriteOff
		|				THEN ISNULL(RoomQuotaBalances.RoomsRemains, 0)
		|			WHEN &qRoomQuotaIsSet
		|					AND NOT &qDoWriteOff
		|					AND ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0) < ISNULL(RoomQuotaBalances.RoomsRemains, 0)
		|				THEN ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0)
		|			WHEN &qRoomQuotaIsSet
		|					AND NOT &qDoWriteOff
		|					AND ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0) >= ISNULL(RoomQuotaBalances.RoomsRemains, 0)
		|				THEN ISNULL(RoomQuotaBalances.RoomsRemains, 0)
		|			ELSE ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0)
		|		END) AS RoomsVacant,
		|	MIN(CASE
		|			WHEN &qRoomQuotaIsSet
		|					AND &qDoWriteOff
		|				THEN ISNULL(RoomQuotaBalances.BedsRemains, 0)
		|			WHEN &qRoomQuotaIsSet
		|					AND NOT &qDoWriteOff
		|					AND ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0) < ISNULL(RoomQuotaBalances.BedsRemains, 0)
		|				THEN ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0)
		|			WHEN &qRoomQuotaIsSet
		|					AND NOT &qDoWriteOff
		|					AND ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0) >= ISNULL(RoomQuotaBalances.BedsRemains, 0)
		|				THEN ISNULL(RoomQuotaBalances.BedsRemains, 0)
		|			ELSE ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0)
		|		END) AS BedsVacant
		|INTO VacantRoomsDetailed
		|FROM
		|	(SELECT
		|		BEGINOFPERIOD(DATEADD(RoomInventoryBalanceAndTurnovers.Period, SECOND, &qShiftInSeconds), DAY) AS Period,
		|		RoomInventoryBalanceAndTurnovers.Hotel AS Hotel,
		|		RoomInventoryBalanceAndTurnovers.RoomType AS RoomType,
		|		MAX(RoomInventoryBalanceAndTurnovers.CounterClosingBalance) AS CounterClosingBalance,
		|		MAX(ISNULL(RoomInventoryBalanceAndTurnovers.TotalRoomsClosingBalance, 0)) AS TotalRoomsClosingBalance,
		|		MAX(ISNULL(RoomInventoryBalanceAndTurnovers.TotalBedsClosingBalance, 0)) AS TotalBedsClosingBalance,
		|		MIN(ISNULL(RoomInventoryBalanceAndTurnovers.RoomsVacantClosingBalance, 0)) AS RoomsVacantClosingBalance,
		|		MIN(ISNULL(RoomInventoryBalanceAndTurnovers.BedsVacantClosingBalance, 0)) AS BedsVacantClosingBalance
		|	FROM
		|		AccumulationRegister.RoomInventory.BalanceAndTurnovers(
		|				&qDateTimeFrom,
		|				&qDateTimeTo,
		|				Minute,
		|				RegisterRecordsAndPeriodBoundaries,
		|				&qHotelIsEmpty
		|					OR Hotel IN HIERARCHY (&qHotel)) AS RoomInventoryBalanceAndTurnovers
		|	
		|	GROUP BY
		|		BEGINOFPERIOD(DATEADD(RoomInventoryBalanceAndTurnovers.Period, SECOND, &qShiftInSeconds), DAY),
		|		RoomInventoryBalanceAndTurnovers.Hotel,
		|		RoomInventoryBalanceAndTurnovers.RoomType) AS RoomInventoryBalance
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
		|
		|GROUP BY
		|	BEGINOFPERIOD(RoomInventoryBalance.Period, DAY),
		|	RoomInventoryBalance.Hotel,
		|	RoomInventoryBalance.RoomType
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT
		|	ExpectedGuestGroupsTurnovers.Hotel AS Hotel,
		|	ExpectedGuestGroupsTurnovers.RoomType AS RoomType,
		|	ExpectedGuestGroupsTurnovers.Period AS Period,
		|	ExpectedGuestGroupsTurnovers.RoomsReservedTurnover AS PreliminaryRooms,
		|	ExpectedGuestGroupsTurnovers.BedsReservedTurnover AS PreliminaryBeds
		|INTO PreliminaryReservations
		|FROM
		|	AccumulationRegister.ExpectedGuestGroups.Turnovers(
		|			&qDateFrom,
		|			&qDateTo,
		|			Day,
		|			&qShowPreliminary
		|				AND (Hotel = &qHotel
		|					OR &qHotelIsEmpty)
		|				AND (&qRoomQuotaIsSet
		|						AND RoomQuota = &qRoomQuota
		|					OR NOT &qRoomQuotaIsSet)) AS ExpectedGuestGroupsTurnovers
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT
		|	RoomInventory.Period AS Period,
		|	RoomInventory.Hotel AS Hotel,
		|	RoomInventory.Hotel.SortCode AS HotelSortCode,
		|	RoomInventory.RoomType AS RoomType,
		|	RoomInventory.RoomType.SortCode AS RoomTypeSortCode,
		|	RoomInventory.TotalRooms AS TotalRooms,
		|	RoomInventory.TotalBeds AS TotalBeds,
		|	RoomInventory.RoomsVacant AS RoomsVacant,
		|	RoomInventory.BedsVacant AS BedsVacant,
		|	ISNULL(PreliminaryReservations.PreliminaryRooms, 0) AS PreliminaryRooms,
		|	ISNULL(PreliminaryReservations.PreliminaryBeds, 0) AS PreliminaryBeds
		|FROM
		|	VacantRoomsDetailed AS RoomInventory
		|		LEFT JOIN PreliminaryReservations AS PreliminaryReservations
		|		ON RoomInventory.Period = PreliminaryReservations.Period
		|			AND RoomInventory.Hotel = PreliminaryReservations.Hotel
		|			AND RoomInventory.RoomType = PreliminaryReservations.RoomType
		|WHERE
		|	NOT RoomInventory.RoomType.DeletionMark" +
		?(ValueIsFilled(SessionParameters.CurrentUser.Customer)," AND RoomInventory.RoomsVacant <> 0 AND RoomInventory.BedsVacant <> 0 ", "") + "
		|ORDER BY
		|	HotelSortCode,
		|	RoomTypeSortCode,
		|	Period
		|TOTALS
		|	SUM(TotalRooms),
		|	SUM(TotalBeds),
		|	SUM(RoomsVacant),
		|	SUM(BedsVacant),
		|	SUM(PreliminaryRooms),
		|	SUM(PreliminaryBeds)
		|BY
		|	Hotel HIERARCHY,
		|	RoomType HIERARCHY,
		|	Period";
		
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
		
		"SELECT ALLOWED
		|	BEGINOFPERIOD(RoomInventoryBalance.Period, DAY) AS Period,
		|	RoomInventoryBalance.Hotel AS Hotel,
		|	RoomInventoryBalance.RoomType AS RoomType,
		|	MAX(CASE
		|			WHEN &qRoomQuotaIsSet
		|					AND &qDoWriteOff
		|				THEN ISNULL(RoomQuotaBalances.RoomsInQuota, 0)
		|			WHEN &qRoomQuotaIsSet
		|					AND NOT &qDoWriteOff
		|				THEN ISNULL(RoomInventoryBalance.TotalRoomsClosingBalance, 0)
		|			ELSE ISNULL(RoomInventoryBalance.TotalRoomsClosingBalance, 0)
		|		END) AS TotalRooms,
		|	MAX(CASE
		|			WHEN &qRoomQuotaIsSet
		|					AND &qDoWriteOff
		|				THEN ISNULL(RoomQuotaBalances.BedsInQuota, 0)
		|			WHEN &qRoomQuotaIsSet
		|					AND NOT &qDoWriteOff
		|				THEN ISNULL(RoomInventoryBalance.TotalBedsClosingBalance, 0)
		|			ELSE ISNULL(RoomInventoryBalance.TotalBedsClosingBalance, 0)
		|		END) AS TotalBeds,
		|	MIN(CASE
		|			WHEN &qRoomQuotaIsSet
		|					AND &qDoWriteOff
		|				THEN ISNULL(RoomQuotaBalances.RoomsRemains, 0)
		|			WHEN &qRoomQuotaIsSet
		|					AND NOT &qDoWriteOff
		|					AND ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0) < ISNULL(RoomQuotaBalances.RoomsRemains, 0)
		|				THEN ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0)
		|			WHEN &qRoomQuotaIsSet
		|					AND NOT &qDoWriteOff
		|					AND ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0) >= ISNULL(RoomQuotaBalances.RoomsRemains, 0)
		|				THEN ISNULL(RoomQuotaBalances.RoomsRemains, 0)
		|			ELSE ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0)
		|		END) AS RoomsVacant,
		|	MIN(CASE
		|			WHEN &qRoomQuotaIsSet
		|					AND &qDoWriteOff
		|				THEN ISNULL(RoomQuotaBalances.BedsRemains, 0)
		|			WHEN &qRoomQuotaIsSet
		|					AND NOT &qDoWriteOff
		|					AND ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0) < ISNULL(RoomQuotaBalances.BedsRemains, 0)
		|				THEN ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0)
		|			WHEN &qRoomQuotaIsSet
		|					AND NOT &qDoWriteOff
		|					AND ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0) >= ISNULL(RoomQuotaBalances.BedsRemains, 0)
		|				THEN ISNULL(RoomQuotaBalances.BedsRemains, 0)
		|			ELSE ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0)
		|		END) AS BedsVacant
		|INTO VacantRoomsDetailed
		|FROM
		|	(SELECT
		|		BEGINOFPERIOD(DATEADD(RoomInventoryBalanceAndTurnovers.Period, SECOND, &qShiftInSeconds), DAY) AS Period,
		|		RoomInventoryBalanceAndTurnovers.Hotel AS Hotel,
		|		RoomInventoryBalanceAndTurnovers.RoomType AS RoomType,
		|		MAX(RoomInventoryBalanceAndTurnovers.CounterClosingBalance) AS CounterClosingBalance,
		|		MAX(ISNULL(RoomInventoryBalanceAndTurnovers.TotalRoomsClosingBalance, 0)) AS TotalRoomsClosingBalance,
		|		MAX(ISNULL(RoomInventoryBalanceAndTurnovers.TotalBedsClosingBalance, 0)) AS TotalBedsClosingBalance,
		|		MIN(ISNULL(RoomInventoryBalanceAndTurnovers.RoomsVacantClosingBalance, 0)) AS RoomsVacantClosingBalance,
		|		MIN(ISNULL(RoomInventoryBalanceAndTurnovers.BedsVacantClosingBalance, 0)) AS BedsVacantClosingBalance
		|	FROM
		|		AccumulationRegister.RoomInventory.BalanceAndTurnovers(
		|				&qDateTimeFrom,
		|				&qDateTimeTo,
		|				Minute,
		|				RegisterRecordsAndPeriodBoundaries,
		|				(&qHotelIsEmpty
		|					OR Hotel IN HIERARCHY (&qHotel)) И (Room в (выбрать т.Номер из ВТ_Номера как т) или Room = VALUE(Catalog.Rooms.EmptyRef))
		|					) AS RoomInventoryBalanceAndTurnovers
		|	GROUP BY
		|		BEGINOFPERIOD(DATEADD(RoomInventoryBalanceAndTurnovers.Period, SECOND, &qShiftInSeconds), DAY),
		|		RoomInventoryBalanceAndTurnovers.Hotel,
		|		RoomInventoryBalanceAndTurnovers.RoomType) AS RoomInventoryBalance
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
		|						AND RoomQuota = &qRoomQuota и Room в (Выбрать т.Номер из ВТ_Номера как Т)) AS RoomQuotaSalesBalanceAndTurnovers) AS RoomQuotaBalances
		|		ON RoomInventoryBalance.Hotel = RoomQuotaBalances.Hotel
		|			AND RoomInventoryBalance.RoomType = RoomQuotaBalances.RoomType
		|			AND (BEGINOFPERIOD(RoomInventoryBalance.Period, DAY) = BEGINOFPERIOD(RoomQuotaBalances.Period, DAY))
		|
		|GROUP BY
		|	BEGINOFPERIOD(RoomInventoryBalance.Period, DAY),
		|	RoomInventoryBalance.Hotel,
		|	RoomInventoryBalance.RoomType
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT
		|	ExpectedGuestGroupsTurnovers.Hotel AS Hotel,
		|	ExpectedGuestGroupsTurnovers.RoomType AS RoomType,
		|	ExpectedGuestGroupsTurnovers.Period AS Period,
		|	ExpectedGuestGroupsTurnovers.RoomsReservedTurnover AS PreliminaryRooms,
		|	ExpectedGuestGroupsTurnovers.BedsReservedTurnover AS PreliminaryBeds
		|INTO PreliminaryReservations
		|FROM
		|	AccumulationRegister.ExpectedGuestGroups.Turnovers(
		|			&qDateFrom,
		|			&qDateTo,
		|			Day,
		|			&qShowPreliminary
		|				AND (Hotel = &qHotel
		|					OR &qHotelIsEmpty)
		|				AND (&qRoomQuotaIsSet
		|						AND RoomQuota = &qRoomQuota
		|					OR NOT &qRoomQuotaIsSet)) AS ExpectedGuestGroupsTurnovers
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT
		|	RoomInventory.Period AS Period,
		|	RoomInventory.Hotel AS Hotel,
		|	RoomInventory.Hotel.SortCode AS HotelSortCode,
		|	RoomInventory.RoomType AS RoomType,
		|	RoomInventory.RoomType.SortCode AS RoomTypeSortCode,
		|	RoomInventory.TotalRooms AS TotalRooms,
		|	RoomInventory.TotalBeds AS TotalBeds,
		|	RoomInventory.RoomsVacant AS RoomsVacant,
		|	RoomInventory.BedsVacant AS BedsVacant,
		|	ISNULL(PreliminaryReservations.PreliminaryRooms, 0) AS PreliminaryRooms,
		|	ISNULL(PreliminaryReservations.PreliminaryBeds, 0) AS PreliminaryBeds
		|FROM
		|	VacantRoomsDetailed AS RoomInventory
		|		LEFT JOIN PreliminaryReservations AS PreliminaryReservations
		|		ON RoomInventory.Period = PreliminaryReservations.Period
		|			AND RoomInventory.Hotel = PreliminaryReservations.Hotel
		|			AND RoomInventory.RoomType = PreliminaryReservations.RoomType
		|WHERE
		|	NOT RoomInventory.RoomType.DeletionMark" +
		?(ValueIsFilled(SessionParameters.CurrentUser.Customer)," AND RoomInventory.RoomsVacant <> 0 AND RoomInventory.BedsVacant <> 0 ", "") + "
		|ORDER BY
		|	HotelSortCode,
		|	RoomTypeSortCode,
		|	Period
		|TOTALS
		|	SUM(TotalRooms),
		|	SUM(TotalBeds),
		|	SUM(RoomsVacant),
		|	SUM(BedsVacant),
		|	SUM(PreliminaryRooms),
		|	SUM(PreliminaryBeds)
		|BY
		|	Hotel HIERARCHY,
		|	RoomType HIERARCHY,
		|	Period";
		
	КонецЕсли;	
	#КонецВставки
	#Удаление
	vQry = New Query();
	vQry.Text =	
	"SELECT
	|	BEGINOFPERIOD(RoomInventoryBalance.Period, DAY) AS Period,
	|	RoomInventoryBalance.Hotel AS Hotel,
	|	RoomInventoryBalance.RoomType AS RoomType,
	|	MAX(CASE
	|			WHEN &qRoomQuotaIsSet
	|					AND &qDoWriteOff
	|				THEN ISNULL(RoomQuotaBalances.RoomsInQuota, 0)
	|			WHEN &qRoomQuotaIsSet
	|					AND NOT &qDoWriteOff
	|				THEN ISNULL(RoomInventoryBalance.TotalRoomsClosingBalance, 0)
	|			ELSE ISNULL(RoomInventoryBalance.TotalRoomsClosingBalance, 0)
	|		END) AS TotalRooms,
	|	MAX(CASE
	|			WHEN &qRoomQuotaIsSet
	|					AND &qDoWriteOff
	|				THEN ISNULL(RoomQuotaBalances.BedsInQuota, 0)
	|			WHEN &qRoomQuotaIsSet
	|					AND NOT &qDoWriteOff
	|				THEN ISNULL(RoomInventoryBalance.TotalBedsClosingBalance, 0)
	|			ELSE ISNULL(RoomInventoryBalance.TotalBedsClosingBalance, 0)
	|		END) AS TotalBeds,
	|	MIN(CASE
	|			WHEN &qRoomQuotaIsSet
	|					AND &qDoWriteOff
	|				THEN ISNULL(RoomQuotaBalances.RoomsRemains, 0)
	|			WHEN &qRoomQuotaIsSet
	|					AND NOT &qDoWriteOff
	|					AND ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0) < ISNULL(RoomQuotaBalances.RoomsRemains, 0)
	|				THEN ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0)
	|			WHEN &qRoomQuotaIsSet
	|					AND NOT &qDoWriteOff
	|					AND ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0) >= ISNULL(RoomQuotaBalances.RoomsRemains, 0)
	|				THEN ISNULL(RoomQuotaBalances.RoomsRemains, 0)
	|			ELSE ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0)
	|		END) AS RoomsVacant,
	|	MIN(CASE
	|			WHEN &qRoomQuotaIsSet
	|					AND &qDoWriteOff
	|				THEN ISNULL(RoomQuotaBalances.BedsRemains, 0)
	|			WHEN &qRoomQuotaIsSet
	|					AND NOT &qDoWriteOff
	|					AND ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0) < ISNULL(RoomQuotaBalances.BedsRemains, 0)
	|				THEN ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0)
	|			WHEN &qRoomQuotaIsSet
	|					AND NOT &qDoWriteOff
	|					AND ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0) >= ISNULL(RoomQuotaBalances.BedsRemains, 0)
	|				THEN ISNULL(RoomQuotaBalances.BedsRemains, 0)
	|			ELSE ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0)
	|		END) AS BedsVacant
	|INTO VacantRoomsDetailed
	|FROM
	|	(SELECT
	|		BEGINOFPERIOD(DATEADD(RoomInventoryBalanceAndTurnovers.Period, SECOND, &qShiftInSeconds), DAY) AS Period,
	|		RoomInventoryBalanceAndTurnovers.Hotel AS Hotel,
	|		RoomInventoryBalanceAndTurnovers.RoomType AS RoomType,
	|		MAX(RoomInventoryBalanceAndTurnovers.CounterClosingBalance) AS CounterClosingBalance,
	|		MAX(ISNULL(RoomInventoryBalanceAndTurnovers.TotalRoomsClosingBalance, 0)) AS TotalRoomsClosingBalance,
	|		MAX(ISNULL(RoomInventoryBalanceAndTurnovers.TotalBedsClosingBalance, 0)) AS TotalBedsClosingBalance,
	|		MIN(ISNULL(RoomInventoryBalanceAndTurnovers.RoomsVacantClosingBalance, 0)) AS RoomsVacantClosingBalance,
	|		MIN(ISNULL(RoomInventoryBalanceAndTurnovers.BedsVacantClosingBalance, 0)) AS BedsVacantClosingBalance
	|	FROM
	|		AccumulationRegister.RoomInventory.BalanceAndTurnovers(
	|				&qDateTimeFrom,
	|				&qDateTimeTo,
	|				Minute,
	|				RegisterRecordsAndPeriodBoundaries,
	|				&qHotelIsEmpty
	|					OR Hotel IN HIERARCHY (&qHotel)) AS RoomInventoryBalanceAndTurnovers
	|	
	|	GROUP BY
	|		BEGINOFPERIOD(DATEADD(RoomInventoryBalanceAndTurnovers.Period, SECOND, &qShiftInSeconds), DAY),
	|		RoomInventoryBalanceAndTurnovers.Hotel,
	|		RoomInventoryBalanceAndTurnovers.RoomType) AS RoomInventoryBalance
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
	|
	|GROUP BY
	|	BEGINOFPERIOD(RoomInventoryBalance.Period, DAY),
	|	RoomInventoryBalance.Hotel,
	|	RoomInventoryBalance.RoomType
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	ExpectedGuestGroupsTurnovers.Hotel AS Hotel,
	|	ExpectedGuestGroupsTurnovers.RoomType AS RoomType,
	|	ExpectedGuestGroupsTurnovers.Period AS Period,
	|	ExpectedGuestGroupsTurnovers.RoomsReservedTurnover AS PreliminaryRooms,
	|	ExpectedGuestGroupsTurnovers.BedsReservedTurnover AS PreliminaryBeds
	|INTO PreliminaryReservations
	|FROM
	|	AccumulationRegister.ExpectedGuestGroups.Turnovers(
	|			&qDateFrom,
	|			&qDateTo,
	|			Day,
	|			&qShowPreliminary
	|				AND (Hotel = &qHotel
	|					OR &qHotelIsEmpty)
	|				AND (&qRoomQuotaIsSet
	|						AND RoomQuota = &qRoomQuota
	|					OR NOT &qRoomQuotaIsSet)) AS ExpectedGuestGroupsTurnovers
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	RoomInventory.Period AS Period,
	|	RoomInventory.Hotel AS Hotel,
	|	RoomInventory.Hotel.SortCode AS HotelSortCode,
	|	RoomInventory.RoomType AS RoomType,
	|	RoomInventory.RoomType.SortCode AS RoomTypeSortCode,
	|	RoomInventory.TotalRooms AS TotalRooms,
	|	RoomInventory.TotalBeds AS TotalBeds,
	|	RoomInventory.RoomsVacant AS RoomsVacant,
	|	RoomInventory.BedsVacant AS BedsVacant,
	|	ISNULL(PreliminaryReservations.PreliminaryRooms, 0) AS PreliminaryRooms,
	|	ISNULL(PreliminaryReservations.PreliminaryBeds, 0) AS PreliminaryBeds
	|FROM
	|	VacantRoomsDetailed AS RoomInventory
	|		LEFT JOIN PreliminaryReservations AS PreliminaryReservations
	|		ON RoomInventory.Period = PreliminaryReservations.Period
	|			AND RoomInventory.Hotel = PreliminaryReservations.Hotel
	|			AND RoomInventory.RoomType = PreliminaryReservations.RoomType
	|WHERE
	|	NOT RoomInventory.RoomType.DeletionMark " +
	?(ValueIsFilled(SessionParameters.CurrentUser.Customer)," AND RoomInventory.RoomsVacant <> 0 AND RoomInventory.BedsVacant <> 0 ", "") + "
	|ORDER BY
	|	HotelSortCode,
	|	RoomTypeSortCode,
	|	Period
	|TOTALS
	|	SUM(TotalRooms),
	|	SUM(TotalBeds),
	|	SUM(RoomsVacant),
	|	SUM(BedsVacant),
	|	SUM(PreliminaryRooms),
	|	SUM(PreliminaryBeds)
	|BY
	|	Hotel HIERARCHY,
	|	RoomType HIERARCHY,
	|	Period";
	#КонецУдаления
	vQry.SetParameter("qHotel", Hotel);
	vQry.SetParameter("qHotelIsEmpty", Not ValueIsFilled(Hotel));
	vQry.SetParameter("qRoomQuota", RoomQuota);
	vQry.SetParameter("qRoomQuotaIsSet", ValueIsFilled(RoomQuota));
	vQry.SetParameter("qDoWriteOff", ?(ValueIsFilled(RoomQuota), RoomQuota.DoWriteOff, False));
	vQry.SetParameter("qDateTimeFrom", vDateTimeFrom);
	vQry.SetParameter("qDateTimeTo", vDateTimeTo);
	vQry.SetParameter("qDateFrom", vDateFrom);
	vQry.SetParameter("qDateTo", EndOfDay(vDateTo));
	vQry.SetParameter("qShiftInSeconds", ?(ValueIsFilled(RoomRate), -(RoomRate.ReferenceHour - BegOfDay(RoomRate.ReferenceHour)), -43200));
	vQry.SetParameter("qShowPreliminary", ShowPreliminary);
	vQryRes = vQry.Execute();

	// Fill end of day balances and periods
	vPeriods = New ValueList();
	vQryHotels = vQryRes.Select(QueryResultIteration.ByGroups, "Hotel");
	While vQryHotels.Next() Do
		// Save all periods where vacant resource is changed
		vQryHours = vQryHotels.Select(QueryResultIteration.ByGroups, "Period", "ALL");
		While vQryHours.Next() Do
			vPeriod = BegOfDay(vQryHours.Period);
			If (vPeriod < BegOfDay(vDateTimeFrom)) Or (vPeriod > EndOfDay(vDateTimeTo)) Then
				Continue;
			EndIf;
			If vPeriods.FindByValue(vPeriod) = Undefined Then
				vPeriods.Add(vPeriod); 
			EndIf;
		EndDo;
	EndDo;
	// Sort periods chronologically
	vPeriods.SortByValue();
	NumberOfPeriods = vPeriods.Count();

	// Draw header
	vSpreadsheet = Report;
	vSpreadsheet.Clear();
	vSpreadsheet.ShowGroups = True;

	// Setup default attributes
	cmSetDefaultPrintFormSettings(vSpreadsheet, PageOrientation.Landscape, False);
	vSpreadsheet.FixedTop = 5;
	vSpreadsheet.FixedLeft = 2;

	If ShowPrices Then 
		vTemplate 	= GetCommonTemplate("AvailableRoomsReportTemplateWithPrices");
		vDaysInPage = 7;
	ElsIf ShowPreliminary Then 
		vTemplate = GetCommonTemplate("AvailableRoomsReportTemplateWithPreliminary");
		vDaysInPage = 21;
	Else
		vTemplate = GetCommonTemplate("AvailableRoomsReportTemplate");
		vDaysInPage = 21;
	EndIf;
	vArea = vTemplate.GetArea("Header|NamesColumn");
	If vShowReportsInBeds Then
		vArea.Parameters.mReportHeaderText = NStr("en='Vacant beds';ru='Свободные места';de='Freie Betten'");
	Else
		vArea.Parameters.mReportHeaderText = NStr("en='Vacant rooms';ru='Свободные номера';de='Freie Zimmer'");
	EndIf;

	vAllotmentText = ?(ValueIsFilled(RoomQuota), RoomQuota, NStr("en = 'Empty'; de = 'Leeren'; ru = 'Нет'"));
	vRoomRateText = ?(ValueIsFilled(RoomRate), RoomRate, NStr("en = 'Empty'; de = 'Leeren'; ru = 'Нет'"));
	vMealBoardText = ?(ValueIsFilled(MealBoardTerm), MealBoardTerm, NStr("en = 'Default'; de = 'Standard'; ru = 'По умолчанию'"));	
	vFilterText = NStr("en = 'Filter: '; de = 'Filter: '; ru = 'Отбор: '") + StrTemplate(NStr("en = 'Allotment: %1; Room rate: %2; Terms: %3'; de = 'Allotment: %1; Tarif: %2; Terms: %3'; ru = 'Квота: %1; Тариф: %2; Питание: %3'"), vAllotmentText, vRoomRateText, vMealBoardText);
	vFilterArea = vTemplate.GetArea("Filter|NamesColumn");
	vFilterArea.Parameters.Filter = vFilterText;
	//vSpreadsheet.Put(vFilterArea);

	vSpreadsheet.Put(vArea);

	// Draw occupation percent
	vEndOfPrevDay = False;
	vDayGroup = False;
	vLastDate = Undefined;

	vOccupationPercentList = GetOccupationPercent(Hotel, vDateTimeFrom, vDateTimeTo);
	i = 0;
	For Each vPeriodItem In vPeriods Do
		vPeriod = vPeriodItem.Value;
		vCurDate = BegOfDay(vPeriod);
		If vLastDate = Undefined Or vCurDate <> vLastDate Then
			vLastDate = vCurDate;
			vEndOfPrevDay = True;
		EndIf;
		mDay = Day(vCurDate);
		mDayOfWeek = cmGetDayOfWeekName(WeekDay(vCurDate), True);
		mMonth = Format(vPeriod, "DF=MMMM");		

		If vEndOfPrevDay Then
			vEndOfPrevDay = False;
			If vCurDate = BegOfMonth(vCurDate) Or vCurDate = vDateFrom Then
				vArea = vTemplate.GetArea("Header|FirstDayOfMonth");
				vArea.Parameters.mMonth = mMonth;
			ElsIf WeekDay(vCurDate) = 1 Then
				vArea = vTemplate.GetArea("Header|FirstDayOfWeek");
			Else
				vArea = vTemplate.GetArea("Header|FirstHourOfDay");
			EndIf;
			vArea.Parameters.mDay = mDay;
			vArea.Parameters.mDayOfWeek = mDayOfWeek;

			vFilter = vOccupationPercentList.FindRows(New Structure("Period",vCurDate));
			If vFilter.Count()>0 Then

				vRow = vFilter[0];
				vTotalRooms		= vRow.TotalRooms;
				vRoomsBlocked 	= -vRow.RoomsBlocked;
				vRoomsRented 	= vRow.RoomsRented;

				vArea.Parameters.mPercent = Format(Round(?((vTotalRooms-vRoomsBlocked) = 0, 0, 100 * vRoomsRented/(vTotalRooms - vRoomsBlocked)), 0), "NFD=0; NZ=; NG=") + ?(ShowPrices Or ShowPreliminary, "%", "");
			Else
				vArea.Parameters.mPercent = "0" + ?(ShowPrices Or ShowPreliminary, "%", "");
			EndIf;	
		Else
			vArea = vTemplate.GetArea("Header|Day");
		EndIf;

		If i = vDaysInPage Then
			i = 0;
		EndIf;

		i = i + 1;
		vSpreadsheet.Join(vArea);
	EndDo;

	// Output events
	If vEvents.Count() > 0 Then
		vArea = vTemplate.GetArea("EventRow|NamesColumn");
		vSpreadsheet.Put(vArea);

		vEventsRow = Undefined;
		vEndOfPrevDay = False;
		vLastDate = Undefined;
		vCommentIsPlaced = False;
		For Each vPeriodItem In vPeriods Do
			vPeriod = vPeriodItem.Value;
			vCurDate = BegOfDay(vPeriod);
			If vLastDate = Undefined Or vCurDate <> vLastDate Then
				vLastDate = vCurDate;
				vEndOfPrevDay = True;
			EndIf;

			// Try to find event starting from this date
			vThisIsFirstPeriodOfEvent = False;
			vProbeEventsRow = vEvents.Find(vCurDate, "DateFrom");
			If vProbeEventsRow <> Undefined Then
				If vEventsRow = Undefined Then
					vEventsRow = vProbeEventsRow;
					vThisIsFirstPeriodOfEvent = True;
					vCommentIsPlaced = False;
				Else
					If vEventsRow <> vProbeEventsRow Then
						vEventsRow = vProbeEventsRow;
						vThisIsFirstPeriodOfEvent = True;
						vCommentIsPlaced = False;
					EndIf;
				EndIf;
			EndIf;

			vAreaRowName = "NoEventRow";
			If vEventsRow <> Undefined Then
				If vCurDate > vEventsRow.DateTo Or vCurDate < vEventsRow.DateFrom Then
					vEventsRow = Undefined;
				Else
					vAreaRowName = "EventRow";
				EndIf;
			EndIf;

			If vEndOfPrevDay Then
				vEndOfPrevDay = False;
				If vCurDate = BegOfMonth(vCurDate) Or vCurDate = vDateFrom Then
					vArea = vTemplate.GetArea(vAreaRowName + "|FirstDayOfMonth");
				ElsIf WeekDay(vCurDate) = 1 Then
					vArea = vTemplate.GetArea(vAreaRowName + "|FirstDayOfWeek");
				Else
					vArea = vTemplate.GetArea(vAreaRowName + "|FirstHourOfDay");
				EndIf;
			Else
				vArea = vTemplate.GetArea(vAreaRowName + "|Day");
			EndIf;
			If vEventsRow <> Undefined And vAreaRowName = "EventRow" Then
				If vThisIsFirstPeriodOfEvent Then
					vArea.Parameters.mEventDescription = TrimAll(vEventsRow.Description);
				Else
					vArea.Parameters.mEventDescription = "";
				EndIf;
				vArea.Parameters.mEvent = vEventsRow.Ref;
			ElsIf vAreaRowName = "NoEventRow" Then
				vArea.Parameters.mEvent = Catalogs.Events.EmptyRef();
			EndIf;
			vOutputArea = vSpreadsheet.Join(vArea);
			If vEventsRow <> Undefined And vAreaRowName = "EventRow" Then
				vEventColor = Undefined;
				If vEventsRow.Color <> Undefined Then
					vEventColor = vEventsRow.Color.Get();
				EndIf;
				If vEventColor <> Undefined Then
					vOutputArea.BackColor = vEventColor;
				EndIf;
				vOutputArea.RightBorder = New Line(SpreadsheetDocumentCellLineType.None, 1);
				If Not vThisIsFirstPeriodOfEvent Then
					vOutputArea.LeftBorder = New Line(SpreadsheetDocumentCellLineType.None, 1);
					vOutputArea.Clear(True);
				EndIf;
				If vEventsRow.DateTo = BegOfDay(vCurDate) And Not vCommentIsPlaced Then
					vCommentIsPlaced = True;
					vOutputArea.Comment.Text = Chars.LF + Chars.LF + TrimAll(Format(vEventsRow.DateFrom, "DF=dd.MM.yyyy") + " - " + Format(vEventsRow.DateTo, "DF=dd.MM.yyyy") + Chars.LF +
					TrimAll(vEventsRow.Remarks));
				EndIf;
			EndIf;
		EndDo;
	EndIf;

	// Count maximum value for progress bar
	vNHotels = vQryRes.Select(QueryResultIteration.ByGroups, "Hotel").Count();
	vNRoomTypes = vQryRes.Select(QueryResultIteration.ByGroups, "RoomType").Count();
	vNHours = 1;
	vQryRoomTypes = vQryHotels.Select(QueryResultIteration.ByGroups, "RoomType");
	If vQryRoomTypes <> Undefined Then
		vNHours = vQryRoomTypes.Select(QueryResultIteration.ByGroups, "Period", "ALL").Count();
	EndIf;

	// Build report form
	vQryHotels = vQryRes.Select(QueryResultIteration.ByGroups, "Hotel");
	While vQryHotels.Next() Do
		// Show hotel
		vArea = vTemplate.GetArea("HotelRow|NamesColumn");
		vArea.Parameters.mHotel = TrimAll(vQryHotels.Hotel);
		vQryHours = vQryHotels.Select(QueryResultIteration.ByGroups, "Period", "ALL");
		While vQryHours.Next() Do
			vPeriod = BegOfDay(vQryHours.Period);
			If (vPeriod < BegOfDay(vDateTimeFrom)) Or (vPeriod > EndOfDay(vDateTimeTo)) Then
				Continue;
			EndIf;
			If vPeriods.FindByValue(vPeriod) = Undefined Then
				Continue;
			EndIf;
			vLastTotal = 0;
			vArea.Parameters.mHotel = vArea.Parameters.mHotel + " (" + Format(GetQueryResource(vQryHours, vShowReportsInBeds, vLastTotal, "Total"), "NFD=0; NZ=; NG=") + ")";
			Break;
		EndDo;
		vSpreadsheet.Put(vArea);

		// Show hotel totals by days and hours
		vEndOfPrevDay = False;
		vLastDate = Undefined;
		vLastVacant = 0;
		vCommentHour = 0;
		vQryHours = vQryHotels.Select(QueryResultIteration.ByGroups, "Period", "ALL");
		While vQryHours.Next() Do
			vPeriod = BegOfDay(vQryHours.Period);
			If (vPeriod < BegOfDay(vDateTimeFrom)) Or (vPeriod > EndOfDay(vDateTimeTo)) Then
				Continue;
			EndIf;
			If vPeriods.FindByValue(vPeriod) = Undefined Then
				Continue;
			EndIf;

			vCurDate = BegOfDay(vPeriod);
			If vLastDate = Undefined Or vCurDate <> vLastDate Then
				vLastDate = vCurDate;
				vEndOfPrevDay = True;
			EndIf;

			// Get necessary report template area
			If vEndOfPrevDay Then
				vEndOfPrevDay = False;
				If vCurDate = BegOfMonth(vCurDate) Or vCurDate = vDateFrom Then
					vArea = vTemplate.GetArea("HotelRow|FirstDayOfMonth");
				ElsIf WeekDay(vCurDate) = 1 Then
					vArea = vTemplate.GetArea("HotelRow|FirstDayOfWeek");
				Else
					vArea = vTemplate.GetArea("HotelRow|FirstHourOfDay");
				EndIf;
			Else
				vArea = vTemplate.GetArea("HotelRow|Day");
			EndIf;

			// Fill parameters and join area
			vVacant = GetQueryResource(vQryHours, vShowReportsInBeds, vLastVacant);
			vArea.Parameters.mVacant = String(vVacant);
			If ShowPreliminary Then
				vPreliminary = GetQueryResource(vQryHours, vShowReportsInBeds, vLastVacant, "Preliminary");
				If vPreliminary <> 0 Then
					vArea.Parameters.mVacant = vArea.Parameters.mVacant + " / " + String(vVacant - vPreliminary);
				EndIf;
			EndIf;

			vArea.Parameters.mDetails = New Structure("Hotel, RoomType, PeriodTo", 
			vQryHotels.Hotel, 
			Catalogs.RoomTypes.EmptyRef(), 
			vPeriod);

			If vVacant < 0 Then
				vCell = vArea.Area(1,1,1,1);
				vCell.TextColor = WebColors.Red;
			EndIf;
			vSpreadsheet.Join(vArea);

			vLastVacant = vArea.Parameters.mVacant;
		EndDo;

		// Show room types for this hotel
		vBaseRTTotal = 0;
		vQryRoomTypes = vQryHotels.Select(QueryResultIteration.ByGroups, "RoomType");
		While vQryRoomTypes.Next() Do
			// Show room type
			vAreaCol = "RoomTypeRow";
			If vQryRoomTypes.RoomType.IsFolder Then
				vAreaCol = "RoomTypeFolderRow";
			EndIf;
			vArea = vTemplate.GetArea(vAreaCol + "|NamesColumn");
			If vAreaCol = "RoomTypeRow" Then
				If ShowPrices Then
					vTablePrices = GetPriceByPeriod(vDateTimeFrom,vDateTimeTo+24*60*60,vQryRoomTypes.RoomType);
				EndIf;
				If IsBlankString(vQryRoomTypes.RoomType.DescriptionTranslations) Then
					vArea.CurrentArea.Comment.Text = TrimAll(vQryRoomTypes.RoomType.Description);
				Else	
					vArea.CurrentArea.Comment.Text = cmNStr(vQryRoomTypes.RoomType.DescriptionTranslations, SessionParameters.CurrentLanguage);
				EndIf;
				If Not IsBlankString(vQryRoomTypes.RoomType.Remarks) Then
					vArea.CurrentArea.Comment.Text = vArea.CurrentArea.Comment.Text + Chars.LF + cmNStr(vQryRoomTypes.RoomType.Remarks, SessionParameters.CurrentLanguage);
				EndIf;
			EndIf;
			If vQryRoomTypes.RoomType.IsFolder Then
				vArea.Parameters.mRoomType = cmGetIndent(vQryRoomTypes.RoomType, +1) + TrimR(vQryRoomTypes.RoomType.Description);
			Else
				vArea.Parameters.mRoomType = cmGetIndent(vQryRoomTypes.RoomType, +1) + TrimR(vQryRoomTypes.RoomType.Description);
				If vAreaCol = "RoomTypeRow" Then
					If pTotalPriceTable <> Undefined Then
						vRT = pTotalPriceTable.Find(vQryRoomTypes.RoomType, "RoomType");
						vTotal = 0;
						If vRT <> Undefined Then
							vTotal = vRT.Total;
							vArea.Parameters.mTotal = cmFormatSum(vTotal, vRT.Currency, "NZ =0,00");
						Else
							If vQryRoomTypes.RoomType = SelRoomType Then
								vArea.Parameters.mTotal = cmFormatSum(0, vQryRoomTypes.Hotel.BaseCurrency, "NZ =0,00");
							EndIf;
						EndIf;						
					EndIf;
					vArea.Parameters.mDetails = New Structure("Hotel, RoomType, PeriodTo", 
					vQryRoomTypes.Hotel, 
					?(vQryRoomTypes.RoomType.IsFolder, Catalogs.RoomTypes.EmptyRef(), vQryRoomTypes.RoomType), 
					"");

				EndIf;
			EndIf;
			vQryHours = vQryRoomTypes.Select(QueryResultIteration.ByGroups, "Period", "ALL");
			While vQryHours.Next() Do
				vPeriod = BegOfDay(vQryHours.Period);
				If (vPeriod < BegOfDay(vDateTimeFrom)) Or (vPeriod > EndOfDay(vDateTimeTo)) Then
					Continue;
				EndIf;
				If vPeriods.FindByValue(vPeriod) = Undefined Then
					Continue;
				EndIf;
				vLastTotal = 0;
				vArea.Parameters.mRoomType = vArea.Parameters.mRoomType + " (" + Format(GetQueryResource(vQryHours, vShowReportsInBeds, vLastTotal, "Total"), "NFD=0; NZ=; NG=") + ")";
				Break;
			EndDo;
			vSpreadsheet.Put(vArea);

			// Show room type totals by days
			vLastVacant = 0;
			vCommentHour = 0;
			vEndOfPrevDay = False;
			vLastDate = Undefined;
			vQryHours = vQryRoomTypes.Select(QueryResultIteration.ByGroups, "Period", "ALL");
			While vQryHours.Next() Do
				vPeriod = BegOfDay(vQryHours.Period);
				If (vPeriod < BegOfDay(vDateTimeFrom)) Or (vPeriod > EndOfDay(vDateTimeTo)) Then
					Continue;
				EndIf;
				If vPeriods.FindByValue(vPeriod) = Undefined Then
					Continue;
				EndIf;

				vCurDate = BegOfDay(vPeriod);
				If vLastDate = Undefined Or vCurDate <> vLastDate Then
					vLastDate = vCurDate;
					vEndOfPrevDay = True;
				EndIf;

				// Check room type stop sale
				vStopSaleRemarks = "";
				vAreaCol = "RoomTypeRow";
				If vQryRoomTypes.RoomType.IsFolder Then
					vAreaCol = "RoomTypeFolderRow";
				Else
					If vQryRoomTypes.RoomType.StopSale Then
						If cmIsStopSalePeriod(vQryRoomTypes.RoomType, vPeriod, vPeriod, vStopSaleRemarks, True) Then
							vAreaCol = "RoomTypeStopSaleRow";
						EndIf;
					EndIf;
				EndIf;

				// Get necessary report template area
				If vEndOfPrevDay Then
					vEndOfPrevDay = False;
					If vCurDate = BegOfMonth(vCurDate) Or vCurDate = vDateFrom Then
						vArea = vTemplate.GetArea(vAreaCol + "|FirstDayOfMonth");
					ElsIf WeekDay(vCurDate) = 1 Then
						vArea = vTemplate.GetArea(vAreaCol + "|FirstDayOfWeek");
					Else
						vArea = vTemplate.GetArea(vAreaCol + "|FirstHourOfDay");
					EndIf;
					// Reset comment on first period of a day
					vCommentHour = 0;
				Else
					vArea = vTemplate.GetArea(vAreaCol + "|Day");
				EndIf;

				// Set area parameters
				vVacant = GetQueryResource(vQryHours, vShowReportsInBeds, vLastVacant);
				vArea.Parameters.mVacant = String(vVacant);
				If ShowPreliminary Then
					vPreliminary = GetQueryResource(vQryHours, vShowReportsInBeds, vLastVacant, "Preliminary");
					If vPreliminary <> 0 Then
						vArea.Parameters.mVacant = vArea.Parameters.mVacant + " / " + String(vVacant - vPreliminary);
					EndIf;
				EndIf;

				If Not vAreaCol="RoomTypeFolderRow" And ShowPrices Then
					Try
						If vTablePrices.Columns.Count() > 0 Then
							vFilter = vTablePrices.FindRows(New Structure("Period",vCurDate));
							If vFilter.Count()>0 Then
								vArea.Parameters.mPrice	= cmFormatSum(vFilter[0].Sum,Hotel.ReportingCurrency);
							Else	
								vArea.Parameters.mPrice = cmFormatSum(0,Hotel.ReportingCurrency);
							EndIf;
						EndIf;
					Except
					EndTry;
				EndIf;		

				vArea.Parameters.mDetails = New Structure("Hotel, RoomType, PeriodTo", 
				vQryHotels.Hotel, 
				vQryRoomTypes.RoomType, 
				vPeriod);

				// Set red color to the overbooking										   
				If vVacant < 0 Then
					vCell = vArea.Area(1,1,1,1);
					vCell.TextColor = WebColors.Red;
				EndIf;

				// Add stop sale comment
				If Not IsBlankString(vStopSaleRemarks) Then
					vArea.Area("T").Comment.Text = TrimAll(vArea.Area("T").Comment.Text) + ?(IsBlankString(vArea.Area("T").Comment.Text), "", Chars.LF + Chars.LF) + vStopSaleRemarks;
				EndIf;

				// Join template area to the report
				vSpreadsheet.Join(vArea);

				vLastVacant = vVacant;
			EndDo;
		EndDo;
	EndDo;

	vSpreadsheet.RepeatOnColumnPrint = vSpreadsheet.Area("C1:C2");
	vSpreadsheet.RepeatOnRowPrint = vSpreadsheet.Area("R1:R5");

	// Set report protection
	cmSetSpreadsheetProtection(vSpreadsheet);

	// Set report header
	cmApplyReportHeader(vSpreadsheet);
	// Add configuration name to the right report header
	vSpreadsheet.Header.LeftText = ?(ValueIsFilled(SessionParameters.CurrentHotel), 
	SessionParameters.CurrentHotel.GetObject().pmGetHotelPrintName(SessionParameters.CurrentLanguage), "") + " - " + 
	TrimAll(SessionParameters.ConfigurationPresentation);
	vSpreadsheet.Header.RightText = TrimAll(SessionParameters.CurrentUser) + " - " + Format(CurrentSessionDate(), "DF='dd.MM.yyyy HH:mm'");
	// Set footer
	cmApplyReportFooter(vSpreadsheet);
EndProcedure

