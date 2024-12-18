#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	
	КоличествоМест = 290;
	ТипВС = Перечисления.чартер_ТипВСРассадка.Boeing763_290PAX;
	Багаж = 30;
	
	ЗаполнитьКвотированиеРейса();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ЗаполнитьКвотированиеРейса() 
	
	Квотирование.Очистить();
	
	ПараметрыКвотирования = Новый Структура;
	ПараметрыКвотирования.Вставить("ДатаРейса", ДатаРейса); 
	ПараметрыКвотирования.Вставить("ТипВС", ТипВС);
	
	КвотыЗаПериод = РегистрыСведений.чартер_КвотированиеОрганизацийНаРейс.ПолучитьКвотыЗаПериод(ПараметрыКвотирования);
	
	Если Не КвотыЗаПериод = Неопределено Тогда

		Выборка = КвотыЗаПериод.Выбрать();
		Пока Выборка.Следующий() Цикл
			НоваяСтрока = Квотирование.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока, Выборка);
		КонецЦикла;
		
	КонецЕсли;			
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли
