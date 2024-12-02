
&ChangeAndValidate("FillRoomAttributes")
Procedure Расш1_FillRoomAttributes(pRoomObj)
	pRoomObj.Owner = Hotel;
	pRoomObj.Description = RoomNumber;
	pRoomObj.Parent = RoomGroup;
	pRoomObj.RoomType = RoomType;
	pRoomObj.NumberOfBedsPerRoom = NumberOfBedsPerRoom;
	pRoomObj.NumberOfPersonsPerRoom = NumberOfPersonsPerRoom;
	pRoomObj.OperationEndDate = OperationEndDate;
	pRoomObj.SortCode = SortCode;
	#Вставка
	pRoomObj.НомерКвартиры = НомерКвартиры;
	#КонецВставки
	If Not IsBlankString(Remarks) Then
		pRoomObj.Remarks = Remarks;
	EndIf;
	pRoomObj.IsVirtual = IsVirtual;
EndProcedure
