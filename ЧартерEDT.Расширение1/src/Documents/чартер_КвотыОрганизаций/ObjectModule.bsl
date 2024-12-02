
#Область ОбработчикиСобытий

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	Движения.чартер_КвотированиеОрганизацийНаРейс.Записывать = Истина;
	Движения.чартер_КвотированиеОрганизацийНаРейс.Очистить();
	
	Для Каждого СтрокаКвоты Из Квоты Цикл
		
		Движение = Движения.чартер_КвотированиеОрганизацийНаРейс.Добавить();
		
		Движение.Регистратор = Ссылка;
		Движение.Период = Ссылка.ПериодРегистрации;
		ЗаполнитьЗначенияСвойств(Движение, ЭтотОбъект);
		ЗаполнитьЗначенияСвойств(Движение, СтрокаКвоты);
		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти