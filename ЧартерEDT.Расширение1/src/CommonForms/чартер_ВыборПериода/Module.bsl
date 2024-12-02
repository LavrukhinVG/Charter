
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Параметры.Свойство("Значение", ВыбираемыйПериод);
	
	//ВыбиратьВидПериода = чартер_ОбщиеПроцедурыИфункцииКлиент.СвойствоСтруктуры(Параметры, "ВыбиратьВидПериода", Ложь);
	//Если ВыбиратьВидПериода Тогда
	//	ВидыВыбираемыхПериодов = Новый ФиксированныйМассив(чартер_ОбщиеПроцедурыИфункцииКлиент.СвойствоСтруктуры(Параметры, "ВидыВыбираемыхПериодов"));
	//КонецЕсли;
	//
	//КлючСохраненияПоложенияОкна = СвойствоСтруктуры(Параметры, "КлючСохраненияПоложенияОкна", "ОдинПериод");
	
	Если НЕ ЗначениеЗаполнено(ВыбираемыйПериод) Тогда
		ВыбираемыйПериод = НачалоМесяца(ТекущаяДатаСеанса());
	КонецЕсли;
	
	Если НЕ Параметры.Свойство("ЗапрашиватьРежимВыбораПериодаУВладельца", ЗапрашиватьРежимВыбораПериодаУВладельца) Тогда
		ЗапрашиватьРежимВыбораПериодаУВладельца = Ложь;
	КонецЕсли;
	
	УстановитьРежимВыбораПериода(ЭтотОбъект, Параметры.РежимВыбораПериода);
	
	ЦветФонаКнопкиВыбранногоПериода = ЦветаСтиля.ФонПомеченнойКнопкиЦвет;
	ЦветФонаКнопки = ЦветаСтиля.ЦветФонаКнопки;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ОбновитьОтображение();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ВыбираемыйПериодПриИзменении(Элемент)
	
	ИзменилсяГод = Истина;
	ОтмеченныйПериод = Неопределено;
	УстановитьВыбираемыйПериод(Год(ВыбираемыйПериод), Месяц(ВыбираемыйПериод));
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура КомандаМесяц01(Команда)
	УстановитьВыбираемыйМесяц(1);
	ОтмеченныйПериод = ВыбираемыйПериод;
КонецПроцедуры

&НаКлиенте
Процедура КомандаМесяц02(Команда)
	УстановитьВыбираемыйМесяц(2);
	ОтмеченныйПериод = ВыбираемыйПериод;
КонецПроцедуры

&НаКлиенте
Процедура КомандаМесяц03(Команда)
	УстановитьВыбираемыйМесяц(3);
	ОтмеченныйПериод = ВыбираемыйПериод;
КонецПроцедуры

&НаКлиенте
Процедура КомандаМесяц04(Команда)
	УстановитьВыбираемыйМесяц(4);
	ОтмеченныйПериод = ВыбираемыйПериод;
КонецПроцедуры

&НаКлиенте
Процедура КомандаМесяц05(Команда)
	УстановитьВыбираемыйМесяц(5);
	ОтмеченныйПериод = ВыбираемыйПериод;
КонецПроцедуры

&НаКлиенте
Процедура КомандаМесяц06(Команда)
	УстановитьВыбираемыйМесяц(6);
	ОтмеченныйПериод = ВыбираемыйПериод;
КонецПроцедуры

&НаКлиенте
Процедура КомандаМесяц07(Команда)
	УстановитьВыбираемыйМесяц(7);
	ОтмеченныйПериод = ВыбираемыйПериод;
КонецПроцедуры

&НаКлиенте
Процедура КомандаМесяц08(Команда)
	УстановитьВыбираемыйМесяц(8);
	ОтмеченныйПериод = ВыбираемыйПериод;
КонецПроцедуры

&НаКлиенте
Процедура КомандаМесяц09(Команда)
	УстановитьВыбираемыйМесяц(9);
	ОтмеченныйПериод = ВыбираемыйПериод;
КонецПроцедуры

&НаКлиенте
Процедура КомандаМесяц10(Команда)
	УстановитьВыбираемыйМесяц(10);
	ОтмеченныйПериод = ВыбираемыйПериод;
КонецПроцедуры

&НаКлиенте
Процедура КомандаМесяц11(Команда)
	УстановитьВыбираемыйМесяц(11);
	ОтмеченныйПериод = ВыбираемыйПериод;
КонецПроцедуры

&НаКлиенте
Процедура КомандаМесяц12(Команда)
	УстановитьВыбираемыйМесяц(12);
	ОтмеченныйПериод = ВыбираемыйПериод;
КонецПроцедуры

