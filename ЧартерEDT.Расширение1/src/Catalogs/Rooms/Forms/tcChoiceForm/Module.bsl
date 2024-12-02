
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
Процедура Расш1_НомернойФондПриИзмененииПосле(Элемент)
	PutData();
КонецПроцедуры


&AtServer
&ChangeAndValidate("PutData")
Procedure Расш1_PutData()
	#Вставка
	SelNumberOfBeds = 0;
	SelNumberOfRooms = 0;
	#КонецВставки
	vRoomStses = GetAllRoomStatuses();
	
	TableBoxRooms.GetItems().Clear();
	Items.TableBoxRoomsVacantFrom.Title = NStr("en='Vacant from ';ru='Свободен с ';de='Frei ab '")+Format(DateFrom, "DF='dd.MM.yyyy HH:mm'");
	Items.TableBoxRoomsVacantTo.Title = NStr("en='Vacant to ';ru='Свободен по ';de='Frei bis '")+Format(DateTo, "DF='dd.MM.yyyy HH:mm'");
	
	// Initialize working vars
	vInBeds = True;
	vTotalVacant = 0;
	vTotalAvailable = 0;
	vUnit = "";
	If SelNumberOfRooms = 0 And SelNumberOfBeds = 0 Then
		If ValueIsFilled(Hotel) Then
			vInBeds = Hotel.ShowReportsInBeds;
		EndIf;
	Else
		If SelNumberOfRooms <> 0 Then
			vInBeds = False;
		EndIf;
	EndIf;
	If vInBeds Then
		vUnit = NStr("en='Beds';ru='Мест';de='Betten'");
	Else
		vUnit = NStr("en='Rooms';ru='Номеров';de='Zimmer'");
	EndIf;
	
	// Check if room status is selected
	vRoomStatus = Undefined;
	vCurPageValue = TempRoomSts.FindRows(New Structure("RoomStsCode", RoomStsCode));
	If vCurPageValue.Count()>0 Then
		If ValueIsFilled(vCurPageValue.Get(0).Value) Then
			vRoomStatus = vCurPageValue.Get(0).Value;
		EndIf;
	EndIf;
	// Initialize working arrays
	vRoomsArray = New Array();
	vRoomPropArray = New Array();
	
	// Clear resulting table
	TableBoxRooms.GetItems().Clear();
	
	// Run query to get rooms in room quota if filled
	vAllotmentByRooms = False;
	vRoomsInQuota = New ValueList();
	If ValueIsFilled(SelRoomQuota) Then
		If Not SelRoomQuota.DeletionMark And SelRoomQuota.IsQuotaForRooms Then
			vAllotmentByRooms = True;
			#Вставка
			Если НомернойФонд.Пустая() Тогда
				vQry = New Query();
				vQry.Text = "SELECT разрешенные
				|	RoomQuotaSales.Room,
				|	RoomQuotaSales.RoomType,
				|	MIN(RoomQuotaSales.CounterClosingBalance) AS CounterClosingBalance,
				|	MIN(RoomQuotaSales.RoomsInQuotaClosingBalance) AS RoomsInQuotaClosingBalance,
				|	MIN(RoomQuotaSales.BedsInQuotaClosingBalance) AS BedsInQuotaClosingBalance
				|FROM
				|	AccumulationRegister.RoomQuotaSales.BalanceAndTurnovers(
				|			&qDateFrom,
				|			&qDateTo,
				|			Second,
				|			RegisterRecordsAndPeriodBoundaries, " + 
				?(ValueIsFilled(Hotel), "Hotel IN HIERARCHY (&qHotel)", "TRUE") + 
				?(ValueIsFilled(SelRoomType), " AND RoomType IN HIERARCHY (&qRoomType)", "") + "
				|				AND RoomQuota = &qRoomQuota) AS RoomQuotaSales
				|WHERE " + 
				?(ValueIsFilled(Company), " (RoomQuotaSales.RoomType.Company = &qCompany) OR (RoomQuotaSales.Room.Company = &qCompany) OR (RoomQuotaSales.RoomType.Company = &qEmptyCompany AND RoomQuotaSales.Room.Company = &qEmptyCompany)", "TRUE") + "
				|
				|GROUP BY
				|	RoomQuotaSales.Room,
				|	RoomQuotaSales.RoomType
				|
				|ORDER BY
				|	RoomQuotaSales.Room.SortCode";
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
				vQry.Text = "SELECT разрешенные
				|	RoomQuotaSales.Room,
				|	RoomQuotaSales.RoomType,
				|	MIN(RoomQuotaSales.CounterClosingBalance) AS CounterClosingBalance,
				|	MIN(RoomQuotaSales.RoomsInQuotaClosingBalance) AS RoomsInQuotaClosingBalance,
				|	MIN(RoomQuotaSales.BedsInQuotaClosingBalance) AS BedsInQuotaClosingBalance
				|FROM
				|	AccumulationRegister.RoomQuotaSales.BalanceAndTurnovers(
				|			&qDateFrom,
				|			&qDateTo,
				|			Second,
				|			RegisterRecordsAndPeriodBoundaries," + 
				?(ValueIsFilled(Hotel), "Hotel IN HIERARCHY (&qHotel)", "TRUE") + 
				?(ValueIsFilled(SelRoomType), " AND RoomType IN HIERARCHY (&qRoomType)", "") + "
				|				AND RoomQuota = &qRoomQuota и Room in (Выбрать Т.Номер Из ВТ_Номера Как Т)) AS RoomQuotaSales
				|WHERE " + 
				?(ValueIsFilled(Company), " (RoomQuotaSales.RoomType.Company = &qCompany) OR (RoomQuotaSales.Room.Company = &qCompany) OR (RoomQuotaSales.RoomType.Company = &qEmptyCompany AND RoomQuotaSales.Room.Company = &qEmptyCompany)", "TRUE") + "
				|
				|GROUP BY
				|	RoomQuotaSales.Room,
				|	RoomQuotaSales.RoomType
				|
				|ORDER BY
				|	RoomQuotaSales.Room.SortCode";
			КонецЕсли;
			#КонецВставки
			
			#Удаление
			vQry = New Query();
			vQry.Text = "SELECT
			|	RoomQuotaSales.Room,
			|	RoomQuotaSales.RoomType,
			|	MIN(RoomQuotaSales.CounterClosingBalance) AS CounterClosingBalance,
			|	MIN(RoomQuotaSales.RoomsInQuotaClosingBalance) AS RoomsInQuotaClosingBalance,
			|	MIN(RoomQuotaSales.BedsInQuotaClosingBalance) AS BedsInQuotaClosingBalance
			|FROM
			|	AccumulationRegister.RoomQuotaSales.BalanceAndTurnovers(
			|			&qDateFrom,
			|			&qDateTo,
			|			Second,
			|			RegisterRecordsAndPeriodBoundaries, " + 
			?(ValueIsFilled(Hotel), "Hotel IN HIERARCHY (&qHotel)", "TRUE") + 
			?(ValueIsFilled(SelRoomType), " AND RoomType IN HIERARCHY (&qRoomType)", "") + "
			|				AND RoomQuota = &qRoomQuota) AS RoomQuotaSales
			|WHERE " + 
			?(ValueIsFilled(Company), " (RoomQuotaSales.RoomType.Company = &qCompany) OR (RoomQuotaSales.Room.Company = &qCompany) OR (RoomQuotaSales.RoomType.Company = &qEmptyCompany AND RoomQuotaSales.Room.Company = &qEmptyCompany)", "TRUE") + "
			|
			|GROUP BY
			|	RoomQuotaSales.Room,
			|	RoomQuotaSales.RoomType
			|
			|ORDER BY
			|	RoomQuotaSales.Room.SortCode";
			#КонецУдаления
			vQry.SetParameter("qRoomQuota", SelRoomQuota);
			vQry.SetParameter("qHotel", Hotel);
			vQry.SetParameter("qRoomType", SelRoomType);
			vQry.SetParameter("qDateFrom", DateFrom);
			vQry.SetParameter("qDateTo", New Boundary(DateTo, BoundaryType.Excluding));
			vQry.SetParameter("qCompany", Company);
			vQry.SetParameter("qEmptyCompany", Catalogs.Companies.EmptyRef());
			vQryResults = vQry.Execute().Unload();
			For Each vQryResultsRow In vQryResults Do
				vRoomsInQuota.Add(vQryResultsRow.Room);
			EndDo;
		EndIf;
	EndIf;
	
	// Run query to get number of vacant rooms for room types
	#Вставка
	Если НомернойФонд.Пустая() Тогда
		vQry = New Query();
		vQry.Text = 
		"SELECT Разрешенные
		|	RoomTypes.RoomType AS RoomType,
		|	RoomTypes.RoomType.SortCode AS RoomTypeSortCode,
		|	RoomTypes.BedsVacant AS BedsVacant,
		|	RoomTypes.RoomsVacant AS RoomsVacant,
		|	RoomTypes.RoomType.Company AS Company
		|
		|FROM(
		|	SELECT
		|		RoomTypesBalance.RoomType AS RoomType,
		|		MAX(RoomTypesBalance.TotalBeds) AS TotalBeds,
		|		MAX(RoomTypesBalance.TotalRooms) AS TotalRooms,
		|		MAX(RoomTypesBalance.BedsVacant) AS BedsVacant,
		|		MAX(RoomTypesBalance.RoomsVacant) AS RoomsVacant
		|	FROM (
		|		SELECT
		|			RoomInventoryBalance.RoomType AS RoomType,
		|			MIN(RoomInventoryBalance.CounterClosingBalance) AS CounterClosingBalance,
		|			MIN(RoomInventoryBalance.TotalBedsClosingBalance) AS TotalBeds,
		|			MIN(RoomInventoryBalance.TotalRoomsClosingBalance) AS TotalRooms,
		|			MIN(RoomInventoryBalance.BedsVacantClosingBalance) AS BedsVacant,
		|			MIN(RoomInventoryBalance.RoomsVacantClosingBalance) AS RoomsVacant
		|		FROM
		|			AccumulationRegister.RoomInventory.BalanceAndTurnovers(&qDateFrom, &qDateTo, 
		|		    	                                                   Second, 
		|		        	                                               RegisterRecordsAndPeriodBoundaries, " +
		?(ValueIsFilled(Hotel), "Hotel IN HIERARCHY (&qHotel)", "TRUE") + 
		?(ValueIsFilled(SelRoomType), " AND RoomType IN HIERARCHY (&qRoomType)", "") + 
		?(vAllotmentByRooms, " AND Room IN (&qRoomsInQuota)", "") + "
		|		) AS RoomInventoryBalance
		|		GROUP BY
		|			RoomInventoryBalance.RoomType
		|		UNION ALL
		|		SELECT
		|			RoomQuotaSalesBalance.RoomType AS RoomType,
		|			MIN(RoomQuotaSalesBalance.CounterClosingBalance),
		|			MIN(RoomQuotaSalesBalance.BedsInQuotaClosingBalance),
		|			MIN(RoomQuotaSalesBalance.RoomsInQuotaClosingBalance),
		|			MIN(RoomQuotaSalesBalance.BedsRemainsClosingBalance),
		|			MIN(RoomQuotaSalesBalance.RoomsRemainsClosingBalance)
		|		FROM
		|			AccumulationRegister.RoomQuotaSales.BalanceAndTurnovers(&qDateFrom, &qDateTo, 
		|		    	                                                    Second, 
		|		           	                                                RegisterRecordsAndPeriodBoundaries, &qUseRoomQuota" +
		?(ValueIsFilled(SelRoomQuota), " AND RoomQuota IN HIERARCHY(&qRoomQuota)", "") + 
		?(ValueIsFilled(Hotel), " AND Hotel IN HIERARCHY (&qHotel)", "") + 
		?(ValueIsFilled(SelRoomType), " AND RoomType IN HIERARCHY (&qRoomType)", "") + 
		?(vAllotmentByRooms, " AND Room IN (&qRoomsInQuota)", "") + "
		|		) AS RoomQuotaSalesBalance
		|		GROUP BY
		|			RoomQuotaSalesBalance.RoomType
		|	) AS RoomTypesBalance
		|	WHERE
		|		RoomTypesBalance.RoomType.DeletionMark = FALSE 
		|	GROUP BY
		|		RoomTypesBalance.RoomType
		|	) AS RoomTypes
		|
		|WHERE " + 
		?(ValueIsFilled(Company), " (RoomTypes.RoomType.Company = &qCompany) OR (RoomTypes.RoomType.Company = &qEmptyCompany)", "TRUE") + "
		|
		|ORDER BY
		|	RoomTypeSortCode";
		
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
		|	RoomTypes.RoomType AS RoomType,
		|	RoomTypes.RoomType.SortCode AS RoomTypeSortCode,
		|	RoomTypes.BedsVacant AS BedsVacant,
		|	RoomTypes.RoomsVacant AS RoomsVacant,
		|	RoomTypes.RoomType.Company AS Company
		|
		|FROM(
		|	SELECT
		|		RoomTypesBalance.RoomType AS RoomType,
		|		MAX(RoomTypesBalance.TotalBeds) AS TotalBeds,
		|		MAX(RoomTypesBalance.TotalRooms) AS TotalRooms,
		|		MAX(RoomTypesBalance.BedsVacant) AS BedsVacant,
		|		MAX(RoomTypesBalance.RoomsVacant) AS RoomsVacant
		|	FROM (
		|		SELECT
		|			RoomInventoryBalance.RoomType AS RoomType,
		|			MIN(RoomInventoryBalance.CounterClosingBalance) AS CounterClosingBalance,
		|			MIN(RoomInventoryBalance.TotalBedsClosingBalance) AS TotalBeds,
		|			MIN(RoomInventoryBalance.TotalRoomsClosingBalance) AS TotalRooms,
		|			MIN(RoomInventoryBalance.BedsVacantClosingBalance) AS BedsVacant,
		|			MIN(RoomInventoryBalance.RoomsVacantClosingBalance) AS RoomsVacant
		|		FROM
		|			AccumulationRegister.RoomInventory.BalanceAndTurnovers(&qDateFrom, &qDateTo, 
		|		    	                                                   Second, 
		|		        	                                               RegisterRecordsAndPeriodBoundaries, " +
		?(ValueIsFilled(Hotel), "Hotel IN HIERARCHY (&qHotel)", "TRUE") + 
		?(ValueIsFilled(SelRoomType), " AND RoomType IN HIERARCHY (&qRoomType)", "") + 
		?(vAllotmentByRooms, " AND Room IN (&qRoomsInQuota)", "") + "
		|		AND Room IN (Выбрать Т.Номер Из ВТ_Номера Как Т)) AS RoomInventoryBalance
		|		GROUP BY
		|			RoomInventoryBalance.RoomType
		|		UNION ALL
		|		SELECT
		|			RoomQuotaSalesBalance.RoomType AS RoomType,
		|			MIN(RoomQuotaSalesBalance.CounterClosingBalance),
		|			MIN(RoomQuotaSalesBalance.BedsInQuotaClosingBalance),
		|			MIN(RoomQuotaSalesBalance.RoomsInQuotaClosingBalance),
		|			MIN(RoomQuotaSalesBalance.BedsRemainsClosingBalance),
		|			MIN(RoomQuotaSalesBalance.RoomsRemainsClosingBalance)
		|		FROM
		|			AccumulationRegister.RoomQuotaSales.BalanceAndTurnovers(&qDateFrom, &qDateTo, 
		|		    	                                                    Second, 
		|		           	                                                RegisterRecordsAndPeriodBoundaries, &qUseRoomQuota" +
		?(ValueIsFilled(SelRoomQuota), " AND RoomQuota IN HIERARCHY(&qRoomQuota)", "") + 
		?(ValueIsFilled(Hotel), " AND Hotel IN HIERARCHY (&qHotel)", "") + 
		?(ValueIsFilled(SelRoomType), " AND RoomType IN HIERARCHY (&qRoomType)", "") + 
		?(vAllotmentByRooms, " AND Room IN (&qRoomsInQuota)", "") + "
		|		AND Room IN (Выбрать Т.Номер Из ВТ_Номера Как Т)) AS RoomQuotaSalesBalance
		|		GROUP BY
		|			RoomQuotaSalesBalance.RoomType
		|	) AS RoomTypesBalance
		|	WHERE
		|		RoomTypesBalance.RoomType.DeletionMark = FALSE 
		|	GROUP BY
		|		RoomTypesBalance.RoomType
		|	) AS RoomTypes
		|
		|WHERE " + 
		?(ValueIsFilled(Company), " (RoomTypes.RoomType.Company = &qCompany) OR (RoomTypes.RoomType.Company = &qEmptyCompany)", "TRUE") + "
		|
		|ORDER BY
		|	RoomTypeSortCode";
	КонецЕсли;	
	#КонецВставки
	
	#Удаление
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	RoomTypes.RoomType AS RoomType,
	|	RoomTypes.RoomType.SortCode AS RoomTypeSortCode,
	|	RoomTypes.BedsVacant AS BedsVacant,
	|	RoomTypes.RoomsVacant AS RoomsVacant,
	|	RoomTypes.RoomType.Company AS Company
	|
	|FROM(
	|	SELECT
	|		RoomTypesBalance.RoomType AS RoomType,
	|		MAX(RoomTypesBalance.TotalBeds) AS TotalBeds,
	|		MAX(RoomTypesBalance.TotalRooms) AS TotalRooms,
	|		MAX(RoomTypesBalance.BedsVacant) AS BedsVacant,
	|		MAX(RoomTypesBalance.RoomsVacant) AS RoomsVacant
	|	FROM (
	|		SELECT
	|			RoomInventoryBalance.RoomType AS RoomType,
	|			MIN(RoomInventoryBalance.CounterClosingBalance) AS CounterClosingBalance,
	|			MIN(RoomInventoryBalance.TotalBedsClosingBalance) AS TotalBeds,
	|			MIN(RoomInventoryBalance.TotalRoomsClosingBalance) AS TotalRooms,
	|			MIN(RoomInventoryBalance.BedsVacantClosingBalance) AS BedsVacant,
	|			MIN(RoomInventoryBalance.RoomsVacantClosingBalance) AS RoomsVacant
	|		FROM
	|			AccumulationRegister.RoomInventory.BalanceAndTurnovers(&qDateFrom, &qDateTo, 
	|		    	                                                   Second, 
	|		        	                                               RegisterRecordsAndPeriodBoundaries, " +
	?(ValueIsFilled(Hotel), "Hotel IN HIERARCHY (&qHotel)", "TRUE") + 
	?(ValueIsFilled(SelRoomType), " AND RoomType IN HIERARCHY (&qRoomType)", "") + 
	?(vAllotmentByRooms, " AND Room IN (&qRoomsInQuota)", "") + "
	|		) AS RoomInventoryBalance
	|		GROUP BY
	|			RoomInventoryBalance.RoomType
	|		UNION ALL
	|		SELECT
	|			RoomQuotaSalesBalance.RoomType AS RoomType,
	|			MIN(RoomQuotaSalesBalance.CounterClosingBalance),
	|			MIN(RoomQuotaSalesBalance.BedsInQuotaClosingBalance),
	|			MIN(RoomQuotaSalesBalance.RoomsInQuotaClosingBalance),
	|			MIN(RoomQuotaSalesBalance.BedsRemainsClosingBalance),
	|			MIN(RoomQuotaSalesBalance.RoomsRemainsClosingBalance)
	|		FROM
	|			AccumulationRegister.RoomQuotaSales.BalanceAndTurnovers(&qDateFrom, &qDateTo, 
	|		    	                                                    Second, 
	|		           	                                                RegisterRecordsAndPeriodBoundaries, &qUseRoomQuota" +
	?(ValueIsFilled(SelRoomQuota), " AND RoomQuota IN HIERARCHY(&qRoomQuota)", "") + 
	?(ValueIsFilled(Hotel), " AND Hotel IN HIERARCHY (&qHotel)", "") + 
	?(ValueIsFilled(SelRoomType), " AND RoomType IN HIERARCHY (&qRoomType)", "") + 
	?(vAllotmentByRooms, " AND Room IN (&qRoomsInQuota)", "") + "
	|		) AS RoomQuotaSalesBalance
	|		GROUP BY
	|			RoomQuotaSalesBalance.RoomType
	|	) AS RoomTypesBalance
	|	WHERE
	|		RoomTypesBalance.RoomType.DeletionMark = FALSE 
	|	GROUP BY
	|		RoomTypesBalance.RoomType
	|	) AS RoomTypes
	|
	|WHERE " + 
	?(ValueIsFilled(Company), " (RoomTypes.RoomType.Company = &qCompany) OR (RoomTypes.RoomType.Company = &qEmptyCompany)", "TRUE") + "
	|
	|ORDER BY
	|	RoomTypeSortCode";
	#КонецУдаления
	vQry.SetParameter("qHotel", Hotel);
	vQry.SetParameter("qRoomType", SelRoomType);
	vQry.SetParameter("qDateFrom", DateFrom);
	vQry.SetParameter("qDateTo", New Boundary(DateTo, BoundaryType.Excluding));
	vQry.SetParameter("qCompany", Company);
	vQry.SetParameter("qEmptyCompany", Catalogs.Companies.EmptyRef());
	vQry.SetParameter("qRoomQuota", SelRoomQuota);
	vQry.SetParameter("qRoomsInQuota", vRoomsInQuota);
	vQry.SetParameter("qUseRoomQuota", ValueIsFilled(SelRoomQuota));
	vQryResult = vQry.Execute();
	vRoomTypes = vQryResult.Unload();
	
	// Run query to get list of available rooms
	#Вставка
	Если НомернойФонд.Пустая() Тогда
		vQry = New Query();
		vQry.Text = 
		"SELECT Разрешенные
		|	Rooms.Room AS Room,
		|	Rooms.Room.parent AS Parent,
		|	Rooms.Room.SortCode AS SortCode,
		|	Rooms.RoomType AS RoomType,
		|	Rooms.Room.RoomStatus AS RoomStatus,
		|	Rooms.TotalBeds AS TotalBeds,
		|	Rooms.TotalRooms AS TotalRooms,
		|	Rooms.BedsVacant AS BedsVacant,
		|	Rooms.RoomsVacant AS RoomsVacant,
		|	Rooms.Room.Company AS Company,
		|	Rooms.Room.IsFolder AS IsFolder,
		|	Rooms.Room.IsVirtual AS IsVirtual,
		|	Rooms.Room.RoomPropertiesCodes AS RoomPropertiesCodes,
		|	Rooms.Room.RoomPropertiesDescriptions AS RoomPropertiesDescriptions,
		|	Rooms.Room.Remarks AS Remarks,
		|	CASE
		|		WHEN RoomsStopSales.RoomsStopSale IS NULL
		|			THEN FALSE
		|		ELSE TRUE
		|	END AS StopSale,
		|	CASE
		|		WHEN RoomTypesStopSales.RoomTypesStopSale IS NULL
		|			THEN FALSE
		|		ELSE TRUE
		|	END AS RoomTypeStopSale
		|FROM
		|	(SELECT
		|		RoomBalance.Room AS Room,
		|		RoomBalance.RoomType AS RoomType,
		|		MAX(RoomBalance.TotalBeds) AS TotalBeds,
		|		MAX(RoomBalance.TotalRooms) AS TotalRooms,
		|		MAX(RoomBalance.BedsVacant) AS BedsVacant,
		|		MAX(RoomBalance.RoomsVacant) AS RoomsVacant
		|	FROM
		|		(SELECT
		|			RoomInventoryBalance.Room AS Room,
		|			RoomInventoryBalance.RoomType AS RoomType,
		|			MIN(RoomInventoryBalance.CounterClosingBalance) AS CounterClosingBalance,
		|			MIN(RoomInventoryBalance.TotalBedsClosingBalance) AS TotalBeds,
		|			MIN(RoomInventoryBalance.TotalRoomsClosingBalance) AS TotalRooms,
		|			MIN(RoomInventoryBalance.BedsVacantClosingBalance) AS BedsVacant,
		|			MIN(RoomInventoryBalance.RoomsVacantClosingBalance) AS RoomsVacant
		|		FROM
		|			AccumulationRegister.RoomInventory.BalanceAndTurnovers(
		|					&qDateFrom,
		|					&qDateTo,
		|					Second,
		|					RegisterRecordsAndPeriodBoundaries,
		|					(&qHotelIsFilled
		|							AND Hotel IN HIERARCHY (&qHotel)
		|						OR NOT &qHotelIsFilled)
		|                       AND Не Room.IsVirtual
		|						AND (&qRoomTypeIsFilled
		|								AND RoomType IN HIERARCHY (&qRoomType)
		|							OR NOT &qRoomTypeIsFilled)
		|						AND (&qAllotmentByRooms
		|								AND Room IN (&qRoomsInQuota)
		|							OR NOT &qAllotmentByRooms)) AS RoomInventoryBalance
		|		
		|		GROUP BY
		|			RoomInventoryBalance.Room,
		|			RoomInventoryBalance.RoomType
		|		
		|		UNION ALL
		|		
		|		SELECT
		|			RoomQuotaSalesBalance.Room,
		|			RoomQuotaSalesBalance.RoomType,
		|			MIN(RoomQuotaSalesBalance.CounterClosingBalance),
		|			MIN(RoomQuotaSalesBalance.BedsInQuotaClosingBalance),
		|			MIN(RoomQuotaSalesBalance.RoomsInQuotaClosingBalance),
		|			MIN(RoomQuotaSalesBalance.BedsRemainsClosingBalance),
		|			MIN(RoomQuotaSalesBalance.RoomsRemainsClosingBalance)
		|		FROM
		|			AccumulationRegister.RoomQuotaSales.BalanceAndTurnovers(
		|					&qDateFrom,
		|					&qDateTo,
		|					Second,
		|					RegisterRecordsAndPeriodBoundaries,
		|					&qUseRoomQuota
		|						AND RoomQuota IN HIERARCHY (&qRoomQuota)
		|						AND (&qHotelIsFilled
		|								AND Hotel IN HIERARCHY (&qHotel)
		|							OR NOT &qHotelIsFilled)
		|						AND (&qRoomTypeIsFilled
		|								AND RoomType IN HIERARCHY (&qRoomType)
		|							OR NOT &qRoomTypeIsFilled)
		|						AND (&qAllotmentByRooms
		|								AND Room IN (&qRoomsInQuota)
		|							OR NOT &qAllotmentByRooms)) AS RoomQuotaSalesBalance
		|		
		|		GROUP BY
		|			RoomQuotaSalesBalance.Room,
		|			RoomQuotaSalesBalance.RoomType) AS RoomBalance
		|	WHERE
		|		NOT RoomBalance.Room.DeletionMark
		|		AND (&qRoomStatusIsFilled
		|					AND RoomBalance.Room.RoomStatus = &qRoomStatus
		|				OR NOT &qRoomStatusIsFilled)
		|	
		|	GROUP BY
		|		RoomBalance.RoomType,
		|		RoomBalance.Room
		|	
		|	HAVING
		|		(&qShowVacantOnly
		|				AND MAX(RoomBalance.BedsVacant) >= &qNumberOfBeds
		|				AND MAX(RoomBalance.RoomsVacant) >= &qNumberOfRooms
		|			OR NOT &qShowVacantOnly)
		|	
		//|	UNION ALL
		//|	
		//|	SELECT
		//|		VirtualRooms.Ref,
		//|		VirtualRooms.RoomType,
		//|		0,
		//|		0,
		//|		0,
		//|		0
		//|	FROM
		//|		Catalog.Rooms AS VirtualRooms
		//|	WHERE
		//|		VirtualRooms.IsVirtual
		//|		AND (&qHotelIsFilled
		//|					AND VirtualRooms.Owner IN HIERARCHY (&qHotel)
		//|				OR NOT &qHotelIsFilled)
		//|		AND (&qRoomTypeIsFilled
		//|					AND VirtualRooms.RoomType IN HIERARCHY (&qRoomType)
		//|				OR NOT &qRoomTypeIsFilled)
		|) AS Rooms
		|		LEFT JOIN (SELECT
		|			RoomsStopSalePeriods.Ref AS RoomsStopSale
		|		FROM
		|			Catalog.Rooms.StopSalePeriods AS RoomsStopSalePeriods
		|		WHERE
		|			RoomsStopSalePeriods.StopSale
		|			AND RoomsStopSalePeriods.PeriodFrom < &qDateTimeTo
		|			AND RoomsStopSalePeriods.PeriodTo > &qDateFrom
		|			AND NOT RoomsStopSalePeriods.Ref.DeletionMark
		|			AND NOT RoomsStopSalePeriods.Ref.IsFolder
		|		
		|		GROUP BY
		|			RoomsStopSalePeriods.Ref) AS RoomsStopSales
		|		ON Rooms.Room = RoomsStopSales.RoomsStopSale
		|		LEFT JOIN (SELECT
		|			RoomTypesStopSalePeriods.Ref AS RoomTypesStopSale
		|		FROM
		|			Catalog.RoomTypes.StopSalePeriods AS RoomTypesStopSalePeriods
		|		WHERE
		|			RoomTypesStopSalePeriods.StopSale
		|			AND RoomTypesStopSalePeriods.PeriodFrom < &qDateTimeTo
		|			AND RoomTypesStopSalePeriods.PeriodTo > &qDateFrom
		|			AND NOT RoomTypesStopSalePeriods.Ref.DeletionMark
		|			AND NOT RoomTypesStopSalePeriods.Ref.IsFolder
		|		
		|		GROUP BY
		|			RoomTypesStopSalePeriods.Ref) AS RoomTypesStopSales
		|		ON Rooms.RoomType = RoomTypesStopSales.RoomTypesStopSale
		|WHERE
		|	(&qCompanyIsFilled
		|				AND (Rooms.RoomType.Company = &qCompany
		|					OR Rooms.Room.Company = &qCompany
		|					OR Rooms.RoomType.Company = &qEmptyCompany
		|						AND Rooms.Room.Company = &qEmptyCompany)
		|			OR NOT &qCompanyIsFilled)
		|
		|ORDER BY
		|	SortCode
		|TOTALS BY
		|	Room HIERARCHY";	
	Иначе
		vQry = New Query();
		vQry.МенеджерВременныхТаблиц = МенеджерВТ;
		vQry.Text = 
		"SELECT Разрешенные
		|	Rooms.Room AS Room,
		|	Rooms.Room.Parent AS Parent,
		|	Rooms.Room.SortCode AS SortCode,
		|	Rooms.RoomType AS RoomType,
		|	Rooms.Room.RoomStatus AS RoomStatus,
		|	Rooms.TotalBeds AS TotalBeds,
		|	Rooms.TotalRooms AS TotalRooms,
		|	Rooms.BedsVacant AS BedsVacant,
		|	Rooms.RoomsVacant AS RoomsVacant,
		|	Rooms.Room.Company AS Company,
		|	Rooms.Room.IsFolder AS IsFolder,
		|	Rooms.Room.IsVirtual AS IsVirtual,
		|	Rooms.Room.RoomPropertiesCodes AS RoomPropertiesCodes,
		|	Rooms.Room.RoomPropertiesDescriptions AS RoomPropertiesDescriptions,
		|	Rooms.Room.Remarks AS Remarks,
		|	CASE
		|		WHEN RoomsStopSales.RoomsStopSale IS NULL
		|			THEN FALSE
		|		ELSE TRUE
		|	END AS StopSale,
		|	CASE
		|		WHEN RoomTypesStopSales.RoomTypesStopSale IS NULL
		|			THEN FALSE
		|		ELSE TRUE
		|	END AS RoomTypeStopSale
		|FROM
		|	(SELECT
		|		RoomBalance.Room AS Room,
		|		RoomBalance.RoomType AS RoomType,
		|		MAX(RoomBalance.TotalBeds) AS TotalBeds,
		|		MAX(RoomBalance.TotalRooms) AS TotalRooms,
		|		MAX(RoomBalance.BedsVacant) AS BedsVacant,
		|		MAX(RoomBalance.RoomsVacant) AS RoomsVacant
		|	FROM
		|		(SELECT
		|			RoomInventoryBalance.Room AS Room,
		|			RoomInventoryBalance.RoomType AS RoomType,
		|			MIN(RoomInventoryBalance.CounterClosingBalance) AS CounterClosingBalance,
		|			MIN(RoomInventoryBalance.TotalBedsClosingBalance) AS TotalBeds,
		|			MIN(RoomInventoryBalance.TotalRoomsClosingBalance) AS TotalRooms,
		|			MIN(RoomInventoryBalance.BedsVacantClosingBalance) AS BedsVacant,
		|			MIN(RoomInventoryBalance.RoomsVacantClosingBalance) AS RoomsVacant
		|		FROM
		|			AccumulationRegister.RoomInventory.BalanceAndTurnovers(
		|					&qDateFrom,
		|					&qDateTo,
		|					Second,
		|					RegisterRecordsAndPeriodBoundaries,
		|					(&qHotelIsFilled
		|							AND Hotel IN HIERARCHY (&qHotel)
		|						OR NOT &qHotelIsFilled)
		|                       AND Room В (Выбрать Т.Номер Из ВТ_Номера как Т)
		|						AND (&qRoomTypeIsFilled
		|								AND RoomType IN HIERARCHY (&qRoomType)
		|							OR NOT &qRoomTypeIsFilled)
		|						AND (&qAllotmentByRooms
		|								AND Room IN (&qRoomsInQuota)
		|							OR NOT &qAllotmentByRooms)) AS RoomInventoryBalance
		|		
		|		GROUP BY
		|			RoomInventoryBalance.Room,
		|			RoomInventoryBalance.RoomType
		|		
		|		UNION ALL
		|		
		|		SELECT
		|			RoomQuotaSalesBalance.Room,
		|			RoomQuotaSalesBalance.RoomType,
		|			MIN(RoomQuotaSalesBalance.CounterClosingBalance),
		|			MIN(RoomQuotaSalesBalance.BedsInQuotaClosingBalance),
		|			MIN(RoomQuotaSalesBalance.RoomsInQuotaClosingBalance),
		|			MIN(RoomQuotaSalesBalance.BedsRemainsClosingBalance),
		|			MIN(RoomQuotaSalesBalance.RoomsRemainsClosingBalance)
		|		FROM
		|			AccumulationRegister.RoomQuotaSales.BalanceAndTurnovers(
		|					&qDateFrom,
		|					&qDateTo,
		|					Second,
		|					RegisterRecordsAndPeriodBoundaries,
		|					&qUseRoomQuota
		|						AND RoomQuota IN HIERARCHY (&qRoomQuota)
		|						AND (&qHotelIsFilled
		|								AND Hotel IN HIERARCHY (&qHotel)
		|							OR NOT &qHotelIsFilled)
		|						AND (&qRoomTypeIsFilled
		|								AND RoomType IN HIERARCHY (&qRoomType)
		|							OR NOT &qRoomTypeIsFilled)
		|                       AND Room В (Выбрать Т.Номер Из ВТ_Номера как Т)
		|                       AND Не Room.IsVirtual 
		|						AND (&qAllotmentByRooms
		|								AND Room IN (&qRoomsInQuota)
		|							OR NOT &qAllotmentByRooms)) AS RoomQuotaSalesBalance
		|		
		|		GROUP BY
		|			RoomQuotaSalesBalance.Room,
		|			RoomQuotaSalesBalance.RoomType) AS RoomBalance
		|	WHERE
		|		NOT RoomBalance.Room.DeletionMark
		|		AND (&qRoomStatusIsFilled
		|					AND RoomBalance.Room.RoomStatus = &qRoomStatus
		|				OR NOT &qRoomStatusIsFilled)
		|	
		|	GROUP BY
		|		RoomBalance.RoomType,
		|		RoomBalance.Room
		|	
		|	HAVING
		|		(&qShowVacantOnly
		|				AND MAX(RoomBalance.BedsVacant) >= &qNumberOfBeds
		|				AND MAX(RoomBalance.RoomsVacant) >= &qNumberOfRooms
		|			OR NOT &qShowVacantOnly)
		|	
		//|	UNION ALL
		//|	
		//|	SELECT
		//|		VirtualRooms.Ref,
		//|		VirtualRooms.RoomType,
		//|		0,
		//|		0,
		//|		0,
		//|		0
		//|	FROM
		//|		Catalog.Rooms AS VirtualRooms
		//|       Внутреннее Соединение ВТ_Номера как ВТ_Номера
		//|       По VirtualRooms.Ref = ВТ_Номера.Номер
		//|	WHERE
		//|		VirtualRooms.IsVirtual
		//|		AND (&qHotelIsFilled
		//|					AND VirtualRooms.Owner IN HIERARCHY (&qHotel)
		//|				OR NOT &qHotelIsFilled)
		//|		AND (&qRoomTypeIsFilled
		//|					AND VirtualRooms.RoomType IN HIERARCHY (&qRoomType)
		//|				OR NOT &qRoomTypeIsFilled)
		|) AS Rooms
		|		LEFT JOIN (SELECT
		|			RoomsStopSalePeriods.Ref AS RoomsStopSale
		|		FROM
		|			Catalog.Rooms.StopSalePeriods AS RoomsStopSalePeriods
		|    		Внутреннее Соединение ВТ_Номера как ВТ_Номера
		|     		По RoomsStopSalePeriods.Ref = ВТ_Номера.Номер
		|		WHERE
		|			RoomsStopSalePeriods.StopSale
		|			AND RoomsStopSalePeriods.PeriodFrom < &qDateTimeTo
		|			AND RoomsStopSalePeriods.PeriodTo > &qDateFrom
		|			AND NOT RoomsStopSalePeriods.Ref.DeletionMark
		|			AND NOT RoomsStopSalePeriods.Ref.IsFolder
		|		
		|		GROUP BY
		|			RoomsStopSalePeriods.Ref) AS RoomsStopSales
		|		ON Rooms.Room = RoomsStopSales.RoomsStopSale
		|		LEFT JOIN (SELECT
		|			RoomTypesStopSalePeriods.Ref AS RoomTypesStopSale
		|		FROM
		|			Catalog.RoomTypes.StopSalePeriods AS RoomTypesStopSalePeriods
		|		WHERE
		|			RoomTypesStopSalePeriods.StopSale
		|			AND RoomTypesStopSalePeriods.PeriodFrom < &qDateTimeTo
		|			AND RoomTypesStopSalePeriods.PeriodTo > &qDateFrom
		|			AND NOT RoomTypesStopSalePeriods.Ref.DeletionMark
		|			AND NOT RoomTypesStopSalePeriods.Ref.IsFolder
		|		
		|		GROUP BY
		|			RoomTypesStopSalePeriods.Ref) AS RoomTypesStopSales
		|		ON Rooms.RoomType = RoomTypesStopSales.RoomTypesStopSale
		|WHERE
		|	(&qCompanyIsFilled
		|				AND (Rooms.RoomType.Company = &qCompany
		|					OR Rooms.Room.Company = &qCompany
		|					OR Rooms.RoomType.Company = &qEmptyCompany
		|						AND Rooms.Room.Company = &qEmptyCompany)
		|			OR NOT &qCompanyIsFilled)
		|
		|ORDER BY
		|	SortCode
		|TOTALS BY
		|	Room HIERARCHY";	
	КонецЕсли;
	#КонецВставки
	
	#Удаление
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Rooms.Room AS Room,
	|	Rooms.Room.SortCode AS SortCode,
	|	Rooms.RoomType AS RoomType,
	|	Rooms.Room.RoomStatus AS RoomStatus,
	|	Rooms.TotalBeds AS TotalBeds,
	|	Rooms.TotalRooms AS TotalRooms,
	|	Rooms.BedsVacant AS BedsVacant,
	|	Rooms.RoomsVacant AS RoomsVacant,
	|	Rooms.Room.Company AS Company,
	|	Rooms.Room.IsFolder AS IsFolder,
	|	Rooms.Room.IsVirtual AS IsVirtual,
	|	Rooms.Room.RoomPropertiesCodes AS RoomPropertiesCodes,
	|	Rooms.Room.RoomPropertiesDescriptions AS RoomPropertiesDescriptions,
	|	Rooms.Room.Remarks AS Remarks,
	|	CASE
	|		WHEN RoomsStopSales.RoomsStopSale IS NULL
	|			THEN FALSE
	|		ELSE TRUE
	|	END AS StopSale,
	|	CASE
	|		WHEN RoomTypesStopSales.RoomTypesStopSale IS NULL
	|			THEN FALSE
	|		ELSE TRUE
	|	END AS RoomTypeStopSale
	|FROM
	|	(SELECT
	|		RoomBalance.Room AS Room,
	|		RoomBalance.RoomType AS RoomType,
	|		MAX(RoomBalance.TotalBeds) AS TotalBeds,
	|		MAX(RoomBalance.TotalRooms) AS TotalRooms,
	|		MAX(RoomBalance.BedsVacant) AS BedsVacant,
	|		MAX(RoomBalance.RoomsVacant) AS RoomsVacant
	|	FROM
	|		(SELECT
	|			RoomInventoryBalance.Room AS Room,
	|			RoomInventoryBalance.RoomType AS RoomType,
	|			MIN(RoomInventoryBalance.CounterClosingBalance) AS CounterClosingBalance,
	|			MIN(RoomInventoryBalance.TotalBedsClosingBalance) AS TotalBeds,
	|			MIN(RoomInventoryBalance.TotalRoomsClosingBalance) AS TotalRooms,
	|			MIN(RoomInventoryBalance.BedsVacantClosingBalance) AS BedsVacant,
	|			MIN(RoomInventoryBalance.RoomsVacantClosingBalance) AS RoomsVacant
	|		FROM
	|			AccumulationRegister.RoomInventory.BalanceAndTurnovers(
	|					&qDateFrom,
	|					&qDateTo,
	|					Second,
	|					RegisterRecordsAndPeriodBoundaries,
	|					(&qHotelIsFilled
	|							AND Hotel IN HIERARCHY (&qHotel)
	|						OR NOT &qHotelIsFilled)
	|						AND (&qRoomTypeIsFilled
	|								AND RoomType IN HIERARCHY (&qRoomType)
	|							OR NOT &qRoomTypeIsFilled)
	|						AND (&qAllotmentByRooms
	|								AND Room IN (&qRoomsInQuota)
	|							OR NOT &qAllotmentByRooms)) AS RoomInventoryBalance
	|		
	|		GROUP BY
	|			RoomInventoryBalance.Room,
	|			RoomInventoryBalance.RoomType
	|		
	|		UNION ALL
	|		
	|		SELECT
	|			RoomQuotaSalesBalance.Room,
	|			RoomQuotaSalesBalance.RoomType,
	|			MIN(RoomQuotaSalesBalance.CounterClosingBalance),
	|			MIN(RoomQuotaSalesBalance.BedsInQuotaClosingBalance),
	|			MIN(RoomQuotaSalesBalance.RoomsInQuotaClosingBalance),
	|			MIN(RoomQuotaSalesBalance.BedsRemainsClosingBalance),
	|			MIN(RoomQuotaSalesBalance.RoomsRemainsClosingBalance)
	|		FROM
	|			AccumulationRegister.RoomQuotaSales.BalanceAndTurnovers(
	|					&qDateFrom,
	|					&qDateTo,
	|					Second,
	|					RegisterRecordsAndPeriodBoundaries,
	|					&qUseRoomQuota
	|						AND RoomQuota IN HIERARCHY (&qRoomQuota)
	|						AND (&qHotelIsFilled
	|								AND Hotel IN HIERARCHY (&qHotel)
	|							OR NOT &qHotelIsFilled)
	|						AND (&qRoomTypeIsFilled
	|								AND RoomType IN HIERARCHY (&qRoomType)
	|							OR NOT &qRoomTypeIsFilled)
	|						AND (&qAllotmentByRooms
	|								AND Room IN (&qRoomsInQuota)
	|							OR NOT &qAllotmentByRooms)) AS RoomQuotaSalesBalance
	|		
	|		GROUP BY
	|			RoomQuotaSalesBalance.Room,
	|			RoomQuotaSalesBalance.RoomType) AS RoomBalance
	|	WHERE
	|		NOT RoomBalance.Room.DeletionMark
	|		AND (&qRoomStatusIsFilled
	|					AND RoomBalance.Room.RoomStatus = &qRoomStatus
	|				OR NOT &qRoomStatusIsFilled)
	|	
	|	GROUP BY
	|		RoomBalance.RoomType,
	|		RoomBalance.Room
	|	
	|	HAVING
	|		(&qShowVacantOnly
	|				AND MAX(RoomBalance.BedsVacant) >= &qNumberOfBeds
	|				AND MAX(RoomBalance.RoomsVacant) >= &qNumberOfRooms
	|			OR NOT &qShowVacantOnly)
	|	
	|	UNION ALL
	|	
	|	SELECT
	|		VirtualRooms.Ref,
	|		VirtualRooms.RoomType,
	|		0,
	|		0,
	|		0,
	|		0
	|	FROM
	|		Catalog.Rooms AS VirtualRooms
	|	WHERE
	|		VirtualRooms.IsVirtual
	|		AND (&qHotelIsFilled
	|					AND VirtualRooms.Owner IN HIERARCHY (&qHotel)
	|				OR NOT &qHotelIsFilled)
	|		AND (&qRoomTypeIsFilled
	|					AND VirtualRooms.RoomType IN HIERARCHY (&qRoomType)
	|				OR NOT &qRoomTypeIsFilled)) AS Rooms
	|		LEFT JOIN (SELECT
	|			RoomsStopSalePeriods.Ref AS RoomsStopSale
	|		FROM
	|			Catalog.Rooms.StopSalePeriods AS RoomsStopSalePeriods
	|		WHERE
	|			RoomsStopSalePeriods.StopSale
	|			AND RoomsStopSalePeriods.PeriodFrom < &qDateTimeTo
	|			AND RoomsStopSalePeriods.PeriodTo > &qDateFrom
	|			AND NOT RoomsStopSalePeriods.Ref.DeletionMark
	|			AND NOT RoomsStopSalePeriods.Ref.IsFolder
	|		
	|		GROUP BY
	|			RoomsStopSalePeriods.Ref) AS RoomsStopSales
	|		ON Rooms.Room = RoomsStopSales.RoomsStopSale
	|		LEFT JOIN (SELECT
	|			RoomTypesStopSalePeriods.Ref AS RoomTypesStopSale
	|		FROM
	|			Catalog.RoomTypes.StopSalePeriods AS RoomTypesStopSalePeriods
	|		WHERE
	|			RoomTypesStopSalePeriods.StopSale
	|			AND RoomTypesStopSalePeriods.PeriodFrom < &qDateTimeTo
	|			AND RoomTypesStopSalePeriods.PeriodTo > &qDateFrom
	|			AND NOT RoomTypesStopSalePeriods.Ref.DeletionMark
	|			AND NOT RoomTypesStopSalePeriods.Ref.IsFolder
	|		
	|		GROUP BY
	|			RoomTypesStopSalePeriods.Ref) AS RoomTypesStopSales
	|		ON Rooms.RoomType = RoomTypesStopSales.RoomTypesStopSale
	|WHERE
	|	(&qCompanyIsFilled
	|				AND (Rooms.RoomType.Company = &qCompany
	|					OR Rooms.Room.Company = &qCompany
	|					OR Rooms.RoomType.Company = &qEmptyCompany
	|						AND Rooms.Room.Company = &qEmptyCompany)
	|			OR NOT &qCompanyIsFilled)
	|
	|ORDER BY
	|	SortCode
	|TOTALS BY
	|	Room HIERARCHY";
	#КонецУдаления
	vQry.SetParameter("qHotel", Hotel);
	vQry.SetParameter("qHotelIsFilled", ValueIsFilled(Hotel));
	vQry.SetParameter("qRoomType", SelRoomType);
	vQry.SetParameter("qRoomTypeIsFilled", ValueIsFilled(SelRoomType));
	vQry.SetParameter("qDateFrom", DateFrom);
	vQry.SetParameter("qDateTo", New Boundary(DateTo, BoundaryType.Excluding));
	vQry.SetParameter("qDateTimeTo", DateTo);
	vQry.SetParameter("qCompany", Company);
	vQry.SetParameter("qCompanyIsFilled", ValueIsFilled(Company));
	vQry.SetParameter("qEmptyCompany", Catalogs.Companies.EmptyRef());
	vQry.SetParameter("qNumberOfBeds", SelNumberOfBeds);
	vQry.SetParameter("qNumberOfRooms", SelNumberOfRooms);
	vQry.SetParameter("qRoomStatus", vRoomStatus);
	vQry.SetParameter("qRoomStatusIsFilled", ValueIsFilled(vRoomStatus));
	vQry.SetParameter("qRoomQuota", SelRoomQuota);
	vQry.SetParameter("qRoomsInQuota", vRoomsInQuota);
	vQry.SetParameter("qAllotmentByRooms", vAllotmentByRooms);
	vQry.SetParameter("qUseRoomQuota", ValueIsFilled(SelRoomQuota));
	vQry.SetParameter("qShowVacantOnly", Not (SelNumberOfBeds = 0 And SelNumberOfRooms = 0));
	vQryResult = vQry.Execute();
	vRooms = vQryResult.Unload();
	
	// Get the value list of all vacant rooms
	vRoomsList = New ValueList();
	vRoomsAndFoldersList = New ValueList();
	For Each vRoomRow In vRooms Do
		vCurRoom = vRoomRow.Room;
		If ValueIsFilled(vCurRoom) Then
			If Not vRoomRow.IsFolder Then
				If vRoomsList.FindByValue(vCurRoom) = Undefined Then
					vRoomsList.Add(vCurRoom);
				EndIf;
			EndIf;
			If vRoomsAndFoldersList.FindByValue(vCurRoom) = Undefined Then
				vRoomsAndFoldersList.Add(vCurRoom);
			EndIf;
		EndIf;
	EndDo;
	
	// Get the table of nearest dates when rooms became busy
	#Вставка	
	vQryReserv = New Query();
	vQryReserv.Text = 
	"SELECT Разрешенные
	|	RoomInventory.Room,
	|	MIN(RoomInventory.PeriodFrom) AS CheckInDate,
	|	RoomInventory.Room.SortCode AS SortCode
	|FROM
	|	AccumulationRegister.RoomInventory AS RoomInventory
	|WHERE
	|	RoomInventory.Room IN(&qRooms)
	|	AND RoomInventory.RecordType = &qExpense
	|	AND RoomInventory.PeriodFrom >= &qDateTo
	|	AND RoomInventory.PeriodFrom < &qNextDateTo
	|	AND (RoomInventory.IsReservation OR RoomInventory.IsAccommodation)
	|GROUP BY
	|	RoomInventory.Room
	|ORDER BY
	|	SortCode";
	#КонецВставки
	
	#Удаление
	vQryReserv = New Query();
	vQryReserv.Text = 
	"SELECT
	|	RoomInventory.Room,
	|	MIN(RoomInventory.PeriodFrom) AS CheckInDate,
	|	RoomInventory.Room.SortCode AS SortCode
	|FROM
	|	AccumulationRegister.RoomInventory AS RoomInventory
	|WHERE
	|	RoomInventory.Room IN(&qRooms)
	|	AND RoomInventory.RecordType = &qExpense
	|	AND RoomInventory.PeriodFrom >= &qDateTo
	|	AND RoomInventory.PeriodFrom < &qNextDateTo
	|	AND (RoomInventory.IsReservation OR RoomInventory.IsAccommodation)
	|GROUP BY
	|	RoomInventory.Room
	|ORDER BY
	|	SortCode";
	#КонецУдаления
	vQryReserv.SetParameter("qRooms", vRoomsList);
	vQryReserv.SetParameter("qExpense", AccumulationRecordType.Expense);
	vQryReserv.SetParameter("qDateTo", DateTo);
	vQryReserv.SetParameter("qNextDateTo", DateTo + 7*24*3600); // Look only for 7 days in the future
	vReserves = vQryReserv.Execute().Unload();
	
	// Get table of nearest times when rooms became vacant
	vNumDays = 2;
	If ValueIsFilled(Hotel) And Hotel.VacantRoomsChoiceFormVacantFromDateHistoryDepth > 0 Then
		vNumDays = Hotel.VacantRoomsChoiceFormVacantFromDateHistoryDepth;
	EndIf;
	
	#Вставка
	vQryVacant = New Query();
	vQryVacant.Text = 
	"SELECT Разрешенные
	|	RoomInventory.Room,
	|	MAX(RoomInventory.PeriodTo) AS CheckOutDate,
	|	RoomInventory.Room.SortCode AS SortCode
	|FROM
	|	AccumulationRegister.RoomInventory AS RoomInventory
	|WHERE
	|	RoomInventory.Room IN(&qRooms)
	|	AND RoomInventory.RecordType = &qReceipt
	|	AND RoomInventory.PeriodTo <= &qDateFrom
	|	AND RoomInventory.PeriodTo > &qPrevDateFrom
	|	AND (RoomInventory.IsReservation OR RoomInventory.IsAccommodation)
	|GROUP BY
	|	RoomInventory.Room
	|ORDER BY
	|	SortCode";
	#КонецВставки
	
	#Удаление
	vQryVacant = New Query();
	vQryVacant.Text = 
	"SELECT
	|	RoomInventory.Room,
	|	MAX(RoomInventory.PeriodTo) AS CheckOutDate,
	|	RoomInventory.Room.SortCode AS SortCode
	|FROM
	|	AccumulationRegister.RoomInventory AS RoomInventory
	|WHERE
	|	RoomInventory.Room IN(&qRooms)
	|	AND RoomInventory.RecordType = &qReceipt
	|	AND RoomInventory.PeriodTo <= &qDateFrom
	|	AND RoomInventory.PeriodTo > &qPrevDateFrom
	|	AND (RoomInventory.IsReservation OR RoomInventory.IsAccommodation)
	|GROUP BY
	|	RoomInventory.Room
	|ORDER BY
	|	SortCode";
	#КонецУдаления
	vQryVacant.SetParameter("qRooms", vRoomsList);
	vQryVacant.SetParameter("qReceipt", AccumulationRecordType.Receipt);
	vQryVacant.SetParameter("qDateFrom", DateFrom);
	vQryVacant.SetParameter("qPrevDateFrom", DateFrom - vNumDays*24*3600); // Look only for 2 day in the past by default
	vVacants = vQryVacant.Execute().Unload();
	
	// Get table of room blocks
	#Вставка
	Если НомернойФонд.Пустая() Тогда
		vQryBlocks = New Query();
		vQryBlocks.Text = 
		"SELECT Разрешенные
		|	RoomInventory.Room AS Room,
		|	RoomInventory.RoomBlockType AS RoomBlockType,
		|	RoomInventory.Room.SortCode AS SortCode
		|FROM
		|	AccumulationRegister.RoomInventory AS RoomInventory
		|WHERE " +
		?(ValueIsFilled(Hotel), "Hotel IN HIERARCHY(&qHotel)", "TRUE") + 
		?(ValueIsFilled(SelRoomType), " AND RoomType IN HIERARCHY(&qRoomType)", " AND TRUE") + 
		?(ValueIsFilled(Company), " AND ((RoomInventory.Room.Company = &qCompany) OR (RoomInventory.RoomType.Company = &qCompany) OR (RoomInventory.Room.Company = &qEmptyCompany AND RoomInventory.RoomType.Company = &qEmptyCompany)) ", " AND TRUE") + "
		|	AND RoomInventory.RecordType = &qExpense
		|	AND RoomInventory.IsBlocking
		|	AND RoomInventory.PeriodFrom > &qEmptyDate
		|	AND RoomInventory.PeriodFrom < &qDateTo
		|	AND (RoomInventory.PeriodTo > &qDateFrom OR RoomInventory.PeriodTo = &qEmptyDate)
		|GROUP BY
		|	RoomInventory.Room,
		|	RoomInventory.RoomBlockType
		|ORDER BY
		|	SortCode";
	Иначе
		vQryBlocks = New Query();
		vQryBlocks.МенеджерВременныхТаблиц = МенеджерВТ;
		vQryBlocks.Text = 
		"SELECT Разрешенные
		|	RoomInventory.Room AS Room,
		|	RoomInventory.RoomBlockType AS RoomBlockType,
		|	RoomInventory.Room.SortCode AS SortCode
		|FROM
		|	AccumulationRegister.RoomInventory AS RoomInventory
		|   ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_Номера как ВТ_Номера
		|   ПО ВТ_Номера.Номер = RoomInventory.Room
		|WHERE " +
		?(ValueIsFilled(Hotel), "Hotel IN HIERARCHY(&qHotel)", "TRUE") + 
		?(ValueIsFilled(SelRoomType), " AND RoomType IN HIERARCHY(&qRoomType)", " AND TRUE") + 
		?(ValueIsFilled(Company), " AND ((RoomInventory.Room.Company = &qCompany) OR (RoomInventory.RoomType.Company = &qCompany) OR (RoomInventory.Room.Company = &qEmptyCompany AND RoomInventory.RoomType.Company = &qEmptyCompany)) ", " AND TRUE") + "
		|	AND RoomInventory.RecordType = &qExpense
		|	AND RoomInventory.IsBlocking
		|	AND RoomInventory.PeriodFrom > &qEmptyDate
		|	AND RoomInventory.PeriodFrom < &qDateTo
		|	AND (RoomInventory.PeriodTo > &qDateFrom OR RoomInventory.PeriodTo = &qEmptyDate)
		|GROUP BY
		|	RoomInventory.Room,
		|	RoomInventory.RoomBlockType
		|ORDER BY
		|	SortCode";
	КонецЕсли;
	#КонецВставки
	
	#Удаление
	vQryBlocks = New Query();
	vQryBlocks.Text = 
	"SELECT
	|	RoomInventory.Room AS Room,
	|	RoomInventory.RoomBlockType AS RoomBlockType,
	|	RoomInventory.Room.SortCode AS SortCode
	|FROM
	|	AccumulationRegister.RoomInventory AS RoomInventory
	|WHERE " +
	?(ValueIsFilled(Hotel), "Hotel IN HIERARCHY(&qHotel)", "TRUE") + 
	?(ValueIsFilled(SelRoomType), " AND RoomType IN HIERARCHY(&qRoomType)", " AND TRUE") + 
	?(ValueIsFilled(Company), " AND ((RoomInventory.Room.Company = &qCompany) OR (RoomInventory.RoomType.Company = &qCompany) OR (RoomInventory.Room.Company = &qEmptyCompany AND RoomInventory.RoomType.Company = &qEmptyCompany)) ", " AND TRUE") + "
	|	AND RoomInventory.RecordType = &qExpense
	|	AND RoomInventory.IsBlocking
	|	AND RoomInventory.PeriodFrom > &qEmptyDate
	|	AND RoomInventory.PeriodFrom < &qDateTo
	|	AND (RoomInventory.PeriodTo > &qDateFrom OR RoomInventory.PeriodTo = &qEmptyDate)
	|GROUP BY
	|	RoomInventory.Room,
	|	RoomInventory.RoomBlockType
	|ORDER BY
	|	SortCode";
	#КонецУдаления
	vQryBlocks.SetParameter("qHotel", Hotel);
	vQryBlocks.SetParameter("qRoomType", SelRoomType);
	vQryBlocks.SetParameter("qCompany", Company);
	vQryBlocks.SetParameter("qEmptyCompany", Catalogs.Companies.EmptyRef());
	vQryBlocks.SetParameter("qExpense", AccumulationRecordType.Expense);
	vQryBlocks.SetParameter("qDateFrom", DateFrom);
	vQryBlocks.SetParameter("qDateTo", DateTo);
	vQryBlocks.SetParameter("qEmptyDate", Date(1,1,1));
	vBlocks = vQryBlocks.Execute().Unload();
	
	// Get table of guest countries and sexes in all rooms
	#Вставка
	Если НомернойФонд.Пустая() Тогда
		vQryGuests = New Query();
		vQryGuests.Text = 
		"SELECT Разрешенные
		|	RoomInventory.Room AS Room,
		|	RoomInventory.IsReservation AS IsReservation,
		|	RoomInventory.Guest.Citizenship.ISOCode AS GuestCitizenship,
		|	RoomInventory.Guest.Sex AS GuestSex,
		|	COUNT(*) AS GuestCount,
		|	RoomInventory.Room.SortCode AS SortCode
		|FROM (
		|	SELECT
		|		RoomInventoryRecorders.Room AS Room,
		|		RoomInventoryRecorders.IsReservation AS IsReservation,
		|		RoomInventoryRecorders.Guest AS Guest,
		|		RoomInventoryRecorders.Recorder AS Recorder
		|	FROM
		|		AccumulationRegister.RoomInventory AS RoomInventoryRecorders
		|	WHERE " +
		?(ValueIsFilled(Hotel), "RoomInventoryRecorders.Hotel IN HIERARCHY(&qHotel)", "TRUE") + "
		|		AND RoomInventoryRecorders.RecordType = &qExpense
		|		AND RoomInventoryRecorders.PeriodFrom < &qDateTo
		|		AND RoomInventoryRecorders.PeriodTo > &qDateFrom
		|		AND (RoomInventoryRecorders.IsReservation OR RoomInventoryRecorders.IsAccommodation)
		|	GROUP BY
		|		RoomInventoryRecorders.Room,
		|		RoomInventoryRecorders.IsReservation,
		|		RoomInventoryRecorders.Guest,
		|		RoomInventoryRecorders.Recorder) AS RoomInventory
		|GROUP BY
		|	RoomInventory.Room,
		|	RoomInventory.IsReservation,
		|	RoomInventory.Guest.Citizenship.ISOCode,
		|	RoomInventory.Guest.Sex
		|ORDER BY
		|	SortCode
		|TOTALS
		|	SUM(GuestCount)
		|BY
		|	IsReservation, GuestCitizenship, GuestSex, Room HIERARCHY";
	Иначе
		vQryGuests = New Query();
		vQryGuests.МенеджерВременныхТаблиц = МенеджерВТ;
		vQryGuests.Text = 
		"SELECT Разрешенные
		|	RoomInventory.Room AS Room,
		|	RoomInventory.IsReservation AS IsReservation,
		|	RoomInventory.Guest.Citizenship.ISOCode AS GuestCitizenship,
		|	RoomInventory.Guest.Sex AS GuestSex,
		|	COUNT(*) AS GuestCount,
		|	RoomInventory.Room.SortCode AS SortCode
		|FROM (
		|	SELECT
		|		RoomInventoryRecorders.Room AS Room,
		|		RoomInventoryRecorders.IsReservation AS IsReservation,
		|		RoomInventoryRecorders.Guest AS Guest,
		|		RoomInventoryRecorders.Recorder AS Recorder
		|	FROM
		|		AccumulationRegister.RoomInventory AS RoomInventoryRecorders
		| 		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_Номера как ВТ_Номера
		|  		ПО ВТ_Номера.Номер = RoomInventoryRecorders.Room
		|	WHERE " +
		?(ValueIsFilled(Hotel), "RoomInventoryRecorders.Hotel IN HIERARCHY(&qHotel)", "TRUE") + "
		|		AND RoomInventoryRecorders.RecordType = &qExpense
		|		AND RoomInventoryRecorders.PeriodFrom < &qDateTo
		|		AND RoomInventoryRecorders.PeriodTo > &qDateFrom
		|		AND (RoomInventoryRecorders.IsReservation OR RoomInventoryRecorders.IsAccommodation)
		|	GROUP BY
		|		RoomInventoryRecorders.Room,
		|		RoomInventoryRecorders.IsReservation,
		|		RoomInventoryRecorders.Guest,
		|		RoomInventoryRecorders.Recorder) AS RoomInventory
		|GROUP BY
		|	RoomInventory.Room,
		|	RoomInventory.IsReservation,
		|	RoomInventory.Guest.Citizenship.ISOCode,
		|	RoomInventory.Guest.Sex
		|ORDER BY
		|	SortCode
		|TOTALS
		|	SUM(GuestCount)
		|BY
		|	IsReservation, GuestCitizenship, GuestSex, Room HIERARCHY";	
	КонецЕсли;
	#КонецВставки
	
	#Удаление
	vQryGuests = New Query();
	vQryGuests.Text = 
	"SELECT
	|	RoomInventory.Room AS Room,
	|	RoomInventory.IsReservation AS IsReservation,
	|	RoomInventory.Guest.Citizenship.ISOCode AS GuestCitizenship,
	|	RoomInventory.Guest.Sex AS GuestSex,
	|	COUNT(*) AS GuestCount,
	|	RoomInventory.Room.SortCode AS SortCode
	|FROM (
	|	SELECT
	|		RoomInventoryRecorders.Room AS Room,
	|		RoomInventoryRecorders.IsReservation AS IsReservation,
	|		RoomInventoryRecorders.Guest AS Guest,
	|		RoomInventoryRecorders.Recorder AS Recorder
	|	FROM
	|		AccumulationRegister.RoomInventory AS RoomInventoryRecorders
	|	WHERE " +
	?(ValueIsFilled(Hotel), "RoomInventoryRecorders.Hotel IN HIERARCHY(&qHotel)", "TRUE") + "
	|		AND RoomInventoryRecorders.RecordType = &qExpense
	|		AND RoomInventoryRecorders.PeriodFrom < &qDateTo
	|		AND RoomInventoryRecorders.PeriodTo > &qDateFrom
	|		AND (RoomInventoryRecorders.IsReservation OR RoomInventoryRecorders.IsAccommodation)
	|	GROUP BY
	|		RoomInventoryRecorders.Room,
	|		RoomInventoryRecorders.IsReservation,
	|		RoomInventoryRecorders.Guest,
	|		RoomInventoryRecorders.Recorder) AS RoomInventory
	|GROUP BY
	|	RoomInventory.Room,
	|	RoomInventory.IsReservation,
	|	RoomInventory.Guest.Citizenship.ISOCode,
	|	RoomInventory.Guest.Sex
	|ORDER BY
	|	SortCode
	|TOTALS
	|	SUM(GuestCount)
	|BY
	|	IsReservation, GuestCitizenship, GuestSex, Room HIERARCHY";
	#КонецУдаления
	vQryGuests.SetParameter("qHotel", Hotel);
	vQryGuests.SetParameter("qExpense", AccumulationRecordType.Expense);
	vQryGuests.SetParameter("qDateFrom", DateFrom);
	vQryGuests.SetParameter("qDateTo", DateTo);
	vGuests = vQryGuests.Execute().Unload();
	// Group by all dimensions to get room folders totals
	vGuests.GroupBy("IsReservation, GuestCitizenship, GuestSex, Room", "GuestCount");
	
	// Get the table of messages
	vMessages = cmGetMessagesForObjectsList(vRoomsAndFoldersList);
	
	// Calculate number of vacant rooms/beds per room type
	For Each vRoomTypeRow In vRoomTypes Do
		vCurRoomType = vRoomTypeRow.RoomType;
		
		// Ignore empty room type
		If Not ValueIsFilled(vCurRoomType) Then
			Continue;
		EndIf;
		
		If Not vCurRoomType.IsFolder Then
			If vInBeds Then
				vTotalVacant = vTotalVacant + vRoomTypeRow.BedsVacant;
			Else
				vTotalVacant = vTotalVacant + vRoomTypeRow.RoomsVacant;
			EndIf;
		EndIf;
	EndDo;
	
	vThereAreCheckedProperties = False;
	For Each vPropItem In SelRoomProperties Do
		If vPropItem.Check Then
			vThereAreCheckedProperties = True;
			Break;
		EndIf;
	EndDo;
	#Вставка
	vParents = New ValueTable();
	vParents.Columns.Add("Item");
	vParents.Columns.Add("Ref");
	vCurParent = Undefined;
	#КонецВставки
	
	vTableBoxRooms = FormAttributeToValue("TableBoxRooms");
	For Each vRoomRow In vRooms Do
		vCurRoomType = vRoomRow.RoomType;
		vCurRoom = vRoomRow.Room;
		
		// Ignore duplicated totals
		If Not ValueIsFilled(vCurRoom) Then
			Continue;
		Else
			If Not vRoomRow.IsFolder And Not ValueIsFilled(vCurRoomType) Then
				Continue;
			EndIf;
		EndIf;
		If vRoomsArray.Find(vCurRoom) = Undefined Then
			vRoomsArray.Add(vCurRoom);
		Else
			Continue;
		EndIf;
		
		vContinue = False;
		If Not vRoomRow.IsFolder Then
			#Вставка
			vRoomProperties = Новый ТаблицаЗначений;
			#КонецВставки
			#Удаление
			vRoomProperties = GetRoomPropertiesByRoom(vCurRoom);
			#КонецУдаления
			If vRoomProperties.Count() > 0 Then
				For Each vPropItem In SelRoomProperties Do
					If vPropItem.Check Then
						If vPropItem.Value.KeepRoomsWithoutProperty Then
							If vRoomProperties.FindRows(New Structure("RoomProperty", vPropItem.Value)).Count() <> 0 Then
								vContinue = True;
								break;	
							EndIf;
						Else
							If vRoomProperties.FindRows(New Structure("RoomProperty", vPropItem.Value)).Count() = 0 Then
								vContinue = True;
								break;	
							EndIf;
						EndIf;
					EndIf;
				EndDo;
			Else
				If vThereAreCheckedProperties Then
					vContinue = True;
				EndIf;
			EndIf;
		EndIf;
		
		If vContinue Then
			Continue;	
		EndIf;
		
		// Calculate total number of available rooms/beds
		If Not vRoomRow.IsFolder Then
			If SelNumberOfRooms = 0 And SelNumberOfBeds = 0 Then
				If vInBeds Then
					vTotalAvailable = vTotalAvailable + vRoomRow.TotalBeds;
				Else
					vTotalAvailable = vTotalAvailable + vRoomRow.TotalRooms;
				EndIf;
			Else
				If vInBeds Then
					vTotalAvailable = vTotalAvailable + vRoomRow.BedsVacant;
				Else
					vTotalAvailable = vTotalAvailable + vRoomRow.RoomsVacant;
				EndIf;
			EndIf;
		EndIf;
		#Вставка
		vCurRoom = vRoomRow.Room;
		
		If ValueIsFilled(vRoomRow.Parent) Then
			vParentsRow = vParents.Find(vRoomRow.Parent, "Ref");	
		
			If vParentsRow = Undefined Then
				vCurFolderItem = vTableBoxRooms;
			Else
				vCurFolderItem = vParentsRow.Item;
			EndIf;
		Else
			vCurFolderItem = vTableBoxRooms;
		EndIf;
		
		If vCurParent <> vRoomRow.Parent Then
			
			vCurParent = vRoomRow.Parent;	
		
			If vRoomRow.IsFolder Then
				vCurFolderItem = vCurFolderItem.Rows.Add();
				FillPropertyValues(vCurFolderItem, vRoomRow);				
				vParentsRow = vParents.Add();
				vParentsRow.Ref = vRoomRow.Room;
				vParentsRow.Item = vCurFolderItem;	
			EndIf;
			
		EndIf;
		
		If Not vRoomRow.IsFolder  Then	
			vTableRow = vCurFolderItem.Rows.Add();
		Иначе
			vTableRow = vCurFolderItem;
		EndIf;	
		#КонецВставки
		// Add new row
		#Удаление	
		vTableRow = vTableBoxRooms.Rows.Add();
		vRowIndex = vTableBoxRooms.Rows.IndexOf(vTableRow);
		#КонецУдаления
		// Fill main parameters
		vTableRow.Room = vCurRoom;
		vTableRow.RoomType = vCurRoomType;
		vTableRow.RoomStatus = vRoomRow.RoomStatus;
		vTableRow.SortCode = vRoomRow.SortCode;
		vTableRow.BedsVacant = vRoomRow.BedsVacant;
		vTableRow.RoomsVacant = vRoomRow.RoomsVacant;
		vTableRow.IsFolder = vRoomRow.IsFolder;
		vTableRow.IsVirtual = vRoomRow.IsVirtual;
		vTableRow.Company = vRoomRow.Company;
		If Not vRoomRow.IsFolder Then
			vTableRow.StopSale = vRoomRow.StopSale;
			vTableRow.RoomTypeStopSale = vRoomRow.RoomTypeStopSale;
		EndIf;
		vTableRow.RoomPropertiesCodes = StrReplace(vRoomRow.RoomPropertiesDescriptions, Chars.LF, ", ");
		
		// Fill picture index		
		If vRoomRow.IsFolder Then
			vTableRow.Icon = 6;
		Else
			If vInBeds Then
				If vTableRow.BedsVacant > 0 Then
					vTableRow.IsVacant = True;
					vTableRow.Icon = 20;
				Else
					vTableRow.IsVacant = False;
					vTableRow.Icon = 18;
				EndIf;
			Else
				If vTableRow.RoomsVacant > 0 And vTableRow.BedsVacant > 0 Then
					vTableRow.IsVacant = True;
					vTableRow.Icon = 20;
				Else
					vTableRow.IsVacant = False;
					vTableRow.Icon = 18;
				EndIf;
			EndIf;
			If vTableRow.StopSale Or vTableRow.RoomTypeStopSale Then
				vTableRow.Icon = 18;		
			EndIf;
		EndIf;
		
		// Fill vacant from
		If Not vRoomRow.IsFolder Then
			If vTableRow.IsVacant Then
				vRow = vVacants.Find(vCurRoom, "Room");
				If vRow <> Undefined Then
					vTableRow.VacantFrom = Format(vRow.CheckOutDate, "DF='dd.MM.yyyy HH:mm'");
				EndIf;
			EndIf;
		EndIf;
		
		// Fill guests
		vRowsArray = vGuests.FindRows(New Structure("Room", vCurRoom));
		vGuestsStr = "";
		For Each vRow In vRowsArray Do
			If Not IsBlankString(vGuestsStr) Then
				vGuestsStr = vGuestsStr + ", ";
			EndIf;
			vGuestCount = vRow.GuestCount;
			If Not vRoomRow.IsFolder Then
				vGuestCount = vGuestCount/2;
			EndIf;
			vGuestSex = TrimAll(String(vRow.GuestSex));
			vGuestCitizenship = TrimAll(vRow.GuestCitizenship);
			vGuestsStr = vGuestsStr + ?(vRow.IsReservation, NStr("en='r';ru='р';de='r'"), "") + 
			String(vGuestCount) + 
			Left(?(vGuestSex="", "?", vGuestSex), 1) + 
			"(" + ?(vGuestCitizenship="", "?", vGuestCitizenship) + ")";
		EndDo;
		vTableRow.Guests = vGuestsStr;
		
		// Fill room blocks
		If Not vRoomRow.IsFolder Then
			vRowsArray = vBlocks.FindRows(New Structure("Room", vCurRoom));
			vBlocksStr = "";
			If Not IsBlankString(vTableRow.Guests) Then
				vBlocksStr = Chars.LF;
			EndIf;
			For Each vRow In vRowsArray Do
				If Not IsBlankString(vBlocksStr) And vBlocksStr <> Chars.LF Then
					vBlocksStr = vBlocksStr + ", ";
				EndIf;
				If ValueIsFilled(vRow.RoomBlockType) Then
					vBlocksStr = vBlocksStr + TrimAll(vRow.RoomBlockType.Description);
				EndIf;
			EndDo;
			vTableRow.Guests = vTableRow.Guests + vBlocksStr;
		EndIf;
		
		// Fill vacant to
		If Not vRoomRow.IsFolder Then
			If vTableRow.IsVacant Then
				vRow = vReserves.Find(vCurRoom, "Room");
				If vRow <> Undefined Then
					vTableRow.VacantTo = Format(vRow.CheckInDate, "DF='dd.MM.yyyy HH:mm'");
				EndIf;
			EndIf;
		EndIf;
		
		// Fill messages
		vTableRow.Messages = cmGetMessagesPresentationForObject(vMessages, vCurRoom);
		// Fill room remarks
		If Not IsBlankString(vRoomRow.Remarks) Then
			If Not IsBlankString(vTableRow.Messages) Then
				vTableRow.Messages = vTableRow.Messages + Chars.LF;
			EndIf;
			vTableRow.Messages = vTableRow.Messages + TrimAll(vRoomRow.Remarks);
		EndIf;
	EndDo;
	
	RoomsVacantTotal = vTableBoxRooms.Rows.Total("RoomsVacant", True);
	BedsVacantTotal = vTableBoxRooms.Rows.Total("BedsVacant", True);
	ValueToFormAttribute(vTableBoxRooms, "TableBoxRooms");
