
&НаКлиенте
Процедура Расш1_НомернойФондПриИзмененииПосле(Элемент)
	FillRoomsList();
КонецПроцедуры

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

&AtServer
&ChangeAndValidate("FillRoomsListAtServer")
Function Расш1_FillRoomsListAtServer()
	vRowId = Undefined;
	
	// Check if all shortcuts are off
	If Not SelShowCheckedIn And Not SelShowCheckedOut And 
		Not SelShowPlannedCheckIn And Not SelShowPlannedCheckOut And 
		Not SelShowDirtyRooms And Not SelShowCleanRooms And 
		Not SelShowVacantRooms And Not SelShowOccupiedRooms And 
		Not SelShowRoomsWithTasks And Not SelShowRoomsWithDiscrepancies And 
		Not SelShowRoomsBlock And Not SelShowRoomsStopSale And Not SelShowRegularOperations Then
		SelShowAllRooms = True;
	EndIf;
	// Check if all statuses are selected
	For Each vItem In TableBoxStatuses Do
		If Not vItem.Check Then
			SelShowAllRooms = False;
			Break;
		EndIf;
	EndDo;
	If SelShowAllRooms Then
		If SelShowCheckedIn Or SelShowCheckedOut Or 
			SelShowPlannedCheckIn Or SelShowPlannedCheckOut Or 
			SelShowDirtyRooms Or SelShowCleanRooms Or 
			SelShowVacantRooms Or SelShowOccupiedRooms Or 
			SelShowRoomsWithTasks Or SelShowRoomsWithDiscrepancies Or
			SelShowRoomsBlock Or SelShowRoomsStopSale Or SelShowRegularOperations Then
			SelShowAllRooms = False;
		EndIf;
	EndIf;
	
	// List of hotels
	vHotelsList = GetHotelsList(SelHotel);
	
	// Fill list of statuses
	vStatusesList = New ValueList();
	For Each vRoomStatusesItem In TableBoxStatuses Do
		If vRoomStatusesItem.Check Then
			vStatusesList.Add(vRoomStatusesItem.Value);
		EndIf;
	EndDo;
	
	// Build lists of room statuses and rooms used to filter rooms
	vRoomsList = New ValueList();
	If SelShowRoomsWithTasks Then
		#Вставка
		Если НомернойФонд.Пустая() Тогда
			vQry = New Query();
			vQry.Text = 
			vQry = New Query();
			vQry.Text = 
			"SELECT разрешенные
			|	Messages.ByObject AS Room,
			|	Messages.Ref AS Recorder
			|FROM
			|	Document.Message AS Messages
			|WHERE
			|	Messages.Posted
			|	AND NOT Messages.IsClosed
			|	AND Messages.ByObject REFS Catalog.Rooms
			|	AND Messages.ByObject <> &qEmptyRoom
			|	AND Messages.ValidFromDate <= &qPeriod
			|	AND (Messages.ValidToDate > &qPeriod
			|			OR Messages.ValidToDate = &qEmptyDate)
			|
			|ORDER BY
			|	Messages.PointInTime DESC";	
		Иначе
			vQry = New Query();
			vQry.Text = 
			"ВЫБРАТЬ РАЗРЕШЕННЫЕ
			|	Messages.ByObject КАК Room,
			|	Messages.Ссылка КАК Recorder
			|ИЗ
			|	Документ.Message КАК Messages
			|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.Расш1_СоставНомерногоФонда КАК Расш1_СоставНомерногоФонда
			|		ПО ((ВЫРАЗИТЬ(Messages.ByObject КАК Справочник.Rooms)) = Расш1_СоставНомерногоФонда.Номер)
			|			И (Расш1_СоставНомерногоФонда.НомернойФонд = &НомернойФонд)
			|ГДЕ
			|	Messages.Проведен
			|	И НЕ Messages.IsClosed
			|	И Messages.ByObject ССЫЛКА Справочник.Rooms
			|	И Messages.ByObject <> &qEmptyRoom
			|	И Messages.ValidFromDate <= &qPeriod
			|	И (Messages.ValidToDate > &qPeriod
			|			ИЛИ Messages.ValidToDate = &qEmptyDate)
			|
			|УПОРЯДОЧИТЬ ПО
			|	Messages.МоментВремени УБЫВ";	
			vQry.SetParameter("НомернойФонд", НомернойФонд);
		КонецЕсли;
		#КонецВставки
		
		#Удаление
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	Messages.ByObject AS Room,
		|	Messages.Ref AS Recorder
		|FROM
		|	Document.Message AS Messages
		|WHERE
		|	Messages.Posted
		|	AND NOT Messages.IsClosed
		|	AND Messages.ByObject REFS Catalog.Rooms
		|	AND Messages.ByObject <> &qEmptyRoom
		|	AND Messages.ValidFromDate <= &qPeriod
		|	AND (Messages.ValidToDate > &qPeriod
		|			OR Messages.ValidToDate = &qEmptyDate)
		|
		|ORDER BY
		|	Messages.PointInTime DESC";
		#КонецУдаления
		vQry.SetParameter("qHotel", SelHotel);
		vQry.SetParameter("qEmptyRoom", Catalogs.Rooms.EmptyRef());
		vQry.SetParameter("qPeriod", CurrentSessionDate());
		vQry.SetParameter("qEmptyDate", '00010101');
		vRooms = vQry.Execute().Unload();
		vRoomsList.LoadValues(vRooms.UnloadColumn("Room"));
	ElsIf SelShowRoomsWithDiscrepancies Then
		#Вставка
		Если НомернойФонд.Пустая() Тогда
			vRoomsList = cmGetActiveRoomsList_Изм(SelHotel);	
		Иначе
			vRoomsList = cmGetActiveRoomsList_Изм(SelHotel, НомернойФонд);
		КонецЕсли;	
		#КонецВставки
		
		#Удаление
		vRoomsList = cmGetActiveRoomsList(SelHotel);
		#КонецУдаления
		vHotelGuests = GetRoomGuests(vRoomsList, CurrentSessionDate());
		i = 0;
		While i < vRoomsList.Count() Do
			vRoom = vRoomsList.Get(i).Value;
			vHotel = vRoom.Owner;
			vRoomGuests = vHotelGuests.FindRows(New Structure("Room", vRoom));
			vDiscrepancy = False;
			If vRoomGuests.Count() > 0 Then
				// There are in-house guests
				If vRoom.RoomStatus = vHotel.VacantRoomStatus And ValueIsFilled(vHotel.VacantRoomStatus) Or 
					ValueIsFilled(vRoom.RoomStatus) And vRoom.RoomStatus.RoomIsVacantClear Or
					vRoom.RoomStatus = vHotel.OutOfOrderRoomStatus And ValueIsFilled(vHotel.OutOfOrderRoomStatus) Or
					vRoom.RoomStatus = vHotel.RoomStatusAfterCheckOut And ValueIsFilled(vHotel.RoomStatusAfterCheckOut) Or
					vRoom.RoomStatus = vHotel.RoomStatusAfterRoomBlock And ValueIsFilled(vHotel.RoomStatusAfterRoomBlock) Or
					vRoom.RoomStatus = vHotel.RoomStatusInspection And ValueIsFilled(vHotel.RoomStatusInspection) Or
					ValueIsFilled(vRoom.RoomStatus) And vRoom.RoomStatus.InspectionIsInProgress Then
					vDiscrepancy = True;
				EndIf;
			Else
				// Nobody at home :-)
				If vRoom.RoomStatus = vHotel.OccupiedRoomStatus And ValueIsFilled(vHotel.OccupiedRoomStatus) Or 
					vRoom.RoomStatus = vHotel.OccupiedDirtyRoomStatus And ValueIsFilled(vHotel.OccupiedDirtyRoomStatus) Or
					vRoom.RoomStatus = vHotel.RoomStatusAfterEarlyCheckIn And ValueIsFilled(vHotel.RoomStatusAfterEarlyCheckIn) Or
					vRoom.RoomStatus = vHotel.RoomStatusDueOut And ValueIsFilled(vHotel.RoomStatusDueOut) Then
					vDiscrepancy = True;
				EndIf;
			EndIf;
			If Not vDiscrepancy Then
				If vRoom.RoomStatus = vHotel.OutOfOrderRoomStatus And ValueIsFilled(vHotel.OutOfOrderRoomStatus) Then
					If Not vRoom.HasRoomBlocks Then
						vDiscrepancy = True;
					EndIf;
				EndIf;
			EndIf;
			If Not vDiscrepancy Then
				vRoomsList.Delete(i);
			Else
				i = i + 1;
			EndIf;
		EndDo;
	ElsIf SelShowVacantRooms Then
		#Вставка
		Если НомернойФонд.Пустая() Тогда
			vRoomsList = cmGetActiveRoomsList_Изм(SelHotel);	
		Иначе
			vRoomsList = cmGetActiveRoomsList_Изм(SelHotel, НомернойФонд);
		КонецЕсли;	
		#КонецВставки
		
		#Удаление
		vRoomsList = cmGetActiveRoomsList(SelHotel);
		#КонецУдаления
		vHotelGuests = GetRoomGuests(vRoomsList, CurrentSessionDate());
		i = 0;
		While i < vRoomsList.Count() Do
			vRoomGuests = vHotelGuests.FindRows(New Structure("Room", vRoomsList.Get(i).Value));
			If vRoomGuests.Count() > 0 Then
				vRoomsList.Delete(i);
			Else
				i = i + 1;
			EndIf;
		EndDo;
	ElsIf SelShowOccupiedRooms Then		
		#Вставка
		Если НомернойФонд.Пустая() Тогда
			vRoomsList = cmGetActiveRoomsList_Изм(SelHotel);	
		Иначе
			vRoomsList = cmGetActiveRoomsList_Изм(SelHotel, НомернойФонд);
		КонецЕсли;	
		#КонецВставки
		
		#Удаление
		vRoomsList = cmGetActiveRoomsList(SelHotel);
		#КонецУдаления
		vHotelGuests = GetRoomGuests(vRoomsList, CurrentSessionDate());
		i = 0;
		While i < vRoomsList.Count() Do
			vRoomGuests = vHotelGuests.FindRows(New Structure("Room", vRoomsList.Get(i).Value));
			If vRoomGuests.Count() = 0 Then
				vRoomsList.Delete(i);
			Else
				i = i + 1;
			EndIf;
		EndDo;
	EndIf;
	
	// Build query to get all rooms
	#Вставка
	Если НомернойФонд.Пустая() Тогда
		vQry = New Query();
		vQry.Text = 
		"SELECT Разрешенные
		|	RoomsStopSalePeriods.Ref AS Room
		|INTO StopSales
		|FROM
		|	Catalog.Rooms.StopSalePeriods AS RoomsStopSalePeriods
		|WHERE
		|	RoomsStopSalePeriods.StopSale
		|	AND RoomsStopSalePeriods.PeriodFrom < &qToday
		|	AND RoomsStopSalePeriods.PeriodTo > &qToday
		|	AND NOT RoomsStopSalePeriods.Ref.DeletionMark
		|	AND NOT RoomsStopSalePeriods.Ref.IsFolder
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT  Разрешенные
		|	Accommodations.Room AS Room,
		|	Accommodations.Customer AS Customer,
		|	Accommodations.ClientType AS ClientType,
		|	Accommodations.AccommodationTemplate AS AccommodationTemplate,
		|	Accommodations.Number AS DocumentNumber,
		|	&qInHouseClause AS Clause,
		|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants AS NumberOfGuests
		|INTO InHouseGuests
		|FROM
		|	Document.Accommodation AS Accommodations
		|WHERE
		|	Accommodations.Posted
		|	AND Accommodations.AccommodationStatus.IsActive
		|	AND Accommodations.AccommodationStatus.IsInHouse
		|	AND (&qHotelsListIsEmpty
		|			OR NOT &qHotelsListIsEmpty
		|				AND Accommodations.Hotel IN (&qHotelsList))
		|	AND (&qParentIsEmpty
		|			OR NOT &qParentIsEmpty
		|				AND Accommodations.Room IN HIERARCHY (&qParent))
		|	AND (&qRoomTypeIsEmpty
		|			OR NOT &qRoomTypeIsEmpty
		|				AND Accommodations.RoomType IN HIERARCHY (&qRoomType))
		|	AND (&qRoomSectionIsEmpty
		|			OR NOT &qRoomSectionIsEmpty
		|				AND Accommodations.Room.RoomSection IN HIERARCHY (&qRoomSection))
		|	AND (&qRoomFloorIsEmpty
		|			OR NOT &qRoomFloorIsEmpty
		|				AND Accommodations.Room.Floor = &qRoomFloor)
		|	AND (&qRoomIsEmpty
		|			OR NOT &qRoomIsEmpty
		|				AND Accommodations.Room = &qRoom)
		|	AND Accommodations.AccommodationTemplate <> VALUE(Catalog.AccommodationTemplates.EmptyRef)
		|
		|GROUP BY
		|	Accommodations.Room,
		|	Accommodations.Number,
		|	Accommodations.Customer,
		|	Accommodations.ClientType,
		|	Accommodations.AccommodationTemplate,
		|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT  Разрешенные
		|	Reservations.Room AS Room,
		|	Reservations.Number AS DocumentNumber,
		|	Reservations.Customer AS Customer,
		|	Reservations.ClientType AS ClientType,
		|	Reservations.AccommodationTemplate AS AccommodationTemplate,
		|	CAST(Reservations.Remarks AS STRING(999)) AS Remarks,
		|	CAST(Reservations.HousekeepingRemarks AS STRING(999)) AS HousekeepingRemarks,
		|	&qExpectedCheckInClause AS Clause,
		|	Reservations.NumberOfAdults + Reservations.NumberOfTeenagers + Reservations.NumberOfChildren + Reservations.NumberOfInfants AS NumberOfGuestsOnArrival
		|INTO ExpectedCheckInGuests
		|FROM
		|	Document.Reservation AS Reservations
		|WHERE
		|	Reservations.Posted
		|	AND (Reservations.ReservationStatus.IsActive
		|			OR Reservations.ReservationStatus.IsPreliminary)
		|	AND Reservations.CheckInDate >= &qBegOfToday
		|	AND Reservations.CheckInDate <= &qEndOfToday
		|	AND Reservations.Room <> VALUE(Catalog.Rooms.EmptyRef)
		|	AND (&qHotelsListIsEmpty
		|			OR NOT &qHotelsListIsEmpty
		|				AND Reservations.Hotel IN (&qHotelsList))
		|	AND (&qParentIsEmpty
		|			OR NOT &qParentIsEmpty
		|				AND Reservations.Room IN HIERARCHY (&qParent))
		|	AND (&qRoomTypeIsEmpty
		|			OR NOT &qRoomTypeIsEmpty
		|				AND Reservations.RoomType IN HIERARCHY (&qRoomType))
		|	AND (&qRoomSectionIsEmpty
		|			OR NOT &qRoomSectionIsEmpty
		|				AND Reservations.Room.RoomSection IN HIERARCHY (&qRoomSection))
		|	AND (&qRoomFloorIsEmpty
		|			OR NOT &qRoomFloorIsEmpty
		|				AND Reservations.Room.Floor = &qRoomFloor)
		|	AND (&qRoomIsEmpty
		|			OR NOT &qRoomIsEmpty
		|				AND Reservations.Room = &qRoom)
		|	AND Reservations.AccommodationTemplate <> VALUE(Catalog.AccommodationTemplates.EmptyRef)
		|
		|GROUP BY
		|	Reservations.Room,
		|	Reservations.Number,
		|	Reservations.Customer,
		|	Reservations.ClientType,
		|	Reservations.AccommodationTemplate,
		|	CAST(Reservations.Remarks AS STRING(999)),
		|	CAST(Reservations.HousekeepingRemarks AS STRING(999)),
		|	Reservations.NumberOfAdults + Reservations.NumberOfTeenagers + Reservations.NumberOfChildren + Reservations.NumberOfInfants
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT Разрешенные
		|	ExpectedRoomMove.Room AS ToRoom,
		|	ExpectedRoomMove.Ref.Room AS FromRoom,
		|	ExpectedRoomMove.Ref.Number AS DocumentNumber,
		|	ExpectedRoomMove.Ref.Customer AS Customer,
		|	ExpectedRoomMove.Ref.ClientType AS ClientType,
		|	ExpectedRoomMove.Ref.AccommodationTemplate AS AccommodationTemplate,
		|	CAST(ExpectedRoomMove.Ref.Remarks AS STRING(999)) AS Remarks,
		|	CAST(ExpectedRoomMove.Ref.HousekeepingRemarks AS STRING(999)) AS HousekeepingRemarks,
		|	&qExpectedRoomMoveClause AS Clause,
		|	ExpectedRoomMove.Ref.NumberOfAdults + ExpectedRoomMove.Ref.NumberOfTeenagers + ExpectedRoomMove.Ref.NumberOfChildren + ExpectedRoomMove.Ref.NumberOfInfants AS NumberOfGuests
		|INTO ExpectedRoomMoveGuests
		|FROM
		|	Document.Accommodation.RoomRates AS ExpectedRoomMove
		|WHERE
		|	ExpectedRoomMove.Ref.Posted
		|	AND ExpectedRoomMove.Ref.AccommodationStatus.IsActive
		|	AND ExpectedRoomMove.Ref.AccommodationStatus.IsInHouse
		|	AND ExpectedRoomMove.Room <> VALUE(Catalog.Rooms.EmptyRef)
		|	AND ExpectedRoomMove.Room <> ExpectedRoomMove.Ref.Room
		|	AND ExpectedRoomMove.AccountingDate = &qBegOfToday
		|	AND (&qHotelsListIsEmpty
		|			OR NOT &qHotelsListIsEmpty
		|				AND ExpectedRoomMove.Ref.Hotel IN (&qHotelsList))
		|	AND (&qParentIsEmpty
		|			OR NOT &qParentIsEmpty
		|				AND ExpectedRoomMove.Ref.Room IN HIERARCHY (&qParent))
		|	AND (&qRoomTypeIsEmpty
		|			OR NOT &qRoomTypeIsEmpty
		|				AND ExpectedRoomMove.Ref.RoomType IN HIERARCHY (&qRoomType))
		|	AND (&qRoomSectionIsEmpty
		|			OR NOT &qRoomSectionIsEmpty
		|				AND ExpectedRoomMove.Ref.Room.RoomSection IN HIERARCHY (&qRoomSection))
		|	AND (&qRoomFloorIsEmpty
		|			OR NOT &qRoomFloorIsEmpty
		|				AND ExpectedRoomMove.Ref.Room.Floor = &qRoomFloor)
		|	AND (&qRoomIsEmpty
		|			OR NOT &qRoomIsEmpty
		|				AND ExpectedRoomMove.Ref.Room = &qRoom)
		|	AND ExpectedRoomMove.Ref.AccommodationTemplate <> VALUE(Catalog.AccommodationTemplates.EmptyRef)
		|
		|GROUP BY
		|	ExpectedRoomMove.Room,
		|	ExpectedRoomMove.Ref.Room,
		|	ExpectedRoomMove.Ref.Number,
		|	ExpectedRoomMove.Ref.Customer,
		|	ExpectedRoomMove.Ref.ClientType,
		|	ExpectedRoomMove.Ref.AccommodationTemplate,
		|	CAST(ExpectedRoomMove.Ref.Remarks AS STRING(999)),
		|	CAST(ExpectedRoomMove.Ref.HousekeepingRemarks AS STRING(999)),
		|	ExpectedRoomMove.Ref.NumberOfAdults + ExpectedRoomMove.Ref.NumberOfTeenagers + ExpectedRoomMove.Ref.NumberOfChildren + ExpectedRoomMove.Ref.NumberOfInfants
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT Разрешенные
		|	Accommodations.Room AS Room,
		|	Accommodations.Customer AS Customer,
		|	Accommodations.AccommodationTemplate AS AccommodationTemplate,
		|	&qExpectedCheckOutClause AS Clause,
		|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants AS NumberOfCheckOutGuests
		|INTO ExpectedCheckOutGuests
		|FROM
		|	Document.Accommodation AS Accommodations
		|WHERE
		|	Accommodations.Posted
		|	AND Accommodations.AccommodationStatus.IsActive
		|	AND Accommodations.AccommodationStatus.IsInHouse
		|	AND Accommodations.AccommodationStatus.IsCheckOut
		|	AND Accommodations.CheckOutDate >= &qBegOfToday
		|	AND Accommodations.CheckOutDate <= &qEndOfToday
		|	AND (&qHotelsListIsEmpty
		|			OR NOT &qHotelsListIsEmpty
		|				AND Accommodations.Hotel IN (&qHotelsList))
		|	AND (&qParentIsEmpty
		|			OR NOT &qParentIsEmpty
		|				AND Accommodations.Room IN HIERARCHY (&qParent))
		|	AND (&qRoomTypeIsEmpty
		|			OR NOT &qRoomTypeIsEmpty
		|				AND Accommodations.RoomType IN HIERARCHY (&qRoomType))
		|	AND (&qRoomSectionIsEmpty
		|			OR NOT &qRoomSectionIsEmpty
		|				AND Accommodations.Room.RoomSection IN HIERARCHY (&qRoomSection))
		|	AND (&qRoomFloorIsEmpty
		|			OR NOT &qRoomFloorIsEmpty
		|				AND Accommodations.Room.Floor = &qRoomFloor)
		|	AND (&qRoomIsEmpty
		|			OR NOT &qRoomIsEmpty
		|				AND Accommodations.Room = &qRoom)
		|	AND Accommodations.AccommodationTemplate <> VALUE(Catalog.AccommodationTemplates.EmptyRef)
		|
		|GROUP BY
		|	Accommodations.Room,
		|	Accommodations.Customer,
		|	Accommodations.AccommodationTemplate,
		|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT Разрешенные
		|	Accommodations.Room AS Room,
		|	Accommodations.AccommodationTemplate AS AccommodationTemplate,
		|	&qCheckedOutClause AS Clause,
		|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants AS NumberOfCheckedOutGuests
		|INTO CheckedOutGuests
		|FROM
		|	Document.Accommodation AS Accommodations
		|WHERE
		|	Accommodations.Posted
		|	AND Accommodations.AccommodationStatus.IsActive
		|	AND NOT Accommodations.AccommodationStatus.IsInHouse
		|	AND Accommodations.AccommodationStatus.IsCheckOut
		|	AND Accommodations.CheckOutDate >= &qBegOfToday
		|	AND Accommodations.CheckOutDate <= &qEndOfToday
		|	AND (&qHotelsListIsEmpty
		|			OR NOT &qHotelsListIsEmpty
		|				AND Accommodations.Hotel IN (&qHotelsList))
		|	AND (&qParentIsEmpty
		|			OR NOT &qParentIsEmpty
		|				AND Accommodations.Room IN HIERARCHY (&qParent))
		|	AND (&qRoomTypeIsEmpty
		|			OR NOT &qRoomTypeIsEmpty
		|				AND Accommodations.RoomType IN HIERARCHY (&qRoomType))
		|	AND (&qRoomSectionIsEmpty
		|			OR NOT &qRoomSectionIsEmpty
		|				AND Accommodations.Room.RoomSection IN HIERARCHY (&qRoomSection))
		|	AND (&qRoomFloorIsEmpty
		|			OR NOT &qRoomFloorIsEmpty
		|				AND Accommodations.Room.Floor = &qRoomFloor)
		|	AND (&qRoomIsEmpty
		|			OR NOT &qRoomIsEmpty
		|				AND Accommodations.Room = &qRoom)
		|	AND Accommodations.AccommodationTemplate <> VALUE(Catalog.AccommodationTemplates.EmptyRef)
		|
		|GROUP BY
		|	Accommodations.Room,
		|	Accommodations.AccommodationTemplate,
		|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT Разрешенные
		|	Accommodations.Room AS Room,
		|	Accommodations.Customer AS Customer,
		|	Accommodations.AccommodationTemplate AS AccommodationTemplate,
		|	CAST(Accommodations.Remarks AS STRING(999)) AS Remarks,
		|	CAST(Accommodations.HousekeepingRemarks AS STRING(999)) AS HousekeepingRemarks,
		|	&qCheckedInClause AS Clause,
		|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants AS NumberOfCheckedInGuests
		|INTO CheckedInGuests
		|FROM
		|	Document.Accommodation AS Accommodations
		|WHERE
		|	Accommodations.Posted
		|	AND Accommodations.AccommodationStatus.IsActive
		|	AND Accommodations.AccommodationStatus.IsInHouse
		|	AND Accommodations.AccommodationStatus.IsCheckIn
		|	AND Accommodations.CheckInDate >= &qBegOfToday
		|	AND Accommodations.CheckInDate <= &qEndOfToday
		|	AND (&qHotelsListIsEmpty
		|			OR NOT &qHotelsListIsEmpty
		|				AND Accommodations.Hotel IN (&qHotelsList))
		|	AND (&qParentIsEmpty
		|			OR NOT &qParentIsEmpty
		|				AND Accommodations.Room IN HIERARCHY (&qParent))
		|	AND (&qRoomTypeIsEmpty
		|			OR NOT &qRoomTypeIsEmpty
		|				AND Accommodations.RoomType IN HIERARCHY (&qRoomType))
		|	AND (&qRoomSectionIsEmpty
		|			OR NOT &qRoomSectionIsEmpty
		|				AND Accommodations.Room.RoomSection IN HIERARCHY (&qRoomSection))
		|	AND (&qRoomFloorIsEmpty
		|			OR NOT &qRoomFloorIsEmpty
		|				AND Accommodations.Room.Floor = &qRoomFloor)
		|	AND (&qRoomIsEmpty
		|			OR NOT &qRoomIsEmpty
		|				AND Accommodations.Room = &qRoom)
		|	AND Accommodations.AccommodationTemplate <> VALUE(Catalog.AccommodationTemplates.EmptyRef)
		|
		|GROUP BY
		|	Accommodations.Room,
		|	Accommodations.Customer,
		|	Accommodations.AccommodationTemplate,
		|	CAST(Accommodations.Remarks AS STRING(999)),
		|	CAST(Accommodations.HousekeepingRemarks AS STRING(999)),
		|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT Разрешенные
		|	Messages.ByObject AS Room,
		|	CAST(Messages.Remarks AS STRING(999)) AS TaskRemarks
		|INTO RoomTasks
		|FROM
		|	Document.Message AS Messages
		|WHERE
		|	Messages.Posted
		|	AND NOT Messages.IsClosed
		|	AND Messages.ByObject REFS Catalog.Rooms
		|	AND (&qHotelsListIsEmpty
		|			OR NOT &qHotelsListIsEmpty
		|				AND Messages.ByObject.Owner IN (&qHotelsList))
		|	AND (Messages.ValidFromDate = &qEmptyDate
		|			OR Messages.ValidFromDate <> &qEmptyDate
		|				AND Messages.ValidFromDate <= &qToday)
		|	AND (Messages.ValidToDate = &qEmptyDate
		|			OR Messages.ValidToDate <> &qEmptyDate
		|				AND Messages.ValidToDate > &qToday)
		|
		|GROUP BY
		|	Messages.ByObject,
		|	CAST(Messages.Remarks AS STRING(999))
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT Разрешенные
		|	RoomBlocks.Room AS Room,
		|	RoomBlocks.RoomBlockType AS RoomBlockType,
		|	RoomBlocks.Number AS BlockNumber,
		|	CAST(RoomBlocks.Remarks AS STRING(999)) AS RoomBlockRemarks
		|INTO RoomBlocks
		|FROM
		|	Document.SetRoomBlock AS RoomBlocks
		|WHERE
		|	RoomBlocks.Posted
		|	AND (&qHotelsListIsEmpty
		|			OR NOT &qHotelsListIsEmpty
		|				AND RoomBlocks.Hotel IN (&qHotelsList))
		|	AND RoomBlocks.DateFrom <= &qToday
		|	AND (RoomBlocks.DateTo = &qEmptyDate
		|			OR RoomBlocks.DateTo <> &qEmptyDate
		|				AND RoomBlocks.DateTo > &qToday)
		|	AND (&qParentIsEmpty
		|			OR NOT &qParentIsEmpty
		|				AND RoomBlocks.Room IN HIERARCHY (&qParent))
		|	AND (&qRoomTypeIsEmpty
		|			OR NOT &qRoomTypeIsEmpty
		|				AND RoomBlocks.Room.RoomType IN HIERARCHY (&qRoomType))
		|	AND (&qRoomSectionIsEmpty
		|			OR NOT &qRoomSectionIsEmpty
		|				AND RoomBlocks.Room.RoomSection IN HIERARCHY (&qRoomSection))
		|	AND (&qRoomFloorIsEmpty
		|			OR NOT &qRoomFloorIsEmpty
		|				AND RoomBlocks.Room.Floor = &qRoomFloor)
		|	AND (&qRoomIsEmpty
		|			OR NOT &qRoomIsEmpty
		|				AND RoomBlocks.Room = &qRoom)
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT DISTINCT Разрешенные
		|	CASE
		|		WHEN Rooms.IsFolder
		|			THEN 6
		|		ELSE 7
		|	END AS Icon,
		|	Rooms.Description AS Description,
		|	Rooms.RoomType AS RoomType,
		|	Rooms.Floor AS Floor,
		|	Rooms.RoomStatus AS RoomStatus,
		|	CASE
		|		WHEN Rooms.Ref = ExpectedRoomMoveGuests.ToRoom
		|			THEN ISNULL(ExpectedCheckInGuests.NumberOfGuestsOnArrival, 0) + ISNULL(ExpectedRoomMoveGuests.NumberOfGuests, 0)
		|		ELSE ISNULL(ExpectedCheckInGuests.NumberOfGuestsOnArrival, 0)
		|	END AS NumberOfGuestsOnArrival,
		|	ISNULL(InHouseGuests.NumberOfGuests, 0) AS NumberOfGuests,
		|	RoomStatusChangeHistory.Period AS RoomStatusLastChangeTime,
		|	CAST(Rooms.Remarks AS STRING(999)) AS Remarks,
		|	RoomTasks.TaskRemarks AS TaskRemarks,
		|	CASE
		|		WHEN ISNULL(ExpectedCheckInGuests.Remarks, """") <> """"
		|			THEN ExpectedCheckInGuests.Remarks
		|		WHEN ISNULL(CheckedInGuests.Remarks, """") <> """"
		|			THEN CheckedInGuests.Remarks
		|		WHEN Rooms.Ref = ExpectedRoomMoveGuests.ToRoom
		|				AND ISNULL(ExpectedRoomMoveGuests.Remarks, """") <> """"
		|			THEN ExpectedRoomMoveGuests.Remarks
		|		ELSE """"
		|	END AS ReceptionRemarks,
		|	CASE
		|		WHEN ISNULL(ExpectedCheckInGuests.HousekeepingRemarks, """") <> """"
		|			THEN ExpectedCheckInGuests.HousekeepingRemarks
		|		WHEN ISNULL(CheckedInGuests.HousekeepingRemarks, """") <> """"
		|			THEN CheckedInGuests.HousekeepingRemarks
		|		WHEN Rooms.Ref = ExpectedRoomMoveGuests.ToRoom
		|				AND ISNULL(ExpectedRoomMoveGuests.HousekeepingRemarks, """") <> """"
		|			THEN ExpectedRoomMoveGuests.HousekeepingRemarks
		|		ELSE """"
		|	END AS HousekeepingRemarks,
		|	CASE
		|		WHEN ISNULL(ExpectedCheckInGuests.Customer, VALUE(Catalog.Customers.EmptyRef)) <> VALUE(Catalog.Customers.EmptyRef)
		|			THEN ExpectedCheckInGuests.Customer
		|		WHEN Rooms.Ref = ExpectedRoomMoveGuests.ToRoom
		|				AND ISNULL(ExpectedRoomMoveGuests.Customer, VALUE(Catalog.Customers.EmptyRef)) <> VALUE(Catalog.Customers.EmptyRef)
		|			THEN ExpectedRoomMoveGuests.Customer
		|		WHEN ISNULL(InHouseGuests.Customer, VALUE(Catalog.Customers.EmptyRef)) <> VALUE(Catalog.Customers.EmptyRef)
		|			THEN InHouseGuests.Customer
		|		ELSE NULL
		|	END AS Customer,
		|	CASE
		|		WHEN ISNULL(ExpectedCheckInGuests.ClientType, VALUE(Catalog.ClientTypes.EmptyRef)) <> VALUE(Catalog.ClientTypes.EmptyRef)
		|			THEN ExpectedCheckInGuests.ClientType
		|		WHEN Rooms.Ref = ExpectedRoomMoveGuests.ToRoom
		|				AND ISNULL(ExpectedRoomMoveGuests.ClientType, VALUE(Catalog.ClientTypes.EmptyRef)) <> VALUE(Catalog.ClientTypes.EmptyRef)
		|			THEN ExpectedRoomMoveGuests.ClientType
		|		WHEN ISNULL(InHouseGuests.ClientType, VALUE(Catalog.ClientTypes.EmptyRef)) <> VALUE(Catalog.ClientTypes.EmptyRef)
		|			THEN InHouseGuests.ClientType
		|		ELSE NULL
		|	END AS ClientType,
		|	CASE
		|		WHEN ISNULL(ExpectedCheckInGuests.ClientType, VALUE(Catalog.ClientTypes.EmptyRef)) <> VALUE(Catalog.ClientTypes.EmptyRef)
		|			THEN ExpectedCheckInGuests.ClientType.Description
		|		WHEN Rooms.Ref = ExpectedRoomMoveGuests.ToRoom
		|				AND ISNULL(ExpectedRoomMoveGuests.ClientType, VALUE(Catalog.ClientTypes.EmptyRef)) <> VALUE(Catalog.ClientTypes.EmptyRef)
		|			THEN ExpectedRoomMoveGuests.ClientType.Description
		|		WHEN ISNULL(InHouseGuests.ClientType, VALUE(Catalog.ClientTypes.EmptyRef)) <> VALUE(Catalog.ClientTypes.EmptyRef)
		|			THEN InHouseGuests.ClientType.Description
		|		ELSE """"
		|	END AS ClientTypeDescription,
		|	CASE
		|		WHEN ISNULL(ExpectedCheckInGuests.AccommodationTemplate, VALUE(Catalog.AccommodationTemplates.EmptyRef)) <> VALUE(Catalog.AccommodationTemplates.EmptyRef)
		|			THEN ExpectedCheckInGuests.AccommodationTemplate
		|		WHEN Rooms.Ref = ExpectedRoomMoveGuests.ToRoom
		|				AND ISNULL(ExpectedRoomMoveGuests.AccommodationTemplate, VALUE(Catalog.AccommodationTemplates.EmptyRef)) <> VALUE(Catalog.AccommodationTemplates.EmptyRef)
		|			THEN ExpectedRoomMoveGuests.AccommodationTemplate
		|		ELSE NULL
		|	END AS AccommodationTemplate,
		|	CASE
		|		WHEN ISNULL(ExpectedCheckInGuests.AccommodationTemplate, VALUE(Catalog.AccommodationTemplates.EmptyRef)) <> VALUE(Catalog.AccommodationTemplates.EmptyRef)
		|			THEN ExpectedCheckInGuests.AccommodationTemplate.Description
		|		WHEN Rooms.Ref = ExpectedRoomMoveGuests.ToRoom
		|				AND ISNULL(ExpectedRoomMoveGuests.AccommodationTemplate, VALUE(Catalog.AccommodationTemplates.EmptyRef)) <> VALUE(Catalog.AccommodationTemplates.EmptyRef)
		|			THEN ExpectedRoomMoveGuests.AccommodationTemplate.Description
		|		ELSE """"
		|	END AS AccommodationTemplateDescription,
		|	CASE
		|		WHEN ISNULL(ExpectedCheckInGuests.DocumentNumber, """") <> """"
		|			THEN ExpectedCheckInGuests.DocumentNumber
		|		WHEN Rooms.Ref = ExpectedRoomMoveGuests.ToRoom
		|				AND ISNULL(ExpectedRoomMoveGuests.DocumentNumber, """") <> """"
		|			THEN ExpectedRoomMoveGuests.DocumentNumber
		|		WHEN ISNULL(InHouseGuests.DocumentNumber, """") <> """"
		|			THEN InHouseGuests.DocumentNumber
		|		ELSE NULL
		|	END AS DocumentNumber,
		|	CASE
		|		WHEN ISNULL(ExpectedCheckInGuests.DocumentNumber, """") <> """"
		|			THEN ExpectedCheckInGuests.Clause
		|		WHEN Rooms.Ref = ExpectedRoomMoveGuests.ToRoom
		|				AND ISNULL(ExpectedRoomMoveGuests.DocumentNumber, """") <> """"
		|			THEN ExpectedRoomMoveGuests.Clause
		|		WHEN ISNULL(InHouseGuests.DocumentNumber, """") <> """"
		|			THEN InHouseGuests.Clause
		|		ELSE NULL
		|	END AS DocumentClause,
		|	Rooms.HasRoomBlocks AS HasRoomBlocks,
		|	RoomBlocks.RoomBlockType AS RoomBlockType,
		|	RoomBlocks.RoomBlockRemarks AS RoomBlockRemarks,
		|	Rooms.StopSale AS StopSale,
		|	Rooms.IsVirtual AS IsVirtual,
		|	CAST(Rooms.RoomPropertiesCodes AS STRING(999)) AS RoomPropertiesCodes,
		|	"""" AS Condition,
		|	ExpectedCheckInGuests.Clause AS ExpectedCheckInClause,
		|	CheckedInGuests.Clause AS CheckedInClause,
		|	ExpectedRoomMoveGuests.Clause AS ExpectedRoomMoveClause,
		|	InHouseGuests.Clause AS InHouseClause,
		|	ExpectedCheckOutGuests.Clause AS ExpectedCheckOutClause,
		|	CheckedOutGuests.Clause AS CheckedOutClause,
		|	Rooms.SortCode AS SortCode,
		|	Rooms.IsFolder AS IsFolder,
		|	ExpectedRoomMoveGuests.FromRoom AS FromRoom,
		|	ExpectedRoomMoveGuests.ToRoom AS ToRoom,
		|	Rooms.Ref AS Ref,
		|	Rooms.Ref.Parent AS Parent
		|FROM
		|	Catalog.Rooms AS Rooms
		|		LEFT JOIN InformationRegister.RoomStatusChangeHistory.SliceLast(
		|				&qToday,
		|				&qHotelsListIsEmpty
		|					OR NOT &qHotelsListIsEmpty
		|						AND Room.Owner IN (&qHotelsList)) AS RoomStatusChangeHistory
		|		ON (RoomStatusChangeHistory.Room = Rooms.Ref)
		|		LEFT JOIN ExpectedCheckInGuests AS ExpectedCheckInGuests
		|		ON (ExpectedCheckInGuests.Room = Rooms.Ref)
		|		LEFT JOIN CheckedInGuests AS CheckedInGuests
		|		ON (CheckedInGuests.Room = Rooms.Ref)
		|		LEFT JOIN ExpectedRoomMoveGuests AS ExpectedRoomMoveGuests
		|		ON (ExpectedRoomMoveGuests.FromRoom = Rooms.Ref
		|				OR ExpectedRoomMoveGuests.ToRoom = Rooms.Ref)
		|		LEFT JOIN InHouseGuests AS InHouseGuests
		|		ON (InHouseGuests.Room = Rooms.Ref)
		|		LEFT JOIN ExpectedCheckOutGuests AS ExpectedCheckOutGuests
		|		ON (ExpectedCheckOutGuests.Room = Rooms.Ref)
		|		LEFT JOIN CheckedOutGuests AS CheckedOutGuests
		|		ON (CheckedOutGuests.Room = Rooms.Ref)
		|		LEFT JOIN RoomTasks AS RoomTasks
		|		ON (RoomTasks.Room = Rooms.Ref)
		|		LEFT JOIN RoomBlocks AS RoomBlocks
		|		ON (RoomBlocks.Room = Rooms.Ref)
		|		LEFT JOIN StopSales AS StopSales
		|		ON (StopSales.Room = Rooms.Ref)
		|WHERE
		|	NOT Rooms.DeletionMark
		|	AND NOT Rooms.IsVirtual
		|	AND Rooms.OperationStartDate < &qEndOfToday
		|	AND (Rooms.OperationEndDate = DATETIME(1, 1, 1)
		|			OR Rooms.OperationEndDate > &qBegOfToday)
		|	AND (&qHotelsListIsEmpty
		|			OR NOT &qHotelsListIsEmpty
		|				AND Rooms.Owner IN (&qHotelsList))
		|	AND (&qParentIsEmpty
		|			OR NOT &qParentIsEmpty
		|				AND Rooms.Ref IN HIERARCHY (&qParent))
		|	AND (&qRoomTypeIsEmpty
		|			OR NOT &qRoomTypeIsEmpty
		|				AND Rooms.RoomType IN HIERARCHY (&qRoomType))
		|	AND (&qRoomSectionIsEmpty
		|			OR NOT &qRoomSectionIsEmpty
		|				AND Rooms.RoomSection IN HIERARCHY (&qRoomSection))
		|	AND (&qRoomFloorIsEmpty
		|			OR NOT &qRoomFloorIsEmpty
		|				AND Rooms.Floor = &qRoomFloor)
		|	AND (&qRoomIsEmpty
		|			OR NOT &qRoomIsEmpty
		|				AND Rooms.Ref = &qRoom)
		|	AND (&qRoomsListIsEmpty
		|			OR NOT &qRoomsListIsEmpty
		|				AND Rooms.Ref IN (&qRoomsList))
		|	AND Rooms.RoomStatus IN(&qRoomStatusesList)
		|	AND (NOT &qExpectedCheckInOnly
		|			OR &qExpectedCheckInOnly
		|				AND ExpectedCheckInGuests.NumberOfGuestsOnArrival > 0)
		|	AND (NOT &qCheckedInOnly
		|			OR &qCheckedInOnly
		|				AND CheckedInGuests.NumberOfCheckedInGuests > 0)
		|	AND (NOT &qExpectedCheckOutOnly
		|			OR &qExpectedCheckOutOnly
		|				AND ExpectedCheckOutGuests.NumberOfCheckOutGuests > 0)
		|	AND (NOT &qCheckedOutOnly
		|			OR &qCheckedOutOnly
		|				AND CheckedOutGuests.NumberOfCheckedOutGuests > 0)
		|	AND (NOT &qCheckedRoomBlock
		|			OR &qCheckedRoomBlock
		|				AND RoomBlocks.Room <> VALUE(Document.SetRoomBlock.EmptyRef))
		|	AND (NOT &qCheckedStopSales
		|			OR &qCheckedStopSales
		|				AND StopSales.Room <> VALUE(Catalog.Rooms.EmptyRef))
		|
		|ORDER BY
		|	Rooms.Owner.SortCode,
		|	Rooms.Owner.Code,
		|	Rooms.SortCode,
		|	HousekeepingRemarks DESC,
		|	ClientTypeDescription DESC,
		|	NumberOfGuestsOnArrival DESC,
		|	NumberOfGuests DESC";
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
		|	RoomsStopSalePeriods.Ref AS Room
		|INTO StopSales
		|FROM
		|	Catalog.Rooms.StopSalePeriods AS RoomsStopSalePeriods
		|	Внутреннее Соединение ВТ_Номера как ВТ_Номера
		|	по ВТ_Номера.Номер = RoomsStopSalePeriods.Ref
		|WHERE
		|	RoomsStopSalePeriods.StopSale
		|	AND RoomsStopSalePeriods.PeriodFrom < &qToday
		|	AND RoomsStopSalePeriods.PeriodTo > &qToday
		|	AND NOT RoomsStopSalePeriods.Ref.DeletionMark
		|	AND NOT RoomsStopSalePeriods.Ref.IsFolder
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT  Разрешенные
		|	Accommodations.Room AS Room,
		|	Accommodations.Customer AS Customer,
		|	Accommodations.ClientType AS ClientType,
		|	Accommodations.AccommodationTemplate AS AccommodationTemplate,
		|	Accommodations.Number AS DocumentNumber,
		|	&qInHouseClause AS Clause,
		|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants AS NumberOfGuests
		|INTO InHouseGuests
		|FROM
		|	Document.Accommodation AS Accommodations
		|	Внутреннее Соединение ВТ_Номера как ВТ_Номера
		|	по ВТ_Номера.Номер = Accommodations.Room
		|WHERE
		|	Accommodations.Posted
		|	AND Accommodations.AccommodationStatus.IsActive
		|	AND Accommodations.AccommodationStatus.IsInHouse
		|	AND (&qHotelsListIsEmpty
		|			OR NOT &qHotelsListIsEmpty
		|				AND Accommodations.Hotel IN (&qHotelsList))
		|	AND (&qParentIsEmpty
		|			OR NOT &qParentIsEmpty
		|				AND Accommodations.Room IN HIERARCHY (&qParent))
		|	AND (&qRoomTypeIsEmpty
		|			OR NOT &qRoomTypeIsEmpty
		|				AND Accommodations.RoomType IN HIERARCHY (&qRoomType))
		|	AND (&qRoomSectionIsEmpty
		|			OR NOT &qRoomSectionIsEmpty
		|				AND Accommodations.Room.RoomSection IN HIERARCHY (&qRoomSection))
		|	AND (&qRoomFloorIsEmpty
		|			OR NOT &qRoomFloorIsEmpty
		|				AND Accommodations.Room.Floor = &qRoomFloor)
		|	AND (&qRoomIsEmpty
		|			OR NOT &qRoomIsEmpty
		|				AND Accommodations.Room = &qRoom)
		|	AND Accommodations.AccommodationTemplate <> VALUE(Catalog.AccommodationTemplates.EmptyRef)
		|
		|GROUP BY
		|	Accommodations.Room,
		|	Accommodations.Number,
		|	Accommodations.Customer,
		|	Accommodations.ClientType,
		|	Accommodations.AccommodationTemplate,
		|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT  Разрешенные
		|	Reservations.Room AS Room,
		|	Reservations.Number AS DocumentNumber,
		|	Reservations.Customer AS Customer,
		|	Reservations.ClientType AS ClientType,
		|	Reservations.AccommodationTemplate AS AccommodationTemplate,
		|	CAST(Reservations.Remarks AS STRING(999)) AS Remarks,
		|	CAST(Reservations.HousekeepingRemarks AS STRING(999)) AS HousekeepingRemarks,
		|	&qExpectedCheckInClause AS Clause,
		|	Reservations.NumberOfAdults + Reservations.NumberOfTeenagers + Reservations.NumberOfChildren + Reservations.NumberOfInfants AS NumberOfGuestsOnArrival
		|INTO ExpectedCheckInGuests
		|FROM
		|	Document.Reservation AS Reservations
		|	Внутреннее Соединение ВТ_Номера как ВТ_Номера
		|	по ВТ_Номера.Номер = Reservations.Room
		|WHERE
		|	Reservations.Posted
		|	AND (Reservations.ReservationStatus.IsActive
		|			OR Reservations.ReservationStatus.IsPreliminary)
		|	AND Reservations.CheckInDate >= &qBegOfToday
		|	AND Reservations.CheckInDate <= &qEndOfToday
		|	AND Reservations.Room <> VALUE(Catalog.Rooms.EmptyRef)
		|	AND (&qHotelsListIsEmpty
		|			OR NOT &qHotelsListIsEmpty
		|				AND Reservations.Hotel IN (&qHotelsList))
		|	AND (&qParentIsEmpty
		|			OR NOT &qParentIsEmpty
		|				AND Reservations.Room IN HIERARCHY (&qParent))
		|	AND (&qRoomTypeIsEmpty
		|			OR NOT &qRoomTypeIsEmpty
		|				AND Reservations.RoomType IN HIERARCHY (&qRoomType))
		|	AND (&qRoomSectionIsEmpty
		|			OR NOT &qRoomSectionIsEmpty
		|				AND Reservations.Room.RoomSection IN HIERARCHY (&qRoomSection))
		|	AND (&qRoomFloorIsEmpty
		|			OR NOT &qRoomFloorIsEmpty
		|				AND Reservations.Room.Floor = &qRoomFloor)
		|	AND (&qRoomIsEmpty
		|			OR NOT &qRoomIsEmpty
		|				AND Reservations.Room = &qRoom)
		|	AND Reservations.AccommodationTemplate <> VALUE(Catalog.AccommodationTemplates.EmptyRef)
		|
		|GROUP BY
		|	Reservations.Room,
		|	Reservations.Number,
		|	Reservations.Customer,
		|	Reservations.ClientType,
		|	Reservations.AccommodationTemplate,
		|	CAST(Reservations.Remarks AS STRING(999)),
		|	CAST(Reservations.HousekeepingRemarks AS STRING(999)),
		|	Reservations.NumberOfAdults + Reservations.NumberOfTeenagers + Reservations.NumberOfChildren + Reservations.NumberOfInfants
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT Разрешенные
		|	ExpectedRoomMove.Room AS ToRoom,
		|	ExpectedRoomMove.Ref.Room AS FromRoom,
		|	ExpectedRoomMove.Ref.Number AS DocumentNumber,
		|	ExpectedRoomMove.Ref.Customer AS Customer,
		|	ExpectedRoomMove.Ref.ClientType AS ClientType,
		|	ExpectedRoomMove.Ref.AccommodationTemplate AS AccommodationTemplate,
		|	CAST(ExpectedRoomMove.Ref.Remarks AS STRING(999)) AS Remarks,
		|	CAST(ExpectedRoomMove.Ref.HousekeepingRemarks AS STRING(999)) AS HousekeepingRemarks,
		|	&qExpectedRoomMoveClause AS Clause,
		|	ExpectedRoomMove.Ref.NumberOfAdults + ExpectedRoomMove.Ref.NumberOfTeenagers + ExpectedRoomMove.Ref.NumberOfChildren + ExpectedRoomMove.Ref.NumberOfInfants AS NumberOfGuests
		|INTO ExpectedRoomMoveGuests
		|FROM
		|	Document.Accommodation.RoomRates AS ExpectedRoomMove
		|	Внутреннее Соединение ВТ_Номера как ВТ_Номера
		|	по ВТ_Номера.Номер = ExpectedRoomMove.Room
		|WHERE
		|	ExpectedRoomMove.Ref.Posted
		|	AND ExpectedRoomMove.Ref.AccommodationStatus.IsActive
		|	AND ExpectedRoomMove.Ref.AccommodationStatus.IsInHouse
		|	AND ExpectedRoomMove.Room <> VALUE(Catalog.Rooms.EmptyRef)
		|	AND ExpectedRoomMove.Room <> ExpectedRoomMove.Ref.Room
		|	AND ExpectedRoomMove.AccountingDate = &qBegOfToday
		|	AND (&qHotelsListIsEmpty
		|			OR NOT &qHotelsListIsEmpty
		|				AND ExpectedRoomMove.Ref.Hotel IN (&qHotelsList))
		|	AND (&qParentIsEmpty
		|			OR NOT &qParentIsEmpty
		|				AND ExpectedRoomMove.Ref.Room IN HIERARCHY (&qParent))
		|	AND (&qRoomTypeIsEmpty
		|			OR NOT &qRoomTypeIsEmpty
		|				AND ExpectedRoomMove.Ref.RoomType IN HIERARCHY (&qRoomType))
		|	AND (&qRoomSectionIsEmpty
		|			OR NOT &qRoomSectionIsEmpty
		|				AND ExpectedRoomMove.Ref.Room.RoomSection IN HIERARCHY (&qRoomSection))
		|	AND (&qRoomFloorIsEmpty
		|			OR NOT &qRoomFloorIsEmpty
		|				AND ExpectedRoomMove.Ref.Room.Floor = &qRoomFloor)
		|	AND (&qRoomIsEmpty
		|			OR NOT &qRoomIsEmpty
		|				AND ExpectedRoomMove.Ref.Room = &qRoom)
		|	AND ExpectedRoomMove.Ref.AccommodationTemplate <> VALUE(Catalog.AccommodationTemplates.EmptyRef)
		|
		|GROUP BY
		|	ExpectedRoomMove.Room,
		|	ExpectedRoomMove.Ref.Room,
		|	ExpectedRoomMove.Ref.Number,
		|	ExpectedRoomMove.Ref.Customer,
		|	ExpectedRoomMove.Ref.ClientType,
		|	ExpectedRoomMove.Ref.AccommodationTemplate,
		|	CAST(ExpectedRoomMove.Ref.Remarks AS STRING(999)),
		|	CAST(ExpectedRoomMove.Ref.HousekeepingRemarks AS STRING(999)),
		|	ExpectedRoomMove.Ref.NumberOfAdults + ExpectedRoomMove.Ref.NumberOfTeenagers + ExpectedRoomMove.Ref.NumberOfChildren + ExpectedRoomMove.Ref.NumberOfInfants
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT Разрешенные
		|	Accommodations.Room AS Room,
		|	Accommodations.Customer AS Customer,
		|	Accommodations.AccommodationTemplate AS AccommodationTemplate,
		|	&qExpectedCheckOutClause AS Clause,
		|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants AS NumberOfCheckOutGuests
		|INTO ExpectedCheckOutGuests
		|FROM
		|	Document.Accommodation AS Accommodations
		|	Внутреннее Соединение ВТ_Номера как ВТ_Номера
		|	по ВТ_Номера.Номер = Accommodations.Room
		|WHERE
		|	Accommodations.Posted
		|	AND Accommodations.AccommodationStatus.IsActive
		|	AND Accommodations.AccommodationStatus.IsInHouse
		|	AND Accommodations.AccommodationStatus.IsCheckOut
		|	AND Accommodations.CheckOutDate >= &qBegOfToday
		|	AND Accommodations.CheckOutDate <= &qEndOfToday
		|	AND (&qHotelsListIsEmpty
		|			OR NOT &qHotelsListIsEmpty
		|				AND Accommodations.Hotel IN (&qHotelsList))
		|	AND (&qParentIsEmpty
		|			OR NOT &qParentIsEmpty
		|				AND Accommodations.Room IN HIERARCHY (&qParent))
		|	AND (&qRoomTypeIsEmpty
		|			OR NOT &qRoomTypeIsEmpty
		|				AND Accommodations.RoomType IN HIERARCHY (&qRoomType))
		|	AND (&qRoomSectionIsEmpty
		|			OR NOT &qRoomSectionIsEmpty
		|				AND Accommodations.Room.RoomSection IN HIERARCHY (&qRoomSection))
		|	AND (&qRoomFloorIsEmpty
		|			OR NOT &qRoomFloorIsEmpty
		|				AND Accommodations.Room.Floor = &qRoomFloor)
		|	AND (&qRoomIsEmpty
		|			OR NOT &qRoomIsEmpty
		|				AND Accommodations.Room = &qRoom)
		|	AND Accommodations.AccommodationTemplate <> VALUE(Catalog.AccommodationTemplates.EmptyRef)
		|
		|GROUP BY
		|	Accommodations.Room,
		|	Accommodations.Customer,
		|	Accommodations.AccommodationTemplate,
		|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT Разрешенные
		|	Accommodations.Room AS Room,
		|	Accommodations.AccommodationTemplate AS AccommodationTemplate,
		|	&qCheckedOutClause AS Clause,
		|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants AS NumberOfCheckedOutGuests
		|INTO CheckedOutGuests
		|FROM
		|	Document.Accommodation AS Accommodations
		|	Внутреннее Соединение ВТ_Номера как ВТ_Номера
		|	по ВТ_Номера.Номер = Accommodations.Room
		|WHERE
		|	Accommodations.Posted
		|	AND Accommodations.AccommodationStatus.IsActive
		|	AND NOT Accommodations.AccommodationStatus.IsInHouse
		|	AND Accommodations.AccommodationStatus.IsCheckOut
		|	AND Accommodations.CheckOutDate >= &qBegOfToday
		|	AND Accommodations.CheckOutDate <= &qEndOfToday
		|	AND (&qHotelsListIsEmpty
		|			OR NOT &qHotelsListIsEmpty
		|				AND Accommodations.Hotel IN (&qHotelsList))
		|	AND (&qParentIsEmpty
		|			OR NOT &qParentIsEmpty
		|				AND Accommodations.Room IN HIERARCHY (&qParent))
		|	AND (&qRoomTypeIsEmpty
		|			OR NOT &qRoomTypeIsEmpty
		|				AND Accommodations.RoomType IN HIERARCHY (&qRoomType))
		|	AND (&qRoomSectionIsEmpty
		|			OR NOT &qRoomSectionIsEmpty
		|				AND Accommodations.Room.RoomSection IN HIERARCHY (&qRoomSection))
		|	AND (&qRoomFloorIsEmpty
		|			OR NOT &qRoomFloorIsEmpty
		|				AND Accommodations.Room.Floor = &qRoomFloor)
		|	AND (&qRoomIsEmpty
		|			OR NOT &qRoomIsEmpty
		|				AND Accommodations.Room = &qRoom)
		|	AND Accommodations.AccommodationTemplate <> VALUE(Catalog.AccommodationTemplates.EmptyRef)
		|
		|GROUP BY
		|	Accommodations.Room,
		|	Accommodations.AccommodationTemplate,
		|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT Разрешенные
		|	Accommodations.Room AS Room,
		|	Accommodations.Customer AS Customer,
		|	Accommodations.AccommodationTemplate AS AccommodationTemplate,
		|	CAST(Accommodations.Remarks AS STRING(999)) AS Remarks,
		|	CAST(Accommodations.HousekeepingRemarks AS STRING(999)) AS HousekeepingRemarks,
		|	&qCheckedInClause AS Clause,
		|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants AS NumberOfCheckedInGuests
		|INTO CheckedInGuests
		|FROM
		|	Document.Accommodation AS Accommodations
		|	Внутреннее Соединение ВТ_Номера как ВТ_Номера
		|	по ВТ_Номера.Номер = Accommodations.Room
		|WHERE
		|	Accommodations.Posted
		|	AND Accommodations.AccommodationStatus.IsActive
		|	AND Accommodations.AccommodationStatus.IsInHouse
		|	AND Accommodations.AccommodationStatus.IsCheckIn
		|	AND Accommodations.CheckInDate >= &qBegOfToday
		|	AND Accommodations.CheckInDate <= &qEndOfToday
		|	AND (&qHotelsListIsEmpty
		|			OR NOT &qHotelsListIsEmpty
		|				AND Accommodations.Hotel IN (&qHotelsList))
		|	AND (&qParentIsEmpty
		|			OR NOT &qParentIsEmpty
		|				AND Accommodations.Room IN HIERARCHY (&qParent))
		|	AND (&qRoomTypeIsEmpty
		|			OR NOT &qRoomTypeIsEmpty
		|				AND Accommodations.RoomType IN HIERARCHY (&qRoomType))
		|	AND (&qRoomSectionIsEmpty
		|			OR NOT &qRoomSectionIsEmpty
		|				AND Accommodations.Room.RoomSection IN HIERARCHY (&qRoomSection))
		|	AND (&qRoomFloorIsEmpty
		|			OR NOT &qRoomFloorIsEmpty
		|				AND Accommodations.Room.Floor = &qRoomFloor)
		|	AND (&qRoomIsEmpty
		|			OR NOT &qRoomIsEmpty
		|				AND Accommodations.Room = &qRoom)
		|	AND Accommodations.AccommodationTemplate <> VALUE(Catalog.AccommodationTemplates.EmptyRef)
		|
		|GROUP BY
		|	Accommodations.Room,
		|	Accommodations.Customer,
		|	Accommodations.AccommodationTemplate,
		|	CAST(Accommodations.Remarks AS STRING(999)),
		|	CAST(Accommodations.HousekeepingRemarks AS STRING(999)),
		|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT Разрешенные
		|	Messages.ByObject AS Room,
		|	CAST(Messages.Remarks AS STRING(999)) AS TaskRemarks
		|INTO RoomTasks
		|FROM
		|	Document.Message AS Messages
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_Номера как ВТ_Номера
		|		ПО ((ВЫРАЗИТЬ(Messages.ByObject КАК Справочник.Rooms)) = ВТ_Номера.Номер)
		|WHERE
		|	Messages.Posted
		|	AND NOT Messages.IsClosed
		|	AND Messages.ByObject REFS Catalog.Rooms
		|	AND (&qHotelsListIsEmpty
		|			OR NOT &qHotelsListIsEmpty
		|				AND Messages.ByObject.Owner IN (&qHotelsList))
		|	AND (Messages.ValidFromDate = &qEmptyDate
		|			OR Messages.ValidFromDate <> &qEmptyDate
		|				AND Messages.ValidFromDate <= &qToday)
		|	AND (Messages.ValidToDate = &qEmptyDate
		|			OR Messages.ValidToDate <> &qEmptyDate
		|				AND Messages.ValidToDate > &qToday)
		|
		|GROUP BY
		|	Messages.ByObject,
		|	CAST(Messages.Remarks AS STRING(999))
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT Разрешенные
		|	RoomBlocks.Room AS Room,
		|	RoomBlocks.RoomBlockType AS RoomBlockType,
		|	RoomBlocks.Number AS BlockNumber,
		|	CAST(RoomBlocks.Remarks AS STRING(999)) AS RoomBlockRemarks
		|INTO RoomBlocks
		|FROM
		|	Document.SetRoomBlock AS RoomBlocks
		|	Внутреннее Соединение ВТ_Номера как ВТ_Номера
		|	по ВТ_Номера.Номер = RoomBlocks.Room
		|WHERE
		|	RoomBlocks.Posted
		|	AND (&qHotelsListIsEmpty
		|			OR NOT &qHotelsListIsEmpty
		|				AND RoomBlocks.Hotel IN (&qHotelsList))
		|	AND RoomBlocks.DateFrom <= &qToday
		|	AND (RoomBlocks.DateTo = &qEmptyDate
		|			OR RoomBlocks.DateTo <> &qEmptyDate
		|				AND RoomBlocks.DateTo > &qToday)
		|	AND (&qParentIsEmpty
		|			OR NOT &qParentIsEmpty
		|				AND RoomBlocks.Room IN HIERARCHY (&qParent))
		|	AND (&qRoomTypeIsEmpty
		|			OR NOT &qRoomTypeIsEmpty
		|				AND RoomBlocks.Room.RoomType IN HIERARCHY (&qRoomType))
		|	AND (&qRoomSectionIsEmpty
		|			OR NOT &qRoomSectionIsEmpty
		|				AND RoomBlocks.Room.RoomSection IN HIERARCHY (&qRoomSection))
		|	AND (&qRoomFloorIsEmpty
		|			OR NOT &qRoomFloorIsEmpty
		|				AND RoomBlocks.Room.Floor = &qRoomFloor)
		|	AND (&qRoomIsEmpty
		|			OR NOT &qRoomIsEmpty
		|				AND RoomBlocks.Room = &qRoom)
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT DISTINCT Разрешенные
		|	CASE
		|		WHEN Rooms.IsFolder
		|			THEN 6
		|		ELSE 7
		|	END AS Icon,
		|	Rooms.Description AS Description,
		|	Rooms.RoomType AS RoomType,
		|	Rooms.Floor AS Floor,
		|	Rooms.RoomStatus AS RoomStatus,
		|	CASE
		|		WHEN Rooms.Ref = ExpectedRoomMoveGuests.ToRoom
		|			THEN ISNULL(ExpectedCheckInGuests.NumberOfGuestsOnArrival, 0) + ISNULL(ExpectedRoomMoveGuests.NumberOfGuests, 0)
		|		ELSE ISNULL(ExpectedCheckInGuests.NumberOfGuestsOnArrival, 0)
		|	END AS NumberOfGuestsOnArrival,
		|	ISNULL(InHouseGuests.NumberOfGuests, 0) AS NumberOfGuests,
		|	RoomStatusChangeHistory.Period AS RoomStatusLastChangeTime,
		|	CAST(Rooms.Remarks AS STRING(999)) AS Remarks,
		|	RoomTasks.TaskRemarks AS TaskRemarks,
		|	CASE
		|		WHEN ISNULL(ExpectedCheckInGuests.Remarks, """") <> """"
		|			THEN ExpectedCheckInGuests.Remarks
		|		WHEN ISNULL(CheckedInGuests.Remarks, """") <> """"
		|			THEN CheckedInGuests.Remarks
		|		WHEN Rooms.Ref = ExpectedRoomMoveGuests.ToRoom
		|				AND ISNULL(ExpectedRoomMoveGuests.Remarks, """") <> """"
		|			THEN ExpectedRoomMoveGuests.Remarks
		|		ELSE """"
		|	END AS ReceptionRemarks,
		|	CASE
		|		WHEN ISNULL(ExpectedCheckInGuests.HousekeepingRemarks, """") <> """"
		|			THEN ExpectedCheckInGuests.HousekeepingRemarks
		|		WHEN ISNULL(CheckedInGuests.HousekeepingRemarks, """") <> """"
		|			THEN CheckedInGuests.HousekeepingRemarks
		|		WHEN Rooms.Ref = ExpectedRoomMoveGuests.ToRoom
		|				AND ISNULL(ExpectedRoomMoveGuests.HousekeepingRemarks, """") <> """"
		|			THEN ExpectedRoomMoveGuests.HousekeepingRemarks
		|		ELSE """"
		|	END AS HousekeepingRemarks,
		|	CASE
		|		WHEN ISNULL(ExpectedCheckInGuests.Customer, VALUE(Catalog.Customers.EmptyRef)) <> VALUE(Catalog.Customers.EmptyRef)
		|			THEN ExpectedCheckInGuests.Customer
		|		WHEN Rooms.Ref = ExpectedRoomMoveGuests.ToRoom
		|				AND ISNULL(ExpectedRoomMoveGuests.Customer, VALUE(Catalog.Customers.EmptyRef)) <> VALUE(Catalog.Customers.EmptyRef)
		|			THEN ExpectedRoomMoveGuests.Customer
		|		WHEN ISNULL(InHouseGuests.Customer, VALUE(Catalog.Customers.EmptyRef)) <> VALUE(Catalog.Customers.EmptyRef)
		|			THEN InHouseGuests.Customer
		|		ELSE NULL
		|	END AS Customer,
		|	CASE
		|		WHEN ISNULL(ExpectedCheckInGuests.ClientType, VALUE(Catalog.ClientTypes.EmptyRef)) <> VALUE(Catalog.ClientTypes.EmptyRef)
		|			THEN ExpectedCheckInGuests.ClientType
		|		WHEN Rooms.Ref = ExpectedRoomMoveGuests.ToRoom
		|				AND ISNULL(ExpectedRoomMoveGuests.ClientType, VALUE(Catalog.ClientTypes.EmptyRef)) <> VALUE(Catalog.ClientTypes.EmptyRef)
		|			THEN ExpectedRoomMoveGuests.ClientType
		|		WHEN ISNULL(InHouseGuests.ClientType, VALUE(Catalog.ClientTypes.EmptyRef)) <> VALUE(Catalog.ClientTypes.EmptyRef)
		|			THEN InHouseGuests.ClientType
		|		ELSE NULL
		|	END AS ClientType,
		|	CASE
		|		WHEN ISNULL(ExpectedCheckInGuests.ClientType, VALUE(Catalog.ClientTypes.EmptyRef)) <> VALUE(Catalog.ClientTypes.EmptyRef)
		|			THEN ExpectedCheckInGuests.ClientType.Description
		|		WHEN Rooms.Ref = ExpectedRoomMoveGuests.ToRoom
		|				AND ISNULL(ExpectedRoomMoveGuests.ClientType, VALUE(Catalog.ClientTypes.EmptyRef)) <> VALUE(Catalog.ClientTypes.EmptyRef)
		|			THEN ExpectedRoomMoveGuests.ClientType.Description
		|		WHEN ISNULL(InHouseGuests.ClientType, VALUE(Catalog.ClientTypes.EmptyRef)) <> VALUE(Catalog.ClientTypes.EmptyRef)
		|			THEN InHouseGuests.ClientType.Description
		|		ELSE """"
		|	END AS ClientTypeDescription,
		|	CASE
		|		WHEN ISNULL(ExpectedCheckInGuests.AccommodationTemplate, VALUE(Catalog.AccommodationTemplates.EmptyRef)) <> VALUE(Catalog.AccommodationTemplates.EmptyRef)
		|			THEN ExpectedCheckInGuests.AccommodationTemplate
		|		WHEN Rooms.Ref = ExpectedRoomMoveGuests.ToRoom
		|				AND ISNULL(ExpectedRoomMoveGuests.AccommodationTemplate, VALUE(Catalog.AccommodationTemplates.EmptyRef)) <> VALUE(Catalog.AccommodationTemplates.EmptyRef)
		|			THEN ExpectedRoomMoveGuests.AccommodationTemplate
		|		ELSE NULL
		|	END AS AccommodationTemplate,
		|	CASE
		|		WHEN ISNULL(ExpectedCheckInGuests.AccommodationTemplate, VALUE(Catalog.AccommodationTemplates.EmptyRef)) <> VALUE(Catalog.AccommodationTemplates.EmptyRef)
		|			THEN ExpectedCheckInGuests.AccommodationTemplate.Description
		|		WHEN Rooms.Ref = ExpectedRoomMoveGuests.ToRoom
		|				AND ISNULL(ExpectedRoomMoveGuests.AccommodationTemplate, VALUE(Catalog.AccommodationTemplates.EmptyRef)) <> VALUE(Catalog.AccommodationTemplates.EmptyRef)
		|			THEN ExpectedRoomMoveGuests.AccommodationTemplate.Description
		|		ELSE """"
		|	END AS AccommodationTemplateDescription,
		|	CASE
		|		WHEN ISNULL(ExpectedCheckInGuests.DocumentNumber, """") <> """"
		|			THEN ExpectedCheckInGuests.DocumentNumber
		|		WHEN Rooms.Ref = ExpectedRoomMoveGuests.ToRoom
		|				AND ISNULL(ExpectedRoomMoveGuests.DocumentNumber, """") <> """"
		|			THEN ExpectedRoomMoveGuests.DocumentNumber
		|		WHEN ISNULL(InHouseGuests.DocumentNumber, """") <> """"
		|			THEN InHouseGuests.DocumentNumber
		|		ELSE NULL
		|	END AS DocumentNumber,
		|	CASE
		|		WHEN ISNULL(ExpectedCheckInGuests.DocumentNumber, """") <> """"
		|			THEN ExpectedCheckInGuests.Clause
		|		WHEN Rooms.Ref = ExpectedRoomMoveGuests.ToRoom
		|				AND ISNULL(ExpectedRoomMoveGuests.DocumentNumber, """") <> """"
		|			THEN ExpectedRoomMoveGuests.Clause
		|		WHEN ISNULL(InHouseGuests.DocumentNumber, """") <> """"
		|			THEN InHouseGuests.Clause
		|		ELSE NULL
		|	END AS DocumentClause,
		|	Rooms.HasRoomBlocks AS HasRoomBlocks,
		|	RoomBlocks.RoomBlockType AS RoomBlockType,
		|	RoomBlocks.RoomBlockRemarks AS RoomBlockRemarks,
		|	Rooms.StopSale AS StopSale,
		|	Rooms.IsVirtual AS IsVirtual,
		|	CAST(Rooms.RoomPropertiesCodes AS STRING(999)) AS RoomPropertiesCodes,
		|	"""" AS Condition,
		|	ExpectedCheckInGuests.Clause AS ExpectedCheckInClause,
		|	CheckedInGuests.Clause AS CheckedInClause,
		|	ExpectedRoomMoveGuests.Clause AS ExpectedRoomMoveClause,
		|	InHouseGuests.Clause AS InHouseClause,
		|	ExpectedCheckOutGuests.Clause AS ExpectedCheckOutClause,
		|	CheckedOutGuests.Clause AS CheckedOutClause,
		|	Rooms.SortCode AS SortCode,
		|	Rooms.IsFolder AS IsFolder,
		|	ExpectedRoomMoveGuests.FromRoom AS FromRoom,
		|	ExpectedRoomMoveGuests.ToRoom AS ToRoom,
		|	Rooms.Ref AS Ref,
		|	Rooms.Ref.Parent AS Parent,
		|FROM
		|	Catalog.Rooms AS Rooms
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_Номера как ВТ_Номера
		|		ПО ВТ_Номера.Номер = Rooms.Ref
		|		LEFT JOIN InformationRegister.RoomStatusChangeHistory.SliceLast(
		|				&qToday, Room в (Выбрать Т.Номер Из ВТ_Номера как Т) и
		|				&qHotelsListIsEmpty
		|					OR NOT &qHotelsListIsEmpty
		|						AND Room.Owner IN (&qHotelsList)) AS RoomStatusChangeHistory
		|		ON (RoomStatusChangeHistory.Room = Rooms.Ref)
		|		LEFT JOIN ExpectedCheckInGuests AS ExpectedCheckInGuests
		|		ON (ExpectedCheckInGuests.Room = Rooms.Ref)
		|		LEFT JOIN CheckedInGuests AS CheckedInGuests
		|		ON (CheckedInGuests.Room = Rooms.Ref)
		|		LEFT JOIN ExpectedRoomMoveGuests AS ExpectedRoomMoveGuests
		|		ON (ExpectedRoomMoveGuests.FromRoom = Rooms.Ref
		|				OR ExpectedRoomMoveGuests.ToRoom = Rooms.Ref)
		|		LEFT JOIN InHouseGuests AS InHouseGuests
		|		ON (InHouseGuests.Room = Rooms.Ref)
		|		LEFT JOIN ExpectedCheckOutGuests AS ExpectedCheckOutGuests
		|		ON (ExpectedCheckOutGuests.Room = Rooms.Ref)
		|		LEFT JOIN CheckedOutGuests AS CheckedOutGuests
		|		ON (CheckedOutGuests.Room = Rooms.Ref)
		|		LEFT JOIN RoomTasks AS RoomTasks
		|		ON (RoomTasks.Room = Rooms.Ref)
		|		LEFT JOIN RoomBlocks AS RoomBlocks
		|		ON (RoomBlocks.Room = Rooms.Ref)
		|		LEFT JOIN StopSales AS StopSales
		|		ON (StopSales.Room = Rooms.Ref)
		|WHERE
		|	NOT Rooms.DeletionMark
		|	AND NOT Rooms.IsVirtual
		|	AND Rooms.OperationStartDate < &qEndOfToday
		|	AND (Rooms.OperationEndDate = DATETIME(1, 1, 1)
		|			OR Rooms.OperationEndDate > &qBegOfToday)
		|	AND (&qHotelsListIsEmpty
		|			OR NOT &qHotelsListIsEmpty
		|				AND Rooms.Owner IN (&qHotelsList))
		|	AND (&qParentIsEmpty
		|			OR NOT &qParentIsEmpty
		|				AND Rooms.Ref IN HIERARCHY (&qParent))
		|	AND (&qRoomTypeIsEmpty
		|			OR NOT &qRoomTypeIsEmpty
		|				AND Rooms.RoomType IN HIERARCHY (&qRoomType))
		|	AND (&qRoomSectionIsEmpty
		|			OR NOT &qRoomSectionIsEmpty
		|				AND Rooms.RoomSection IN HIERARCHY (&qRoomSection))
		|	AND (&qRoomFloorIsEmpty
		|			OR NOT &qRoomFloorIsEmpty
		|				AND Rooms.Floor = &qRoomFloor)
		|	AND (&qRoomIsEmpty
		|			OR NOT &qRoomIsEmpty
		|				AND Rooms.Ref = &qRoom)
		|	AND (&qRoomsListIsEmpty
		|			OR NOT &qRoomsListIsEmpty
		|				AND Rooms.Ref IN (&qRoomsList))
		|	AND Rooms.RoomStatus IN(&qRoomStatusesList)
		|	AND (NOT &qExpectedCheckInOnly
		|			OR &qExpectedCheckInOnly
		|				AND ExpectedCheckInGuests.NumberOfGuestsOnArrival > 0)
		|	AND (NOT &qCheckedInOnly
		|			OR &qCheckedInOnly
		|				AND CheckedInGuests.NumberOfCheckedInGuests > 0)
		|	AND (NOT &qExpectedCheckOutOnly
		|			OR &qExpectedCheckOutOnly
		|				AND ExpectedCheckOutGuests.NumberOfCheckOutGuests > 0)
		|	AND (NOT &qCheckedOutOnly
		|			OR &qCheckedOutOnly
		|				AND CheckedOutGuests.NumberOfCheckedOutGuests > 0)
		|	AND (NOT &qCheckedRoomBlock
		|			OR &qCheckedRoomBlock
		|				AND RoomBlocks.Room <> VALUE(Document.SetRoomBlock.EmptyRef))
		|	AND (NOT &qCheckedStopSales
		|			OR &qCheckedStopSales
		|				AND StopSales.Room <> VALUE(Catalog.Rooms.EmptyRef))
		|
		|ORDER BY
		|	Rooms.Owner.SortCode,
		|	Rooms.Owner.Code,
		|	Rooms.SortCode,
		|	HousekeepingRemarks DESC,
		|	ClientTypeDescription DESC,
		|	NumberOfGuestsOnArrival DESC,
		|	NumberOfGuests DESC";	
	КонецЕсли;
	#КонецВставки
	
	#Удаление
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	RoomsStopSalePeriods.Ref AS Room
	|INTO StopSales
	|FROM
	|	Catalog.Rooms.StopSalePeriods AS RoomsStopSalePeriods
	|WHERE
	|	RoomsStopSalePeriods.StopSale
	|	AND RoomsStopSalePeriods.PeriodFrom < &qToday
	|	AND RoomsStopSalePeriods.PeriodTo > &qToday
	|	AND NOT RoomsStopSalePeriods.Ref.DeletionMark
	|	AND NOT RoomsStopSalePeriods.Ref.IsFolder
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	Accommodations.Room AS Room,
	|	Accommodations.Customer AS Customer,
	|	Accommodations.ClientType AS ClientType,
	|	Accommodations.AccommodationTemplate AS AccommodationTemplate,
	|	Accommodations.Number AS DocumentNumber,
	|	&qInHouseClause AS Clause,
	|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants AS NumberOfGuests
	|INTO InHouseGuests
	|FROM
	|	Document.Accommodation AS Accommodations
	|WHERE
	|	Accommodations.Posted
	|	AND Accommodations.AccommodationStatus.IsActive
	|	AND Accommodations.AccommodationStatus.IsInHouse
	|	AND (&qHotelsListIsEmpty
	|			OR NOT &qHotelsListIsEmpty
	|				AND Accommodations.Hotel IN (&qHotelsList))
	|	AND (&qParentIsEmpty
	|			OR NOT &qParentIsEmpty
	|				AND Accommodations.Room IN HIERARCHY (&qParent))
	|	AND (&qRoomTypeIsEmpty
	|			OR NOT &qRoomTypeIsEmpty
	|				AND Accommodations.RoomType IN HIERARCHY (&qRoomType))
	|	AND (&qRoomSectionIsEmpty
	|			OR NOT &qRoomSectionIsEmpty
	|				AND Accommodations.Room.RoomSection IN HIERARCHY (&qRoomSection))
	|	AND (&qRoomFloorIsEmpty
	|			OR NOT &qRoomFloorIsEmpty
	|				AND Accommodations.Room.Floor = &qRoomFloor)
	|	AND (&qRoomIsEmpty
	|			OR NOT &qRoomIsEmpty
	|				AND Accommodations.Room = &qRoom)
	|	AND Accommodations.AccommodationTemplate <> VALUE(Catalog.AccommodationTemplates.EmptyRef)
	|
	|GROUP BY
	|	Accommodations.Room,
	|	Accommodations.Number,
	|	Accommodations.Customer,
	|	Accommodations.ClientType,
	|	Accommodations.AccommodationTemplate,
	|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	Reservations.Room AS Room,
	|	Reservations.Number AS DocumentNumber,
	|	Reservations.Customer AS Customer,
	|	Reservations.ClientType AS ClientType,
	|	Reservations.AccommodationTemplate AS AccommodationTemplate,
	|	CAST(Reservations.Remarks AS STRING(999)) AS Remarks,
	|	CAST(Reservations.HousekeepingRemarks AS STRING(999)) AS HousekeepingRemarks,
	|	&qExpectedCheckInClause AS Clause,
	|	Reservations.NumberOfAdults + Reservations.NumberOfTeenagers + Reservations.NumberOfChildren + Reservations.NumberOfInfants AS NumberOfGuestsOnArrival
	|INTO ExpectedCheckInGuests
	|FROM
	|	Document.Reservation AS Reservations
	|WHERE
	|	Reservations.Posted
	|	AND (Reservations.ReservationStatus.IsActive
	|			OR Reservations.ReservationStatus.IsPreliminary)
	|	AND Reservations.CheckInDate >= &qBegOfToday
	|	AND Reservations.CheckInDate <= &qEndOfToday
	|	AND Reservations.Room <> VALUE(Catalog.Rooms.EmptyRef)
	|	AND (&qHotelsListIsEmpty
	|			OR NOT &qHotelsListIsEmpty
	|				AND Reservations.Hotel IN (&qHotelsList))
	|	AND (&qParentIsEmpty
	|			OR NOT &qParentIsEmpty
	|				AND Reservations.Room IN HIERARCHY (&qParent))
	|	AND (&qRoomTypeIsEmpty
	|			OR NOT &qRoomTypeIsEmpty
	|				AND Reservations.RoomType IN HIERARCHY (&qRoomType))
	|	AND (&qRoomSectionIsEmpty
	|			OR NOT &qRoomSectionIsEmpty
	|				AND Reservations.Room.RoomSection IN HIERARCHY (&qRoomSection))
	|	AND (&qRoomFloorIsEmpty
	|			OR NOT &qRoomFloorIsEmpty
	|				AND Reservations.Room.Floor = &qRoomFloor)
	|	AND (&qRoomIsEmpty
	|			OR NOT &qRoomIsEmpty
	|				AND Reservations.Room = &qRoom)
	|	AND Reservations.AccommodationTemplate <> VALUE(Catalog.AccommodationTemplates.EmptyRef)
	|
	|GROUP BY
	|	Reservations.Room,
	|	Reservations.Number,
	|	Reservations.Customer,
	|	Reservations.ClientType,
	|	Reservations.AccommodationTemplate,
	|	CAST(Reservations.Remarks AS STRING(999)),
	|	CAST(Reservations.HousekeepingRemarks AS STRING(999)),
	|	Reservations.NumberOfAdults + Reservations.NumberOfTeenagers + Reservations.NumberOfChildren + Reservations.NumberOfInfants
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	ExpectedRoomMove.Room AS ToRoom,
	|	ExpectedRoomMove.Ref.Room AS FromRoom,
	|	ExpectedRoomMove.Ref.Number AS DocumentNumber,
	|	ExpectedRoomMove.Ref.Customer AS Customer,
	|	ExpectedRoomMove.Ref.ClientType AS ClientType,
	|	ExpectedRoomMove.Ref.AccommodationTemplate AS AccommodationTemplate,
	|	CAST(ExpectedRoomMove.Ref.Remarks AS STRING(999)) AS Remarks,
	|	CAST(ExpectedRoomMove.Ref.HousekeepingRemarks AS STRING(999)) AS HousekeepingRemarks,
	|	&qExpectedRoomMoveClause AS Clause,
	|	ExpectedRoomMove.Ref.NumberOfAdults + ExpectedRoomMove.Ref.NumberOfTeenagers + ExpectedRoomMove.Ref.NumberOfChildren + ExpectedRoomMove.Ref.NumberOfInfants AS NumberOfGuests
	|INTO ExpectedRoomMoveGuests
	|FROM
	|	Document.Accommodation.RoomRates AS ExpectedRoomMove
	|WHERE
	|	ExpectedRoomMove.Ref.Posted
	|	AND ExpectedRoomMove.Ref.AccommodationStatus.IsActive
	|	AND ExpectedRoomMove.Ref.AccommodationStatus.IsInHouse
	|	AND ExpectedRoomMove.Room <> VALUE(Catalog.Rooms.EmptyRef)
	|	AND ExpectedRoomMove.Room <> ExpectedRoomMove.Ref.Room
	|	AND ExpectedRoomMove.AccountingDate = &qBegOfToday
	|	AND (&qHotelsListIsEmpty
	|			OR NOT &qHotelsListIsEmpty
	|				AND ExpectedRoomMove.Ref.Hotel IN (&qHotelsList))
	|	AND (&qParentIsEmpty
	|			OR NOT &qParentIsEmpty
	|				AND ExpectedRoomMove.Ref.Room IN HIERARCHY (&qParent))
	|	AND (&qRoomTypeIsEmpty
	|			OR NOT &qRoomTypeIsEmpty
	|				AND ExpectedRoomMove.Ref.RoomType IN HIERARCHY (&qRoomType))
	|	AND (&qRoomSectionIsEmpty
	|			OR NOT &qRoomSectionIsEmpty
	|				AND ExpectedRoomMove.Ref.Room.RoomSection IN HIERARCHY (&qRoomSection))
	|	AND (&qRoomFloorIsEmpty
	|			OR NOT &qRoomFloorIsEmpty
	|				AND ExpectedRoomMove.Ref.Room.Floor = &qRoomFloor)
	|	AND (&qRoomIsEmpty
	|			OR NOT &qRoomIsEmpty
	|				AND ExpectedRoomMove.Ref.Room = &qRoom)
	|	AND ExpectedRoomMove.Ref.AccommodationTemplate <> VALUE(Catalog.AccommodationTemplates.EmptyRef)
	|
	|GROUP BY
	|	ExpectedRoomMove.Room,
	|	ExpectedRoomMove.Ref.Room,
	|	ExpectedRoomMove.Ref.Number,
	|	ExpectedRoomMove.Ref.Customer,
	|	ExpectedRoomMove.Ref.ClientType,
	|	ExpectedRoomMove.Ref.AccommodationTemplate,
	|	CAST(ExpectedRoomMove.Ref.Remarks AS STRING(999)),
	|	CAST(ExpectedRoomMove.Ref.HousekeepingRemarks AS STRING(999)),
	|	ExpectedRoomMove.Ref.NumberOfAdults + ExpectedRoomMove.Ref.NumberOfTeenagers + ExpectedRoomMove.Ref.NumberOfChildren + ExpectedRoomMove.Ref.NumberOfInfants
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	Accommodations.Room AS Room,
	|	Accommodations.Customer AS Customer,
	|	Accommodations.AccommodationTemplate AS AccommodationTemplate,
	|	&qExpectedCheckOutClause AS Clause,
	|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants AS NumberOfCheckOutGuests
	|INTO ExpectedCheckOutGuests
	|FROM
	|	Document.Accommodation AS Accommodations
	|WHERE
	|	Accommodations.Posted
	|	AND Accommodations.AccommodationStatus.IsActive
	|	AND Accommodations.AccommodationStatus.IsInHouse
	|	AND Accommodations.AccommodationStatus.IsCheckOut
	|	AND Accommodations.CheckOutDate >= &qBegOfToday
	|	AND Accommodations.CheckOutDate <= &qEndOfToday
	|	AND (&qHotelsListIsEmpty
	|			OR NOT &qHotelsListIsEmpty
	|				AND Accommodations.Hotel IN (&qHotelsList))
	|	AND (&qParentIsEmpty
	|			OR NOT &qParentIsEmpty
	|				AND Accommodations.Room IN HIERARCHY (&qParent))
	|	AND (&qRoomTypeIsEmpty
	|			OR NOT &qRoomTypeIsEmpty
	|				AND Accommodations.RoomType IN HIERARCHY (&qRoomType))
	|	AND (&qRoomSectionIsEmpty
	|			OR NOT &qRoomSectionIsEmpty
	|				AND Accommodations.Room.RoomSection IN HIERARCHY (&qRoomSection))
	|	AND (&qRoomFloorIsEmpty
	|			OR NOT &qRoomFloorIsEmpty
	|				AND Accommodations.Room.Floor = &qRoomFloor)
	|	AND (&qRoomIsEmpty
	|			OR NOT &qRoomIsEmpty
	|				AND Accommodations.Room = &qRoom)
	|	AND Accommodations.AccommodationTemplate <> VALUE(Catalog.AccommodationTemplates.EmptyRef)
	|
	|GROUP BY
	|	Accommodations.Room,
	|	Accommodations.Customer,
	|	Accommodations.AccommodationTemplate,
	|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	Accommodations.Room AS Room,
	|	Accommodations.AccommodationTemplate AS AccommodationTemplate,
	|	&qCheckedOutClause AS Clause,
	|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants AS NumberOfCheckedOutGuests
	|INTO CheckedOutGuests
	|FROM
	|	Document.Accommodation AS Accommodations
	|WHERE
	|	Accommodations.Posted
	|	AND Accommodations.AccommodationStatus.IsActive
	|	AND NOT Accommodations.AccommodationStatus.IsInHouse
	|	AND Accommodations.AccommodationStatus.IsCheckOut
	|	AND Accommodations.CheckOutDate >= &qBegOfToday
	|	AND Accommodations.CheckOutDate <= &qEndOfToday
	|	AND (&qHotelsListIsEmpty
	|			OR NOT &qHotelsListIsEmpty
	|				AND Accommodations.Hotel IN (&qHotelsList))
	|	AND (&qParentIsEmpty
	|			OR NOT &qParentIsEmpty
	|				AND Accommodations.Room IN HIERARCHY (&qParent))
	|	AND (&qRoomTypeIsEmpty
	|			OR NOT &qRoomTypeIsEmpty
	|				AND Accommodations.RoomType IN HIERARCHY (&qRoomType))
	|	AND (&qRoomSectionIsEmpty
	|			OR NOT &qRoomSectionIsEmpty
	|				AND Accommodations.Room.RoomSection IN HIERARCHY (&qRoomSection))
	|	AND (&qRoomFloorIsEmpty
	|			OR NOT &qRoomFloorIsEmpty
	|				AND Accommodations.Room.Floor = &qRoomFloor)
	|	AND (&qRoomIsEmpty
	|			OR NOT &qRoomIsEmpty
	|				AND Accommodations.Room = &qRoom)
	|	AND Accommodations.AccommodationTemplate <> VALUE(Catalog.AccommodationTemplates.EmptyRef)
	|
	|GROUP BY
	|	Accommodations.Room,
	|	Accommodations.AccommodationTemplate,
	|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	Accommodations.Room AS Room,
	|	Accommodations.Customer AS Customer,
	|	Accommodations.AccommodationTemplate AS AccommodationTemplate,
	|	CAST(Accommodations.Remarks AS STRING(999)) AS Remarks,
	|	CAST(Accommodations.HousekeepingRemarks AS STRING(999)) AS HousekeepingRemarks,
	|	&qCheckedInClause AS Clause,
	|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants AS NumberOfCheckedInGuests
	|INTO CheckedInGuests
	|FROM
	|	Document.Accommodation AS Accommodations
	|WHERE
	|	Accommodations.Posted
	|	AND Accommodations.AccommodationStatus.IsActive
	|	AND Accommodations.AccommodationStatus.IsInHouse
	|	AND Accommodations.AccommodationStatus.IsCheckIn
	|	AND Accommodations.CheckInDate >= &qBegOfToday
	|	AND Accommodations.CheckInDate <= &qEndOfToday
	|	AND (&qHotelsListIsEmpty
	|			OR NOT &qHotelsListIsEmpty
	|				AND Accommodations.Hotel IN (&qHotelsList))
	|	AND (&qParentIsEmpty
	|			OR NOT &qParentIsEmpty
	|				AND Accommodations.Room IN HIERARCHY (&qParent))
	|	AND (&qRoomTypeIsEmpty
	|			OR NOT &qRoomTypeIsEmpty
	|				AND Accommodations.RoomType IN HIERARCHY (&qRoomType))
	|	AND (&qRoomSectionIsEmpty
	|			OR NOT &qRoomSectionIsEmpty
	|				AND Accommodations.Room.RoomSection IN HIERARCHY (&qRoomSection))
	|	AND (&qRoomFloorIsEmpty
	|			OR NOT &qRoomFloorIsEmpty
	|				AND Accommodations.Room.Floor = &qRoomFloor)
	|	AND (&qRoomIsEmpty
	|			OR NOT &qRoomIsEmpty
	|				AND Accommodations.Room = &qRoom)
	|	AND Accommodations.AccommodationTemplate <> VALUE(Catalog.AccommodationTemplates.EmptyRef)
	|
	|GROUP BY
	|	Accommodations.Room,
	|	Accommodations.Customer,
	|	Accommodations.AccommodationTemplate,
	|	CAST(Accommodations.Remarks AS STRING(999)),
	|	CAST(Accommodations.HousekeepingRemarks AS STRING(999)),
	|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	Messages.ByObject AS Room,
	|	CAST(Messages.Remarks AS STRING(999)) AS TaskRemarks
	|INTO RoomTasks
	|FROM
	|	Document.Message AS Messages
	|WHERE
	|	Messages.Posted
	|	AND NOT Messages.IsClosed
	|	AND Messages.ByObject REFS Catalog.Rooms
	|	AND (&qHotelsListIsEmpty
	|			OR NOT &qHotelsListIsEmpty
	|				AND Messages.ByObject.Owner IN (&qHotelsList))
	|	AND (Messages.ValidFromDate = &qEmptyDate
	|			OR Messages.ValidFromDate <> &qEmptyDate
	|				AND Messages.ValidFromDate <= &qToday)
	|	AND (Messages.ValidToDate = &qEmptyDate
	|			OR Messages.ValidToDate <> &qEmptyDate
	|				AND Messages.ValidToDate > &qToday)
	|
	|GROUP BY
	|	Messages.ByObject,
	|	CAST(Messages.Remarks AS STRING(999))
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	RoomBlocks.Room AS Room,
	|	RoomBlocks.RoomBlockType AS RoomBlockType,
	|	RoomBlocks.Number AS BlockNumber,
	|	CAST(RoomBlocks.Remarks AS STRING(999)) AS RoomBlockRemarks
	|INTO RoomBlocks
	|FROM
	|	Document.SetRoomBlock AS RoomBlocks
	|WHERE
	|	RoomBlocks.Posted
	|	AND (&qHotelsListIsEmpty
	|			OR NOT &qHotelsListIsEmpty
	|				AND RoomBlocks.Hotel IN (&qHotelsList))
	|	AND RoomBlocks.DateFrom <= &qToday
	|	AND (RoomBlocks.DateTo = &qEmptyDate
	|			OR RoomBlocks.DateTo <> &qEmptyDate
	|				AND RoomBlocks.DateTo > &qToday)
	|	AND (&qParentIsEmpty
	|			OR NOT &qParentIsEmpty
	|				AND RoomBlocks.Room IN HIERARCHY (&qParent))
	|	AND (&qRoomTypeIsEmpty
	|			OR NOT &qRoomTypeIsEmpty
	|				AND RoomBlocks.Room.RoomType IN HIERARCHY (&qRoomType))
	|	AND (&qRoomSectionIsEmpty
	|			OR NOT &qRoomSectionIsEmpty
	|				AND RoomBlocks.Room.RoomSection IN HIERARCHY (&qRoomSection))
	|	AND (&qRoomFloorIsEmpty
	|			OR NOT &qRoomFloorIsEmpty
	|				AND RoomBlocks.Room.Floor = &qRoomFloor)
	|	AND (&qRoomIsEmpty
	|			OR NOT &qRoomIsEmpty
	|				AND RoomBlocks.Room = &qRoom)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT DISTINCT
	|	CASE
	|		WHEN Rooms.IsFolder
	|			THEN 6
	|		ELSE 7
	|	END AS Icon,
	|	Rooms.Description AS Description,
	|	Rooms.RoomType AS RoomType,
	|	Rooms.Floor AS Floor,
	|	Rooms.RoomStatus AS RoomStatus,
	|	CASE
	|		WHEN Rooms.Ref = ExpectedRoomMoveGuests.ToRoom
	|			THEN ISNULL(ExpectedCheckInGuests.NumberOfGuestsOnArrival, 0) + ISNULL(ExpectedRoomMoveGuests.NumberOfGuests, 0)
	|		ELSE ISNULL(ExpectedCheckInGuests.NumberOfGuestsOnArrival, 0)
	|	END AS NumberOfGuestsOnArrival,
	|	ISNULL(InHouseGuests.NumberOfGuests, 0) AS NumberOfGuests,
	|	RoomStatusChangeHistory.Period AS RoomStatusLastChangeTime,
	|	CAST(Rooms.Remarks AS STRING(999)) AS Remarks,
	|	RoomTasks.TaskRemarks AS TaskRemarks,
	|	CASE
	|		WHEN ISNULL(ExpectedCheckInGuests.Remarks, """") <> """"
	|			THEN ExpectedCheckInGuests.Remarks
	|		WHEN ISNULL(CheckedInGuests.Remarks, """") <> """"
	|			THEN CheckedInGuests.Remarks
	|		WHEN Rooms.Ref = ExpectedRoomMoveGuests.ToRoom
	|				AND ISNULL(ExpectedRoomMoveGuests.Remarks, """") <> """"
	|			THEN ExpectedRoomMoveGuests.Remarks
	|		ELSE """"
	|	END AS ReceptionRemarks,
	|	CASE
	|		WHEN ISNULL(ExpectedCheckInGuests.HousekeepingRemarks, """") <> """"
	|			THEN ExpectedCheckInGuests.HousekeepingRemarks
	|		WHEN ISNULL(CheckedInGuests.HousekeepingRemarks, """") <> """"
	|			THEN CheckedInGuests.HousekeepingRemarks
	|		WHEN Rooms.Ref = ExpectedRoomMoveGuests.ToRoom
	|				AND ISNULL(ExpectedRoomMoveGuests.HousekeepingRemarks, """") <> """"
	|			THEN ExpectedRoomMoveGuests.HousekeepingRemarks
	|		ELSE """"
	|	END AS HousekeepingRemarks,
	|	CASE
	|		WHEN ISNULL(ExpectedCheckInGuests.Customer, VALUE(Catalog.Customers.EmptyRef)) <> VALUE(Catalog.Customers.EmptyRef)
	|			THEN ExpectedCheckInGuests.Customer
	|		WHEN Rooms.Ref = ExpectedRoomMoveGuests.ToRoom
	|				AND ISNULL(ExpectedRoomMoveGuests.Customer, VALUE(Catalog.Customers.EmptyRef)) <> VALUE(Catalog.Customers.EmptyRef)
	|			THEN ExpectedRoomMoveGuests.Customer
	|		WHEN ISNULL(InHouseGuests.Customer, VALUE(Catalog.Customers.EmptyRef)) <> VALUE(Catalog.Customers.EmptyRef)
	|			THEN InHouseGuests.Customer
	|		ELSE NULL
	|	END AS Customer,
	|	CASE
	|		WHEN ISNULL(ExpectedCheckInGuests.ClientType, VALUE(Catalog.ClientTypes.EmptyRef)) <> VALUE(Catalog.ClientTypes.EmptyRef)
	|			THEN ExpectedCheckInGuests.ClientType
	|		WHEN Rooms.Ref = ExpectedRoomMoveGuests.ToRoom
	|				AND ISNULL(ExpectedRoomMoveGuests.ClientType, VALUE(Catalog.ClientTypes.EmptyRef)) <> VALUE(Catalog.ClientTypes.EmptyRef)
	|			THEN ExpectedRoomMoveGuests.ClientType
	|		WHEN ISNULL(InHouseGuests.ClientType, VALUE(Catalog.ClientTypes.EmptyRef)) <> VALUE(Catalog.ClientTypes.EmptyRef)
	|			THEN InHouseGuests.ClientType
	|		ELSE NULL
	|	END AS ClientType,
	|	CASE
	|		WHEN ISNULL(ExpectedCheckInGuests.ClientType, VALUE(Catalog.ClientTypes.EmptyRef)) <> VALUE(Catalog.ClientTypes.EmptyRef)
	|			THEN ExpectedCheckInGuests.ClientType.Description
	|		WHEN Rooms.Ref = ExpectedRoomMoveGuests.ToRoom
	|				AND ISNULL(ExpectedRoomMoveGuests.ClientType, VALUE(Catalog.ClientTypes.EmptyRef)) <> VALUE(Catalog.ClientTypes.EmptyRef)
	|			THEN ExpectedRoomMoveGuests.ClientType.Description
	|		WHEN ISNULL(InHouseGuests.ClientType, VALUE(Catalog.ClientTypes.EmptyRef)) <> VALUE(Catalog.ClientTypes.EmptyRef)
	|			THEN InHouseGuests.ClientType.Description
	|		ELSE """"
	|	END AS ClientTypeDescription,
	|	CASE
	|		WHEN ISNULL(ExpectedCheckInGuests.AccommodationTemplate, VALUE(Catalog.AccommodationTemplates.EmptyRef)) <> VALUE(Catalog.AccommodationTemplates.EmptyRef)
	|			THEN ExpectedCheckInGuests.AccommodationTemplate
	|		WHEN Rooms.Ref = ExpectedRoomMoveGuests.ToRoom
	|				AND ISNULL(ExpectedRoomMoveGuests.AccommodationTemplate, VALUE(Catalog.AccommodationTemplates.EmptyRef)) <> VALUE(Catalog.AccommodationTemplates.EmptyRef)
	|			THEN ExpectedRoomMoveGuests.AccommodationTemplate
	|		ELSE NULL
	|	END AS AccommodationTemplate,
	|	CASE
	|		WHEN ISNULL(ExpectedCheckInGuests.AccommodationTemplate, VALUE(Catalog.AccommodationTemplates.EmptyRef)) <> VALUE(Catalog.AccommodationTemplates.EmptyRef)
	|			THEN ExpectedCheckInGuests.AccommodationTemplate.Description
	|		WHEN Rooms.Ref = ExpectedRoomMoveGuests.ToRoom
	|				AND ISNULL(ExpectedRoomMoveGuests.AccommodationTemplate, VALUE(Catalog.AccommodationTemplates.EmptyRef)) <> VALUE(Catalog.AccommodationTemplates.EmptyRef)
	|			THEN ExpectedRoomMoveGuests.AccommodationTemplate.Description
	|		ELSE """"
	|	END AS AccommodationTemplateDescription,
	|	CASE
	|		WHEN ISNULL(ExpectedCheckInGuests.DocumentNumber, """") <> """"
	|			THEN ExpectedCheckInGuests.DocumentNumber
	|		WHEN Rooms.Ref = ExpectedRoomMoveGuests.ToRoom
	|				AND ISNULL(ExpectedRoomMoveGuests.DocumentNumber, """") <> """"
	|			THEN ExpectedRoomMoveGuests.DocumentNumber
	|		WHEN ISNULL(InHouseGuests.DocumentNumber, """") <> """"
	|			THEN InHouseGuests.DocumentNumber
	|		ELSE NULL
	|	END AS DocumentNumber,
	|	CASE
	|		WHEN ISNULL(ExpectedCheckInGuests.DocumentNumber, """") <> """"
	|			THEN ExpectedCheckInGuests.Clause
	|		WHEN Rooms.Ref = ExpectedRoomMoveGuests.ToRoom
	|				AND ISNULL(ExpectedRoomMoveGuests.DocumentNumber, """") <> """"
	|			THEN ExpectedRoomMoveGuests.Clause
	|		WHEN ISNULL(InHouseGuests.DocumentNumber, """") <> """"
	|			THEN InHouseGuests.Clause
	|		ELSE NULL
	|	END AS DocumentClause,
	|	Rooms.HasRoomBlocks AS HasRoomBlocks,
	|	RoomBlocks.RoomBlockType AS RoomBlockType,
	|	RoomBlocks.RoomBlockRemarks AS RoomBlockRemarks,
	|	Rooms.StopSale AS StopSale,
	|	Rooms.IsVirtual AS IsVirtual,
	|	CAST(Rooms.RoomPropertiesCodes AS STRING(999)) AS RoomPropertiesCodes,
	|	"""" AS Condition,
	|	ExpectedCheckInGuests.Clause AS ExpectedCheckInClause,
	|	CheckedInGuests.Clause AS CheckedInClause,
	|	ExpectedRoomMoveGuests.Clause AS ExpectedRoomMoveClause,
	|	InHouseGuests.Clause AS InHouseClause,
	|	ExpectedCheckOutGuests.Clause AS ExpectedCheckOutClause,
	|	CheckedOutGuests.Clause AS CheckedOutClause,
	|	Rooms.SortCode AS SortCode,
	|	Rooms.IsFolder AS IsFolder,
	|	ExpectedRoomMoveGuests.FromRoom AS FromRoom,
	|	ExpectedRoomMoveGuests.ToRoom AS ToRoom,
	|	Rooms.Ref AS Ref
	|FROM
	|	Catalog.Rooms AS Rooms
	|		LEFT JOIN InformationRegister.RoomStatusChangeHistory.SliceLast(
	|				&qToday,
	|				&qHotelsListIsEmpty
	|					OR NOT &qHotelsListIsEmpty
	|						AND Room.Owner IN (&qHotelsList)) AS RoomStatusChangeHistory
	|		ON (RoomStatusChangeHistory.Room = Rooms.Ref)
	|		LEFT JOIN ExpectedCheckInGuests AS ExpectedCheckInGuests
	|		ON (ExpectedCheckInGuests.Room = Rooms.Ref)
	|		LEFT JOIN CheckedInGuests AS CheckedInGuests
	|		ON (CheckedInGuests.Room = Rooms.Ref)
	|		LEFT JOIN ExpectedRoomMoveGuests AS ExpectedRoomMoveGuests
	|		ON (ExpectedRoomMoveGuests.FromRoom = Rooms.Ref
	|				OR ExpectedRoomMoveGuests.ToRoom = Rooms.Ref)
	|		LEFT JOIN InHouseGuests AS InHouseGuests
	|		ON (InHouseGuests.Room = Rooms.Ref)
	|		LEFT JOIN ExpectedCheckOutGuests AS ExpectedCheckOutGuests
	|		ON (ExpectedCheckOutGuests.Room = Rooms.Ref)
	|		LEFT JOIN CheckedOutGuests AS CheckedOutGuests
	|		ON (CheckedOutGuests.Room = Rooms.Ref)
	|		LEFT JOIN RoomTasks AS RoomTasks
	|		ON (RoomTasks.Room = Rooms.Ref)
	|		LEFT JOIN RoomBlocks AS RoomBlocks
	|		ON (RoomBlocks.Room = Rooms.Ref)
	|		LEFT JOIN StopSales AS StopSales
	|		ON (StopSales.Room = Rooms.Ref)
	|WHERE
	|	NOT Rooms.DeletionMark
	|	AND Rooms.OperationStartDate < &qEndOfToday
	|	AND (Rooms.OperationEndDate = DATETIME(1, 1, 1)
	|			OR Rooms.OperationEndDate > &qBegOfToday)
	|	AND (&qHotelsListIsEmpty
	|			OR NOT &qHotelsListIsEmpty
	|				AND Rooms.Owner IN (&qHotelsList))
	|	AND (&qParentIsEmpty
	|			OR NOT &qParentIsEmpty
	|				AND Rooms.Ref IN HIERARCHY (&qParent))
	|	AND (&qRoomTypeIsEmpty
	|			OR NOT &qRoomTypeIsEmpty
	|				AND Rooms.RoomType IN HIERARCHY (&qRoomType))
	|	AND (&qRoomSectionIsEmpty
	|			OR NOT &qRoomSectionIsEmpty
	|				AND Rooms.RoomSection IN HIERARCHY (&qRoomSection))
	|	AND (&qRoomFloorIsEmpty
	|			OR NOT &qRoomFloorIsEmpty
	|				AND Rooms.Floor = &qRoomFloor)
	|	AND (&qRoomIsEmpty
	|			OR NOT &qRoomIsEmpty
	|				AND Rooms.Ref = &qRoom)
	|	AND (&qRoomsListIsEmpty
	|			OR NOT &qRoomsListIsEmpty
	|				AND Rooms.Ref IN (&qRoomsList))
	|	AND Rooms.RoomStatus IN(&qRoomStatusesList)
	|	AND (NOT &qExpectedCheckInOnly
	|			OR &qExpectedCheckInOnly
	|				AND ExpectedCheckInGuests.NumberOfGuestsOnArrival > 0)
	|	AND (NOT &qCheckedInOnly
	|			OR &qCheckedInOnly
	|				AND CheckedInGuests.NumberOfCheckedInGuests > 0)
	|	AND (NOT &qExpectedCheckOutOnly
	|			OR &qExpectedCheckOutOnly
	|				AND ExpectedCheckOutGuests.NumberOfCheckOutGuests > 0)
	|	AND (NOT &qCheckedOutOnly
	|			OR &qCheckedOutOnly
	|				AND CheckedOutGuests.NumberOfCheckedOutGuests > 0)
	|	AND (NOT &qCheckedRoomBlock
	|			OR &qCheckedRoomBlock
	|				AND RoomBlocks.Room <> VALUE(Document.SetRoomBlock.EmptyRef))
	|	AND (NOT &qCheckedStopSales
	|			OR &qCheckedStopSales
	|				AND StopSales.Room <> VALUE(Catalog.Rooms.EmptyRef))
	|
	|ORDER BY
	|	Rooms.Owner.SortCode,
	|	Rooms.Owner.Code,
	|	Rooms.SortCode,
	|	HousekeepingRemarks DESC,
	|	ClientTypeDescription DESC,
	|	NumberOfGuestsOnArrival DESC,
	|	NumberOfGuests DESC";
	#КонецУдаления
	vQry.SetParameter("qHotelsListIsEmpty", ?(vHotelsList.Count() > 0, False, True));
	vQry.SetParameter("qHotelsList", vHotelsList);
	vQry.SetParameter("qToday", CurrentSessionDate());
	vQry.SetParameter("qBegOfToday", BegOfDay(CurrentSessionDate()));
	vQry.SetParameter("qEndOfToday", EndOfDay(CurrentSessionDate()));
	vQry.SetParameter("qEmptyDate", '00010101');
	vQry.SetParameter("qParentIsEmpty", Not ValueIsFilled(SelRoomsFolder));
	vQry.SetParameter("qParent", SelRoomsFolder);
	vQry.SetParameter("qRoomTypeIsEmpty", Not ValueIsFilled(SelRoomType));
	vQry.SetParameter("qRoomType", SelRoomType);
	vQry.SetParameter("qRoomSectionIsEmpty", Not ValueIsFilled(SelRoomSection));
	vQry.SetParameter("qRoomSection", SelRoomSection);
	vQry.SetParameter("qRoomIsEmpty", Not ValueIsFilled(SelRoom));
	vQry.SetParameter("qRoom", SelRoom);
	vQry.SetParameter("qRoomFloorIsEmpty", IsBlankString(SelFloor));
	vQry.SetParameter("qRoomFloor", TrimAll(SelFloor));
	vQry.SetParameter("qRoomStatusesList", vStatusesList);
	vQry.SetParameter("qExpectedCheckInOnly", SelShowPlannedCheckIn);
	vQry.SetParameter("qCheckedInOnly", SelShowCheckedIn);
	vQry.SetParameter("qCheckedOutOnly", SelShowCheckedOut);
	vQry.SetParameter("qExpectedCheckOutOnly", SelShowPlannedCheckOut);
	vQry.SetParameter("qCheckedRoomBlock", SelShowRoomsBlock);
	vQry.SetParameter("qCheckedStopSales", SelShowRoomsStopSale);
	If SelShowRoomsWithTasks Or SelShowRoomsWithDiscrepancies Then
		vQry.SetParameter("qRoomsListIsEmpty", False);
	Else
		vQry.SetParameter("qRoomsListIsEmpty", ?(vRoomsList.Count() > 0, False, True));
	EndIf;
	vQry.SetParameter("qRoomsList", vRoomsList);
	vQry.SetParameter("qExpectedCheckInClause", NStr("en='Arrival today'; ru='На заезде'; de='Anreise heute'"));
	vQry.SetParameter("qCheckedInClause", NStr("en='Checked-in'; ru='Заехал'; de='Checked-in'"));
	vQry.SetParameter("qInHouseClause", NStr("en='In house'; ru='Занят'; de='In house'"));
	vQry.SetParameter("qExpectedCheckOutClause", NStr("en='Departure today'; ru='На выезде'; de='Abreise heute'"));
	vQry.SetParameter("qCheckedOutClause", NStr("en='Checked-out'; ru='Выехал'; de='Checked-out'"));
	vQry.SetParameter("qExpectedRoomMoveClause", NStr("en='Moving'; ru='Переселение'; de='Umzug'"));
	vRooms = vQry.Execute().Unload();
	
	vVacantClause = NStr("en='Vacant'; ru='Свободен'; de='Leer'");
	
	// Initialize table of total rooms by room statuses
	vRoomStatusesTotals = New ValueTable();
	vRoomStatusesTotals.Columns.Add("RoomStatus", cmGetCatalogTypeDescription("RoomStatuses"));
	vRoomStatusesTotals.Columns.Add("Quantity", cmGetNumberTypeDescription(6, 0));
	
	// Fill form table
	vParents = New ValueTable();
	vParents.Columns.Add("Item");
	vParents.Columns.Add("Ref");
	
	// Get regular operations
	#Вставка
	Если НомернойФонд.Пустая() Тогда
		vRegOprQry = New Query();
		vRegOprQry.Text = 
		"SELECT
		|	Hotels.Ref AS Hotel,
		|	Hotels.RegularOperationGroup AS RegularOperationGroup
		|INTO HotelsWithRegularOperations
		|FROM
		|	Catalog.Hotels AS Hotels
		|WHERE
		|	(&qHotelsListIsEmpty
		|			OR NOT &qHotelsListIsEmpty
		|				AND Hotels.Ref IN (&qHotelsList))
		|	AND NOT Hotels.DeletionMark
		|	AND NOT Hotels.IsFolder
		|	AND NOT Hotels.RegularOperationGroup.Code IS NULL
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT DISTINCT Разрешенные
		|	RoomInventoryBalance.Hotel AS Hotel,
		|	RoomInventoryBalance.Hotel.Code AS HotelCode,
		|	RoomInventoryBalance.Room AS Room,
		|	RoomInventoryBalance.Room.SortCode AS RoomSortCode,
		|	RoomInventoryBalance.TotalBedsBalance AS TotalBedsBalance,
		|	RegularOperations.RegularOperation AS RegularOperation,
		|	RegularOperations.RegularOperation.Code AS RegularOperationCode,
		|	CASE
		|		WHEN RegularOperations.RegularOperation IS NOT NULL 
		|			THEN RegularOperations.RegularOperation.SortCode
		|		ELSE 999999
		|	END AS RegularOperationSortCode,
		|	HotelsWithRegularOperations.RegularOperationGroup AS RegularOperationGroup
		|FROM
		|	AccumulationRegister.RoomInventory.Balance(
		|			&qEndOfToday,
		|			(&qHotelsListIsEmpty
		|				OR NOT &qHotelsListIsEmpty
		|					AND Hotel IN (&qHotelsList))
		|				AND (&qParentIsEmpty
		|					OR NOT &qParentIsEmpty
		|						AND Room IN HIERARCHY (&qParent))
		|				AND (&qRoomTypeIsEmpty
		|					OR NOT &qRoomTypeIsEmpty
		|						AND RoomType IN HIERARCHY (&qRoomType))
		|				AND (&qRoomSectionIsEmpty
		|					OR NOT &qRoomSectionIsEmpty
		|						AND Room.RoomSection IN HIERARCHY (&qRoomSection))
		|				AND (&qRoomIsEmpty
		|					OR NOT &qRoomIsEmpty
		|						AND Room = &qRoom)
		|				AND (&qRoomsListIsEmpty
		|					OR NOT &qRoomsListIsEmpty
		|						AND Room IN (&qRoomsList))
		|				AND Room.RoomStatus IN (&qRoomStatusesList)
		|				AND (&qRoomFloorIsEmpty
		|					OR NOT &qRoomFloorIsEmpty
		|						AND Room.Floor = &qRoomFloor)) AS RoomInventoryBalance
		|		LEFT JOIN AccumulationRegister.RoomInventory AS InHousePersons
		|		ON RoomInventoryBalance.Room = InHousePersons.Room
		|			AND (InHousePersons.RecordType = &qExpense)
		|			AND (InHousePersons.IsInHouse)
		|			AND (InHousePersons.PeriodFrom < &qBegOfToday)
		|			AND (InHousePersons.PeriodTo > &qEndOfToday)
		|			AND (InHousePersons.Period = InHousePersons.PeriodFrom)
		|		LEFT JOIN AccumulationRegister.RoomInventory AS CheckedOutGuests
		|		ON RoomInventoryBalance.Room = CheckedOutGuests.Room
		|			AND (CheckedOutGuests.RecordType = &qReceipt)
		|			AND (CheckedOutGuests.IsCheckOut)
		|			AND (CheckedOutGuests.PeriodTo = CheckedOutGuests.CheckOutDate)
		|			AND (CheckedOutGuests.PeriodTo > &qBegOfToday)
		|			AND (CheckedOutGuests.PeriodTo <= &qEndOfToday)
		|			AND (CheckedOutGuests.Period = CheckedOutGuests.PeriodTo)
		|		LEFT JOIN AccumulationRegister.RoomInventory AS CheckedInPersons
		|		ON RoomInventoryBalance.Room = CheckedInPersons.Room
		|			AND (CheckedInPersons.RecordType = &qExpense)
		|			AND (CheckedInPersons.IsInHouse)
		|			AND (CheckedInPersons.PeriodFrom = CheckedInPersons.CheckInDate)
		|			AND (CheckedInPersons.PeriodFrom >= &qBegOfToday)
		|			AND (CheckedInPersons.PeriodFrom < &qEndOfToday)
		|			AND (CheckedInPersons.Period = CheckedInPersons.PeriodFrom)
		|		LEFT JOIN (SELECT
		|			RoomInventoryLastCheckedOutGuests.Room AS Room,
		|			MAX(RoomInventoryLastCheckedOutGuests.PeriodTo) AS LastCheckOutDate
		|		FROM
		|			AccumulationRegister.RoomInventory AS RoomInventoryLastCheckedOutGuests
		|		WHERE
		|			RoomInventoryLastCheckedOutGuests.RecordType = &qReceipt
		|			AND RoomInventoryLastCheckedOutGuests.IsCheckOut
		|			AND RoomInventoryLastCheckedOutGuests.CheckOutDate <= &qBegOfToday
		|		
		|		GROUP BY
		|			RoomInventoryLastCheckedOutGuests.Room) AS LastCheckedOutGuests
		|		ON RoomInventoryBalance.Room = LastCheckedOutGuests.Room
		|		INNER JOIN HotelsWithRegularOperations AS HotelsWithRegularOperations
		|		ON RoomInventoryBalance.Hotel = HotelsWithRegularOperations.Hotel
		|		LEFT JOIN Catalog.RegularOperationGroups.RegularOperations AS RegularOperations
		|		ON (RegularOperations.Ref = HotelsWithRegularOperations.RegularOperationGroup)
		|			AND (RegularOperations.PerformWhenRoomIsBusy
		|					AND DATEDIFF(&qBegOfToday, BEGINOFPERIOD(InHousePersons.PeriodFrom, DAY), DAY) / RegularOperations.RegularOperationFrequency = (CAST(DATEDIFF(&qBegOfToday, BEGINOFPERIOD(InHousePersons.PeriodFrom, DAY), DAY) / RegularOperations.RegularOperationFrequency AS NUMBER(17, 0)))
		|					AND DATEDIFF(&qBegOfToday, BEGINOFPERIOD(InHousePersons.PeriodFrom, DAY), DAY) <> 0
		|				OR RegularOperations.PerformWhenRoomIsBusy
		|					AND RegularOperations.PerformOnCheckInDay
		|					AND CheckedInPersons.Recorder IS NOT NULL 
		|				OR RegularOperations.PerformWhenRoomIsBusy
		|					AND RegularOperations.PerformOnCheckOutDay
		|					AND CheckedOutGuests.Recorder IS NOT NULL 
		|				OR RegularOperations.PerformWhenRoomIsFree
		|					AND InHousePersons.Recorder IS NULL
		|					AND CheckedInPersons.Recorder IS NULL
		|					AND CheckedOutGuests.Recorder IS NULL
		|					AND (RegularOperations.RegularOperationFrequency = 0
		|						OR RegularOperations.RegularOperationFrequency = 1
		|						OR RegularOperations.RegularOperationFrequency > 1
		|							AND DATEDIFF(&qBegOfToday, BEGINOFPERIOD(LastCheckedOutGuests.LastCheckOutDate, DAY), DAY) / RegularOperations.RegularOperationFrequency = (CAST(DATEDIFF(&qBegOfToday, BEGINOFPERIOD(LastCheckedOutGuests.LastCheckOutDate, DAY), DAY) / RegularOperations.RegularOperationFrequency AS NUMBER(17, 0)))
		|							AND DATEDIFF(&qBegOfToday, BEGINOFPERIOD(LastCheckedOutGuests.LastCheckOutDate, DAY), DAY) <> 0))
		|			AND (NOT RegularOperations.DoNotPerformOnWeekends
		|				OR RegularOperations.DoNotPerformOnWeekends
		|					AND WEEKDAY(&qBegOfToday) < 6)
		|			AND (RegularOperations.RoomType = &qEmptyRoomType
		|				OR RegularOperations.RoomType <> &qEmptyRoomType
		|					AND RoomInventoryBalance.RoomType = RegularOperations.RoomType
		|				OR RegularOperations.RoomType <> &qEmptyRoomType
		|					AND RoomInventoryBalance.RoomType.Parent <> &qEmptyRoomType
		|					AND RoomInventoryBalance.RoomType.Parent = RegularOperations.RoomType)
		|			AND (RegularOperations.RoomRate = &qEmptyRoomRate
		|				OR RegularOperations.RoomRate <> &qEmptyRoomRate
		|					AND NOT InHousePersons.Recorder.RoomRate IS NULL
		|					AND InHousePersons.Recorder.RoomRate <> &qEmptyRoomRate
		|					AND (InHousePersons.Recorder.RoomRate = RegularOperations.RoomRate
		|						OR InHousePersons.Recorder.RoomRate.Parent = RegularOperations.RoomRate
		|						OR InHousePersons.Recorder.RoomRate.Parent.Parent = RegularOperations.RoomRate))
		|WHERE
		|	RoomInventoryBalance.TotalBedsBalance > 0
		|	AND NOT RegularOperations.RegularOperation.Code IS NULL
		|
		|ORDER BY
		|	HotelCode,
		|	RoomSortCode,
		|	RegularOperationSortCode";
		
	Иначе
		vRegOprQry = New Query();
		vRegOprQry.МенеджерВременныхТаблиц = МенеджерВТ;		
		vRegOprQry.Text = 
		"SELECT
		|	Hotels.Ref AS Hotel,
		|	Hotels.RegularOperationGroup AS RegularOperationGroup
		|INTO HotelsWithRegularOperations
		|FROM
		|	Catalog.Hotels AS Hotels
		|WHERE
		|	(&qHotelsListIsEmpty
		|			OR NOT &qHotelsListIsEmpty
		|				AND Hotels.Ref IN (&qHotelsList))
		|	AND NOT Hotels.DeletionMark
		|	AND NOT Hotels.IsFolder
		|	AND NOT Hotels.RegularOperationGroup.Code IS NULL
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT DISTINCT Разрешенные
		|	RoomInventoryBalance.Hotel AS Hotel,
		|	RoomInventoryBalance.Hotel.Code AS HotelCode,
		|	RoomInventoryBalance.Room AS Room,
		|	RoomInventoryBalance.Room.SortCode AS RoomSortCode,
		|	RoomInventoryBalance.TotalBedsBalance AS TotalBedsBalance,
		|	RegularOperations.RegularOperation AS RegularOperation,
		|	RegularOperations.RegularOperation.Code AS RegularOperationCode,
		|	CASE
		|		WHEN RegularOperations.RegularOperation IS NOT NULL 
		|			THEN RegularOperations.RegularOperation.SortCode
		|		ELSE 999999
		|	END AS RegularOperationSortCode,
		|	HotelsWithRegularOperations.RegularOperationGroup AS RegularOperationGroup
		|FROM
		|	AccumulationRegister.RoomInventory.Balance(
		|			&qEndOfToday, Room В (Выбрать Т.Номер Из ВТ_Номера как Т) и
		|			(&qHotelsListIsEmpty
		|				OR NOT &qHotelsListIsEmpty
		|					AND Hotel IN (&qHotelsList))
		|				AND (&qParentIsEmpty
		|					OR NOT &qParentIsEmpty
		|						AND Room IN HIERARCHY (&qParent))
		|				AND (&qRoomTypeIsEmpty
		|					OR NOT &qRoomTypeIsEmpty
		|						AND RoomType IN HIERARCHY (&qRoomType))
		|				AND (&qRoomSectionIsEmpty
		|					OR NOT &qRoomSectionIsEmpty
		|						AND Room.RoomSection IN HIERARCHY (&qRoomSection))
		|				AND (&qRoomIsEmpty
		|					OR NOT &qRoomIsEmpty
		|						AND Room = &qRoom)
		|				AND (&qRoomsListIsEmpty
		|					OR NOT &qRoomsListIsEmpty
		|						AND Room IN (&qRoomsList))
		|				AND Room.RoomStatus IN (&qRoomStatusesList)
		|				AND (&qRoomFloorIsEmpty
		|					OR NOT &qRoomFloorIsEmpty
		|						AND Room.Floor = &qRoomFloor)) AS RoomInventoryBalance
		|		LEFT JOIN AccumulationRegister.RoomInventory AS InHousePersons
		|		ON RoomInventoryBalance.Room = InHousePersons.Room
		|			AND (InHousePersons.RecordType = &qExpense)
		|			AND (InHousePersons.IsInHouse)
		|			AND (InHousePersons.PeriodFrom < &qBegOfToday)
		|			AND (InHousePersons.PeriodTo > &qEndOfToday)
		|			AND (InHousePersons.Period = InHousePersons.PeriodFrom)
		|		LEFT JOIN AccumulationRegister.RoomInventory AS CheckedOutGuests
		|		ON RoomInventoryBalance.Room = CheckedOutGuests.Room
		|			AND (CheckedOutGuests.RecordType = &qReceipt)
		|			AND (CheckedOutGuests.IsCheckOut)
		|			AND (CheckedOutGuests.PeriodTo = CheckedOutGuests.CheckOutDate)
		|			AND (CheckedOutGuests.PeriodTo > &qBegOfToday)
		|			AND (CheckedOutGuests.PeriodTo <= &qEndOfToday)
		|			AND (CheckedOutGuests.Period = CheckedOutGuests.PeriodTo)
		|		LEFT JOIN AccumulationRegister.RoomInventory AS CheckedInPersons
		|		ON RoomInventoryBalance.Room = CheckedInPersons.Room
		|			AND (CheckedInPersons.RecordType = &qExpense)
		|			AND (CheckedInPersons.IsInHouse)
		|			AND (CheckedInPersons.PeriodFrom = CheckedInPersons.CheckInDate)
		|			AND (CheckedInPersons.PeriodFrom >= &qBegOfToday)
		|			AND (CheckedInPersons.PeriodFrom < &qEndOfToday)
		|			AND (CheckedInPersons.Period = CheckedInPersons.PeriodFrom)
		|		LEFT JOIN (SELECT
		|			RoomInventoryLastCheckedOutGuests.Room AS Room,
		|			MAX(RoomInventoryLastCheckedOutGuests.PeriodTo) AS LastCheckOutDate
		|		FROM
		|			AccumulationRegister.RoomInventory AS RoomInventoryLastCheckedOutGuests
		|		WHERE
		|			RoomInventoryLastCheckedOutGuests.RecordType = &qReceipt
		|			AND RoomInventoryLastCheckedOutGuests.IsCheckOut
		|			AND RoomInventoryLastCheckedOutGuests.CheckOutDate <= &qBegOfToday
		|		
		|		GROUP BY
		|			RoomInventoryLastCheckedOutGuests.Room) AS LastCheckedOutGuests
		|		ON RoomInventoryBalance.Room = LastCheckedOutGuests.Room
		|		INNER JOIN HotelsWithRegularOperations AS HotelsWithRegularOperations
		|		ON RoomInventoryBalance.Hotel = HotelsWithRegularOperations.Hotel
		|		LEFT JOIN Catalog.RegularOperationGroups.RegularOperations AS RegularOperations
		|		ON (RegularOperations.Ref = HotelsWithRegularOperations.RegularOperationGroup)
		|			AND (RegularOperations.PerformWhenRoomIsBusy
		|					AND DATEDIFF(&qBegOfToday, BEGINOFPERIOD(InHousePersons.PeriodFrom, DAY), DAY) / RegularOperations.RegularOperationFrequency = (CAST(DATEDIFF(&qBegOfToday, BEGINOFPERIOD(InHousePersons.PeriodFrom, DAY), DAY) / RegularOperations.RegularOperationFrequency AS NUMBER(17, 0)))
		|					AND DATEDIFF(&qBegOfToday, BEGINOFPERIOD(InHousePersons.PeriodFrom, DAY), DAY) <> 0
		|				OR RegularOperations.PerformWhenRoomIsBusy
		|					AND RegularOperations.PerformOnCheckInDay
		|					AND CheckedInPersons.Recorder IS NOT NULL 
		|				OR RegularOperations.PerformWhenRoomIsBusy
		|					AND RegularOperations.PerformOnCheckOutDay
		|					AND CheckedOutGuests.Recorder IS NOT NULL 
		|				OR RegularOperations.PerformWhenRoomIsFree
		|					AND InHousePersons.Recorder IS NULL
		|					AND CheckedInPersons.Recorder IS NULL
		|					AND CheckedOutGuests.Recorder IS NULL
		|					AND (RegularOperations.RegularOperationFrequency = 0
		|						OR RegularOperations.RegularOperationFrequency = 1
		|						OR RegularOperations.RegularOperationFrequency > 1
		|							AND DATEDIFF(&qBegOfToday, BEGINOFPERIOD(LastCheckedOutGuests.LastCheckOutDate, DAY), DAY) / RegularOperations.RegularOperationFrequency = (CAST(DATEDIFF(&qBegOfToday, BEGINOFPERIOD(LastCheckedOutGuests.LastCheckOutDate, DAY), DAY) / RegularOperations.RegularOperationFrequency AS NUMBER(17, 0)))
		|							AND DATEDIFF(&qBegOfToday, BEGINOFPERIOD(LastCheckedOutGuests.LastCheckOutDate, DAY), DAY) <> 0))
		|			AND (NOT RegularOperations.DoNotPerformOnWeekends
		|				OR RegularOperations.DoNotPerformOnWeekends
		|					AND WEEKDAY(&qBegOfToday) < 6)
		|			AND (RegularOperations.RoomType = &qEmptyRoomType
		|				OR RegularOperations.RoomType <> &qEmptyRoomType
		|					AND RoomInventoryBalance.RoomType = RegularOperations.RoomType
		|				OR RegularOperations.RoomType <> &qEmptyRoomType
		|					AND RoomInventoryBalance.RoomType.Parent <> &qEmptyRoomType
		|					AND RoomInventoryBalance.RoomType.Parent = RegularOperations.RoomType)
		|			AND (RegularOperations.RoomRate = &qEmptyRoomRate
		|				OR RegularOperations.RoomRate <> &qEmptyRoomRate
		|					AND NOT InHousePersons.Recorder.RoomRate IS NULL
		|					AND InHousePersons.Recorder.RoomRate <> &qEmptyRoomRate
		|					AND (InHousePersons.Recorder.RoomRate = RegularOperations.RoomRate
		|						OR InHousePersons.Recorder.RoomRate.Parent = RegularOperations.RoomRate
		|						OR InHousePersons.Recorder.RoomRate.Parent.Parent = RegularOperations.RoomRate))
		|WHERE
		|	RoomInventoryBalance.TotalBedsBalance > 0
		|	AND NOT RegularOperations.RegularOperation.Code IS NULL
		|
		|ORDER BY
		|	HotelCode,
		|	RoomSortCode,
		|	RegularOperationSortCode";
	КонецЕсли;
	#КонецВставки
	
	#Удаление
	vRegOprQry = New Query();
	vRegOprQry.Text = 
	"SELECT
	|	Hotels.Ref AS Hotel,
	|	Hotels.RegularOperationGroup AS RegularOperationGroup
	|INTO HotelsWithRegularOperations
	|FROM
	|	Catalog.Hotels AS Hotels
	|WHERE
	|	(&qHotelsListIsEmpty
	|			OR NOT &qHotelsListIsEmpty
	|				AND Hotels.Ref IN (&qHotelsList))
	|	AND NOT Hotels.DeletionMark
	|	AND NOT Hotels.IsFolder
	|	AND NOT Hotels.RegularOperationGroup.Code IS NULL
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT DISTINCT
	|	RoomInventoryBalance.Hotel AS Hotel,
	|	RoomInventoryBalance.Hotel.Code AS HotelCode,
	|	RoomInventoryBalance.Room AS Room,
	|	RoomInventoryBalance.Room.SortCode AS RoomSortCode,
	|	RoomInventoryBalance.TotalBedsBalance AS TotalBedsBalance,
	|	RegularOperations.RegularOperation AS RegularOperation,
	|	RegularOperations.RegularOperation.Code AS RegularOperationCode,
	|	CASE
	|		WHEN RegularOperations.RegularOperation IS NOT NULL 
	|			THEN RegularOperations.RegularOperation.SortCode
	|		ELSE 999999
	|	END AS RegularOperationSortCode,
	|	HotelsWithRegularOperations.RegularOperationGroup AS RegularOperationGroup
	|FROM
	|	AccumulationRegister.RoomInventory.Balance(
	|			&qEndOfToday,
	|			(&qHotelsListIsEmpty
	|				OR NOT &qHotelsListIsEmpty
	|					AND Hotel IN (&qHotelsList))
	|				AND (&qParentIsEmpty
	|					OR NOT &qParentIsEmpty
	|						AND Room IN HIERARCHY (&qParent))
	|				AND (&qRoomTypeIsEmpty
	|					OR NOT &qRoomTypeIsEmpty
	|						AND RoomType IN HIERARCHY (&qRoomType))
	|				AND (&qRoomSectionIsEmpty
	|					OR NOT &qRoomSectionIsEmpty
	|						AND Room.RoomSection IN HIERARCHY (&qRoomSection))
	|				AND (&qRoomIsEmpty
	|					OR NOT &qRoomIsEmpty
	|						AND Room = &qRoom)
	|				AND (&qRoomsListIsEmpty
	|					OR NOT &qRoomsListIsEmpty
	|						AND Room IN (&qRoomsList))
	|				AND Room.RoomStatus IN (&qRoomStatusesList)
	|				AND (&qRoomFloorIsEmpty
	|					OR NOT &qRoomFloorIsEmpty
	|						AND Room.Floor = &qRoomFloor)) AS RoomInventoryBalance
	|		LEFT JOIN AccumulationRegister.RoomInventory AS InHousePersons
	|		ON RoomInventoryBalance.Room = InHousePersons.Room
	|			AND (InHousePersons.RecordType = &qExpense)
	|			AND (InHousePersons.IsInHouse)
	|			AND (InHousePersons.PeriodFrom < &qBegOfToday)
	|			AND (InHousePersons.PeriodTo > &qEndOfToday)
	|			AND (InHousePersons.Period = InHousePersons.PeriodFrom)
	|		LEFT JOIN AccumulationRegister.RoomInventory AS CheckedOutGuests
	|		ON RoomInventoryBalance.Room = CheckedOutGuests.Room
	|			AND (CheckedOutGuests.RecordType = &qReceipt)
	|			AND (CheckedOutGuests.IsCheckOut)
	|			AND (CheckedOutGuests.PeriodTo = CheckedOutGuests.CheckOutDate)
	|			AND (CheckedOutGuests.PeriodTo > &qBegOfToday)
	|			AND (CheckedOutGuests.PeriodTo <= &qEndOfToday)
	|			AND (CheckedOutGuests.Period = CheckedOutGuests.PeriodTo)
	|		LEFT JOIN AccumulationRegister.RoomInventory AS CheckedInPersons
	|		ON RoomInventoryBalance.Room = CheckedInPersons.Room
	|			AND (CheckedInPersons.RecordType = &qExpense)
	|			AND (CheckedInPersons.IsInHouse)
	|			AND (CheckedInPersons.PeriodFrom = CheckedInPersons.CheckInDate)
	|			AND (CheckedInPersons.PeriodFrom >= &qBegOfToday)
	|			AND (CheckedInPersons.PeriodFrom < &qEndOfToday)
	|			AND (CheckedInPersons.Period = CheckedInPersons.PeriodFrom)
	|		LEFT JOIN (SELECT
	|			RoomInventoryLastCheckedOutGuests.Room AS Room,
	|			MAX(RoomInventoryLastCheckedOutGuests.PeriodTo) AS LastCheckOutDate
	|		FROM
	|			AccumulationRegister.RoomInventory AS RoomInventoryLastCheckedOutGuests
	|		WHERE
	|			RoomInventoryLastCheckedOutGuests.RecordType = &qReceipt
	|			AND RoomInventoryLastCheckedOutGuests.IsCheckOut
	|			AND RoomInventoryLastCheckedOutGuests.CheckOutDate <= &qBegOfToday
	|		
	|		GROUP BY
	|			RoomInventoryLastCheckedOutGuests.Room) AS LastCheckedOutGuests
	|		ON RoomInventoryBalance.Room = LastCheckedOutGuests.Room
	|		INNER JOIN HotelsWithRegularOperations AS HotelsWithRegularOperations
	|		ON RoomInventoryBalance.Hotel = HotelsWithRegularOperations.Hotel
	|		LEFT JOIN Catalog.RegularOperationGroups.RegularOperations AS RegularOperations
	|		ON (RegularOperations.Ref = HotelsWithRegularOperations.RegularOperationGroup)
	|			AND (RegularOperations.PerformWhenRoomIsBusy
	|					AND DATEDIFF(&qBegOfToday, BEGINOFPERIOD(InHousePersons.PeriodFrom, DAY), DAY) / RegularOperations.RegularOperationFrequency = (CAST(DATEDIFF(&qBegOfToday, BEGINOFPERIOD(InHousePersons.PeriodFrom, DAY), DAY) / RegularOperations.RegularOperationFrequency AS NUMBER(17, 0)))
	|					AND DATEDIFF(&qBegOfToday, BEGINOFPERIOD(InHousePersons.PeriodFrom, DAY), DAY) <> 0
	|				OR RegularOperations.PerformWhenRoomIsBusy
	|					AND RegularOperations.PerformOnCheckInDay
	|					AND CheckedInPersons.Recorder IS NOT NULL 
	|				OR RegularOperations.PerformWhenRoomIsBusy
	|					AND RegularOperations.PerformOnCheckOutDay
	|					AND CheckedOutGuests.Recorder IS NOT NULL 
	|				OR RegularOperations.PerformWhenRoomIsFree
	|					AND InHousePersons.Recorder IS NULL
	|					AND CheckedInPersons.Recorder IS NULL
	|					AND CheckedOutGuests.Recorder IS NULL
	|					AND (RegularOperations.RegularOperationFrequency = 0
	|						OR RegularOperations.RegularOperationFrequency = 1
	|						OR RegularOperations.RegularOperationFrequency > 1
	|							AND DATEDIFF(&qBegOfToday, BEGINOFPERIOD(LastCheckedOutGuests.LastCheckOutDate, DAY), DAY) / RegularOperations.RegularOperationFrequency = (CAST(DATEDIFF(&qBegOfToday, BEGINOFPERIOD(LastCheckedOutGuests.LastCheckOutDate, DAY), DAY) / RegularOperations.RegularOperationFrequency AS NUMBER(17, 0)))
	|							AND DATEDIFF(&qBegOfToday, BEGINOFPERIOD(LastCheckedOutGuests.LastCheckOutDate, DAY), DAY) <> 0))
	|			AND (NOT RegularOperations.DoNotPerformOnWeekends
	|				OR RegularOperations.DoNotPerformOnWeekends
	|					AND WEEKDAY(&qBegOfToday) < 6)
	|			AND (RegularOperations.RoomType = &qEmptyRoomType
	|				OR RegularOperations.RoomType <> &qEmptyRoomType
	|					AND RoomInventoryBalance.RoomType = RegularOperations.RoomType
	|				OR RegularOperations.RoomType <> &qEmptyRoomType
	|					AND RoomInventoryBalance.RoomType.Parent <> &qEmptyRoomType
	|					AND RoomInventoryBalance.RoomType.Parent = RegularOperations.RoomType)
	|			AND (RegularOperations.RoomRate = &qEmptyRoomRate
	|				OR RegularOperations.RoomRate <> &qEmptyRoomRate
	|					AND NOT InHousePersons.Recorder.RoomRate IS NULL
	|					AND InHousePersons.Recorder.RoomRate <> &qEmptyRoomRate
	|					AND (InHousePersons.Recorder.RoomRate = RegularOperations.RoomRate
	|						OR InHousePersons.Recorder.RoomRate.Parent = RegularOperations.RoomRate
	|						OR InHousePersons.Recorder.RoomRate.Parent.Parent = RegularOperations.RoomRate))
	|WHERE
	|	RoomInventoryBalance.TotalBedsBalance > 0
	|	AND NOT RegularOperations.RegularOperation.Code IS NULL
	|
	|ORDER BY
	|	HotelCode,
	|	RoomSortCode,
	|	RegularOperationSortCode";
	#КонецУдаления
	vRegOprQry.SetParameter("qBegOfToday", BegOfDay(CurrentSessionDate()));
	vRegOprQry.SetParameter("qEndOfToday", EndOfDay(CurrentSessionDate()));
	vRegOprQry.SetParameter("qRegularOperationGroup", SelHotel.RegularOperationGroup);
	vRegOprQry.SetParameter("qHotelsListIsEmpty", ?(vHotelsList.Count() > 0, False, True));
	vRegOprQry.SetParameter("qHotelsList", vHotelsList);
	vRegOprQry.SetParameter("qParentIsEmpty", Not ValueIsFilled(SelRoomsFolder));
	vRegOprQry.SetParameter("qParent", SelRoomsFolder);
	vRegOprQry.SetParameter("qRoomTypeIsEmpty", Not ValueIsFilled(SelRoomType));
	vRegOprQry.SetParameter("qRoomType", SelRoomType);
	vRegOprQry.SetParameter("qEmptyRoomType", Catalogs.RoomTypes.EmptyRef());
	vRegOprQry.SetParameter("qEmptyRoomRate", Catalogs.RoomRates.EmptyRef());
	vRegOprQry.SetParameter("qRoomSectionIsEmpty", Not ValueIsFilled(SelRoomSection));
	vRegOprQry.SetParameter("qRoomSection", SelRoomSection);
	vRegOprQry.SetParameter("qRoomIsEmpty", Not ValueIsFilled(SelRoom));
	vRegOprQry.SetParameter("qRoom", SelRoom);
	vRegOprQry.SetParameter("qRoomFloorIsEmpty", IsBlankString(SelFloor));
	vRegOprQry.SetParameter("qRoomFloor", TrimAll(SelFloor));
	vRegOprQry.SetParameter("qRoomStatusesList", vStatusesList);
	If SelShowRoomsWithTasks Or SelShowRoomsWithDiscrepancies Then
		vRegOprQry.SetParameter("qRoomsListIsEmpty", False);
	Else
		vRegOprQry.SetParameter("qRoomsListIsEmpty", ?(vRoomsList.Count() > 0, False, True));
	EndIf;
	vRegOprQry.SetParameter("qRoomsList", vRoomsList);
	vRegOprQry.SetParameter("qExpense", AccumulationRecordType.Expense);
	vRegOprQry.SetParameter("qReceipt", AccumulationRecordType.Receipt);
	vRegularOperations = vRegOprQry.Execute().Unload();
	
	TableBoxRooms.GetItems().Clear();
	TotalRoomsInList = 0;
	
	vCurParent = Undefined;
	vCurRoom = Undefined;
	For Each vRoomsRow In vRooms Do
		If Not vRoomsRow.IsFolder Then
			vRegularOperationsRows = vRegularOperations.FindRows(New Structure("Room", vRoomsRow.Ref));
			If SelShowRegularOperations And vRegularOperationsRows.Count() = 0 Then
				Continue;
			EndIf;
		EndIf;
		
		vDoAddRoom = True;
		If vCurRoom = vRoomsRow.Ref Then
			vDoAddRoom = False;
			If vRoomsRow.IsFolder Then
				Continue;
			EndIf;
		EndIf;
		
		vCurRoom = vRoomsRow.Ref;
		#Вставка
		If ValueIsFilled(vRoomsRow.Parent) Then
			vParentsRow = vParents.Find(vRoomsRow.Parent, "Ref");	
		#КонецВставки
		#Удаление
		If ValueIsFilled(vCurRoom.Parent) Then	
			vParentsRow = vParents.Find(vCurRoom.Parent, "Ref");
		#КонецУдаления	
			If vParentsRow = Undefined Then
				vCurFolderItem = TableBoxRooms;
			Else
				vCurFolderItem = vParentsRow.Item;
			EndIf;
		Else
			vCurFolderItem = TableBoxRooms;
		EndIf;
		
		
		#Вставка
		If vCurParent <> vRoomsRow.Parent Then
			vCurParent = vRoomsRow.Parent;	
		#КонецВставки
		#Удаление
		If vCurParent <> vCurRoom.Parent Then
			vCurParent = vCurRoom.Parent;
		#КонецУдаления
			If ValueIsFilled(vCurParent) Then
				vCurFolderItem = vCurFolderItem.GetItems().Add();
				FillPropertyValues(vCurFolderItem, vCurParent, "Description, IsFolder, Ref");
				vCurFolderItem.Icon = 6;
				vCurFolderItem.RoomStatusIcon = 5;
				
				vParentsRow = vParents.Add();
				vParentsRow.Ref = vCurParent;
				vParentsRow.Item = vCurFolderItem;
			EndIf;
		EndIf;
		
		If vDoAddRoom Then
			vCurRoomItem = vCurFolderItem.GetItems().Add();
			TotalRoomsInList = TotalRoomsInList + 1;
			FillPropertyValues(vCurRoomItem, vRoomsRow, , "NumberOfGuests, NumberOfGuestsOnArrival, Remarks");
			vCurRoomItem.RoomStatusIcon = GetRoomStatusIconIndex(vCurRoomItem.RoomStatus);
			vCurRoomItem.NumberOfGuests = vCurRoomItem.NumberOfGuests + vRoomsRow.NumberOfGuests;
			vCurRoomItem.NumberOfGuestsOnArrival = vCurRoomItem.NumberOfGuestsOnArrival + vRoomsRow.NumberOfGuestsOnArrival;
		EndIf;
		
		If Not IsBlankString(vRoomsRow.AccommodationTemplateDescription) Then
			If StrFind(vCurRoomItem.Remarks, vRoomsRow.AccommodationTemplateDescription) = 0 Then
				vCurRoomItem.Remarks = vCurRoomItem.Remarks + ?(IsBlankString(vCurRoomItem.Remarks), "", Chars.LF) + vRoomsRow.AccommodationTemplateDescription;
			EndIf;
		EndIf;
		If Not IsBlankString(vRoomsRow.ClientTypeDescription) Then
			If StrFind(vCurRoomItem.Remarks, vRoomsRow.ClientTypeDescription) = 0 Then
				vCurRoomItem.Remarks = vCurRoomItem.Remarks + ?(IsBlankString(vCurRoomItem.Remarks), "", Chars.LF) + vRoomsRow.ClientTypeDescription;
			EndIf;
		EndIf;
		If Not IsBlankString(vRoomsRow.HousekeepingRemarks) Then
			If StrFind(vCurRoomItem.Remarks, vRoomsRow.HousekeepingRemarks) = 0 Then
				vCurRoomItem.Remarks = vCurRoomItem.Remarks + ?(IsBlankString(vCurRoomItem.Remarks), "", Chars.LF) + vRoomsRow.HousekeepingRemarks;
			EndIf;
		EndIf;
		If Not IsBlankString(vRoomsRow.ReceptionRemarks) Then
			If StrFind(vCurRoomItem.Remarks, vRoomsRow.ReceptionRemarks) = 0 Then
				vCurRoomItem.Remarks = vCurRoomItem.Remarks + ?(IsBlankString(vCurRoomItem.Remarks), "", Chars.LF) + vRoomsRow.ReceptionRemarks;
			EndIf;
		EndIf;
		If Not IsBlankString(vRoomsRow.RoomBlockRemarks) Then
			If StrFind(vCurRoomItem.Remarks, vRoomsRow.RoomBlockRemarks) = 0 Then
				vCurRoomItem.Remarks = vCurRoomItem.Remarks + ?(IsBlankString(vCurRoomItem.Remarks), "", Chars.LF) + vRoomsRow.RoomBlockRemarks;
			EndIf;
		EndIf;
		If Not IsBlankString(vRoomsRow.Remarks) Then
			If StrFind(vCurRoomItem.Remarks, vRoomsRow.Remarks) = 0 Then
				vCurRoomItem.Remarks = vCurRoomItem.Remarks + ?(IsBlankString(vCurRoomItem.Remarks), "", Chars.LF) + vRoomsRow.Remarks;
			EndIf;
		EndIf;
		vIsVacant = True;
		If Not IsBlankString(vRoomsRow.ExpectedCheckOutClause) Then
			If StrFind(vCurRoomItem.Condition, vRoomsRow.ExpectedCheckOutClause) = 0 Then
				vCurRoomItem.Condition = vCurRoomItem.Condition + ?(IsBlankString(vCurRoomItem.Condition), "", ", ") + vRoomsRow.ExpectedCheckOutClause;
			EndIf;
			vIsVacant = False;
		EndIf;
		If Not IsBlankString(vRoomsRow.ExpectedCheckInClause) Then
			If StrFind(vCurRoomItem.Condition, vRoomsRow.ExpectedCheckInClause) = 0 Then
				vCurRoomItem.Condition = vCurRoomItem.Condition + ?(IsBlankString(vCurRoomItem.Condition), "", ", ") + vRoomsRow.ExpectedCheckInClause;
			EndIf;
			vIsVacant = False;
		EndIf;
		If Not IsBlankString(vRoomsRow.CheckedInClause) Then
			If StrFind(vCurRoomItem.Condition, vRoomsRow.CheckedInClause) = 0 Then
				vCurRoomItem.Condition = vCurRoomItem.Condition + ?(IsBlankString(vCurRoomItem.Condition), "", ", ") + vRoomsRow.CheckedInClause;
			EndIf;
			vIsVacant = False;
		EndIf;
		If Not IsBlankString(vRoomsRow.ExpectedRoomMoveClause) Then
			If StrFind(vCurRoomItem.Condition, vRoomsRow.ExpectedRoomMoveClause) = 0 Then
				If vRoomsRow.Ref = vRoomsRow.ToRoom Then
					vCurRoomItem.Condition = vCurRoomItem.Condition + ?(IsBlankString(vCurRoomItem.Condition), "", ", ") + vRoomsRow.ExpectedRoomMoveClause + NStr("en=' in from room '; ru=' из номера '; de=' vom Zimmer '") + TrimAll(vRoomsRow.FromRoom);
				ElsIf vRoomsRow.Ref = vRoomsRow.FromRoom Then
					vCurRoomItem.Condition = vCurRoomItem.Condition + ?(IsBlankString(vCurRoomItem.Condition), "", ", ") + vRoomsRow.ExpectedRoomMoveClause + NStr("en=' out to room '; ru=' в номер '; de=' ins Zimmer '") + TrimAll(vRoomsRow.ToRoom);
				EndIf;
			EndIf;
			vIsVacant = False;
		EndIf;
		If Not IsBlankString(vRoomsRow.InHouseClause) And IsBlankString(vRoomsRow.CheckedInClause) And IsBlankString(vRoomsRow.ExpectedCheckOutClause) Then
			If StrFind(vCurRoomItem.Condition, vRoomsRow.InHouseClause) = 0 Then
				vCurRoomItem.Condition = vCurRoomItem.Condition + ?(IsBlankString(vCurRoomItem.Condition), "", ", ") + vRoomsRow.InHouseClause;
			EndIf;
			vIsVacant = False;
		ElsIf Not IsBlankString(vRoomsRow.CheckedOutClause) Then
			If StrFind(vCurRoomItem.Condition, vRoomsRow.CheckedOutClause) = 0 Then
				vCurRoomItem.Condition = vCurRoomItem.Condition + ?(IsBlankString(vCurRoomItem.Condition), "", ", ") + vRoomsRow.CheckedOutClause;
			EndIf;
			vIsVacant = False;
		EndIf;
		If ValueIsFilled(vRoomsRow.RoomBlockType) Then
			If StrFind(vCurRoomItem.Condition, TrimAll(vRoomsRow.RoomBlockType)) = 0 Then
				vCurRoomItem.Condition = vCurRoomItem.Condition + ?(IsBlankString(vCurRoomItem.Condition), "", ", ") + TrimAll(vRoomsRow.RoomBlockType);
			EndIf;
			vIsVacant = False;
		EndIf;
		If vIsVacant Then
			If StrFind(vCurRoomItem.Condition, vVacantClause) = 0 Then
				vCurRoomItem.Condition = vCurRoomItem.Condition + ?(IsBlankString(vCurRoomItem.Condition), "", ", ") + vVacantClause;
			EndIf;
		EndIf;
		
		// Fill regular operations
		If vDoAddRoom Then
			For Each vRegularOperationsRow In vRegularOperationsRows Do
				vCurRoomItem.RegularOperations = vCurRoomItem.RegularOperations + ?(IsBlankString(vCurRoomItem.RegularOperations), "", ", ") + TrimAll(vRegularOperationsRow.RegularOperationCode);
			EndDo;
		EndIf;
		
		// Calculate room status totals
		If vDoAddRoom Then
			vRoomStatusesTotalsRow = vRoomStatusesTotals.Find(vRoomsRow.RoomStatus, "RoomStatus");
			If vRoomStatusesTotalsRow = Undefined Then
				vRoomStatusesTotalsRow = vRoomStatusesTotals.Add();
				vRoomStatusesTotalsRow.RoomStatus = vRoomsRow.RoomStatus;
				vRoomStatusesTotalsRow.Quantity = 0;
			EndIf;
			vRoomStatusesTotalsRow.Quantity = vRoomStatusesTotalsRow.Quantity + 1;
		EndIf;
		
		If vCurRoom = CurRowRoom Then
			vRowId = vCurRoomItem.GetID();
		Endif;			
	EndDo;
	
	// Update number of rooms by statuses
	For Each vStatusItem In TableBoxStatuses Do
		vRoomStatus = vStatusItem.Value;
		vRoomStatusesTotalsRow = vRoomStatusesTotals.Find(vRoomStatus, "RoomStatus");
		If vRoomStatusesTotalsRow <> Undefined Then
			vStatusItem.Presentation = TrimAll(vRoomStatus.Description) + " (" + Format(vRoomStatusesTotalsRow.Quantity, "NFD=0; NZ=; NG=") + ")";
		Else
			vStatusItem.Presentation = TrimAll(vRoomStatus.Description);
		EndIf;
	EndDo;
	
	Return vRowId;
EndFunction

Function cmGetActiveRoomsList_Изм(pHotel = Undefined, НомернойФонд = Неопределено) 
	vList = New ValueList();
	vQry = New Query();
	Если НомернойФонд = Неопределено Тогда
		vQry.Text = 
		"SELECT  Разрешенные
		|	Rooms.Ref
		|FROM
		|	Catalog.Rooms AS Rooms
		|WHERE
		|	NOT Rooms.IsFolder
		|	AND NOT Rooms.IsVirtual
		|	AND NOT Rooms.DeletionMark
		|	AND Rooms.OperationStartDate <= &qDate
		|	AND (Rooms.OperationEndDate >= &qDate
		|			OR Rooms.OperationEndDate = &qEmptyDate)
		|	AND (NOT &qHotelIsEmpty
		|				AND Rooms.Owner = &qHotel
		|			OR &qHotelIsEmpty)
		|
		|ORDER BY
		|	Rooms.SortCode";
	Иначе
		vQry.Text = 
		"ВЫБРАТЬ  разрешенные
		|	Rooms.Ссылка КАК Ref
		|ИЗ
		|	Справочник.Rooms КАК Rooms
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.Расш1_СоставНомерногоФонда КАК Расш1_СоставНомерногоФонда
		|		ПО (Rooms.Ссылка = Расш1_СоставНомерногоФонда.Номер
		|				И Расш1_СоставНомерногоФонда.НомернойФонд = &НомернойФонд)
		|ГДЕ
		|	НЕ Rooms.ЭтоГруппа
		|	И НЕ Rooms.IsVirtual
		|	И НЕ Rooms.ПометкаУдаления
		|	И Rooms.OperationStartDate <= &qDate
		|	И (Rooms.OperationEndDate >= &qDate
		|			ИЛИ Rooms.OperationEndDate = &qEmptyDate)
		|	И (НЕ &qHotelIsEmpty
		|				И Rooms.Владелец = &qHotel
		|			ИЛИ &qHotelIsEmpty)
		|
		|УПОРЯДОЧИТЬ ПО
		|	Rooms.SortCode";
		vQry.SetParameter("НомернойФонд", НомернойФонд);		
	КонецЕсли;
	
	vQry.SetParameter("qDate", BegOfDay(CurrentSessionDate()));
	vQry.SetParameter("qEmptyDate", '00010101');
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qHotelIsEmpty", Not ValueIsFilled(pHotel));
	vRooms = vQry.Execute().Unload();
	If vRooms.Count() > 0 Then
		vList.LoadValues(vRooms.UnloadColumn("Ref"));
	EndIf;
	Return vList;
EndFunction //cmGetActiveRoomsList
