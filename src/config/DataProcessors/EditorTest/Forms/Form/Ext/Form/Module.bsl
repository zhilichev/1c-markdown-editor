
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	MarkdownEditor.Constructor(ThisObject, Items.DefaultGroup);
	
EndProcedure

#Region AttachableHandlersOfMarkdownEditor

&AtClient
Procedure Attachable_MarkdownEditorSwitchMode()
	
	MarkdownEditorClient.SwitchMode(ThisObject);
	
EndProcedure

#EndRegion