EndProcedure


&НаКлиенте
Процедура Расш1_TableBoxRoomsПриАктивизацииСтрокиПосле(Элемент)
	
	Если ТипЗнч(ЭтаФорма.ВладелецФормы) = Тип("ПолеФормы")тогда
		Возврат;	
	КонецЕсли;
	
	vCurData = Items.TableBoxRooms.CurrentData;
	
	If vCurData = Undefined Тогда
		Элементы.TableBoxRoomsЗанятьОсвободить.Видимость = Ложь;
		Возврат;
	EndIf;
	
	Если vCurData.IsFolder Тогда
		Элементы.TableBoxRoomsЗанятьОсвободить.Видимость = Ложь;
		Возврат;
	КонецЕсли;
	
	Элементы.TableBoxRoomsЗанятьОсвободить.Видимость = Истина;
	
	Если vCurData.RoomsVacant > 0 или vCurData.BedsVacant > 0 Тогда
		Элементы.TableBoxRoomsЗанятьОсвободить.Заголовок = "Поселить";
		Элементы.TableBoxRoomsЗанятьОсвободить.Картинка = БиблиотекаКартинок.CheckIn;	
	Иначе
		Элементы.TableBoxRoomsЗанятьОсвободить.Заголовок = "Выселить";
		Элементы.TableBoxRoomsЗанятьОсвободить.Картинка = БиблиотекаКартинок.CheckOut;
	КонецЕсли;
	
