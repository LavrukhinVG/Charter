
#Область ОбработчикиКомандФормы

&AtClient
Procedure Command1(Command)
	ВыполнитьНаСервере();
EndProcedure

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ВыполнитьНаСервере()
	
	Запрос = Новый Запрос;
	Запрос.Текст = "SELECT
	|	чартер_Сотрудники.Ref AS Ссылка
	|FROM
	|	Catalog.чартер_Сотрудники AS чартер_Сотрудники
	|WHERE
	|	НЕ чартер_Сотрудники.UUIDЗУП = """"
	|	И НЕ
	|		чартер_Сотрудники.СтатусСотрудникаВОрганизации = ЗНАЧЕНИЕ(ПЕРЕЧИСЛЕНИЕ.чартер_СтатусСотрудникаВОрганизации.Сотрудник)";
	
	РезультатЗапроса = Запрос.Выполнить();
	Выборка = РезультатЗапроса.Выбрать();
	Пока Выборка.Следующий() Цикл
		СпрОбъект = Выборка.Ссылка.ПОлучитьОбъект();
		СпрОбъект.СтатусСотрудникаВОрганизации = Перечисления.чартер_СтатусСотрудникаВОрганизации.Сотрудник;
		СпрОбъект.Записать();
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти
