
&ChangeAndValidate("pmCheckDocumentAttributes")
Function Расш1_pmCheckDocumentAttributes(pPeriod, pIsPosted, pMessage, pAttributeInErr, pDoNotCheckRests)
	vHasErrors = False;
	pMessage = "";
	pAttributeInErr = "";
	vMsgTextRu = "";
	vMsgTextEn = "";
	vMsgTextDe = "";
	If Not ValueIsFilled(Hotel) Then
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Гостиница> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Hotel> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<Hotel> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "Hotel", pAttributeInErr);
	EndIf;
	If Not ValueIsFilled(Company) Then
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Фирма> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Company> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<Company> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "Company", pAttributeInErr);
	EndIf;
	If Not ValueIsFilled(ExchangeRateDate) Then
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Дата курса> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Exchange rate date> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<Exchange rate date> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "ExchangeRateDate", pAttributeInErr);
	EndIf;
	If Not ValueIsFilled(ReportingCurrency) Then
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Отчетная валюта> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Reporting currency> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<Reporting currency> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "ReportingCurrency", pAttributeInErr);
	EndIf;
	If ReportingCurrencyExchangeRate <= 0 Then
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Курс отчетной валюты> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Reporting currency exchange rate> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<Reporting currency exchange rate> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "ReportingCurrencyExchangeRate", pAttributeInErr);
	EndIf;
	If Not ValueIsFilled(GuestGroup) Then
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Номер группы> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Guest group> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<Guest group> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "GuestGroup", pAttributeInErr);
	EndIf;
	If Not ValueIsFilled(AccommodationStatus) Then
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Статус размещения> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Accommodation status> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<Accommodation status> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "AccommodationStatus", pAttributeInErr);
	EndIf;
	If Not ValueIsFilled(pPeriod.AccommodationType) Then
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Вид размещения> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Accommodation type> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<Accommodation type> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "AccommodationType", pAttributeInErr);
	ElsIf ValueIsFilled(Guest) And ValueIsFilled(CheckInDate) Then
		If Not ValueIsFilled(Guest.DateOfBirth) And GuestAge = 0 Then
			If AccommodationType.AllowedClientAgeFrom <> 0 Or 
				AccommodationType.AllowedClientAgeTo <> 0 Or 
				ValueIsFilled(AccommodationType.AllowedClientAgeRange) Then
				vMsgTextRu = vMsgTextRu + "Не указана дата рождения гостя " + TrimAll(Guest) + "!" + Chars.LF;
				vMsgTextEn = vMsgTextEn + "Date of birth is not specified for guest " + TrimAll(Guest) + "!" + Chars.LF;
				vMsgTextDe = vMsgTextDe + "Date of birth is not specified for guest " + TrimAll(Guest) + "!" + Chars.LF;
				pAttributeInErr = ?(pAttributeInErr = "", "Guest", pAttributeInErr);
				If Not cmCheckUserPermissions("HavePermissionToIgnoreGuestAgeLimitations") Then
					vHasErrors = True; 
				Else
					vWarning = NStr("ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';");
					If AdditionalProperties.Property("WarningMessage") Then
						AdditionalProperties.WarningMessage = AdditionalProperties.WarningMessage + ?(IsBlankString(AdditionalProperties.WarningMessage), "", Chars.LF) + vWarning;
					Else
						Message(vWarning, MessageStatus.Attention);
					EndIf;
				EndIf;
			EndIf;
		EndIf;
		vGuestAge = Guest.GetObject().pmGetClientAge(CheckInDate);
		If vGuestAge = 0 Then
			vGuestAge = GuestAge;
		EndIf;
		If Not (AccommodationType.AllowedClientAgeFrom = 0 And vGuestAge = 0) And AccommodationType.AllowedClientAgeFrom >= vGuestAge Then
			vMsgTextRu = vMsgTextRu + "Возраст гостя должен быть больше " + AccommodationType.AllowedClientAgeFrom + "!" + Chars.LF;
			vMsgTextEn = vMsgTextEn + "Guest has to be more then " + AccommodationType.AllowedClientAgeFrom + " years old!" + Chars.LF;
			vMsgTextDe = vMsgTextDe + "Guest has to be more then " + AccommodationType.AllowedClientAgeFrom + " years old!" + Chars.LF;
			pAttributeInErr = ?(pAttributeInErr = "", "Guest", pAttributeInErr);
			If Not cmCheckUserPermissions("HavePermissionToIgnoreGuestAgeLimitations") Then
				vHasErrors = True; 
			Else
				vWarning = NStr("ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';");
				If AdditionalProperties.Property("WarningMessage") Then
					AdditionalProperties.WarningMessage = AdditionalProperties.WarningMessage + ?(IsBlankString(AdditionalProperties.WarningMessage), "", Chars.LF) + vWarning;
				Else
					Message(vWarning, MessageStatus.Attention);
				EndIf;
			EndIf;
		EndIf;
		If AccommodationType.AllowedClientAgeTo > 0 And AccommodationType.AllowedClientAgeTo <= vGuestAge Then
			vMsgTextRu = vMsgTextRu + "Возраст гостя должен быть меньше " + AccommodationType.AllowedClientAgeTo + "!" + Chars.LF;
			vMsgTextEn = vMsgTextEn + "Guest has to be less then " + AccommodationType.AllowedClientAgeTo + " years old!" + Chars.LF;
			vMsgTextDe = vMsgTextDe + "Guest has to be less then " + AccommodationType.AllowedClientAgeTo + " years old!" + Chars.LF;
			pAttributeInErr = ?(pAttributeInErr = "", "Guest", pAttributeInErr);
			If Not cmCheckUserPermissions("HavePermissionToIgnoreGuestAgeLimitations") Then
				vHasErrors = True; 
			Else
				vWarning = NStr("ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';");
				If AdditionalProperties.Property("WarningMessage") Then
					AdditionalProperties.WarningMessage = AdditionalProperties.WarningMessage + ?(IsBlankString(AdditionalProperties.WarningMessage), "", Chars.LF) + vWarning;
				Else
					Message(vWarning, MessageStatus.Attention);
				EndIf;
			EndIf;
		EndIf;
		If ValueIsFilled(AccommodationType.AllowedClientAgeRange) Then
			vGuestAgeRange = Guest.GetObject().pmGetClientAgeRange(vGuestAge);
			If AccommodationType.AllowedClientAgeRange <> vGuestAgeRange Then
				vMsgTextRu = vMsgTextRu + "Возраст гостя должен быть в возрастной группе " + AccommodationType.AllowedClientAgeRange + "!" + Chars.LF;
				vMsgTextEn = vMsgTextEn + "Guest age has to be in " + AccommodationType.AllowedClientAgeRange + " age range group!" + Chars.LF;
				vMsgTextDe = vMsgTextDe + "Guest age has to be in " + AccommodationType.AllowedClientAgeRange + " age range group!" + Chars.LF;
				pAttributeInErr = ?(pAttributeInErr = "", "Guest", pAttributeInErr);
				If Not cmCheckUserPermissions("HavePermissionToIgnoreGuestAgeLimitations") Then
					vHasErrors = True; 
				Else
					vWarning = NStr("ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';");
					If AdditionalProperties.Property("WarningMessage") Then
						AdditionalProperties.WarningMessage = AdditionalProperties.WarningMessage + ?(IsBlankString(AdditionalProperties.WarningMessage), "", Chars.LF) + vWarning;
					Else
						Message(vWarning, MessageStatus.Attention);
					EndIf;
				EndIf;
			EndIf;
		EndIf;
	EndIf;
	If Not ValueIsFilled(pPeriod.RoomType) Then
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Тип номера> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Room type> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<Room type> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "RoomType", pAttributeInErr);
	Else
		If pPeriod.RoomType.IsVirtual Then
			If Not cmCheckUserPermissions("HavePermissionToUseVirtualRooms") Then
				vHasErrors = True; 
				vMsgTextRu = vMsgTextRu + "У вас нет прав на поселение гостей в виртуальные типы номеров!" + Chars.LF;
				vMsgTextEn = vMsgTextEn + "You do not have rights to check-in to the virtual room types!" + Chars.LF;
				vMsgTextDe = vMsgTextDe + "You do not have rights to check-in to the virtual room types!" + Chars.LF;
				pAttributeInErr = ?(pAttributeInErr = "", "RoomType", pAttributeInErr);
			EndIf;
		EndIf;
	EndIf;
	If Not ValueIsFilled(pPeriod.Room) Then
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Номер> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Room> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<Room> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "Room", pAttributeInErr);
	Else
		If pPeriod.Room.IsVirtual Then
			If Not cmCheckUserPermissions("HavePermissionToUseVirtualRooms") Then
				vHasErrors = True; 
				vMsgTextRu = vMsgTextRu + "У вас нет прав на поселение гостей в виртуальные номера!" + Chars.LF;
				vMsgTextEn = vMsgTextEn + "You do not have rights to check-in to the virtual rooms!" + Chars.LF;
				vMsgTextDe = vMsgTextDe + "You do not have rights to check-in to the virtual rooms!" + Chars.LF;
				pAttributeInErr = ?(pAttributeInErr = "", "Room", pAttributeInErr);
			EndIf;
		EndIf;
	EndIf;
	If Not ValueIsFilled(pPeriod.CheckInDate) Then
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Дата заезда> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Check in date> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<Check in date> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "CheckInDate", pAttributeInErr);
	EndIf;
	If Not ValueIsFilled(pPeriod.CheckOutDate) Then
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Дата выезда> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Check out date> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<Check out date> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "CheckOutDate", pAttributeInErr);
	EndIf;
	If ValueIsFilled(pPeriod.CheckInDate) And ValueIsFilled(pPeriod.CheckOutDate) Then
		If pPeriod.CheckInDate > pPeriod.CheckOutDate Then
			vHasErrors = True; 
			vMsgTextRu = vMsgTextRu + "Дата выезда должна быть позже даты заезда!" + Chars.LF;
			vMsgTextEn = vMsgTextEn + "Check out date should be after check in date!" + Chars.LF;
			vMsgTextDe = vMsgTextDe + "Check out date should be after check in date!" + Chars.LF;
			pAttributeInErr = ?(pAttributeInErr = "", "CheckOutDate", pAttributeInErr);
		Else
			If ValueIsFilled(Contract) Then
				If Contract.PeriodCheckType = 0 Then
					If ValueIsFilled(Contract.ValidFromDate) And 
						pPeriod.CheckInDate < BegOfDay(Contract.ValidFromDate) Or
						ValueIsFilled(Contract.ValidToDate) And
						pPeriod.CheckInDate > EndOfDay(Contract.ValidToDate) Then
						vHasErrors = True; 
						vMsgTextRu = vMsgTextRu + "Выбранный договор не действует на указанном периоде проживания!" + Chars.LF;
						vMsgTextEn = vMsgTextEn + "Contract is not valid on period selected!" + Chars.LF;
						vMsgTextDe = vMsgTextDe + "Contract is not valid on period selected!" + Chars.LF;
						pAttributeInErr = ?(pAttributeInErr = "", "Contract", pAttributeInErr);
					EndIf;
				ElsIf Contract.PeriodCheckType = 1 And Not IsByReservation Then
					If ValueIsFilled(Contract.ValidFromDate) And 
						Date < BegOfDay(Contract.ValidFromDate) Or
						ValueIsFilled(Contract.ValidToDate) And
						Date > EndOfDay(Contract.ValidToDate) Then
						vHasErrors = True; 
						vMsgTextRu = vMsgTextRu + "Выбранный договор не действует на дату создания размещения!" + Chars.LF;
						vMsgTextEn = vMsgTextEn + "Contract is not valid on accommodation creation date!" + Chars.LF;
						vMsgTextDe = vMsgTextDe + "Contract is not valid on accommodation creation date!" + Chars.LF;
						pAttributeInErr = ?(pAttributeInErr = "", "Contract", pAttributeInErr);
					EndIf;
				EndIf;
			EndIf;
		EndIf;
	EndIf;
	If Not cmCheckUserPermissions("HavePermissionToDoCheckInWithEmptyGuest") Then
		If Not ValueIsFilled(Guest) Then
			vHasErrors = True; 
			vMsgTextRu = vMsgTextRu + "Не указан гость!" + Chars.LF;
			vMsgTextEn = vMsgTextEn + "Guest should be filled!" + Chars.LF;
			vMsgTextDe = vMsgTextDe + "Guest should be filled!" + Chars.LF;
			pAttributeInErr = ?(pAttributeInErr = "", "Guest", pAttributeInErr);
		EndIf;
	EndIf;
	If ValueIsFilled(Guest) Then
		If Guest.DoNotCheckIn Then
			If Not cmCheckUserPermissions("HavePermissionToIgnoreBlackListLimitations") Then
				vHasErrors = True; 
				vMsgTextRu = vMsgTextRu + "У гостя установлен режим запрета поселения!" + Chars.LF;
				vMsgTextEn = vMsgTextEn + "Guest check-in is forbidden!" + Chars.LF;
				vMsgTextDe = vMsgTextDe + "Guest check-in is forbidden!" + Chars.LF;
				pAttributeInErr = ?(pAttributeInErr = "", "Guest", pAttributeInErr);
			EndIf;
		EndIf;
	EndIf;
	If BegOfDay(pPeriod.CheckInDate) = BegOfDay(CurrentSessionDate()) And ValueIsFilled(AccommodationStatus) And AccommodationStatus.IsActive And 
		AccommodationStatus.IsCheckIn And AccommodationStatus.IsInHouse And 
		ValueIsFilled(pPeriod.Room) And ValueIsFilled(pPeriod.Room.RoomStatus) Then
		If pPeriod.Room.RoomStatus.CheckInIsForbidden Then
			If Not cmCheckUserPermissions("HavePermissionToCheckInToRoomsWithForbiddenStatus") Then
				vHasErrors = True; 
				vMsgTextRu = vMsgTextRu + "У вас нет прав на поселение гостя в номер со статусом " + TrimAll(pPeriod.Room.RoomStatus) + "!" + Chars.LF;
				vMsgTextEn = vMsgTextEn + "You do not have rights to check-in guest to the room with " + TrimAll(pPeriod.Room.RoomStatus) + " status!" + Chars.LF;
				vMsgTextDe = vMsgTextDe + "You do not have rights to check-in guest to the room with " + TrimAll(pPeriod.Room.RoomStatus) + " status!" + Chars.LF;
				pAttributeInErr = ?(pAttributeInErr = "", "Room", pAttributeInErr);
			EndIf;
		EndIf;
	EndIf;
	If Not ValueIsFilled(BoardPlace) Then
		If Not cmCheckUserPermissions("HavePermissionToSkipBoardPlaceSetting") And Not pDoNotCheckRests Then
			vBoardPlaces = cmGetBoardPlaces(Hotel);
			If vBoardPlaces.Count() > 0 Then
				vHasErrors = True; 
				vMsgTextRu = vMsgTextRu + "У вас нет прав на поселение гостя без указания места питания!" + Chars.LF;
				vMsgTextEn = vMsgTextEn + "You do not have rights to check-in guest with no board place setting!" + Chars.LF;
				vMsgTextDe = vMsgTextDe + "Es gibt kein Rechte auf Nahrung nicht in der Reservierung angeben!" + Chars.LF;
				pAttributeInErr = ?(pAttributeInErr = "", "BoardPlace", pAttributeInErr);
			EndIf;
		EndIf;
	EndIf;
	If ValueIsFilled(AccommodationStatus) And IsPeriodOfStayExtension() Then
		If ValueIsFilled(RoomType) Then
			If RoomType.StopSale And NumberOfBeds > 0 Then
				vRes = pmGetParentReservation();
				vIgnoreStopSaleFlag = False;
				If ValueIsFilled(vRes) And
					(vRes.RoomType = RoomType) And (vRes.CheckOutDate >= CheckOutDate) Then
					vIgnoreStopSaleFlag = True;
				EndIf;
				If Not vIgnoreStopSaleFlag Then
					vRemarks = "";
					If cmIsStopSalePeriod(RoomType, CheckInDate, CheckOutDate, vRemarks) Then
						If Not cmCheckUserPermissions("HavePermissionToIgnoreStopSaleLimitations") Then
							vHasErrors = True; 
							vMsgTextRu = vMsgTextRu + "Выбранный тип номера снят с продажи!" + Chars.LF + ?(IsBlankString(vRemarks), "", vRemarks + Chars.LF);
							vMsgTextEn = vMsgTextEn + "Room type choosen is out of sale!" + Chars.LF + ?(IsBlankString(vRemarks), "", vRemarks + Chars.LF);
							vMsgTextDe = vMsgTextDe + "Room type choosen is out of sale!" + Chars.LF + ?(IsBlankString(vRemarks), "", vRemarks + Chars.LF);
							pAttributeInErr = ?(pAttributeInErr = "", "RoomType", pAttributeInErr);
						EndIf;
					EndIf;
				EndIf;
			EndIf;
		EndIf;
		If ValueIsFilled(Room) Then
			If Room.StopSale And NumberOfBeds > 0 Then
				vRes = pmGetParentReservation();
				vIgnoreStopSaleFlag = False;
				If ValueIsFilled(vRes) And
					(vRes.Room = Room) And (vRes.CheckOutDate >= CheckOutDate) Then
					vIgnoreStopSaleFlag = True;
				EndIf;
				If Not vIgnoreStopSaleFlag Then
					vRemarks = "";
					If cmIsRoomStopSalePeriod(Room, CheckInDate, CheckOutDate, vRemarks) Then
						If Not cmCheckUserPermissions("HavePermissionToIgnoreStopSaleLimitations") Then
							vHasErrors = True; 
							vMsgTextRu = vMsgTextRu + "Выбранный номер снят с продажи!" + Chars.LF + ?(IsBlankString(vRemarks), "", vRemarks + Chars.LF);
							vMsgTextEn = vMsgTextEn + "Room choosen is out of sale!" + Chars.LF + ?(IsBlankString(vRemarks), "", vRemarks + Chars.LF);
							vMsgTextDe = vMsgTextDe + "Room choosen is out of sale!" + Chars.LF + ?(IsBlankString(vRemarks), "", vRemarks + Chars.LF);
							pAttributeInErr = ?(pAttributeInErr = "", "Room", pAttributeInErr);
						EndIf;
					EndIf;
				EndIf;
			EndIf;
		EndIf;
	EndIf;
	If Not pDoNotCheckRests And ValueIsFilled(AccommodationStatus) Then
		If AccommodationStatus.IsActive Then
			vMsgTextRu = ""; vMsgTextEn = ""; vMsgTextde = "";
			If Max(CurrentSessionDate(), pPeriod.CheckInDate) < pPeriod.CheckOutDate Then
				If Not cmCheckRoomAvailability(Hotel, RoomQuota, pPeriod.RoomType, pPeriod.Room, Ref, pIsPosted, CheckRoomTypeBalances(),
					pPeriod.NumberOfPersons, pPeriod.NumberOfRooms, pPeriod.NumberOfBeds, pPeriod.NumberOfAdditionalBeds, 
					pPeriod.NumberOfBedsPerRoom, pPeriod.NumberOfPersonsPerRoom, Max(CurrentSessionDate(), pPeriod.CheckInDate), pPeriod.CheckOutDate, 
					vMsgTextRu, vMsgTextEn, vMsgTextDe) Then
					vHasErrors = True; 
					pAttributeInErr = ?(pAttributeInErr = "", "CheckInDate", pAttributeInErr);
				ElsIf Not IsBlankString(vMsgTextRu) Or Not IsBlankString(vMsgTextEn) Or Not IsBlankString(vMsgTextDe) Then
					vWarning = NStr("ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';");
					If AdditionalProperties.Property("WarningMessage") Then
						AdditionalProperties.WarningMessage = AdditionalProperties.WarningMessage + ?(IsBlankString(AdditionalProperties.WarningMessage), "", Chars.LF) + vWarning;
					EndIf;
				EndIf;
			EndIf;
			If ValueIsFilled(RoomQuota) And ValueIsFilled(pPeriod.AccommodationType) And 
				(pPeriod.AccommodationType.Type = Enums.AccomodationTypes.Beds Or pPeriod.AccommodationType.Type = Enums.AccomodationTypes.Room) Then
				If RoomQuota.CustomerOrContractChangeIsNotAllowed Then
					If RoomQuota.Customer <> Customer Or
						RoomQuota.Contract <> Contract Then
						vHasErrors = True; 
						vMsgTextRu = vMsgTextRu + "Поселение с указанием контрагента/договора отличных от них в выбранной квоте запрещено!" + Chars.LF;
						vMsgTextEn = vMsgTextEn + "It is not allowed to check-in with customer/contract different from them in allotment choosen!" + Chars.LF;
						vMsgTextDe = vMsgTextDe + "It is not allowed to check-in with customer/contract different from them in allotment choosen!" + Chars.LF;
						pAttributeInErr = ?(pAttributeInErr = "", "RoomQuota", pAttributeInErr);
					EndIf;
				EndIf;
				vRoomType = pPeriod.RoomType;
				If ValueIsFilled(RoomTypeUpgrade) And ValueIsFilled(RoomTypeUpgrade.BaseRoomType) And pPeriod.RoomType = RoomTypeUpgrade.BaseRoomType Then
					vRoomType = RoomTypeUpgrade;
				EndIf;
				vMsgTextRu = ""; vMsgTextEn = ""; vMsgTextde = "";
				If Max(CurrentSessionDate(), pPeriod.CheckInDate) < pPeriod.CheckOutDate Then
					If Not cmCheckRoomQuotaAvailability(RoomQuota.Agent, RoomQuota.Customer, RoomQuota.Contract, RoomQuota, 
						Hotel, vRoomType, pPeriod.Room, Ref, pIsPosted, False,
						pPeriod.NumberOfRooms, pPeriod.NumberOfBeds, 
						Max(CurrentSessionDate(), pPeriod.CheckInDate), pPeriod.CheckOutDate, 
						vMsgTextRu, vMsgTextEn, vMsgTextDe) Then
						vHasErrors = True; 
						pAttributeInErr = ?(pAttributeInErr = "", "CheckInDate", pAttributeInErr);
					ElsIf Not IsBlankString(vMsgTextRu) Or Not IsBlankString(vMsgTextEn) Or Not IsBlankString(vMsgTextDe) Then
						vWarning = NStr("ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';");
						If AdditionalProperties.Property("WarningMessage") Then
							AdditionalProperties.WarningMessage = AdditionalProperties.WarningMessage + ?(IsBlankString(AdditionalProperties.WarningMessage), "", Chars.LF) + vWarning;
						EndIf;
					EndIf;
					If Not IsByReservation And ValueIsFilled(AccommodationStatus) And 
						AccommodationStatus.IsActive And AccommodationStatus.IsInHouse Then
						If RoomQuota.IsForCheckInPeriods And pPeriod.CheckInDate = CheckInDate Then
							vMsgTextRu = ""; vMsgTextEn = ""; vMsgTextde = "";
							If Not cmCheckCheckInPeriods(Hotel, RoomQuota, CheckInDate, CheckOutDate) Then
								vHasErrors = True; 
								vMsgTextRu = vMsgTextRu + "Указанный срок проживания не попадает на границы заездов!" + Chars.LF;
								vMsgTextEn = vMsgTextEn + "Accommodation period specified is out from the check-in period dates!" + Chars.LF;
								vMsgTextDe = vMsgTextDe + "Accommodation period specified is out from the check-in period dates!" + Chars.LF;
								pAttributeInErr = ?(pAttributeInErr = "", "CheckOutDate", pAttributeInErr);
							EndIf;
						EndIf;
					EndIf;
				EndIf;
			EndIf;
			// Get and check room rate restrictions
			If ValueIsFilled(RoomRate) And BegOfDay(CheckInDate) >= BegOfDay(CurrentSessionDate()) And AccommodationStatus.IsCheckIn And AccommodationStatus.IsInHouse Then 
				// Fill effective period
				vCheckInDate = CheckInDate;
				vCheckOutDate = CheckOutDate;
				vReservationCheckInDate = vCheckInDate;
				vReservationCheckOutDate = vCheckOutDate;
				If IsByReservation Then
					If ValueIsFilled(Reservation) Then
						vReservationCheckInDate = Reservation.CheckInDate;
						vReservationCheckOutDate = Reservation.CheckOutDate;
					EndIf;
				EndIf;
				If ValueIsFilled(HotelProduct) And Not HotelProduct.IsFolder Then
					If HotelProduct.FixProductPeriod Then
						vCheckInDate = HotelProduct.CheckInDate;
						vCheckOutDate = HotelProduct.CheckOutDate;
					EndIf;
				EndIf;
				If FixReservationConditions And IsByReservation Then
					vSavCheckInDate = vCheckInDate;
					vSavCheckOutDate = vCheckOutDate;
					If ValueIsFilled(ParentDoc) And TypeOf(ParentDoc) = Type("DocumentRef.Reservation") Then
						vCheckInDate = Min(CheckInDate, vReservationCheckInDate);
					Else
						vReservationCheckInDate = vCheckInDate;
					EndIf;
					If AccommodationStatus.IsCheckOut Then
						vSkipCheck = True;
						If IsNew() Then
							vSkipCheck = False;
						EndIf;
						If vSkipCheck Then 
							// Check that there is no accommodation where current one is parent document
							vQry = New Query();
							vQry.Text = 
							"SELECT
							|	Accommodation.Ref
							|FROM
							|	Document.Accommodation AS Accommodation
							|WHERE
							|	Accommodation.Posted
							|	AND Accommodation.ParentDoc = &qParentDoc
							|	AND Accommodation.CheckInDate > &qCheckInDate
							|	AND Accommodation.AccommodationStatus.IsActive";
							vQry.SetParameter("qParentDoc", Ref);
							vQry.SetParameter("qCheckInDate", CheckInDate);
							vNextDocs = vQry.Execute().Unload();
							If vNextDocs.Count() = 0 Then
								vSkipCheck = False;
							EndIf;
						EndIf;
						If Not vSkipCheck Then
							vCheckOutDate = Max(CheckOutDate, vReservationCheckOutDate);
						Else
							vReservationCheckOutDate = vCheckOutDate;
						EndIf;
					EndIf;
					If vCheckOutDate <= vCheckInDate Then
						vCheckInDate = vSavCheckInDate;
						vCheckOutDate = vSavCheckOutDate;
						If Not (ValueIsFilled(ParentDoc) And TypeOf(ParentDoc) = Type("DocumentRef.Reservation")) Then
							vReservationCheckInDate = vCheckInDate;
							vReservationCheckOutDate = vCheckOutDate;
						EndIf;
					EndIf;
				EndIf;
				If Not IsByReservation Then
					vRoomRateHasChanged = False;
					vLastDocState = pmGetPreviousObjectState(CurrentSessionDate());
					If vLastDocState <> Undefined Then
						If RoomRate <> vLastDocState.RoomRate Or 
							BegOfDay(CheckInDate) <> BegOfDay(vLastDocState.CheckInDate) Or 
							BegOfDay(CheckOutDate) <> BegOfDay(vLastDocState.CheckOutDate) Or 
							RoomType <> vLastDocState.RoomType Then
							vRoomRateHasChanged = True;
						EndIf;
					Else
						vRoomRateHasChanged = True;
					EndIf;
					If Not Posted Or vRoomRateHasChanged Then
						vRestrStruct = RoomRate.GetObject().pmGetRoomRateRestrictions(vCheckInDate, vCheckOutDate, ?(ValueIsFilled(RoomTypeUpgrade), RoomTypeUpgrade, RoomType), True);
						If vRestrStruct.StopSale Then
							vHasErrors = True; 
							vMsgTextRu = vMsgTextRu + "Продажи по тарифу " + TrimAll(RoomRate) + " остановлены на периоде с " + Format(vCheckInDate, "DF=dd.MM.yyyy") + " по " + Format(vCheckOutDate, "DF=dd.MM.yyyy") + " в ограничениях тарифа (Stop Sale включен)!" + Chars.LF;
							vMsgTextEn = vMsgTextEn + "Room rate " + TrimAll(RoomRate) + " could not be used for the given period " + Format(vCheckInDate, "DF=dd.MM.yyyy") + " - " + Format(vCheckOutDate, "DF=dd.MM.yyyy") + " (room rate restriction Stop Sales is turned on)!" + Chars.LF;
							vMsgTextDe = vMsgTextDe + "Tariff " + TrimAll(RoomRate) + " ist geschlossen (Tariff Einschränkung Stop Sale ist auf), periode " + Format(vCheckInDate, "DF=dd.MM.yyyy") + " - " + Format(vCheckOutDate, "DF=dd.MM.yyyy") + "!" + Chars.LF;
							pAttributeInErr = ?(pAttributeInErr = "", "RoomRate", pAttributeInErr);
						EndIf;
						If vRestrStruct.CTA Then
							vHasErrors = True; 
							vMsgTextRu = vMsgTextRu + "Заезд в выбранную дату " + Format(vCheckInDate, "DF=dd.MM.yyyy") + " запрещен в ограничениях указанных у тарифа (CTA включен)!" + Chars.LF;
							vMsgTextEn = vMsgTextEn + "Check-in is closed (CTA is On) for the given check-in date " + Format(vCheckInDate, "DF=dd.MM.yyyy") + "!" + Chars.LF;
							vMsgTextDe = vMsgTextDe + "Check-in ist fur den Check-in-Datum " + Format(vCheckInDate, "DF=dd.MM.yyyy") + " geschlossen (CTA is On)!" + Chars.LF;
							pAttributeInErr = ?(pAttributeInErr = "", "CheckInDate", pAttributeInErr);
						EndIf;
						If vRestrStruct.CTD Then
							vHasErrors = True; 
							vMsgTextRu = vMsgTextRu + "Выезд в выбранную дату " + Format(vCheckOutDate, "DF=dd.MM.yyyy") + " запрещен в ограничениях указанных у тарифа (CTD включен)!" + Chars.LF;
							vMsgTextEn = vMsgTextEn + "Check-out is closed (CTD is On) for the given check-out date " + Format(vCheckOutDate, "DF=dd.MM.yyyy") + "!" + Chars.LF;
							vMsgTextDe = vMsgTextDe + "Check-out ist fur den Check-out-Datum " + Format(vCheckOutDate, "DF=dd.MM.yyyy") + " geschlossen (CTD is On)!" + Chars.LF;
							pAttributeInErr = ?(pAttributeInErr = "", "CheckOutDate", pAttributeInErr);
						EndIf;
						If vRestrStruct.MLOS > 0 And Duration < vRestrStruct.MLOS And RoomRate.MLOSIsBlocking And ValueIsFilled(AccommodationStatus) And AccommodationStatus.IsCheckOut And AccommodationStatus.IsActive And Not FixReservationConditions Then
							vHasErrors = True; 
							vMsgTextRu = vMsgTextRu + "Минимальная продолжительность проживания " + vRestrStruct.MLOS + " дней!" + Chars.LF;
							vMsgTextEn = vMsgTextEn + "Minimum length of stay is " + vRestrStruct.MLOS + "!" + Chars.LF;
							vMsgTextDe = vMsgTextDe + "Mindestaufenthaltsdauer betragt " + vRestrStruct.MLOS + " Tage!" + Chars.LF;
							pAttributeInErr = ?(pAttributeInErr = "", "CheckInDate", pAttributeInErr);
						EndIf;
						If vRestrStruct.MaxLOS > 0 And Duration > vRestrStruct.MaxLOS Then
							vHasErrors = True; 
							vMsgTextRu = vMsgTextRu + "Максимальная продолжительность проживания " + vRestrStruct.MaxLOS + " дней!" + Chars.LF;
							vMsgTextEn = vMsgTextEn + "Maximum length of stay is " + vRestrStruct.MaxLOS + "!" + Chars.LF;
							vMsgTextDe = vMsgTextDe + "Maximaleaufenthaltsdauer betragt " + vRestrStruct.MaxLOS + " Tage!" + Chars.LF;
							pAttributeInErr = ?(pAttributeInErr = "", "CheckOutDate", pAttributeInErr);
						EndIf;
						If vRestrStruct.MinDaysBeforeCheckIn > 0 And ValueIsFilled(AccommodationType) And (AccommodationType.Type = Enums.AccomodationTypes.Room Or AccommodationType.Type = Enums.AccomodationTypes.Beds) Then
							vDate = GuestGroup.CreateDate;
							vDaysBeforeCheckIn = Int((BegOfDay(vCheckInDate) - BegOfDay(vDate))/(24*3600));
							If vDaysBeforeCheckIn < vRestrStruct.MinDaysBeforeCheckIn Then
								vHasErrors = True; 
								vMsgTextRu = vMsgTextRu + "Минимальное кол-во дней от даты бронирования до даты заезда " + vRestrStruct.MinDaysBeforeCheckIn + "!" + Chars.LF;
								vMsgTextEn = vMsgTextEn + "Minimum days between booking and check-in dates is " + vRestrStruct.MinDaysBeforeCheckIn + "!" + Chars.LF;
								vMsgTextDe = vMsgTextDe + "Mindest Tage zwischen Buchung und Check-in Daten ist " + vRestrStruct.MinDaysBeforeCheckIn + "!" + Chars.LF;
								pAttributeInErr = ?(pAttributeInErr = "", "CheckInDate", pAttributeInErr);
							EndIf;
						EndIf;
						If vRestrStruct.MaxDaysBeforeCheckIn > 0 And ValueIsFilled(AccommodationType) And (AccommodationType.Type = Enums.AccomodationTypes.Room Or AccommodationType.Type = Enums.AccomodationTypes.Beds) Then
							vDate = GuestGroup.CreateDate;
							vDaysBeforeCheckIn = Int((BegOfDay(vCheckInDate) - BegOfDay(vDate))/(24*3600));
							If vDaysBeforeCheckIn > vRestrStruct.MaxDaysBeforeCheckIn Then
								vHasErrors = True; 
								vMsgTextRu = vMsgTextRu + "Максимальное кол-во дней от даты бронирования до даты заезда " + vRestrStruct.MaxDaysBeforeCheckIn + "!" + Chars.LF;
								vMsgTextEn = vMsgTextEn + "Maximum days between booking and check-in dates is " + vRestrStruct.MaxDaysBeforeCheckIn + "!" + Chars.LF;
								vMsgTextDe = vMsgTextDe + "Maximale Tage zwischen Buchung und Check-in Daten ist " + vRestrStruct.MaxDaysBeforeCheckIn + "!" + Chars.LF;
								pAttributeInErr = ?(pAttributeInErr = "", "CheckInDate", pAttributeInErr);
							EndIf;
						EndIf;
					EndIf;
				EndIf;
			EndIf;
		EndIf;
	EndIf;
	// Check that there is no change room attributes in the period selected
	If ValueIsFilled(Room) And ValueIsFilled(CheckInDate) And ValueIsFilled(CheckOutDate) Then
		If TypeOf(pPeriod) <> Type("DocumentObject.Accommodation") Then
			vChangeRoomAttrs = cmGetChangeRoomAttributes(pPeriod.Room, pPeriod.CheckInDate, pPeriod.CheckOutDate);