КонецПроцедуры


&НаСервере
Функция ПолучитьТекущийДокументРазмещения(vCurData)
	
	ДокументРазмещения =Неопределено;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ ПЕРВЫЕ 1
		|	Accommodation.Ссылка КАК Document
		|ИЗ
		|	Документ.Accommodation КАК Accommodation
		|ГДЕ
		|	Accommodation.room = &Romm
		|	И Accommodation.AccommodationStatus.IsActive
		|	И Accommodation.AccommodationStatus.IsInHouse
		|	И Accommodation.Проведен
		|
		|УПОРЯДОЧИТЬ ПО
		|	Accommodation.Дата";
	
	Запрос.УстановитьПараметр("Romm", vCurData);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		ДокументРазмещения = ВыборкаДетальныеЗаписи.Document;
	КонецЦикла;
	
	Возврат ДокументРазмещения
	
КонецФункции

&AtServer
&ChangeAndValidate("OnCreateAtServer")
Procedure Расш1_OnCreateAtServer(Cancel, StandardProcessing)
	#Вставка
	Элементы.TableBoxRoomsЗанятьОсвободить.Видимость = Ложь;
	#КонецВставки
	If Parameters.Property("Hotel") Then
		Hotel = Parameters.Hotel;
	EndIf;
	SelRoomProperties = cmGetAllRoomProperties(Undefined, Hotel); 
	If Parameters.Property("SelRoomProperties") Then
		For Each vRP In Parameters.SelRoomProperties Do
			If ValueIsFilled(vRP.Value) Then
				vRPItem = SelRoomProperties.FindByValue(vRP.Value);
				If vRPItem <> Undefined Then
					vRPItem.Check = True;
				EndIf;
			EndIf;
		EndDo;
	EndIf;
	If Not ValueIsFilled(Hotel) Then
		Hotel = SessionParameters.CurrentHotel;
	EndIf;
	If Parameters.Property("DateFrom") Then
		DateFrom = cm1SecondShift(Parameters.DateFrom);
		Items.DateFrom.ReadOnly = True;
	Else
		DateFrom = CurrentSessionDate();
	EndIf;
	If Parameters.Property("DateTo") Then
		DateTo = cm0SecondShift(Parameters.DateTo);
		Items.DateTo.ReadOnly = True;
	Else
		DateTo = cmCalculateCheckOutDate(Hotel.RoomRate, DateFrom, 1);
	EndIf;
	If Parameters.Property("RoomType") Then
		SelRoomType = Parameters.RoomType;
	EndIf;
	If Parameters.Property("RoomQuota") Then
		If ValueIsFilled(Parameters.RoomQuota) And Parameters.RoomQuota.IsQuotaForRooms Then
			SelRoomQuota = Parameters.RoomQuota;
		EndIf;
	EndIf;
	If Parameters.Property("Room") Then
		SelRoom = Parameters.Room;
	EndIf;
	If Parameters.Property("IsOpenedFromReservation") Then
		SelIsOpenedFromReservation = Parameters.IsOpenedFromReservation;
	EndIf;	
	If Parameters.Property("NumberOfBeds") Then
		SelNumberOfBeds = Parameters.NumberOfBeds;
	EndIf;	
	If Parameters.Property("NumberOfRooms") Then
		SelNumberOfRooms = Parameters.NumberOfRooms;
	EndIf;
	If Parameters.Property("Company") Then
		Company = Parameters.Company;
	EndIf;
	RoomPropertiesPresentation = GetRoomPropertiesPresentation();
	OnOpenForm();
	PutData();	
