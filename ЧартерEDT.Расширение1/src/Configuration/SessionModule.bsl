
&After("SessionParametersSetting")
Procedure Расш1_SessionParametersSetting()
	
	Query = New Query;
	Query.Text = 
	"ВЫБРАТЬ
	|	СоставНомерногоФонда.Номер КАК Ссылка
	|ИЗ
	|	РегистрСведений.Расш1_СоставНомерногоФонда КАК СоставНомерногоФонда
	|ГДЕ
	|	СоставНомерногоФонда.НомернойФонд В
	|			(ВЫБРАТЬ
	|				PermissionGroupsДоступныеНомерныеФонды.НомернойФонд КАК НомернойФонд
	|			ИЗ
	|				Catalog.Employees КАК Employees
	|					ВНУТРЕННЕЕ СОЕДИНЕНИЕ Catalog.PermissionGroups.ДоступныеНомерныеФонды КАК PermissionGroupsДоступныеНомерныеФонды
	|					ПО
	|						Employees.PermissionGroup = PermissionGroupsДоступныеНомерныеФонды.Ссылка
	|			ГДЕ
	|				Employees.Ссылка = &Ref)";
	
	Query.SetParameter("Ref", SessionParameters.CurrentUser);
	
	QueryResult = Query.Execute();
	
	Массив =  QueryResult.Выгрузить().ВыгрузитьКолонку("Ссылка");
	Массив.Add(Catalogs.Rooms.EmptyRef());
	
	SessionParameters.ДоступныеНомера = Новый ФиксированныйМассив(Массив);
	SessionParameters.ВсеНомераДоступны = РольДоступна("Administrator");
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	PermissionGroups.Ссылка КАК Ref
	|ИЗ
	|	Справочник.Employees КАК Employees
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.PermissionGroups КАК PermissionGroups
	|		ПО Employees.PermissionGroup = PermissionGroups.Ссылка
	|ГДЕ
	|	Employees.Ссылка = &Ref
	|	И PermissionGroups.Наименование = &Description";
	
	Запрос.УстановитьПараметр("Ref", SessionParameters.CurrentUser);
	Запрос.УстановитьПараметр("Description", "Оператор АСЭ");
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если Не РезультатЗапроса.Пустой() Тогда
		SessionParameters.ВсеНомераДоступны = Истина;
	КонецЕсли;
	
EndProcedure
