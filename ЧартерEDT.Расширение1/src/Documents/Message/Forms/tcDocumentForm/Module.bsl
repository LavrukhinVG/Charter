
&AtServer
&ChangeAndValidate("OnCreateAtServer")
Procedure Расш1_OnCreateAtServer(Cancel, StandardProcessing)	
	If Parameters.Property("AvtoTest") Then
		If Parameters.AvtoTest Then
			Return;
		EndIf;	
	EndIf;

	// Check protection system
	tcProtection.cmCheckForm(ThisForm);

	// Let's set the properties of the form
	tcOnServer.cmSetFormProperties(ThisForm);

	vObject = FormAttributeToValue("Object");
	vTempArray = New Array();

	pNewForm = Parameters.Key.IsEmpty();
	If pNewForm Then
		vObject.pmFillAttributesWithDefaultValues();
		Items.GroupMessage.Title = "" + vObject.Author;
		#Вставка
	    vObject.Type = Перечисления.MessageTypes.Task;
		Items.Type.ТолькоПросмотр = Истина;
		vObject.MessageStatus = Справочники.MessageStatuses.НайтиПоНаименованию("Новая");
		#КонецВставки

	Else
		Items.GroupMessage.Title = Format(vObject.Date, "DF='dd.MM.yyyy HH:mm'") + " - " + vObject.Author + " - " + TrimAll(vObject.Number);
	EndIf;

	If Parameters.Property("Type") Then
		If TypeOf(Parameters.Type) = Type("EnumRef.MessageTypes") Then
			vObject.Type = Parameters.Type;
		EndIf;
	EndIf;
	If Parameters.Property("SetParamObject") Then
		If not ValueIsFilled(vObject.ByObject) Then
			vObject.ByObject = Parameters.SetParamObject;
		EndIf;		
		If TypeOf(vObject.ByObject) = Type("CatalogRef.Rooms") Then
			ThisForm.SelRoom = vObject.ByObject;
		EndIf;
	EndIf;
	If Parameters.Property("SetEmployee") Then
		vObject.ForEmployee = Parameters.SetEmployee;
	EndIf;
	If Parameters.Property("SetOrder") Then
		vObject.ByOrder = Parameters.SetOrder;
	EndIf;
	If Parameters.Property("SetDepartment") Then
		vObject.ForDepartment = Parameters.SetDepartment;
	EndIf;
	If Parameters.Property("SetRemarks") Then
		vObject.Remarks = Parameters.SetRemarks;
	EndIf;
	If Parameters.Property("SetType") Then
		vObject.MessageType = Parameters.SetType;
	EndIf;

	// Check if there are any message types defined
	vMessageTypes = cmGetAllMessageTypes();
	If vMessageTypes.Count() = 0 Then
		Items.MessageType.Visible = False;
	Else
		Items.MessageType.Visible = True;
	EndIf;

	// Check if there are any message statuses defined
	vMessageStatuses = cmGetAllMessageStatuses();
	If vMessageStatuses.Count() = 0 Then
		Items.MessageStatus.Visible = False;
		Items.IsClosed.Visible = True;
	Else
		Items.IsClosed.Visible = False;
		Items.MessageStatus.Visible = True;
	EndIf;

	// Comments
	cNewPolAtServer();

	If vObject.IsClosed And Not(pNewForm) Then
		pEnabled = False;
		EnableAllItems(pEnabled, pNewForm);
	Else
		pEnabled = True;
		EnableAllItems(pEnabled, pNewForm);
	EndIf;

	If ValueIsFilled(SelRoom) And SelRoom = vObject.ByObject Then
		Items.ByObject.Visible = False;
	ElsIf ValueIsFilled(vObject.ByObject) And TypeOf(vObject.ByObject) <> Type("CatalogRef.Rooms") Then
		Items.SelRoom.Visible = False;
	EndIf;

	Items.GroupWhenClosed.Visible = vObject.IsClosed;

	GetPictureServer();

	ValueToFormAttribute(vObject, "Object");

	SetFormAppearanceAtServer();
EndProcedure
