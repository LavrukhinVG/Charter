#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	Движения.чартер_КвотированиеОрганизацийНаРейс.Записывать = Истина;
	Движения.чартер_КвотированиеОрганизацийНаРейс.Очистить();
	
	Для Каждого СтрокаКвоты Из Квоты Цикл
		
		Движение = Движения.чартер_КвотированиеОрганизацийНаРейс.Добавить();
		
		Движение.Регистратор = Ссылка;
		Движение.Период = ПериодРегистрации;
		ЗаполнитьЗначенияСвойств(Движение, ЭтотОбъект);
		ЗаполнитьЗначенияСвойств(Движение, СтрокаКвоты);
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
				   |	чартер_ТипВСРассадка.Ссылка КАК ТипКомпановки,
				   |    0 КАК Квота
				   |ИЗ
				   |	Перечисление.чартер_ТипВСРассадка КАК чартер_ТипВСРассадка";

	РезультатЗапроса = Запрос.Выполнить();
	Квоты.Загрузить(РезультатЗапроса.Выгрузить());

КонецПроцедуры
#КонецОбласти

#Иначе
ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли