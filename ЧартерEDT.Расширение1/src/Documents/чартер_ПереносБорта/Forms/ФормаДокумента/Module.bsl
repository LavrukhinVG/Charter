#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Ключ.Пустая() Тогда

		ЗаполнитьЗначенияСвойств(Объект, Параметры);			
			
	КонецЕсли; 
			
	Объект.Исполнитель 		   = SessionParameters.CurrentUser;
	Объект.ДатаИзменения 	   = ТекущаяДатаСеанса();
		
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	
	Если ЗавершениеРаботы Тогда
		Возврат;	
	КонецЕсли; 
	
	Оповестить("ИзмененияСпискаРегистрации");
	
КонецПроцедуры

#КонецОбласти  

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура КонечныйРейсНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
    // При переносе не давать выбирать "архивные" Рейсы
	ЗадатьПараметрыВыбораРейса();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ЗадатьПараметрыВыбораРейса()
	
	Перем ПерПараметрыВыбора, Параметр;
	
	ПерПараметрыВыбора = Новый Массив();
	Параметр = Новый ПараметрВыбора("Отбор.Архив", Ложь);	
	ПерПараметрыВыбора.Добавить(Параметр);
	
	Элементы.КонечныйРейс.ПараметрыВыбора = Новый ФиксированныйМассив(ПерПараметрыВыбора);
	
КонецПроцедуры 

#КонецОбласти  