#Delete
			If vChangeRoomAttrs.Count() > 0 Then
				vHasErrors = True; 
				vMsgTextRu = vMsgTextRu + "В плане размещения не должно быть не учтенных изменений параметров выбранного номера!" + Chars.LF;
				vMsgTextEn = vMsgTextEn + "There should be no missed change room attributes in the accommodation plan!" + Chars.LF;
				vMsgTextDe = vMsgTextDe + "There should be no missed change room attributes in the accommodation plan!" + Chars.LF;
				pAttributeInErr = ?(pAttributeInErr = "", "Room", pAttributeInErr);
			EndIf;
#EndDelete
#Insert
// Здесь можно описать новое поведение.
			//If vChangeRoomAttrs.Count() > 0 Then
			//	vHasErrors = True; 
			//	vMsgTextRu = vMsgTextRu + "В плане размещения не должно быть не учтенных изменений параметров выбранного номера!" + Chars.LF;
			//	vMsgTextEn = vMsgTextEn + "There should be no missed change room attributes in the accommodation plan!" + Chars.LF;
			//	vMsgTextDe = vMsgTextDe + "There should be no missed change room attributes in the accommodation plan!" + Chars.LF;
			//	pAttributeInErr = ?(pAttributeInErr = "", "Room", pAttributeInErr);
			//EndIf;

#EndInsert
		EndIf;
	EndIf;
	// Check charging rules
	For Each vCRRow In ChargingRules Do
		If vCRRow.ChargingRule = Enums.ChargingRuleTypes.AllButOne And Not ValueIsFilled(vCRRow.ChargingRuleValue) Then
			vHasErrors = True; 
			vMsgTextRu = vMsgTextRu + "В правилах начисления в строке " + Format(vCRRow.LineNumber, "ND=4; NFD=0; NG=") + " не указана услуга!" + Chars.LF;
			vMsgTextEn = vMsgTextEn + "Service is not filled in the charging rules row number " + Format(vCRRow.LineNumber, "ND=4; NFD=0; NG=") + "!" + Chars.LF;
			vMsgTextDe = vMsgTextDe + "Service is not filled in the charging rules row number " + Format(vCRRow.LineNumber, "ND=4; NFD=0; NG=") + "!" + Chars.LF;
			pAttributeInErr = ?(pAttributeInErr = "", "ChargingRules", pAttributeInErr);
		ElsIf vCRRow.ChargingRule = Enums.ChargingRuleTypes.InServiceGroup And Not ValueIsFilled(vCRRow.ChargingRuleValue) Then
			vHasErrors = True; 
			vMsgTextRu = vMsgTextRu + "В правилах начисления в строке " + Format(vCRRow.LineNumber, "ND=4; NFD=0; NG=") + " не указан набор услуг!" + Chars.LF;
			vMsgTextEn = vMsgTextEn + "Service group is not filled in the charging rules row number " + Format(vCRRow.LineNumber, "ND=4; NFD=0; NG=") + "!" + Chars.LF;
			vMsgTextDe = vMsgTextDe + "Service group is not filled in the charging rules row number " + Format(vCRRow.LineNumber, "ND=4; NFD=0; NG=") + "!" + Chars.LF;
			pAttributeInErr = ?(pAttributeInErr = "", "ChargingRules", pAttributeInErr);
		ElsIf vCRRow.ChargingRule = Enums.ChargingRuleTypes.One And Not ValueIsFilled(vCRRow.ChargingRuleValue) Then
			vHasErrors = True; 
			vMsgTextRu = vMsgTextRu + "В правилах начисления в строке " + Format(vCRRow.LineNumber, "ND=4; NFD=0; NG=") + " не указана услуга!" + Chars.LF;
			vMsgTextEn = vMsgTextEn + "Service is not filled in the charging rules row number " + Format(vCRRow.LineNumber, "ND=4; NFD=0; NG=") + "!" + Chars.LF;
			vMsgTextDe = vMsgTextDe + "Service is not filled in the charging rules row number " + Format(vCRRow.LineNumber, "ND=4; NFD=0; NG=") + "!" + Chars.LF;
			pAttributeInErr = ?(pAttributeInErr = "", "ChargingRules", pAttributeInErr);
		ElsIf vCRRow.ChargingRule = Enums.ChargingRuleTypes.NotInServiceGroup And Not ValueIsFilled(vCRRow.ChargingRuleValue) Then
			vHasErrors = True; 
			vMsgTextRu = vMsgTextRu + "В правилах начисления в строке " + Format(vCRRow.LineNumber, "ND=4; NFD=0; NG=") + " не указан набор услуг!" + Chars.LF;
			vMsgTextEn = vMsgTextEn + "Service group is not filled in the charging rules row number " + Format(vCRRow.LineNumber, "ND=4; NFD=0; NG=") + "!" + Chars.LF;
			vMsgTextDe = vMsgTextDe + "Service group is not filled in the charging rules row number " + Format(vCRRow.LineNumber, "ND=4; NFD=0; NG=") + "!" + Chars.LF;
			pAttributeInErr = ?(pAttributeInErr = "", "ChargingRules", pAttributeInErr);
		EndIf;
		If Not ValueIsFilled(vCRRow.Owner) And ValueIsFilled(vCRRow.ChargingFolio) And ValueIsFilled(vCRRow.ChargingFolio.PaymentMethod) And vCRRow.ChargingFolio.PaymentMethod.IsByBankTransfer Then
			If ValueIsFilled(Hotel) And ValueIsFilled(Hotel.IndividualsCustomer) Then
				vCRRow.Owner = Hotel.IndividualsCustomer;
			Else
				vHasErrors = True; 
				vMsgTextRu = vMsgTextRu + "В правилах начисления в строке " + Format(vCRRow.LineNumber, "ND=4; NFD=0; NG=") + " установлен способ оплаты контрагентом, а контрагент не указан!" + Chars.LF;
				vMsgTextEn = vMsgTextEn + "Customer is not choosen in the charging rule owner in the row number " + Format(vCRRow.LineNumber, "ND=4; NFD=0; NG=") + " but payment method choosen states that folio is paid by customer!" + Chars.LF;
				vMsgTextDe = vMsgTextDe + "Customer is not choosen in the charging rule owner in the row number " + Format(vCRRow.LineNumber, "ND=4; NFD=0; NG=") + " but payment method choosen states that folio is paid by customer!" + Chars.LF;
				pAttributeInErr = ?(pAttributeInErr = "", "ChargingRules", pAttributeInErr);
			EndIf;
		EndIf;
	EndDo;
	// Check table of services
	If ValueIsFilled(AccommodationStatus) And AccommodationStatus.IsActive And AccommodationStatus.IsInHouse Then
		If Not cmCheckUserPermissions("HavePermissionToEditRoomRateServices") Then
			If ValueIsFilled(RoomRate) And RoomRate.RateChargeDirection = Enums.RateChargeDirections.MergeToTheMainRoomGuest And ValueIsFilled(AccommodationTemplate) Or
				ValueIsFilled(RoomRate) And RoomRate.RateChargeDirection <> Enums.RateChargeDirections.MergeToTheMainRoomGuest Then
				vServices = Services.FindRows(New Structure("IsRoomRevenue", True));
				If vServices.Count() = 0 Then
					vHasErrors = True; 
					vMsgTextRu = vMsgTextRu + "В таблице услуг к начислению нет стоимости проживания!" + Chars.LF;
					vMsgTextEn = vMsgTextEn + "There are no room revenue found in the list of services to be charged!" + Chars.LF;
					vMsgTextDe = vMsgTextDe + "There are no room revenue found in the list of services to be charged!" + Chars.LF;
					pAttributeInErr = ?(pAttributeInErr = "", "Services", pAttributeInErr);
				EndIf;
			EndIf;
		EndIf;
	EndIf;
	// Check rights to create group debt
	If IsByReservation And ValueIsFilled(Customer) And ValueIsFilled(PlannedPaymentMethod) And PlannedPaymentMethod.IsByBankTransfer And 
		ValueIsFilled(AccommodationStatus) And AccommodationStatus.IsActive Then
		If Not pDoNotCheckRests And cmCheckUserPermissions("NoDebtAllowedForGroupInhouseGuests") And ValueIsFilled(GuestGroup) Then
			vGroupObj = GuestGroup.GetObject();
			vGuestGroupBalance = 0;
			vSales = vGroupObj.pmGetSalesTotals();
			vSales.GroupBy("Currency", "Sales, SalesForecast, ExpectedSales");
			For Each vSalesRow In vSales Do
				vSalesInBaseCurrency = cmConvertCurrencies(vSalesRow.Sales + vSalesRow.SalesForecast, vSalesRow.Currency, , Hotel.BaseCurrency, , ExchangeRateDate, Hotel);
				vGuestGroupBalance = vGuestGroupBalance + vSalesInBaseCurrency;
			EndDo;
			vPayments = vGroupObj.pmGetPaymentsTotals();
			vPayments.GroupBy("Currency", "Sum");
			For Each vPaymentsRow In vPayments Do
				vGuestGroupBalance = vGuestGroupBalance - cmConvertCurrencies(vPaymentsRow.Sum, vPaymentsRow.Currency, , Hotel.BaseCurrency, , ExchangeRateDate, Hotel);
			EndDo;
			If vGuestGroupBalance > 0 Then
				vHasErrors = True; 
				vMsgTextRu = vMsgTextRu + "После сохранения изменений по этому гостю по группе будет долг!" + Chars.LF;
				vMsgTextEn = vMsgTextEn + "After the changes are saved for this guest, the group will have a debt!" + Chars.LF;
				vMsgTextDe = vMsgTextDe + "Nachdem die Änderungen für diesen Gast gespeichert wurden, hat die Gruppe eine Verschuldung!" + Chars.LF;
				pAttributeInErr = ?(pAttributeInErr = "", "CheckOutDate", pAttributeInErr);
			EndIf;
		EndIf;
	EndIf;
	// Build error return string
	If vHasErrors Then
		pMessage = "ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';";
	EndIf;
	Return vHasErrors;
