
&ChangeAndValidate("ChangeRoom")
Procedure Расш1_ChangeRoom(pCancel)
	// Room atributes should be changed only if current document is the last one
	vRoomObj = Room.GetObject();
	vRoomAttr = vRoomObj.pmGetRoomAttributes('39991231235959');
	For Each vRoomAttrRow In vRoomAttr Do
		If ValueIsFilled(vRoomAttrRow.DocRecorder) Then
			If vRoomAttrRow.DocRecorder.Date > Date Then
				Return;
			ElsIf vRoomAttrRow.DocRecorder.Date = Date And vRoomAttrRow.DocRecorder <> Ref Then
				Raise NStr("en='There is already one <Add room> or <Change room> document for the date choosen! You can not create more then one <Add/Change room> documents for the same moment. Please change date of the current document.';
				|ru='Для указанного номера уже существуют документы <Ввод номера в НФ> или <Изменить номер> с такой же датой документа! У одного номера в один момент времени может быть только один документ ввода в НФ/изменения реквизитов номера. Пожалуйста измените дату текущего документа.';
				|de='Für das angegebene Zimmer wurde bereits das Dokument <Eingabe des Zimmers im Zimmerbestand> oder <Zimmer ändern> erstellt! Für ein Zimmer für einen Zeitpunkt muss es nur ein Dokument über die Eingabe in den Zimmerbestand/Änderung von Zimmerrequisiten geben. Bitte ändern Sie das Datum des aktuellen Dokuments.'");
			EndIf;
		EndIf;
	EndDo;

	// Change current room attributes
	vRoomObj.Owner = Hotel;
	vRoomObj.Description = RoomNumber;
	vRoomObj.Parent = RoomGroup;
	vRoomObj.RoomType = RoomType;
	vRoomObj.NumberOfBedsPerRoom = NumberOfBedsPerRoom;
	vRoomObj.NumberOfPersonsPerRoom = NumberOfPersonsPerRoom;
	vRoomObj.OperationEndDate = OperationEndDate;
	vRoomObj.SortCode = SortCode;
	#Вставка
	vRoomObj.НомерКвартиры = НомерКвартиры;
	#КонецВставки
	If Not IsBlankString(Remarks) Then
		vRoomObj.Remarks = Remarks;
	EndIf;
	vRoomObj.isVirtual = IsVirtual;

	vRoomObj.Write();

	// Remove records from the room change history
	UndoPosting(pCancel);

	// Add record to the room change history
	pmWriteToRoomChangeHistory();
EndProcedure

&ChangeAndValidate("pmFillAttributesWithDefaultValues")
Procedure Расш1_pmFillAttributesWithDefaultValues()
	// Fill author and document date
	pmFillAuthorAndDate();
	// Fill room attributes
	If ValueIsFilled(Room) Then
		vRoomObj = Room.GetObject();
		vRoomAttr = vRoomObj.pmGetRoomAttributes(Date);
		For Each vRoomAttrRow In vRoomAttr Do
			Hotel = vRoomAttrRow.Hotel;
			RoomGroup = vRoomAttrRow.RoomGroup;
			RoomNumber = vRoomAttrRow.RoomNumber;
			RoomType = vRoomAttrRow.RoomType;
			NumberOfBedsPerRoom = vRoomAttrRow.NumberOfBedsPerRoom;
			NumberOfPersonsPerRoom = vRoomAttrRow.NumberOfPersonsPerRoom;
			OperationEndDate = vRoomAttrRow.OperationEndDate;
			SortCode = Room.SortCode;
			Remarks = Room.Remarks;
			#Вставка
			НомерКвартиры = Room.НомерКвартиры;
			#КонецВставки
			IsVirtual = vRoomAttrRow.IsVirtual;
		EndDo;
	EndIf;
	If Not ValueIsFilled(Hotel) Then
		Hotel = SessionParameters.CurrentHotel;
	EndIf;EndProcedure