EndProcedure


&НаКлиенте
Процедура Расш1_ЗанятьОсвободитьПосле(Команда)

	Если ТипЗнч(ЭтаФорма.ВладелецФормы) = Тип("ПолеФормы")тогда
		Возврат;	
	КонецЕсли;
	
	vCurData = Items.TableBoxRooms.CurrentData;
	
	If vCurData = Undefined Тогда
		Возврат;
	EndIf;
	
	Если vCurData.IsFolder Тогда
		Возврат;
	КонецЕсли;
	
	ТекущийДокументРазмещения = ПолучитьТекущийДокументРазмещения(vCurData.Room);
	
	Если ТекущийДокументРазмещения = Неопределено Тогда 
		//ПараметрыФормы = Новый Структура("Room", vCurData.Room);
		ПараметрыФормы = Новый Структура("Номер", vCurData.Room);
		ОткрытьФорму("Документ.Accommodation.Форма.tcDocumentForm", ПараметрыФормы);
	Иначе
		ПараметрыФормы = Новый Структура("Ключ", ТекущийДокументРазмещения);
		ОткрытьФорму("Документ.Accommodation.Форма.tcDocumentForm", ПараметрыФормы);	
	КонецЕсли;
	
КонецПроцедуры

&AtServer
&ChangeAndValidate("OnOpenForm")
Procedure Расш1_OnOpenForm()
	vVacantRoomStatus = Undefined;
	If ValueIsFilled(Hotel) And ValueIsFilled(Hotel.VacantRoomStatus) Then
		vVacantRoomStatus = Hotel.VacantRoomStatus;
	EndIf;
	RoomStsCode = "Any";
	vRoomStses = GetAllRoomStatuses();
	vCommand = Commands.Add("RoomStsAny");
	vCommand.Action = "ClickRoomSts";
	vStructure = New Structure("Title, CommandName, Representation, Type, Check", NStr("en = 'Any'; de = 'Beliebig'; ru = 'Любой'"), "RoomStsAny", ButtonRepresentation.Text, FormButtonType.CommandBarButton, True);		
	#Удаление
	tcOnServer.cmCreateItem(ThisForm, Items.GroupFilterStatusCompact, "RoomStsAny", "FormButton", vStructure);
	For Each vRoomSts In vRoomStses Do
		vRoomStsesCode = cmGetValidName(TrimAll(vRoomSts.Code));
		
		vCommand = Commands.Add("RoomSts" + vRoomStsesCode);
		vCommand.Action = "ClickRoomSts";
		vStructure = New Structure("Title, CommandName, Representation, Picture, Type", TrimAll(vRoomSts.Description), "RoomSts" + vRoomStsesCode, ButtonRepresentation.PictureAndText, tcOnServer.cmGetRoomStatusIconOnServer(vRoomSts.RoomStatus), FormButtonType.CommandBarButton);		
		tcOnServer.cmCreateItem(ThisForm, Items.GroupFilterStatusCompact, "RoomSts" + vRoomStsesCode, "FormButton", vStructure); 
		vNewRow = TempRoomSts.Add();
		vNewRow.RoomStsCode = vRoomStsesCode;
		vNewRow.Value = vRoomSts.RoomStatus;
		If vVacantRoomStatus = vRoomSts.RoomStatus Then
			If Not SelIsOpenedFromReservation Then
				If BegOfDay(ThisForm.DateFrom) = BegOfDay(CurrentSessionDate()) Then
					RoomStsCode = vRoomStsesCode;
					Items["FormButtonRoomSts" + vRoomStsesCode].Check = True;
					Items["FormButtonRoomStsAny"].Check = False;
				EndIf;
			EndIf;
		EndIf;

	EndDo;  
	#КонецУдаления
	If Not ValueIsFilled(DateFrom) Or Not ValueIsFilled(DateTo) Then
		DateFrom = CurrentSessionDate();
		DateTo = CurrentSessionDate()+86400;
	EndIf;
EndProcedure //OnOpenForm
