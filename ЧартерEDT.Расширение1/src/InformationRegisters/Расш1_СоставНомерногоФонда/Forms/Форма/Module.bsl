

//-----------------------------------------------------------------------------
// Description: Returns value table with accommodations intersecting by period with
//              input parameter period and for the given hotel, room type,
//              room or rooms list
// Parameters: Hotel, Room type, Room, Start of period, End of period,
//             Rooms value list
// Return value: Value table with accommodations found
//-----------------------------------------------------------------------------
&AtServer
Function GetRoomGuestsФорма(pRooms, pDate, НомернойФонд)
	// Build and run query to get room guests
	vQry = New Query;
	vQry.Text = 
	"ВЫБРАТЬ
	|	RoomInventory.Room КАК Room,
	|	RoomInventory.Customer КАК Customer,
	|	RoomInventory.GuestGroup.Наименование КАК GuestGroupDescription,
	|	ВЫРАЗИТЬ(ЕСТЬNULL(RoomInventory.Guest.Remarks, """") КАК СТРОКА(512)) КАК GuestRemarks,
	|	ВЫБОР
	|		КОГДА RoomInventory.CheckOutDate >= &qDateFrom
	|				И RoomInventory.CheckOutDate <= &qDateTo
	|			ТОГДА ИСТИНА
	|		ИНАЧЕ ЛОЖЬ
	|	КОНЕЦ КАК CheckOutToday,
	|	RoomInventory.IsInHouse КАК IsInHouse,
	|	СУММА(RoomInventory.NumberOfPersons) КАК NumberOfPersons
	|ИЗ
	|	РегистрНакопления.RoomInventory КАК RoomInventory
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.Расш1_СоставНомерногоФонда КАК Расш1_СоставНомерногоФонда
	|		ПО (RoomInventory.Room = Расш1_СоставНомерногоФонда.Номер
	|				И Расш1_СоставНомерногоФонда.НомернойФонд = &НомернойФонд)
	|ГДЕ
	|	RoomInventory.IsAccommodation
	|	И RoomInventory.IsInHouse
	|	И RoomInventory.Room В(&qRooms)
	|	И RoomInventory.ВидДвижения = &qExpense
	|	И RoomInventory.PeriodFrom < &qDateTo
	|	И RoomInventory.PeriodTo > &qDateFrom
	|	И RoomInventory.Период = RoomInventory.PeriodFrom
	|
	|СГРУППИРОВАТЬ ПО
	|	RoomInventory.Room,
	|	RoomInventory.Customer,
	|	RoomInventory.GuestGroup.Наименование,
	|	ВЫРАЗИТЬ(ЕСТЬNULL(RoomInventory.Guest.Remarks, """") КАК СТРОКА(512)),
	|	ВЫБОР
	|		КОГДА RoomInventory.CheckOutDate >= &qDateFrom
	|				И RoomInventory.CheckOutDate <= &qDateTo
	|			ТОГДА ИСТИНА
	|		ИНАЧЕ ЛОЖЬ
	|	КОНЕЦ,
	|	RoomInventory.IsInHouse
	|
	|УПОРЯДОЧИТЬ ПО
	|	RoomInventory.Room.SortCode";
	
	vQry.SetParameter("НомернойФонд", НомернойФонд);
	vQry.SetParameter("qRooms", pRooms);
	vQry.SetParameter("qExpense", AccumulationRecordType.Expense);
	vQry.SetParameter("qDateFrom", BegOfDay(pDate));
	vQry.SetParameter("qDateTo", EndOfDay(pDate));
	
	vQryTab = vQry.Execute().Unload();
	
	// Return
	Return vQryTab;
EndFunction //GetRoomGuests

&AtServer
Function FillRoomsListAtServerЛевый()
	
	vRowId = Undefined;
	
	// List of hotels
	vHotelsList = GetHotelsList(SelHotel);
	
	// Build lists of room statuses and rooms used to filter rooms
	vRoomsList = New ValueList();
	
	If Режим = 2 Then
		vRoomsList = cmGetActiveRoomsListФорма(SelHotel, НомернойФондЛевый);
		vHotelGuests = GetRoomGuestsФорма(vRoomsList, CurrentSessionDate(), НомернойФондЛевый);
		i = 0;
		While i < vRoomsList.Count() Do
			vRoomGuests = vHotelGuests.FindRows(New Structure("Room", vRoomsList.Get(i).Value));
			If vRoomGuests.Count() > 0 Then
				vRoomsList.Delete(i);
			Else
				i = i + 1;
			EndIf;
		EndDo;
	ElsIf Режим = 3 Then
		vRoomsList = cmGetActiveRoomsListФорма(SelHotel, НомернойФондЛевый);
		vHotelGuests = GetRoomGuestsФорма(vRoomsList, CurrentSessionDate(), НомернойФондЛевый);
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
	vQry = New Query();
	vQry.Text = 
	"ВЫБРАТЬ
	|	Accommodations.Room КАК Room,
	|	Accommodations.Customer КАК Customer,
	|	Accommodations.ClientType КАК ClientType,
	|	Accommodations.AccommodationTemplate КАК AccommodationTemplate,
	|	Accommodations.Номер КАК DocumentNumber,
	|	&qInHouseClause КАК Clause,
	|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants КАК NumberOfGuests
	|ПОМЕСТИТЬ InHouseGuests
	|ИЗ
	|	Документ.Accommodation КАК Accommodations
	|ГДЕ
	|	Accommodations.Проведен
	|	И Accommodations.AccommodationStatus.IsActive
	|	И Accommodations.AccommodationStatus.IsInHouse
	|	И (&qHotelsListIsEmpty
	|			ИЛИ НЕ &qHotelsListIsEmpty
	|				И Accommodations.Hotel В (&qHotelsList))
	|	И (&qParentIsEmpty
	|			ИЛИ НЕ &qParentIsEmpty
	|				И Accommodations.Room В ИЕРАРХИИ (&qParent))
	|	И (&qRoomTypeIsEmpty
	|			ИЛИ НЕ &qRoomTypeIsEmpty
	|				И Accommodations.RoomType В ИЕРАРХИИ (&qRoomType))
	|	И Accommodations.AccommodationTemplate <> ЗНАЧЕНИЕ(Catalog.AccommodationTemplates.EmptyRef)
	|
	|СГРУППИРОВАТЬ ПО
	|	Accommodations.Room,
	|	Accommodations.Номер,
	|	Accommodations.Customer,
	|	Accommodations.ClientType,
	|	Accommodations.AccommodationTemplate,
	|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Reservations.Room КАК Room,
	|	Reservations.Номер КАК DocumentNumber,
	|	Reservations.Customer КАК Customer,
	|	Reservations.ClientType КАК ClientType,
	|	Reservations.AccommodationTemplate КАК AccommodationTemplate,
	|	ВЫРАЗИТЬ(Reservations.Remarks КАК СТРОКА(999)) КАК Remarks,
	|	ВЫРАЗИТЬ(Reservations.HousekeepingRemarks КАК СТРОКА(999)) КАК HousekeepingRemarks,
	|	&qExpectedCheckInClause КАК Clause,
	|	Reservations.NumberOfAdults + Reservations.NumberOfTeenagers + Reservations.NumberOfChildren + Reservations.NumberOfInfants КАК NumberOfGuestsOnArrival
	|ПОМЕСТИТЬ ExpectedCheckInGuests
	|ИЗ
	|	Документ.Reservation КАК Reservations
	|ГДЕ
	|	Reservations.Проведен
	|	И (Reservations.ReservationStatus.IsActive
	|			ИЛИ Reservations.ReservationStatus.IsPreliminary)
	|	И Reservations.CheckInDate >= &qBegOfToday
	|	И Reservations.CheckInDate <= &qEndOfToday
	|	И Reservations.Room <> ЗНАЧЕНИЕ(Catalog.Rooms.EmptyRef)
	|	И (&qHotelsListIsEmpty
	|			ИЛИ НЕ &qHotelsListIsEmpty
	|				И Reservations.Hotel В (&qHotelsList))
	|	И (&qParentIsEmpty
	|			ИЛИ НЕ &qParentIsEmpty
	|				И Reservations.Room В ИЕРАРХИИ (&qParent))
	|	И (&qRoomTypeIsEmpty
	|			ИЛИ НЕ &qRoomTypeIsEmpty
	|				И Reservations.RoomType В ИЕРАРХИИ (&qRoomType))
	|	И Reservations.AccommodationTemplate <> ЗНАЧЕНИЕ(Catalog.AccommodationTemplates.EmptyRef)
	|
	|СГРУППИРОВАТЬ ПО
	|	Reservations.Room,
	|	Reservations.Номер,
	|	Reservations.Customer,
	|	Reservations.ClientType,
	|	Reservations.AccommodationTemplate,
	|	ВЫРАЗИТЬ(Reservations.Remarks КАК СТРОКА(999)),
	|	ВЫРАЗИТЬ(Reservations.HousekeepingRemarks КАК СТРОКА(999)),
	|	Reservations.NumberOfAdults + Reservations.NumberOfTeenagers + Reservations.NumberOfChildren + Reservations.NumberOfInfants
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ExpectedRoomMove.Room КАК ToRoom,
	|	ExpectedRoomMove.Ссылка.Room КАК FromRoom,
	|	ExpectedRoomMove.Ссылка.Номер КАК DocumentNumber,
	|	ExpectedRoomMove.Ссылка.Customer КАК Customer,
	|	ExpectedRoomMove.Ссылка.ClientType КАК ClientType,
	|	ExpectedRoomMove.Ссылка.AccommodationTemplate КАК AccommodationTemplate,
	|	ВЫРАЗИТЬ(ExpectedRoomMove.Ссылка.Remarks КАК СТРОКА(999)) КАК Remarks,
	|	ВЫРАЗИТЬ(ExpectedRoomMove.Ссылка.HousekeepingRemarks КАК СТРОКА(999)) КАК HousekeepingRemarks,
	|	&qExpectedRoomMoveClause КАК Clause,
	|	ExpectedRoomMove.Ссылка.NumberOfAdults + ExpectedRoomMove.Ссылка.NumberOfTeenagers + ExpectedRoomMove.Ссылка.NumberOfChildren + ExpectedRoomMove.Ссылка.NumberOfInfants КАК NumberOfGuests
	|ПОМЕСТИТЬ ExpectedRoomMoveGuests
	|ИЗ
	|	Документ.Accommodation.RoomRates КАК ExpectedRoomMove
	|ГДЕ
	|	ExpectedRoomMove.Ссылка.Проведен
	|	И ExpectedRoomMove.Ссылка.AccommodationStatus.IsActive
	|	И ExpectedRoomMove.Ссылка.AccommodationStatus.IsInHouse
	|	И ExpectedRoomMove.Room <> ЗНАЧЕНИЕ(Catalog.Rooms.EmptyRef)
	|	И ExpectedRoomMove.Room <> ExpectedRoomMove.Ссылка.Room
	|	И ExpectedRoomMove.AccountingDate = &qBegOfToday
	|	И (&qHotelsListIsEmpty
	|			ИЛИ НЕ &qHotelsListIsEmpty
	|				И ExpectedRoomMove.Ссылка.Hotel В (&qHotelsList))
	|	И (&qParentIsEmpty
	|			ИЛИ НЕ &qParentIsEmpty
	|				И ExpectedRoomMove.Ссылка.Room В ИЕРАРХИИ (&qParent))
	|	И (&qRoomTypeIsEmpty
	|			ИЛИ НЕ &qRoomTypeIsEmpty
	|				И ExpectedRoomMove.Ссылка.RoomType В ИЕРАРХИИ (&qRoomType))
	|	И ExpectedRoomMove.Ссылка.AccommodationTemplate <> ЗНАЧЕНИЕ(Catalog.AccommodationTemplates.EmptyRef)
	|
	|СГРУППИРОВАТЬ ПО
	|	ExpectedRoomMove.Room,
	|	ExpectedRoomMove.Ссылка.Room,
	|	ExpectedRoomMove.Ссылка.Номер,
	|	ExpectedRoomMove.Ссылка.Customer,
	|	ExpectedRoomMove.Ссылка.ClientType,
	|	ExpectedRoomMove.Ссылка.AccommodationTemplate,
	|	ВЫРАЗИТЬ(ExpectedRoomMove.Ссылка.Remarks КАК СТРОКА(999)),
	|	ВЫРАЗИТЬ(ExpectedRoomMove.Ссылка.HousekeepingRemarks КАК СТРОКА(999)),
	|	ExpectedRoomMove.Ссылка.NumberOfAdults + ExpectedRoomMove.Ссылка.NumberOfTeenagers + ExpectedRoomMove.Ссылка.NumberOfChildren + ExpectedRoomMove.Ссылка.NumberOfInfants
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Accommodations.Room КАК Room,
	|	Accommodations.Customer КАК Customer,
	|	Accommodations.AccommodationTemplate КАК AccommodationTemplate,
	|	&qExpectedCheckOutClause КАК Clause,
	|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants КАК NumberOfCheckOutGuests
	|ПОМЕСТИТЬ ExpectedCheckOutGuests
	|ИЗ
	|	Документ.Accommodation КАК Accommodations
	|ГДЕ
	|	Accommodations.Проведен
	|	И Accommodations.AccommodationStatus.IsActive
	|	И Accommodations.AccommodationStatus.IsInHouse
	|	И Accommodations.AccommodationStatus.IsCheckOut
	|	И Accommodations.CheckOutDate >= &qBegOfToday
	|	И Accommodations.CheckOutDate <= &qEndOfToday
	|	И (&qHotelsListIsEmpty
	|			ИЛИ НЕ &qHotelsListIsEmpty
	|				И Accommodations.Hotel В (&qHotelsList))
	|	И (&qParentIsEmpty
	|			ИЛИ НЕ &qParentIsEmpty
	|				И Accommodations.Room В ИЕРАРХИИ (&qParent))
	|	И (&qRoomTypeIsEmpty
	|			ИЛИ НЕ &qRoomTypeIsEmpty
	|				И Accommodations.RoomType В ИЕРАРХИИ (&qRoomType))
	|	И Accommodations.AccommodationTemplate <> ЗНАЧЕНИЕ(Catalog.AccommodationTemplates.EmptyRef)
	|
	|СГРУППИРОВАТЬ ПО
	|	Accommodations.Room,
	|	Accommodations.Customer,
	|	Accommodations.AccommodationTemplate,
	|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Accommodations.Room КАК Room,
	|	Accommodations.AccommodationTemplate КАК AccommodationTemplate,
	|	&qCheckedOutClause КАК Clause,
	|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants КАК NumberOfCheckedOutGuests
	|ПОМЕСТИТЬ CheckedOutGuests
	|ИЗ
	|	Документ.Accommodation КАК Accommodations
	|ГДЕ
	|	Accommodations.Проведен
	|	И Accommodations.AccommodationStatus.IsActive
	|	И НЕ Accommodations.AccommodationStatus.IsInHouse
	|	И Accommodations.AccommodationStatus.IsCheckOut
	|	И Accommodations.CheckOutDate >= &qBegOfToday
	|	И Accommodations.CheckOutDate <= &qEndOfToday
	|	И (&qHotelsListIsEmpty
	|			ИЛИ НЕ &qHotelsListIsEmpty
	|				И Accommodations.Hotel В (&qHotelsList))
	|	И (&qParentIsEmpty
	|			ИЛИ НЕ &qParentIsEmpty
	|				И Accommodations.Room В ИЕРАРХИИ (&qParent))
	|	И (&qRoomTypeIsEmpty
	|			ИЛИ НЕ &qRoomTypeIsEmpty
	|				И Accommodations.RoomType В ИЕРАРХИИ (&qRoomType))
	|	И Accommodations.AccommodationTemplate <> ЗНАЧЕНИЕ(Catalog.AccommodationTemplates.EmptyRef)
	|
	|СГРУППИРОВАТЬ ПО
	|	Accommodations.Room,
	|	Accommodations.AccommodationTemplate,
	|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Accommodations.Room КАК Room,
	|	Accommodations.Customer КАК Customer,
	|	Accommodations.AccommodationTemplate КАК AccommodationTemplate,
	|	ВЫРАЗИТЬ(Accommodations.Remarks КАК СТРОКА(999)) КАК Remarks,
	|	ВЫРАЗИТЬ(Accommodations.HousekeepingRemarks КАК СТРОКА(999)) КАК HousekeepingRemarks,
	|	&qCheckedInClause КАК Clause,
	|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants КАК NumberOfCheckedInGuests
	|ПОМЕСТИТЬ CheckedInGuests
	|ИЗ
	|	Документ.Accommodation КАК Accommodations
	|ГДЕ
	|	Accommodations.Проведен
	|	И Accommodations.AccommodationStatus.IsActive
	|	И Accommodations.AccommodationStatus.IsInHouse
	|	И Accommodations.AccommodationStatus.IsCheckIn
	|	И Accommodations.CheckInDate >= &qBegOfToday
	|	И Accommodations.CheckInDate <= &qEndOfToday
	|	И (&qHotelsListIsEmpty
	|			ИЛИ НЕ &qHotelsListIsEmpty
	|				И Accommodations.Hotel В (&qHotelsList))
	|	И (&qParentIsEmpty
	|			ИЛИ НЕ &qParentIsEmpty
	|				И Accommodations.Room В ИЕРАРХИИ (&qParent))
	|	И (&qRoomTypeIsEmpty
	|			ИЛИ НЕ &qRoomTypeIsEmpty
	|				И Accommodations.RoomType В ИЕРАРХИИ (&qRoomType))
	|	И Accommodations.AccommodationTemplate <> ЗНАЧЕНИЕ(Catalog.AccommodationTemplates.EmptyRef)
	|
	|СГРУППИРОВАТЬ ПО
	|	Accommodations.Room,
	|	Accommodations.Customer,
	|	Accommodations.AccommodationTemplate,
	|	ВЫРАЗИТЬ(Accommodations.Remarks КАК СТРОКА(999)),
	|	ВЫРАЗИТЬ(Accommodations.HousekeepingRemarks КАК СТРОКА(999)),
	|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	RoomBlocks.Room КАК Room,
	|	RoomBlocks.RoomBlockType КАК RoomBlockType,
	|	RoomBlocks.Номер КАК BlockNumber,
	|	ВЫРАЗИТЬ(RoomBlocks.Remarks КАК СТРОКА(999)) КАК RoomBlockRemarks
	|ПОМЕСТИТЬ RoomBlocks
	|ИЗ
	|	Документ.SetRoomBlock КАК RoomBlocks
	|ГДЕ
	|	RoomBlocks.Проведен
	|	И (&qHotelsListIsEmpty
	|			ИЛИ НЕ &qHotelsListIsEmpty
	|				И RoomBlocks.Hotel В (&qHotelsList))
	|	И RoomBlocks.DateFrom <= &qToday
	|	И (RoomBlocks.DateTo = &qEmptyDate
	|			ИЛИ RoomBlocks.DateTo <> &qEmptyDate
	|				И RoomBlocks.DateTo > &qToday)
	|	И (&qParentIsEmpty
	|			ИЛИ НЕ &qParentIsEmpty
	|				И RoomBlocks.Room В ИЕРАРХИИ (&qParent))
	|	И (&qRoomTypeIsEmpty
	|			ИЛИ НЕ &qRoomTypeIsEmpty
	|				И RoomBlocks.Room.RoomType В ИЕРАРХИИ (&qRoomType))
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ВЫБОР
	|		КОГДА Rooms.ЭтоГруппа
	|			ТОГДА 6
	|		ИНАЧЕ 7
	|	КОНЕЦ КАК Icon,
	|	Rooms.Наименование КАК Description,
	|	Rooms.RoomType КАК RoomType,
	|	Rooms.Floor КАК Floor,
	|	Rooms.RoomStatus КАК RoomStatus,
	|	RoomStatusChangeHistory.Период КАК RoomStatusLastChangeTime,
	|	ВЫРАЗИТЬ(Rooms.Remarks КАК СТРОКА(999)) КАК Remarks,
	|	Rooms.HasRoomBlocks КАК HasRoomBlocks,
	|	RoomBlocks.RoomBlockType КАК RoomBlockType,
	|	RoomBlocks.RoomBlockRemarks КАК RoomBlockRemarks,
	|	Rooms.StopSale КАК StopSale,
	|	Rooms.IsVirtual КАК IsVirtual,
	|	ВЫРАЗИТЬ(Rooms.RoomPropertiesCodes КАК СТРОКА(999)) КАК RoomPropertiesCodes,
	|	"""" КАК Condition,
	|	ExpectedCheckInGuests.Clause КАК ExpectedCheckInClause,
	|	CheckedInGuests.Clause КАК CheckedInClause,
	|	ExpectedRoomMoveGuests.Clause КАК ExpectedRoomMoveClause,
	|	InHouseGuests.Clause КАК InHouseClause,
	|	ExpectedCheckOutGuests.Clause КАК ExpectedCheckOutClause,
	|	CheckedOutGuests.Clause КАК CheckedOutClause,
	|	Rooms.SortCode КАК SortCode,
	|	Rooms.ЭтоГруппа КАК IsFolder,
	|	Rooms.Ссылка КАК Ref,
	|	Rooms.RoomType.NumberOfBedsPerRoom КАК NumberOfBedsPerRoom
	|ИЗ
	|	Справочник.Rooms КАК Rooms
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.RoomStatusChangeHistory.СрезПоследних(
	|				&qToday,
	|				&qHotelsListIsEmpty
	|					ИЛИ НЕ &qHotelsListIsEmpty
	|						И Room.Owner В (&qHotelsList)) КАК RoomStatusChangeHistory
	|		ПО (RoomStatusChangeHistory.Room = Rooms.Ссылка)
	|		ЛЕВОЕ СОЕДИНЕНИЕ ExpectedCheckInGuests КАК ExpectedCheckInGuests
	|		ПО (ExpectedCheckInGuests.Room = Rooms.Ссылка)
	|		ЛЕВОЕ СОЕДИНЕНИЕ CheckedInGuests КАК CheckedInGuests
	|		ПО (CheckedInGuests.Room = Rooms.Ссылка)
	|		ЛЕВОЕ СОЕДИНЕНИЕ ExpectedRoomMoveGuests КАК ExpectedRoomMoveGuests
	|		ПО (ExpectedRoomMoveGuests.FromRoom = Rooms.Ссылка
	|				ИЛИ ExpectedRoomMoveGuests.ToRoom = Rooms.Ссылка)
	|		ЛЕВОЕ СОЕДИНЕНИЕ InHouseGuests КАК InHouseGuests
	|		ПО (InHouseGuests.Room = Rooms.Ссылка)
	|		ЛЕВОЕ СОЕДИНЕНИЕ ExpectedCheckOutGuests КАК ExpectedCheckOutGuests
	|		ПО (ExpectedCheckOutGuests.Room = Rooms.Ссылка)
	|		ЛЕВОЕ СОЕДИНЕНИЕ CheckedOutGuests КАК CheckedOutGuests
	|		ПО (CheckedOutGuests.Room = Rooms.Ссылка)
	|		ЛЕВОЕ СОЕДИНЕНИЕ RoomBlocks КАК RoomBlocks
	|		ПО (RoomBlocks.Room = Rooms.Ссылка)
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.Расш1_СоставНомерногоФонда КАК Расш1_СоставНомерногоФонда
	|		ПО Rooms.Ссылка = Расш1_СоставНомерногоФонда.Номер
	|			И (Расш1_СоставНомерногоФонда.НомернойФонд = &НомернойФонд)
	|ГДЕ
	|	НЕ Rooms.ПометкаУдаления
	|	И Rooms.OperationStartDate < &qEndOfToday
	|	И (Rooms.OperationEndDate = ДАТАВРЕМЯ(1, 1, 1)
	|			ИЛИ Rooms.OperationEndDate > &qBegOfToday)
	|	И (&qHotelsListIsEmpty
	|			ИЛИ НЕ &qHotelsListIsEmpty
	|				И Rooms.Владелец В (&qHotelsList))
	|	И (&qParentIsEmpty
	|			ИЛИ НЕ &qParentIsEmpty
	|				И Rooms.Ссылка В ИЕРАРХИИ (&qParent))
	|	И (&qRoomTypeIsEmpty
	|			ИЛИ НЕ &qRoomTypeIsEmpty
	|				И Rooms.RoomType В ИЕРАРХИИ (&qRoomType))
	|	И (НЕ &qCheckedRoomBlock
	|			ИЛИ &qCheckedRoomBlock
	|				И RoomBlocks.Room <> ЗНАЧЕНИЕ(Document.SetRoomBlock.EmptyRef))
	|	И (&qRoomsListIsEmpty
	|			ИЛИ НЕ &qRoomsListIsEmpty
	|				И Rooms.Ссылка В (&qRoomsList))
	|
	|УПОРЯДОЧИТЬ ПО
	|	Rooms.Родитель,
	|	SortCode";
	
	vQry.SetParameter("НомернойФонд", НомернойФондЛевый);
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
	//vQry.SetParameter("qRoomFloorIsEmpty", IsBlankString(SelFloor));
	//vQry.SetParameter("qRoomFloor", TrimAll(SelFloor));
	vQry.SetParameter("qCheckedRoomBlock", SelShowRoomsBlock);
	//vQry.SetParameter("qRoomsListIsEmpty", ?(vRoomsList.Count() > 0, False, True));
	vQry.SetParameter("qRoomsListIsEmpty", ?(vRoomsList.Count() > 0, False,?(Режим = 1, Истина, Ложь)));
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
	
	TableBoxRooms.GetItems().Clear();
	TotalRoomsInList = 0;
	TotalBedsPerRoom =  0; 
	
	vCurParent = Undefined;
	vCurRoom = Undefined;
	
	For Each vRoomsRow In vRooms Do
		
		vDoAddRoom = True;
		If vCurRoom = vRoomsRow.Ref Then
			vDoAddRoom = False;
			If vRoomsRow.IsFolder Then
				Continue;
			EndIf;
		EndIf;
		
		vCurRoom = vRoomsRow.Ref;
		If ValueIsFilled(vCurRoom.Parent) Then
			vParentsRow = vParents.Find(vCurRoom.Parent, "Ref");
			If vParentsRow = Undefined Then
				vCurFolderItem = TableBoxRooms;
			Else
				vCurFolderItem = vParentsRow.Item;
			EndIf;
		Else
			vCurFolderItem = TableBoxRooms;
		EndIf;
		
		If vCurParent <> vCurRoom.Parent Then
			vCurParent = vCurRoom.Parent;
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
			TotalBedsPerRoom = TotalBedsPerRoom + vRoomsRow.NumberOfBedsPerRoom;
			//FillPropertyValues(vCurRoomItem, vRoomsRow, , "NumberOfGuests, NumberOfGuestsOnArrival, Remarks");
			FillPropertyValues(vCurRoomItem, vRoomsRow);
			vCurRoomItem.RoomStatusIcon = GetRoomStatusIconIndex(vCurRoomItem.RoomStatus);
			//vCurRoomItem.NumberOfGuests = vCurRoomItem.NumberOfGuests + vRoomsRow.NumberOfGuests;
			//vCurRoomItem.NumberOfGuestsOnArrival = vCurRoomItem.NumberOfGuestsOnArrival + vRoomsRow.NumberOfGuestsOnArrival;
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
		
	EndDo;
	
	Return vRowId;
	
EndFunction //FillRoomsListAtServer

&AtServerNoContext
Function GetHotelsList(pHotel)
	vHotelsList = New ValueList();
	If ValueIsFilled(pHotel) Then
		vHotelsList.Add(pHotel);
	Else
		vHotels = cmGetAllHotels();
		For Each vHotelsRow In vHotels Do
			vHotelsList.Add(vHotelsRow.Hotel);
		EndDo;
	EndIf;
	Return vHotelsList;
EndFunction

&AtServerNoContext
Function GetRoomStatusIconIndex(pRoomStatus) Export
	vPictureIndex = 5;
	If ValueIsFilled(pRoomStatus) Then
		If ValueIsFilled(pRoomStatus.RoomStatusIcon) Then
			If pRoomStatus.RoomStatusIcon = Enums.RoomStatusesIcons.None Then
				vPictureIndex = 5;
			ElsIf pRoomStatus.RoomStatusIcon = Enums.RoomStatusesIcons.Reserved Then
				vPictureIndex = 6;
			ElsIf pRoomStatus.RoomStatusIcon = Enums.RoomStatusesIcons.Occupied Then
				vPictureIndex = 2;
			ElsIf pRoomStatus.RoomStatusIcon = Enums.RoomStatusesIcons.OccupiedDirty Then
				vPictureIndex = 7;
			ElsIf pRoomStatus.RoomStatusIcon = Enums.RoomStatusesIcons.Repair Then
				vPictureIndex = 8;
			ElsIf pRoomStatus.RoomStatusIcon = Enums.RoomStatusesIcons.Luggage Then
				vPictureIndex = 9;
			ElsIf pRoomStatus.RoomStatusIcon = Enums.RoomStatusesIcons.Malfunction Then
				vPictureIndex = 10;
			ElsIf pRoomStatus.RoomStatusIcon = Enums.RoomStatusesIcons.Waiting Then
				vPictureIndex = 1;
			ElsIf pRoomStatus.RoomStatusIcon = Enums.RoomStatusesIcons.TidyingUp Then
				vPictureIndex = 0;
			ElsIf pRoomStatus.RoomStatusIcon = Enums.RoomStatusesIcons.CheckOut Then
				vPictureIndex = 3;
			ElsIf pRoomStatus.RoomStatusIcon = Enums.RoomStatusesIcons.Vacant Then
				vPictureIndex = 4;
			EndIf;
		EndIf;
	EndIf;
	Return vPictureIndex;
EndFunction //GetRoomStatusIconIndex

&НаКлиенте
Процедура НомернойФондЛевПриИзменении(Элемент)
	
	FillRoomsListЛевый();
	
	For Each vItem In TableBoxRooms.GetItems() Do
		Items.TableBoxRooms.Expand(vItem.GetID(), True);
	EndDo;
	
КонецПроцедуры

&AtClient
Procedure FillRoomsListЛевый()
	
	vRowId = FillRoomsListAtServerЛевый();
	
	If vRowId <> Undefined Then
		Items.TableBoxRooms.CurrentRow = vRowId;
	EndIf;
	
EndProcedure //FillRoomsList


&AtServer
Function FillRoomsListAtServerПравый()
	
	vRowId = Undefined;
	
	// List of hotels
	vHotelsList = GetHotelsList(SelHotel);
	
	// Build lists of room statuses and rooms used to filter rooms
	
	vRoomsList = New ValueList();
	
	If Режим1 = 2 Then
		vRoomsList = cmGetActiveRoomsListФорма(SelHotel, НомернойФондПравый);
		vHotelGuests = GetRoomGuestsФорма(vRoomsList, CurrentSessionDate(), НомернойФондПравый);
		i = 0;
		While i < vRoomsList.Count() Do
			vRoomGuests = vHotelGuests.FindRows(New Structure("Room", vRoomsList.Get(i).Value));
			If vRoomGuests.Count() > 0 Then
				vRoomsList.Delete(i);
			Else
				i = i + 1;
			EndIf;
		EndDo;
	ElsIf Режим1 = 3 Then
		vRoomsList = cmGetActiveRoomsListФорма(SelHotel, НомернойФондПравый);
		vHotelGuests = GetRoomGuestsФорма(vRoomsList, CurrentSessionDate(), НомернойФондПравый);
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
	vQry = New Query();
	vQry.Text = 
	"ВЫБРАТЬ
	|	Accommodations.Room КАК Room,
	|	Accommodations.Customer КАК Customer,
	|	Accommodations.ClientType КАК ClientType,
	|	Accommodations.AccommodationTemplate КАК AccommodationTemplate,
	|	Accommodations.Номер КАК DocumentNumber,
	|	&qInHouseClause КАК Clause,
	|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants КАК NumberOfGuests
	|ПОМЕСТИТЬ InHouseGuests
	|ИЗ
	|	Документ.Accommodation КАК Accommodations
	|ГДЕ
	|	Accommodations.Проведен
	|	И Accommodations.AccommodationStatus.IsActive
	|	И Accommodations.AccommodationStatus.IsInHouse
	|	И (&qHotelsListIsEmpty
	|			ИЛИ НЕ &qHotelsListIsEmpty
	|				И Accommodations.Hotel В (&qHotelsList))
	|	И (&qParentIsEmpty
	|			ИЛИ НЕ &qParentIsEmpty
	|				И Accommodations.Room В ИЕРАРХИИ (&qParent))
	|	И (&qRoomTypeIsEmpty
	|			ИЛИ НЕ &qRoomTypeIsEmpty
	|				И Accommodations.RoomType В ИЕРАРХИИ (&qRoomType))
	|	И Accommodations.AccommodationTemplate <> ЗНАЧЕНИЕ(Catalog.AccommodationTemplates.EmptyRef)
	|
	|СГРУППИРОВАТЬ ПО
	|	Accommodations.Room,
	|	Accommodations.Номер,
	|	Accommodations.Customer,
	|	Accommodations.ClientType,
	|	Accommodations.AccommodationTemplate,
	|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Reservations.Room КАК Room,
	|	Reservations.Номер КАК DocumentNumber,
	|	Reservations.Customer КАК Customer,
	|	Reservations.ClientType КАК ClientType,
	|	Reservations.AccommodationTemplate КАК AccommodationTemplate,
	|	ВЫРАЗИТЬ(Reservations.Remarks КАК СТРОКА(999)) КАК Remarks,
	|	ВЫРАЗИТЬ(Reservations.HousekeepingRemarks КАК СТРОКА(999)) КАК HousekeepingRemarks,
	|	&qExpectedCheckInClause КАК Clause,
	|	Reservations.NumberOfAdults + Reservations.NumberOfTeenagers + Reservations.NumberOfChildren + Reservations.NumberOfInfants КАК NumberOfGuestsOnArrival
	|ПОМЕСТИТЬ ExpectedCheckInGuests
	|ИЗ
	|	Документ.Reservation КАК Reservations
	|ГДЕ
	|	Reservations.Проведен
	|	И (Reservations.ReservationStatus.IsActive
	|			ИЛИ Reservations.ReservationStatus.IsPreliminary)
	|	И Reservations.CheckInDate >= &qBegOfToday
	|	И Reservations.CheckInDate <= &qEndOfToday
	|	И Reservations.Room <> ЗНАЧЕНИЕ(Catalog.Rooms.EmptyRef)
	|	И (&qHotelsListIsEmpty
	|			ИЛИ НЕ &qHotelsListIsEmpty
	|				И Reservations.Hotel В (&qHotelsList))
	|	И (&qParentIsEmpty
	|			ИЛИ НЕ &qParentIsEmpty
	|				И Reservations.Room В ИЕРАРХИИ (&qParent))
	|	И (&qRoomTypeIsEmpty
	|			ИЛИ НЕ &qRoomTypeIsEmpty
	|				И Reservations.RoomType В ИЕРАРХИИ (&qRoomType))
	|	И Reservations.AccommodationTemplate <> ЗНАЧЕНИЕ(Catalog.AccommodationTemplates.EmptyRef)
	|
	|СГРУППИРОВАТЬ ПО
	|	Reservations.Room,
	|	Reservations.Номер,
	|	Reservations.Customer,
	|	Reservations.ClientType,
	|	Reservations.AccommodationTemplate,
	|	ВЫРАЗИТЬ(Reservations.Remarks КАК СТРОКА(999)),
	|	ВЫРАЗИТЬ(Reservations.HousekeepingRemarks КАК СТРОКА(999)),
	|	Reservations.NumberOfAdults + Reservations.NumberOfTeenagers + Reservations.NumberOfChildren + Reservations.NumberOfInfants
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ExpectedRoomMove.Room КАК ToRoom,
	|	ExpectedRoomMove.Ссылка.Room КАК FromRoom,
	|	ExpectedRoomMove.Ссылка.Номер КАК DocumentNumber,
	|	ExpectedRoomMove.Ссылка.Customer КАК Customer,
	|	ExpectedRoomMove.Ссылка.ClientType КАК ClientType,
	|	ExpectedRoomMove.Ссылка.AccommodationTemplate КАК AccommodationTemplate,
	|	ВЫРАЗИТЬ(ExpectedRoomMove.Ссылка.Remarks КАК СТРОКА(999)) КАК Remarks,
	|	ВЫРАЗИТЬ(ExpectedRoomMove.Ссылка.HousekeepingRemarks КАК СТРОКА(999)) КАК HousekeepingRemarks,
	|	&qExpectedRoomMoveClause КАК Clause,
	|	ExpectedRoomMove.Ссылка.NumberOfAdults + ExpectedRoomMove.Ссылка.NumberOfTeenagers + ExpectedRoomMove.Ссылка.NumberOfChildren + ExpectedRoomMove.Ссылка.NumberOfInfants КАК NumberOfGuests
	|ПОМЕСТИТЬ ExpectedRoomMoveGuests
	|ИЗ
	|	Документ.Accommodation.RoomRates КАК ExpectedRoomMove
	|ГДЕ
	|	ExpectedRoomMove.Ссылка.Проведен
	|	И ExpectedRoomMove.Ссылка.AccommodationStatus.IsActive
	|	И ExpectedRoomMove.Ссылка.AccommodationStatus.IsInHouse
	|	И ExpectedRoomMove.Room <> ЗНАЧЕНИЕ(Catalog.Rooms.EmptyRef)
	|	И ExpectedRoomMove.Room <> ExpectedRoomMove.Ссылка.Room
	|	И ExpectedRoomMove.AccountingDate = &qBegOfToday
	|	И (&qHotelsListIsEmpty
	|			ИЛИ НЕ &qHotelsListIsEmpty
	|				И ExpectedRoomMove.Ссылка.Hotel В (&qHotelsList))
	|	И (&qParentIsEmpty
	|			ИЛИ НЕ &qParentIsEmpty
	|				И ExpectedRoomMove.Ссылка.Room В ИЕРАРХИИ (&qParent))
	|	И (&qRoomTypeIsEmpty
	|			ИЛИ НЕ &qRoomTypeIsEmpty
	|				И ExpectedRoomMove.Ссылка.RoomType В ИЕРАРХИИ (&qRoomType))
	|	И ExpectedRoomMove.Ссылка.AccommodationTemplate <> ЗНАЧЕНИЕ(Catalog.AccommodationTemplates.EmptyRef)
	|
	|СГРУППИРОВАТЬ ПО
	|	ExpectedRoomMove.Room,
	|	ExpectedRoomMove.Ссылка.Room,
	|	ExpectedRoomMove.Ссылка.Номер,
	|	ExpectedRoomMove.Ссылка.Customer,
	|	ExpectedRoomMove.Ссылка.ClientType,
	|	ExpectedRoomMove.Ссылка.AccommodationTemplate,
	|	ВЫРАЗИТЬ(ExpectedRoomMove.Ссылка.Remarks КАК СТРОКА(999)),
	|	ВЫРАЗИТЬ(ExpectedRoomMove.Ссылка.HousekeepingRemarks КАК СТРОКА(999)),
	|	ExpectedRoomMove.Ссылка.NumberOfAdults + ExpectedRoomMove.Ссылка.NumberOfTeenagers + ExpectedRoomMove.Ссылка.NumberOfChildren + ExpectedRoomMove.Ссылка.NumberOfInfants
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Accommodations.Room КАК Room,
	|	Accommodations.Customer КАК Customer,
	|	Accommodations.AccommodationTemplate КАК AccommodationTemplate,
	|	&qExpectedCheckOutClause КАК Clause,
	|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants КАК NumberOfCheckOutGuests
	|ПОМЕСТИТЬ ExpectedCheckOutGuests
	|ИЗ
	|	Документ.Accommodation КАК Accommodations
	|ГДЕ
	|	Accommodations.Проведен
	|	И Accommodations.AccommodationStatus.IsActive
	|	И Accommodations.AccommodationStatus.IsInHouse
	|	И Accommodations.AccommodationStatus.IsCheckOut
	|	И Accommodations.CheckOutDate >= &qBegOfToday
	|	И Accommodations.CheckOutDate <= &qEndOfToday
	|	И (&qHotelsListIsEmpty
	|			ИЛИ НЕ &qHotelsListIsEmpty
	|				И Accommodations.Hotel В (&qHotelsList))
	|	И (&qParentIsEmpty
	|			ИЛИ НЕ &qParentIsEmpty
	|				И Accommodations.Room В ИЕРАРХИИ (&qParent))
	|	И (&qRoomTypeIsEmpty
	|			ИЛИ НЕ &qRoomTypeIsEmpty
	|				И Accommodations.RoomType В ИЕРАРХИИ (&qRoomType))
	|	И Accommodations.AccommodationTemplate <> ЗНАЧЕНИЕ(Catalog.AccommodationTemplates.EmptyRef)
	|
	|СГРУППИРОВАТЬ ПО
	|	Accommodations.Room,
	|	Accommodations.Customer,
	|	Accommodations.AccommodationTemplate,
	|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Accommodations.Room КАК Room,
	|	Accommodations.AccommodationTemplate КАК AccommodationTemplate,
	|	&qCheckedOutClause КАК Clause,
	|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants КАК NumberOfCheckedOutGuests
	|ПОМЕСТИТЬ CheckedOutGuests
	|ИЗ
	|	Документ.Accommodation КАК Accommodations
	|ГДЕ
	|	Accommodations.Проведен
	|	И Accommodations.AccommodationStatus.IsActive
	|	И НЕ Accommodations.AccommodationStatus.IsInHouse
	|	И Accommodations.AccommodationStatus.IsCheckOut
	|	И Accommodations.CheckOutDate >= &qBegOfToday
	|	И Accommodations.CheckOutDate <= &qEndOfToday
	|	И (&qHotelsListIsEmpty
	|			ИЛИ НЕ &qHotelsListIsEmpty
	|				И Accommodations.Hotel В (&qHotelsList))
	|	И (&qParentIsEmpty
	|			ИЛИ НЕ &qParentIsEmpty
	|				И Accommodations.Room В ИЕРАРХИИ (&qParent))
	|	И (&qRoomTypeIsEmpty
	|			ИЛИ НЕ &qRoomTypeIsEmpty
	|				И Accommodations.RoomType В ИЕРАРХИИ (&qRoomType))
	|	И Accommodations.AccommodationTemplate <> ЗНАЧЕНИЕ(Catalog.AccommodationTemplates.EmptyRef)
	|
	|СГРУППИРОВАТЬ ПО
	|	Accommodations.Room,
	|	Accommodations.AccommodationTemplate,
	|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Accommodations.Room КАК Room,
	|	Accommodations.Customer КАК Customer,
	|	Accommodations.AccommodationTemplate КАК AccommodationTemplate,
	|	ВЫРАЗИТЬ(Accommodations.Remarks КАК СТРОКА(999)) КАК Remarks,
	|	ВЫРАЗИТЬ(Accommodations.HousekeepingRemarks КАК СТРОКА(999)) КАК HousekeepingRemarks,
	|	&qCheckedInClause КАК Clause,
	|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants КАК NumberOfCheckedInGuests
	|ПОМЕСТИТЬ CheckedInGuests
	|ИЗ
	|	Документ.Accommodation КАК Accommodations
	|ГДЕ
	|	Accommodations.Проведен
	|	И Accommodations.AccommodationStatus.IsActive
	|	И Accommodations.AccommodationStatus.IsInHouse
	|	И Accommodations.AccommodationStatus.IsCheckIn
	|	И Accommodations.CheckInDate >= &qBegOfToday
	|	И Accommodations.CheckInDate <= &qEndOfToday
	|	И (&qHotelsListIsEmpty
	|			ИЛИ НЕ &qHotelsListIsEmpty
	|				И Accommodations.Hotel В (&qHotelsList))
	|	И (&qParentIsEmpty
	|			ИЛИ НЕ &qParentIsEmpty
	|				И Accommodations.Room В ИЕРАРХИИ (&qParent))
	|	И (&qRoomTypeIsEmpty
	|			ИЛИ НЕ &qRoomTypeIsEmpty
	|				И Accommodations.RoomType В ИЕРАРХИИ (&qRoomType))
	|	И Accommodations.AccommodationTemplate <> ЗНАЧЕНИЕ(Catalog.AccommodationTemplates.EmptyRef)
	|
	|СГРУППИРОВАТЬ ПО
	|	Accommodations.Room,
	|	Accommodations.Customer,
	|	Accommodations.AccommodationTemplate,
	|	ВЫРАЗИТЬ(Accommodations.Remarks КАК СТРОКА(999)),
	|	ВЫРАЗИТЬ(Accommodations.HousekeepingRemarks КАК СТРОКА(999)),
	|	Accommodations.NumberOfAdults + Accommodations.NumberOfTeenagers + Accommodations.NumberOfChildren + Accommodations.NumberOfInfants
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	RoomBlocks.Room КАК Room,
	|	RoomBlocks.RoomBlockType КАК RoomBlockType,
	|	RoomBlocks.Номер КАК BlockNumber,
	|	ВЫРАЗИТЬ(RoomBlocks.Remarks КАК СТРОКА(999)) КАК RoomBlockRemarks
	|ПОМЕСТИТЬ RoomBlocks
	|ИЗ
	|	Документ.SetRoomBlock КАК RoomBlocks
	|ГДЕ
	|	RoomBlocks.Проведен
	|	И (&qHotelsListIsEmpty
	|			ИЛИ НЕ &qHotelsListIsEmpty
	|				И RoomBlocks.Hotel В (&qHotelsList))
	|	И RoomBlocks.DateFrom <= &qToday
	|	И (RoomBlocks.DateTo = &qEmptyDate
	|			ИЛИ RoomBlocks.DateTo <> &qEmptyDate
	|				И RoomBlocks.DateTo > &qToday)
	|	И (&qParentIsEmpty
	|			ИЛИ НЕ &qParentIsEmpty
	|				И RoomBlocks.Room В ИЕРАРХИИ (&qParent))
	|	И (&qRoomTypeIsEmpty
	|			ИЛИ НЕ &qRoomTypeIsEmpty
	|				И RoomBlocks.Room.RoomType В ИЕРАРХИИ (&qRoomType))
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ВЫБОР
	|		КОГДА Rooms.ЭтоГруппа
	|			ТОГДА 6
	|		ИНАЧЕ 7
	|	КОНЕЦ КАК Icon,
	|	Rooms.Наименование КАК Description,
	|	Rooms.RoomType КАК RoomType,
	|	Rooms.Floor КАК Floor,
	|	Rooms.RoomStatus КАК RoomStatus,
	|	RoomStatusChangeHistory.Период КАК RoomStatusLastChangeTime,
	|	ВЫРАЗИТЬ(Rooms.Remarks КАК СТРОКА(999)) КАК Remarks,
	|	Rooms.HasRoomBlocks КАК HasRoomBlocks,
	|	RoomBlocks.RoomBlockType КАК RoomBlockType,
	|	RoomBlocks.RoomBlockRemarks КАК RoomBlockRemarks,
	|	Rooms.StopSale КАК StopSale,
	|	Rooms.IsVirtual КАК IsVirtual,
	|	ВЫРАЗИТЬ(Rooms.RoomPropertiesCodes КАК СТРОКА(999)) КАК RoomPropertiesCodes,
	|	"""" КАК Condition,
	|	ExpectedCheckInGuests.Clause КАК ExpectedCheckInClause,
	|	CheckedInGuests.Clause КАК CheckedInClause,
	|	ExpectedRoomMoveGuests.Clause КАК ExpectedRoomMoveClause,
	|	InHouseGuests.Clause КАК InHouseClause,
	|	ExpectedCheckOutGuests.Clause КАК ExpectedCheckOutClause,
	|	CheckedOutGuests.Clause КАК CheckedOutClause,
	|	Rooms.SortCode КАК SortCode,
	|	Rooms.ЭтоГруппа КАК IsFolder,
	|	Rooms.Ссылка КАК Ref,
	|	Rooms.RoomType.NumberOfBedsPerRoom КАК NumberOfBedsPerRoom
	|ИЗ
	|	Справочник.Rooms КАК Rooms
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.RoomStatusChangeHistory.СрезПоследних(
	|				&qToday,
	|				&qHotelsListIsEmpty
	|					ИЛИ НЕ &qHotelsListIsEmpty
	|						И Room.Owner В (&qHotelsList)) КАК RoomStatusChangeHistory
	|		ПО (RoomStatusChangeHistory.Room = Rooms.Ссылка)
	|		ЛЕВОЕ СОЕДИНЕНИЕ ExpectedCheckInGuests КАК ExpectedCheckInGuests
	|		ПО (ExpectedCheckInGuests.Room = Rooms.Ссылка)
	|		ЛЕВОЕ СОЕДИНЕНИЕ CheckedInGuests КАК CheckedInGuests
	|		ПО (CheckedInGuests.Room = Rooms.Ссылка)
	|		ЛЕВОЕ СОЕДИНЕНИЕ ExpectedRoomMoveGuests КАК ExpectedRoomMoveGuests
	|		ПО (ExpectedRoomMoveGuests.FromRoom = Rooms.Ссылка
	|				ИЛИ ExpectedRoomMoveGuests.ToRoom = Rooms.Ссылка)
	|		ЛЕВОЕ СОЕДИНЕНИЕ InHouseGuests КАК InHouseGuests
	|		ПО (InHouseGuests.Room = Rooms.Ссылка)
	|		ЛЕВОЕ СОЕДИНЕНИЕ ExpectedCheckOutGuests КАК ExpectedCheckOutGuests
	|		ПО (ExpectedCheckOutGuests.Room = Rooms.Ссылка)
	|		ЛЕВОЕ СОЕДИНЕНИЕ CheckedOutGuests КАК CheckedOutGuests
	|		ПО (CheckedOutGuests.Room = Rooms.Ссылка)
	|		ЛЕВОЕ СОЕДИНЕНИЕ RoomBlocks КАК RoomBlocks
	|		ПО (RoomBlocks.Room = Rooms.Ссылка)
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.Расш1_СоставНомерногоФонда КАК Расш1_СоставНомерногоФонда
	|		ПО Rooms.Ссылка = Расш1_СоставНомерногоФонда.Номер
	|			И (Расш1_СоставНомерногоФонда.НомернойФонд = &НомернойФонд)
	|ГДЕ
	|	НЕ Rooms.ПометкаУдаления
	|	И Rooms.OperationStartDate < &qEndOfToday
	|	И (Rooms.OperationEndDate = ДАТАВРЕМЯ(1, 1, 1)
	|			ИЛИ Rooms.OperationEndDate > &qBegOfToday)
	|	И (&qHotelsListIsEmpty
	|			ИЛИ НЕ &qHotelsListIsEmpty
	|				И Rooms.Владелец В (&qHotelsList))
	|	И (&qParentIsEmpty
	|			ИЛИ НЕ &qParentIsEmpty
	|				И Rooms.Ссылка В ИЕРАРХИИ (&qParent))
	|	И (&qRoomTypeIsEmpty
	|			ИЛИ НЕ &qRoomTypeIsEmpty
	|				И Rooms.RoomType В ИЕРАРХИИ (&qRoomType))
	|	И (НЕ &qCheckedRoomBlock
	|			ИЛИ &qCheckedRoomBlock
	|				И RoomBlocks.Room <> ЗНАЧЕНИЕ(Document.SetRoomBlock.EmptyRef))
	|	И (&qRoomsListIsEmpty
	|			ИЛИ НЕ &qRoomsListIsEmpty
	|				И Rooms.Ссылка В (&qRoomsList))
	|
	|УПОРЯДОЧИТЬ ПО
	|	Rooms.Родитель,
	|	SortCode";
	
	vQry.SetParameter("НомернойФонд", НомернойФондПравый);
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
	//vQry.SetParameter("qRoomFloorIsEmpty", IsBlankString(SelFloor));
	//vQry.SetParameter("qRoomFloor", TrimAll(SelFloor));
	vQry.SetParameter("qCheckedRoomBlock", SelShowRoomsBlock);
	//vQry.SetParameter("qRoomsListIsEmpty", ?(vRoomsList.Count() > 0, False, True));
	vQry.SetParameter("qRoomsListIsEmpty", ?(vRoomsList.Count() > 0, False,?(Режим1 = 1, Истина, Ложь)));
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
	
	TableBoxRooms1.GetItems().Clear();
	TotalRoomsInList1 = 0;
	
	vCurParent = Undefined;
	vCurRoom = Undefined;
	
	For Each vRoomsRow In vRooms Do
		
		vDoAddRoom = True;
		If vCurRoom = vRoomsRow.Ref Then
			vDoAddRoom = False;
			If vRoomsRow.IsFolder Then
				Continue;
			EndIf;
		EndIf;
		
		vCurRoom = vRoomsRow.Ref;
		If ValueIsFilled(vCurRoom.Parent) Then
			vParentsRow = vParents.Find(vCurRoom.Parent, "Ref");
			If vParentsRow = Undefined Then
				vCurFolderItem = TableBoxRooms1;
			Else
				vCurFolderItem = vParentsRow.Item;
			EndIf;
		Else
			vCurFolderItem = TableBoxRooms1;
		EndIf;
		
		If vCurParent <> vCurRoom.Parent Then
			vCurParent = vCurRoom.Parent;
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
			TotalRoomsInList1 = TotalRoomsInList1 + 1;
			TotalBedsPerRoom1 = TotalBedsPerRoom1 + vRoomsRow.NumberOfBedsPerRoom;
			FillPropertyValues(vCurRoomItem, vRoomsRow);
			vCurRoomItem.RoomStatusIcon = GetRoomStatusIconIndex(vCurRoomItem.RoomStatus);
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
		
	EndDo;
	
	Return vRowId;
	
EndFunction //FillRoomsListAtServer

&НаКлиенте
Процедура НомернойФондПравыйПриИзменении(Элемент)
	
	FillRoomsListПравый();
	
	For Each vItem In TableBoxRooms1.GetItems() Do
		Items.TableBoxRooms1.Expand(vItem.GetID(), True);
	EndDo;
	
КонецПроцедуры

&AtClient
Procedure FillRoomsListПравый()
	
	vRowId = FillRoomsListAtServerПравый();
	
	If vRowId <> Undefined Then
		Items.TableBoxRooms1.CurrentRow = vRowId;
	EndIf;
	
EndProcedure 


&НаКлиенте
Процедура ПеренестиВлево(Команда)
	
	Если НомернойФондЛевый = НомернойФондПравый Тогда 
		Возврат;
	КонецЕсли;
	
	ТЗ_Номера.Очистить();
	
	Для каждого ВыделеннаяСтрока Из Items.TableBoxRooms1.ВыделенныеСтроки Цикл
		
		ЭлементДерево = Items.TableBoxRooms1.ДанныеСтроки(ВыделеннаяСтрока);
		
		Если ЭлементДерево.IsFolder тогда
			
			НайтиНомераРекурсивноПравая(ЭлементДерево.ПолучитьЭлементы()); 
			
		Иначе
			
			НоваяСтрока = ТЗ_Номера.Добавить();			
			НоваяСтрока.Ref = TableBoxRooms1.НайтиПоИдентификатору(ВыделеннаяСтрока).Ref;
			
		КонецЕсли;
		
	КонецЦикла;
	
	ПеренестиВыбранныеНомера("ВЛево");
	
	FillRoomsListПравый();
	
	For Each vItem In TableBoxRooms1.GetItems() Do
		Items.TableBoxRooms1.Expand(vItem.GetID(), True);
	EndDo;
	
	FillRoomsListЛевый();
	
	For Each vItem In TableBoxRooms.GetItems() Do
		Items.TableBoxRooms.Expand(vItem.GetID(), True);
	EndDo;
	
КонецПроцедуры

&НаКлиенте
Процедура ПеренестиВПраво(Команда)
	
	Если НомернойФондЛевый = НомернойФондПравый Тогда
		Возврат;
	КонецЕсли;
	
	ТЗ_Номера.Очистить();
	
	Для каждого ВыделеннаяСтрока Из Items.TableBoxRooms.ВыделенныеСтроки Цикл
		
		ЭлементДерево = Items.TableBoxRooms.ДанныеСтроки(ВыделеннаяСтрока);
		
		Если ЭлементДерево.IsFolder тогда
			
			НайтиНомераРекурсивноЛевая(ЭлементДерево.ПолучитьЭлементы()); 
			
		Иначе
			
			НоваяСтрока = ТЗ_Номера.Добавить();			
			НоваяСтрока.Ref = TableBoxRooms.НайтиПоИдентификатору(ВыделеннаяСтрока).Ref;
			
		КонецЕсли;
		
	КонецЦикла;
	
	ПеренестиВыбранныеНомера("ВПраво"); 
	
	FillRoomsListПравый();
	
	For Each vItem In TableBoxRooms1.GetItems() Do
		Items.TableBoxRooms1.Expand(vItem.GetID(), True);
	EndDo;
	
	FillRoomsListЛевый();
	
	For Each vItem In TableBoxRooms.GetItems() Do
		Items.TableBoxRooms.Expand(vItem.GetID(), True);
	EndDo;
	
КонецПроцедуры

&НаКлиенте
Процедура НайтиНомераРекурсивноЛевая(Строки)
	
	Для Каждого СтрокаДерева Из Строки Цикл
		
		ПодчиненныеСтроки  = СтрокаДерева.ПолучитьЭлементы();
		
		Если ПодчиненныеСтроки.Количество() > 0 Тогда
			
			НайтиНомераРекурсивноЛевая(ПодчиненныеСтроки);
			
		Иначе
			
			НоваяСтрока = ТЗ_Номера.Добавить();
			НоваяСтрока.Ref = TableBoxRooms.НайтиПоИдентификатору(СтрокаДерева.ПолучитьИдентификатор()).Ref;
			
			НоваяСтрока = ТЗ_ВыделенныеСтроки.Добавить();
			НоваяСтрока.Ref = TableBoxRooms.НайтиПоИдентификатору(СтрокаДерева.ПолучитьИдентификатор()).Ref;
			НоваяСтрока.КоличествоНомеров = 1;
			НоваяСтрока.КоличествоМест = TableBoxRooms.НайтиПоИдентификатору(СтрокаДерева.ПолучитьИдентификатор()).NumberOfBedsPerRoom;
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура НайтиНомераРекурсивноПравая(Строки)
	
	Для Каждого СтрокаДерева Из Строки Цикл
		
		ПодчиненныеСтроки  = СтрокаДерева.ПолучитьЭлементы();
		
		Если ПодчиненныеСтроки.Количество() > 0 Тогда
			
			НайтиНомераРекурсивноПравая(ПодчиненныеСтроки);
			
		Иначе
			
			НоваяСтрока = ТЗ_Номера.Добавить();
			НоваяСтрока.Ref = TableBoxRooms1.НайтиПоИдентификатору(СтрокаДерева.ПолучитьИдентификатор()).Ref;
			
			НоваяСтрока = ТЗ_ВыделенныеСтроки1.Добавить();
			НоваяСтрока.Ref = TableBoxRooms1.НайтиПоИдентификатору(СтрокаДерева.ПолучитьИдентификатор()).Ref;
			НоваяСтрока.КоличествоНомеров = 1;
			НоваяСтрока.КоличествоМест = TableBoxRooms1.НайтиПоИдентификатору(СтрокаДерева.ПолучитьИдентификатор()).NumberOfBedsPerRoom;
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура TableBoxRoomsВыбор(pItem, pSelectedRow, pField, pStandardProcessing)
	
	vCurData = Items.TableBoxRooms.CurrentData;
	If vCurData <> Undefined And Not vCurData.IsFolder Then
		If pField.Name <> "CatalogListRoomsRoomStatus" Then
			pStandardProcessing = False;
			OpenForm("Catalog.Rooms.Form.tcHousekeepingItemForm", New Structure("Key", vCurData.Ref));
		EndIf;
	EndIf;
	
КонецПроцедуры

&НаКлиенте
Процедура TableBoxRooms1Выбор(pItem, pSelectedRow, pField, pStandardProcessing)
	
	vCurData = Items.TableBoxRooms1.CurrentData;
	If vCurData <> Undefined And Not vCurData.IsFolder Then
		If pField.Name <> "CatalogListRoomsRoomStatus" Then
			pStandardProcessing = False;
			OpenForm("Catalog.Rooms.Form.tcHousekeepingItemForm", New Structure("Key", vCurData.Ref));
		EndIf;
	EndIf;
	
КонецПроцедуры

&НаКлиенте
Процедура SelRoomsFolderПриИзменении(Элемент)
	
	FillRoomsListЛевый();
	
	For Each vItem In TableBoxRooms.GetItems() Do
		Items.TableBoxRooms.Expand(vItem.GetID(), True);
	EndDo;
	
КонецПроцедуры

&НаКлиенте
Процедура SelRoomsFolder1ПриИзменении(Элемент)
	
	FillRoomsListПравый();
	
	For Each vItem In TableBoxRooms1.GetItems() Do
		Items.TableBoxRooms1.Expand(vItem.GetID(), True);
	EndDo;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Режим  = 1;
	Режим1 = 1;
	
	ВыделеноНомеров = 0;
	ВыделеноМест = 0;
	
	FillRoomsListПравый();
	
	For Each vItem In TableBoxRooms1.GetItems() Do
		Items.TableBoxRooms1.Expand(vItem.GetID(), True);
	EndDo;
	
	FillRoomsListЛевый();
	
	For Each vItem In TableBoxRooms.GetItems() Do
		Items.TableBoxRooms.Expand(vItem.GetID(), True);
	EndDo;
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	НомернойФондЛевый  = Справочники.Расш1_НомерныеФонды.ПустаяСсылка();
	НомернойФондПравый = Справочники.Расш1_НомерныеФонды.ПустаяСсылка();
	
КонецПроцедуры

&НаСервере
Процедура ПеренестиВыбранныеНомера(Куда)
	
	ОбъектТЗ = РеквизитФормыВЗначение("ТЗ_Номера");
	ОбъектТЗ.Свернуть("Ref");
	
	Для Каждого Строка Из ОбъектТЗ Цикл
		
		МенеджерЗаписи = РегистрыСведений.Расш1_СоставНомерногоФонда.СоздатьМенеджерЗаписи();
		МенеджерЗаписи.Номер = Строка.Ref;
		
		Если Куда = "ВПраво" Тогда
			МенеджерЗаписи.НомернойФонд = НомернойФондПравый;	
		ИначеЕсли Куда = "ВЛево" Тогда
			МенеджерЗаписи.НомернойФонд = НомернойФондЛевый;
		КонецЕсли;
		
		МенеджерЗаписи.Записать();
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура SelRoomType1ПриИзменении(Элемент)
	
	FillRoomsListПравый();
	
	For Each vItem In TableBoxRooms1.GetItems() Do
		Items.TableBoxRooms1.Expand(vItem.GetID(), True);
	EndDo;
	
КонецПроцедуры


&НаСервере
Function cmGetActiveRoomsListФорма(pHotel = Undefined, НомернойФонд) Export
	
	vList = New ValueList();
	vQry = New Query();
	vQry.Text = 
	"ВЫБРАТЬ
	|	Rooms.Ссылка КАК Ref
	|ИЗ
	|	Справочник.Rooms КАК Rooms
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.Расш1_СоставНомерногоФонда КАК Расш1_СоставНомерногоФонда
	|		ПО (Rooms.Ссылка = Расш1_СоставНомерногоФонда.Номер
	|				И Расш1_СоставНомерногоФонда.НомернойФонд = &НомернойФонд)
	|ГДЕ
	|	НЕ Rooms.ЭтоГруппа
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
	vQry.SetParameter("qDate", BegOfDay(CurrentSessionDate()));
	vQry.SetParameter("qEmptyDate", '00010101');
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("НомернойФонд", НомернойФонд);
	vQry.SetParameter("qHotelIsEmpty", Not ValueIsFilled(pHotel));
	vRooms = vQry.Execute().Unload();
	If vRooms.Count() > 0 Then
		vList.LoadValues(vRooms.UnloadColumn("Ref"));
	EndIf;
	Return vList;
EndFunction //cmGetActiveRoomsList

&НаКлиенте
Процедура РежимПриИзменении(Элемент)
	
	FillRoomsListЛевый();
	
	For Each vItem In TableBoxRooms.GetItems() Do
		Items.TableBoxRooms.Expand(vItem.GetID(), True);
	EndDo;
	
КонецПроцедуры

&НаКлиенте
Процедура Режим1ПриИзменении(Элемент)
	
	FillRoomsListПравый();
	
	For Each vItem In TableBoxRooms1.GetItems() Do
		Items.TableBoxRooms1.Expand(vItem.GetID(), True);
	EndDo;
	
КонецПроцедуры

&НаКлиенте
Процедура TableBoxRoomsПриАктивизацииСтроки(Элемент)
	
	AttachIdleHandler("ОбработатьВыделениеСтрокЛевый", 0.2, True);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьВыделениеСтрокЛевый()
	
	ТЗ_ВыделенныеСтроки.Очистить();
	
	Для каждого ВыделеннаяСтрока Из Items.TableBoxRooms.ВыделенныеСтроки Цикл
		
		ЭлементДерево = Items.TableBoxRooms.ДанныеСтроки(ВыделеннаяСтрока);
		
		Если ЭлементДерево.IsFolder тогда
			
			НайтиНомераРекурсивноЛевая(ЭлементДерево.ПолучитьЭлементы()); 
			
		Иначе
			
			НоваяСтрока = ТЗ_ВыделенныеСтроки.Добавить();			
			НоваяСтрока.Ref = TableBoxRooms.НайтиПоИдентификатору(ВыделеннаяСтрока).Ref;
			НоваяСтрока.КоличествоНомеров = 1;
			НоваяСтрока.КоличествоМест = TableBoxRooms.НайтиПоИдентификатору(ВыделеннаяСтрока).NumberOfBedsPerRoom;
			
			
		КонецЕсли;
		
	КонецЦикла;
	
	Для каждого Строка из ТЗ_ВыделенныеСтроки цикл
		
		Отбор = Новый Структура();
		Отбор.Вставить("Ref", Строка.Ref);
		
		Строки = ТЗ_ВыделенныеСтроки.НайтиСтроки(Отбор);
		
		Если Строки.Количество() > 1 Тогда
			Сч = 0;
			Пока Сч<Строки.Количество()-1 Цикл
				ТЗ_ВыделенныеСтроки.Удалить(Строки[Сч]);    
				Сч = Сч+1;
			КонецЦикла;
		КонецЕсли;        
	КонецЦикла;
	
	ВыделеноНомеров = ТЗ_ВыделенныеСтроки.Итог("КоличествоНомеров");
	ВыделеноМест = ТЗ_ВыделенныеСтроки.Итог("КоличествоМест");
	
КонецПроцедуры


&НаКлиенте
Процедура TableBoxRooms1ПриАктивизацииСтроки(Элемент)
	
	AttachIdleHandler("ОбработатьВыделениеСтрокПравый", 0.2, True);
		
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьВыделениеСтрокПравый()
	
	ТЗ_ВыделенныеСтроки1.Очистить();
	
	Для каждого ВыделеннаяСтрока Из Items.TableBoxRooms1.ВыделенныеСтроки Цикл
		
		ЭлементДерево = Items.TableBoxRooms1.ДанныеСтроки(ВыделеннаяСтрока);
		
		Если ЭлементДерево.IsFolder тогда
			
			НайтиНомераРекурсивноПравая(ЭлементДерево.ПолучитьЭлементы()); 
			
		Иначе
			
			НоваяСтрока = ТЗ_ВыделенныеСтроки1.Добавить();			
			НоваяСтрока.Ref = TableBoxRooms1.НайтиПоИдентификатору(ВыделеннаяСтрока).Ref;
			НоваяСтрока.КоличествоНомеров = 1;
			НоваяСтрока.КоличествоМест = TableBoxRooms1.НайтиПоИдентификатору(ВыделеннаяСтрока).NumberOfBedsPerRoom;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Для каждого Строка из ТЗ_ВыделенныеСтроки1 цикл
		
		Отбор = Новый Структура();
		Отбор.Вставить("Ref", Строка.Ref);
		
		Строки = ТЗ_ВыделенныеСтроки1.НайтиСтроки(Отбор);
		
		Если Строки.Количество() > 1 Тогда
			Сч = 0;
			Пока Сч<Строки.Количество()-1 Цикл
				ТЗ_ВыделенныеСтроки1.Удалить(Строки[Сч]);    
				Сч = Сч+1;
			КонецЦикла;
		КонецЕсли;        
	КонецЦикла;
	
	ВыделеноНомеров1 = ТЗ_ВыделенныеСтроки1.Итог("КоличествоНомеров");
	ВыделеноМест1 = ТЗ_ВыделенныеСтроки1.Итог("КоличествоМест");
	
КонецПроцедуры
