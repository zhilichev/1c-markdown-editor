
#Region FormCommandsEventHandlers

&AtClient
Procedure InsertLink(Command)
	
	Result = New Structure;
	Result.Insert("URL", ImageURL);
	Result.Insert("AltText", AltText);
	
	Close(Result);
	
EndProcedure

#EndRegion