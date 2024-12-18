#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

// Обработка данных из файла загрузки и загрузка их в ТЧ
//
// Параметры:     
// 	АдресХранилища - ХранилищеЗначений - адрес загружаемого файла во временном хранилище
//
Процедура ВыгрузитьДанныеДляПредпросмотра(АдресХранилища) Экспорт	
	
	ДанныеДляЗагрузки.Очистить();
	
	ТЗСотрудники = чартеры_ОбщиеПроцедурыИФункцииСервер.ПрочитатьТабличныйДокументИзВФ(АдресХранилища);	

	Запрос = Новый Запрос;
	Запрос.Текст = ПолучитьЗапросПоискСотрудников();
	Запрос.УстановитьПараметр("СотрудникиИзФайла", ТЗСотрудники); 
	
    МассивРезультатов = Запрос.ВыполнитьПакет();
	
	// Добавим в ТЧ сотрудников по которым ФИО совпало
	Если НЕ МассивРезультатов[2].Пустой() Тогда
		ЗаполнитьТЧПоНайденнымСотрудникам(МассивРезультатов[2]);
	КонецЕсли;
	
	// Попробуем поискать сотрудников по вторичным полям
	Если НЕ МассивРезультатов[3].Пустой() Тогда
		
		МассивТН = Новый Массив;
		
		Выборка = МассивРезультатов[3].Выбрать();
		Пока Выборка.Следующий() Цикл  			
			МассивТН.Добавить(СтрЗаменить(Выборка.ТабельныйНомерФайл, Символ(160), ""));						
		КонецЦикла;
		СотрудникиНайденныеПоТабельнымНомерам = НайтиСотрудниковПоТН(МассивТН);
		Если НЕ СотрудникиНайденныеПоТабельнымНомерам = Неопределено Тогда
			ЗаполнитьТЧПоНайденнымСотрудникам(СотрудникиНайденныеПоТабельнымНомерам);
		КонецЕсли;
	КонецЕсли;	
		
КонецПроцедуры

#КонецОбласти 

#Область СлужебныеПроцедурыИФункции

Procedure ЗаполнитьТЧПоНайденнымСотрудникам(СписокСотрудников)
	
	Выборка = СписокСотрудников.Выбрать();
	Пока Выборка.Следующий() Цикл 
		
		НоваяСтрока = ДанныеДляЗагрузки.Добавить();		
		НоваяСтрока.Организация = Выборка.Организация;
		НоваяСтрока.ТабельныйНомер = СтрЗаменить(Выборка.ТабельныйНомерФайл, Символ(160), "");
		НоваяСтрока.Должность = Выборка.ДолжностьФайл;
		НоваяСтрока.ФИО = Выборка.ФИОФайл;
		НоваяСтрока.Подразделение = Выборка.ПодразделениеФайл;
		НоваяСтрока.НомерТелефона = Выборка.НомерТелефонаФайл; 		
		Если Не Выборка.ПричиныВылета = "" Тогда		
			НоваяСтрока.ПричиныВылета = Выборка.ПричиныВылета;
		Иначе
			чартеры_ОбщиеПроцедурыИФункцииСервер.СообщитьПользователю("Не заполнена причина вылета у сотрудника : " 
			+ Выборка.ФИОФайл); 
			НоваяСтрока.ПричиныВылета = "";			
		КонецЕсли;			
		НоваяСтрока.СотрудникЗУП = Выборка.СотрудникЗУП;
		НоваяСтрока.СотрудникНайден = Выборка.СотрудникНайден;
					
	КонецЦикла;

EndProcedure 

Функция НайтиСотрудниковПоТН(МассивТН)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	чартер_Сотрудники.Наименование КАК ФИОФайл,
	               |	чартер_Сотрудники.UUIDЗУП КАК СотрудникЗУП,
	               |	чартер_Сотрудники.Организация КАК Организация,
	               |	чартер_Сотрудники.ТабельныйНомер КАК ТабельныйНомерФайл,
	               |	чартер_Сотрудники.Должность КАК ДолжностьФайл,
	               |	чартер_Сотрудники.Подразделение КАК ПодразделениеФайл,
	               |	чартер_Сотрудники.Телефон КАК НомерТелефонаФайл,
	               |	ИСТИНА КАК СотрудникНайден
	               |ИЗ
	               |	Справочник.чартер_Сотрудники КАК чартер_Сотрудники
	               |ГДЕ
	               |	НЕ чартер_Сотрудники.ПометкаУдаления
	               |	И чартер_Сотрудники.ТабельныйНомер В (чартер_Сотрудники.ТабельныйНомер)";
	
	Запрос.УстановитьПараметр("ТН", МассивТН);
	
	Возврат Запрос.Выполнить().Выбрать();
	
КонецФункции

