
&AtServer
&ChangeAndValidate("OnCreateAtServer")
Procedure Расш1_OnCreateAtServer(pCancel, pStandardProcessing)
	If Parameters.Property("AvtoTest") Then
		If Parameters.AvtoTest Then
			Return;
		EndIf;	
	EndIf;
	vFormDataStructure = Undefined;
	If ThisForm.Parameters.Property("FormData", vFormDataStructure) Then
		If vFormDataStructure <> Undefined Then
			Object.LastName = vFormDataStructure.LastName;
			Object.SecondName = vFormDataStructure.SecondName;
			Object.FirstName = vFormDataStructure.FirstName;
			Object.IdentityDocumentSeries = vFormDataStructure.IdentityDocumentSeries;
			Object.IdentityDocumentNumber = vFormDataStructure.IdentityDocumentNumber;
			Object.EMail = vFormDataStructure.EMail;
			Object.Phone = vFormDataStructure.Phone;
		EndIf;
	EndIf;   
	#Удаление
	// Check protection system
	tcProtection.cmCheckForm(ThisForm);
	// Let's set the properties of the form
	#КонецУдаления
	tcOnServer.cmSetFormProperties(ThisForm);
	#Удаление
	ClientTypeColorAtServer();
	#КонецУдаления
	// Fill fan id data
	WasNew = False;
	If ValueIsFilled(Object.Ref) Then
		FillFanIDData();
		#Вставка
		ЗаполнитьСостояниеСотрудника();		
		#КонецВставки
	Else
		WasNew = True;
		Items.FanID.Enabled = False;
		Items.FanIDNumber.Enabled = False;
	EndIf;
	// Relationship
	FillRelationshipsListAtServer();
	// Do actions for the new client
	If Not ValueIsFilled(Object.Ref) Then
		// Filter discount cards
		Items.CreditCardsGroup.Visible = False;
		Items.DiscountCardsGroup.Visible = False;
		
		// Fill attributes from the template client
		If Parameters.Property("TemplateGuest") Then
			vTemplateGuest = Parameters.TemplateGuest;
			If ValueIsFilled(vTemplateGuest) And Not IsBlankString(vTemplateGuest.Address) Then
				vPermissionGroup = cmGetEmployeePermissionGroup(SessionParameters.CurrentUser);
				If ValueIsFilled(vPermissionGroup) And Not vPermissionGroup.DoNotCopyGroupClientsAddresses Then
					Object.Address = vTemplateGuest.Address;
				EndIf;
			EndIf;
		EndIf;
	Else
		If ValueIsFilled(SessionParameters.CurrentUser.Customer) Then
			Items.CreditCardsGroup.Visible = False;
		Else
			Items.CreditCardsGroup.Visible = True;
		EndIf;
		Items.DiscountCardsGroup.Visible = True;
		If Not cmCheckUserPermissions("HavePermissionToManagePrices") Then
			Items.TableBoxDiscountCards.ChangeRowSet = False;
		EndIf;
		// Apply filter by current client
		vNewFilter 					= TableBoxDiscountCards.SettingsComposer.Settings.Filter.Items.Add(Type("DataCompositionFilterItem"));
		vNewFilter.LeftValue		= New DataCompositionField("Client");
		vNewFilter.ComparisonType	= DataCompositionComparisonType.Equal;
		vNewFilter.RightValue		= Object.Ref;
		vNewFilter.Use				= True;
		vNewFilter.ViewMode 		= DataCompositionSettingsItemViewMode.Inaccessible;
	EndIf; 
	#Вставка
	ОбновитьОтсутствие();	
	#КонецВставки
	// Customer
	DisableFieldsByCustomer();
	//Fill tags
	FillClientTags();
	// Fill document tasks presentation
	FillTasksPresentation();
EndProcedure

&AtServer
Процедура ЗаполнитьСостояниеСотрудника();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	СостоянияСотрудников.Состояние КАК Состояние,
		|	СостоянияСотрудников.ДействуетДо КАК ДействуетДо
		|ИЗ
		|	РегистрСведений.СостоянияСотрудников КАК СостоянияСотрудников
		|ГДЕ
		|	СостоянияСотрудников.Сотрудник = &Сотрудник";
	
	Запрос.УстановитьПараметр("Сотрудник", Object.Ref);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Если ВыборкаДетальныеЗаписи.Следующий() Тогда
		ТекущееСостояниеСотрудника  =ВыборкаДетальныеЗаписи.Состояние;
		ДействуетДо = ВыборкаДетальныеЗаписи.ДействуетДо;
	КонецЕсли;
	
КонецПроцедуры

&AtServer
&ChangeAndValidate("BeforeWriteAtServer")
Procedure Расш1_BeforeWriteAtServer(pCancel, pCurrentObject, pWriteParameters)
	// Check client data
	SetObjectAndFormAttributeConformity(pCurrentObject, "Object");
	If Not cmCheckUserPermissions("HavePermissionToDoCheckInWithEmptyGuest") Then
		If Not ValueIsFilled(pCurrentObject.Sex) Then
			vUM = New UserMessage();
			vUM.SetData(pCurrentObject);
			vUM.Field = "Sex";
			vUM.Text = NStr("en='Please fill client sex!';ru='Пожалуйста, укажите пол клиента!';de='Bitte geben Sie das Geschlecht des Kunden an!'");
			vUM.Message();
			pCancel = True;
		EndIf;
		If Not ValueIsFilled(pCurrentObject.Citizenship) Then
			vUM = New UserMessage();
			vUM.SetData(pCurrentObject);
			vUM.Field = "Citizenship";
			vUM.Text = NStr("en='Please fill client citizenship!';ru='Пожалуйста, укажите страну гражданства клиента!';de='Bitte geben Sie das Land des Kunden an!'");
			vUM.Message();
			pCancel = True;
		EndIf;
		If Not cmCheckUserPermissions("HavePermissionToSkipInputOfGuestIdentificationDocumentData") Then
			If IsBlankString(pCurrentObject.IdentityDocumentNumber) Then
				vUM = New UserMessage();
				vUM.SetData(pCurrentObject);
				vUM.Field = "IdentityDocumentNumber";
				vUM.Text = NStr("en='Please fill client identity document data!';ru='Пожалуйста, укажите данные документа удостоверяющего личность клиента!';de='Bitte geben Sie die Personalausweisdaten des Kunden an!'");
				vUM.Message();
				pCancel = True;
			EndIf;
		EndIf;
		If Not cmCheckUserPermissions("HavePermissionToSkipInputOfGuestAddress") Then
			If ValueIsFilled(SessionParameters.CurrentHotel) Then
				If pCurrentObject.Citizenship = SessionParameters.CurrentHotel.Citizenship Then
					If IsBlankString(pCurrentObject.Address) Then
						vUM = New UserMessage();
						vUM.SetData(pCurrentObject);
						vUM.Field = "Address";
						vUM.Text = NStr("en='Please fill client address!';ru='Пожалуйста, укажите адрес прописки клиента!';de='Bitte geben Sie die Meldeanschrift des Kunden an!'");
						vUM.Message();
						pCancel = True;
					EndIf;
				EndIf;
			EndIf;
		EndIf;
		If ValueIsFilled(pCurrentObject.Citizenship) And pCurrentObject.Citizenship.Code = 643 Then
			If Not IsBlankString(pCurrentObject.SocialSecurityNumber) And Not cmCheckRussianSocialSecurityNumber(TrimR(pCurrentObject.SocialSecurityNumber)) Then
				vUM = New UserMessage();
				vUM.SetData(pCurrentObject);
				vUM.Field = "SocialSecurityNumber";
				vUM.Text = NStr("en='Social security number id wrong!';ru='СНИЛС клиента указан с ошибкой!';de='Sozialversicherungsnummer ist falsch!'");
				vUM.Message();
				pCancel = True;
			EndIf;
		EndIf;
		#Вставка
		//Если Не ЗначениеЗаполнено(pCurrentObject.ТабельныйНомер) И (pCurrentObject.КатегорияПроживающего = Перечисления.Расш1_КатегорииПроживающих.АУП Или
		//	pCurrentObject.КатегорияПроживающего = Перечисления.Расш1_КатегорииПроживающих.ИТР или
		//	pCurrentObject.КатегорияПроживающего = Перечисления.Расш1_КатегорииПроживающих.ОПР или 
		//	pCurrentObject.КатегорияПроживающего = Перечисления.Расш1_КатегорииПроживающих.Руководство)  Тогда
		//	
		//	vUM = New UserMessage();
		//	vUM.SetData(pCurrentObject);
		//	vUM.Field = "ТабельныйНомер";
		//	vUM.Text = NStr("en='Табельный номер должен быть указан для не прикомандированных сотрудников!';ru='Табельный номер должен быть указан для не прикомандированных сотрудников!';de='Табельный номер должен быть указан для не прикомандированных сотрудников!'");
		//	vUM.Message();
		//	pCancel = True;				
		//КонецЕсли;	
		#КонецВставки
	EndIf;
	// Check Russian passport data
	If ValueIsFilled(pCurrentObject.IdentityDocumentType) And TrimAll(pCurrentObject.IdentityDocumentType.Code) = "21" Then
		If Not IsBlankString(pCurrentObject.IdentityDocumentSeries) Then
			vIdentityDocumentSeries = StrReplace(TrimAll(pCurrentObject.IdentityDocumentSeries), " ", "");
			If StrLen(vIdentityDocumentSeries) <> 4 Then
				vUM = New UserMessage();
				vUM.SetData(pCurrentObject);
				vUM.Field = "IdentityDocumentSeries";
				vUM.Text = NStr("en='Client identity document series amount of digits should be equal to 4!';ru='Количество цифр в серии паспорта должно быть равно 4!';de='Anzahl von Zahlen in der Passserie muss gleich 4 sein!'");
				vUM.Message();
				pCancel = True;
			EndIf;
			If Not cmIsNumber(vIdentityDocumentSeries) Then
				vUM = New UserMessage();
				vUM.SetData(pCurrentObject);
				vUM.Field = "IdentityDocumentSeries";
				vUM.Text = NStr("en='Digits are allowed for client identity document series only!';ru='В серии паспорта разрешены только цифры!';de='In der Passseriennummer sind nur Zahlen erlaubt!'");
				vUM.Message();
				pCancel = True;
			EndIf;
		EndIf;
		If Not IsBlankString(pCurrentObject.IdentityDocumentNumber) Then
			vIdentityDocumentNumber = TrimAll(pCurrentObject.IdentityDocumentNumber);
			If StrLen(vIdentityDocumentNumber) <> 6 Then
				vUM = New UserMessage();
				vUM.SetData(pCurrentObject);
				vUM.Field = "IdentityDocumentNumber";
				vUM.Text = NStr("en='Client identity document number amount of digits should be equal to 6!';ru='Количество цифр в номере паспорта должно быть равно 6!';de='Anzahl von Zahlen in der Passnummer muss gleich 6 sein!'");
				vUM.Message();
				pCancel = True;
			EndIf;
			If Not cmIsNumber(vIdentityDocumentNumber) Then
				vUM = New UserMessage();
				vUM.SetData(pCurrentObject);
				vUM.Field = "IdentityDocumentNumber";
				vUM.Text = NStr("en='Digits are allowed for client identity document number only!';ru='В номере паспорта разрешены только цифры!';de='In der Passnummer sind nur Zahlen erlaubt!'");
				vUM.Message();
				pCancel = True;
			EndIf;
		EndIf;
		If IsBlankString(pCurrentObject.IdentityDocumentSeries) And Not IsBlankString(pCurrentObject.IdentityDocumentNumber) Then
			vUM = New UserMessage();
			vUM.SetData(pCurrentObject);
			vUM.Field = "IdentityDocumentSeries";
			vUM.Text = NStr("en='Client identity document series is missing!';ru='Номер паспорта указан без серии!';de='Die Passnummer ist ohne Seriennummer angegeben!'");
			vUM.Message();
			pCancel = True;
		EndIf;
		If IsBlankString(pCurrentObject.IdentityDocumentNumber) And Not IsBlankString(pCurrentObject.IdentityDocumentSeries) Then
			vUM = New UserMessage();
			vUM.SetData(pCurrentObject);
			vUM.Field = "IdentityDocumentNumber";
			vUM.Text = NStr("en='Client identity document number is missing!';ru='Серия паспорта указана без номера!';de='Die Serie des Ausweises ist ohne Nummer angegeben!'");
			vUM.Message();
			pCancel = True;
		EndIf;
		If Not IsBlankString(pCurrentObject.IdentityDocumentNumber) And IsBlankString(pCurrentObject.IdentityDocumentUnitCode) Then
			vUM = New UserMessage();
			vUM.SetData(pCurrentObject);
			vUM.Field = "IdentityDocumentUnitCode";
			vUM.Text = NStr("en='Client identity document unit code is missing!';ru='Не указан код подразделения кем выдан паспорт!';de='Des Ausweises ist ohne Unterteilung Code angegeben!'");
			vUM.Message();
			pCancel = True;
		EndIf;
		If Not IsBlankString(pCurrentObject.IdentityDocumentNumber) And IsBlankString(pCurrentObject.IdentityDocumentIssuedBy) Then
			vUM = New UserMessage();
			vUM.SetData(pCurrentObject);
			vUM.Field = "IdentityDocumentIssuedBy";
			vUM.Text = NStr("en='Client identity document issued by is missing!';ru='Не указано кем выдан паспорт!';de='Des Ausweises ist ohne Ausgestellt durch angegeben!'");
			vUM.Message();
			pCancel = True;
		EndIf;
	EndIf;
	If ValueIsFilled(pCurrentObject.IdentityDocumentIssueDate) And ValueIsFilled(pCurrentObject.IdentityDocumentValidToDate) And BegOfDay(pCurrentObject.IdentityDocumentValidToDate) < BegOfDay(pCurrentObject.IdentityDocumentIssueDate) Then
		vUM = New UserMessage();
		vUM.SetData(pCurrentObject);
		vUM.Field = "IdentityDocumentValidToDate";
		vUM.Text = NStr("en='Client identity document valid to date is less the document issue date!';ru='Дата окончания периода действия документа удостоверяющего личность указана ранее даты его выдачи!';de='Enddatum des Personalausweises angegeben früher als das Datum der Ausstellung!'");
		vUM.Message();
		pCancel = True;
	EndIf;
	// Check client identity document in the list of forbidden identity documents
	vIDRemarks = "";
	If cmIsClientIdentityDocumentInForbiddenList(pCurrentObject.IdentityDocumentType, pCurrentObject.IdentityDocumentSeries, pCurrentObject.IdentityDocumentNumber, vIDRemarks) Then
		vMessage = pCurrentObject.pmGetFullName() + Chars.LF + NStr("en='Client identity document data found in the forbidden list!';ru='ДУЛ клиента найден в запрещенном списке!';de='PA des Kunden wurde in der Sperrliste gefunden!'") + Chars.LF + vIDRemarks;
		vUM = New UserMessage();
		vUM.SetData(pCurrentObject);
		vUM.Field = "IdentityDocumentNumber";
		vUM.Text = vMessage;
		vUM.Message();
		pCancel = False;
		WriteLogEvent(NStr("en='Client.IdentityDocumentIsForbidden';ru='Клиент.ДУЛВЗапрещенномСписке';de='Client.IdentityDocumentIsForbidden'"), EventLogLevel.Warning, , pCurrentObject.Ref, vMessage); 
	EndIf;
