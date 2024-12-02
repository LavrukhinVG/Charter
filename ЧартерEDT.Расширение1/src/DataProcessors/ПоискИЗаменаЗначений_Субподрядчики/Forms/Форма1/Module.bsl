
////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБЩЕГО НАЗНАЧЕНИЯ

&НаСервере
// Возвращает объект ОписаниеТипов, содержащий указанный тип.
//
// Параметры:
//  ЗначениеТипа - строка с именем типа или значение типа Тип.
//  
// Возвращаемое значение:
//  ОписаниеТипов
//
Функция вОписаниеТипа(ЗначениеТипа)

	МассивТипов = Новый Массив;
	Если ТипЗнч(ЗначениеТипа) = Тип("Строка") Тогда
		МассивТипов.Добавить(Тип(ЗначениеТипа));
	Иначе
		МассивТипов.Добавить(ЗначениеТипа);
	КонецЕсли; 
	ОписаниеТипов	= Новый ОписаниеТипов(МассивТипов);

	Возврат ОписаниеТипов;

КонецФункции // вОписаниеТипа()


////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ДЕЙСТВИЯ КОМАНДНЫХ ПАНЕЛЕЙ ФОРМЫ

&НаКлиенте
Процедура Настройка(Команда)
	
	ФормаНастройки = ПолучитьФорму("ВнешняяОбработка.ПоискИЗаменаЗначений.Форма.ФормаНастройки1");
	ФормаНастройки.Объект.ВыполнятьВТранзакции    = Объект.ВыполнятьВТранзакции;
	ФормаНастройки.Объект.ОтключатьКонтрольЗаписи = Объект.ОтключатьКонтрольЗаписи;
	
	Если ФормаНастройки.ОткрытьМодально() = КодВозвратаДиалога.ОК Тогда
		Объект.ВыполнятьВТранзакции    = ФормаНастройки.Объект.ВыполнятьВТранзакции;
		Объект.ОтключатьКонтрольЗаписи = ФормаНастройки.Объект.ОтключатьКонтрольЗаписи;
	КонецЕсли; 
	
КонецПроцедуры

&НаКлиенте
Процедура КнопкаВыполнитьНажатие(Команда)
	
	ВыполнитьСервер();
	
	Предупреждение("Обработка завершена!");
	
	ПометитьНаУдаление();
	
КонецПроцедуры

&НаСервере
Процедура ВыполнитьСервер()
	
	Заменяемые = Новый Соответствие;
	Для каждого Стр Из ЗаменяемыеЗначения Цикл
		Если Стр.Пометка Тогда
			Заменяемые.Вставить(Стр.ЧтоЗаменять, Стр.НаЧтоЗаменять);
		КонецЕсли;
	КонецЦикла;
	
	ТаблицаНайденныеСсылки = Объект.НайденныеСсылки.Выгрузить();
	ТаблицаНайденныеСсылки.Колонки.Добавить("Метаданные");
	
	Для каждого СтрокаНайденныеСсылки Из ТаблицаНайденныеСсылки Цикл
		Если СтрокаНайденныеСсылки.Включено Тогда
			СтрокаНайденныеСсылки.Метаданные = Метаданные.НайтиПоПолномуИмени(СтрокаНайденныеСсылки.ПредставлениеМетаданных);
		КонецЕсли;
	КонецЦикла;
	
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	ОбработкаОбъект.ВыполнитьЗаменуЭлементов(Заменяемые, ТаблицаНайденныеСсылки);
	
КонецПроцедуры

&НаКлиенте
Процедура КоманднаяПанельЗаменяемыеЗначенияНайтиСсылки(Команда)

	МассивЗаменяемых = Новый Массив;
	Для каждого Стр Из ЗаменяемыеЗначения Цикл
		Если Стр.Пометка Тогда
			МассивЗаменяемых.Добавить(Стр.ЧтоЗаменять);
		КонецЕсли;
	КонецЦикла;

	Если МассивЗаменяемых.Количество() = 0 Тогда
		Предупреждение("Не выбрано ни одного значения для поиска!");
		Возврат;
	КонецЕсли;

	КоманднаяПанельЗаменяемыеЗначенияНайтиСсылкиСервер(МассивЗаменяемых);
	
	КоманднаяПанельНайденныеСсылкиВключитьВсе("");
	
КонецПроцедуры

