
#Region Interface

Procedure Constructor(Form, OwnerGroup) Export
	
	InitFormData(Form, OwnerGroup);
	
EndProcedure

#EndRegion

#Region InternalProceduresAndFunctions

Procedure InitFormData(Form, OwnerGroup)
	
	// Создаваемые команды формы
	Var NewCommands;
	
	// Создание дополнительных реквизитов формы
	CreateFormAttributes(Form);
	
	// Создание дополнительных команд формы
	CreateFormCommands(Form, NewCommands);
	
	// Создание элементов формы редактора
	CreateFormItems(Form, OwnerGroup, NewCommands);
	
EndProcedure

Procedure CreateFormAttributes(Form)
	
	// Программное создание необходимых реквизитов на форме
	
	// Реквизит MarkdownEditor_EditMode хранит состояние редактора:
	// - True - включен редактор;
	// - False - включен режим просмотра.
	EditorMode = New FormAttribute("MarkdownEditor_EditMode",
		New TypeDescription("Boolean"));
		
	// Реквизит MarkdownEditor_SimpleText хранит редактируемый текст
	MarkdownText = New FormAttribute("MarkdownEditor_SimpleText", 
		New TypeDescription("String"), , , True);
		
	// Реквизит MarkdownEditor_HTMLText хранит преобразованный текст в HTML-код
	HTMLText = New FormAttribute("MarkdownEditor_HTMLText", New TypeDescription("String"));
		
	NewAttributes = New Array;
	NewAttributes.Add(EditorMode);
	NewAttributes.Add(MarkdownText);
	NewAttributes.Add(HTMLText);
	
	Form.ChangeAttributes(NewAttributes);
	
	// Установка значений новых реквизитов формы
	Form["MarkdownEditor_EditMode"] = True;	
	
EndProcedure

Procedure CreateFormCommands(Form, NewCommands)
	
	// Программное создание команд
	NewCommands = New Structure;
	
	// Команда переключения режима редактора
	Command = Form.Commands.Add("MarkdownEditor_SwitchMode");
	Command.Action         = "Attachable_MarkdownEditorSwitchMode";
	Command.Picture        = PictureLib.ViewMode;
	Command.Representation = ButtonRepresentation.Picture;
	Command.ToolTip        = "Переключить редактор в режим редактирования или просмотра результата";
	Command.Shortcut       = New Shortcut(Key.V, True, False, True);
	
	NewCommands.Insert("SwitchMode", Command.Name);	
	
EndProcedure

////////////////////////////////////////////////////////////////////////////////
// Процедуры и функции создания элементов формы редактора

Procedure CreateFormItems(Form, OwnerGroup, Commands)
	
	Items = Form.Items;
	
	// Создание общей группы, на которой будут размещены все элементы редактора
	MainGroup = Items.Add("MarkdownEditor_MainGroup", Type("FormGroup"), OwnerGroup);
	MainGroup.Type      = FormGroupType.UsualGroup;
	MainGroup.Group     = ChildFormItemsGroup.Vertical;
	MainGroup.ShowTitle = False;
	
#Region ЗаполнениеОсновнойКоманднойПанели
	
	// Главная командная панель управления редактором
	MainCommandBar = Items.Add("MarkdownEditor_MainCommandBar", 
		Type("FormGroup"), MainGroup);
		
	MainCommandBar.Type = FormGroupType.CommandBar;
	MainCommandBar.HorizontalStretch = True;
	
	// Группа кнопок отображения кнопки переключения режимов "редактор" / "просмотр"
	ModeButtonsGroup = Items.Add("MarkdownEditor_ModeButtonsGroup", Type("FormGroup"),
		MainCommandBar);
		
	ModeButtonsGroup.Type = FormGroupType.ButtonGroup;
	
	// Кнопка переключения режима редактора
	SwitchModeButton = Items.Add("MarkdownEditor_SwitchModeButton",
		Type("FormButton"), ModeButtonsGroup);
		
	SwitchModeButton.CommandName = Commands.SwitchMode;
	
#EndRegion

#Region СозданиеРедактораТекста

	// Создание текстового поля для редактирования простого текста
	EditorTextField = Items.Add("MarkdownEditor_EditorField", Type("FormField"),
		MainGroup);
		
	EditorTextField.DataPath = "MarkdownEditor_SimpleText";
	EditorTextField.Type = FormFieldType.InputField;
	
	EditorTextField.AutoMaxWidth = False;
	EditorTextField.AutoMaxHeight = False;	
	EditorTextField.MultiLine = True;
	EditorTextField.TitleLocation = FormItemTitleLocation.None;
	EditorTextField.ExtendedEdit = True;
	EditorTextField.HorizontalStretch = True;
	EditorTextField.VerticalStretch = True;	

#EndRegion

#Region СозданиеПросмотрщикаMarkdown

	// Создание поля HTML-документа для просмотра результата
	HTMLViewerField = Items.Add("MarkdownEditor_HTMLViewerField", Type("FormField"), 
		MainGroup);
	
	HTMLViewerField.DataPath = "MarkdownEditor_HTMLText";
	HTMLViewerField.Type = FormFieldType.HTMLDocumentField;
	HTMLViewerField.TitleLocation = FormItemTitleLocation.None;
	
	HTMLViewerField.AutoMaxWidth = False;
	HTMLViewerField.AutoMaxHeight = False;	
	HTMLViewerField.HorizontalStretch = True;
	HTMLViewerField.VerticalStretch = True;	
	
	// TODO: Написать обработчик нажатия
	//HTMLViewerField.SetAction("OnClick", "Attachable_MarkdownEditonOnHTMLFieldClick");

#EndRegion
	
EndProcedure

#EndRegion