&НаКлиенте
Процедура КомандаКвартал1(Команда)
	УстановитьВыбираемыйКвартал(1);
	ОтмеченныйПериод = ВыбираемыйПериод;
КонецПроцедуры

&НаКлиенте
Процедура КомандаКвартал2(Команда)
	УстановитьВыбираемыйКвартал(2);
	ОтмеченныйПериод = ВыбираемыйПериод;
КонецПроцедуры

&НаКлиенте
Процедура КомандаКвартал3(Команда)
	УстановитьВыбираемыйКвартал(3);
	ОтмеченныйПериод = ВыбираемыйПериод;
КонецПроцедуры

&НаКлиенте
Процедура КомандаКвартал4(Команда)
	УстановитьВыбираемыйКвартал(4);
	ОтмеченныйПериод = ВыбираемыйПериод;
КонецПроцедуры

&НаКлиенте
Процедура КомандаПолугодие1(Команда)
	УстановитьВыбираемоеПолугодие(1);
	ОтмеченныйПериод = ВыбираемыйПериод;
КонецПроцедуры

&НаКлиенте
Процедура КомандаПолугодие2(Команда)
	УстановитьВыбираемоеПолугодие(2);
	ОтмеченныйПериод = ВыбираемыйПериод;
КонецПроцедуры

&НаКлиенте
Процедура КомандаГод(Команда)
	УстановитьВыбираемыйГод();
	ОтмеченныйПериод = ВыбираемыйПериод;
КонецПроцедуры

&НаКлиенте
Процедура КомандаВыбрать(Команда)
	ВыполнитьВыбор();
КонецПроцедуры

&НаКлиенте
Процедура КомандаОтмена(Команда)
	Закрыть();
КонецПроцедуры

&НаКлиенте
Процедура КомандаПролистатьГодВМинус(Команда)
	
	ВыбираемыйГод = Год(ВыбираемыйПериод) - 1;
	ОтмеченныйПериод = Неопределено;
	УстановитьВыбираемыйПериод(ВыбираемыйГод, Месяц(ВыбираемыйПериод));
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаПролистатьГодВПлюс(Команда)
	
	ВыбираемыйГод = Год(ВыбираемыйПериод) + 1;
	ОтмеченныйПериод = Неопределено;
	УстановитьВыбираемыйПериод(ВыбираемыйГод, Месяц(ВыбираемыйПериод));
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции


&НаКлиенте
Процедура УстановитьВыбираемыйМесяц(НомерМесяца)
	УстановитьВыбираемыйПериод(Год(ВыбираемыйПериод), НомерМесяца, "МЕСЯЦ");
КонецПроцедуры

&НаКлиенте
Процедура УстановитьВыбираемыйКвартал(НомерКвартала)
	УстановитьВыбираемыйПериод(Год(ВыбираемыйПериод), ((НомерКвартала - 1) * 3) + 1, "КВАРТАЛ");
КонецПроцедуры

&НаКлиенте
Процедура УстановитьВыбираемоеПолугодие(НомерПолугодия)
	УстановитьВыбираемыйПериод(Год(ВыбираемыйПериод), ((НомерПолугодия - 1) * 6) + 1, "ПОЛУГОДИЕ");
КонецПроцедуры

&НаКлиенте
Процедура УстановитьВыбираемыйГод()
	УстановитьВыбираемыйПериод(Год(ВыбираемыйПериод), 1, "ГОД");
КонецПроцедуры

&НаКлиенте
Процедура ПроверитьРежимВыбораПериода()
	
	Если ЗапрашиватьРежимВыбораПериодаУВладельца Тогда
		УстановитьРежимВыбораПериода(ЭтотОбъект, ВладелецФормы.РежимВыбораПериода(ВыбираемыйПериод));
	КонецЕсли;
	
КонецПроцедуры
	
