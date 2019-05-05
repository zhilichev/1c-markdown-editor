
&AtClient
Procedure EnterHyperlink(Command)
	
	Result = New Structure;
	Result.Insert("Address", Address);
	Result.Insert("Title", LinkTitle);
	
	Close(Result);
	
EndProcedure
