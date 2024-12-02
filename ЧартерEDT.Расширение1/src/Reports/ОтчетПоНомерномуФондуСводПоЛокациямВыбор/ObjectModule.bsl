
Procedure OnComposeResult(ResultDocument, DetailsData, StandardProcessing)
	
	ПараметрCheckOutDate = Новый ПараметрКомпоновкиДанных("CheckOutDate");
	ЗначениеCheckOutDate = ТекущаяДатаСеанса();
    КомпоновщикНастроек.Настройки.ПараметрыДанных.УстановитьЗначениеПараметра(ПараметрCheckOutDate, ЗначениеCheckOutDate);
	
	//СтатусРазмещения = Новый ПараметрКомпоновкиДанных("AccommodationStatus");
	//ЗначениеСтатуса = Справочники.AccommodationStatuses.НайтиПоКоду("10");
	//КомпоновщикНастроек.Настройки.ПараметрыДанных.УстановитьЗначениеПараметра(СтатусРазмещения, ЗначениеСтатуса);
	
EndProcedure