&НаСервере
Процедура УстановитьРежимВыбораПериода(Форма, Знач РежимВыбора)
	
	Если НЕ ЗначениеЗаполнено(РежимВыбора) Тогда
		РежимВыбора = "Месяц";
	КонецЕсли; 
	
	Если Форма.РежимВыбораПериода = ВРег(РежимВыбора) Тогда
		Возврат;
	КонецЕсли; 
	
	Форма.РежимВыбораПериода = ВРег(РежимВыбора);
	
	Если Форма.ВыбиратьВидПериода Тогда
		ГруппаМесяцыВидимость = Форма.ВидыВыбираемыхПериодов.Найти("МЕСЯЦ") <> Неопределено;
		ГруппаКварталыВидимость = Форма.ВидыВыбираемыхПериодов.Найти("КВАРТАЛ") <> Неопределено;
		ГруппаПолугодияВидимость = Форма.ВидыВыбираемыхПериодов.Найти("ПОЛУГОДИЕ") <> Неопределено;
		ВидимостьКомандыГод = Форма.ВидыВыбираемыхПериодов.Найти("ГОД") <> Неопределено;
	Иначе
		
		ГруппаМесяцыВидимость = Ложь;
		ГруппаКварталыВидимость = Ложь;
		ГруппаПолугодияВидимость = Ложь;
		ВидимостьКомандыГод = Ложь;
		
		Если Форма.РежимВыбораПериода = "МЕСЯЦ" Тогда
			
			ГруппаМесяцыВидимость = Истина;
			Форма.ВыбираемыйПериод = НачалоМесяца(Форма.ВыбираемыйПериод);
			
		ИначеЕсли Форма.РежимВыбораПериода = "КВАРТАЛ" Тогда
			
			ГруппаКварталыВидимость = Истина;
			НомерКвартала = Цел((Месяц(Форма.ВыбираемыйПериод) - 1) / 3 + 1);
			Форма.ВыбираемыйПериод = Дата(Год(Форма.ВыбираемыйПериод), (НомерКвартала - 1) * 3 + 1, 1);
			
		ИначеЕсли Форма.РежимВыбораПериода = "ПОЛУГОДИЕ" Тогда
			
			ГруппаПолугодияВидимость = Истина;
			Форма.ВыбираемыйПериод = Дата(Год(Форма.ВыбираемыйПериод), ?(Месяц(Форма.ВыбираемыйПериод) < 7, 1, 7), 1);
			
		КонецЕсли;
		
	КонецЕсли;
	
	УстановитьСвойствоЭлементаФормы(
		Форма.Элементы,
		"ГруппаМесяцы",
		"Видимость",
		ГруппаМесяцыВидимость);
	
	УстановитьСвойствоЭлементаФормы(
		Форма.Элементы,
		"ГруппаКварталы",
		"Видимость",
		ГруппаКварталыВидимость);
		
	УстановитьСвойствоЭлементаФормы(
		Форма.Элементы,
		"ГруппаПолугодия",
		"Видимость",
		ГруппаПолугодияВидимость);
		
	УстановитьСвойствоЭлементаФормы(
		Форма.Элементы,
		"ВыбираемыйПериод",
		"Видимость",
		Не ВидимостьКомандыГод);
	УстановитьСвойствоЭлементаФормы(
		Форма.Элементы,
		"КомандаГод",
		"Видимость",
		ВидимостьКомандыГод);
		
КонецПроцедуры


&НаКлиенте
Процедура УстановитьНевыбранныйЦветКнопок()

	Если РежимВыбораПериода = "МЕСЯЦ" Тогда
		ЧислоКнопок = 12;
		ПрефиксКоманды = "КомандаМесяц";
	ИначеЕсли РежимВыбораПериода = "КВАРТАЛ" Тогда
		ЧислоКнопок = 4;
		ПрефиксКоманды = "КомандаКвартал";
	ИначеЕсли РежимВыбораПериода = "ПОЛУГОДИЕ" Тогда
		ЧислоКнопок = 2;
		ПрефиксКоманды = "КомандаПолугодие";
	Иначе
		ЧислоКнопок = 1;
		ПрефиксКоманды = "КомандаГод";
	КонецЕсли;

	Для НомерПоПорядку = 1 По ЧислоКнопок Цикл
		Если РежимВыбораПериода = "ГОД" Тогда
			ЭлементКнопка = Элементы[ПрефиксКоманды];
		Иначе
			ФорматнаяСтрока = ?(РежимВыбораПериода = "МЕСЯЦ", "ЧЦ=2; ЧВН=", "ЧЦ=1");
			ЭлементКнопка = Элементы[ПрефиксКоманды + Формат(НомерПоПорядку, ФорматнаяСтрока)];
		КонецЕсли;
		
		Если ЭлементКнопка.ЦветФона <> ЦветФонаКнопки Тогда
			ЭлементКнопка.ЦветФона = ЦветФонаКнопки;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиентеНаСервере
Процедура УстановитьЗаголовокКомандеГод(Форма)

	Если Не Форма.ВыбиратьВидПериода
		ИЛИ Форма.ВидыВыбираемыхПериодов.Найти("ГОД") = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьСвойствоЭлементаФормы(
		Форма.Элементы,
		"КомандаГод",
		"Заголовок",
		Формат(Форма.ВыбираемыйПериод, "ДФ='гггг'"));

КонецПроцедуры

&НаКлиенте
Процедура ОбновитьОтображение()
	
	ПроверитьРежимВыбораПериода();
	
	Если РежимВыбораПериода = "МЕСЯЦ" Тогда
		
		КнопкаМесяца = Элементы["КомандаМесяц" + Формат(Месяц(ВыбираемыйПериод), "ЧЦ=2; ЧВН=")];
		Если КнопкаМесяца.ЦветФона <> ЦветФонаКнопкиВыбранногоПериода Тогда
			КнопкаМесяца.ЦветФона = ЦветФонаКнопкиВыбранногоПериода;
		КонецЕсли;
		
		ТекущийЭлемент = КнопкаМесяца;
		ПериодСтрокой = Формат(ВыбираемыйПериод, "ДФ='ММММ гггг'")
		
	ИначеЕсли РежимВыбораПериода = "КВАРТАЛ" Тогда
		
		КварталМесяца = (Месяц(ВыбираемыйПериод) - 1) / 3 + 1;
		КнопкаКвартала = Элементы["КомандаКвартал" + Формат(КварталМесяца, "ЧЦ=1")];
		
		Если КнопкаКвартала.ЦветФона <> ЦветФонаКнопкиВыбранногоПериода Тогда
			КнопкаКвартала.ЦветФона = ЦветФонаКнопкиВыбранногоПериода;
		КонецЕсли;
		
		ТекущийЭлемент = КнопкаКвартала;
		ПериодСтрокой = Формат(КварталМесяца, "ЧЦ=1") + " " + НСтр("ru = 'квартал'") + " " + Формат(ВыбираемыйПериод,"ДФ=гггг");
		
	ИначеЕсли РежимВыбораПериода = "ПОЛУГОДИЕ" Тогда
		
		Если Месяц(ВыбираемыйПериод) = 1 Тогда
			Элементы.КомандаПолугодие1.ЦветФона = ЦветФонаКнопкиВыбранногоПериода;
			ПериодСтрокой = НСтр("ru = '1 полугодие'") + " " + Формат(ВыбираемыйПериод,"ДФ=гггг");
		Иначе
			Элементы.КомандаПолугодие2.ЦветФона = ЦветФонаКнопкиВыбранногоПериода;
			ПериодСтрокой = НСтр("ru = '2 полугодие'") + " " + Формат(ВыбираемыйПериод,"ДФ=гггг");
		КонецЕсли;
		
	Иначе
		Элементы.КомандаГод.ЦветФона = ЦветФонаКнопкиВыбранногоПериода;
		ПериодСтрокой = Формат(ВыбираемыйПериод, "ДФ='гггг'")
	КонецЕсли;
	
	УстановитьЗаголовокКомандеГод(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьВыбираемыйПериод(Год, Месяц, РежимВыбора = "")
	
	Если ОтмеченныйПериод = Дата(Год, Месяц, 1)
		И НЕ ИзменилсяГод 
		И РежимВыбораПериода = РежимВыбора Тогда
		
		ВыполнитьВыбор();
	КонецЕсли; 
	
	Если ЗначениеЗаполнено(РежимВыбора) Тогда
		УстановитьНевыбранныйЦветКнопок();
		РежимВыбораПериода = РежимВыбора;
	КонецЕсли;
	
	Если Год < 1 Тогда
		Год = 1;
	КонецЕсли; 
	
	ИзменилсяГод = Ложь;
	ВыбираемыйПериод = Дата(Год, Месяц, 1);
	
	ОбновитьОтображение();
	
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьВыбор()
	
	Если ВыбиратьВидПериода Тогда
		ТолстаяДата = Новый Структура("Период, Горизонт", ВыбираемыйПериод, РежимВыбораПериода);
		Закрыть(ТолстаяДата);
	Иначе
		Закрыть(ВыбираемыйПериод);
	КонецЕсли;
	
КонецПроцедуры

// Устанавливает свойство ИмяСвойства элемента формы с именем ИмяЭлемента в значение Значение.
// Применяется в тех случаях, когда элемента формы может не быть на форме из-за отсутствия прав у пользователя
// на объект, реквизит объекта или команду.
//
// Параметры:
//  ЭлементыФормы - ВсеЭлементыФормы
//                - ЭлементыФормы - коллекция элементов управляемой формы.
//  ИмяЭлемента   - Строка       - имя элемента формы.
//  ИмяСвойства   - Строка       - имя устанавливаемого свойства элемента формы.
//  Значение      - Произвольный - новое значение элемента.
// 
&НаСервере
Процедура УстановитьСвойствоЭлементаФормы(ЭлементыФормы, ИмяЭлемента, ИмяСвойства, Значение) 
	
	ЭлементФормы = ЭлементыФормы.Найти(ИмяЭлемента);
	Если ЭлементФормы <> Неопределено И ЭлементФормы[ИмяСвойства] <> Значение Тогда
		ЭлементФормы[ИмяСвойства] = Значение;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти   