EndFunction

&ChangeAndValidate("pmCalculateServices")
//-----------------------------------------------------------------------------
// Calculates services for the given document.
// Returns False if warnings were rised during services calculation. Otherwise
// returns True
//-----------------------------------------------------------------------------
Function Расш1_pmCalculateServices(rWarnings = "", pPeriodDiscount = 0, pPeriodDiscountType = Undefined, 
                                             pPeriodDiscountServiceGroup = Undefined, pPeriodDiscountConfirmationText = "", pIsForFolioSplit = Undefined) Export
	vWarnings = False;
	If Not ValueIsFilled(RoomType) Then
		Return vWarnings;
	EndIf;
	
	// Folio split mode
	vIsForFolioSplit = False;
	If pIsForFolioSplit <> Undefined Then
		vIsForFolioSplit = pIsForFolioSplit;
	Else
		// Calculate if it is folio split mode
		If ValueIsFilled(AccommodationType) Then
			If ValueIsFilled(AccommodationTemplate) And AccommodationTemplate.IsForFolioSplit Then
				vIsForFolioSplit = True;
			ElsIf AccommodationType.Type = Enums.AccomodationTypes.Beds Then
				vIsForFolioSplit = True;
			ElsIf AccommodationType.Type = Enums.AccomodationTypes.AdditionalBed Then
				// Try to find reservation/accommodation with type Beds. If yes then assume that this is folio split mode
				vOneRoomAccommodations = cmGetOneRoomAccommodations(Room, GuestGroup, CheckInDate, CheckOutDate, Number);
				For Each vOneRoomAccommodationRow In vOneRoomAccommodations Do
					If vOneRoomAccommodationRow.AccommodationTypeType = Enums.AccomodationTypes.Beds Then
						vIsForFolioSplit = True;
						Break;
					EndIf;
				EndDo;
			EndIf;
		EndIf;
	EndIf;
	
	// Internal attributes check
	If ValueIsFilled(AccommodationTemplate) Then
		If NumberOfAdults = 0 And NumberOfTeenagers = 0 And NumberOfChildren = 0 And NumberOfInfants = 0 Then
			NumberOfAdults = AccommodationTemplate.NumberOfAdults;
			NumberOfTeenagers = AccommodationTemplate.NumberOfTeenagers;
			NumberOfChildren = AccommodationTemplate.NumberOfChildren;
			NumberOfInfants = AccommodationTemplate.NumberOfInfants;
		EndIf;
	Else
		NumberOfAdults = 0;
		NumberOfTeenagers = 0;
		NumberOfChildren = 0;
		NumberOfInfants = 0;
	EndIf;
	
	// User exit before calculate services
	vBeforeCalculateServicesUserExit = Catalogs.ExternalDataProcessors.AccommodationBeforeCalculateServices;
	If vBeforeCalculateServicesUserExit.ExternalProcessingType = Enums.ExternalProcessingTypes.Algorithm And Not IsBlankString(vBeforeCalculateServicesUserExit.Algorithm) Then
		SetSafeMode(True);
		Execute(TrimR(vBeforeCalculateServicesUserExit.Algorithm));
		SetSafeMode(False);
	EndIf;
	
	// Processing
	vNoAccommodationService = True;
	vCurPriceTag = Undefined;
	BegOfCheckInDate = BegOfDay(CheckInDate);
	HotelAccountingDate = '00010101';
	CheckAccountingDate = False;	
	If ValueIsFilled(Hotel) Then
		CheckAccountingDate = Hotel.DoNotEditClosedDateDocs;
		HotelAccountingDate = Hotel.AccountingDate;
		If Not ValueIsFilled(HotelAccountingDate) Then
			CheckAccountingDate = False;
		EndIf;
	EndIf;
	If ValueIsFilled(HotelAccountingDate) And AdditionalProperties.Property("AccountingDate") Then
		If ValueIsFilled(AdditionalProperties.AccountingDate) And TypeOf(AdditionalProperties.AccountingDate) = Type("Date") Then
			HotelAccountingDate = AdditionalProperties.AccountingDate;
		EndIf;
	EndIf;
	vSplitChargesToPersonalFolioForIndividualCustomers = Constants.SplitChargesToPersonalFolioForIndividualCustomers.Get();
	// Check if this accommodation is check in
	vIsCheckIn = False;
	vIsCheckOut = False;
	vIsRoomChange = False;
	vIsBeforeRoomChange = False;
	If ValueIsFilled(AccommodationStatus) Then
		vIsCheckIn = AccommodationStatus.IsCheckIn;
		vIsCheckOut = AccommodationStatus.IsCheckOut;
		vIsRoomChange = AccommodationStatus.IsRoomChange;
		If AccommodationStatus.IsActive And Not AccommodationStatus.IsCheckOut Then
			vIsBeforeRoomChange = True;
		EndIf;
	EndIf;
	// Check if this accommodation is based on reservation
	vIsBasedOnReservation = False;
	vReservation = Documents.Reservation.EmptyRef();
	vReservationCheckInDate = CheckInDate;
	vReservationCheckOutDate = CheckOutDate;
	pmSetIsByReservation(vReservation);
	If IsByReservation Then
		If vIsCheckIn Then
			vIsBasedOnReservation = True;
		EndIf;
		If ValueIsFilled(vReservation) Then
			vReservationCheckInDate = vReservation.CheckInDate;
			vReservationCheckOutDate = vReservation.CheckOutDate;
		EndIf;
	EndIf;
	vReservationDate = Date;
	If ValueIsFilled(GuestGroup) And ValueIsFilled(GuestGroup.CreateDate) Then
		vReservationDate = GuestGroup.CreateDate;
	EndIf;
	vParentDocObj = Undefined;
	If ValueIsFilled(ParentDoc) Then
		vParentDocObj = ParentDoc.GetObject();
	EndIf;
	// Create table of charging rules
	vCRTab = ChargingRules.Unload();
	If Not IgnoreGroupChargingRules Then
		cmAddGuestGroupChargingRules(vCRTab, GuestGroup);
	EndIf;
	// Check if there are customer charging rules
	vThereAreCustomerChargingRules = False;
	For Each vCRTabRow In vCRTab Do
		If ValueIsFilled(vCRTabRow.Owner) And 
		  (TypeOf(vCRTabRow.Owner) = Type("CatalogRef.Customers") Or TypeOf(vCRTabRow.Owner) = Type("CatalogRef.Contracts")) Then
			vThereAreCustomerChargingRules = True;
			Break;
		EndIf;
	EndDo;
	// Fill effective period
	vCheckInDate = CheckInDate;
	vCheckOutDate = CheckOutDate;
	If ValueIsFilled(HotelProduct) And Not HotelProduct.IsFolder Then
		If HotelProduct.FixProductPeriod Then
			vCheckInDate = HotelProduct.CheckInDate;
			vCheckOutDate = HotelProduct.CheckOutDate;
			// If this is not check-in then return because all services were already added
			If Not vIsCheckIn Then
				PricePresentation = "";
				Return vWarnings;
			EndIf;
		EndIf;
		If HotelProduct.FixProductCost Then
			// If this is not check-in then return because all services were already added
			If Not vIsCheckIn Then
				PricePresentation = "";
				Return vWarnings;
			EndIf;
		EndIf;
	EndIf;
	If FixReservationConditions And IsByReservation Then
		vSavCheckInDate = vCheckInDate;
		vSavCheckOutDate = vCheckOutDate;
		If vIsCheckIn Then
			If ValueIsFilled(ParentDoc) And TypeOf(ParentDoc) = Type("DocumentRef.Reservation") Then
				vCheckInDate = Min(CheckInDate, vReservationCheckInDate);
			Else
				vReservationCheckInDate = vCheckInDate;
			EndIf;
		EndIf;
		If vIsCheckOut Then
			vSkipCheck = True;
			If IsNew() Then
				vSkipCheck = False;
			EndIf;
			If vSkipCheck Then 
				// Check that there is no accommodation where current one is parent document
				vQry = New Query();
				vQry.Text = 
				"SELECT
				|	Accommodation.Ref
				|FROM
				|	Document.Accommodation AS Accommodation
				|WHERE
				|	Accommodation.Posted
				|	AND Accommodation.ParentDoc = &qParentDoc
				|	AND Accommodation.CheckInDate > &qCheckInDate
				|	AND Accommodation.AccommodationStatus.IsActive";
				vQry.SetParameter("qParentDoc", Ref);
				vQry.SetParameter("qCheckInDate", CheckInDate);
				vNextDocs = vQry.Execute().Unload();
				If vNextDocs.Count() = 0 Then
					vSkipCheck = False;
				EndIf;
			EndIf;
			If Not vSkipCheck Then
				vCheckOutDate = Max(CheckOutDate, vReservationCheckOutDate);
			Else
				vReservationCheckOutDate = vCheckOutDate;
			EndIf;
		EndIf;
		If vCheckOutDate <= vCheckInDate Then
			vCheckInDate = vSavCheckInDate;
			vCheckOutDate = vSavCheckOutDate;
			If Not (ValueIsFilled(ParentDoc) And TypeOf(ParentDoc) = Type("DocumentRef.Reservation")) Then
				vReservationCheckInDate = vCheckInDate;
				vReservationCheckOutDate = vCheckOutDate;
			EndIf;
		EndIf;
	EndIf;
	// Create table of manual prices
	vMPTab = Prices.Unload();
	// Create table of current services calendar day types for accounting dates
	vDayTypes = Services.Unload();
	vDayTypes.GroupBy("AccountingDate, Service, CalendarDayType, RoomRate, PriceTag, IsRoomRevenue, IsInPrice", );
	If Not ValueIsFilled(PriceCalculationDate) Then
		vDayTypes.Clear();
	EndIf;
	vCalendarDayTypes = vDayTypes.Copy(, "CalendarDayType");
	vCalendarDayTypes.GroupBy("CalendarDayType", );
	vCalendarDayTypesList = New ValueList();
	vCalendarDayTypesList.LoadValues(vCalendarDayTypes.UnloadColumn("CalendarDayType"));
	// Save services with prices changed manually
	vMCServices = Services.Unload();
	vMCServices.Columns.Add("PaymentMethod", cmGetCatalogTypeDescription("PaymentMethods"));
	i = 0;
	While i < vMCServices.Count() Do
		vSrv = vMCServices.Get(i);
		If Not vSrv.IsManualPrice Then
			vMCServices.Delete(i);
		Else
			If ValueIsFilled(vSrv.Folio) Then
				vSrv.PaymentMethod = vSrv.Folio.PaymentMethod;
			EndIf;
			i = i + 1;
		EndIf;
	EndDo;
	// Clear room rate services
	i = 0;
	While i < Services.Count() Do
		vSrv = Services.Get(i);
		If Not vSrv.IsManual Then
			Services.Delete(i);
		Else
			vSrv.Company = Company;
			vCurFolio = vSrv.Folio;
			If vSrv.Company <> vCurFolio.Company And vCurFolio.DoNotUpdateCompany Then
				vSrv.Company = vCurFolio.Company;
			EndIf;
			i = i + 1;
		EndIf;
	EndDo;
	// Check folios for the manual services
	pmSetFolioBasedOnChargingRules(Services, True);
	// Check that room rate is filled
	If Not ValueIsFilled(RoomRate) Then
		PricePresentation = "";
		Return vWarnings;
	EndIf;
	If Not ValueIsFilled(RoomRate.Calendar) Then
		PricePresentation = "";
		Return vWarnings;
	EndIf;
	// Get and check room rate restrictions
	vDoCheckRestrictions = False;
	If Not IsNew() Then
		If RoomRate <> Ref.RoomRate Or 
		   BegOfDay(CheckInDate) <> BegOfDay(Ref.CheckInDate) Or 
		   BegOfDay(CheckOutDate) <> BegOfDay(Ref.CheckOutDate) Or 
		   RoomType <> Ref.RoomType Then
			vDoCheckRestrictions = True;
		EndIf;
	ElsIf ValueIsFilled(Reservation) Then
		If RoomRate <> Reservation.RoomRate Or 
		   BegOfDay(CheckInDate) <> BegOfDay(Reservation.CheckInDate) Or 
		   BegOfDay(CheckOutDate) <> BegOfDay(Reservation.CheckOutDate) Or 
		   RoomType <> Reservation.RoomType Then
			vDoCheckRestrictions = True;
		EndIf;
	Else
		vDoCheckRestrictions = True;
	EndIf;
	If vDoCheckRestrictions Then
		vRestrStruct = RoomRate.GetObject().pmGetRoomRateRestrictions(vCheckInDate, vCheckOutDate, ?(ValueIsFilled(RoomTypeUpgrade), RoomTypeUpgrade, RoomType), True);
		If vRestrStruct.StopSale And AccommodationStatus.IsActive And AccommodationStatus.IsInHouse Then
			vWarnings = True;
			vWarningsEn = "Room rate " + TrimAll(RoomRate) + " could not be used for the given period " + Format(vCheckInDate, "DF=dd.MM.yyyy") + " - " + Format(vCheckOutDate, "DF=dd.MM.yyyy") + " (room rate restriction Stop Sales is turned on)!";
			vWarningsDe = "Tariff " + TrimAll(RoomRate) + " ist geschlossen (Tariff Einschränkung Stop Sale ist auf), periode " + Format(vCheckInDate, "DF=dd.MM.yyyy") + " - " + Format(vCheckOutDate, "DF=dd.MM.yyyy") + "!";
			vWarningsRu = "Продажи по тарифу " + TrimAll(RoomRate) + " остановлены на периоде с " + Format(vCheckInDate, "DF=dd.MM.yyyy") + " по " + Format(vCheckOutDate, "DF=dd.MM.yyyy") + " в ограничениях тарифа (Stop Sale включен)!";
			rWarnings = "ru = '" + vWarningsRu + "'; de = '" + vWarningsDe + "'; en = '" + vWarningsEn + "'";
		EndIf;
		If vRestrStruct.CTA And AccommodationStatus.IsActive And AccommodationStatus.IsCheckIn And AccommodationStatus.IsInHouse Then
			vWarnings = True;
			vWarningsEn = "Check-in is closed (CTA is On) for the given check-in date " + Format(vCheckInDate, "DF=dd.MM.yyyy") + "!";
			vWarningsDe = "Check-in ist fur den Check-in-Datum " + Format(vCheckInDate, "DF=dd.MM.yyyy") + " geschlossen (CTA is On)!";
			vWarningsRu = "Заезд в выбранную дату " + Format(vCheckInDate, "DF=dd.MM.yyyy") + " запрещен в ограничениях указанных у тарифа (CTA включен)!";
			rWarnings = "ru = '" + vWarningsRu + "'; de = '" + vWarningsDe + "'; en = '" + vWarningsEn + "'";
		EndIf;
		If vRestrStruct.CTD And AccommodationStatus.IsActive And AccommodationStatus.IsCheckOut And AccommodationStatus.IsInHouse Then
			vWarnings = True;
			vWarningsEn = "Check-out is closed (CTD is On) for the given check-out date " + Format(vCheckOutDate, "DF=dd.MM.yyyy") + "!";
			vWarningsDe = "Check-out ist fur den Check-out-Datum " + Format(vCheckOutDate, "DF=dd.MM.yyyy") + " geschlossen (CTD is On)!";
			vWarningsRu = "Выезд в выбранную дату " + Format(vCheckOutDate, "DF=dd.MM.yyyy") + " запрещен в ограничениях указанных у тарифа (CTD включен)!";
			rWarnings = "ru = '" + vWarningsRu + "'; de = '" + vWarningsDe + "'; en = '" + vWarningsEn + "'";
		EndIf;
		If vRestrStruct.MLOS > 0 And Duration < vRestrStruct.MLOS And ValueIsFilled(RoomRate) Then
			If RoomRate.DurationCalculationRuleType = Enums.DurationCalculationRuleTypes.ByDays Then
				If (Int((BegOfDay(vCheckOutDate) - BegOfDay(vCheckInDate))/(24*3600)) + 1) < vRestrStruct.MLOS Then
					vCheckOutDate = cm0SecondShift(BegOfDay(vCheckInDate) + (vCheckOutDate - BegOfDay(vCheckOutDate)) + 24*3600*(vRestrStruct.MLOS - 1));
				EndIf;
			ElsIf RoomRate.DurationCalculationRuleType = Enums.DurationCalculationRuleTypes.ByHours Then
				If Int((BegOfDay(vCheckOutDate) - BegOfDay(vCheckInDate))/3600) < vRestrStruct.MLOS Then
					vCheckOutDate = cm0SecondShift(BegOfDay(vCheckInDate) + 3600*vRestrStruct.MLOS);
				EndIf;
			Else
				If Int((BegOfDay(vCheckOutDate) - BegOfDay(vCheckInDate))/(24*3600)) < vRestrStruct.MLOS Then
					vCheckOutDate = cm0SecondShift(BegOfDay(vCheckInDate) + (vCheckOutDate - BegOfDay(vCheckOutDate)) + 24*3600*vRestrStruct.MLOS);
				EndIf;
			EndIf;
			If RoomRate.MLOSIsBlocking And ValueIsFilled(AccommodationStatus) And AccommodationStatus.IsCheckOut And AccommodationStatus.IsActive And Not FixReservationConditions Then
				vWarnings = True;
				vWarningsRu = "Минимальная продолжительность проживания " + vRestrStruct.MLOS + " дней!";
				vWarningsEn = "Minimum length of stay is " + vRestrStruct.MLOS + "!";
				vWarningsDe = "Mindestaufenthaltsdauer betragt " + vRestrStruct.MLOS + " Tage!";
				rWarnings = "ru = '" + vWarningsRu + "'; de = '" + vWarningsDe + "'; en = '" + vWarningsEn + "'";
			EndIf;
		EndIf;
		If vRestrStruct.MaxLOS > 0 And Duration > vRestrStruct.MaxLOS Then
			vWarnings = True;
			vWarningsRu = "Максимальная продолжительность проживания " + vRestrStruct.MaxLOS + " дней!";
			vWarningsEn = "Maximum length of stay is " + vRestrStruct.MaxLOS + "!";
			vWarningsDe = "Maximaleaufenthaltsdauer betragt " + vRestrStruct.MaxLOS + " Tage!";
			rWarnings = "ru = '" + vWarningsRu + "'; de = '" + vWarningsDe + "'; en = '" + vWarningsEn + "'";
		EndIf;
		If vRestrStruct.MinDaysBeforeCheckIn > 0 And ValueIsFilled(AccommodationType) And (AccommodationType.Type = Enums.AccomodationTypes.Room Or AccommodationType.Type = Enums.AccomodationTypes.Beds) Then
			vDate = GuestGroup.CreateDate;
			vDaysBeforeCheckIn = Int((BegOfDay(vCheckInDate) - BegOfDay(vDate))/(24*3600));
			If vDaysBeforeCheckIn < vRestrStruct.MinDaysBeforeCheckIn Then
				vWarnings = True;
				vWarningsRu = "Минимальное кол-во дней от даты бронирования до даты заезда " + vRestrStruct.MinDaysBeforeCheckIn + "!";
				vWarningsEn = "Minimum days between booking and check-in dates is " + vRestrStruct.MinDaysBeforeCheckIn + "!";
				vWarningsDe = "Mindest Tage zwischen Buchung und Check-in Daten ist " + vRestrStruct.MinDaysBeforeCheckIn + "!";
				rWarnings = "ru = '" + vWarningsRu + "'; de = '" + vWarningsDe + "'; en = '" + vWarningsEn + "'";
			EndIf;
		EndIf;
		If vRestrStruct.MaxDaysBeforeCheckIn > 0 And ValueIsFilled(AccommodationType) And (AccommodationType.Type = Enums.AccomodationTypes.Room Or AccommodationType.Type = Enums.AccomodationTypes.Beds) Then
			vDate = GuestGroup.CreateDate;
			vDaysBeforeCheckIn = Int((BegOfDay(vCheckInDate) - BegOfDay(vDate))/(24*3600));
			If vDaysBeforeCheckIn > vRestrStruct.MaxDaysBeforeCheckIn Then
				vWarnings = True;
				vWarningsRu = "Максимальное кол-во дней от даты бронирования до даты заезда " + vRestrStruct.MaxDaysBeforeCheckIn + "!";
				vWarningsEn = "Maximum days between booking and check-in dates is " + vRestrStruct.MaxDaysBeforeCheckIn + "!";
				vWarningsDe = "Maximale Tage zwischen Buchung und Check-in Daten ist " + vRestrStruct.MaxDaysBeforeCheckIn + "!";
				rWarnings = "ru = '" + vWarningsRu + "'; de = '" + vWarningsDe + "'; en = '" + vWarningsEn + "'";
			EndIf;
		EndIf;
	EndIf;
	// Get accommodation condition periods
	vAccommodationPeriods = pmGetAccommodationPeriods(False);
	// Get accounting check-in and check-out dates
	vBegOfCheckInDate = BegOfDay(vCheckInDate);
	vBegOfCheckOutDate = BegOfDay(vCheckOutDate);
	// Save some old values
	vSavCheckInDate = CheckInDate;
	vSavCheckOutDate = CheckOutDate;
	If Not IsNew() Then
		vSavCheckInDate = Ref.CheckInDate;
		vSavCheckOutDate = Ref.CheckOutDate;
	EndIf;
	// Fill occupation percents
	vOccupationPercentsAreFilled = False;
	If ValueIsFilled(RoomRate) And ValueIsFilled(RoomType) Then
		If RoomRate.PriceTagType = Enums.PriceTagTypes.ByOccupancyPercent Or 
		   RoomRate.PriceTagType = Enums.PriceTagTypes.ByOccupancyPercentPerRoomType Or 
		   RoomRate.PriceTagType = Enums.PriceTagTypes.ByOccupancyPercentPerRoomTypePerDayType Then
			vOccupationPercentsAreFilled = True;
			If Not ValueIsFilled(PriceCalculationDate) Or 
			   Not Posted Or 
			   Posted And (BegOfDay(vSavCheckInDate) <> BegOfDay(CheckInDate) Or BegOfDay(vSavCheckOutDate) <> BegOfDay(CheckOutDate)) Then
				pmFillOccupationPercents(vBegOfCheckInDate, vBegOfCheckOutDate);
			EndIf;
		EndIf;
	EndIf;
	// Discount confirmation text
	If Not ValueIsFilled(DiscountType) Or ValueIsFilled(DiscountType) And (DiscountType.IsAccumulatingDiscount Or IsBlankString(DiscountType.ConfirmationPattern)) Then
		DiscountConfirmationText = "";
	EndIf;
	// Get list of accumulating discount types with actual resources
	vAccDiscounts = pmGetAccumulatingDiscountResources();
	// Initialize value of discount that should be applied to the whole period
	vPeriodDiscount = pPeriodDiscount;
	vPeriodDiscountType = pPeriodDiscountType;
	vPeriodDiscountServiceGroup = pPeriodDiscountServiceGroup;
	vPeriodDiscountConfirmationText = pPeriodDiscountConfirmationText;
	// Get active special offers
	vOffers = cmGetConfirmedSpecialOffersForReservation(?(ValueIsFilled(Reservation), Reservation, Ref), Hotel, RoomRate, RoomRateType, Guest, ClientType, Customer, CustomerType, GuestGroup, SourceOfBusiness, MarketingCode, TripPurpose, CheckInDate, Duration, CheckOutDate, ?(ValueIsFilled(Reservation), Reservation.Date, Date));
	// Build list of service packages
	vServicePackagesList = New ValueList();
	If ValueIsFilled(ServicePackage) Then
		vServicePackagesList.Add(ServicePackage);
	EndIf;
	For Each vServicePackagesRow In ServicePackages Do
		If ValueIsFilled(vServicePackagesRow.ServicePackage) Then
			vServicePackagesList.Add(vServicePackagesRow.ServicePackage);
		EndIf;
	EndDo;
	// Get list of price records for the given room rate
	vRoom = Room;
	vRoomRoomType = RoomType;
	vRoomType = RoomType;
	If ValueIsFilled(RoomTypeUpgrade) Then
		vRoomType = RoomTypeUpgrade;
	EndIf;
	vBasePrices = RoomRate.GetObject().pmGetRoomRatePrices(vCheckInDate, PriceCalculationDate, ClientType, vRoomType, AccommodationType, vServicePackagesList, , vCheckInDate, vCheckOutDate, , , vCalendarDayTypesList, , AccommodationTemplate, vIsForFolioSplit);
	If ValueIsFilled(ClientType) And vBasePrices.Count() = 0 Then
		vBasePrices = RoomRate.GetObject().pmGetRoomRatePrices(vCheckInDate, PriceCalculationDate, Catalogs.ClientTypes.EmptyRef(), vRoomType, AccommodationType, vServicePackagesList, , vCheckInDate, vCheckOutDate, , , vCalendarDayTypesList, , AccommodationTemplate, vIsForFolioSplit);
	EndIf;
	vReservationRoomType = vRoomType;
	vReservationRoomRate = RoomRate;
	vReservationAccommodationType = AccommodationType;
	vReservationAccommodationTemplate = AccommodationTemplate;
	vReservationRoomRates = Undefined;
	If ValueIsFilled(Reservation) Then
		vReservationRoomRate = Reservation.RoomRate;
		vReservationRoomType = Reservation.RoomType;
		If ValueIsFilled(Reservation.RoomTypeUpgrade) Then
			vReservationRoomType = Reservation.RoomTypeUpgrade;
		EndIf;
		vReservationAccommodationType = Reservation.AccommodationType;
		vReservationRoomRates = Reservation.GetObject().pmGetAccommodationPlan();
	EndIf;
	// Check if we have other room types specified in the charging rules
	vCRRoomTypePrices = New ValueTable();
	vCRRoomTypePrices.Columns.Add("RoomType", cmGetCatalogTypeDescription("RoomTypes"));
	vCRRoomTypePrices.Columns.Add("Prices");
	For Each vCRRow In vCRTab Do
		If TypeOf(vCRRow.ChargingRuleValue) = Type("CatalogRef.RoomTypes") And 
		   ValueIsFilled(vCRRow.ChargingRuleValue) Then
			If vCRRoomTypePrices.Find(vCRRow.ChargingRuleValue, "RoomType") = Undefined Then
				vCRRoomTypePricesRow = vCRRoomTypePrices.Add();
				vCRRoomTypePricesRow.RoomType = vCRRow.ChargingRuleValue;
				vCRRoomTypePricesTable = RoomRate.GetObject().pmGetRoomRatePrices(vCheckInDate, PriceCalculationDate, ClientType, vCRRoomTypePricesRow.RoomType, AccommodationType, vServicePackagesList, , vCheckInDate, vCheckOutDate, , , vCalendarDayTypesList, , AccommodationTemplate, vIsForFolioSplit);
				If ValueIsFilled(ClientType) And vCRRoomTypePricesTable.Count() = 0 Then
					vCRRoomTypePricesTable = RoomRate.GetObject().pmGetRoomRatePrices(vCheckInDate, PriceCalculationDate, Catalogs.ClientTypes.EmptyRef(), vCRRoomTypePricesRow.RoomType, AccommodationType, vServicePackagesList, , vCheckInDate, vCheckOutDate, , , vCalendarDayTypesList, , AccommodationTemplate, vIsForFolioSplit);
				EndIf;
				vCRRoomTypePricesRow.Prices = vCRRoomTypePricesTable;
			EndIf;
		EndIf;
	EndDo;
	// Build value table of room rates per accounting days
	For Each vRRRow In RoomRates Do
		If RoomRate = vRRRow.RoomRate And ValueIsFilled(vRRRow.PriceCalculationDate) And vRRRow.PriceCalculationDate <> PriceCalculationDate Then
			vRRRow.PriceCalculationDate = PriceCalculationDate;
		EndIf;
	EndDo;
	vRoomRates = pmGetAccommodationPlan();
	vRoomRates.Columns.Add("Prices");
	If vRoomRates.Count() > 0 Then
		vRoomRatesDimensions = vRoomRates.Copy();
		vRoomRatesDimensions.GroupBy("RoomRate, AccommodationType, RoomType, PriceCalculationDate, AccommodationTemplate", );
		vRoomRatesDimensions.Columns.Add("Prices");
		For Each vRoomRatesDimensionsRow In vRoomRatesDimensions Do
			vDimensionRoomRate = ?(ValueIsFilled(vRoomRatesDimensionsRow.RoomRate), vRoomRatesDimensionsRow.RoomRate, RoomRate);
			vDimensionAccommodationType = ?(ValueIsFilled(vRoomRatesDimensionsRow.AccommodationType), vRoomRatesDimensionsRow.AccommodationType, AccommodationType);
			vDimensionRoomType = ?(ValueIsFilled(vRoomRatesDimensionsRow.RoomType) And Not ValueIsFilled(RoomTypeUpgrade), vRoomRatesDimensionsRow.RoomType, vRoomType);
			vPriceCalculationDate = vRoomRatesDimensionsRow.PriceCalculationDate;
			If vDimensionRoomRate = RoomRate Then
				vPriceCalculationDate = PriceCalculationDate;
			EndIf;
			vDimensionAccommodationTemplate = ?(ValueIsFilled(vRoomRatesDimensionsRow.AccommodationTemplate), vRoomRatesDimensionsRow.AccommodationTemplate, AccommodationTemplate);
			vDimensionPrices = vDimensionRoomRate.GetObject().pmGetRoomRatePrices(vCheckInDate, vPriceCalculationDate, ClientType, vDimensionRoomType, vDimensionAccommodationType, vServicePackagesList, , vCheckInDate, vCheckOutDate, , , vCalendarDayTypesList, , vDimensionAccommodationTemplate, vIsForFolioSplit);
			If ValueIsFilled(ClientType) And vDimensionPrices.Count() = 0 Then
				vDimensionPrices = vDimensionRoomRate.GetObject().pmGetRoomRatePrices(vCheckInDate, vPriceCalculationDate, Catalogs.ClientTypes.EmptyRef(), vDimensionRoomType, vDimensionAccommodationType, vServicePackagesList, , vCheckInDate, vCheckOutDate, , , vCalendarDayTypesList, , vDimensionAccommodationTemplate, vIsForFolioSplit);
			EndIf;
			vRoomRatesDimensionsRow.Prices = vDimensionPrices;
			vRoomRatesDimensionsRow.PriceCalculationDate = vPriceCalculationDate;
			// Update room rates
			For Each vRRRow In RoomRates Do
				If ValueIsFilled(vRRRow.RoomRate) And vRRRow.RoomRate = vDimensionRoomRate And 
				   vRRRow.PriceCalculationDate <> vPriceCalculationDate Then
					vRRRow.PriceCalculationDate = vPriceCalculationDate;
				EndIf;
			EndDo;
		EndDo;
		For Each vRoomRatesRow In vRoomRates Do
			vRoomRatesDimensionsRows = vRoomRatesDimensions.FindRows(New Structure("RoomRate, AccommodationType, RoomType", vRoomRatesRow.RoomRate, vRoomRatesRow.AccommodationType, vRoomRatesRow.RoomType));
			If vRoomRatesDimensionsRows.Count() > 0 Then
				vRoomRatesDimensionsRow = vRoomRatesDimensionsRows.Get(0);
				vRoomRatesRow.Prices = vRoomRatesDimensionsRow.Prices;
			EndIf;
		EndDo;
	EndIf;
	// Get complex commission
	vComplexCommission = pmGetComplexCommission();
	// Create discount type object
	vIsAmountDiscount = False;
	vUseDocumentDiscount = False;
	vFixedDiscount = Discount;
	vFixedDiscountTypeObj = Undefined;
	If ValueIsFilled(DiscountType) Then
		vFixedDiscountTypeObj = DiscountType.GetObject();
		If DiscountType.IsAmountDiscount Then
			vIsAmountDiscount = True;
			vUseDocumentDiscount = True;
		Else
			If Not DiscountType.IsAccumulatingDiscount And Not DiscountType.DifferentDiscountPercentsForServiceGroupsAllowed Then
				vFixedDiscountPercent = vFixedDiscountTypeObj.pmGetDiscount(CheckInDate, , Hotel);
				If vFixedDiscountPercent <> vFixedDiscount Then
					vUseDocumentDiscount = True;
				EndIf;
			EndIf;
		EndIf;
	EndIf;
	// Build value table of discount percents per days
	vDiscountPercents = New ValueTable();
	vDiscountPercents.Columns.Add("AccountingDate", cmGetDateTypeDescription());
	vDiscountPercents.Columns.Add("Discount", cmGetDiscountTypeDescription());
	// Build value table of discount percents per services
	vFixedServiceDiscount = 0;
	vFixedDiscountPercents = New ValueTable();
	vFixedDiscountPercents.Columns.Add("AccountingDate", cmGetDateTypeDescription());
	vFixedDiscountPercents.Columns.Add("Service", cmGetCatalogTypeDescription("Services"));
	vFixedDiscountPercents.Columns.Add("Discount", cmGetDiscountTypeDescription());
	vServices = vBasePrices.Copy(, "Service");
	vServices.GroupBy("Service", );
	// Get list of days with day types from room rate calendar
	vDays = RoomRate.Calendar.GetObject().pmGetDays(vCheckInDate, vCheckOutDate, , , vRoomType);
	If vCheckInDate >= vCheckOutDate Then
		vDays.Clear();
	Else
		If vDays.Count() > 0 And vDays.Count() <> ((BegOfDay(vCheckOutDate) - BegOfDay(vCheckInDate))/(24*3600) + 1) Then
			vDaysDate = BegOfDay(vCheckInDate);
			vPrevDaysRow = Undefined;
			i = 0;
			While vDaysDate <= BegOfDay(vCheckOutDate) Do
				vDaysRow = vDays.Find(vDaysDate, "Period");
				If vDaysRow <> Undefined Then
					vPrevDaysRow = vDaysRow;
					i = i + 1;
				ElsIf vPrevDaysRow <> Undefined Then
					vDaysRow = vDays.Insert(i);
					FillPropertyValues(vDaysRow, vPrevDaysRow);
					vDaysRow.Period = vDaysDate;
					i = i + 1;
				EndIf;
				vDaysDate = vDaysDate + 24*3600;
			EndDo;
		EndIf;
	EndIf;
	// Get contract service package included in the room rate
	vMealBoardTermIncluded = Undefined;
	vMealBoardTermIncludedServices = Undefined;
	If ValueIsFilled(Contract) And ValueIsFilled(Contract.MealBoardTerm) Then
		vMealBoardTermIncluded = Contract.MealBoardTerm;
		vMealBoardTermIncludedServices = vMealBoardTermIncluded.GetObject().pmGetServices(vCheckInDate);
	ElsIf ValueIsFilled(ServicePackage) And ServicePackage.IsMealBoardTerm Then
		vMealBoardTermIncluded = ServicePackage;
	EndIf;
	// Save contract meal board terms
	vContractMealBoardTerms = New ValueTable();
	vContractMealBoardTerms.Columns.Add("MealBoardTerm");
	vContractMealBoardTerms.Columns.Add("PriceCorrection");
	vContractMealBoardTerms.Columns.Add("CheckInDateFrom", cmGetDateTypeDescription());
	vContractMealBoardTerms.Columns.Add("CheckInDateTo", cmGetDateTypeDescription());
	vContractMealBoardTerms.Columns.Add("ReservationDateFrom", cmGetDateTypeDescription());
	vContractMealBoardTerms.Columns.Add("ReservationDateTo", cmGetDateTypeDescription());
	vContractMealBoardTerms.Columns.Add("PeriodOfStayFrom", cmGetDateTypeDescription());
	vContractMealBoardTerms.Columns.Add("PeriodOfStayTo", cmGetDateTypeDescription());
	If ValueIsFilled(Contract) Then
		vContractMealBoardTerms = Contract.MealBoardTerms.Unload();
	EndIf;
	// Calculate quantity for each service from room rate
	i = 0;
	vFirstDayWithAccommodationService = True;
	vRestOfCurAmount = 0;
	vRestOfServiceSum = 0;
	vChargingRuleAmountIsSet = False;
	For Each vDayRow In vDays Do
		vCurAccountingDate = vDayRow.Period;
		vCurCalendarDayType = vDayRow.CalendarDayType;
		vCurTimetable = vDayRow.Timetable;
		vCurPriceTag = Catalogs.PriceTags.EmptyRef();
		vFixedPriceTag = vDayRow.PriceTag;
		vEarlyCheckInQuantity = 0;
		vEarlyCheckInSrvQuantity = 0;
		vLateCheckOutQuantity = 0;
		vLateCheckOutSrvQuantity = 0;
		vCurRoomRateSrv = Undefined;
		vCurRoomRateSrvHasManualPrice = False;
		// Build value table of discount percents per days
		If ValueIsFilled(DiscountType) Then
			If vCurAccountingDate >= DiscountType.DateValidFrom And 
			   (Not ValueIsFilled(DiscountType.DateValidTo) Or ValueIsFilled(DiscountType.DateValidTo) And vCurAccountingDate <= DiscountType.DateValidTo) Then
				If DiscountType.DifferentDiscountPercentsForServiceGroupsAllowed Then
					For Each vServicesRow In vServices Do
						If cmIsServiceInServiceGroup(vServicesRow.Service, DiscountServiceGroup) Then
							vFixedDiscountPercentsRow = vFixedDiscountPercents.Add();
							vFixedDiscountPercentsRow.AccountingDate = vCurAccountingDate;
							vFixedDiscountPercentsRow.Service = vServicesRow.Service;
							vFixedDiscountPercentsRow.Discount = vFixedDiscountTypeObj.pmGetDiscount(vCurAccountingDate, vServicesRow.Service, Hotel);
						EndIf;
					EndDo;
				Else
					vDiscountPercentsRow = vDiscountPercents.Add();
					vDiscountPercentsRow.AccountingDate = vCurAccountingDate;
					vDiscountPercentsRow.Discount = vFixedDiscountTypeObj.pmGetDiscount(vCurAccountingDate, , Hotel);
				EndIf;
			EndIf;
		EndIf;
		// Get prices for the current accounting date
		vPrices = vBasePrices;
		vRoomRate = RoomRate;
		vAccommodationType = AccommodationType;
		vAccommodationTemplate = AccommodationTemplate;
		vRoomRatesRow = vRoomRates.Find(vCurAccountingDate, "AccountingDate");
		If vRoomRatesRow <> Undefined Then
			vPrices = vRoomRatesRow.Prices;
			If ValueIsFilled(vRoomRatesRow.RoomType) And Not ValueIsFilled(RoomTypeUpgrade) Then
				vRoomType = vRoomRatesRow.RoomType;
			EndIf;
			If ValueIsFilled(vRoomRatesRow.RoomType) Then
				vRoomRoomType = vRoomRatesRow.RoomType;
			EndIf;
			If ValueIsFilled(vRoomRatesRow.Room) Then
				vRoom = vRoomRatesRow.Room;
			EndIf;
			If ValueIsFilled(vRoomRatesRow.RoomRate) Then
				vRoomRate = vRoomRatesRow.RoomRate;
				vCurCalendarDayType = cmGetCalendarDayType(vRoomRate, vCurAccountingDate, vCheckInDate, vCheckOutDate, , ?(ValueIsFilled(RoomTypeUpgrade), RoomTypeUpgrade, vRoomRoomType));
			EndIf;
			If ValueIsFilled(vRoomRatesRow.AccommodationType) Then
				vAccommodationType = vRoomRatesRow.AccommodationType;
			EndIf;
			If ValueIsFilled(vRoomRatesRow.AccommodationTemplate) Then
				vAccommodationTemplate = vRoomRatesRow.AccommodationTemplate;
			EndIf;
		EndIf;
		If vReservationRoomRates <> Undefined And ValueIsFilled(Reservation) Then
			vReservationRoomRatesRow = vReservationRoomRates.Find(vCurAccountingDate, "AccountingDate");
			If vReservationRoomRatesRow <> Undefined Then
				If ValueIsFilled(vReservationRoomRatesRow.RoomType) Then
					If Not ValueIsFilled(Reservation.RoomTypeUpgrade) Then
						vReservationRoomType = vReservationRoomRatesRow.RoomType;
					EndIf;
				EndIf;
				If ValueIsFilled(vReservationRoomRatesRow.RoomRate) Then
					vReservationRoomRate = vReservationRoomRatesRow.RoomRate;
				EndIf;
				If ValueIsFilled(vReservationRoomRatesRow.AccommodationType) Then
					vReservationAccommodationType = vReservationRoomRatesRow.AccommodationType;
				EndIf;
				If ValueIsFilled(vReservationRoomRatesRow.AccommodationTemplate) Then
					vReservationAccommodationTemplate = vReservationRoomRatesRow.AccommodationTemplate;
				EndIf;
			EndIf;
		EndIf;
		vDoesNotAffectRoomRevenueStatistics = False;
		If ValueIsFilled(vRoomRoomType) Then
			vDoesNotAffectRoomRevenueStatistics = vRoomRoomType.DoesNotAffectRoomRevenueStatistics;
		EndIf;
		// Check should we take price tags into account or not and 
		// try to find appropriate price tag for the current accounting date
		vPriceTagsAreUsed = False;
		vResetPriceTagPrices = False;
		If ValueIsFilled(vRoomRate) Then
			If ValueIsFilled(vRoomRate.PriceTagType) Then
				vPriceTagsAreUsed = True;
				If vRoomRate.PriceTagType = Enums.PriceTagTypes.ByDurationOfStayByDays Then
					// Check should we used saved price tags or not
					If BegOfDay(CheckInDate) <> BegOfDay(vSavCheckInDate) Or BegOfDay(CheckOutDate) <> BegOfDay(vSavCheckOutDate) Then
						vResetPriceTagPrices = True;
					EndIf;
					If Not Posted And Not ValueIsFilled(Reservation) Then
						vResetPriceTagPrices = True;
					EndIf;
				ElsIf vRoomRate.PriceTagType = Enums.PriceTagTypes.ByDurationOfStayByPeriod Then
					// Check should we used saved price tags or not
					If BegOfDay(CheckInDate) <> BegOfDay(vSavCheckInDate) Or BegOfDay(CheckOutDate) <> BegOfDay(vSavCheckOutDate) Then
						vResetPriceTagPrices = True;
					EndIf;
					If Not Posted And Not ValueIsFilled(Reservation) Then
						vResetPriceTagPrices = True;
					EndIf;
				ElsIf vRoomRate.PriceTagType = Enums.PriceTagTypes.ByOccupancyPercent Or 
					  vRoomRate.PriceTagType = Enums.PriceTagTypes.ByOccupancyPercentPerRoomType Or 
					  vRoomRate.PriceTagType = Enums.PriceTagTypes.ByOccupancyPercentPerRoomTypePerDayType Then
					// Check should we used saved price tags or not
					If BegOfDay(CheckInDate) <> BegOfDay(vSavCheckInDate) Or BegOfDay(CheckOutDate) <> BegOfDay(vSavCheckOutDate) Then
						vResetPriceTagPrices = True;
						vOccupationPercentsAreFilled = False;
					EndIf;
					If Not Posted And Not ValueIsFilled(Reservation) Then
						vResetPriceTagPrices = True;
					EndIf;
				EndIf;
				If vResetPriceTagPrices Or vDayTypes.Count() = 0 Or vDayTypes.FindRows(New Structure("AccountingDate", vCurAccountingDate)).Count() = 0 Then
					vPriceTagRanges = cmGetPriceTagRanges(Hotel, vRoomRate.PriceTagType, vCurAccountingDate);
					If vRoomRate.PriceTagType = Enums.PriceTagTypes.ByDurationOfStayByDays Then
						// Check should we used saved price tags or not
						If BegOfDay(CheckInDate) <> BegOfDay(vSavCheckInDate) Or BegOfDay(CheckOutDate) <> BegOfDay(vSavCheckOutDate) Then
							vResetPriceTagPrices = True;
						EndIf;
						// Calculate price tag
						vCurDurationInDays = (vCurAccountingDate - vBegOfCheckInDate)/(24*3600) + 1;
						vCurDurationInDays = ?(vCurDurationInDays < 0, 0, vCurDurationInDays);
						For Each vPriceTagRangesRow In vPriceTagRanges Do
							If vCurDurationInDays >= vPriceTagRangesRow.StartValue And vCurDurationInDays <= vPriceTagRangesRow.EndValue Then
								vCurPriceTag = vPriceTagRangesRow.PriceTag;
								Break;
							EndIf;
						EndDo;
					ElsIf vRoomRate.PriceTagType = Enums.PriceTagTypes.ByDurationOfStayByPeriod Then
						// Check should we used saved price tags or not
						If BegOfDay(CheckInDate) <> BegOfDay(vSavCheckInDate) Or BegOfDay(CheckOutDate) <> BegOfDay(vSavCheckOutDate) Then
							vResetPriceTagPrices = True;
						EndIf;
						// Calculate price tag
						vCurDurationInDays = (vBegOfCheckOutDate - vBegOfCheckInDate)/(24*3600);
						vCurDurationInDays = ?(vCurDurationInDays <= 0, 1, vCurDurationInDays);
						For Each vPriceTagRangesRow In vPriceTagRanges Do
							If vCurDurationInDays >= vPriceTagRangesRow.StartValue And vCurDurationInDays <= vPriceTagRangesRow.EndValue Then
								vCurPriceTag = vPriceTagRangesRow.PriceTag;
								Break;
							EndIf;
						EndDo;
					ElsIf vRoomRate.PriceTagType = Enums.PriceTagTypes.ByOccupancyPercent Or 
						  vRoomRate.PriceTagType = Enums.PriceTagTypes.ByOccupancyPercentPerRoomType Or 
						  vRoomRate.PriceTagType = Enums.PriceTagTypes.ByOccupancyPercentPerRoomTypePerDayType Then
						If Not vOccupationPercentsAreFilled And ValueIsFilled(RoomRate) And ValueIsFilled(RoomType) Then
							vOccupationPercentsAreFilled = True;
							pmFillOccupationPercents(vBegOfCheckInDate, vBegOfCheckOutDate);
						EndIf;
						vCurOccupancyPercentRow = OccupationPercents.Find(vCurAccountingDate, "AccountingDate");
						If vCurOccupancyPercentRow <> Undefined Then
							vCurOccupancyPercent = vCurOccupancyPercentRow.OccupationPercent;
							For Each vPriceTagRangesRow In vPriceTagRanges Do
								If vCurOccupancyPercent >= vPriceTagRangesRow.StartValue And vCurOccupancyPercent <= vPriceTagRangesRow.EndValue Then
									vCurPriceTag = vPriceTagRangesRow.PriceTag;
									Break;
								EndIf;
							EndDo;
						EndIf;
					EndIf;
				EndIf;
			EndIf;
		EndIf;
		// Fixed price tag
		If vPriceTagsAreUsed And ValueIsFilled(vFixedPriceTag) Then
			vCurPriceTag = vFixedPriceTag;
		EndIf;
		// Try to restore old calendar day type and old price tag values
		If vDayTypes.Count() > 0 And Not vRoomRate.Calendar.IsPerPeriod Then
			// Search old service with the same accounting date
			vDayTypeRows = vDayTypes.FindRows(New Structure("AccountingDate", vCurAccountingDate));
			For Each vDayTypeRow In vDayTypeRows Do
				If ValueIsFilled(vDayTypeRow.CalendarDayType) And vDayTypeRow.RoomRate = vRoomRate Then
					vCurCalendarDayType = vDayTypeRow.CalendarDayType;
					If vPriceTagsAreUsed And Not vResetPriceTagPrices Then
						vCurPriceTag = vDayTypeRow.PriceTag;
					EndIf;
					If vDayTypeRow.IsRoomRevenue And vDayTypeRow.IsInPrice Then
						Break;
					EndIf;
				EndIf;
			EndDo;
		EndIf;
		// Process each row in prices
		vPricesRowsByDayTypeAndPriceTag = vPrices.FindRows(New Structure("CalendarDayType, PriceTag", vCurCalendarDayType, vCurPriceTag));
		vPricesRowsByEmptyDayType = vPrices.FindRows(New Structure("CalendarDayType", Catalogs.CalendarDayTypes.EmptyRef()));
		For Each vPricesRowByEmptyDayType In vPricesRowsByEmptyDayType Do
			vPricesRowsByDayTypeAndPriceTag.Add(vPricesRowByEmptyDayType);
		EndDo;
		For Each vPricesRow In vPricesRowsByDayTypeAndPriceTag Do
			vCurRecorder = vPricesRow.Recorder;
			vCurService = vPricesRow.Service;
			vCurIsRoomRevenue = vPricesRow.IsRoomRevenue;
			vCurRoomRevenueAmountsOnly = ?(vDoesNotAffectRoomRevenueStatistics, vDoesNotAffectRoomRevenueStatistics, vPricesRow.RoomRevenueAmountsOnly);
			vCurIsInPrice = vPricesRow.IsInPrice;
			vCurAccountingDate = vDayRow.Period;
			vCurNumberOfPersons = vPricesRow.NumberOfPersonsInRoom;
			vCurNumberOfRooms = vPricesRow.NumberOfRooms;
			vCurNumberOfBeds = vPricesRow.NumberOfBeds;
			vCurNumberOfAdditionalBeds = vPricesRow.NumberOfAdditionalBeds;
			// Check price tags
			If vPriceTagsAreUsed Then
				If vCurPriceTag <> vPricesRow.PriceTag Then
					Continue;
				EndIf;
			ElsIf ValueIsFilled(vPricesRow.PriceTag) Then
				Continue;
			EndIf;
			// Retrieve current fixed discount
			vFixedServiceDiscount = 0;
			If Not vUseDocumentDiscount Then
				If vFixedDiscountPercents.Count() > 0 Then
					vFixedDiscountPercentsRows = vFixedDiscountPercents.FindRows(New Structure("Service, AccountingDate", vCurService, vCurAccountingDate));
					If vFixedDiscountPercentsRows.Count() > 0 Then
						vFixedDiscountPercentsRow = vFixedDiscountPercentsRows.Get(0);
						vFixedServiceDiscount = vFixedDiscountPercentsRow.Discount;
					EndIf;
				ElsIf vDiscountPercents.Count() > 0 Then
					vDiscountPercentsRows = vDiscountPercents.FindRows(New Structure("AccountingDate", vCurAccountingDate));
					If vDiscountPercentsRows.Count() > 0 Then
						vDiscountPercentsRow = vDiscountPercentsRows.Get(0);
						vFixedDiscount = vDiscountPercentsRow.Discount;
					Else
						vFixedDiscount = 0;
					EndIf;
				EndIf;
			EndIf;
			// Check that service fit to the room rate service group
			If cmIsServiceInServiceGroup(vCurService, RoomRateServiceGroup) Then
				If (vCurCalendarDayType = vPricesRow.CalendarDayType) Or 
				   (vPricesRow.CalendarDayType = Catalogs.CalendarDayTypes.EmptyRef() And 
				    (ValueIsFilled(vPricesRow.QuantityCalculationRule) Or 
				     vPricesRow.AccountingDayNumber = 0 And vCurAccountingDate = BegOfDay(vPricesRow.AccountingDate) Or 
				     vPricesRow.AccountingDayNumber = 9999 And vCurAccountingDate = vBegOfCheckOutDate Or 
				     vPricesRow.AccountingDayNumber <> 0 And vCurAccountingDate = (vBegOfCheckInDate + (vPricesRow.AccountingDayNumber - 1)*24*3600) Or 
				     Not ValueIsFilled(vPricesRow.QuantityCalculationRule) And Not ValueIsFilled(vPricesRow.AccountingDate) And vPricesRow.AccountingDayNumber = 0)) Then
					// Check accounting date time for service package
					If ValueIsFilled(vPricesRow.AccountingDate) And vPricesRow.AccountingDate <> BegOfDay(vPricesRow.AccountingDate) Then
						If BegOfDay(vCheckInDate) = BegOfDay(vPricesRow.AccountingDate) And vPricesRow.AccountingDate <= vCheckInDate Then
							Continue;
						EndIf;
						If BegOfDay(vCheckOutDate) = BegOfDay(vPricesRow.AccountingDate) And vPricesRow.AccountingDate >= vCheckOutDate Then
							Continue;
						EndIf;
					EndIf;
					// Save current price
					vCurPrice = vPricesRow.Price;
					vCurCurrency = vPricesRow.Currency;
					vCurUnit = vPricesRow.Unit;
					vRestOfCurPrice = 0;
					vCurRatePrice = vPricesRow.Price;
					// Check manual prices. Use it if one will be found.
					vIsManualPrice = cmGetManualPrice(vMPTab, vPricesRow.Service, vCurPrice, vCurCurrency, vCurUnit, vCurCalendarDayType, vPricesRow.Remarks);
					If vPricesRow.IsRoomRevenue And vPricesRow.IsInPrice Then
						If Not vIsManualPrice And ValueIsFilled(vRoomType) And ValueIsFilled(AccommodationTemplate) Then
							vProbeRoomType = vRoomType;
							If ValueIsFilled(RoomTypeUpgrade) Then
								vProbeRoomType = RoomTypeUpgrade;
							EndIf;
							If ValueIsFilled(RoomQuota) And RoomQuota.RoomTypes.Count() > 0 Then
								vRMPRows = RoomQuota.RoomTypes.FindRows(New Structure("NumberOfAdults, NumberOfTeenagers, NumberOfChildren, NumberOfInfants", NumberOfAdults, NumberOfTeenagers, NumberOfChildren, NumberOfInfants));
								For Each vRMPRow In vRMPRows Do
									If vRMPRow.Price <> 0 And vRMPRow.RoomType = vProbeRoomType Then
										If BegOfDay(vRMPRow.PeriodFrom) <= vCurAccountingDate And BegOfDay(vRMPRow.PeriodTo) > vCurAccountingDate Then
											vCurPrice = cmConvertCurrencies(vRMPRow.Price, vRMPRow.Currency, , vCurCurrency, , vCurAccountingDate, Hotel);
											Break;
										EndIf;
									EndIf;
								EndDo;
							EndIf;
							If ValueIsFilled(GuestGroup) And GuestGroup.InitialBlock.Count() > 0 Then
								vGMPRows = GuestGroup.InitialBlock.FindRows(New Structure("NumberOfAdults, NumberOfTeenagers, NumberOfChildren, NumberOfInfants", NumberOfAdults, NumberOfTeenagers, NumberOfChildren, NumberOfInfants));
								For Each vGMPRow In vGMPRows Do
									If vGMPRow.Price <> 0 And (Not ValueIsFilled(vGMPRow.RoomType) Or ValueIsFilled(vGMPRow.RoomType) And (vGMPRow.RoomType = vProbeRoomType Or vGMPRow.RoomType.IsFolder And vProbeRoomType.BelongsToItem(vGMPRow.RoomType))) Then
										vCurPrice = cmConvertCurrencies(vGMPRow.Price, vGMPRow.Currency, , vCurCurrency, , vCurAccountingDate, Hotel);
										Break;
									EndIf;
								EndDo;
							EndIf;
						EndIf;
					EndIf;
					// Initialize flags
					vEarlyCheckInIsCharged = False;
					vLateCheckOutIsCharged = False;
					vReservationServiceWasCharged = False;
					// Check charging rules
					vRoomRevenuePriceByRoomType = False;
					For Each vCRRow In vCRTab Do
						vCurAccountingDate = vDayRow.Period;
						vCurIsInRate = True;
						vCurQuantityCalculationRule = vPricesRow.QuantityCalculationRule;
						If ValueIsFilled(vCurQuantityCalculationRule) And (vCurQuantityCalculationRule.QuantityCalculationRuleType = Enums.QuantityCalculationRuleTypes.ResortFeeRu2018 Or vCurQuantityCalculationRule.QuantityCalculationRuleType = Enums.QuantityCalculationRuleTypes.ResortFeeRu2018CO) Then
							vCurIsInRate = False;
						EndIf;
						vCurIsSplit = False;
						vNoDiscounts = False;
						// Check if current service fit to the current charging rule
						If cmIsServiceFitToTheChargingRule(vCRRow, vCurService, vCurAccountingDate, vCurIsInRate, vCurIsRoomRevenue) Then
							// Check charging rule and do price correction if necessary
							If vCRRow.ChargingRule = Enums.ChargingRuleTypes.RoomRevenuePrice Then
								If TypeOf(vCRRow.ChargingRuleValue) = Type("Number") Then
									If vCRRow.ChargingRuleValue <> 0 Then
										If vCRRow.ChargingRuleValue < vPricesRow.Price Then
											vRestOfCurPrice = vCurPrice - vCRRow.ChargingRuleValue;
											vCurPrice = vCRRow.ChargingRuleValue;
										EndIf;
									Else
										Continue;
									EndIf;
								Else
									Continue;
								EndIf;
							ElsIf vCRRow.ChargingRule = Enums.ChargingRuleTypes.RoomRevenuePricePercent Then
								If TypeOf(vCRRow.ChargingRuleValue) = Type("Number") Then
									If vCRRow.ChargingRuleValue > 0 And vCRRow.ChargingRuleValue < 100 Then
										vSavCurPrice = vCurPrice;	
										vCurPrice = Round(vCurPrice * vCRRow.ChargingRuleValue / 100, 2);
										vRestOfCurPrice = vSavCurPrice - vCurPrice;
									Else
										Continue;
									EndIf;
								Else
									Continue;
								EndIf;
							ElsIf vCRRow.ChargingRule = Enums.ChargingRuleTypes.RoomRevenueAmount Then
								If TypeOf(vCRRow.ChargingRuleValue) = Type("Number") Then
									If vCRRow.ChargingRuleValue > 0 Then
										If Not vChargingRuleAmountIsSet Then
											vChargingRuleAmountIsSet = True;
											vRestOfCurAmount = vCRRow.ChargingRuleValue;
										EndIf;
										If vRestOfCurAmount <= 0 Then
											Continue;
										EndIf;
									Else
										Continue;
									EndIf;
								Else
									Continue;
								EndIf;
							ElsIf vCRRow.ChargingRule = Enums.ChargingRuleTypes.RoomRevenuePriceByRoomType Then
								If TypeOf(vCRRow.ChargingRuleValue) = Type("CatalogRef.RoomTypes") Then
									vCRRoomTypePricesRow = vCRRoomTypePrices.Find(vCRRow.ChargingRuleValue, "RoomType");
									If vCRRoomTypePricesRow <> Undefined Then
										vCRPrices = vCRRoomTypePricesRow.Prices;
										// Process each row in new prices
										vCurCRPrice = 0;
										vCurCRPriceIsFound = False;
										For Each vCRPricesRow In vCRPrices Do
											vCurCRService = vCRPricesRow.Service;
											vCurCRIsRoomRevenue = vCRPricesRow.IsRoomRevenue;
											vCurCRRoomRevenueAmountsOnly = vCRPricesRow.RoomRevenueAmountsOnly;
											vCurCRIsInPrice = vCRPricesRow.IsInPrice;
											// Check service package period
											If ValueIsFilled(vCRPricesRow.ServicePackage) And 
											  (vCurAccountingDate < vCRPricesRow.ServicePackageDateValidFrom Or vCurAccountingDate > vCRPricesRow.ServicePackageDateValidTo And ValueIsFilled(vCRPricesRow.ServicePackageDateValidTo)) Then
												Continue;
											EndIf;
											// Check that service fit to the room rate service group
											If cmIsServiceInServiceGroup(vCurCRService, RoomRateServiceGroup) Then
												If (vCurCalendarDayType = vCRPricesRow.CalendarDayType) Or 
												   (vCRPricesRow.CalendarDayType = Catalogs.CalendarDayTypes.EmptyRef() And 
												    (ValueIsFilled(vCRPricesRow.QuantityCalculationRule) Or 
												     vCRPricesRow.AccountingDayNumber = 0 And vCurAccountingDate = BegOfDay(vCRPricesRow.AccountingDate) Or 
												     vCRPricesRow.AccountingDayNumber = 9999 And vCurAccountingDate = vBegOfCheckOutDate Or 
												     vCRPricesRow.AccountingDayNumber <> 0 And vCurAccountingDate = (vBegOfCheckInDate + (vCRPricesRow.AccountingDayNumber - 1)*24*3600) Or 
												     Not ValueIsFilled(vCRPricesRow.QuantityCalculationRule) And Not ValueIsFilled(vCRPricesRow.AccountingDate) And vCRPricesRow.AccountingDayNumber = 0)) Then
													// Check accounting date time for service package
													If ValueIsFilled(vCRPricesRow.AccountingDate) And vCRPricesRow.AccountingDate <> BegOfDay(vCRPricesRow.AccountingDate) Then
														If BegOfDay(vCheckInDate) = BegOfDay(vCRPricesRow.AccountingDate) And vCRPricesRow.AccountingDate <= vCheckInDate Then
															Continue;
														EndIf;
														If BegOfDay(vCheckOutDate) = BegOfDay(vCRPricesRow.AccountingDate) And vCRPricesRow.AccountingDate >= vCheckOutDate Then
															Continue;
														EndIf;
													EndIf;
													// Save current price
													vCurCRPrice = vCRPricesRow.Price;
													vCurCRPriceIsFound = True;
													Break;
												EndIf;
											EndIf;
										EndDo;
										If vCurCRPriceIsFound Then
											If vCurCRPrice < vPricesRow.Price Then
												vRestOfCurPrice = vCurPrice - vCurCRPrice;
												vCurPrice = vCurCRPrice;
												vRoomRevenuePriceByRoomType = True;
											EndIf;
										EndIf;
									EndIf;
								Else
									Continue;
								EndIf;
							ElsIf vCRRow.ChargingRule = Enums.ChargingRuleTypes.RestOfRoomRevenuePrice Then
								If vChargingRuleAmountIsSet Then
									If vRestOfServiceSum > 0 Then
										Continue;
									EndIf;
								Else
									If vRestOfCurPrice <> 0 Then
										vCurPrice = vRestOfCurPrice;
										vRestOfCurPrice = 0;
										vCurIsSplit = True;
										If vRoomRevenuePriceByRoomType Then
											vNoDiscounts = True;
										EndIf;
									Else
										Continue;
									EndIf;
								EndIf;
							EndIf;
							// Check folio
							vCurFolio = vCRRow.ChargingFolio;
							If Not ValueIsFilled(vCurFolio) Then
								Continue;
							EndIf;
							// Restore prices from the reservation
							If FixReservationConditions And IsByReservation And vPricesRow.IsRoomRevenue And vPricesRow.IsInPrice And vRoomType = vReservationRoomType And vAccommodationType = vReservationAccommodationType And ValueIsFilled(vCurPriceTag) And 
							   vCurAccountingDate >= BegOfDay(vReservationCheckInDate) And vCurAccountingDate < BegOfDay(vReservationCheckOutDate) Then
								vReservationServices = vReservation.Services.FindRows(New Structure("AccountingDate, Service, Folio, IsInPrice, IsSplit", vCurAccountingDate, vCurService, vCurFolio, True, False));
								If vReservationServices.Count() = 1 Then
									vReservationServicesRow = vReservationServices.Get(0);
									vCurPrice = vReservationServicesRow.Price;
									vCurCurrency = vReservationServicesRow.FolioCurrency;
								EndIf;
							EndIf;
							vCurFolioCurrency = vCurFolio.FolioCurrency;
							vCurFolioCurrencyExchangeRate = cmGetCurrencyExchangeRate(Hotel, vCurFolioCurrency, ?(ValueIsFilled(vCurAccountingDate), vCurAccountingDate, ExchangeRateDate));
							vCompany = Company;
							If ValueIsFilled(vCurFolio.Company) And vCurFolio.DoNotUpdateCompany Then
								vCompany = vCurFolio.Company;
							EndIf;
							vCurVATRate = ?(vCompany.IsUsingSimpleTaxSystem, vCompany.VATRate, vPricesRow.VATRate);
							vCurMinQuantity = vPricesRow.MinimumQuantity;
							vCurRemarks = "";
							vIsDayUse = False;
							vSrvAccountingDate = vCurAccountingDate;
							vOccParams = Undefined;
							// Calculate quantity
							vCurQuantity = cmCalculateServiceQuantity(vCurService, vCurQuantityCalculationRule, 
							                                          vSrvAccountingDate, vCheckInDate, vCheckOutDate, 
							                                          ThisObject, vParentDocObj, vIsCheckIn, vIsBasedOnReservation, 
							                                          vIsBeforeRoomChange, vIsRoomChange, vIsCheckOut, IsOneTimeChargeNecessary, 
							                                          vCurPrice, vCurCurrency, vCurRemarks, vIsDayUse, vCurMinQuantity, vAccommodationPeriods, 
																	  vOccParams);
							If vCurCurrency <> vCurFolioCurrency Then
								vCurPriceInFolioCurrency = Round(cmConvertCurrencies(vCurPrice, vCurCurrency, , vCurFolioCurrency, vCurFolioCurrencyExchangeRate, ?(ValueIsFilled(vCurAccountingDate), vCurAccountingDate, ExchangeRateDate), Hotel), 2);
								vCurRatePriceInFolioCurrency = Round(cmConvertCurrencies(vCurRatePrice, vCurCurrency, , vCurFolioCurrency, vCurFolioCurrencyExchangeRate, ?(ValueIsFilled(vCurAccountingDate), vCurAccountingDate, ExchangeRateDate), Hotel), 2);
							Else
								vCurPriceInFolioCurrency = vCurPrice;
								vCurRatePriceInFolioCurrency = vCurRatePrice;
							EndIf;
							vCurQuantity = vCurQuantity * vPricesRow.Quantity;
							// Take number of persons into account
							vCurSrvQuantity = vCurQuantity;
							If vPricesRow.IsPricePerPerson Then
								vCurQuantity = vCurQuantity * NumberOfPersons;
							EndIf;
							// Fill remarks
							If Not IsBlankString(vPricesRow.Remarks) Then
								vCurRemarks = vPricesRow.Remarks;
							EndIf;
							// Check service package period
							If ValueIsFilled(vPricesRow.ServicePackage) And 
							  (vCurAccountingDate < vPricesRow.ServicePackageDateValidFrom Or vCurAccountingDate > vPricesRow.ServicePackageDateValidTo And ValueIsFilled(vPricesRow.ServicePackageDateValidTo)) Then
								Break;
							EndIf;
							// Process quantity calculation rule parameters
							If ValueIsFilled(vCurQuantityCalculationRule) Then
								// Skip reservation charge if parent document is not reservation
								If Not vIsBasedOnReservation Then
									If vCurQuantityCalculationRule.QuantityCalculationRuleType = Enums.QuantityCalculationRuleTypes.Reservation Then
										Break;
									EndIf;
								EndIf;
								// Skip service based on "foreigners only" or "citizens only" parameters
								If vCurQuantityCalculationRule.ForeignersOnly Or vCurQuantityCalculationRule.CitizensOnly Then
									If ValueIsFilled(Hotel) And ValueIsFilled(Hotel.Citizenship) And 
									   ValueIsFilled(Guest) And ValueIsFilled(Guest.Citizenship) Then
										If Guest.Citizenship = Hotel.Citizenship Then
											If vCurQuantityCalculationRule.ForeignersOnly Then
												Break;
											EndIf;
										Else
											If vCurQuantityCalculationRule.CitizensOnly Then
												Break;
											EndIf;
										EndIf;
									Else
										If vCurQuantityCalculationRule.ForeignersOnly Then
											Break;
										EndIf;
									EndIf;
								EndIf;
							EndIf;
							vSavCurQuantity = vCurQuantity;
							// Change price to the rack rate if this is day use
							If FixReservationConditions And IsByReservation And vPricesRow.IsRoomRevenue And vPricesRow.IsInPrice And 
							   (vCurAccountingDate < BegOfDay(vReservationCheckInDate) Or 
							    vCurAccountingDate = BegOfDay(vReservationCheckInDate) And CheckInDate < vReservationCheckInDate Or
							    vCurAccountingDate > BegOfDay(vReservationCheckOutDate) Or
							    vCurAccountingDate = BegOfDay(vReservationCheckOutDate) And CheckOutDate > vReservationCheckOutDate) Then
								If vCurAccountingDate < BegOfDay(vReservationCheckInDate) Or
								   vCurAccountingDate > BegOfDay(vReservationCheckOutDate) Then
									vWrkRoomRate = vRoomRate;
									If ValueIsFilled(vCRRow.ChargingFolio) And ValueIsFilled(vCRRow.ChargingFolio.Customer) And Not vCRRow.ChargingFolio.Customer.IsIndividual Then
										Continue; // Continue to the next charging rule
									EndIf;
									// Add service to the services tabular part if quantity is not zero
									If vCurQuantity > 0 Then
										vWrkNoDiscounts = vNoDiscounts;
										If ValueIsFilled(vRoomRate.RackRate) Then
											vWrkRoomRate = vRoomRate.RackRate;
										Else
											vWrkRoomRate = Hotel.RoomRate;
										EndIf;
										vRackCurrency = vCurCurrency;
										If vWrkRoomRate <> vRoomRate Then
											vPriceCalcDate = CheckOutDate;
											If vCurAccountingDate < BegOfDay(vReservationCheckInDate) Then
												vPriceCalcDate = CheckInDate;
											EndIf;
											vRackPrice = pmGetServiceRatePrice(vWrkRoomRate, vCurAccountingDate, vPriceCalcDate, vCurService, vRackCurrency, vRoomType, ?(vCurPriceTag = Undefined, Catalogs.PriceTags.EmptyRef(), vCurPriceTag), vAccommodationType, vAccommodationTemplate, vIsForFolioSplit);
											If vRackPrice <> 0 Then
												If vRackCurrency <> vCurFolioCurrency Then
													vCurPriceInFolioCurrency = Round(cmConvertCurrencies(vRackPrice, vRackCurrency, , vCurFolioCurrency, vCurFolioCurrencyExchangeRate, ?(ValueIsFilled(vCurAccountingDate), vCurAccountingDate, ExchangeRateDate), Hotel), 2);
												Else
													vCurPriceInFolioCurrency = vRackPrice;
												EndIf;
												// If discount type is from the customer then it shouldn't be applied
												If ValueIsFilled(Contract) And ValueIsFilled(Contract.DiscountType) And Contract.DiscountType = DiscountType Then
													vWrkNoDiscounts = True;
												ElsIf ValueIsFilled(Customer) And ValueIsFilled(Customer.DiscountType) And Customer.DiscountType = DiscountType Then
													vWrkNoDiscounts = True;
												ElsIf ValueIsFilled(RoomRate) And ValueIsFilled(RoomRate.DiscountType) And RoomRate.DiscountType = DiscountType Then
													vWrkNoDiscounts = True;
												EndIf;
											Else
												vWrkRoomRate = vRoomRate;
											EndIf;
										EndIf;
										AddService(i, vCurFolio, vCurFolioCurrency, vCurFolioCurrencyExchangeRate, vSrvAccountingDate,
										           vCurService, vCurPriceInFolioCurrency, vCurRatePriceInFolioCurrency, vCurUnit, vCurQuantity, vCurVATRate, vCurRemarks, 
										           vCurIsRoomRevenue, vCurIsInPrice, vCurIsSplit, vCurRoomRevenueAmountsOnly, vCurCalendarDayType, vCurTimetable, vCurPriceTag, vCurQuantityCalculationRule,
										           vCurSrvQuantity, vFirstDayWithAccommodationService, vIsCheckIn, vIsRoomChange, vIsCheckOut, 
										           vFixedDiscount, vFixedServiceDiscount, vPeriodDiscount, vPeriodDiscountType, vPeriodDiscountServiceGroup, vPeriodDiscountConfirmationText, 
										           vAccDiscounts, vMCServices, vNoAccommodationService, vWrkRoomRate, vAccommodationType, vRoom, vRoomRoomType, vWrkNoDiscounts, 
												   vRoomRevenuePriceByRoomType, vRestOfCurPrice, vRestOfCurAmount, vChargingRuleAmountIsSet, vRestOfServiceSum, 
												   vRoomRates, True, vCRTab, vComplexCommission, vPricesRow.PacketPriceIsIncludedInRoomRate, vCurRoomRateSrv, rWarnings, vOccParams, 
												   vPricesRow.ServicePackageUsageType, vPricesRow.ServicePackage, vMealBoardTermIncluded, vMealBoardTermIncludedServices, vContractMealBoardTerms, vReservationDate, vAccommodationTemplate, 
												   vCurNumberOfPersons, vCurNumberOfRooms, vCurNumberOfBeds, vCurNumberOfAdditionalBeds,
												   vCurRoomRateSrvHasManualPrice, vIsManualPrice, vPriceCalcDate, vOffers, vIsForFolioSplit);
										// We've found suitable charging rule so move to the other service
										If vChargingRuleAmountIsSet Then
											If vRestOfCurAmount > 0 Then
												Break;
											ElsIf vRestOfServiceSum <= 0 Then
												Break;
											EndIf;
										Else
											If vRestOfCurPrice = 0 Then
												Break;
											EndIf;
										EndIf;
									EndIf;
								ElsIf vCurAccountingDate = BegOfDay(vReservationCheckInDate) And 
								      CheckInDate < vReservationCheckInDate Then
									If Not vEarlyCheckInIsCharged Then
										vEarlyCheckInIsCharged = True;
										// Add service with early check-in based on reservation period
										vWrkPrice = vCurPriceInFolioCurrency;
										vWrkAccountingDate = vDayRow.Period;
										vEarlyCheckInQuantity = cmCalculateServiceQuantity(vCurService, vCurQuantityCalculationRule, 
										                                                   vWrkAccountingDate, vReservationCheckInDate, vReservationCheckOutDate, 
										                                                   ThisObject, vParentDocObj, vIsCheckIn, vIsBasedOnReservation, 
										                                                   vIsBeforeRoomChange, vIsRoomChange, vIsCheckOut, IsOneTimeChargeNecessary, 
										                                                   vWrkPrice, vCurCurrency, vCurRemarks, vIsDayUse);
										vEarlyCheckInQuantity = vEarlyCheckInQuantity * vPricesRow.Quantity;
										// Take number of persons into account
										vEarlyCheckInSrvQuantity = vEarlyCheckInQuantity;
										If vPricesRow.IsPricePerPerson Then
											vEarlyCheckInQuantity = vEarlyCheckInQuantity * NumberOfPersons;
										EndIf;
										If vEarlyCheckInQuantity > 0 Then
											If Not (vThereAreCustomerChargingRules And FixReservationConditions And IsByReservation And ValueIsFilled(Reservation) And (vReservationRoomType <> vRoomType Or vReservationAccommodationType <> vAccommodationType)) Then
												AddService(i, vCurFolio, vCurFolioCurrency, vCurFolioCurrencyExchangeRate, vSrvAccountingDate,
												           vCurService, vWrkPrice, vCurRatePriceInFolioCurrency, vCurUnit, vEarlyCheckInQuantity, vCurVATRate, vCurRemarks, 
												           vCurIsRoomRevenue, vCurIsInPrice, False, vCurRoomRevenueAmountsOnly, vCurCalendarDayType, vCurTimetable, vCurPriceTag, vCurQuantityCalculationRule,
												           vEarlyCheckInSrvQuantity, vFirstDayWithAccommodationService, vIsCheckIn, vIsRoomChange, vIsCheckOut, 
												           vFixedDiscount, vFixedServiceDiscount, vPeriodDiscount, vPeriodDiscountType, vPeriodDiscountServiceGroup, vPeriodDiscountConfirmationText, 
												           vAccDiscounts, vMCServices, vNoAccommodationService, vRoomRate, vAccommodationType, vRoom, vRoomRoomType, vNoDiscounts, 
														   vRoomRevenuePriceByRoomType, vRestOfCurPrice, vRestOfCurAmount, vChargingRuleAmountIsSet, vRestOfServiceSum, 
														   vRoomRates, , vCRTab, vComplexCommission, vPricesRow.PacketPriceIsIncludedInRoomRate, vCurRoomRateSrv, rWarnings, , 
														   vPricesRow.ServicePackageUsageType, vPricesRow.ServicePackage, vMealBoardTermIncluded, vMealBoardTermIncludedServices, vContractMealBoardTerms, vReservationDate, vAccommodationTemplate, 
														   vCurNumberOfPersons, vCurNumberOfRooms, vCurNumberOfBeds, vCurNumberOfAdditionalBeds, 
														   vCurRoomRateSrvHasManualPrice, vIsManualPrice, vPriceCalcDate, vOffers, vIsForFolioSplit);
											EndIf;
										EndIf;
									EndIf;
									If Not ValueIsFilled(vCurFolio.Customer) Or ValueIsFilled(vCurFolio.Customer) And vCurFolio.Customer.IsIndividual And Not vSplitChargesToPersonalFolioForIndividualCustomers Then
										// Add service to the services tabular part if quantity is not zero
										vWrkRoomRate = vRoomRate;
										vCurQuantity = vCurQuantity - vEarlyCheckInQuantity;
										vCurSrvQuantity = vCurSrvQuantity - vEarlyCheckInSrvQuantity;
										If vCurQuantity > 0 Then
											vWrkNoDiscounts = vNoDiscounts;
											If ValueIsFilled(vRoomRate.RackRate) Then
												vWrkRoomRate = vRoomRate.RackRate;
											Else
												vWrkRoomRate = Hotel.RoomRate;
											EndIf;
											vWrkPrice = vCurPriceInFolioCurrency;
											vRackCurrency = vCurCurrency;
											vRackPrice = pmGetServiceRatePrice(vWrkRoomRate, vCurAccountingDate, CheckInDate, vCurService, vRackCurrency, vRoomType, ?(vCurPriceTag = Undefined, Catalogs.PriceTags.EmptyRef(), vCurPriceTag), vAccommodationType, vAccommodationTemplate, vIsForFolioSplit);
											If vRackPrice <> 0 Then
												If vRackCurrency <> vCurFolioCurrency Then
													vWrkPrice = Round(cmConvertCurrencies(vRackPrice, vRackCurrency, , vCurFolioCurrency, vCurFolioCurrencyExchangeRate, ?(ValueIsFilled(vCurAccountingDate), vCurAccountingDate, ExchangeRateDate), Hotel), 2);
												Else
													vWrkPrice = vRackPrice;
												EndIf;
												// If discount type is from the customer then it shouldn't be applied
												If ValueIsFilled(Contract) And ValueIsFilled(Contract.DiscountType) And Contract.DiscountType = DiscountType Then
													vWrkNoDiscounts = True;
												ElsIf ValueIsFilled(Customer) And ValueIsFilled(Customer.DiscountType) And Customer.DiscountType = DiscountType Then
													vWrkNoDiscounts = True;
												ElsIf ValueIsFilled(RoomRate) And ValueIsFilled(RoomRate.DiscountType) And RoomRate.DiscountType = DiscountType Then
													vWrkNoDiscounts = True;
												EndIf;
											Else
												vWrkRoomRate = vRoomRate;
											EndIf;
											vWrkRemarks = vCurRemarks;
											If vEarlyCheckInSrvQuantity <> 0 Then
												vWrkRemarks = NStr("ru='Доп. начисление " + Round(vCurSrvQuantity*24, 0) + " часов';en='Add. charge " + Round(vCurSrvQuantity*24, 0) + " hours';de='Aufpreis " + Round(vCurSrvQuantity*24, 0) + " Stunden'");
											EndIf;
											AddService(i, vCurFolio, vCurFolioCurrency, vCurFolioCurrencyExchangeRate, vSrvAccountingDate,
											           vCurService, vWrkPrice, vCurRatePriceInFolioCurrency, vCurUnit, vCurQuantity, vCurVATRate, vWrkRemarks, 
											           vCurIsRoomRevenue, vCurIsInPrice, False, vCurRoomRevenueAmountsOnly, vCurCalendarDayType, vCurTimetable, vCurPriceTag, vCurQuantityCalculationRule,
											           vCurSrvQuantity, vFirstDayWithAccommodationService, vIsCheckIn, vIsRoomChange, vIsCheckOut, 
											           vFixedDiscount, vFixedServiceDiscount, vPeriodDiscount, vPeriodDiscountType, vPeriodDiscountServiceGroup, vPeriodDiscountConfirmationText, 
											           vAccDiscounts, vMCServices, vNoAccommodationService, vWrkRoomRate, vAccommodationType, vRoom, vRoomRoomType, vWrkNoDiscounts, 
													   vRoomRevenuePriceByRoomType, vRestOfCurPrice, vRestOfCurAmount, vChargingRuleAmountIsSet, vRestOfServiceSum, 
													   vRoomRates, True, vCRTab, vComplexCommission, vPricesRow.PacketPriceIsIncludedInRoomRate, vCurRoomRateSrv, rWarnings, , 
													   vPricesRow.ServicePackageUsageType, vPricesRow.ServicePackage, vMealBoardTermIncluded, vMealBoardTermIncludedServices, vContractMealBoardTerms, vReservationDate, vAccommodationTemplate, 
													   vCurNumberOfPersons, vCurNumberOfRooms, vCurNumberOfBeds, vCurNumberOfAdditionalBeds, 
													   vCurRoomRateSrvHasManualPrice, vIsManualPrice, vPriceCalcDate, vOffers, vIsForFolioSplit);
											// We've found suitable charging rule so move to the other service
											If Not (vThereAreCustomerChargingRules And FixReservationConditions And IsByReservation And ValueIsFilled(Reservation) And (vReservationRoomType <> vRoomType Or vReservationAccommodationType <> vAccommodationType)) Then
												Break;
											EndIf;
										EndIf;
									EndIf;
								ElsIf vCurAccountingDate = BegOfDay(vReservationCheckOutDate) And 
								      CheckOutDate > vReservationCheckOutDate Then
									If Not vLateCheckOutIsCharged Then
										vLateCheckOutIsCharged = True;
										// Add service with late check-out based on reservation period
										vWrkPrice = vCurPriceInFolioCurrency;
										vWrkAccountingDate = vDayRow.Period;
										vLateCheckOutQuantity = cmCalculateServiceQuantity(vCurService, vCurQuantityCalculationRule, 
										                                                   vWrkAccountingDate, vReservationCheckInDate, vReservationCheckOutDate, 
										                                                   ThisObject, vParentDocObj, vIsCheckIn, vIsBasedOnReservation, 
										                                                   vIsBeforeRoomChange, vIsRoomChange, vIsCheckOut, IsOneTimeChargeNecessary, 
										                                                   vWrkPrice, vCurCurrency, vCurRemarks, vIsDayUse);
										vLateCheckOutQuantity = vLateCheckOutQuantity * vPricesRow.Quantity;
										// Take number of persons into account
										vLateCheckOutSrvQuantity = vLateCheckOutQuantity;
										If vPricesRow.IsPricePerPerson Then
											vLateCheckOutQuantity = vLateCheckOutQuantity * NumberOfPersons;
										EndIf;
										If vLateCheckOutQuantity > 0 Then
											If Not (vThereAreCustomerChargingRules And FixReservationConditions And IsByReservation And ValueIsFilled(Reservation) And (vReservationRoomType <> vRoomType Or vReservationAccommodationType <> vAccommodationType)) Then
												AddService(i, vCurFolio, vCurFolioCurrency, vCurFolioCurrencyExchangeRate, vSrvAccountingDate,
												           vCurService, vWrkPrice, vCurRatePriceInFolioCurrency, vCurUnit, vLateCheckOutQuantity, vCurVATRate, vCurRemarks, 
												           vCurIsRoomRevenue, vCurIsInPrice, False, vCurRoomRevenueAmountsOnly, vCurCalendarDayType, vCurTimetable, vCurPriceTag, vCurQuantityCalculationRule,
												           vCurSrvQuantity, vFirstDayWithAccommodationService, vIsCheckIn, vIsRoomChange, vIsCheckOut, 
												           vFixedDiscount, vFixedServiceDiscount, vPeriodDiscount, vPeriodDiscountType, vPeriodDiscountServiceGroup, vPeriodDiscountConfirmationText, 
												           vAccDiscounts, vMCServices, vNoAccommodationService, vRoomRate, vAccommodationType, vRoom, vRoomRoomType, vNoDiscounts, 
														   vRoomRevenuePriceByRoomType, vRestOfCurPrice, vRestOfCurAmount, vChargingRuleAmountIsSet, vRestOfServiceSum, 
														   vRoomRates, , vCRTab, vComplexCommission, vPricesRow.PacketPriceIsIncludedInRoomRate, vCurRoomRateSrv, rWarnings, , 
														   vPricesRow.ServicePackageUsageType, vPricesRow.ServicePackage, vMealBoardTermIncluded, vMealBoardTermIncludedServices, vContractMealBoardTerms, vReservationDate, vAccommodationTemplate, 
														   vCurNumberOfPersons, vCurNumberOfRooms, vCurNumberOfBeds, vCurNumberOfAdditionalBeds, 
														   vCurRoomRateSrvHasManualPrice, vIsManualPrice, vPriceCalcDate, vOffers, vIsForFolioSplit);
											EndIf;
										EndIf;
									EndIf;
									If Not ValueIsFilled(vCurFolio.Customer) Or ValueIsFilled(vCurFolio.Customer) And vCurFolio.Customer.IsIndividual And Not vSplitChargesToPersonalFolioForIndividualCustomers Then
										// Add service to the services tabular part if quantity is not zero
										vWrkRoomRate = vRoomRate;
										vCurQuantity = vCurQuantity - vLateCheckOutQuantity;
										vCurSrvQuantity = vCurSrvQuantity - vLateCheckOutSrvQuantity;
										If vCurQuantity > 0 Then
											vWrkNoDiscounts = vNoDiscounts;
											If ValueIsFilled(vRoomRate.RackRate) Then
												vWrkRoomRate = vRoomRate.RackRate;
											Else
												vWrkRoomRate = Hotel.RoomRate;
											EndIf;
											vWrkPrice = vCurPriceInFolioCurrency;
											vRackCurrency = vCurCurrency;
											vRackPrice = pmGetServiceRatePrice(vWrkRoomRate, vCurAccountingDate, CheckOutDate, vCurService, vRackCurrency, vRoomType, ?(vCurPriceTag = Undefined, Catalogs.PriceTags.EmptyRef(), vCurPriceTag), vAccommodationType, vAccommodationTemplate, vIsForFolioSplit);
											If vRackPrice <> 0 Then
												If vRackCurrency <> vCurFolioCurrency Then
													vWrkPrice = Round(cmConvertCurrencies(vRackPrice, vRackCurrency, , vCurFolioCurrency, vCurFolioCurrencyExchangeRate, ?(ValueIsFilled(vCurAccountingDate), vCurAccountingDate, ExchangeRateDate), Hotel), 2);
												Else
													vWrkPrice = vRackPrice;
												EndIf;
												// If discount type is from the customer then it shouldn't be applied
												If ValueIsFilled(Contract) And ValueIsFilled(Contract.DiscountType) And Contract.DiscountType = DiscountType Then
													vWrkNoDiscounts = True;
												ElsIf ValueIsFilled(Customer) And ValueIsFilled(Customer.DiscountType) And Customer.DiscountType = DiscountType Then
													vWrkNoDiscounts = True;
												ElsIf ValueIsFilled(RoomRate) And ValueIsFilled(RoomRate.DiscountType) And RoomRate.DiscountType = DiscountType Then
													vWrkNoDiscounts = True;
												EndIf;
											Else
												vWrkRoomRate = vRoomRate;
											EndIf;
											vWrkRemarks = vCurRemarks;
											If vLateCheckOutSrvQuantity <> 0 Then
												vWrkRemarks = NStr("ru='Доп. начисление " + Round(vCurSrvQuantity*24, 0) + " часов';en='Add. charge " + Round(vCurSrvQuantity*24, 0) + " hours';de='Aufpreis " + Round(vCurSrvQuantity*24, 0) + " Stunden'");
											EndIf;
											AddService(i, vCurFolio, vCurFolioCurrency, vCurFolioCurrencyExchangeRate, vSrvAccountingDate,
											           vCurService, vWrkPrice, vCurRatePriceInFolioCurrency, vCurUnit, vCurQuantity, vCurVATRate, vWrkRemarks, 
											           vCurIsRoomRevenue, vCurIsInPrice, False, vCurRoomRevenueAmountsOnly, vCurCalendarDayType, vCurTimetable, vCurPriceTag, vCurQuantityCalculationRule,
											           vCurSrvQuantity, vFirstDayWithAccommodationService, vIsCheckIn, vIsRoomChange, vIsCheckOut, 
											           vFixedDiscount, vFixedServiceDiscount, vPeriodDiscount, vPeriodDiscountType, vPeriodDiscountServiceGroup, vPeriodDiscountConfirmationText, 
											           vAccDiscounts, vMCServices, vNoAccommodationService, vWrkRoomRate, vAccommodationtype, vRoom, vRoomRoomType, vWrkNoDiscounts, 
													   vRoomRevenuePriceByRoomType, vRestOfCurPrice, vRestOfCurAmount, vChargingRuleAmountIsSet, vRestOfServiceSum, 
													   vRoomRates, True, vCRTab, vComplexCommission, vPricesRow.PacketPriceIsIncludedInRoomRate, vCurRoomRateSrv, rWarnings, , 
													   vPricesRow.ServicePackageUsageType, vPricesRow.ServicePackage, vMealBoardTermIncluded, vMealBoardTermIncludedServices, vContractMealBoardTerms, vReservationDate, vAccommodationTemplate, 
													   vCurNumberOfPersons, vCurNumberOfRooms, vCurNumberOfBeds, vCurNumberOfAdditionalBeds, 
													   vCurRoomRateSrvHasManualPrice, vIsManualPrice, vPriceCalcDate, vOffers, vIsForFolioSplit);
											// We've found suitable charging rule so move to the other service
											If Not (vThereAreCustomerChargingRules And FixReservationConditions And IsByReservation And ValueIsFilled(Reservation) And (vReservationRoomType <> vRoomType Or vReservationAccommodationType <> vAccommodationType)) Then
												Break;
											EndIf;
										EndIf;
									EndIf;
								EndIf;
								// Check if there are customer folios
								If vThereAreCustomerChargingRules And FixReservationConditions And IsByReservation And ValueIsFilled(Reservation) And (vReservationRoomType <> vRoomType Or vReservationAccommodationType <> vAccommodationType) And 
								   (vCurAccountingDate >= BegOfDay(vReservationCheckInDate) Or vCurAccountingDate < BegOfDay(vReservationCheckOutDate)) Then
									vCurQuantity = vSavCurQuantity;
									If vCurQuantity <> 0 Then
										If ValueIsFilled(vCurFolio.Customer) And Not vCurFolio.Customer.IsIndividual Then
											// Get reservation price
											If Not vReservationServiceWasCharged Then
												vReservationSevicesRows = Reservation.Services.FindRows(New Structure("AccountingDate, Service, IsRoomRevenue, IsInPrice, IsSplit", vSrvAccountingDate, vCurService, vCurIsRoomRevenue, vCurIsInPrice, vCurIsSplit));
												If vReservationSevicesRows.Count() > 0 Then
													vReservationSevicesRow = vReservationSevicesRows.Get(0);
													If vReservationSevicesRow.FolioCurrency <> vCurFolioCurrency Then
														vReservationPriceInFolioCurrency = Round(cmConvertCurrencies(vReservationSevicesRow.Price, vReservationSevicesRow.FolioCurrency, vReservationSevicesRow.FolioCurrencyExchangeRate, vCurFolioCurrency, vCurFolioCurrencyExchangeRate, ?(ValueIsFilled(vCurAccountingDate), vCurAccountingDate, ExchangeRateDate), Hotel), 2);
													Else
														vReservationPriceInFolioCurrency = vReservationSevicesRow.Price;
													EndIf;
													AddService(i, vCurFolio, vCurFolioCurrency, vCurFolioCurrencyExchangeRate, vSrvAccountingDate,
													           vCurService, vReservationPriceInFolioCurrency, vCurRatePriceInFolioCurrency, vCurUnit, vCurQuantity, vCurVATRate, vCurRemarks, 
													           vCurIsRoomRevenue, vCurIsInPrice, vCurIsSplit, vCurRoomRevenueAmountsOnly, vCurCalendarDayType, vCurTimetable, vCurPriceTag, vCurQuantityCalculationRule,
													           vCurSrvQuantity, vFirstDayWithAccommodationService, vIsCheckIn, vIsRoomChange, vIsCheckOut, 
													           vFixedDiscount, vFixedServiceDiscount, vPeriodDiscount, vPeriodDiscountType, vPeriodDiscountServiceGroup, vPeriodDiscountConfirmationText, 
													           vAccDiscounts, vMCServices, vNoAccommodationService, vRoomRate, vAccommodationType, vRoom, vRoomRoomType, vNoDiscounts, 
															   vRoomRevenuePriceByRoomType, vRestOfCurPrice, vRestOfCurAmount, vChargingRuleAmountIsSet, vRestOfServiceSum, 
															   vRoomRates, , vCRTab, vComplexCommission, vPricesRow.PacketPriceIsIncludedInRoomRate, vCurRoomRateSrv, rWarnings, vOccParams, 
															   vPricesRow.ServicePackageUsageType, vPricesRow.ServicePackage, vMealBoardTermIncluded, vMealBoardTermIncludedServices, vContractMealBoardTerms, vReservationDate, vAccommodationTemplate, 
															   vCurNumberOfPersons, vCurNumberOfRooms, vCurNumberOfBeds, vCurNumberOfAdditionalBeds, 
															   vCurRoomRateSrvHasManualPrice, vIsManualPrice, vPriceCalcDate, vOffers, vIsForFolioSplit);
													vReservationServiceWasCharged = True;
												EndIf;
											EndIf;
										Else
											If Not vReservationServiceWasCharged Then
												// Get reservation price
												vReservationSevicesRows = Reservation.Services.FindRows(New Structure("AccountingDate, Service, IsRoomRevenue, IsInPrice, IsSplit", vSrvAccountingDate, vCurService, vCurIsRoomRevenue, vCurIsInPrice, vCurIsSplit));
												If vReservationSevicesRows.Count() > 0 Then
													vReservationSevicesRow = vReservationSevicesRows.Get(0);
													If vReservationSevicesRow.FolioCurrency <> vCurFolioCurrency Then
														vReservationPriceInFolioCurrency = Round(cmConvertCurrencies(vReservationSevicesRow.Price, vReservationSevicesRow.FolioCurrency, vReservationSevicesRow.FolioCurrencyExchangeRate, vCurFolioCurrency, vCurFolioCurrencyExchangeRate, ?(ValueIsFilled(vCurAccountingDate), vCurAccountingDate, ExchangeRateDate), Hotel), 2);
													Else
														vReservationPriceInFolioCurrency = vReservationSevicesRow.Price;
													EndIf;
													AddService(i, vCurFolio, vCurFolioCurrency, vCurFolioCurrencyExchangeRate, vSrvAccountingDate,
													           vCurService, vReservationPriceInFolioCurrency, vCurRatePriceInFolioCurrency, vCurUnit, vCurQuantity, vCurVATRate, vCurRemarks, 
													           vCurIsRoomRevenue, vCurIsInPrice, vCurIsSplit, vCurRoomRevenueAmountsOnly, vCurCalendarDayType, vCurTimetable, vCurPriceTag, vCurQuantityCalculationRule,
													           vCurSrvQuantity, vFirstDayWithAccommodationService, vIsCheckIn, vIsRoomChange, vIsCheckOut, 
													           vFixedDiscount, vFixedServiceDiscount, vPeriodDiscount, vPeriodDiscountType, vPeriodDiscountServiceGroup, vPeriodDiscountConfirmationText, 
													           vAccDiscounts, vMCServices, vNoAccommodationService, vRoomRate, vAccommodationType, vRoom, vRoomRoomType, vNoDiscounts, 
															   vRoomRevenuePriceByRoomType, vRestOfCurPrice, vRestOfCurAmount, vChargingRuleAmountIsSet, vRestOfServiceSum, 
															   vRoomRates, , vCRTab, vComplexCommission, vPricesRow.PacketPriceIsIncludedInRoomRate, vCurRoomRateSrv, rWarnings, vOccParams, 
															   vPricesRow.ServicePackageUsageType, vPricesRow.ServicePackage, vMealBoardTermIncluded, vMealBoardTermIncludedServices, vContractMealBoardTerms, vReservationDate, vAccommodationTemplate, 
															   vCurNumberOfPersons, vCurNumberOfRooms, vCurNumberOfBeds, vCurNumberOfAdditionalBeds, 
															   vCurRoomRateSrvHasManualPrice, vIsManualPrice, vPriceCalcDate, vOffers, vIsForFolioSplit);
													vReservationServiceWasCharged = True;
												EndIf;
											EndIf;
											// Charge rack price difference
											vWrkNoDiscounts = vNoDiscounts;
											vWrkRoomRate = vRoomRate;
											If ValueIsFilled(vRoomRate.RackRate) Then
												vWrkRoomRate = vRoomRate.RackRate;
											Else
												vWrkRoomRate = Hotel.RoomRate;
											EndIf;
											vWrkPrice = vCurPriceInFolioCurrency;
											vRackCurrency = vCurCurrency;
											vRackPrice = pmGetServiceRatePrice(vWrkRoomRate, vCurAccountingDate, CheckInDate, vCurService, vRackCurrency, vRoomType, ?(vCurPriceTag = Undefined, Catalogs.PriceTags.EmptyRef(), vCurPriceTag), vAccommodationType, vAccommodationTemplate, vIsForFolioSplit);
											If vRackPrice <> 0 Then
												If vRackCurrency <> vCurCurrency Then
													vRackPrice = Round(cmConvertCurrencies(vRackPrice, vRackCurrency, , vCurCurrency, vCurFolioCurrencyExchangeRate, ?(ValueIsFilled(vCurAccountingDate), vCurAccountingDate, ExchangeRateDate), Hotel), 2);
												EndIf;
												// Get price from rack rate for reservation room type
												vReservationRackCurrency = vRackCurrency;
												vReservationRackPrice = pmGetServiceRatePrice(vWrkRoomRate, vCurAccountingDate, CheckInDate, vCurService, vReservationRackCurrency, vReservationRoomType, ?(vCurPriceTag = Undefined, Catalogs.PriceTags.EmptyRef(), vCurPriceTag), vReservationAccommodationType, vReservationAccommodationTemplate, vIsForFolioSplit);
												If vReservationRackPrice <> 0 Then
													If vReservationRackCurrency <> vCurCurrency Then
														vReservationRackPrice = Round(cmConvertCurrencies(vReservationRackPrice, vReservationRackCurrency, , vCurCurrency, vCurFolioCurrencyExchangeRate, ?(ValueIsFilled(vCurAccountingDate), vCurAccountingDate, ExchangeRateDate), Hotel), 2);
													EndIf;
													vWrkPrice = vRackPrice - vReservationRackPrice;
													If vWrkPrice > 0 Then
														// If discount type is from the customer then it shouldn't be applied
														If ValueIsFilled(Contract) And ValueIsFilled(Contract.DiscountType) And Contract.DiscountType = DiscountType Then
															vWrkNoDiscounts = True;
														ElsIf ValueIsFilled(Customer) And ValueIsFilled(Customer.DiscountType) And Customer.DiscountType = DiscountType Then
															vWrkNoDiscounts = True;
														ElsIf ValueIsFilled(RoomRate) And ValueIsFilled(RoomRate.DiscountType) And RoomRate.DiscountType = DiscountType Then
															vWrkNoDiscounts = True;
														EndIf;
														AddService(i, vCurFolio, vCurFolioCurrency, vCurFolioCurrencyExchangeRate, vSrvAccountingDate,
																   vCurService, vWrkPrice, vWrkPrice, vCurUnit, vCurQuantity, vCurVATRate, vCurRemarks, 
																   vCurIsRoomRevenue, vCurIsInPrice, True, True, vCurCalendarDayType, vCurTimetable, vCurPriceTag, vCurQuantityCalculationRule,
																   vCurSrvQuantity, vFirstDayWithAccommodationService, vIsCheckIn, vIsRoomChange, vIsCheckOut, 
																   vFixedDiscount, vFixedServiceDiscount, vPeriodDiscount, vPeriodDiscountType, vPeriodDiscountServiceGroup, vPeriodDiscountConfirmationText, 
																   vAccDiscounts, vMCServices, vNoAccommodationService, vWrkRoomRate, vAccommodationtype, vRoom, vRoomRoomType, vWrkNoDiscounts, 
																   vRoomRevenuePriceByRoomType, vRestOfCurPrice, vRestOfCurAmount, vChargingRuleAmountIsSet, vRestOfServiceSum, 
																   vRoomRates, True, vCRTab, vComplexCommission, vPricesRow.PacketPriceIsIncludedInRoomRate, vCurRoomRateSrv, rWarnings, vOccParams, 
																   vPricesRow.ServicePackageUsageType, vPricesRow.ServicePackage, vMealBoardTermIncluded, vMealBoardTermIncludedServices, vContractMealBoardTerms, vReservationDate, vAccommodationTemplate, 
																   vCurNumberOfPersons, vCurNumberOfRooms, vCurNumberOfBeds, vCurNumberOfAdditionalBeds, 
																   vCurRoomRateSrvHasManualPrice, vIsManualPrice, vPriceCalcDate, vOffers, vIsForFolioSplit);
													EndIf;
												EndIf;
											Else
												vWrkRoomRate = vRoomRate;
											EndIf;
											// We've found suitable charging rule so move to the other service
											Break;
										EndIf;
									EndIf;
								EndIf;
							Else
								// Check if there are customer folios
								If vThereAreCustomerChargingRules And FixReservationConditions And IsByReservation And ValueIsFilled(Reservation) And 
								   (vReservationRoomType <> vRoomType Or vReservationAccommodationType <> vAccommodationType) And (vCurAccountingDate >= BegOfDay(vReservationCheckInDate) Or vCurAccountingDate < BegOfDay(vReservationCheckOutDate)) Then
									If vCurQuantity <> 0 Then
										If ValueIsFilled(vCurFolio.Customer) And Not vCurFolio.Customer.IsIndividual Then
											If Not vReservationServiceWasCharged Then
												// Get reservation price
												vReservationSevicesRows = Reservation.Services.FindRows(New Structure("AccountingDate, Service, IsRoomRevenue, IsInPrice, IsSplit", vSrvAccountingDate, vCurService, vCurIsRoomRevenue, vCurIsInPrice, vCurIsSplit));
												If vReservationSevicesRows.Count() > 0 Then
													vReservationSevicesRow = vReservationSevicesRows.Get(0);
													If vReservationSevicesRow.FolioCurrency <> vCurFolioCurrency Then
														vReservationPriceInFolioCurrency = Round(cmConvertCurrencies(vReservationSevicesRow.Price, vReservationSevicesRow.FolioCurrency, vReservationSevicesRow.FolioCurrencyExchangeRate, vCurFolioCurrency, vCurFolioCurrencyExchangeRate, ?(ValueIsFilled(vCurAccountingDate), vCurAccountingDate, ExchangeRateDate), Hotel), 2);
													Else
														vReservationPriceInFolioCurrency = vReservationSevicesRow.Price;
													EndIf;
													AddService(i, vCurFolio, vCurFolioCurrency, vCurFolioCurrencyExchangeRate, vSrvAccountingDate,
													           vCurService, vReservationPriceInFolioCurrency, vCurRatePriceInFolioCurrency, vCurUnit, vCurQuantity, vCurVATRate, vCurRemarks, 
													           vCurIsRoomRevenue, vCurIsInPrice, vCurIsSplit, vCurRoomRevenueAmountsOnly, vCurCalendarDayType, vCurTimetable, vCurPriceTag, vCurQuantityCalculationRule,
													           vCurSrvQuantity, vFirstDayWithAccommodationService, vIsCheckIn, vIsRoomChange, vIsCheckOut, 
													           vFixedDiscount, vFixedServiceDiscount, vPeriodDiscount, vPeriodDiscountType, vPeriodDiscountServiceGroup, vPeriodDiscountConfirmationText, 
													           vAccDiscounts, vMCServices, vNoAccommodationService, vRoomRate, vAccommodationType, vRoom, vRoomRoomType, vNoDiscounts, 
															   vRoomRevenuePriceByRoomType, vRestOfCurPrice, vRestOfCurAmount, vChargingRuleAmountIsSet, vRestOfServiceSum, 
															   vRoomRates, , vCRTab, vComplexCommission, vPricesRow.PacketPriceIsIncludedInRoomRate, vCurRoomRateSrv, rWarnings, vOccParams, 
															   vPricesRow.ServicePackageUsageType, vPricesRow.ServicePackage, vMealBoardTermIncluded, vMealBoardTermIncludedServices, vContractMealBoardTerms, vReservationDate, vAccommodationTemplate, 
															   vCurNumberOfPersons, vCurNumberOfRooms, vCurNumberOfBeds, vCurNumberOfAdditionalBeds, 
															   vCurRoomRateSrvHasManualPrice, vIsManualPrice, vPriceCalcDate, vOffers, vIsForFolioSplit);
													vReservationServiceWasCharged = True;
												Else
													AddService(i, vCurFolio, vCurFolioCurrency, vCurFolioCurrencyExchangeRate, vSrvAccountingDate,
													           vCurService, vCurPriceInFolioCurrency, vCurRatePriceInFolioCurrency, vCurUnit, vCurQuantity, vCurVATRate, vCurRemarks, 
													           vCurIsRoomRevenue, vCurIsInPrice, vCurIsSplit, vCurRoomRevenueAmountsOnly, vCurCalendarDayType, vCurTimetable, vCurPriceTag, vCurQuantityCalculationRule,
													           vCurSrvQuantity, vFirstDayWithAccommodationService, vIsCheckIn, vIsRoomChange, vIsCheckOut, 
													           vFixedDiscount, vFixedServiceDiscount, vPeriodDiscount, vPeriodDiscountType, vPeriodDiscountServiceGroup, vPeriodDiscountConfirmationText, 
													           vAccDiscounts, vMCServices, vNoAccommodationService, vRoomRate, vAccommodationType, vRoom, vRoomRoomType, vNoDiscounts, 
															   vRoomRevenuePriceByRoomType, vRestOfCurPrice, vRestOfCurAmount, vChargingRuleAmountIsSet, vRestOfServiceSum, 
															   vRoomRates, , vCRTab, vComplexCommission, vPricesRow.PacketPriceIsIncludedInRoomRate, vCurRoomRateSrv, rWarnings, vOccParams, 
															   vPricesRow.ServicePackageUsageType, vPricesRow.ServicePackage, vMealBoardTermIncluded, vMealBoardTermIncludedServices, vContractMealBoardTerms, vReservationDate, vAccommodationTemplate, 
															   vCurNumberOfPersons, vCurNumberOfRooms, vCurNumberOfBeds, vCurNumberOfAdditionalBeds,
															   ,, vPriceCalcDate, vOffers, vIsForFolioSplit);
													vReservationServiceWasCharged = True;
													// We've found suitable charging rule so move to the other service
													If vChargingRuleAmountIsSet Then
														If vRestOfCurAmount > 0 Then
															Break;
														ElsIf vRestOfServiceSum <= 0 Then
															Break;
														EndIf;
													Else
														If vRestOfCurPrice = 0 Then
															Break;
														EndIf;
													EndIf;
												EndIf;
											EndIf;
										ElsIf vSplitChargesToPersonalFolioForIndividualCustomers Then 
											If Not vReservationServiceWasCharged Then
												// Get reservation price
												vReservationSevicesRows = Reservation.Services.FindRows(New Structure("AccountingDate, Service, IsRoomRevenue, IsInPrice, IsSplit", vSrvAccountingDate, vCurService, vCurIsRoomRevenue, vCurIsInPrice, vCurIsSplit));
												If vReservationSevicesRows.Count() > 0 Then
													vReservationSevicesRow = vReservationSevicesRows.Get(0);
													If vReservationSevicesRow.FolioCurrency <> vCurFolioCurrency Then
														vReservationPriceInFolioCurrency = Round(cmConvertCurrencies(vReservationSevicesRow.Price, vReservationSevicesRow.FolioCurrency, vReservationSevicesRow.FolioCurrencyExchangeRate, vCurFolioCurrency, vCurFolioCurrencyExchangeRate, ?(ValueIsFilled(vCurAccountingDate), vCurAccountingDate, ExchangeRateDate), Hotel), 2);
													Else
														vReservationPriceInFolioCurrency = vReservationSevicesRow.Price;
													EndIf;
													AddService(i, vCurFolio, vCurFolioCurrency, vCurFolioCurrencyExchangeRate, vSrvAccountingDate,
													           vCurService, vReservationPriceInFolioCurrency, vCurRatePriceInFolioCurrency, vCurUnit, vCurQuantity, vCurVATRate, vCurRemarks, 
													           vCurIsRoomRevenue, vCurIsInPrice, vCurIsSplit, vCurRoomRevenueAmountsOnly, vCurCalendarDayType, vCurTimetable, vCurPriceTag, vCurQuantityCalculationRule,
													           vCurSrvQuantity, vFirstDayWithAccommodationService, vIsCheckIn, vIsRoomChange, vIsCheckOut, 
													           vFixedDiscount, vFixedServiceDiscount, vPeriodDiscount, vPeriodDiscountType, vPeriodDiscountServiceGroup, vPeriodDiscountConfirmationText, 
													           vAccDiscounts, vMCServices, vNoAccommodationService, vRoomRate, vAccommodationType, vRoom, vRoomRoomType, vNoDiscounts, 
															   vRoomRevenuePriceByRoomType, vRestOfCurPrice, vRestOfCurAmount, vChargingRuleAmountIsSet, vRestOfServiceSum, 
															   vRoomRates, , vCRTab, vComplexCommission, vPricesRow.PacketPriceIsIncludedInRoomRate, vCurRoomRateSrv, rWarnings, vOccParams, 
															   vPricesRow.ServicePackageUsageType, vPricesRow.ServicePackage, vMealBoardTermIncluded, vMealBoardTermIncludedServices, vContractMealBoardTerms, vReservationDate, vAccommodationTemplate, 
															   vCurNumberOfPersons, vCurNumberOfRooms, vCurNumberOfBeds, vCurNumberOfAdditionalBeds, 
															   vCurRoomRateSrvHasManualPrice, vIsManualPrice, vPriceCalcDate, vOffers, vIsForFolioSplit);
													vReservationServiceWasCharged = True;
												Else
													AddService(i, vCurFolio, vCurFolioCurrency, vCurFolioCurrencyExchangeRate, vSrvAccountingDate,
													           vCurService, vCurPriceInFolioCurrency, vCurRatePriceInFolioCurrency, vCurUnit, vCurQuantity, vCurVATRate, vCurRemarks, 
													           vCurIsRoomRevenue, vCurIsInPrice, vCurIsSplit, vCurRoomRevenueAmountsOnly, vCurCalendarDayType, vCurTimetable, vCurPriceTag, vCurQuantityCalculationRule,
													           vCurSrvQuantity, vFirstDayWithAccommodationService, vIsCheckIn, vIsRoomChange, vIsCheckOut, 
													           vFixedDiscount, vFixedServiceDiscount, vPeriodDiscount, vPeriodDiscountType, vPeriodDiscountServiceGroup, vPeriodDiscountConfirmationText, 
													           vAccDiscounts, vMCServices, vNoAccommodationService, vRoomRate, vAccommodationType, vRoom, vRoomRoomType, vNoDiscounts, 
															   vRoomRevenuePriceByRoomType, vRestOfCurPrice, vRestOfCurAmount, vChargingRuleAmountIsSet, vRestOfServiceSum, 
															   vRoomRates, , vCRTab, vComplexCommission, vPricesRow.PacketPriceIsIncludedInRoomRate, vCurRoomRateSrv, rWarnings, vOccParams, 
															   vPricesRow.ServicePackageUsageType, vPricesRow.ServicePackage, vMealBoardTermIncluded, vMealBoardTermIncludedServices, vContractMealBoardTerms, vReservationDate, vAccommodationTemplate, 
															   vCurNumberOfPersons, vCurNumberOfRooms, vCurNumberOfBeds, vCurNumberOfAdditionalBeds,
															   ,, vPriceCalcDate, vOffers, vIsForFolioSplit);
													vReservationServiceWasCharged = True;
													// We've found suitable charging rule so move to the other service
													If vChargingRuleAmountIsSet Then
														If vRestOfCurAmount > 0 Then
															Break;
														ElsIf vRestOfServiceSum <= 0 Then
															Break;
														EndIf;
													Else
														If vRestOfCurPrice = 0 Then
															Break;
														EndIf;
													EndIf;
												EndIf;
											EndIf;
											// Charge difference between rack prices 
											vWrkNoDiscounts = vNoDiscounts;
											vWrkRoomRate = vRoomRate;
											If ValueIsFilled(vRoomRate.RackRate) Then
												vWrkRoomRate = vRoomRate.RackRate;
											Else
												vWrkRoomRate = Hotel.RoomRate;
											EndIf;
											vWrkPrice = vCurPriceInFolioCurrency;
											vRackCurrency = vCurCurrency;
											vRackPrice = pmGetServiceRatePrice(vWrkRoomRate, vCurAccountingDate, CheckInDate, vCurService, vRackCurrency, vRoomType, ?(vCurPriceTag = Undefined, Catalogs.PriceTags.EmptyRef(), vCurPriceTag), vAccommodationType, vAccommodationTemplate, vIsForFolioSplit);
											If vRackPrice <> 0 Then
												If vRackCurrency <> vCurCurrency Then
													vRackPrice = Round(cmConvertCurrencies(vRackPrice, vRackCurrency, , vCurCurrency, vCurFolioCurrencyExchangeRate, ?(ValueIsFilled(vCurAccountingDate), vCurAccountingDate, ExchangeRateDate), Hotel), 2);
												EndIf;
												// Get price from rack rate for reservation room type
												vReservationRackCurrency = vRackCurrency;
												vReservationRackPrice = pmGetServiceRatePrice(vWrkRoomRate, vCurAccountingDate, CheckInDate, vCurService, vReservationRackCurrency, vReservationRoomType, ?(vCurPriceTag = Undefined, Catalogs.PriceTags.EmptyRef(), vCurPriceTag), vReservationAccommodationType, vReservationAccommodationTemplate, vIsForFolioSplit);
												If vReservationRackPrice <> 0 Then
													If vReservationRackCurrency <> vCurCurrency Then
														vReservationRackPrice = Round(cmConvertCurrencies(vReservationRackPrice, vReservationRackCurrency, , vCurCurrency, vCurFolioCurrencyExchangeRate, ?(ValueIsFilled(vCurAccountingDate), vCurAccountingDate, ExchangeRateDate), Hotel), 2);
													EndIf;
													vWrkPrice = vRackPrice - vReservationRackPrice;
													If vWrkPrice > 0 Then
														// If discount type is from the customer then it shouldn't be applied
														If ValueIsFilled(Contract) And ValueIsFilled(Contract.DiscountType) And Contract.DiscountType = DiscountType Then
															vWrkNoDiscounts = True;
														ElsIf ValueIsFilled(Customer) And ValueIsFilled(Customer.DiscountType) And Customer.DiscountType = DiscountType Then
															vWrkNoDiscounts = True;
														ElsIf ValueIsFilled(RoomRate) And ValueIsFilled(RoomRate.DiscountType) And RoomRate.DiscountType = DiscountType Then
															vWrkNoDiscounts = True;
														EndIf;
														AddService(i, vCurFolio, vCurFolioCurrency, vCurFolioCurrencyExchangeRate, vSrvAccountingDate,
																   vCurService, vWrkPrice, vWrkPrice, vCurUnit, vCurQuantity, vCurVATRate, vCurRemarks, 
																   vCurIsRoomRevenue, vCurIsInPrice, True, True, vCurCalendarDayType, vCurTimetable, vCurPriceTag, vCurQuantityCalculationRule,
																   vCurSrvQuantity, vFirstDayWithAccommodationService, vIsCheckIn, vIsRoomChange, vIsCheckOut, 
																   vFixedDiscount, vFixedServiceDiscount, vPeriodDiscount, vPeriodDiscountType, vPeriodDiscountServiceGroup, vPeriodDiscountConfirmationText, 
																   vAccDiscounts, vMCServices, vNoAccommodationService, vWrkRoomRate, vAccommodationtype, vRoom, vRoomRoomType, vWrkNoDiscounts, 
																   vRoomRevenuePriceByRoomType, vRestOfCurPrice, vRestOfCurAmount, vChargingRuleAmountIsSet, vRestOfServiceSum, 
																   vRoomRates, True, vCRTab, vComplexCommission, vPricesRow.PacketPriceIsIncludedInRoomRate, vCurRoomRateSrv, rWarnings, vOccParams, 
																   vPricesRow.ServicePackageUsageType, vPricesRow.ServicePackage, vMealBoardTermIncluded, vMealBoardTermIncludedServices, vContractMealBoardTerms, vReservationDate, vAccommodationTemplate, 
																   vCurNumberOfPersons, vCurNumberOfRooms, vCurNumberOfBeds, vCurNumberOfAdditionalBeds, 
																   vCurRoomRateSrvHasManualPrice, vIsManualPrice, vPriceCalcDate, vOffers, vIsForFolioSplit);
													EndIf;
												EndIf;
											Else
												vWrkRoomRate = vRoomRate;
											EndIf;
											// We've found suitable charging rule so move to the other service
											Break;
										Else
											// Add service to the services tabular part if quantity is not zero
											If vCurQuantity <> 0 Then
												AddService(i, vCurFolio, vCurFolioCurrency, vCurFolioCurrencyExchangeRate, vSrvAccountingDate,
												           vCurService, vCurPriceInFolioCurrency, vCurRatePriceInFolioCurrency, vCurUnit, vCurQuantity, vCurVATRate, vCurRemarks, 
												           vCurIsRoomRevenue, vCurIsInPrice, vCurIsSplit, vCurRoomRevenueAmountsOnly, vCurCalendarDayType, vCurTimetable, vCurPriceTag, vCurQuantityCalculationRule,
												           vCurSrvQuantity, vFirstDayWithAccommodationService, vIsCheckIn, vIsRoomChange, vIsCheckOut, 
												           vFixedDiscount, vFixedServiceDiscount, vPeriodDiscount, vPeriodDiscountType, vPeriodDiscountServiceGroup, vPeriodDiscountConfirmationText, 
												           vAccDiscounts, vMCServices, vNoAccommodationService, vRoomRate, vAccommodationType, vRoom, vRoomRoomType, vNoDiscounts, 
														   vRoomRevenuePriceByRoomType, vRestOfCurPrice, vRestOfCurAmount, vChargingRuleAmountIsSet, vRestOfServiceSum, 
														   vRoomRates, , vCRTab, vComplexCommission, vPricesRow.PacketPriceIsIncludedInRoomRate, vCurRoomRateSrv, rWarnings, vOccParams, 
														   vPricesRow.ServicePackageUsageType, vPricesRow.ServicePackage, vMealBoardTermIncluded, vMealBoardTermIncludedServices, vContractMealBoardTerms, vReservationDate, vAccommodationTemplate, 
														   vCurNumberOfPersons, vCurNumberOfRooms, vCurNumberOfBeds, vCurNumberOfAdditionalBeds, 
														   vCurRoomRateSrvHasManualPrice, vIsManualPrice, vPriceCalcDate, vOffers, vIsForFolioSplit);
												// We've found suitable charging rule so move to the other service
												If vChargingRuleAmountIsSet Then
													If vRestOfCurAmount > 0 Then
														Break;
													ElsIf vRestOfServiceSum <= 0 Then
														Break;
													EndIf;
												Else
													If vRestOfCurPrice = 0 Then
														Break;
													EndIf;
												EndIf;
											EndIf;
										EndIf;
									EndIf;
								Else
									// Add service to the services tabular part if quantity is not zero
									If vCurQuantity <> 0 Then
										AddService(i, vCurFolio, vCurFolioCurrency, vCurFolioCurrencyExchangeRate, vSrvAccountingDate,
										           vCurService, vCurPriceInFolioCurrency, vCurRatePriceInFolioCurrency, vCurUnit, vCurQuantity, vCurVATRate, vCurRemarks, 
										           vCurIsRoomRevenue, vCurIsInPrice, vCurIsSplit, vCurRoomRevenueAmountsOnly, vCurCalendarDayType, vCurTimetable, vCurPriceTag, vCurQuantityCalculationRule,
										           vCurSrvQuantity, vFirstDayWithAccommodationService, vIsCheckIn, vIsRoomChange, vIsCheckOut, 
										           vFixedDiscount, vFixedServiceDiscount, vPeriodDiscount, vPeriodDiscountType, vPeriodDiscountServiceGroup, vPeriodDiscountConfirmationText, 
										           vAccDiscounts, vMCServices, vNoAccommodationService, vRoomRate, vAccommodationType, vRoom, vRoomRoomType, vNoDiscounts, 
												   vRoomRevenuePriceByRoomType, vRestOfCurPrice, vRestOfCurAmount, vChargingRuleAmountIsSet, vRestOfServiceSum, 
												   vRoomRates, , vCRTab, vComplexCommission, vPricesRow.PacketPriceIsIncludedInRoomRate, vCurRoomRateSrv, rWarnings, vOccParams, 
												   vPricesRow.ServicePackageUsageType, vPricesRow.ServicePackage, vMealBoardTermIncluded, vMealBoardTermIncludedServices, vContractMealBoardTerms, vReservationDate, vAccommodationTemplate, 
												   vCurNumberOfPersons, vCurNumberOfRooms, vCurNumberOfBeds, vCurNumberOfAdditionalBeds, 
												   vCurRoomRateSrvHasManualPrice, vIsManualPrice, vPriceCalcDate, vOffers, vIsForFolioSplit);
										// We've found suitable charging rule so move to the other service
										If vChargingRuleAmountIsSet Then
											If vRestOfCurAmount > 0 Then
												Break;
											ElsIf vRestOfServiceSum <= 0 Then
												Break;
											EndIf;
										Else
											If vRestOfCurPrice = 0 Then
												Break;
											EndIf;
										EndIf;
									EndIf;
								EndIf;
							EndIf;
						EndIf;
					EndDo;
				EndIf;
			EndIf;
		EndDo;
	EndDo;
	// Check amount discount
	If vIsAmountDiscount And DiscountSum <> 0 Then
		vDiscountSum = DiscountSum;
		vNumServices = Services.Count();
		If vNumServices > 0 Then
			// Do first run
			vNumDiscountServices = 0;
			vFirstRunDiscountSum = Int(vDiscountSum/vNumServices);
			For Each vSrvRow In Services Do
				If vSrvRow.Sum <> 0 And vSrvRow.Sum >= vFirstRunDiscountSum And 
				   cmIsServiceInServiceGroup(vSrvRow.Service, DiscountServiceGroup) Then
					vSrvRow.DiscountSum = vFirstRunDiscountSum;
					vSrvRow.VATDiscountSum = cmCalculateVATSum(vSrvRow.VATRate, vSrvRow.DiscountSum, vSrvRow.AccountingDate);
					vDiscountSum = vDiscountSum - vFirstRunDiscountSum;
					vNumDiscountServices = vNumDiscountServices + 1;
				EndIf;
			EndDo;
			// Do second run
			If vDiscountSum <> 0 And vNumDiscountServices > 0 Then
				vSecondRunDiscountSum = Round(vDiscountSum/vNumDiscountServices, 2);
				For Each vSrvRow In Services Do
					If vSrvRow.Sum <> 0 And vSrvRow.Sum >= vSecondRunDiscountSum And 
					   cmIsServiceInServiceGroup(vSrvRow.Service, DiscountServiceGroup) Then
						If vDiscountSum > 0 Then
							If vDiscountSum > vSecondRunDiscountSum Then
								vSrvRow.DiscountSum = vSrvRow.DiscountSum + vSecondRunDiscountSum;
								vDiscountSum = vDiscountSum - vSecondRunDiscountSum;
							Else
								vSrvRow.DiscountSum = vSrvRow.DiscountSum + vDiscountSum;
								vDiscountSum = 0;
							EndIf;
						Else
							If vDiscountSum < vSecondRunDiscountSum Then
								vSrvRow.DiscountSum = vSrvRow.DiscountSum + vSecondRunDiscountSum;
								vDiscountSum = vDiscountSum - vSecondRunDiscountSum;
							Else
								vSrvRow.DiscountSum = vSrvRow.DiscountSum + vDiscountSum;
								vDiscountSum = 0;
							EndIf;
						EndIf;
						vSrvRow.VATDiscountSum = cmCalculateVATSum(vSrvRow.VATRate, vSrvRow.DiscountSum, vSrvRow.AccountingDate);
					EndIf;
				EndDo;
			EndIf;
			// Do third run
			If vDiscountSum <> 0 And vNumDiscountServices > 0 Then
				For Each vSrvRow In Services Do
					If vSrvRow.Sum <> 0 And vSrvRow.Sum >= vDiscountSum And 
					   cmIsServiceInServiceGroup(vSrvRow.Service, DiscountServiceGroup) Then
						vSrvRow.DiscountSum = vSrvRow.DiscountSum + vDiscountSum;
						vSrvRow.VATDiscountSum = cmCalculateVATSum(vSrvRow.VATRate, vSrvRow.DiscountSum, vSrvRow.AccountingDate);
						vDiscountSum = 0;
						Break;
					EndIf;
				EndDo;
			EndIf;
		EndIf;
	EndIf;
	// Calculate price presentation
	vPricePresentation = pmCalculatePricePresentation();
	If TrimAll(vPricePresentation) <> TrimAll(PricePresentation) Then
		PricePresentation = TrimAll(vPricePresentation);
	EndIf;
	// Check should we call this function recursively to recalculate discounts
	If vPeriodDiscount <> pPeriodDiscount Then
		Return pmCalculateServices(rWarnings, vPeriodDiscount, vPeriodDiscountType, 
		                                      vPeriodDiscountServiceGroup, vPeriodDiscountConfirmationText);
	ElsIf IsBlankString(rWarnings) Then
		// Process warnings
		vWarningsEn = "";
		vWarningsDe = "";
		vWarningsRu = "";
		#Удаление	
		If vNoAccommodationService And NumberOfBeds > 0 Then
			If ValueIsFilled(RoomRate) And 
			   ValueIsFilled(vRoomType) And 
			   ValueIsFilled(AccommodationType) And 
			   Not ValueIsFilled(RoomQuota) And 
			   Not vRoomType.IsVirtual And
			   (RoomRate.RateChargeDirection <> Enums.RateChargeDirections.MergeToTheMainRoomGuest Or 
			    RoomRate.RateChargeDirection = Enums.RateChargeDirections.MergeToTheMainRoomGuest And ValueIsFilled(AccommodationTemplate)) Then
				vWarnings = True;
				vWarningsEn = "Room rate price is not defined for room rate " + RoomRate + ", accommodation period " + Format(CheckInDate, "DF='dd.MM.yyyy HH:mm'") + " - " + Format(CheckOutDate, "DF='dd.MM.yyyy HH:mm'") + ", room type " + vRoomType + " and accommodation type " + AccommodationType + "!";
				vWarningsDe = "Zimmerpreis ist nicht definiert fur Tariff " + RoomRate + ", den Zeitraum des Aufenthalts von " + Format(CheckInDate, "DF='dd.MM.yyyy HH:mm'") + " bis " + Format(CheckOutDate, "DF='dd.MM.yyyy HH:mm'") + ", Zimmertyp " + vRoomType + " und Typ der Unterbringungen " + AccommodationType + "!";
				vWarningsRu = "Для периода проживания " + Format(CheckInDate, "DF='dd.MM.yyyy HH:mm'") + " - " + Format(CheckOutDate, "DF='dd.MM.yyyy HH:mm'") + " в тарифе " + RoomRate + " для типа номера " + vRoomType + " и вида размещения " + AccommodationType + " не определена цена проживания!";
			EndIf;
		EndIf;
		#КонецУдаления
		If vWarnings Then
			rWarnings = "ru = '" + vWarningsRu + "'; de = '" + vWarningsDe + "'; en = '" + vWarningsEn + "'";
		EndIf;
	Else
		vWarnings = True;
	EndIf;
	If vWarnings And Not IsBlankString(rWarnings) Then
		WriteLogEvent(NStr("en='Accommodation.CalculateServices';ru='Размещение.РасчетУслуг';de='Accommodation.CalculateServices'"), EventLogLevel.Warning, ThisObject.Metadata(), Ref, cmNStr(rWarnings));
	EndIf;
	// Remove services without quantity and price
	i = 0;
	While i < Services.Count() Do
		vSrvRow = Services.Get(i);
		If Not vSrvRow.IsManual And Not vSrvRow.IsManualPrice And Not vSrvRow.QuantityIsChanged And 
		   vSrvRow.Quantity = 0 And vSrvRow.Sum = 0 Then
			Services.Delete(i);
		Else
			i = i + 1;
		EndIf;
	EndDo;
	Return vWarnings;
EndFunction //pmCalculateServices


