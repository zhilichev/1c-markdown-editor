
&AtClient
Procedure InsertLink(Command)
	
	Result = New Structure;
	Result.Insert("Address", Address);
	Result.Insert("LinkText", LinkText);
	Result.Insert("Title", LinkTitle);
	
	Close(Result);
	
EndProcedure
