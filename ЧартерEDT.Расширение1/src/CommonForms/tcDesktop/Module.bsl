
&AtClient
&Around("StartProlongedOperations")
Procedure Расш1_StartProlongedOperations()
	BackgroundJobsList.Clear();

	////Room statuses
	//vProcedureParametrs 	= new Array;
	//vTempStorageAdress 	 	= PutToTempStorage(Null);
	//vProcedureParametrs.Add(vTempStorageAdress);
	//vProcedureParametrs.Add(CurrentHotel);
	////#Вставка
	//vProcedureParametrs.Очистить();
	//vProcedureParametrs.Add(vTempStorageAdress);
	//СтруктураПараметров = Новый Структура;
	//СтруктураПараметров.Вставить("CurrentHotel", CurrentHotel);
	//СтруктураПараметров.Вставить("НомернойФонд", НомернойФонд);
	//vProcedureParametrs.Add(СтруктураПараметров);	
	////#КонецВставки

	//vBackgroundJob 		 	= StartBackgroundJob("ProlongedOperations.tcDesktop_GetRoomStatusesTable", vProcedureParametrs, vTempStorageAdress);

	//vnewRow 				= BackgroundJobsList.Add();
	//vnewRow.Name 		 	= "tcDesktop_GetRoomStatusesTable";
	//vnewRow.UUID 		 	= vBackgroundJob.UUID;
	//vnewRow.ResultAddress 	= vBackgroundJob.TempStorageAddress;
	//vnewRow.Status 		 	= "Processing";

	////Summary indexes
	//vProcedureParametrs.Clear();
	//vTempStorageAdress 	 	= PutToTempStorage(Null);
	//vProcedureParametrs.Add(vTempStorageAdress);
	//vProcedureParametrs.Add(CurrentHotel);
	////#Вставка
	//vProcedureParametrs.Очистить();
	//vProcedureParametrs.Add(vTempStorageAdress);
	//СтруктураПараметров = Новый Структура;
	//СтруктураПараметров.Вставить("CurrentHotel", CurrentHotel);
	//СтруктураПараметров.Вставить("НомернойФонд", НомернойФонд);
	//vProcedureParametrs.Add(СтруктураПараметров);	
	////#КонецВставки

	//vBackgroundJob 		 	= StartBackgroundJob("ProlongedOperations.tcDesktop_GetSummaryPercent", vProcedureParametrs, vTempStorageAdress);

	//vnewRow 				= BackgroundJobsList.Add();
	//vnewRow.Name 		 	= "tcDesktop_GetSummaryPercent";
	//vnewRow.UUID 		 	= vBackgroundJob.UUID;
	//vnewRow.ResultAddress 	= vBackgroundJob.TempStorageAddress;
	//vnewRow.Status 		 	= "Processing";

	////Check in/out
	//vProcedureParametrs.Clear();
	//vTempStorageAdress 	 	= PutToTempStorage(Null);
	//vProcedureParametrs.Add(vTempStorageAdress);
	//vProcedureParametrs.Add(CurrentHotel);
	////#Вставка
	//vProcedureParametrs.Очистить();
	//vProcedureParametrs.Add(vTempStorageAdress);
	//СтруктураПараметров = Новый Структура;
	//СтруктураПараметров.Вставить("CurrentHotel", CurrentHotel);
	//СтруктураПараметров.Вставить("НомернойФонд", НомернойФонд);
	//vProcedureParametrs.Add(СтруктураПараметров);	
	////#КонецВставки

	//vBackgroundJob 		 	= StartBackgroundJob("ProlongedOperations.tcDesktop_GetCheckInOutCount", vProcedureParametrs, vTempStorageAdress);

	//vnewRow 				= BackgroundJobsList.Add();
	//vnewRow.Name 		 	= "tcDesktop_GetCheckInOutCount";
	//vnewRow.UUID 		 	= vBackgroundJob.UUID;
	//vnewRow.ResultAddress 	= vBackgroundJob.TempStorageAddress;
	//vnewRow.Status 		 	= "Processing";

	////InHouse
	//vProcedureParametrs.Clear();
	//vTempStorageAdress 	 	= PutToTempStorage(Null);
	//vProcedureParametrs.Add(vTempStorageAdress);
	//vProcedureParametrs.Add(CurrentHotel);
	//vProcedureParametrs.Add(EndOfDay(CurrentDate()));
	////#Вставка
	//vProcedureParametrs.Очистить();
	//vProcedureParametrs.Add(vTempStorageAdress);
	//СтруктураПараметров = Новый Структура;
	//СтруктураПараметров.Вставить("CurrentHotel", CurrentHotel);
	//СтруктураПараметров.Вставить("НомернойФонд", НомернойФонд);
	//vProcedureParametrs.Add(СтруктураПараметров);
	//vProcedureParametrs.Add(EndOfDay(CurrentDate()));
	////#КонецВставки

	//vBackgroundJob 		 	= StartBackgroundJob("ProlongedOperations.tcDesktop_GetInHouse", vProcedureParametrs, vTempStorageAdress);

	//vnewRow 				= BackgroundJobsList.Add();
	//vnewRow.Name 		 	= "tcDesktop_GetInHouse";
	//vnewRow.UUID 		 	= vBackgroundJob.UUID;
	//vnewRow.ResultAddress 	= vBackgroundJob.TempStorageAddress;
	//vnewRow.Status 		 	= "Processing";

	//AttachIdleHandler("CheckBackgroundJobs",1,False);
EndProcedure

&НаКлиенте
Процедура Расш1_НомернойФондПриИзмененииПосле(Элемент)
	
	CancelProlongedOperations();
	Items.SummaryIndexesGroup_Row_1.Visible = False;
	Items.InHouse_Rooms_Value.Visible 		= False;
	Items.CheckIn_Rooms_Value.Visible 		= False;
	Items.CheckOut_Rooms_Value.Visible 		= False;
	Items.RoomsTable.Visible 				= False;
	
	Items.Loading_picture_SummaryIndexes.Visible 		= True;
	Items.Processing_Picture_InHouse_Row_1.Visible 		= True;
	Items.Processing_Picture_CheckIn_Row_2.Visible 		= True;
	Items.Processing_Picture_CheckOut_Row_2.Visible 	= True;
	Items.Loading_picture_RoomsTable.Visible 			= True;
	StartProlongedOperations();
	
	RefreshSessionDate();

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

&НаКлиенте
Процедура Расш1_СотрудникиПосле(Команда)
	OpenForm("Справочник.Clients.ФормаСписка");
КонецПроцедуры

&НаКлиенте
Процедура Расш1_ЗадачиПосле(Команда)
	//+Шершнев 20220805
	OpenForm("Document.Message.ListForm");            
	//OpenForm("Catalog.Rooms.Form.tcHousekeepingForm");	//20220905
	//ОткрытьФорму("ОбщаяФорма.Расш1_ФормаЖилойФонд");		//20220905
	//-Шершнев 20220805
КонецПроцедуры

&НаКлиенте
Процедура Расш1_ПоселитьСотрудникаПосле(Команда)
	#If Not WebClient Then
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 10, NStr("en='Opening...';ru='Открытие формы...';de='Öffnen des Formulars...'"), PictureLib.LongOperation); 
	#EndIf
	vDocFormParameters = New Structure;
	vDocFormParameters.Insert("Document", tcOnServer.cmGetDocumentItemRefByDocNumber("Accommodation", "", True) );
	vFrm = GetForm("Document.Accommodation.ObjectForm", vDocFormParameters);
	#If Not WebClient Then
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 30, NStr("en='Opening...';ru='Открытие формы...';de='Öffnen des Formulars...'"), PictureLib.LongOperation); 
	#EndIf	
	vFrm.Open();
КонецПроцедуры

&НаКлиенте
Процедура Расш1_ВыселитьСотрудникаПосле(Команда)
	If amPersistentObjects.Property("IsLockApplication") Then
		If amPersistentObjects.IsLockApplication Then
			Return;	
		EndIf;	
	EndIf;
	If Not CheckUserPermission() Then
		Raise NStr("en='You do not have rights to this function!';ru='У вас нет прав на эту функцию!';de='Sie haben keine Rechte für diese Funktion!'");
		Return;
	EndIf;
	#IF NOT MobileClient THEN 
		OpenForm("Document.Accommodation.Form.tcAccommodationListForm", New Structure("SelFilterStatus", 0));
	#ELSE
		OpenForm("Document.Accommodation.Form.mcAccommodationListForm", New Structure("SelFilterStatus", 0));	
	#ENDIF
	Notify("Document.Accommodation.ListForm.InHouseGuests");
КонецПроцедуры

&AtServer
Function CheckUserPermission()
	If ValueIsFilled(SessionParameters.CurrentUser) Then
		If Not ValueIsFilled(SessionParameters.CurrentUser.Customer) Then
			Return True;
		EndIf;
	EndIf;
	Return False;
EndFunction //CheckUserPermission

&НаКлиенте
Процедура Расш1_СправкаПосле(Команда)
	OpenForm("Отчет.СправкаБКАЭ.Форма.ФормаОтчета");
КонецПроцедуры

&НаКлиенте
Процедура Расш1_ДублирующиеЗаселенияПосле(Команда)
	OpenForm("Отчет.ДублирующиеЗаселения.Форма.ФормаОтчета");
КонецПроцедуры

&НаКлиенте
Процедура Расш1_РаспределениеНФПосле(Команда)
	OpenForm("РегистрСведений.Расш1_СоставНомерногоФонда.Форма.Форма");
КонецПроцедуры

&AtServer
&ChangeAndValidate("OnCreateAtServer")
Procedure Расш1_OnCreateAtServer(pCancel, pStandardProcessing)
	If Parameters.Property("AvtoTest") Then
		If Parameters.AvtoTest Then
			Return;
		EndIf;	
	EndIf;

	// Check protection system
	tcProtection.cmCheckForm(ThisForm);
	// Let's set the properties of the form
	tcOnServer.cmSetFormProperties(ThisForm);

	// Access rights
	If Not AccessRight("View", Metadata.CommonCommands.MainMenuSummaryIndexesCommand) Then
		Items.SummaryIndexesGroup_New.Visible 	= False;
		Items.RoomsPlan.Visible 				= False;
	EndIf;
	If ValueIsFilled(SessionParameters.CurrentUser) Then
		If ValueIsFilled(SessionParameters.CurrentUser.Customer) Then
			Items.InHouseGroup.Visible = False;
			Items.CheckOutGroup.Visible = False;
		EndIf;
	Else
		Items.InHouseGroup.Visible = False;
		Items.CheckOutGroup.Visible = False;
	EndIf;

	CurrentHotel = SessionParameters.CurrentHotel;
	If ValueIsFilled(SessionParameters.CurrentUser.Customer) Then
		ThisForm.Title = NStr("en='Hotel agent remote workplace';ru='Удаленное рабочее место агента';de='Gelöschter Arbeitsplatz des Agenten'") + ?(ValueIsFilled(CurrentHotel), " " + CurrentHotel.GetObject().pmGetHotelPrintName(SessionParameters.CurrentLanguage), "");
	Else
		ThisForm.Title = ?(ValueIsFilled(CurrentHotel), " " + CurrentHotel.GetObject().pmGetHotelPrintName(SessionParameters.CurrentLanguage), "");
	EndIf;
	CurrentDateField = FillSessionDate();
	#Вставка
	Если Не SessionParameters.ВсеНомераДоступны Тогда
		Массив = ПолучитьМассивДоступныхНомерныхФондов();
		Если Массив.Количество() > 0 Тогда
			НомернойФонд = Массив[0];
		КонецЕсли;
	КонецЕсли;
	#КонецВставки
EndProcedure
