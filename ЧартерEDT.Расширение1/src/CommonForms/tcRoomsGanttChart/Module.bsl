
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
	RefreshList();
КонецПроцедуры


&AtServer
&ChangeAndValidate("GetMaximumNumberOfBedsPerRoom")
Function Расш1_GetMaximumNumberOfBedsPerRoom()
	#Вставка	
	Если НомернойФонд.Пустая() Тогда
		vQry = New Query();
		vQry.Text = 
		"SELECT Разрешенные
		|	MAX(Rooms.NumberOfBedsPerRoom) AS NumberOfBedsPerRoom,
		|	MAX(Rooms.NumberOfPersonsPerRoom) AS NumberOfPersonsPerRoom
		|FROM
		|	Catalog.Rooms AS Rooms
		|WHERE
		|	(NOT &qHotelIsFilled
		|			OR &qHotelIsFilled
		|				AND Rooms.Owner IN HIERARCHY (&qHotel))
		|	AND (NOT &qRoomIsFilled
		|			OR &qRoomIsFilled
		|				AND Rooms.Ref IN HIERARCHY (&qRoom))
		|	AND (NOT &qRoomSectionIsFilled
		|			OR &qRoomSectionIsFilled
		|				AND Rooms.RoomSection IN HIERARCHY (&qRoomSection))
		|	AND (NOT &qRoomTypeIsFilled
		|			OR &qRoomTypeIsFilled
		|				AND Rooms.RoomType IN HIERARCHY (&qRoomType))
		|	AND NOT Rooms.IsVirtual";
		
	Иначе
		vQry = New Query();
		vQry.Text = 
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	МАКСИМУМ(Rooms.NumberOfBedsPerRoom) КАК NumberOfBedsPerRoom,
		|	МАКСИМУМ(Rooms.NumberOfPersonsPerRoom) КАК NumberOfPersonsPerRoom
		|ИЗ
		|	Справочник.Rooms КАК Rooms
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.Расш1_СоставНомерногоФонда КАК Расш1_СоставНомерногоФонда
		|		ПО (Rooms.Ссылка = Расш1_СоставНомерногоФонда.Номер
		|				И Расш1_СоставНомерногоФонда.НомернойФонд = &НомернойФонд)
		|ГДЕ
		|	(НЕ &qHotelIsFilled
		|			ИЛИ &qHotelIsFilled
		|				И Rooms.Владелец В ИЕРАРХИИ (&qHotel))
		|	И (НЕ &qRoomIsFilled
		|			ИЛИ &qRoomIsFilled
		|				И Rooms.Ссылка В ИЕРАРХИИ (&qRoom))
		|	И (НЕ &qRoomSectionIsFilled
		|			ИЛИ &qRoomSectionIsFilled
		|				И Rooms.RoomSection В ИЕРАРХИИ (&qRoomSection))
		|	И (НЕ &qRoomTypeIsFilled
		|			ИЛИ &qRoomTypeIsFilled
		|				И Rooms.RoomType В ИЕРАРХИИ (&qRoomType))
		|	И НЕ Rooms.IsVirtual";
		vQry.SetParameter("НомернойФонд", НомернойФонд);
	КонецЕсли;	
	#КонецВставки
	
	#Удаление
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	MAX(Rooms.NumberOfBedsPerRoom) AS NumberOfBedsPerRoom,
	|	MAX(Rooms.NumberOfPersonsPerRoom) AS NumberOfPersonsPerRoom
	|FROM
	|	Catalog.Rooms AS Rooms
	|WHERE
	|	(NOT &qHotelIsFilled
	|			OR &qHotelIsFilled
	|				AND Rooms.Owner IN HIERARCHY (&qHotel))
	|	AND (NOT &qRoomIsFilled
	|			OR &qRoomIsFilled
	|				AND Rooms.Ref IN HIERARCHY (&qRoom))
	|	AND (NOT &qRoomSectionIsFilled
	|			OR &qRoomSectionIsFilled
	|				AND Rooms.RoomSection IN HIERARCHY (&qRoomSection))
	|	AND (NOT &qRoomTypeIsFilled
	|			OR &qRoomTypeIsFilled
	|				AND Rooms.RoomType IN HIERARCHY (&qRoomType))
	|	AND NOT Rooms.IsVirtual";
	#КонецУдаления
	vQry.SetParameter("qHotel", SelHotel);
	vQry.SetParameter("qHotelIsFilled", ValueIsFilled(SelHotel));
	vQry.SetParameter("qRoomType", SelRoomType);
	vQry.SetParameter("qRoomTypeIsFilled", ValueIsFilled(SelRoomType));
	vQry.SetParameter("qRoomSection", SelRoomSection);
	vQry.SetParameter("qRoomSectionIsFilled", ValueIsFilled(SelRoomSection));
	vQry.SetParameter("qRoom", SelRoom);
	vQry.SetParameter("qRoomIsFilled", ValueIsFilled(SelRoom));
	vRes = vQry.Execute().Unload();
	If vRes.Count() > 0 Then
		If SelShowAllGuests = 0 Then
			Return vRes.Get(0).NumberOfBedsPerRoom;
		Else
			Return vRes.Get(0).NumberOfPersonsPerRoom;
		EndIf;
	Else
		Return 2;
	EndIf;
EndFunction


&AtServer
&ChangeAndValidate("GetRoomsGanttChartData")
Function Расш1_GetRoomsGanttChartData(pPeriodFrom, pPeriodTo)
	// Check should we show only vacant rooms
	vShowVacantRoomsOnly = False;
	// Reset some variables
	SelCheckInDate = '00010101';
	SelCheckOutDate = '00010101';
	// Build and run query
	#Вставка
	Если НомернойФонд.Пустая() Тогда
		vQry = New Query();
		vQry.Text = 
		"SELECT разрешенные
		|	RoomInventoryBalance.Hotel,
		|	RoomInventoryBalance.Room,
		|	RoomInventoryBalance.RoomType,
		|	ISNULL(RoomInventoryBalance.TotalRoomsBalance, 0) AS TotalRoomsBalance,
		|	ISNULL(RoomInventoryBalance.RoomsVacantBalance, 0) AS RoomsVacantBalance
		|INTO RoomInventoryBalance
		|FROM
		|	AccumulationRegister.RoomInventory.Balance(&qDate, TRUE" + 
		?(SelRoomTypes.Count() > 1, " AND RoomType IN HIERARCHY (&qRoomTypes)", ?(ValueIsFilled(SelRoomType), ?(SelRoomType.IsFolder, " AND RoomType IN HIERARCHY(&qRoomType)", " AND RoomType = &qRoomType"), "")) + 
		?(ValueIsFilled(SelRoom), ?(SelRoom.IsFolder, " AND Room IN HIERARCHY(&qRoom)", " AND Room = &qRoom"), "") + 
		?(ValueIsFilled(SelRoomSection), ?(SelRoomSection.IsFolder, " AND Room.RoomSection IN HIERARCHY(&qRoomSection)", " AND Room.RoomSection = &qRoomSection"), "") + 
		?(ValueIsFilled(SelHotel), ?(SelHotel.IsFolder, " AND Hotel IN HIERARCHY(&qHotel)", " AND Hotel = &qHotel"), "") + "
		|) AS RoomInventoryBalance
		|WHERE" + 
		?(vShowVacantRoomsOnly, " ISNULL(RoomInventoryBalance.RoomsVacantBalance, 0) > 0", " ISNULL(RoomInventoryBalance.TotalRoomsBalance, 0) > 0") + "
		|;
		|
		|SELECT  разрешенные
		|	ResDocuments.Recorder AS Accommodation,
		|	ResDocuments.Room AS Room,
		|	ResDocuments.RoomType AS RoomType,
		|	CASE
		|		WHEN ResDocuments.IsAccommodation THEN
		|			ResDocuments.AccommodationStatus 
		|		ELSE
		|			ResDocuments.ReservationStatus
		|	END AS Status,
		|	ResDocuments.PeriodFrom AS CheckInDate,
		|	ResDocuments.PeriodTo AS CheckOutDate,
		|	ResDocuments.AccommodationType AS AccommodationType,
		|	ResDocuments.RoomRate AS RoomRate
		|INTO ResDocuments
		|FROM
		|	AccumulationRegister.RoomInventory AS ResDocuments
		|WHERE
		|	ResDocuments.PeriodFrom < &qPeriodTo
		|	AND ResDocuments.PeriodTo > &qPeriodFrom " +  
		?(ValueIsFilled(SelHotel), ?(SelHotel.IsFolder, " AND ResDocuments.Hotel IN HIERARCHY(&qHotel)", " AND ResDocuments.Hotel = &qHotel"), "") + "
		|	AND ResDocuments.RecordType = &qExpense
		|	AND (ResDocuments.IsAccommodation OR ResDocuments.IsReservation) " + 
		?(Not IsBlankString(SelDocNumber), " AND ResDocuments.Recorder.Number = &qDocNumber", "") + 
		?(ValueIsFilled(SelCustomer), ?(SelCustomer.IsFolder, " AND ResDocuments.Customer IN HIERARCHY(&qCustomer)", " AND ResDocuments.Customer = &qCustomer"), "") + 
		?(ValueIsFilled(SelContract), " AND ResDocuments.Contract = &qContract", "") + 
		?(Not IsBlankString(SelRemarks), " AND (ResDocuments.Remarks LIKE &qRemarks OR ResDocuments.Car LIKE &qRemarks)", "") + 
		?(ValueIsFilled(SelGuest), " AND ResDocuments.Guest = &qGuest", 
		?(IsBlankString(SelGuestStr), "", " AND (ResDocuments.Guest.FullName LIKE &qGuestStr OR ResDocuments.Customer.Description LIKE &qGuestStr)")) + 
		?(ValueIsFilled(SelGuestGroup), " AND ResDocuments.GuestGroup = &qGuestGroup", "") + 
		?(SelShowExpectedChangeRoomOnly, " AND (ResDocuments.PeriodTo < ResDocuments.CheckOutDate AND ResDocuments.CheckOutAccountingDate = &qBegOfCurrentDate OR ResDocuments.PeriodFrom > ResDocuments.CheckInDate AND ResDocuments.CheckInAccountingDate = &qBegOfCurrentDate)", "") + 
		?(SelIntersection,
		?(ValueIsFilled(SelCheckInDate), " AND ResDocuments.PeriodTo > &qCheckInDate", "") + 
		?(ValueIsFilled(SelCheckOutDate), " AND ResDocuments.PeriodFrom < &qCheckOutDate", ""), 
		?(ValueIsFilled(SelCheckInDate), " AND ResDocuments.PeriodFrom >= &qBegOfCheckInDate AND ResDocuments.PeriodFrom < &qEndOfCheckInDate", "") + 
		?(ValueIsFilled(SelCheckOutDate), " AND ResDocuments.PeriodTo >= &qBegOfCheckOutDate AND ResDocuments.PeriodTo < &qEndOfCheckOutDate", "")) + "
		|GROUP BY
		|	ResDocuments.Recorder,
		|	ResDocuments.Room,
		|	ResDocuments.RoomType,
		|	CASE
		|		WHEN ResDocuments.IsAccommodation THEN
		|			ResDocuments.AccommodationStatus 
		|		ELSE
		|			ResDocuments.ReservationStatus
		|	END,
		|	ResDocuments.PeriodFrom,
		|	ResDocuments.PeriodTo,
		|	ResDocuments.AccommodationType,
		|	ResDocuments.RoomRate
		|;
		|
		|SELECT Разрешенные
		|	RoomInventoryBalance.Hotel,
		|	RoomInventoryBalance.Room,
		|	RoomInventoryBalance.RoomType,
		|	Documents.Accommodation AS Accommodation,
		|	Documents.Status AS Status,
		|	Documents.Accommodation.AccommodationTemplate AS AccommodationTemplate,
		|	Documents.Accommodation.ParentDoc AS ParentDoc,
		|	Documents.Accommodation.ClientType AS ClientType,
		|	Documents.Accommodation.Guest AS Guest,
		|	Documents.CheckInDate AS CheckInDate,
		|	Documents.CheckOutDate AS CheckOutDate,
		|	Documents.AccommodationType AS AccommodationType,
		|	Documents.RoomRate AS RoomRate,
		|	Documents.Accommodation.GuestGroup AS GuestGroup,
		|	Documents.Accommodation.HotelProduct AS HotelProduct,
		|	Documents.Accommodation.RoomQuota AS RoomQuota,
		|	Documents.Accommodation.Customer AS Customer,
		|	Documents.Accommodation.Contract AS Contract, 
		|	Documents.Accommodation.ContactPerson AS ContactPerson,
		|	Documents.Accommodation.Agent AS Agent, 
		|	Documents.Accommodation.PlannedPaymentMethod AS PlannedPaymentMethod, 
		|	Documents.Accommodation.NumberOfPersons AS NumberOfPersons, 
		|	MIN(RoomInventoryBalance.RoomsVacantBalance) AS RoomsVacantBalance
		|INTO Accommodations
		|FROM
		|	RoomInventoryBalance AS RoomInventoryBalance
		|		" + ?(IsBlankString(SelGuestStr), "LEFT", "INNER") + " JOIN ResDocuments AS Documents
		|		ON RoomInventoryBalance.Room = Documents.Room" + 
		?(SelShowExpectedChangeRoomOnly, "WHERE NOT (Documents.Accommodation IS NULL)", "") + " 
		|
		|GROUP BY
		|	RoomInventoryBalance.Hotel,
		|	RoomInventoryBalance.Room,
		|	RoomInventoryBalance.RoomType,
		|	Documents.Accommodation,
		|	Documents.Status,
		|	Documents.CheckInDate,
		|	Documents.CheckOutDate,
		|	Documents.AccommodationType,
		|	Documents.RoomRate
		|;
		|
		|SELECT разрешенные
		|	Accommodations.Room.Owner AS Hotel,
		|	Accommodations.Room.Owner.SortCode AS HotelSortCode,
		|	Accommodations.Room AS Room,
		|	Accommodations.Room.SortCode AS RoomSortCode,
		|	Accommodations.Room AS RoomInDocument,
		|	ISNULL(Accommodations.Room.Description, """") AS RoomDescription,
		|	ISNULL(Accommodations.Room.IsFolder, FALSE) AS RoomIsFolder,
		|	Accommodations.Room.Parent AS RoomParent,
		|	Accommodations.Room.Parent.Description AS RoomParentDescription,
		|	Accommodations.Room.RoomStatus AS RoomRoomStatus,
		|	ISNULL(Accommodations.Room.StopSale, FALSE) AS RoomStopSale,
		|	Accommodations.Room.RoomPropertiesCodes AS RoomRoomPropertiesCodes,
		|	Accommodations.RoomType AS RoomType,
		|	Accommodations.RoomType.SortCode AS RoomTypeSortCode,
		|	Accommodations.RoomType.Code AS RoomTypeCode,
		|	Accommodations.RoomType.Description AS RoomTypeDescription,
		|	ISNULL(Accommodations.RoomType.IsFolder, FALSE) AS RoomTypeIsFolder,
		|	ISNULL(Accommodations.RoomType.StopSale, FALSE) AS RoomTypeStopSale,
		|	Accommodations.RoomType.Parent AS RoomTypeParent,
		|	Accommodations.Accommodation AS Accommodation,
		|	Accommodations.Accommodation.Number AS AccommodationNumber,
		|	Accommodations.Accommodation.PointInTime AS AccommodationPointInTime,
		|	Accommodations.ParentDoc AS ParentDoc,
		|	Accommodations.ParentDoc.Room AS ParentDocRoom,
		|	ISNULL(Accommodations.ParentDoc.ReservationStatus.IsCheckIn, FALSE) AS ParentDocReservationStatusIsCheckIn,
		|	Accommodations.Guest AS Guest,
		|	Accommodations.Guest.Description AS GuestDescription,
		|	Accommodations.Guest.FullName AS GuestFullName,
		|	Accommodations.Guest.Citizenship AS GuestCitizenship,
		|	Accommodations.Guest.Citizenship.ISOCode AS GuestCitizenshipISOCode,
		|	Accommodations.Guest.Sex AS GuestSex,
		|	Accommodations.Guest.DateOfBirth AS GuestDateOfBirth,
		|	Accommodations.CheckInDate AS CheckInDate,
		|	Accommodations.CheckOutDate AS CheckOutDate,
		|	Accommodations.AccommodationType AS AccommodationType,
		|	Accommodations.AccommodationType.Type AS AccommodationTypeType,
		|	Accommodations.RoomRate AS RoomRate,
		|	Accommodations.ClientType AS ClientType,
		|	Accommodations.ClientType.Color AS ClientTypeColor,
		|	Accommodations.AccommodationTemplate AS AccommodationTemplate,
		|	Accommodations.Status AS Status,
		|	Accommodations.Status.Color AS StatusColor,
		|	ISNULL(Accommodations.Status.IsInHouse, FALSE) AS StatusIsInHouse,
		|	ISNULL(Accommodations.Status.IsGuaranteed, FALSE) AS StatusIsGuaranteed,
		|	Accommodations.GuestGroup AS GuestGroup,
		|	Accommodations.GuestGroup.Code AS GuestGroupCode,
		|	Accommodations.GuestGroup.Description AS GuestGroupDescription,
		|	Accommodations.GuestGroup.Color AS GuestGroupColor,
		|	Accommodations.HotelProduct AS HotelProduct,
		|	Accommodations.HotelProduct.Description AS HotelProductDescription,
		|	Accommodations.HotelProduct.Parent AS HotelProductParent,
		|	Accommodations.HotelProduct.Parent.Description AS HotelProductParentDescription,
		|	Accommodations.RoomQuota AS RoomQuota,
		|	Accommodations.RoomQuota.Code AS RoomQuotaCode,
		|	Accommodations.RoomQuota.Color AS RoomQuotaColor,
		|	Accommodations.Customer AS Customer,
		|	Accommodations.Customer.Code AS CustomerCode,
		|	Accommodations.Customer.Color AS CustomerColor,
		|	ISNULL(Accommodations.Customer.IsIndividual, TRUE) AS CustomerIsIndividual,
		|	Accommodations.Contract AS Contract,
		|	Accommodations.Contract.Code AS ContractCode,
		|	Accommodations.Contract.Color AS ContractColor,
		|	Accommodations.ContactPerson AS ContactPerson,
		|	Accommodations.Agent AS Agent,
		|	Accommodations.Accommodation.Remarks AS Remarks,
		|	Accommodations.Accommodation.Car AS Car,
		|	Accommodations.Accommodation.IsMaster AS IsMaster,
		|	Accommodations.Accommodation.IsClosedForEdit AS IsClosedForEdit,
		|	Accommodations.PlannedPaymentMethod AS PlannedPaymentMethod,
		|	Accommodations.PlannedPaymentMethod.Code AS PlannedPaymentMethodCode,
		|	Accommodations.PlannedPaymentMethod.Description AS PlannedPaymentMethodDescription,
		|	Accommodations.PlannedPaymentMethod.IsByBankTransfer AS IsByBankTransfer,
		|	Accommodations.NumberOfPersons AS NumberOfPersons,
		|	Accommodations.Accommodation.ServicePackage AS ServicePackage,
		|	CAST(Accommodations.Accommodation.PricePresentation AS STRING(17)) AS PricePresentation,
		|	0 AS DurationInSeconds,
		|	0 AS OverbookingIndex,
		|	CASE
		|		WHEN Accommodations.Accommodation.AccommodationType.Type = &qAccomodationTypesRoom THEN 0
		|		WHEN Accommodations.Accommodation.AccommodationType.Type = &qAccomodationTypesBeds THEN 0
		|		WHEN Accommodations.Accommodation.AccommodationType.Type = &qAccomodationTypesAdditionalBed THEN 1
		|		ELSE 2
		|	END AS AccommodationTypeSortCode,
		|	CASE
		|		WHEN NOT Accommodations.Accommodation.NumberOfBeds IS NULL THEN Accommodations.Accommodation.NumberOfBeds
		|		WHEN NOT Accommodations.Accommodation.RoomBlockType IS NULL THEN Accommodations.Room.NumberOfBedsPerRoom
		|		ELSE 0
		|	END AS NumberOfBeds,
		|	Accommodations.RoomsVacantBalance AS RoomsVacantBalance,
		|	ISNULL(Accommodations.Accommodation.RoomQuantity, 1) AS RoomQuantity
		|
		|FROM Accommodations AS Accommodations
		|
		|ORDER BY
		|	HotelSortCode, " +
		?(SelShowRoomsByRoomTypes, "RoomTypeSortCode, RoomTypeDescription, ", "") + "
		|	RoomSortCode,
		|	CheckInDate,
		|	RoomQuotaCode,
		|	CustomerCode,
		|	ContractCode,
		|	GuestGroupCode,
		|	AccommodationTypeSortCode,
		|	AccommodationPointInTime
		|
		|TOTALS
		|BY
		|	Hotel ONLY HIERARCHY, " + 
		?(SelShowRoomsByRoomTypes, "RoomType HIERARCHY", "Room ONLY HIERARCHY");
		
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
		"SELECT разрешенные
		|	RoomInventoryBalance.Hotel,
		|	RoomInventoryBalance.Room,
		|	RoomInventoryBalance.RoomType,
		|	ISNULL(RoomInventoryBalance.TotalRoomsBalance, 0) AS TotalRoomsBalance,
		|	ISNULL(RoomInventoryBalance.RoomsVacantBalance, 0) AS RoomsVacantBalance
		|INTO RoomInventoryBalance
		|FROM
		|	AccumulationRegister.RoomInventory.Balance(&qDate, TRUE" + 
		?(SelRoomTypes.Count() > 1, " AND RoomType IN HIERARCHY (&qRoomTypes)", ?(ValueIsFilled(SelRoomType), ?(SelRoomType.IsFolder, " AND RoomType IN HIERARCHY(&qRoomType)", " AND RoomType = &qRoomType"), "")) + 
		?(ValueIsFilled(SelRoom), ?(SelRoom.IsFolder, " AND Room IN HIERARCHY(&qRoom)", " AND Room = &qRoom"), " И Room В (Выбрать Т.Номер Из ВТ_Номера Как Т)") + 
		?(ValueIsFilled(SelRoomSection), ?(SelRoomSection.IsFolder, " AND Room.RoomSection IN HIERARCHY(&qRoomSection)", " AND Room.RoomSection = &qRoomSection"), "") + 
		?(ValueIsFilled(SelHotel), ?(SelHotel.IsFolder, " AND Hotel IN HIERARCHY(&qHotel)", " AND Hotel = &qHotel"), "") + "
		|) AS RoomInventoryBalance
		|WHERE" + 
		?(vShowVacantRoomsOnly, " ISNULL(RoomInventoryBalance.RoomsVacantBalance, 0) > 0", " ISNULL(RoomInventoryBalance.TotalRoomsBalance, 0) > 0") + "
		|;
		|
		|SELECT  разрешенные
		|	ResDocuments.Recorder AS Accommodation,
		|	ResDocuments.Room AS Room,
		|	ResDocuments.RoomType AS RoomType,
		|	CASE
		|		WHEN ResDocuments.IsAccommodation THEN
		|			ResDocuments.AccommodationStatus 
		|		ELSE
		|			ResDocuments.ReservationStatus
		|	END AS Status,
		|	ResDocuments.PeriodFrom AS CheckInDate,
		|	ResDocuments.PeriodTo AS CheckOutDate,
		|	ResDocuments.AccommodationType AS AccommodationType,
		|	ResDocuments.RoomRate AS RoomRate
		|INTO ResDocuments
		|FROM
		|	AccumulationRegister.RoomInventory AS ResDocuments
		|   Внутреннее соединение ВТ_Номера Как ВТ_Номера
		|   по ResDocuments.Room = ВТ_Номера.Номер
		|WHERE
		|	ResDocuments.PeriodFrom < &qPeriodTo
		|	AND ResDocuments.PeriodTo > &qPeriodFrom " +  
		?(ValueIsFilled(SelHotel), ?(SelHotel.IsFolder, " AND ResDocuments.Hotel IN HIERARCHY(&qHotel)", " AND ResDocuments.Hotel = &qHotel"), "") + "
		|	AND ResDocuments.RecordType = &qExpense
		|	AND (ResDocuments.IsAccommodation OR ResDocuments.IsReservation) " + 
		?(Not IsBlankString(SelDocNumber), " AND ResDocuments.Recorder.Number = &qDocNumber", "") + 
		?(ValueIsFilled(SelCustomer), ?(SelCustomer.IsFolder, " AND ResDocuments.Customer IN HIERARCHY(&qCustomer)", " AND ResDocuments.Customer = &qCustomer"), "") + 
		?(ValueIsFilled(SelContract), " AND ResDocuments.Contract = &qContract", "") + 
		?(Not IsBlankString(SelRemarks), " AND (ResDocuments.Remarks LIKE &qRemarks OR ResDocuments.Car LIKE &qRemarks)", "") + 
		?(ValueIsFilled(SelGuest), " AND ResDocuments.Guest = &qGuest", 
		?(IsBlankString(SelGuestStr), "", " AND (ResDocuments.Guest.FullName LIKE &qGuestStr OR ResDocuments.Customer.Description LIKE &qGuestStr)")) + 
		?(ValueIsFilled(SelGuestGroup), " AND ResDocuments.GuestGroup = &qGuestGroup", "") + 
		?(SelShowExpectedChangeRoomOnly, " AND (ResDocuments.PeriodTo < ResDocuments.CheckOutDate AND ResDocuments.CheckOutAccountingDate = &qBegOfCurrentDate OR ResDocuments.PeriodFrom > ResDocuments.CheckInDate AND ResDocuments.CheckInAccountingDate = &qBegOfCurrentDate)", "") + 
		?(SelIntersection,
		?(ValueIsFilled(SelCheckInDate), " AND ResDocuments.PeriodTo > &qCheckInDate", "") + 
		?(ValueIsFilled(SelCheckOutDate), " AND ResDocuments.PeriodFrom < &qCheckOutDate", ""), 
		?(ValueIsFilled(SelCheckInDate), " AND ResDocuments.PeriodFrom >= &qBegOfCheckInDate AND ResDocuments.PeriodFrom < &qEndOfCheckInDate", "") + 
		?(ValueIsFilled(SelCheckOutDate), " AND ResDocuments.PeriodTo >= &qBegOfCheckOutDate AND ResDocuments.PeriodTo < &qEndOfCheckOutDate", "")) + "
		|GROUP BY
		|	ResDocuments.Recorder,
		|	ResDocuments.Room,
		|	ResDocuments.RoomType,
		|	CASE
		|		WHEN ResDocuments.IsAccommodation THEN
		|			ResDocuments.AccommodationStatus 
		|		ELSE
		|			ResDocuments.ReservationStatus
		|	END,
		|	ResDocuments.PeriodFrom,
		|	ResDocuments.PeriodTo,
		|	ResDocuments.AccommodationType,
		|	ResDocuments.RoomRate
		|;
		|
		|SELECT Разрешенные
		|	RoomInventoryBalance.Hotel,
		|	RoomInventoryBalance.Room,
		|	RoomInventoryBalance.RoomType,
		|	Documents.Accommodation AS Accommodation,
		|	Documents.Status AS Status,
		|	Documents.Accommodation.AccommodationTemplate AS AccommodationTemplate,
		|	Documents.Accommodation.ParentDoc AS ParentDoc,
		|	Documents.Accommodation.ClientType AS ClientType,
		|	Documents.Accommodation.Guest AS Guest,
		|	Documents.CheckInDate AS CheckInDate,
		|	Documents.CheckOutDate AS CheckOutDate,
		|	Documents.AccommodationType AS AccommodationType,
		|	Documents.RoomRate AS RoomRate,
		|	Documents.Accommodation.GuestGroup AS GuestGroup,
		|	Documents.Accommodation.HotelProduct AS HotelProduct,
		|	Documents.Accommodation.RoomQuota AS RoomQuota,
		|	Documents.Accommodation.Customer AS Customer,
		|	Documents.Accommodation.Contract AS Contract, 
		|	Documents.Accommodation.ContactPerson AS ContactPerson,
		|	Documents.Accommodation.Agent AS Agent, 
		|	Documents.Accommodation.PlannedPaymentMethod AS PlannedPaymentMethod, 
		|	Documents.Accommodation.NumberOfPersons AS NumberOfPersons, 
		|	MIN(RoomInventoryBalance.RoomsVacantBalance) AS RoomsVacantBalance
		|INTO Accommodations
		|FROM
		|	RoomInventoryBalance AS RoomInventoryBalance
		|		" + ?(IsBlankString(SelGuestStr), "LEFT", "INNER") + " JOIN ResDocuments AS Documents
		|		ON RoomInventoryBalance.Room = Documents.Room" + 
		?(SelShowExpectedChangeRoomOnly, "WHERE NOT (Documents.Accommodation IS NULL)", "") + " 
		|
		|GROUP BY
		|	RoomInventoryBalance.Hotel,
		|	RoomInventoryBalance.Room,
		|	RoomInventoryBalance.RoomType,
		|	Documents.Accommodation,
		|	Documents.Status,
		|	Documents.CheckInDate,
		|	Documents.CheckOutDate,
		|	Documents.AccommodationType,
		|	Documents.RoomRate
		|;
		|
		|SELECT
		|	Accommodations.Room.Owner AS Hotel,
		|	Accommodations.Room.Owner.SortCode AS HotelSortCode,
		|	Accommodations.Room AS Room,
		|	Accommodations.Room.SortCode AS RoomSortCode,
		|	Accommodations.Room AS RoomInDocument,
		|	ISNULL(Accommodations.Room.Description, """") AS RoomDescription,
		|	ISNULL(Accommodations.Room.IsFolder, FALSE) AS RoomIsFolder,
		|	Accommodations.Room.Parent AS RoomParent,
		|	Accommodations.Room.Parent.Description AS RoomParentDescription,
		|	Accommodations.Room.RoomStatus AS RoomRoomStatus,
		|	ISNULL(Accommodations.Room.StopSale, FALSE) AS RoomStopSale,
		|	Accommodations.Room.RoomPropertiesCodes AS RoomRoomPropertiesCodes,
		|	Accommodations.RoomType AS RoomType,
		|	Accommodations.RoomType.SortCode AS RoomTypeSortCode,
		|	Accommodations.RoomType.Code AS RoomTypeCode,
		|	Accommodations.RoomType.Description AS RoomTypeDescription,
		|	ISNULL(Accommodations.RoomType.IsFolder, FALSE) AS RoomTypeIsFolder,
		|	ISNULL(Accommodations.RoomType.StopSale, FALSE) AS RoomTypeStopSale,
		|	Accommodations.RoomType.Parent AS RoomTypeParent,
		|	Accommodations.Accommodation AS Accommodation,
		|	Accommodations.Accommodation.Number AS AccommodationNumber,
		|	Accommodations.Accommodation.PointInTime AS AccommodationPointInTime,
		|	Accommodations.ParentDoc AS ParentDoc,
		|	Accommodations.ParentDoc.Room AS ParentDocRoom,
		|	ISNULL(Accommodations.ParentDoc.ReservationStatus.IsCheckIn, FALSE) AS ParentDocReservationStatusIsCheckIn,
		|	Accommodations.Guest AS Guest,
		|	Accommodations.Guest.Description AS GuestDescription,
		|	Accommodations.Guest.FullName AS GuestFullName,
		|	Accommodations.Guest.Citizenship AS GuestCitizenship,
		|	Accommodations.Guest.Citizenship.ISOCode AS GuestCitizenshipISOCode,
		|	Accommodations.Guest.Sex AS GuestSex,
		|	Accommodations.Guest.DateOfBirth AS GuestDateOfBirth,
		|	Accommodations.CheckInDate AS CheckInDate,
		|	Accommodations.CheckOutDate AS CheckOutDate,
		|	Accommodations.AccommodationType AS AccommodationType,
		|	Accommodations.AccommodationType.Type AS AccommodationTypeType,
		|	Accommodations.RoomRate AS RoomRate,
		|	Accommodations.ClientType AS ClientType,
		|	Accommodations.ClientType.Color AS ClientTypeColor,
		|	Accommodations.AccommodationTemplate AS AccommodationTemplate,
		|	Accommodations.Status AS Status,
		|	Accommodations.Status.Color AS StatusColor,
		|	ISNULL(Accommodations.Status.IsInHouse, FALSE) AS StatusIsInHouse,
		|	ISNULL(Accommodations.Status.IsGuaranteed, FALSE) AS StatusIsGuaranteed,
		|	Accommodations.GuestGroup AS GuestGroup,
		|	Accommodations.GuestGroup.Code AS GuestGroupCode,
		|	Accommodations.GuestGroup.Description AS GuestGroupDescription,
		|	Accommodations.GuestGroup.Color AS GuestGroupColor,
		|	Accommodations.HotelProduct AS HotelProduct,
		|	Accommodations.HotelProduct.Description AS HotelProductDescription,
		|	Accommodations.HotelProduct.Parent AS HotelProductParent,
		|	Accommodations.HotelProduct.Parent.Description AS HotelProductParentDescription,
		|	Accommodations.RoomQuota AS RoomQuota,
		|	Accommodations.RoomQuota.Code AS RoomQuotaCode,
		|	Accommodations.RoomQuota.Color AS RoomQuotaColor,
		|	Accommodations.Customer AS Customer,
		|	Accommodations.Customer.Code AS CustomerCode,
		|	Accommodations.Customer.Color AS CustomerColor,
		|	ISNULL(Accommodations.Customer.IsIndividual, TRUE) AS CustomerIsIndividual,
		|	Accommodations.Contract AS Contract,
		|	Accommodations.Contract.Code AS ContractCode,
		|	Accommodations.Contract.Color AS ContractColor,
		|	Accommodations.ContactPerson AS ContactPerson,
		|	Accommodations.Agent AS Agent,
		|	Accommodations.Accommodation.Remarks AS Remarks,
		|	Accommodations.Accommodation.Car AS Car,
		|	Accommodations.Accommodation.IsMaster AS IsMaster,
		|	Accommodations.Accommodation.IsClosedForEdit AS IsClosedForEdit,
		|	Accommodations.PlannedPaymentMethod AS PlannedPaymentMethod,
		|	Accommodations.PlannedPaymentMethod.Code AS PlannedPaymentMethodCode,
		|	Accommodations.PlannedPaymentMethod.Description AS PlannedPaymentMethodDescription,
		|	Accommodations.PlannedPaymentMethod.IsByBankTransfer AS IsByBankTransfer,
		|	Accommodations.NumberOfPersons AS NumberOfPersons,
		|	Accommodations.Accommodation.ServicePackage AS ServicePackage,
		|	CAST(Accommodations.Accommodation.PricePresentation AS STRING(17)) AS PricePresentation,
		|	0 AS DurationInSeconds,
		|	0 AS OverbookingIndex,
		|	CASE
		|		WHEN Accommodations.Accommodation.AccommodationType.Type = &qAccomodationTypesRoom THEN 0
		|		WHEN Accommodations.Accommodation.AccommodationType.Type = &qAccomodationTypesBeds THEN 0
		|		WHEN Accommodations.Accommodation.AccommodationType.Type = &qAccomodationTypesAdditionalBed THEN 1
		|		ELSE 2
		|	END AS AccommodationTypeSortCode,
		|	CASE
		|		WHEN NOT Accommodations.Accommodation.NumberOfBeds IS NULL THEN Accommodations.Accommodation.NumberOfBeds
		|		WHEN NOT Accommodations.Accommodation.RoomBlockType IS NULL THEN Accommodations.Room.NumberOfBedsPerRoom
		|		ELSE 0
		|	END AS NumberOfBeds,
		|	Accommodations.RoomsVacantBalance AS RoomsVacantBalance,
		|	ISNULL(Accommodations.Accommodation.RoomQuantity, 1) AS RoomQuantity
		|
		|FROM Accommodations AS Accommodations
		|
		|ORDER BY
		|	HotelSortCode, " +
		?(SelShowRoomsByRoomTypes, "RoomTypeSortCode, RoomTypeDescription, ", "") + "
		|	RoomSortCode,
		|	CheckInDate,
		|	RoomQuotaCode,
		|	CustomerCode,
		|	ContractCode,
		|	GuestGroupCode,
		|	AccommodationTypeSortCode,
		|	AccommodationPointInTime
		|
		|TOTALS
		|BY
		|	Hotel ONLY HIERARCHY, " + 
		?(SelShowRoomsByRoomTypes, "RoomType HIERARCHY", "Room ONLY HIERARCHY");		
	КонецЕсли;	
	#КонецВставки
	
	#Удаление
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	RoomInventoryBalance.Hotel,
	|	RoomInventoryBalance.Room,
	|	RoomInventoryBalance.RoomType,
	|	ISNULL(RoomInventoryBalance.TotalRoomsBalance, 0) AS TotalRoomsBalance,
	|	ISNULL(RoomInventoryBalance.RoomsVacantBalance, 0) AS RoomsVacantBalance
	|INTO RoomInventoryBalance
	|FROM
	|	AccumulationRegister.RoomInventory.Balance(&qDate, TRUE" + 
	?(SelRoomTypes.Count() > 1, " AND RoomType IN HIERARCHY (&qRoomTypes)", ?(ValueIsFilled(SelRoomType), ?(SelRoomType.IsFolder, " AND RoomType IN HIERARCHY(&qRoomType)", " AND RoomType = &qRoomType"), "")) + 
	?(ValueIsFilled(SelRoom), ?(SelRoom.IsFolder, " AND Room IN HIERARCHY(&qRoom)", " AND Room = &qRoom"), "") + 
	?(ValueIsFilled(SelRoomSection), ?(SelRoomSection.IsFolder, " AND Room.RoomSection IN HIERARCHY(&qRoomSection)", " AND Room.RoomSection = &qRoomSection"), "") + 
	?(ValueIsFilled(SelHotel), ?(SelHotel.IsFolder, " AND Hotel IN HIERARCHY(&qHotel)", " AND Hotel = &qHotel"), "") + "
	|) AS RoomInventoryBalance
	|WHERE" + 
	?(vShowVacantRoomsOnly, " ISNULL(RoomInventoryBalance.RoomsVacantBalance, 0) > 0", " ISNULL(RoomInventoryBalance.TotalRoomsBalance, 0) > 0") + "
	|;
	|
	|SELECT
	|	ResDocuments.Recorder AS Accommodation,
	|	ResDocuments.Room AS Room,
	|	ResDocuments.RoomType AS RoomType,
	|	CASE
	|		WHEN ResDocuments.IsAccommodation THEN
	|			ResDocuments.AccommodationStatus 
	|		ELSE
	|			ResDocuments.ReservationStatus
	|	END AS Status,
	|	ResDocuments.PeriodFrom AS CheckInDate,
	|	ResDocuments.PeriodTo AS CheckOutDate,
	|	ResDocuments.AccommodationType AS AccommodationType,
	|	ResDocuments.RoomRate AS RoomRate
	|INTO ResDocuments
	|FROM
	|	AccumulationRegister.RoomInventory AS ResDocuments
	|WHERE
	|	ResDocuments.PeriodFrom < &qPeriodTo
	|	AND ResDocuments.PeriodTo > &qPeriodFrom " +  
	?(ValueIsFilled(SelHotel), ?(SelHotel.IsFolder, " AND ResDocuments.Hotel IN HIERARCHY(&qHotel)", " AND ResDocuments.Hotel = &qHotel"), "") + "
	|	AND ResDocuments.RecordType = &qExpense
	|	AND (ResDocuments.IsAccommodation OR ResDocuments.IsReservation) " + 
	?(Not IsBlankString(SelDocNumber), " AND ResDocuments.Recorder.Number = &qDocNumber", "") + 
	?(ValueIsFilled(SelCustomer), ?(SelCustomer.IsFolder, " AND ResDocuments.Customer IN HIERARCHY(&qCustomer)", " AND ResDocuments.Customer = &qCustomer"), "") + 
	?(ValueIsFilled(SelContract), " AND ResDocuments.Contract = &qContract", "") + 
	?(Not IsBlankString(SelRemarks), " AND (ResDocuments.Remarks LIKE &qRemarks OR ResDocuments.Car LIKE &qRemarks)", "") + 
	?(ValueIsFilled(SelGuest), " AND ResDocuments.Guest = &qGuest", 
	?(IsBlankString(SelGuestStr), "", " AND (ResDocuments.Guest.FullName LIKE &qGuestStr OR ResDocuments.Customer.Description LIKE &qGuestStr)")) + 
	?(ValueIsFilled(SelGuestGroup), " AND ResDocuments.GuestGroup = &qGuestGroup", "") + 
	?(SelShowExpectedChangeRoomOnly, " AND (ResDocuments.PeriodTo < ResDocuments.CheckOutDate AND ResDocuments.CheckOutAccountingDate = &qBegOfCurrentDate OR ResDocuments.PeriodFrom > ResDocuments.CheckInDate AND ResDocuments.CheckInAccountingDate = &qBegOfCurrentDate)", "") + 
	?(SelIntersection,
	?(ValueIsFilled(SelCheckInDate), " AND ResDocuments.PeriodTo > &qCheckInDate", "") + 
	?(ValueIsFilled(SelCheckOutDate), " AND ResDocuments.PeriodFrom < &qCheckOutDate", ""), 
	?(ValueIsFilled(SelCheckInDate), " AND ResDocuments.PeriodFrom >= &qBegOfCheckInDate AND ResDocuments.PeriodFrom < &qEndOfCheckInDate", "") + 
	?(ValueIsFilled(SelCheckOutDate), " AND ResDocuments.PeriodTo >= &qBegOfCheckOutDate AND ResDocuments.PeriodTo < &qEndOfCheckOutDate", "")) + "
	|GROUP BY
	|	ResDocuments.Recorder,
	|	ResDocuments.Room,
	|	ResDocuments.RoomType,
	|	CASE
	|		WHEN ResDocuments.IsAccommodation THEN
	|			ResDocuments.AccommodationStatus 
	|		ELSE
	|			ResDocuments.ReservationStatus
	|	END,
	|	ResDocuments.PeriodFrom,
	|	ResDocuments.PeriodTo,
	|	ResDocuments.AccommodationType,
	|	ResDocuments.RoomRate
	|;
	|
	|SELECT
	|	RoomInventoryBalance.Hotel,
	|	RoomInventoryBalance.Room,
	|	RoomInventoryBalance.RoomType,
	|	Documents.Accommodation AS Accommodation,
	|	Documents.Status AS Status,
	|	Documents.Accommodation.AccommodationTemplate AS AccommodationTemplate,
	|	Documents.Accommodation.ParentDoc AS ParentDoc,
	|	Documents.Accommodation.ClientType AS ClientType,
	|	Documents.Accommodation.Guest AS Guest,
	|	Documents.CheckInDate AS CheckInDate,
	|	Documents.CheckOutDate AS CheckOutDate,
	|	Documents.AccommodationType AS AccommodationType,
	|	Documents.RoomRate AS RoomRate,
	|	Documents.Accommodation.GuestGroup AS GuestGroup,
	|	Documents.Accommodation.HotelProduct AS HotelProduct,
	|	Documents.Accommodation.RoomQuota AS RoomQuota,
	|	Documents.Accommodation.Customer AS Customer,
	|	Documents.Accommodation.Contract AS Contract, 
	|	Documents.Accommodation.ContactPerson AS ContactPerson,
	|	Documents.Accommodation.Agent AS Agent, 
	|	Documents.Accommodation.PlannedPaymentMethod AS PlannedPaymentMethod, 
	|	Documents.Accommodation.NumberOfPersons AS NumberOfPersons, 
	|	MIN(RoomInventoryBalance.RoomsVacantBalance) AS RoomsVacantBalance
	|INTO Accommodations
	|FROM
	|	RoomInventoryBalance AS RoomInventoryBalance
	|		" + ?(IsBlankString(SelGuestStr), "LEFT", "INNER") + " JOIN ResDocuments AS Documents
	|		ON RoomInventoryBalance.Room = Documents.Room" + 
	?(SelShowExpectedChangeRoomOnly, "WHERE NOT (Documents.Accommodation IS NULL)", "") + " 
	|
	|GROUP BY
	|	RoomInventoryBalance.Hotel,
	|	RoomInventoryBalance.Room,
	|	RoomInventoryBalance.RoomType,
	|	Documents.Accommodation,
	|	Documents.Status,
	|	Documents.CheckInDate,
	|	Documents.CheckOutDate,
	|	Documents.AccommodationType,
	|	Documents.RoomRate
	|;
	|
	|SELECT
	|	Accommodations.Room.Owner AS Hotel,
	|	Accommodations.Room.Owner.SortCode AS HotelSortCode,
	|	Accommodations.Room AS Room,
	|	Accommodations.Room.SortCode AS RoomSortCode,
	|	Accommodations.Room AS RoomInDocument,
	|	ISNULL(Accommodations.Room.Description, """") AS RoomDescription,
	|	ISNULL(Accommodations.Room.IsFolder, FALSE) AS RoomIsFolder,
	|	Accommodations.Room.Parent AS RoomParent,
	|	Accommodations.Room.Parent.Description AS RoomParentDescription,
	|	Accommodations.Room.RoomStatus AS RoomRoomStatus,
	|	ISNULL(Accommodations.Room.StopSale, FALSE) AS RoomStopSale,
	|	Accommodations.Room.RoomPropertiesCodes AS RoomRoomPropertiesCodes,
	|	Accommodations.RoomType AS RoomType,
	|	Accommodations.RoomType.SortCode AS RoomTypeSortCode,
	|	Accommodations.RoomType.Code AS RoomTypeCode,
	|	Accommodations.RoomType.Description AS RoomTypeDescription,
	|	ISNULL(Accommodations.RoomType.IsFolder, FALSE) AS RoomTypeIsFolder,
	|	ISNULL(Accommodations.RoomType.StopSale, FALSE) AS RoomTypeStopSale,
	|	Accommodations.RoomType.Parent AS RoomTypeParent,
	|	Accommodations.Accommodation AS Accommodation,
	|	Accommodations.Accommodation.Number AS AccommodationNumber,
	|	Accommodations.Accommodation.PointInTime AS AccommodationPointInTime,
	|	Accommodations.ParentDoc AS ParentDoc,
	|	Accommodations.ParentDoc.Room AS ParentDocRoom,
	|	ISNULL(Accommodations.ParentDoc.ReservationStatus.IsCheckIn, FALSE) AS ParentDocReservationStatusIsCheckIn,
	|	Accommodations.Guest AS Guest,
	|	Accommodations.Guest.Description AS GuestDescription,
	|	Accommodations.Guest.FullName AS GuestFullName,
	|	Accommodations.Guest.Citizenship AS GuestCitizenship,
	|	Accommodations.Guest.Citizenship.ISOCode AS GuestCitizenshipISOCode,
	|	Accommodations.Guest.Sex AS GuestSex,
	|	Accommodations.Guest.DateOfBirth AS GuestDateOfBirth,
	|	Accommodations.CheckInDate AS CheckInDate,
	|	Accommodations.CheckOutDate AS CheckOutDate,
	|	Accommodations.AccommodationType AS AccommodationType,
	|	Accommodations.AccommodationType.Type AS AccommodationTypeType,
	|	Accommodations.RoomRate AS RoomRate,
	|	Accommodations.ClientType AS ClientType,
	|	Accommodations.ClientType.Color AS ClientTypeColor,
	|	Accommodations.AccommodationTemplate AS AccommodationTemplate,
	|	Accommodations.Status AS Status,
	|	Accommodations.Status.Color AS StatusColor,
	|	ISNULL(Accommodations.Status.IsInHouse, FALSE) AS StatusIsInHouse,
	|	ISNULL(Accommodations.Status.IsGuaranteed, FALSE) AS StatusIsGuaranteed,
	|	Accommodations.GuestGroup AS GuestGroup,
	|	Accommodations.GuestGroup.Code AS GuestGroupCode,
	|	Accommodations.GuestGroup.Description AS GuestGroupDescription,
	|	Accommodations.GuestGroup.Color AS GuestGroupColor,
	|	Accommodations.HotelProduct AS HotelProduct,
	|	Accommodations.HotelProduct.Description AS HotelProductDescription,
	|	Accommodations.HotelProduct.Parent AS HotelProductParent,
	|	Accommodations.HotelProduct.Parent.Description AS HotelProductParentDescription,
	|	Accommodations.RoomQuota AS RoomQuota,
	|	Accommodations.RoomQuota.Code AS RoomQuotaCode,
	|	Accommodations.RoomQuota.Color AS RoomQuotaColor,
	|	Accommodations.Customer AS Customer,
	|	Accommodations.Customer.Code AS CustomerCode,
	|	Accommodations.Customer.Color AS CustomerColor,
	|	ISNULL(Accommodations.Customer.IsIndividual, TRUE) AS CustomerIsIndividual,
	|	Accommodations.Contract AS Contract,
	|	Accommodations.Contract.Code AS ContractCode,
	|	Accommodations.Contract.Color AS ContractColor,
	|	Accommodations.ContactPerson AS ContactPerson,
	|	Accommodations.Agent AS Agent,
	|	Accommodations.Accommodation.Remarks AS Remarks,
	|	Accommodations.Accommodation.Car AS Car,
	|	Accommodations.Accommodation.IsMaster AS IsMaster,
	|	Accommodations.Accommodation.IsClosedForEdit AS IsClosedForEdit,
	|	Accommodations.PlannedPaymentMethod AS PlannedPaymentMethod,
	|	Accommodations.PlannedPaymentMethod.Code AS PlannedPaymentMethodCode,
	|	Accommodations.PlannedPaymentMethod.Description AS PlannedPaymentMethodDescription,
	|	Accommodations.PlannedPaymentMethod.IsByBankTransfer AS IsByBankTransfer,
	|	Accommodations.NumberOfPersons AS NumberOfPersons,
	|	Accommodations.Accommodation.ServicePackage AS ServicePackage,
	|	CAST(Accommodations.Accommodation.PricePresentation AS STRING(17)) AS PricePresentation,
	|	0 AS DurationInSeconds,
	|	0 AS OverbookingIndex,
	|	CASE
	|		WHEN Accommodations.Accommodation.AccommodationType.Type = &qAccomodationTypesRoom THEN 0
	|		WHEN Accommodations.Accommodation.AccommodationType.Type = &qAccomodationTypesBeds THEN 0
	|		WHEN Accommodations.Accommodation.AccommodationType.Type = &qAccomodationTypesAdditionalBed THEN 1
	|		ELSE 2
	|	END AS AccommodationTypeSortCode,
	|	CASE
	|		WHEN NOT Accommodations.Accommodation.NumberOfBeds IS NULL THEN Accommodations.Accommodation.NumberOfBeds
	|		WHEN NOT Accommodations.Accommodation.RoomBlockType IS NULL THEN Accommodations.Room.NumberOfBedsPerRoom
	|		ELSE 0
	|	END AS NumberOfBeds,
	|	Accommodations.RoomsVacantBalance AS RoomsVacantBalance,
	|	ISNULL(Accommodations.Accommodation.RoomQuantity, 1) AS RoomQuantity
	|
	|FROM Accommodations AS Accommodations
	|
	|ORDER BY
	|	HotelSortCode, " +
	?(SelShowRoomsByRoomTypes, "RoomTypeSortCode, RoomTypeDescription, ", "") + "
	|	RoomSortCode,
	|	CheckInDate,
	|	RoomQuotaCode,
	|	CustomerCode,
	|	ContractCode,
	|	GuestGroupCode,
	|	AccommodationTypeSortCode,
	|	AccommodationPointInTime
	|
	|TOTALS
	|BY
	|	Hotel ONLY HIERARCHY, " + 
	?(SelShowRoomsByRoomTypes, "RoomType HIERARCHY", "Room ONLY HIERARCHY");
	#КонецУдаления
	
	If ValueIsFilled(SelPeriodDateFrom) Then
		vQry.SetParameter("qDate", EndOfDay(SelPeriodDateFrom));
	Else
		vQry.SetParameter("qDate", ?(BegOfDay(SelPeriodFrom) = BegOfDay(CurrentSessionDate() - 1*24*3600), EndOfDay(SelPeriodFrom) + 1*24*3600, EndOfDay(SelPeriodFrom)));
	EndIf;
	vQry.SetParameter("qHotel", SessionParameters.CurrentHotel);
	vQry.SetParameter("qRoomType", SelRoomType);
	vQry.SetParameter("qRoomTypes", SelRoomTypes);
	vQry.SetParameter("qRoom", SelRoom);
	vQry.SetParameter("qRoomSection", SelRoomSection);
	vQry.SetParameter("qDocNumber", "");
	vQry.SetParameter("qCustomer", Catalogs.Customers.EmptyRef());
	vQry.SetParameter("qContract", Catalogs.Contracts.EmptyRef());
	vQry.SetParameter("qRemarks", "");
	vQry.SetParameter("qGuest", Catalogs.Clients.EmptyRef());
	vQry.SetParameter("qGuestStr", "%"+TrimR(SelGuestStr)+"%");
	vQry.SetParameter("qGuestGroup", Catalogs.GuestGroups.EmptyRef());
	vQry.SetParameter("qPeriodFrom", pPeriodFrom);
	vQry.SetParameter("qPeriodTo", pPeriodTo);
	vQry.SetParameter("qCheckInDate", SelCheckInDate);
	vQry.SetParameter("qBegOfCheckInDate", ?(ValueIsFilled(SelCheckInDate), BegOfDay(SelCheckInDate), '00010101'));
	vQry.SetParameter("qEndOfCheckInDate", ?(ValueIsFilled(SelCheckInDate), BegOfDay(SelCheckInDate) + 3600 * 24, '00010101'));
	vQry.SetParameter("qCheckOutDate", SelCheckOutDate);
	vQry.SetParameter("qBegOfCheckOutDate", ?(ValueIsFilled(SelCheckOutDate), BegOfDay(SelCheckOutDate), '00010101'));
	vQry.SetParameter("qEndOfCheckOutDate", ?(ValueIsFilled(SelCheckOutDate), BegOfDay(SelCheckOutDate) + 3600 * 24, '00010101'));
	vQry.SetParameter("qExpense", AccumulationRecordType.Expense);
	vQry.SetParameter("qAccomodationTypesRoom", Enums.AccomodationTypes.Room);
	vQry.SetParameter("qAccomodationTypesBeds", Enums.AccomodationTypes.Beds);
	vQry.SetParameter("qAccomodationTypesAdditionalBed", Enums.AccomodationTypes.AdditionalBed);
	vQry.SetParameter("qBegOfCurrentDate", BegOfDay(CurrentSessionDate()));
	vQryRes = vQry.Execute().Unload();
	Return vQryRes;
EndFunction


&AtServer
&ChangeAndValidate("GetBookingsWithoutRooms")
Function Расш1_GetBookingsWithoutRooms(pPeriodFrom, pPeriodTo, pShowTodaysBookingsOnly)
	// Build and run query
	#Вставка
	Если  НомернойФонд.Пустая() Тогда
		vQry = New Query();
		vQry.Text = 
		"SELECT Разрешенные
		|	DocumentPeriods.Hotel AS Hotel,
		|	DocumentPeriods.Hotel.SortCode AS HotelSortCode,
		|	DocumentPeriods.Room AS Room,
		|	DocumentPeriods.Room.SortCode AS RoomSortCode,
		|	ISNULL(DocumentPeriods.Room.IsFolder, FALSE) AS RoomIsFolder,
		|	ISNULL(DocumentPeriods.Room.Description, """") AS RoomDescription,
		|	DocumentPeriods.Room.Parent AS RoomParent,
		|	DocumentPeriods.Room.Parent.Description AS RoomParentDescription,
		|	DocumentPeriods.Room.RoomStatus AS RoomRoomStatus,
		|	ISNULL(DocumentPeriods.Room.StopSale, FALSE) AS RoomStopSale,
		|	DocumentPeriods.RoomType AS RoomType,
		|	DocumentPeriods.RoomType.SortCode AS RoomTypeSortCode,
		|	DocumentPeriods.RoomType.Code AS RoomTypeCode,
		|	DocumentPeriods.RoomType.Description AS RoomTypeDescription,
		|	ISNULL(DocumentPeriods.RoomType.IsFolder, FALSE) AS RoomTypeIsFolder,
		|	ISNULL(DocumentPeriods.RoomType.StopSale, FALSE) AS RoomTypeStopSale,
		|	DocumentPeriods.RoomType.Parent AS RoomTypeParent,
		|	DocumentPeriods.Recorder AS Accommodation,
		|	DocumentPeriods.Recorder.Number AS AccommodationNumber,
		|	DocumentPeriods.Recorder.PointInTime AS AccommodationPointInTime,
		|	DocumentPeriods.ParentDoc AS ParentDoc,
		|	DocumentPeriods.ParentDoc.Room AS ParentDocRoom,
		|	ISNULL(DocumentPeriods.ParentDoc.ReservationStatus.IsCheckIn, FALSE) AS ParentDocReservationStatusIsCheckIn,
		|	DocumentPeriods.Guest AS Guest,
		|	DocumentPeriods.Guest.Description AS GuestDescription,
		|	DocumentPeriods.Guest.FullName AS GuestFullName,
		|	DocumentPeriods.Guest.Citizenship AS GuestCitizenship,
		|	DocumentPeriods.Guest.Citizenship.ISOCode AS GuestCitizenshipISOCode,
		|	DocumentPeriods.Guest.DateOfBirth AS GuestDateOfBirth,
		|	DocumentPeriods.Guest.Sex AS GuestSex,
		|	DocumentPeriods.CheckInDate AS CheckInDate,
		|	DocumentPeriods.CheckOutDate AS CheckOutDate,
		|	DocumentPeriods.AccommodationType AS AccommodationType,
		|	DocumentPeriods.AccommodationType.Type AS AccommodationTypeType,
		|	DocumentPeriods.RoomRate AS RoomRate,
		|	DocumentPeriods.ClientType AS ClientType,
		|	DocumentPeriods.ClientType.Color AS ClientTypeColor,
		|	DocumentPeriods.ReservationStatus AS Status,
		|	DocumentPeriods.ReservationStatus.Color AS StatusColor,
		|	FALSE AS StatusIsInHouse,
		|	DocumentPeriods.ReservationStatus.IsGuaranteed AS StatusIsGuaranteed,
		|	DocumentPeriods.GuestGroup AS GuestGroup,
		|	DocumentPeriods.GuestGroup.Code AS GuestGroupCode,
		|	DocumentPeriods.GuestGroup.Description AS GuestGroupDescription,
		|	DocumentPeriods.GuestGroup.Color AS GuestGroupColor,
		|	DocumentPeriods.HotelProduct AS HotelProduct,
		|	DocumentPeriods.HotelProduct.Description AS HotelProductDescription,
		|	DocumentPeriods.HotelProduct.Parent AS HotelProductParent,
		|	DocumentPeriods.HotelProduct.Parent.Description AS HotelProductParentDescription,
		|	DocumentPeriods.RoomQuota AS RoomQuota,
		|	DocumentPeriods.RoomQuota.Code AS RoomQuotaCode,
		|	DocumentPeriods.RoomQuota.Color AS RoomQuotaColor,
		|	DocumentPeriods.Customer AS Customer,
		|	DocumentPeriods.Customer.Code AS CustomerCode,
		|	DocumentPeriods.Customer.Color AS CustomerColor,
		|	ISNULL(DocumentPeriods.Customer.IsIndividual, TRUE) AS CustomerIsIndividual,
		|	DocumentPeriods.Contract AS Contract,
		|	DocumentPeriods.Contract.Code AS ContractCode,
		|	DocumentPeriods.Contract.Color AS ContractColor,
		|	DocumentPeriods.ContactPerson AS ContactPerson,
		|	DocumentPeriods.Recorder.Remarks AS Remarks,
		|	DocumentPeriods.Recorder.Car AS Car,
		|	DocumentPeriods.IsMaster AS IsMaster,
		|	DocumentPeriods.IsClosedForEdit AS IsClosedForEdit,
		|	DocumentPeriods.PlannedPaymentMethod AS PlannedPaymentMethod,
		|	DocumentPeriods.PlannedPaymentMethod.Code AS PlannedPaymentMethodCode,
		|	DocumentPeriods.PlannedPaymentMethod.Description AS PlannedPaymentMethodDescription,
		|	DocumentPeriods.PlannedPaymentMethod.IsByBankTransfer AS IsByBankTransfer,
		|	DocumentPeriods.NumberOfPersons AS NumberOfPersons,
		|	DocumentPeriods.Recorder.ServicePackage AS ServicePackage,
		|	CAST(DocumentPeriods.Recorder.PricePresentation AS STRING(17)) AS PricePresentation,
		|	DATEDIFF(DocumentPeriods.DocCheckInDate, DocumentPeriods.DocCheckOutDate, SECOND) AS DurationInSeconds,
		|	CASE
		|		WHEN DocumentPeriods.AccommodationType.Type = &qAccomodationTypesRoom
		|			THEN 0
		|		WHEN DocumentPeriods.AccommodationType.Type = &qAccomodationTypesBeds
		|			THEN 0
		|		WHEN DocumentPeriods.AccommodationType.Type = &qAccomodationTypesAdditionalBed
		|			THEN 1
		|		ELSE 2
		|	END AS AccommodationTypeSortCode,
		|	DocumentPeriods.RoomsReserved AS RoomsReserved,
		|	DocumentPeriods.BedsReserved AS BedsReserved,
		|	DocumentPeriods.GuestsReserved AS GuestsReserved,
		|	DocumentPeriods.BedsReserved AS NumberOfBeds,
		|	ISNULL(DocumentPeriods.Recorder.RoomQuantity, 1) AS RoomQuantity
		|FROM
		|	(SELECT
		|		Reservations.Hotel AS Hotel,
		|		Reservations.Room AS Room,
		|		Reservations.RoomType AS RoomType,
		|		Reservations.Recorder AS Recorder,
		|		Reservations.ParentDoc AS ParentDoc,
		|		Reservations.Guest AS Guest,
		|		Reservations.PeriodFrom AS CheckInDate,
		|		Reservations.PeriodTo AS CheckOutDate,
		|		Reservations.AccommodationType AS AccommodationType,
		|		Reservations.RoomRate AS RoomRate,
		|		Reservations.ClientType AS ClientType,
		|		Reservations.ReservationStatus AS ReservationStatus,
		|		Reservations.GuestGroup AS GuestGroup,
		|		Reservations.HotelProduct AS HotelProduct,
		|		Reservations.RoomQuota AS RoomQuota,
		|		Reservations.Customer AS Customer,
		|		Reservations.Contract AS Contract,
		|		Reservations.ContactPerson AS ContactPerson,
		|		Reservations.IsMaster AS IsMaster,
		|		ISNULL(Reservations.Recorder.IsClosedForEdit, FALSE) AS IsClosedForEdit,
		|		Reservations.PlannedPaymentMethod AS PlannedPaymentMethod,
		|		Reservations.NumberOfPersons AS NumberOfPersons,
		|		Reservations.CheckInDate AS DocCheckInDate,
		|		Reservations.CheckOutDate AS DocCheckOutDate,
		|		MAX(Reservations.RoomsReserved) AS RoomsReserved,
		|		MAX(Reservations.BedsReserved) AS BedsReserved,
		|		MAX(Reservations.GuestsReserved) AS GuestsReserved,
		|		MAX(Reservations.BedsReserved) AS NumberOfBeds
		|	FROM
		|		AccumulationRegister.RoomInventory AS Reservations
		|	WHERE
		|		Reservations.RecordType = &qExpense
		|		AND Reservations.IsReservation
		|		AND (Reservations.PeriodFrom < &qPeriodTo
		|					AND Reservations.PeriodTo > &qPeriodFrom
		|					AND NOT &qShowTodaysBookingsOnly
		|				OR Reservations.PeriodFrom < &qPeriodTo
		|					AND Reservations.PeriodFrom >= &qPeriodFrom
		|					AND &qShowTodaysBookingsOnly)
		|		AND Reservations.Room = &qEmptyRoom " + 
		?(ValueIsFilled(SelHotel), ?(SelHotel.IsFolder, " AND Reservations.Hotel IN HIERARCHY(&qHotel)", " AND Reservations.Hotel = &qHotel"), "") + 
		?(SelRoomTypes.Count() > 1, " AND Reservations.RoomType IN HIERARCHY (&qRoomTypes)", ?(ValueIsFilled(SelRoomType), ?(SelRoomType.IsFolder, " AND Reservations.RoomType IN HIERARCHY(&qRoomType)", " AND Reservations.RoomType = &qRoomType"), "")) + 
		?(Not IsBlankString(SelDocNumber), " AND Reservations.Recorder.Number = &qDocNumber", "") + 
		?(ValueIsFilled(SelCustomer), ?(SelCustomer.IsFolder, " AND Reservations.Customer IN HIERARCHY(&qCustomer)", " AND Reservations.Customer = &qCustomer"), "") + 
		?(ValueIsFilled(SelContract), " AND Reservations.Contract = &qContract", "") + 
		?(Not IsBlankString(SelRemarks), " AND (Reservations.Remarks LIKE &qRemarks OR Reservations.Car LIKE &qRemarks)", "") + 
		?(ValueIsFilled(SelGuest), " AND Reservations.Guest = &qGuest", 
		?(IsBlankString(SelGuestStr), "", " AND (Reservations.Guest.FullName LIKE &qGuestStr OR Reservations.Customer.Description LIKE &qGuestStr)")) + 
		?(ValueIsFilled(SelGuestGroup), " AND Reservations.GuestGroup = &qGuestGroup", "") + 
		?(SelShowExpectedChangeRoomOnly, " AND FALSE", "") + 
		?(SelIntersection, 
		?(ValueIsFilled(SelCheckInDate), " AND Reservations.PeriodTo > &qCheckInDate", "") + 
		?(ValueIsFilled(SelCheckOutDate), " AND Reservations.PeriodFrom < &qCheckOutDate", ""), 
		?(ValueIsFilled(SelCheckInDate), " AND Reservations.PeriodFrom >= &qBegOfCheckInDate AND Reservations.PeriodFrom < &qEndOfCheckInDate", "") + 
		?(ValueIsFilled(SelCheckOutDate), " AND Reservations.PeriodTo >= &qBegOfCheckOutDate AND Reservations.PeriodTo < &qEndOfCheckOutDate", "")) + "
		|	
		|	GROUP BY
		|		Reservations.Hotel,
		|		Reservations.Room,
		|		Reservations.RoomType,
		|		Reservations.Recorder,
		|		Reservations.ParentDoc,
		|		Reservations.Guest,
		|		Reservations.PeriodFrom,
		|		Reservations.PeriodTo,
		|		Reservations.AccommodationType,
		|		Reservations.RoomRate,
		|		Reservations.ClientType,
		|		Reservations.ReservationStatus,
		|		Reservations.GuestGroup,
		|		Reservations.HotelProduct,
		|		Reservations.RoomQuota,
		|		Reservations.Customer,
		|		Reservations.Contract,
		|		Reservations.ContactPerson,
		|		Reservations.Car,
		|		Reservations.IsMaster,
		|		ISNULL(Reservations.Recorder.IsClosedForEdit, FALSE),
		|		Reservations.PlannedPaymentMethod,
		|		Reservations.NumberOfPersons,
		|		Reservations.CheckInDate,
		|		Reservations.CheckOutDate) AS DocumentPeriods
		|
		|ORDER BY
		|	HotelSortCode,
		|	RoomTypeSortCode,
		|	CheckInDate,
		|	DurationInSeconds DESC,
		|	RoomQuotaCode,
		|	CustomerCode,
		|	ContractCode,
		|	GuestGroupCode,
		|	AccommodationTypeSortCode,
		|	AccommodationPointInTime";	
	Иначе
		vQry = New Query();
		vQry.Text = 
		"SELECT Разрешенные
		|	DocumentPeriods.Hotel AS Hotel,
		|	DocumentPeriods.Hotel.SortCode AS HotelSortCode,
		|	DocumentPeriods.Room AS Room,
		|	DocumentPeriods.Room.SortCode AS RoomSortCode,
		|	ISNULL(DocumentPeriods.Room.IsFolder, FALSE) AS RoomIsFolder,
		|	ISNULL(DocumentPeriods.Room.Description, """") AS RoomDescription,
		|	DocumentPeriods.Room.Parent AS RoomParent,
		|	DocumentPeriods.Room.Parent.Description AS RoomParentDescription,
		|	DocumentPeriods.Room.RoomStatus AS RoomRoomStatus,
		|	ISNULL(DocumentPeriods.Room.StopSale, FALSE) AS RoomStopSale,
		|	DocumentPeriods.RoomType AS RoomType,
		|	DocumentPeriods.RoomType.SortCode AS RoomTypeSortCode,
		|	DocumentPeriods.RoomType.Code AS RoomTypeCode,
		|	DocumentPeriods.RoomType.Description AS RoomTypeDescription,
		|	ISNULL(DocumentPeriods.RoomType.IsFolder, FALSE) AS RoomTypeIsFolder,
		|	ISNULL(DocumentPeriods.RoomType.StopSale, FALSE) AS RoomTypeStopSale,
		|	DocumentPeriods.RoomType.Parent AS RoomTypeParent,
		|	DocumentPeriods.Recorder AS Accommodation,
		|	DocumentPeriods.Recorder.Number AS AccommodationNumber,
		|	DocumentPeriods.Recorder.PointInTime AS AccommodationPointInTime,
		|	DocumentPeriods.ParentDoc AS ParentDoc,
		|	DocumentPeriods.ParentDoc.Room AS ParentDocRoom,
		|	ISNULL(DocumentPeriods.ParentDoc.ReservationStatus.IsCheckIn, FALSE) AS ParentDocReservationStatusIsCheckIn,
		|	DocumentPeriods.Guest AS Guest,
		|	DocumentPeriods.Guest.Description AS GuestDescription,
		|	DocumentPeriods.Guest.FullName AS GuestFullName,
		|	DocumentPeriods.Guest.Citizenship AS GuestCitizenship,
		|	DocumentPeriods.Guest.Citizenship.ISOCode AS GuestCitizenshipISOCode,
		|	DocumentPeriods.Guest.DateOfBirth AS GuestDateOfBirth,
		|	DocumentPeriods.Guest.Sex AS GuestSex,
		|	DocumentPeriods.CheckInDate AS CheckInDate,
		|	DocumentPeriods.CheckOutDate AS CheckOutDate,
		|	DocumentPeriods.AccommodationType AS AccommodationType,
		|	DocumentPeriods.AccommodationType.Type AS AccommodationTypeType,
		|	DocumentPeriods.RoomRate AS RoomRate,
		|	DocumentPeriods.ClientType AS ClientType,
		|	DocumentPeriods.ClientType.Color AS ClientTypeColor,
		|	DocumentPeriods.ReservationStatus AS Status,
		|	DocumentPeriods.ReservationStatus.Color AS StatusColor,
		|	FALSE AS StatusIsInHouse,
		|	DocumentPeriods.ReservationStatus.IsGuaranteed AS StatusIsGuaranteed,
		|	DocumentPeriods.GuestGroup AS GuestGroup,
		|	DocumentPeriods.GuestGroup.Code AS GuestGroupCode,
		|	DocumentPeriods.GuestGroup.Description AS GuestGroupDescription,
		|	DocumentPeriods.GuestGroup.Color AS GuestGroupColor,
		|	DocumentPeriods.HotelProduct AS HotelProduct,
		|	DocumentPeriods.HotelProduct.Description AS HotelProductDescription,
		|	DocumentPeriods.HotelProduct.Parent AS HotelProductParent,
		|	DocumentPeriods.HotelProduct.Parent.Description AS HotelProductParentDescription,
		|	DocumentPeriods.RoomQuota AS RoomQuota,
		|	DocumentPeriods.RoomQuota.Code AS RoomQuotaCode,
		|	DocumentPeriods.RoomQuota.Color AS RoomQuotaColor,
		|	DocumentPeriods.Customer AS Customer,
		|	DocumentPeriods.Customer.Code AS CustomerCode,
		|	DocumentPeriods.Customer.Color AS CustomerColor,
		|	ISNULL(DocumentPeriods.Customer.IsIndividual, TRUE) AS CustomerIsIndividual,
		|	DocumentPeriods.Contract AS Contract,
		|	DocumentPeriods.Contract.Code AS ContractCode,
		|	DocumentPeriods.Contract.Color AS ContractColor,
		|	DocumentPeriods.ContactPerson AS ContactPerson,
		|	DocumentPeriods.Recorder.Remarks AS Remarks,
		|	DocumentPeriods.Recorder.Car AS Car,
		|	DocumentPeriods.IsMaster AS IsMaster,
		|	DocumentPeriods.IsClosedForEdit AS IsClosedForEdit,
		|	DocumentPeriods.PlannedPaymentMethod AS PlannedPaymentMethod,
		|	DocumentPeriods.PlannedPaymentMethod.Code AS PlannedPaymentMethodCode,
		|	DocumentPeriods.PlannedPaymentMethod.Description AS PlannedPaymentMethodDescription,
		|	DocumentPeriods.PlannedPaymentMethod.IsByBankTransfer AS IsByBankTransfer,
		|	DocumentPeriods.NumberOfPersons AS NumberOfPersons,
		|	DocumentPeriods.Recorder.ServicePackage AS ServicePackage,
		|	CAST(DocumentPeriods.Recorder.PricePresentation AS STRING(17)) AS PricePresentation,
		|	DATEDIFF(DocumentPeriods.DocCheckInDate, DocumentPeriods.DocCheckOutDate, SECOND) AS DurationInSeconds,
		|	CASE
		|		WHEN DocumentPeriods.AccommodationType.Type = &qAccomodationTypesRoom
		|			THEN 0
		|		WHEN DocumentPeriods.AccommodationType.Type = &qAccomodationTypesBeds
		|			THEN 0
		|		WHEN DocumentPeriods.AccommodationType.Type = &qAccomodationTypesAdditionalBed
		|			THEN 1
		|		ELSE 2
		|	END AS AccommodationTypeSortCode,
		|	DocumentPeriods.RoomsReserved AS RoomsReserved,
		|	DocumentPeriods.BedsReserved AS BedsReserved,
		|	DocumentPeriods.GuestsReserved AS GuestsReserved,
		|	DocumentPeriods.BedsReserved AS NumberOfBeds,
		|	ISNULL(DocumentPeriods.Recorder.RoomQuantity, 1) AS RoomQuantity
		|FROM
		|	(SELECT
		|		Reservations.Hotel AS Hotel,
		|		Reservations.Room AS Room,
		|		Reservations.RoomType AS RoomType,
		|		Reservations.Recorder AS Recorder,
		|		Reservations.ParentDoc AS ParentDoc,
		|		Reservations.Guest AS Guest,
		|		Reservations.PeriodFrom AS CheckInDate,
		|		Reservations.PeriodTo AS CheckOutDate,
		|		Reservations.AccommodationType AS AccommodationType,
		|		Reservations.RoomRate AS RoomRate,
		|		Reservations.ClientType AS ClientType,
		|		Reservations.ReservationStatus AS ReservationStatus,
		|		Reservations.GuestGroup AS GuestGroup,
		|		Reservations.HotelProduct AS HotelProduct,
		|		Reservations.RoomQuota AS RoomQuota,
		|		Reservations.Customer AS Customer,
		|		Reservations.Contract AS Contract,
		|		Reservations.ContactPerson AS ContactPerson,
		|		Reservations.IsMaster AS IsMaster,
		|		ISNULL(Reservations.Recorder.IsClosedForEdit, FALSE) AS IsClosedForEdit,
		|		Reservations.PlannedPaymentMethod AS PlannedPaymentMethod,
		|		Reservations.NumberOfPersons AS NumberOfPersons,
		|		Reservations.CheckInDate AS DocCheckInDate,
		|		Reservations.CheckOutDate AS DocCheckOutDate,
		|		MAX(Reservations.RoomsReserved) AS RoomsReserved,
		|		MAX(Reservations.BedsReserved) AS BedsReserved,
		|		MAX(Reservations.GuestsReserved) AS GuestsReserved,
		|		MAX(Reservations.BedsReserved) AS NumberOfBeds
		|	FROM
		|		AccumulationRegister.RoomInventory AS Reservations
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.Расш1_СоставНомерногоФонда КАК Расш1_СоставНомерногоФонда
		|		ПО (Reservations.Room = Расш1_СоставНомерногоФонда.Номер
		|				И Расш1_СоставНомерногоФонда.НомернойФонд = &НомернойФонд)
		|	WHERE
		|		Reservations.RecordType = &qExpense
		|		AND Reservations.IsReservation
		|		AND (Reservations.PeriodFrom < &qPeriodTo
		|					AND Reservations.PeriodTo > &qPeriodFrom
		|					AND NOT &qShowTodaysBookingsOnly
		|				OR Reservations.PeriodFrom < &qPeriodTo
		|					AND Reservations.PeriodFrom >= &qPeriodFrom
		|					AND &qShowTodaysBookingsOnly)
		|		AND Reservations.Room = &qEmptyRoom " + 
		?(ValueIsFilled(SelHotel), ?(SelHotel.IsFolder, " AND Reservations.Hotel IN HIERARCHY(&qHotel)", " AND Reservations.Hotel = &qHotel"), "") + 
		?(SelRoomTypes.Count() > 1, " AND Reservations.RoomType IN HIERARCHY (&qRoomTypes)", ?(ValueIsFilled(SelRoomType), ?(SelRoomType.IsFolder, " AND Reservations.RoomType IN HIERARCHY(&qRoomType)", " AND Reservations.RoomType = &qRoomType"), "")) + 
		?(Not IsBlankString(SelDocNumber), " AND Reservations.Recorder.Number = &qDocNumber", "") + 
		?(ValueIsFilled(SelCustomer), ?(SelCustomer.IsFolder, " AND Reservations.Customer IN HIERARCHY(&qCustomer)", " AND Reservations.Customer = &qCustomer"), "") + 
		?(ValueIsFilled(SelContract), " AND Reservations.Contract = &qContract", "") + 
		?(Not IsBlankString(SelRemarks), " AND (Reservations.Remarks LIKE &qRemarks OR Reservations.Car LIKE &qRemarks)", "") + 
		?(ValueIsFilled(SelGuest), " AND Reservations.Guest = &qGuest", 
		?(IsBlankString(SelGuestStr), "", " AND (Reservations.Guest.FullName LIKE &qGuestStr OR Reservations.Customer.Description LIKE &qGuestStr)")) + 
		?(ValueIsFilled(SelGuestGroup), " AND Reservations.GuestGroup = &qGuestGroup", "") + 
		?(SelShowExpectedChangeRoomOnly, " AND FALSE", "") + 
		?(SelIntersection, 
		?(ValueIsFilled(SelCheckInDate), " AND Reservations.PeriodTo > &qCheckInDate", "") + 
		?(ValueIsFilled(SelCheckOutDate), " AND Reservations.PeriodFrom < &qCheckOutDate", ""), 
		?(ValueIsFilled(SelCheckInDate), " AND Reservations.PeriodFrom >= &qBegOfCheckInDate AND Reservations.PeriodFrom < &qEndOfCheckInDate", "") + 
		?(ValueIsFilled(SelCheckOutDate), " AND Reservations.PeriodTo >= &qBegOfCheckOutDate AND Reservations.PeriodTo < &qEndOfCheckOutDate", "")) + "
		|	
		|	GROUP BY
		|		Reservations.Hotel,
		|		Reservations.Room,
		|		Reservations.RoomType,
		|		Reservations.Recorder,
		|		Reservations.ParentDoc,
		|		Reservations.Guest,
		|		Reservations.PeriodFrom,
		|		Reservations.PeriodTo,
		|		Reservations.AccommodationType,
		|		Reservations.RoomRate,
		|		Reservations.ClientType,
		|		Reservations.ReservationStatus,
		|		Reservations.GuestGroup,
		|		Reservations.HotelProduct,
		|		Reservations.RoomQuota,
		|		Reservations.Customer,
		|		Reservations.Contract,
		|		Reservations.ContactPerson,
		|		Reservations.Car,
		|		Reservations.IsMaster,
		|		ISNULL(Reservations.Recorder.IsClosedForEdit, FALSE),
		|		Reservations.PlannedPaymentMethod,
		|		Reservations.NumberOfPersons,
		|		Reservations.CheckInDate,
		|		Reservations.CheckOutDate) AS DocumentPeriods
		|
		|ORDER BY
		|	HotelSortCode,
		|	RoomTypeSortCode,
		|	CheckInDate,
		|	DurationInSeconds DESC,
		|	RoomQuotaCode,
		|	CustomerCode,
		|	ContractCode,
		|	GuestGroupCode,
		|	AccommodationTypeSortCode,
		|	AccommodationPointInTime";
		vQry.SetParameter("НомернойФонд", НомернойФонд);
	КонецЕсли;	
	#КонецВставки
	
	#Удаление
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	DocumentPeriods.Hotel AS Hotel,
	|	DocumentPeriods.Hotel.SortCode AS HotelSortCode,
	|	DocumentPeriods.Room AS Room,
	|	DocumentPeriods.Room.SortCode AS RoomSortCode,
	|	ISNULL(DocumentPeriods.Room.IsFolder, FALSE) AS RoomIsFolder,
	|	ISNULL(DocumentPeriods.Room.Description, """") AS RoomDescription,
	|	DocumentPeriods.Room.Parent AS RoomParent,
	|	DocumentPeriods.Room.Parent.Description AS RoomParentDescription,
	|	DocumentPeriods.Room.RoomStatus AS RoomRoomStatus,
	|	ISNULL(DocumentPeriods.Room.StopSale, FALSE) AS RoomStopSale,
	|	DocumentPeriods.RoomType AS RoomType,
	|	DocumentPeriods.RoomType.SortCode AS RoomTypeSortCode,
	|	DocumentPeriods.RoomType.Code AS RoomTypeCode,
	|	DocumentPeriods.RoomType.Description AS RoomTypeDescription,
	|	ISNULL(DocumentPeriods.RoomType.IsFolder, FALSE) AS RoomTypeIsFolder,
	|	ISNULL(DocumentPeriods.RoomType.StopSale, FALSE) AS RoomTypeStopSale,
	|	DocumentPeriods.RoomType.Parent AS RoomTypeParent,
	|	DocumentPeriods.Recorder AS Accommodation,
	|	DocumentPeriods.Recorder.Number AS AccommodationNumber,
	|	DocumentPeriods.Recorder.PointInTime AS AccommodationPointInTime,
	|	DocumentPeriods.ParentDoc AS ParentDoc,
	|	DocumentPeriods.ParentDoc.Room AS ParentDocRoom,
	|	ISNULL(DocumentPeriods.ParentDoc.ReservationStatus.IsCheckIn, FALSE) AS ParentDocReservationStatusIsCheckIn,
	|	DocumentPeriods.Guest AS Guest,
	|	DocumentPeriods.Guest.Description AS GuestDescription,
	|	DocumentPeriods.Guest.FullName AS GuestFullName,
	|	DocumentPeriods.Guest.Citizenship AS GuestCitizenship,
	|	DocumentPeriods.Guest.Citizenship.ISOCode AS GuestCitizenshipISOCode,
	|	DocumentPeriods.Guest.DateOfBirth AS GuestDateOfBirth,
	|	DocumentPeriods.Guest.Sex AS GuestSex,
	|	DocumentPeriods.CheckInDate AS CheckInDate,
	|	DocumentPeriods.CheckOutDate AS CheckOutDate,
	|	DocumentPeriods.AccommodationType AS AccommodationType,
	|	DocumentPeriods.AccommodationType.Type AS AccommodationTypeType,
	|	DocumentPeriods.RoomRate AS RoomRate,
	|	DocumentPeriods.ClientType AS ClientType,
	|	DocumentPeriods.ClientType.Color AS ClientTypeColor,
	|	DocumentPeriods.ReservationStatus AS Status,
	|	DocumentPeriods.ReservationStatus.Color AS StatusColor,
	|	FALSE AS StatusIsInHouse,
	|	DocumentPeriods.ReservationStatus.IsGuaranteed AS StatusIsGuaranteed,
	|	DocumentPeriods.GuestGroup AS GuestGroup,
	|	DocumentPeriods.GuestGroup.Code AS GuestGroupCode,
	|	DocumentPeriods.GuestGroup.Description AS GuestGroupDescription,
	|	DocumentPeriods.GuestGroup.Color AS GuestGroupColor,
	|	DocumentPeriods.HotelProduct AS HotelProduct,
	|	DocumentPeriods.HotelProduct.Description AS HotelProductDescription,
	|	DocumentPeriods.HotelProduct.Parent AS HotelProductParent,
	|	DocumentPeriods.HotelProduct.Parent.Description AS HotelProductParentDescription,
	|	DocumentPeriods.RoomQuota AS RoomQuota,
	|	DocumentPeriods.RoomQuota.Code AS RoomQuotaCode,
	|	DocumentPeriods.RoomQuota.Color AS RoomQuotaColor,
	|	DocumentPeriods.Customer AS Customer,
	|	DocumentPeriods.Customer.Code AS CustomerCode,
	|	DocumentPeriods.Customer.Color AS CustomerColor,
	|	ISNULL(DocumentPeriods.Customer.IsIndividual, TRUE) AS CustomerIsIndividual,
	|	DocumentPeriods.Contract AS Contract,
	|	DocumentPeriods.Contract.Code AS ContractCode,
	|	DocumentPeriods.Contract.Color AS ContractColor,
	|	DocumentPeriods.ContactPerson AS ContactPerson,
	|	DocumentPeriods.Recorder.Remarks AS Remarks,
	|	DocumentPeriods.Recorder.Car AS Car,
	|	DocumentPeriods.IsMaster AS IsMaster,
	|	DocumentPeriods.IsClosedForEdit AS IsClosedForEdit,
	|	DocumentPeriods.PlannedPaymentMethod AS PlannedPaymentMethod,
	|	DocumentPeriods.PlannedPaymentMethod.Code AS PlannedPaymentMethodCode,
	|	DocumentPeriods.PlannedPaymentMethod.Description AS PlannedPaymentMethodDescription,
	|	DocumentPeriods.PlannedPaymentMethod.IsByBankTransfer AS IsByBankTransfer,
	|	DocumentPeriods.NumberOfPersons AS NumberOfPersons,
	|	DocumentPeriods.Recorder.ServicePackage AS ServicePackage,
	|	CAST(DocumentPeriods.Recorder.PricePresentation AS STRING(17)) AS PricePresentation,
	|	DATEDIFF(DocumentPeriods.DocCheckInDate, DocumentPeriods.DocCheckOutDate, SECOND) AS DurationInSeconds,
	|	CASE
	|		WHEN DocumentPeriods.AccommodationType.Type = &qAccomodationTypesRoom
	|			THEN 0
	|		WHEN DocumentPeriods.AccommodationType.Type = &qAccomodationTypesBeds
	|			THEN 0
	|		WHEN DocumentPeriods.AccommodationType.Type = &qAccomodationTypesAdditionalBed
	|			THEN 1
	|		ELSE 2
	|	END AS AccommodationTypeSortCode,
	|	DocumentPeriods.RoomsReserved AS RoomsReserved,
	|	DocumentPeriods.BedsReserved AS BedsReserved,
	|	DocumentPeriods.GuestsReserved AS GuestsReserved,
	|	DocumentPeriods.BedsReserved AS NumberOfBeds,
	|	ISNULL(DocumentPeriods.Recorder.RoomQuantity, 1) AS RoomQuantity
	|FROM
	|	(SELECT
	|		Reservations.Hotel AS Hotel,
	|		Reservations.Room AS Room,
	|		Reservations.RoomType AS RoomType,
	|		Reservations.Recorder AS Recorder,
	|		Reservations.ParentDoc AS ParentDoc,
	|		Reservations.Guest AS Guest,
	|		Reservations.PeriodFrom AS CheckInDate,
	|		Reservations.PeriodTo AS CheckOutDate,
	|		Reservations.AccommodationType AS AccommodationType,
	|		Reservations.RoomRate AS RoomRate,
	|		Reservations.ClientType AS ClientType,
	|		Reservations.ReservationStatus AS ReservationStatus,
	|		Reservations.GuestGroup AS GuestGroup,
	|		Reservations.HotelProduct AS HotelProduct,
	|		Reservations.RoomQuota AS RoomQuota,
	|		Reservations.Customer AS Customer,
	|		Reservations.Contract AS Contract,
	|		Reservations.ContactPerson AS ContactPerson,
	|		Reservations.IsMaster AS IsMaster,
	|		ISNULL(Reservations.Recorder.IsClosedForEdit, FALSE) AS IsClosedForEdit,
	|		Reservations.PlannedPaymentMethod AS PlannedPaymentMethod,
	|		Reservations.NumberOfPersons AS NumberOfPersons,
	|		Reservations.CheckInDate AS DocCheckInDate,
	|		Reservations.CheckOutDate AS DocCheckOutDate,
	|		MAX(Reservations.RoomsReserved) AS RoomsReserved,
	|		MAX(Reservations.BedsReserved) AS BedsReserved,
	|		MAX(Reservations.GuestsReserved) AS GuestsReserved,
	|		MAX(Reservations.BedsReserved) AS NumberOfBeds
	|	FROM
	|		AccumulationRegister.RoomInventory AS Reservations
	|	WHERE
	|		Reservations.RecordType = &qExpense
	|		AND Reservations.IsReservation
	|		AND (Reservations.PeriodFrom < &qPeriodTo
	|					AND Reservations.PeriodTo > &qPeriodFrom
	|					AND NOT &qShowTodaysBookingsOnly
	|				OR Reservations.PeriodFrom < &qPeriodTo
	|					AND Reservations.PeriodFrom >= &qPeriodFrom
	|					AND &qShowTodaysBookingsOnly)
	|		AND Reservations.Room = &qEmptyRoom " + 
	?(ValueIsFilled(SelHotel), ?(SelHotel.IsFolder, " AND Reservations.Hotel IN HIERARCHY(&qHotel)", " AND Reservations.Hotel = &qHotel"), "") + 
	?(SelRoomTypes.Count() > 1, " AND Reservations.RoomType IN HIERARCHY (&qRoomTypes)", ?(ValueIsFilled(SelRoomType), ?(SelRoomType.IsFolder, " AND Reservations.RoomType IN HIERARCHY(&qRoomType)", " AND Reservations.RoomType = &qRoomType"), "")) + 
	?(Not IsBlankString(SelDocNumber), " AND Reservations.Recorder.Number = &qDocNumber", "") + 
	?(ValueIsFilled(SelCustomer), ?(SelCustomer.IsFolder, " AND Reservations.Customer IN HIERARCHY(&qCustomer)", " AND Reservations.Customer = &qCustomer"), "") + 
	?(ValueIsFilled(SelContract), " AND Reservations.Contract = &qContract", "") + 
	?(Not IsBlankString(SelRemarks), " AND (Reservations.Remarks LIKE &qRemarks OR Reservations.Car LIKE &qRemarks)", "") + 
	?(ValueIsFilled(SelGuest), " AND Reservations.Guest = &qGuest", 
	?(IsBlankString(SelGuestStr), "", " AND (Reservations.Guest.FullName LIKE &qGuestStr OR Reservations.Customer.Description LIKE &qGuestStr)")) + 
	?(ValueIsFilled(SelGuestGroup), " AND Reservations.GuestGroup = &qGuestGroup", "") + 
	?(SelShowExpectedChangeRoomOnly, " AND FALSE", "") + 
	?(SelIntersection, 
	?(ValueIsFilled(SelCheckInDate), " AND Reservations.PeriodTo > &qCheckInDate", "") + 
	?(ValueIsFilled(SelCheckOutDate), " AND Reservations.PeriodFrom < &qCheckOutDate", ""), 
	?(ValueIsFilled(SelCheckInDate), " AND Reservations.PeriodFrom >= &qBegOfCheckInDate AND Reservations.PeriodFrom < &qEndOfCheckInDate", "") + 
	?(ValueIsFilled(SelCheckOutDate), " AND Reservations.PeriodTo >= &qBegOfCheckOutDate AND Reservations.PeriodTo < &qEndOfCheckOutDate", "")) + "
	|	
	|	GROUP BY
	|		Reservations.Hotel,
	|		Reservations.Room,
	|		Reservations.RoomType,
	|		Reservations.Recorder,
	|		Reservations.ParentDoc,
	|		Reservations.Guest,
	|		Reservations.PeriodFrom,
	|		Reservations.PeriodTo,
	|		Reservations.AccommodationType,
	|		Reservations.RoomRate,
	|		Reservations.ClientType,
	|		Reservations.ReservationStatus,
	|		Reservations.GuestGroup,
	|		Reservations.HotelProduct,
	|		Reservations.RoomQuota,
	|		Reservations.Customer,
	|		Reservations.Contract,
	|		Reservations.ContactPerson,
	|		Reservations.Car,
	|		Reservations.IsMaster,
	|		ISNULL(Reservations.Recorder.IsClosedForEdit, FALSE),
	|		Reservations.PlannedPaymentMethod,
	|		Reservations.NumberOfPersons,
	|		Reservations.CheckInDate,
	|		Reservations.CheckOutDate) AS DocumentPeriods
	|
	|ORDER BY
	|	HotelSortCode,
	|	RoomTypeSortCode,
	|	CheckInDate,
	|	DurationInSeconds DESC,
	|	RoomQuotaCode,
	|	CustomerCode,
	|	ContractCode,
	|	GuestGroupCode,
	|	AccommodationTypeSortCode,
	|	AccommodationPointInTime";
	#КонецУдаления
	vQry.SetParameter("qHotel", SelHotel);
	vQry.SetParameter("qRoomType", SelRoomType);
	vQry.SetParameter("qRoomTypes", SelRoomTypes);
	vQry.SetParameter("qEmptyRoom", Catalogs.Rooms.EmptyRef());
	vQry.SetParameter("qDocNumber", TrimAll(SelDocNumber));
	vQry.SetParameter("qCustomer", SelCustomer);
	vQry.SetParameter("qContract", SelContract);
	vQry.SetParameter("qRemarks", "%"+TrimR(SelRemarks)+"%");
	vQry.SetParameter("qGuest", SelGuest);
	vQry.SetParameter("qGuestStr", "%"+TrimR(SelGuestStr)+"%");
	vQry.SetParameter("qGuestGroup", SelGuestGroup);
	If pShowTodaysBookingsOnly Then
		vQry.SetParameter("qPeriodFrom", BegOfDay(CurrentSessionDate()));
		vQry.SetParameter("qPeriodTo", EndOfDay(CurrentSessionDate()));
	Else
		vQry.SetParameter("qPeriodFrom", pPeriodFrom);
		vQry.SetParameter("qPeriodTo", pPeriodTo);
	EndIf;
	vQry.SetParameter("qShowTodaysBookingsOnly", pShowTodaysBookingsOnly);
	vQry.SetParameter("qCheckInDate", SelCheckInDate);
	vQry.SetParameter("qBegOfCheckInDate", ?(ValueIsFilled(SelCheckInDate), BegOfDay(SelCheckInDate), '00010101'));
	vQry.SetParameter("qEndOfCheckInDate", ?(ValueIsFilled(SelCheckInDate), BegOfDay(SelCheckInDate) + 3600 * 24, '00010101'));
	vQry.SetParameter("qCheckOutDate", SelCheckOutDate);
	vQry.SetParameter("qBegOfCheckOutDate", ?(ValueIsFilled(SelCheckOutDate), BegOfDay(SelCheckOutDate), '00010101'));
	vQry.SetParameter("qEndOfCheckOutDate", ?(ValueIsFilled(SelCheckOutDate), BegOfDay(SelCheckOutDate) + 3600 * 24, '00010101'));
	vQry.SetParameter("qExpense", AccumulationRecordType.Expense);
	vQry.SetParameter("qAccomodationTypesRoom", Enums.AccomodationTypes.Room);
	vQry.SetParameter("qAccomodationTypesBeds", Enums.AccomodationTypes.Beds);
	vQry.SetParameter("qAccomodationTypesAdditionalBed", Enums.AccomodationTypes.AdditionalBed);
	vQryRes = vQry.Execute().Unload();
	Return vQryRes;
EndFunction


&AtServer
&ChangeAndValidate("GetRoomsVacantPeriods")
Function Расш1_GetRoomsVacantPeriods(pAllRooms, pBookings, pPeriodFrom, pPeriodTo)
	// Get minimum check-in and maximum check-out dates
	vPeriodFrom = pPeriodFrom;
	vPeriodTo = pPeriodTo;
	For Each vRoomRow In pAllRooms Do
		If ValueIsFilled(vRoomRow.Accommodation) And 
			ValueIsFilled(vRoomRow.CheckInDate) And
			ValueIsFilled(vRoomRow.CheckOutDate) Then
			If vPeriodFrom > vRoomRow.CheckInDate Then
				vPeriodFrom = vRoomRow.CheckInDate;
			EndIf;
			If vPeriodTo < vRoomRow.CheckOutDate Then
				vPeriodTo = vRoomRow.CheckOutDate;
			EndIf;
		EndIf;
	EndDo;
	For Each vBookingRow In pBookings Do
		If ValueIsFilled(vBookingRow.Accommodation) And 
			ValueIsFilled(vBookingRow.CheckInDate) And
			ValueIsFilled(vBookingRow.CheckOutDate) Then
			If vPeriodFrom > vBookingRow.CheckInDate Then
				vPeriodFrom = vBookingRow.CheckInDate;
			EndIf;
			If vPeriodTo < vBookingRow.CheckOutDate Then
				vPeriodTo = vBookingRow.CheckOutDate;
			EndIf;
		EndIf;
	EndDo;
	// Build and run query
	#Вставка
	Если НомернойФонд.Пустая() тогда
		vQry = New Query();
		vQry.Text = 
		"SELECT разрешенные
		|	RoomInventoryBalanceAndTurnovers.Hotel,
		|	RoomInventoryBalanceAndTurnovers.Hotel.SortCode AS HotelSortCode,
		|	RoomInventoryBalanceAndTurnovers.Room,
		|	RoomInventoryBalanceAndTurnovers.Room.SortCode AS RoomSortCode,
		|	RoomInventoryBalanceAndTurnovers.Room.Description AS RoomDescription,
		|	ISNULL(RoomInventoryBalanceAndTurnovers.Room.IsFolder, FALSE) AS RoomIsFolder,
		|	RoomInventoryBalanceAndTurnovers.Room.Parent AS RoomParent,
		|	RoomInventoryBalanceAndTurnovers.Room.Parent.Description AS RoomParentDescription,
		|	RoomInventoryBalanceAndTurnovers.Room.RoomStatus AS RoomRoomStatus,
		|	RoomInventoryBalanceAndTurnovers.Room.StopSale AS RoomStopSale,
		|	RoomInventoryBalanceAndTurnovers.RoomType AS RoomType,
		|	RoomInventoryBalanceAndTurnovers.RoomType.SortCode AS RoomTypeSortCode,
		|	RoomInventoryBalanceAndTurnovers.RoomType.Code AS RoomTypeCode,
		|	RoomInventoryBalanceAndTurnovers.RoomType.Description AS RoomTypeDescription,
		|	RoomInventoryBalanceAndTurnovers.RoomType.IsFolder AS RoomTypeIsFolder,
		|	RoomInventoryBalanceAndTurnovers.RoomType.StopSale AS RoomTypeStopSale,
		|	RoomInventoryBalanceAndTurnovers.RoomType.Parent AS RoomTypeParent,
		|	RoomInventoryBalanceAndTurnovers.CounterClosingBalance AS CounterClosingBalance,
		|	RoomInventoryBalanceAndTurnovers.RoomsVacantClosingBalance AS RoomsVacant,
		|	RoomInventoryBalanceAndTurnovers.BedsVacantClosingBalance AS BedsVacant,
		|	RoomInventoryBalanceAndTurnovers.Period AS Period,
		|	RoomInventoryBalanceAndTurnovers.Period AS VacantFromDate,
		|	RoomInventoryBalanceAndTurnovers.Period AS VacantToDate
		|FROM
		|	AccumulationRegister.RoomInventory.BalanceAndTurnovers(&qPeriodFrom, &qPeriodTo, 
		|															Second, 
		|															RegisterRecordsAndPeriodBoundaries, 
		|															TRUE " + 
		?(ValueIsFilled(SelHotel), ?(SelHotel.IsFolder, " AND Hotel IN HIERARCHY(&qHotel)", " AND Hotel = &qHotel"), "") + 
		?(SelRoomTypes.Count() > 1, " AND RoomType IN HIERARCHY (&qRoomTypes)", ?(ValueIsFilled(SelRoomType), ?(SelRoomType.IsFolder, " AND RoomType IN HIERARCHY(&qRoomType)", " AND RoomType = &qRoomType"), "")) + 
		?(ValueIsFilled(SelRoomSection), ?(SelRoomSection.IsFolder, " AND Room.RoomSection IN HIERARCHY(&qRoomSection)", " AND Room.RoomSection = &qRoomSection"), "") + 
		?(ValueIsFilled(SelRoom), ?(SelRoom.IsFolder, " AND Room IN HIERARCHY(&qRoom)", " AND Room = &qRoom"), "") + " 
		|) AS RoomInventoryBalanceAndTurnovers
		|WHERE
		|	RoomInventoryBalanceAndTurnovers.Room <> &qEmptyRoom
		|
		|ORDER BY
		|	HotelSortCode,
		|	RoomSortCode,
		|	VacantFromDate";	
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
		"SELECT разрешенные
		|	RoomInventoryBalanceAndTurnovers.Hotel,
		|	RoomInventoryBalanceAndTurnovers.Hotel.SortCode AS HotelSortCode,
		|	RoomInventoryBalanceAndTurnovers.Room,
		|	RoomInventoryBalanceAndTurnovers.Room.SortCode AS RoomSortCode,
		|	RoomInventoryBalanceAndTurnovers.Room.Description AS RoomDescription,
		|	ISNULL(RoomInventoryBalanceAndTurnovers.Room.IsFolder, FALSE) AS RoomIsFolder,
		|	RoomInventoryBalanceAndTurnovers.Room.Parent AS RoomParent,
		|	RoomInventoryBalanceAndTurnovers.Room.Parent.Description AS RoomParentDescription,
		|	RoomInventoryBalanceAndTurnovers.Room.RoomStatus AS RoomRoomStatus,
		|	RoomInventoryBalanceAndTurnovers.Room.StopSale AS RoomStopSale,
		|	RoomInventoryBalanceAndTurnovers.RoomType AS RoomType,
		|	RoomInventoryBalanceAndTurnovers.RoomType.SortCode AS RoomTypeSortCode,
		|	RoomInventoryBalanceAndTurnovers.RoomType.Code AS RoomTypeCode,
		|	RoomInventoryBalanceAndTurnovers.RoomType.Description AS RoomTypeDescription,
		|	RoomInventoryBalanceAndTurnovers.RoomType.IsFolder AS RoomTypeIsFolder,
		|	RoomInventoryBalanceAndTurnovers.RoomType.StopSale AS RoomTypeStopSale,
		|	RoomInventoryBalanceAndTurnovers.RoomType.Parent AS RoomTypeParent,
		|	RoomInventoryBalanceAndTurnovers.CounterClosingBalance AS CounterClosingBalance,
		|	RoomInventoryBalanceAndTurnovers.RoomsVacantClosingBalance AS RoomsVacant,
		|	RoomInventoryBalanceAndTurnovers.BedsVacantClosingBalance AS BedsVacant,
		|	RoomInventoryBalanceAndTurnovers.Period AS Period,
		|	RoomInventoryBalanceAndTurnovers.Period AS VacantFromDate,
		|	RoomInventoryBalanceAndTurnovers.Period AS VacantToDate
		|FROM
		|	AccumulationRegister.RoomInventory.BalanceAndTurnovers(&qPeriodFrom, &qPeriodTo, 
		|															Second, 
		|															RegisterRecordsAndPeriodBoundaries, 
		|															TRUE " + 
		?(ValueIsFilled(SelHotel), ?(SelHotel.IsFolder, " AND Hotel IN HIERARCHY(&qHotel)", " AND Hotel = &qHotel"), "") + 
		?(SelRoomTypes.Count() > 1, " AND RoomType IN HIERARCHY (&qRoomTypes)", ?(ValueIsFilled(SelRoomType), ?(SelRoomType.IsFolder, " AND RoomType IN HIERARCHY(&qRoomType)", " AND RoomType = &qRoomType"), "")) + 
		?(ValueIsFilled(SelRoomSection), ?(SelRoomSection.IsFolder, " AND Room.RoomSection IN HIERARCHY(&qRoomSection)", " AND Room.RoomSection = &qRoomSection"), "") + 
		?(ValueIsFilled(SelRoom), ?(SelRoom.IsFolder, " AND Room IN HIERARCHY(&qRoom)", " AND Room = &qRoom"), " и Room в (Выбрать Т.Номер Из ВТ_Номера как Т) ") + " 
		|) AS RoomInventoryBalanceAndTurnovers
		|WHERE
		|	RoomInventoryBalanceAndTurnovers.Room <> &qEmptyRoom
		|
		|ORDER BY
		|	HotelSortCode,
		|	RoomSortCode,
		|	VacantFromDate";	
	КонецЕсли;
	
	#КонецВставки
	
	#Удаление
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	RoomInventoryBalanceAndTurnovers.Hotel,
	|	RoomInventoryBalanceAndTurnovers.Hotel.SortCode AS HotelSortCode,
	|	RoomInventoryBalanceAndTurnovers.Room,
	|	RoomInventoryBalanceAndTurnovers.Room.SortCode AS RoomSortCode,
	|	RoomInventoryBalanceAndTurnovers.Room.Description AS RoomDescription,
	|	ISNULL(RoomInventoryBalanceAndTurnovers.Room.IsFolder, FALSE) AS RoomIsFolder,
	|	RoomInventoryBalanceAndTurnovers.Room.Parent AS RoomParent,
	|	RoomInventoryBalanceAndTurnovers.Room.Parent.Description AS RoomParentDescription,
	|	RoomInventoryBalanceAndTurnovers.Room.RoomStatus AS RoomRoomStatus,
	|	RoomInventoryBalanceAndTurnovers.Room.StopSale AS RoomStopSale,
	|	RoomInventoryBalanceAndTurnovers.RoomType AS RoomType,
	|	RoomInventoryBalanceAndTurnovers.RoomType.SortCode AS RoomTypeSortCode,
	|	RoomInventoryBalanceAndTurnovers.RoomType.Code AS RoomTypeCode,
	|	RoomInventoryBalanceAndTurnovers.RoomType.Description AS RoomTypeDescription,
	|	RoomInventoryBalanceAndTurnovers.RoomType.IsFolder AS RoomTypeIsFolder,
	|	RoomInventoryBalanceAndTurnovers.RoomType.StopSale AS RoomTypeStopSale,
	|	RoomInventoryBalanceAndTurnovers.RoomType.Parent AS RoomTypeParent,
	|	RoomInventoryBalanceAndTurnovers.CounterClosingBalance AS CounterClosingBalance,
	|	RoomInventoryBalanceAndTurnovers.RoomsVacantClosingBalance AS RoomsVacant,
	|	RoomInventoryBalanceAndTurnovers.BedsVacantClosingBalance AS BedsVacant,
	|	RoomInventoryBalanceAndTurnovers.Period AS Period,
	|	RoomInventoryBalanceAndTurnovers.Period AS VacantFromDate,
	|	RoomInventoryBalanceAndTurnovers.Period AS VacantToDate
	|FROM
	|	AccumulationRegister.RoomInventory.BalanceAndTurnovers(&qPeriodFrom, &qPeriodTo, 
	|															Second, 
	|															RegisterRecordsAndPeriodBoundaries, 
	|															TRUE " + 
	?(ValueIsFilled(SelHotel), ?(SelHotel.IsFolder, " AND Hotel IN HIERARCHY(&qHotel)", " AND Hotel = &qHotel"), "") + 
	?(SelRoomTypes.Count() > 1, " AND RoomType IN HIERARCHY (&qRoomTypes)", ?(ValueIsFilled(SelRoomType), ?(SelRoomType.IsFolder, " AND RoomType IN HIERARCHY(&qRoomType)", " AND RoomType = &qRoomType"), "")) + 
	?(ValueIsFilled(SelRoomSection), ?(SelRoomSection.IsFolder, " AND Room.RoomSection IN HIERARCHY(&qRoomSection)", " AND Room.RoomSection = &qRoomSection"), "") + 
	?(ValueIsFilled(SelRoom), ?(SelRoom.IsFolder, " AND Room IN HIERARCHY(&qRoom)", " AND Room = &qRoom"), "") + " 
	|) AS RoomInventoryBalanceAndTurnovers
	|WHERE
	|	RoomInventoryBalanceAndTurnovers.Room <> &qEmptyRoom
	|
	|ORDER BY
	|	HotelSortCode,
	|	RoomSortCode,
	|	VacantFromDate";
	#КонецУдаления
	vQry.SetParameter("qHotel", SelHotel);
	vQry.SetParameter("qRoomType", SelRoomType);
	vQry.SetParameter("qRoomTypes", SelRoomTypes);
	vQry.SetParameter("qRoom", SelRoom);
	vQry.SetParameter("qRoomSection", SelRoomSection);
	vQry.SetParameter("qEmptyRoom", Catalogs.Rooms.EmptyRef());
	vQry.SetParameter("qPeriodFrom", vPeriodFrom);
	vQry.SetParameter("qPeriodTo", vPeriodTo);
	vQryRes = vQry.Execute().Unload();
	// Build vacant periods
	i = 0;
	vCurRow = Undefined;
	vNextRow = Undefined;
	While i < (vQryRes.Count() - 1) Do
		vCurRow = vQryRes.Get(i);
		vNextRow = vQryRes.Get(i+1);
		If vCurRow.Room = vNextRow.Room Then
			vCurRow.VacantToDate = vNextRow.VacantFromDate;
		Else
			vCurRow.VacantToDate = '39991231235959';
		EndIf;
		i = i + 1;
	EndDo;
	If vNextRow <> Undefined And 
		vNextRow.VacantFromDate = vNextRow.VacantToDate Then
		vNextRow.VacantToDate = '39991231235959';
	EndIf;
	If vCurRow <> Undefined And 
		vCurRow.VacantFromDate = vCurRow.VacantToDate Then
		vCurRow.VacantToDate = '39991231235959';
	EndIf;
	// Glue chained periods with the same resources
	i = 0;
	While i < (vQryRes.Count() - 1) Do
		vCurRow = vQryRes.Get(i);
		vNextRow = vQryRes.Get(i + 1);
		If vNextRow.Room = vCurRow.Room And
			vNextRow.VacantFromDate = vCurRow.VacantToDate And 
			vNextRow.BedsVacant = vCurRow.BedsVacant And 
			vNextRow.RoomsVacant = vCurRow.RoomsVacant Then
			vCurRow.VacantToDate = vNextRow.VacantToDate;
			vQryRes.Delete(i + 1);
		Else
			i = i + 1;
		EndIf;
	EndDo;
	// Delete periods where vacant beds is less or equal zero
	i = 0;
	While i < vQryRes.Count() Do
		vCurRow = vQryRes.Get(i);
		If vCurRow.BedsVacant <= 0 Then
			vQryRes.Delete(i);
		Else
			i = i + 1;
		EndIf;
	EndDo;
	// Return vacant periods
	Return vQryRes;
EndFunction


&AtServer
&ChangeAndValidate("GetPeriodDailyVacants")
Function Расш1_GetPeriodDailyVacants(pPeriodFrom, pPeriodTo, pRoomType)
	If pRoomType = Undefined Then
		pRoomType = SelRoomType;
	EndIf;
	// Initialize "Show reports in beds" flag
	vShowReportsInBeds = False;
	If valueIsFilled(SelHotel) Then
		vShowReportsInBeds = SelHotel.ShowReportsInBeds;
	EndIf;
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	#Вставка
	"SELECT разрешенные
	|	RoomInventoryBalance.Period AS Period,
	|	RoomInventoryBalance.CounterClosingBalance AS CounterClosingBalance,
	|	RoomInventoryBalance.RoomsVacantClosingBalance AS RoomsVacant,
	|	RoomInventoryBalance.BedsVacantClosingBalance AS BedsVacant
	|FROM
	|	AccumulationRegister.RoomInventory.BalanceAndTurnovers(
	|			&qDateTimeFrom,
	|			&qDateTimeTo,
	|			Day,
	|			RegisterRecordsAndPeriodBoundaries,
	|			(Hotel IN HIERARCHY (&qHotel)
	|				OR &qHotelIsEmpty)
	|				AND (Room.RoomSection IN HIERARCHY (&qRoomSection)
	|					OR &qRoomSectionIsEmpty)
	|				AND (RoomType IN HIERARCHY (&qRoomType)
	|					OR &qRoomTypeIsEmpty)) AS RoomInventoryBalance
	|
	|ORDER BY
	|	Period
	|TOTALS
	|	SUM(CounterClosingBalance),
	|	SUM(RoomsVacant),
	|	SUM(BedsVacant)
	|BY
	|	Period PERIODS(DAY, &qDateTimeFrom, &qDateTimeTo)";
	#КонецВставки
	#Удаление
	"SELECT
	|	RoomInventoryBalance.Period AS Period,
	|	RoomInventoryBalance.CounterClosingBalance AS CounterClosingBalance,
	|	RoomInventoryBalance.RoomsVacantClosingBalance AS RoomsVacant,
	|	RoomInventoryBalance.BedsVacantClosingBalance AS BedsVacant
	|FROM
	|	AccumulationRegister.RoomInventory.BalanceAndTurnovers(
	|			&qDateTimeFrom,
	|			&qDateTimeTo,
	|			Day,
	|			RegisterRecordsAndPeriodBoundaries,
	|			(Hotel IN HIERARCHY (&qHotel)
	|				OR &qHotelIsEmpty)
	|				AND (Room.RoomSection IN HIERARCHY (&qRoomSection)
	|					OR &qRoomSectionIsEmpty)
	|				AND (RoomType IN HIERARCHY (&qRoomType)
	|					OR &qRoomTypeIsEmpty)) AS RoomInventoryBalance
	|
	|ORDER BY
	|	Period
	|TOTALS
	|	SUM(CounterClosingBalance),
	|	SUM(RoomsVacant),
	|	SUM(BedsVacant)
	|BY
	|	Period PERIODS(DAY, &qDateTimeFrom, &qDateTimeTo)";
	#КонецУдаления
	vQry.SetParameter("qHotel", SelHotel);
	vQry.SetParameter("qHotelIsEmpty", Not ValueIsFilled(SelHotel));
	vQry.SetParameter("qRoomSection", SelRoomSection);
	vQry.SetParameter("qRoomSectionIsEmpty", Not ValueIsFilled(SelRoomSection));
	vQry.SetParameter("qRoomType", ?(SelRoomTypes.Count() > 1, SelRoomTypes, pRoomType));
	vQry.SetParameter("qRoomTypeIsEmpty", Not ValueIsFilled(pRoomType));
	vQry.SetParameter("qDateTimeFrom", BegOfDay(pPeriodFrom));
	vQry.SetParameter("qDateTimeTo", EndOfDay(pPeriodTo));
	vQryRes = vQry.Execute();

	// Fill end of day balances and periods
	vPeriodDailyVacants = New Map();
	// Save all periods where vacant resource is changed and save periods where last change per day took place
	vLastVacant = Undefined;
	vQryDays = vQryRes.Select(QueryResultIteration.ByGroups, "Period", "ALL");
	While vQryDays.Next() Do
		vPeriod = vQryDays.Period;
		If (vPeriod < pPeriodFrom) Or (vPeriod > pPeriodTo) Then
			Continue;
		EndIf;
		vBegOfDay = BegOfDay(vPeriod);
		SetQueryVacantResource(vQryDays, vShowReportsInBeds, vLastVacant);
		vPeriodDailyVacants.Insert(vPeriod, ?(vLastVacant = Undefined, 0, vLastVacant));
	EndDo;
	// Return
	Return vPeriodDailyVacants;
EndFunction

