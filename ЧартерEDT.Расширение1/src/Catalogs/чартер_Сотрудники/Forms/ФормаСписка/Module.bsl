#Область ОбработчикиСобытийФормы

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
    Если ИмяСобытия = "ОбновлениеСотрудниковЗУП" Тогда
		Элементы.Список.Обновить();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ЗагрузитьСотрудников(Команда)
	
	ОткрытьФорму("Обработка.чартер_ЗагрузкаСотрудниковИзЗУП.Форма", , , , , , 
								, РежимОткрытияОкнаФормы.БлокироватьВесьИнтерфейс);		
	
КонецПроцедуры

#КонецОбласти