EndProcedure

&НаКлиенте
Процедура Расш1_КатегорияРаботникаНачалоВыбораВместо(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Если ПроверитьДоступностьВсегоНомерногоФонда() Тогда
		Возврат;
	КонецЕсли;
	
	СтандартнаяОбработка = Ложь;
	
	Элементы.КатегорияРаботника.РежимВыбораИзСписка = истина;
    Элементы.КатегорияРаботника.СписокВыбора.ЗагрузитьЗначения(ВозможныеЗначенияПеречисления());
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ВозможныеЗначенияПеречисления()
	
	МассивЗначений = Новый Массив;
	
	Для Каждого ЗначениеПеречисления ИЗ Перечисления["Расш1_КатегорииПроживающих"] Цикл
		СинонимПеречисления = Строка(ЗначениеПеречисления);
		//Если СтрНайти(СинонимПеречисления, "_ПС") Тогда
		//	Продолжить;
		//КонецЕсли; 
		МассивЗначений.Добавить(ЗначениеПеречисления);
	КонецЦикла;
	
	Возврат МассивЗначений;
	
КонецФункции
	
&НаСервереБезКонтекста
Функция ПроверитьДоступностьВсегоНомерногоФонда()

	Возврат SessionParameters.ВсеНомераДоступны; 	
	
КонецФункции

&НаКлиенте
Асинх Процедура Расш1_ОтсутствиеПриИзмененииВместо(Элемент)
	
	Если НЕ Object.Отсутствие Тогда
		
		Если НЕ Object.ТипОтсутствия = Неопределено Тогда
			
			Ответ = Ждать ВопросАсинх("Отсутствие сотрудника будет очищено. Продолжить?", РежимДиалогаВопрос.ДаНет);
			Если Ответ = КодВозвратаДиалога.Нет Тогда
				Object.Отсутствие = Истина;
				Возврат;
			КонецЕсли;
			
			Object.ТипОтсутствия = ПредопределенноеЗначение("Перечисление.ТипОтсутствия.ПустаяСсылка");
			Object.ОтсутствиеС = Дата(1,1,1); 
			Object.ОтсутствиеПо = Дата(1,1,1);   
			ОбновитьОтсутствие();
			
		КонецЕсли;
				
	КонецЕсли; 
	
	Если Object.Отсутствие Тогда
		ОбновитьОтсутствие();
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьОтсутствие()
	
		Элементы.ГруппаОтсутствие.Видимость = Object.Отсутствие;
	
КонецПроцедуры