Функция ПолучитьЗапросПоискСотрудников()

	ЗапросТекст = "ВЫБРАТЬ
	              |	СотрудникиИзФайла.Организация КАК Организация,
	              |	СотрудникиИзФайла.ТабельныйНомер КАК ТабельныйНомер,
	              |	СотрудникиИзФайла.ФИО КАК ФИО,
	              |	СотрудникиИзФайла.Должность КАК Должность,
	              |	СотрудникиИзФайла.Отдел КАК Отдел,
	              |	СотрудникиИзФайла.НомерТелефона КАК НомерТелефона,
	              |	СотрудникиИзФайла.ПричиныВылета КАК ПричиныВылета
	              |ПОМЕСТИТЬ втСотрудникиКЗагрузке
	              |ИЗ
	              |	&СотрудникиИзФайла КАК СотрудникиИзФайла
	              |
	              |ИНДЕКСИРОВАТЬ ПО
	              |	ФИО
	              |;
	              |
	              |////////////////////////////////////////////////////////////////////////////////
	              |ВЫБРАТЬ
	              |	ВЫБОР
	              |		КОГДА чартер_Сотрудники.Наименование = втСотрудникиКЗагрузке.ФИО
	              |			ТОГДА ИСТИНА
	              |		ИНАЧЕ ЛОЖЬ
	              |	КОНЕЦ КАК СотрудникНайден,
	              |	втСотрудникиКЗагрузке.Организация КАК ОрганизацияФайл,
	              |	втСотрудникиКЗагрузке.ТабельныйНомер КАК ТабельныйНомерФайл,
	              |	втСотрудникиКЗагрузке.ФИО КАК ФИОФайл,
	              |	втСотрудникиКЗагрузке.Должность КАК ДолжностьФайл,
	              |	втСотрудникиКЗагрузке.Отдел КАК ПодразделениеФайл,
	              |	втСотрудникиКЗагрузке.НомерТелефона КАК НомерТелефонаФайл,
	              |	втСотрудникиКЗагрузке.ПричиныВылета КАК ПричиныВылета,
	              |	чартер_Сотрудники.Ссылка КАК СотрудникЗУП,
	              |	чартер_Сотрудники.Организация КАК Организация,
	              |	чартер_Сотрудники.ТабельныйНомер КАК ТабельныйНомер,
	              |	чартер_Сотрудники.Должность КАК Должность,
	              |	чартер_Сотрудники.Подразделение КАК Подразделение
	              |ПОМЕСТИТЬ втСотрудникиПослеСравнения
	              |ИЗ
	              |	втСотрудникиКЗагрузке КАК втСотрудникиКЗагрузке
	              |		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.чартер_Сотрудники КАК чартер_Сотрудники
	              |		ПО втСотрудникиКЗагрузке.ФИО = чартер_Сотрудники.Наименование
	              |ГДЕ
	              |	НЕ чартер_Сотрудники.ПометкаУдаления
	              |;
	              |
	              |////////////////////////////////////////////////////////////////////////////////
	              |ВЫБРАТЬ
	              |	втСотрудникиПослеСравнения.СотрудникНайден КАК СотрудникНайден,
	              |	втСотрудникиПослеСравнения.ОрганизацияФайл КАК ОрганизацияФайл,
	              |	втСотрудникиПослеСравнения.ТабельныйНомерФайл КАК ТабельныйНомерФайл,
	              |	втСотрудникиПослеСравнения.ФИОФайл КАК ФИОФайл,
	              |	втСотрудникиПослеСравнения.ДолжностьФайл КАК ДолжностьФайл,
	              |	втСотрудникиПослеСравнения.ПодразделениеФайл КАК ПодразделениеФайл,
	              |	втСотрудникиПослеСравнения.НомерТелефонаФайл КАК НомерТелефонаФайл,
	              |	втСотрудникиПослеСравнения.ПричиныВылета КАК ПричиныВылета,
	              |	втСотрудникиПослеСравнения.СотрудникЗУП КАК СотрудникЗУП,
	              |	втСотрудникиПослеСравнения.Организация КАК Организация,
	              |	втСотрудникиПослеСравнения.ТабельныйНомер КАК ТабельныйНомер,
	              |	втСотрудникиПослеСравнения.Должность КАК Должность,
	              |	втСотрудникиПослеСравнения.Подразделение КАК Подразделение
	              |ИЗ
	              |	втСотрудникиПослеСравнения КАК втСотрудникиПослеСравнения
	              |ГДЕ
	              |	втСотрудникиПослеСравнения.СотрудникНайден
	              |;
	              |
	              |////////////////////////////////////////////////////////////////////////////////
	              |ВЫБРАТЬ
	              |	втСотрудникиПослеСравнения.СотрудникНайден КАК СотрудникНайден,
	              |	втСотрудникиПослеСравнения.ОрганизацияФайл КАК ОрганизацияФайл,
	              |	втСотрудникиПослеСравнения.ТабельныйНомерФайл КАК ТабельныйНомерФайл,
	              |	втСотрудникиПослеСравнения.ФИОФайл КАК ФИОФайл,
	              |	втСотрудникиПослеСравнения.ДолжностьФайл КАК ДолжностьФайл,
	              |	втСотрудникиПослеСравнения.ПодразделениеФайл КАК ПодразделениеФайл,
	              |	втСотрудникиПослеСравнения.НомерТелефонаФайл КАК НомерТелефонаФайл,
	              |	втСотрудникиПослеСравнения.ПричиныВылета КАК ПричиныВылета,
	              |	втСотрудникиПослеСравнения.СотрудникЗУП КАК СотрудникЗУП,
	              |	втСотрудникиПослеСравнения.Организация КАК Организация,
	              |	втСотрудникиПослеСравнения.ТабельныйНомер КАК ТабельныйНомер,
	              |	втСотрудникиПослеСравнения.Должность КАК Должность,
	              |	втСотрудникиПослеСравнения.Подразделение КАК Подразделение
	              |ИЗ
	              |	втСотрудникиПослеСравнения КАК втСотрудникиПослеСравнения
	              |ГДЕ
	              |	НЕ втСотрудникиПослеСравнения.СотрудникНайден";
	              
	Возврат ЗапросТекст;
	
КонецФункции

#КонецОбласти   

#Иначе
ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли