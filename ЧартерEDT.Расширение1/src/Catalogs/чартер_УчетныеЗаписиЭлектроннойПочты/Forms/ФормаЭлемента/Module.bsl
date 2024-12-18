#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.БлокироватьВладельца Тогда
		РежимОткрытияОкна = РежимОткрытияОкнаФормы.БлокироватьОкноВладельца;
	КонецЕсли;
	
	Если Объект.Ссылка.Пустая() Тогда
		Объект.ИспользоватьДляОтправки = Истина;
		Объект.ИспользоватьДляПолучения = ДоступноПолучениеПисем;
		ЗаполнитьНастройки();
	КонецЕсли;
	
	Элементы.ИспользоватьУчетнуюЗапись.ОтображатьЗаголовок = ДоступноПолучениеПисем;
	Элементы.ДляПолучения.Видимость = ДоступноПолучениеПисем;
	
	Если Не ДоступноПолучениеПисем Тогда
		Элементы.ДляОтправки.Заголовок = НСтр("ru = 'Использовать для отправки писем'");
	КонецЕсли;
	
	//Элементы.ГруппаДляКогоУчетнаяЗапись.Доступность = Пользователи.ЭтоПолноправныйПользователь();
	
	РеквизитыТребующиеВводаПароляДляИзменения = Справочники.чартер_УчетныеЗаписиЭлектроннойПочты.РеквизитыТребующиеВводаПароляДляИзменения();
	
	//Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ПодключаемыеКоманды") Тогда
	//	МодульПодключаемыеКоманды = ОбщегоНазначения.ОбщийМодуль("ПодключаемыеКоманды");
	//	МодульПодключаемыеКоманды.ПриСозданииНаСервере(ЭтотОбъект);
	//КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	//УстановитьВидНастройкиХраненияПисемНаСервере();
	//Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.ПодключаемыеКоманды") Тогда
	//	МодульПодключаемыеКомандыКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ПодключаемыеКомандыКлиент");
	//	МодульПодключаемыеКомандыКлиент.НачатьОбновлениеКоманд(ЭтотОбъект);
	//КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	// СтандартныеПодсистемы.УправлениеДоступом
	//Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.УправлениеДоступом") Тогда
	//	МодульУправлениеДоступом = ОбщегоНазначения.ОбщийМодуль("УправлениеДоступом");
	//	МодульУправлениеДоступом.ПриЧтенииНаСервере(ЭтотОбъект, ТекущийОбъект);
	//КонецЕсли;
	// Конец СтандартныеПодсистемы.УправлениеДоступом
	
	ЗаполнитьНастройки();
	
	//Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ПодключаемыеКоманды") Тогда
	//	МодульПодключаемыеКомандыКлиентСервер = ОбщегоНазначения.ОбщийМодуль("ПодключаемыеКомандыКлиентСервер");
	//	МодульПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
	//КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПротоколПриИзменении(Элемент)
	
	Если ПустаяСтрока(Объект.ПротоколВходящейПочты) Тогда
		Объект.ПротоколВходящейПочты = "IMAP";
	КонецЕсли;
	
	Если Объект.ПротоколВходящейПочты = "IMAP" Тогда
		Если СтрНачинаетсяС(Объект.СерверВходящейПочты, "pop.") Тогда
			Объект.СерверВходящейПочты = "imap." + Сред(Объект.СерверВходящейПочты, 5);
		КонецЕсли
	Иначе
		Если СтрНачинаетсяС(Объект.СерверВходящейПочты, "imap.") Тогда
			Объект.СерверВходящейПочты = "pop." + Сред(Объект.СерверВходящейПочты, 6);
		КонецЕсли;
	КонецЕсли;
	
	Элементы.СерверВходящейПочты.Заголовок = чартер_ОбщиеПроцедурыИфункцииКлиент.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Сервер %1'"), Объект.ПротоколВходящейПочты);
		
	ИспользуетсяПротоколPOP = Объект.ПротоколВходящейПочты = "POP";
	Элементы.ОставлятьПисьмаНаСервере.Видимость = ИспользуетсяПротоколPOP И ДоступноПолучениеПисем;
	
	УстановитьВидГруппыТребуетсяАвторизация(ЭтотОбъект, ИспользуетсяПротоколPOP);
	
	УстановитьПортВходящейПочты();
	УстановитьВидНастройкиХраненияПисемНаСервере();
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьВидГруппыТребуетсяАвторизация(Форма, ИспользуетсяПротоколPOP)
	
	//Если ИспользуетсяПротоколPOP Тогда
	//	Форма.Элементы.ТребуетсяАвторизацияПриОтправкеПисем.Заголовок = НСтр("ru = 'При отправке писем требуется авторизация'");
	//Иначе
	//	Форма.Элементы.ТребуетсяАвторизацияПриОтправкеПисем.Заголовок = НСтр("ru = 'При отправке писем требуется авторизация на сервере исходящей почты (SMTP)'");
	//КонецЕсли;

	//Форма.Элементы.АвторизацияПриОтправкеПисем.Видимость = ИспользуетсяПротоколPOP;
	
КонецПроцедуры

&НаКлиенте
Процедура СерверВходящейПочтыПриИзменении(Элемент)
	Объект.СерверВходящейПочты = СокрЛП(НРег(Объект.СерверВходящейПочты));
КонецПроцедуры

&НаКлиенте
Процедура СерверИсходящейПочтыПриИзменении(Элемент)
	Объект.СерверИсходящейПочты = СокрЛП(НРег(Объект.СерверИсходящейПочты));
КонецПроцедуры

&НаКлиенте
Процедура АдресЭлектроннойПочтыПриИзменении(Элемент)
	Объект.АдресЭлектроннойПочты = СокрЛП(Объект.АдресЭлектроннойПочты);
КонецПроцедуры

&НаКлиенте
Процедура ОставлятьКопииПисемНаСервереПриИзменении(Элемент)
	УстановитьВидНастройкиХраненияПисемНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура УдалятьПисьмаССервераПриИзменении(Элемент)
	УстановитьВидНастройкиХраненияПисемНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ПарольПриИзменении(Элемент)
	ПарольИзменен = Истина;
КонецПроцедуры

&НаКлиенте
Процедура ПарольИзменениеТекстаРедактирования(Элемент, Текст, СтандартнаяОбработка)
	Элементы.Пароль.КнопкаВыбора = Истина;
КонецПроцедуры

&НаКлиенте
Процедура ПарольНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	чартер_ОбщиеПроцедурыИфункцииКлиент.ПолеПароляНачалоВыбора(Элемент, Пароль, СтандартнаяОбработка);	
КонецПроцедуры

&НаКлиенте
Процедура ТребуетсяАвторизацияПриОтправкеПисемПриИзменении(Элемент)   
	
	Элементы.АвторизацияПриОтправкеПисем.Доступность = Объект.ПриОтправкеПисемТребуетсяАвторизация;
	Элементы.АвторизацияПриОтправкеПисем.Видимость = Объект.ПротоколВходящейПочты = "POP";
	
КонецПроцедуры

&НаКлиенте
Процедура ШифрованиеПриОтправкеПочтыПриИзменении(Элемент)
	
	Объект.ИспользоватьЗащищенноеСоединениеДляИсходящейПочты = ШифрованиеПриОтправкеПочты = "SSL";
	УстановитьПортИсходящейПочты();
	
КонецПроцедуры

&НаКлиенте
Процедура ШифрованиеПриПолученииПочтыПриИзменении(Элемент)
	Объект.ИспользоватьЗащищенноеСоединениеДляВходящейПочты = ШифрованиеПриПолученииПочты = "SSL";
	УстановитьПортВходящейПочты();
КонецПроцедуры

&НаКлиенте
Процедура СпособАвторизацииПриОтправкеПочтыПриИзменении(Элемент)
	Объект.ТребуетсяВходНаСерверПередОтправкой = ?(СпособАвторизацииПриОтправкеПочты = "POP", Истина, Ложь);
	УстановитьВидНастройкиХраненияПисемНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ИспользованиеПриИзменении(Элемент)
	Элементы.ФормаПроверитьНастройки.Доступность = Объект.ИспользоватьДляОтправки Или Объект.ИспользоватьДляПолучения;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ЗаписатьИЗакрыть(Команда)
	
	Записать(Новый Структура("ЗаписатьИЗакрыть"));
	
КонецПроцедуры


#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура УстановитьВидНастройкиХраненияПисемНаСервере()
	
	ИспользуетсяПротоколPOP = Объект.ПротоколВходящейПочты = "POP";
	Элементы.ОставлятьПисьмаНаСервере.Видимость = ИспользуетсяПротоколPOP И ДоступноПолучениеПисем;
	Элементы.НастройкаПериодаХраненияПисем.Доступность = Объект.ОставлятьКопииСообщенийНаСервере;
	Элементы.ПериодХраненияСообщенийНаСервере.Доступность = УдалятьПисьмаССервера;
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьПортВходящейПочты()
	Если Объект.ПротоколВходящейПочты = "IMAP" Тогда
		Если Объект.ПортСервераВходящейПочты = 995 Тогда
			Объект.ПортСервераВходящейПочты = 993;
		КонецЕсли;
	Иначе
		Если Объект.ПортСервераВходящейПочты = 993 Тогда
			Объект.ПортСервераВходящейПочты = 995;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура УстановитьПортИсходящейПочты()
	Если Объект.ИспользоватьЗащищенноеСоединениеДляИсходящейПочты Тогда
		Если Объект.ПортСервераИсходящейПочты = 587 Тогда
			Объект.ПортСервераИсходящейПочты = 465;
		КонецЕсли;
	Иначе
		Если Объект.ПортСервераИсходящейПочты = 465 Тогда
			Объект.ПортСервераИсходящейПочты = 587;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьПроверкуНастроек()
	
	Если Модифицированность Тогда
		Записать(Новый Структура("ПроверитьНастройки"));
	//Иначе
	//	РаботаСПочтовымиСообщениямиКлиент.ПроверитьНастройкиУчетнойЗаписи(Объект.Ссылка);
	КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура ЗаполнитьНастройки()
	
	ДоступноПолучениеПисем = чартеры_ОбщиеПроцедурыИФункцииСервер.НастройкиПодсистемы().ДоступноПолучениеПисем;
	Элементы.ОставлятьПисьмаНаСервере.Видимость = Объект.ПротоколВходящейПочты = "POP" И ДоступноПолучениеПисем;
	
	Элементы.СерверВходящейПочты.Заголовок = чартеры_ОбщиеПроцедурыИФункцииСервер.ПодставитьПараметрыВСтроку(
	НСтр("ru = 'Сервер %1'"), Объект.ПротоколВходящейПочты);
	
	УдалятьПисьмаССервера = Объект.ПериодХраненияСообщенийНаСервере > 0;
	Если Не УдалятьПисьмаССервера Тогда
		Объект.ПериодХраненияСообщенийНаСервере = 10;
	КонецЕсли;
	
	Элементы.ФормаЗаписатьИЗакрыть.Доступность = Не ТолькоПросмотр;
	
	ИспользуетсяПротоколPOP = Объект.ПротоколВходящейПочты = "POP";
	Элементы.АвторизацияПриОтправкеПисем.Доступность = Объект.ПриОтправкеПисемТребуетсяАвторизация;
	УстановитьВидГруппыТребуетсяАвторизация(ЭтотОбъект, ИспользуетсяПротоколPOP);
	
	ШифрованиеПриОтправкеПочты = ?(Объект.ИспользоватьЗащищенноеСоединениеДляИсходящейПочты, "SSL", "Авто");
	ШифрованиеПриПолученииПочты = ?(Объект.ИспользоватьЗащищенноеСоединениеДляВходящейПочты, "SSL", "Авто");
	
	СпособАвторизацииПриОтправкеПочты = ?(Объект.ТребуетсяВходНаСерверПередОтправкой, "POP", "SMTP");
	Элементы.ФормаПроверитьНастройки.Доступность = Объект.ИспользоватьДляОтправки Или Объект.ИспользоватьДляПолучения;
	Элементы.ФормаОткрытьПомощникНастройки.Доступность = Не Объект.Ссылка.Пустая() И Не ТолькоПросмотр;
	
	Элементы.Пароль.КнопкаВыбора = Ложь;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗапонитьЗначениямиПоУмолчанию(Команда)
		
	Объект.ИмяПользователя = НСтр("ru = '1С:Предприятие'");
	Объект.ИспользоватьДляПолучения = Ложь;
	Объект.ИспользоватьДляОтправки = Ложь;
	Объект.ОставлятьКопииСообщенийНаСервере = Ложь;
	Объект.ПериодХраненияСообщенийНаСервере = 0;
	Объект.ВремяОжидания = 30;
	Объект.ПортСервераВходящейПочты = 110;
	Объект.ПортСервераИсходящейПочты = 25;
	Объект.ПротоколВходящейПочты = "POP";
	
КонецПроцедуры

#КонецОбласти
