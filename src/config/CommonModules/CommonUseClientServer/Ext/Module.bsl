#Region Interface

Function ArrayToMultilineText(Val Array) Export

	Return StrConcat(Array, Chars.LF);

EndFunction

// Создает объект ОписаниеТипов, содержащий тип Дата.
//
// Параметры:
//  СоставДаты - ЧастиДаты - состав даты (время/дата/дата и время).
//
// Возвращаемое значение:
//  ОписаниеТипов. Описание типа Дата.
//
Function GetDateTypeDescription(Val DatePart = Undefined) Export
	
	If DatePart = Undefined Then
		DatePart = DateFractions.DateTime;
	EndIf;
	
	Return New TypeDescription("Date", , , New DateQualifiers(DatePart));
	
EndFunction

// Создает объект ОписаниеТипов, содержащий тип Строка.
//
// Параметры:
//  ДлинаСтроки - Число - длина строки.
//
// Возвращаемое значение:
//  ОписаниеТипов. Описание типа Строка.
//
Function GetStringTypeDescription(Val StrLen) Export
	
	StrQualifier = New StringQualifiers(StrLen, AllowedLength.Variable);
	
	Return New TypeDescription("String", , StrQualifier);
	
EndFunction

// Создает объект ОписаниеТипов, содержащий тип Число.
//
// Параметры:
//  Разрядность             - Число - общее количество разрядов числа (количество 
//                            разрядов целой части + количество разрядов дробной 
//                            части).
//  РазрядностьДробнойЧасти - Число - количество разрядов дробной части.
//  ДопустимыйЗнак          - ДопустимыйЗнак - допустимый знак числа.
//
// Возвращаемое значение:
//  ОписаниеТипов. Описание типа Число.
//
Function GetNumberTypeDescription(Val Digits, Val FractionDigits = 0, Val AllowedSign = Undefined) Export
	
	If AllowedSign = Undefined Then
		NumberQualifier = New NumberQualifiers(Digits, FractionDigits);
	Else
		NumberQualifier = New NumberQualifiers(Digits, FractionDigits, AllowedSign);
	EndIf;
	
	Return New TypeDescription("Number", NumberQualifier);
	
EndFunction

Function MultilineTextToArray(Val Text) Export
	
	TextLines = StrSplit(Text, Chars.LF, True);
	
	Return TextLines;
	
EndFunction

#EndRegion