&НаСервере
Процедура КоманднаяПанельЗаменяемыеЗначенияНайтиСсылкиСервер(МассивЗаменяемых)
	
	ТаблицаНайденныхСсылок = НайтиПоСсылкам(МассивЗаменяемых);
	
	
	ТаблицаНайденныхСсылок.Колонки[0].Имя = "Ссылка";
	ТаблицаНайденныхСсылок.Колонки[1].Имя = "Данные";
	ТаблицаНайденныхСсылок.Колонки[2].Имя = "Метаданные";
	
	ТаблицаНайденныхСсылок.Колонки.Добавить("Включено", вОписаниеТипа("Булево"));
	ТаблицаНайденныхСсылок.Колонки.Добавить("ПредставлениеМетаданных", вОписаниеТипа("Строка"));
	ТаблицаНайденныхСсылок.Колонки.Добавить("КлючЗаписиРегистраСведений", вОписаниеТипа("СписокЗначений"));
	
	Для каждого СтрокаНайденнаяСсылка Из ТаблицаНайденныхСсылок Цикл
		СтрокаНайденнаяСсылка.ПредставлениеМетаданных = СтрокаНайденнаяСсылка.Метаданные.ПолноеИмя();
		Если Метаданные.РегистрыСведений.Содержит(СтрокаНайденнаяСсылка.Метаданные) Тогда
			Данные = СтрокаНайденнаяСсылка.Данные;
			КлючЗаписи = СтрокаНайденнаяСсылка.КлючЗаписиРегистраСведений;
			КлючЗаписи.Добавить(Данные.Период, "Период");
			КлючЗаписи.Добавить(Данные.Регистратор, "Регистратор");
			Для Каждого Измерение ИЗ СтрокаНайденнаяСсылка.Метаданные.Измерения Цикл
				КлючЗаписи.Добавить(Данные[Измерение.Имя], Измерение.Имя);
			КонецЦикла;
		КонецЕсли;
	КонецЦикла;
	
	Объект.НайденныеСсылки.Загрузить(ТаблицаНайденныхСсылок);

КонецПроцедуры

&НаКлиенте
Процедура КоманднаяПанельНайденныеСсылкиВключитьВсе(Команда)
	Для каждого СтрокаНайденныеСсылки Из Объект.НайденныеСсылки Цикл
		СтрокаНайденныеСсылки.Включено = Истина;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура КоманднаяПанельНайденныеСсылкиВыключитьВсе(Команда)
	Для каждого СтрокаНайденныеСсылки Из Объект.НайденныеСсылки Цикл
		СтрокаНайденныеСсылки.Включено = Ложь;
	КонецЦикла;
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ ТАБЛИЧНОГО ПОЛЯ ЗаменяемыеЗначения

&НаКлиенте
Процедура ЗаменяемыеЗначенияПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)

	Если НоваяСтрока Тогда
		Элемент.ТекущиеДанные.Пометка = Истина;
	КонецЕсли;
	
КонецПроцедуры



////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ ТАБЛИЧНОГО ПОЛЯ НайденныеСсылки

&НаКлиенте
Процедура НайденныеСсылкиВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	ОткрытьЗначение(ВыбраннаяСтрока.Данные);
	СтандартнаяОбработка = Ложь;
КонецПроцедуры


&НаКлиенте
Процедура ЗаполнитьДублями(Команда)
	
	Если Не ЗначениеЗаполнено(Субподрядчик) Тогда
		Возврат;
	КонецЕсли;
	
	ЗаменяемыеЗначения.Очистить();
	
	ЗаполнитьДублямиНаСервере();
	
КонецПроцедуры


&НаСервере
Процедура ЗаполнитьДублямиНаСервере()
	
		//{{КОНСТРУКТОР_ЗАПРОСА_С_ОБРАБОТКОЙ_РЕЗУЛЬТАТА
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Расш1_НомерныеФонды.Ссылка КАК Ref
		|ИЗ
		|	Справочник.Расш1_НомерныеФонды КАК Расш1_НомерныеФонды
		|ГДЕ
		|	НЕ Расш1_НомерныеФонды.ПометкаУдаления
		|	И Расш1_НомерныеФонды.Ссылка <> &Ref
		|	И Расш1_НомерныеФонды.Наименование = &Description";
	
	Запрос.УстановитьПараметр("Description", Субподрядчик.Description);
	Запрос.УстановитьПараметр("Ref", Субподрядчик);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	Номер = 1;
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
		НоваяСтрока = ЗаменяемыеЗначения.Добавить();
		НоваяСтрока.ЧтоЗаменять = ВыборкаДетальныеЗаписи.Ref;
		НоваяСтрока.НаЧтоЗаменять = Субподрядчик;
		НоваяСтрока.Пометка = Истина;
		НоваяСтрока.Номер = Номер;
		
		Номер = Номер + 1;
		
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ПометитьНаУдаление()

	Для каждого Стр Из ЗаменяемыеЗначения Цикл
		Если Стр.Пометка Тогда
			Об = Стр.ЧтоЗаменять.GetObject();
			Об.Description = Об.Description + " (удален после ошибки в интеграции)"; 
			Об.ПометкаУдаления = Истина;
			об.Записать();
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура СубподрядчикПриИзмененииНаСервере()
	
		//{{КОНСТРУКТОР_ЗАПРОСА_С_ОБРАБОТКОЙ_РЕЗУЛЬТАТА
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	КОЛИЧЕСТВО(Расш1_СоставНомерногоФонда.Номер) КАК Номер
		|ИЗ
		|	РегистрСведений.Расш1_СоставНомерногоФонда КАК Расш1_СоставНомерногоФонда
		|ГДЕ
		|	Расш1_СоставНомерногоФонда.НомернойФонд.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Субподрядчик);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		СсылокНаНомернойФонд = ВыборкаДетальныеЗаписи.Номер;
	КонецЦикла;
	
	//}}КОНСТРУКТОР_ЗАПРОСА_С_ОБРАБОТКОЙ_РЕЗУЛЬТАТА

	// Вставить содержимое обработчика.
КонецПроцедуры

&НаКлиенте
Процедура СубподрядчикПриИзменении(Элемент)
	Объект.НайденныеСсылки.Очистить();
	СубподрядчикПриИзмененииНаСервере();
КонецПроцедуры
