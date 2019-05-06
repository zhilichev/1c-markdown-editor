
&AtClient
Procedure InsertLInk(Command)
	
	Result = New Structure;
	Result.Insert("Address", Address);
	Result.Insert("Title", LinkTitle);
	
	Close(Result);
	
EndProcedure
