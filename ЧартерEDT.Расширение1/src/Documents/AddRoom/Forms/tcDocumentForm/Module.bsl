
&After("PostDocument")
Procedure Расш1_PostDocument()
	
	МенеджерЗаписи = РегистрыСведений.Расш1_СоставНомерногоФонда.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.Номер = Object.Room;
	МенеджерЗаписи.Записать();
	
EndProcedure
