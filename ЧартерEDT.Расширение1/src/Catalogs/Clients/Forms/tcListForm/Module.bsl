
&НаКлиенте
Процедура Расш1_ИсторияЗаселенияПриИзмененииПосле(Элемент)
	Элементы.GroupClientData.Видимость = ИсторияЗаселения; 
КонецПроцедуры

&AtClient
&ChangeAndValidate("OnOpen")
Procedure Расш1_OnOpen(pCancel)
	AdvanceList.Parameters.SetParameterValue("qClient", Undefined);
	If ThisForm.FormOwner <> Undefined And TypeOf(ThisForm.FormOwner) = Type("FormField") Then
		If  ValueIsFilled(ThisForm.FormOwner.EditText) And Not GuestNameFieldsIsFilled() Then
			SelLastName = tcOnServer.cmGetCatalogItemRefByDescription("Clients", ThisForm.FormOwner.EditText, False, "LastName");
			SelFirstName = tcOnServer.cmGetCatalogItemRefByDescription("Clients", ThisForm.FormOwner.EditText, False, "FirstName");	
			SelSecondName = tcOnServer.cmGetCatalogItemRefByDescription("Clients", ThisForm.FormOwner.EditText, False, "SecondName");
		EndIf;
	EndIf;
	If ValueIsFilled(SelLastName) Then
		SelLastName = Title(SelLastName);
		AddNewFilter("SelLastName", SelLastName);
	EndIf;
	If ValueIsFilled(SelFirstName) Then
		SelFirstName = Title(SelFirstName);
		AddNewFilter("SelFirstName", SelFirstName);
	EndIf;
	If ValueIsFilled(SelSecondName) Then
		SelSecondName = Title(SelSecondName);
		AddNewFilter("SelSecondName", SelSecondName);
	EndIf;
	If ValueIsFilled(SelIdentityDocumentNumber) Then
		AddNewFilter("SelIdentityDocumentNumber", SelIdentityDocumentNumber);
	EndIf;
	If ValueIsFilled(SelIdentityDocumentSeries) Then
		AddNewFilter("SelIdentityDocumentSeries", SelIdentityDocumentSeries);
	EndIf;
	If ValueIsFilled(SelPhone) Then
		AddNewFilter("SelPhone", SelPhone);
	EndIf;
	#Вставка
	ИсторияЗаселения = Ложь;
	Элементы.GroupClientData.Видимость = ИсторияЗаселения;
	#КонецВставки
EndProcedure

&AtClient
&ChangeAndValidate("ListOnActivateRow")
Procedure Расш1_ListOnActivateRow(pItem)
	vCurData = pItem.CurrentRow;
	If vCurData = Undefined Then
		Items.GroupClientData.Visible = False;
	Else
		If CurrentDataRef <> vCurData Then
			CurrentDataRef = vCurData;
			#Вставка
			Items.GroupClientData.Visible = ИсторияЗаселения;
			#КонецВставки
			#Удаление
			Items.GroupClientData.Visible = True;
			#КонецУдаления
			AdvanceList.Parameters.SetParameterValue("qClient", vCurData);
			If pItem.CurrentData <> Undefined Then
				AccommodationCount = NStr("en='Acc. ';ru='Разм. ';de='Acc. '") + pItem.CurrentData.AccommodationCount;
				ReservationCount = NStr("en='Res. ';ru='Бронь ';de='Res. '") + pItem.CurrentData.ReservationCount;
			EndIf;
			vIsInBlackList = False;
			vIsInWhiteList = False;
			PutAdvanceData(vCurData, vIsInBlackList, vIsInWhiteList);
			// Check if client is in black list
			vRedColor = New Color(255,0,0);
			vGreenColor = New Color(0,255,0);
			vBorderDefaultColor = New Color(179,172,134);
			vTextDefaultColor = New Color(0,0,0);
			If vIsInBlackList Then
				TRemarks = NStr("en='Is in <black> list!';ru='В <черном> списке!';de='Auf der <schwarzen> Liste!'") + Chars.LF + TRemarks;
				Items.TRemarks.BorderColor = vRedColor;
				Items.TRemarks.TextColor = vRedColor;
			ElsIf vIsInWhiteList Then
				TRemarks = NStr("en='Is in <white> list!';ru='В <белом> списке!';de='Au der <weißen> Liste!'") + Chars.LF + TRemarks;
				Items.TRemarks.BorderColor = vGreenColor;
				Items.TRemarks.TextColor = vGreenColor;
			Else
				Items.TRemarks.BorderColor = vBorderDefaultColor;
				Items.TRemarks.TextColor = vTextDefaultColor;
			EndIf;
			#Вставка
			Уволен = ?(pItem.CurrentData.ПризнакУволенного > 0, Истина, Ложь);
			
			ТекущийДокументРазмещения = ПолучитьТекущийДокументРазмещения(vCurData);
			Если ТекущийДокументРазмещения.Пустая() Тогда
				Если Не Уволен Тогда
					Элементы.ListПоселитьВыселить.Видимость = Истина;
					Элементы.ListПоселитьВыселить.Заголовок = "Поселить";
					Элементы.ListПоселитьВыселить.Картинка = БиблиотекаКартинок.CheckIn;
				Иначе
					Элементы.ListПоселитьВыселить.Видимость = Ложь;
				КонецЕсли;
			Иначе
				Элементы.ListПоселитьВыселить.Видимость = Истина;
				Элементы.ListПоселитьВыселить.Заголовок = "Выселить";
				Элементы.ListПоселитьВыселить.Картинка = БиблиотекаКартинок.CheckOut;
			КонецЕсли;
			#КонецВставки
		EndIf;
	EndIf;
EndProcedure

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
		|	Accommodation.Guest = &qClient
		|	И Accommodation.AccommodationStatus.IsActive
		|	И Accommodation.AccommodationStatus.IsInHouse
		|	И Accommodation.Проведен
		|
		|УПОРЯДОЧИТЬ ПО
		|	Accommodation.Дата";
	
	Запрос.УстановитьПараметр("qClient", vCurData);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		ДокументРазмещения = ВыборкаДетальныеЗаписи.Document;
	КонецЦикла;
	
	Возврат ДокументРазмещения
	
КонецФункции


&НаКлиенте
Процедура Расш1_ПоселитьВыселитьПосле(Команда)
	
	vCurData = Элементы.List.ТекущаяСтрока;

	If vCurData = Undefined Then
		Возврат;
	КонецЕсли;
		
	Если ТекущийДокументРазмещения.Пустая() Тогда 
		ПараметрыФормы = Новый Структура("Сотрудник", vCurData);
		ОткрытьФорму("Документ.Accommodation.Форма.tcDocumentForm", ПараметрыФормы);
	Иначе
		ПараметрыФормы = Новый Структура("Ключ", ТекущийДокументРазмещения);
		ОткрытьФорму("Документ.Accommodation.Форма.tcDocumentForm", ПараметрыФормы);	
	КонецЕсли;
КонецПроцедуры

&AtServer
&ChangeAndValidate("OnCreateAtServer")
Procedure Расш1_OnCreateAtServer(pCancel, pStandardProcessing)
	List.Parameters.SetParameterValue("qClientSex", Enums.Sex.Male);
	List.Parameters.SetParameterValue("qSexMale", 26);
	List.Parameters.SetParameterValue("qSexFemale", 27);
	#Вставка
	List.Parameters.SetParameterValue("ТекущаяДата", ТекущаяДата());
	//+Шершнев 20220901
	List.Parameters.SetParameterValue("qОрганизация", ПолучитьМассивДоступныхНомерныхФондов());
	//-Шершнев 20220901
	#КонецВставки
	
	If ValueIsFilled(SessionParameters.CurrentUser) And ValueIsFilled(SessionParameters.CurrentUser.Customer) Then
		List.Parameters.SetParameterValue("qAuthor", SessionParameters.CurrentUser);
	Else
		List.Parameters.SetParameterValue("qAuthor", Catalogs.Employees.EmptyRef());
	EndIf;

	If Parameters.Property("SelLastName") Then
		SelLastName = Parameters.SelLastName;
	Else
		If Parameters.Property("CurrentRow") Then
			If TypeOf(Parameters.CurrentRow) = Type("CatalogRef.Clients") Then
				vClient = Parameters.CurrentRow;
				SelLastName = TrimR(vClient.LastName);
				SelFirstName = TrimR(vClient.FirstName);
				SelSecondName = TrimR(vClient.SecondName);
				SelIdentityDocumentNumber = TrimR(vClient.IdentityDocumentNumber);
				SelIdentityDocumentSeries = TrimR(vClient.IdentityDocumentSeries);
				SelPhone = TrimR(vClient.Phone);
				SelEMail = TrimR(vClient.EMail);
			EndIf;
		EndIf;
	EndIf;
	If Parameters.Property("SelFirstName") Then
		SelFirstName = Parameters.SelFirstName;
	EndIf;
	If Parameters.Property("SelSecondName") Then
		SelSecondName = Parameters.SelSecondName;
	EndIf;
	If Parameters.Property("SelIdentityDocumentNumber") Then
		SelIdentityDocumentNumber = Parameters.SelIdentityDocumentNumber;
	EndIf;
	If Parameters.Property("SelIdentityDocumentSeries") Then
		SelIdentityDocumentSeries = Parameters.SelIdentityDocumentSeries;
	EndIf;
	If Parameters.Property("SelPhone") Then
		SelPhone = Parameters.SelPhone;
	EndIf;
	If Parameters.Property("SelTag") Then
		SelTag = Parameters.SelTag;
	EndIf;
	If Parameters.Property("SelClientType") Then
		SelClientType = Parameters.SelClientType;
	EndIf;
	vChoiceMode = False;
	If Parameters.Property("ChoiceMode", vChoiceMode) Then
		If vChoiceMode Then
			Items.List.ChoiceMode = vChoiceMode;
		EndIf;
	EndIf;
	List.Parameters.SetParameterValue("qTag", SelTag);
	List.Parameters.SetParameterValue("qTagIsFilled", ValueIsFilled(SelTag));
	List.Parameters.SetParameterValue("qClientType", SelClientType);
	List.Parameters.SetParameterValue("qClientTypeIsFilled", ValueIsFilled(SelClientType));
	FilterSame();
EndProcedure

//+Шершнев 20220901
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
//-Шершнев 20220901