
'
' Editor for Blitzmax
'

SuperStrict

Framework wx.wxApp

'Import wx.wxAUI
Import wx.wxFlatNotebook
Import wx.wxComboBox
Import wx.wxFrame
Import wx.wxListCtrl
Import wx.wxLocale
Import wx.wxChoice
Import wx.wxMenu
Import wx.wxMenuBar
Import wx.wxPanel
Import wx.wxScrolledWindow
Import wx.wxStaticLine
Import wx.wxStaticText
Import wx.wxStatusBar
Import wx.wxTextCtrl
Import wx.wxWindow
Import wx.wxDialog
Import wx.wxAboutBox
Import wx.wxCheckListBox
Import wx.wxArtProvider

Import wx.wxScintilla
Import wx.wxHtmlWindow
Import wx.wxFileSystem
Import wx.wxInternetFSHandler

Import brl.standardio
Import brl.random
Import brl.linkedlist
Import brl.retro

?Win32
'Import "manifest\rc_32.o"
?

'---------------------------------
'Application info
'---------------------------------
Const APP_TITLE:String = "Editor"
Const APP_VERSION:String = "0.1.1"	' 
'----------------------------------


Global COLOUR_BACK:wxColour = New wxColour.Create(51, 68, 85)
Global COLOUR_FRONT:wxColour = New wxColour.Create(240, 240, 240)

'Graphics imports
'Incbin "manifest\new.ico"
'Incbin "manifest\new_window.ico"
Incbin "graphics\app.png"
Incbin "graphics\new.png"
Incbin "graphics\open.png"
Incbin "graphics\close.png"
Incbin "graphics\save.png"

Const userID_NEW:Int = wxID_HIGHEST + 1
Const userID_OPEN:Int = wxID_HIGHEST + 2
Const userID_CLOSE:Int = wxID_HIGHEST + 3
Const userID_SAVE:Int = wxID_HIGHEST + 4

Const menuID_QUIT:Int = wxID_HIGHEST + 101
Const menuID_HELP:Int = wxID_HIGHEST + 401
Const menuID_ABOUT:Int = wxID_HIGHEST + 402

'Const listID_FILTER_WEEK:Int	= wxID_HIGHEST + 20

'Const FLAGS_DEFAULT:Int = 0, FLAGS_OPEN:Int = 1, FLAGS_EDIT:Int = 2

Global globalUser:String = getenv_("USERNAME").ToUpper().Trim()
Global globalUserShort:String = globalUser[..3]
Global globalTempDir:String = getenv_("TEMP") + "\"


'*** Run application
New TApp.run()

Type TApp Extends wxApp
	
	Field myprov:ArtProvider = ArtProvider(New ArtProvider.Create() )
	
	Global myframe:wxFrame
	Global myWin:TWindow
	Global myHelpFrame:wxFrame
	Global myHelpWin:wxHtmlWindow
	
	Const MAX_HEIGHT:Int = 800
	Const MAX_WIDTH:Int = 1000
	
	Method OnInit:Int()
		
		' Required For HTML help (.zip/.hfb)
		'wxFileSystem.AddHandler(New wxZipFSHandler)
		wxFileSystem.AddHandler(New wxInternetFSHandler)
		
		wxInitAllImageHandlers()
		wxArtProvider.Push(myprov)
		
		'Check max window size
		Local x:Int, y:Int, width:Int, height:Int
		wxClientDisplayRect(x, y, width, height)
		
		'Local width:Int = DesktopWidth(), height:Int = (DesktopHeight() - 100)
		
		If height > MAX_HEIGHT Then height = MAX_HEIGHT
		If width > MAX_WIDTH Then width = MAX_WIDTH
		
		DebugLog height + " | " + width
		
		' Add frame creation code here
		myframe	= wxFrame(New wxFrame.Create(Null, wxID_ANY, APP_TITLE + "   Ver." + APP_VERSION, - 1, - 1, width, height, wxDEFAULT_FRAME_STYLE | wxTAB_TRAVERSAL) )
		'myframe.SetForegroundColour(wxSystemSettings.GetColour(wxSYS_COLOUR_WINDOW) )
		myframe.SetBackgroundColour(New wxColour.Create(255, 255, 200) )
		
		'Local icon:wxIcon = New wxIcon.Create()
		'icon.LoadFile("graphics/icon.ico", wxBITMAP_TYPE_ICO)
		'If Not icon.IsOk() Then Throw("Can't load 'Icon.ico'")
		
		myframe.SetIcon( wxIcon.CreateFromFile("incbin::graphics\app.png", wxBITMAP_TYPE_PNG)  )
		'myframe.SetIcon( wxIcon.CreateFromFile("graphics\icon.png", wxBITMAP_TYPE_PNG) )
		
		'Create help window
		'myHelpFrame = wxFrame(New wxFrame.Create(Null, wxID_ANY, "TranslatorX Ohje", - 1, - 1, width, height, wxDEFAULT_FRAME_STYLE | wxTAB_TRAVERSAL) )
		'myHelpWin = New wxHtmlWindow.Create(myHelpFrame, -1)
		'myHelpWin.LoadPage(RealPath("help.htm"))
			
		'DebugLog "Maxsize = " + w + " | " + h
		
		myframe.refresh()
		
		TWindow.Create()
		TConsole.Create()
		
		myframe.Layout()
		myframe.Center(wxBOTH)
		myframe.show()
		'myHelpFrame.show()
		
		Return True
	End Method
	
	
End Type


Type TWindow Extends TApp
	
	Field w_statusbar:wxStatusBar
	Field w_menubar:wxMenuBar
	Field w_toolbar:wxToolBar
	
	Global imageList:wxImageList
	Global w_sizer:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
	
	Function Create()
		myWin = New TWindow
		myWin.OnInit()
		myWin.ConnectEvents()
	EndFunction
	
	Method OnInit()
		
		myFrame.SetSizer(w_sizer)
		
		w_statusbar = myframe.CreateStatusBar(1, 0 | wxST_SIZEGRIP, wxID_ANY)
		
		InitMenu()
		InitToolbar()
		
	EndMethod
	
	Method InitMenu()
		
		'Create main window menu's
		'--------------------------
		w_menubar = New wxMenuBar.Create()

		Local w_menu1:wxMenu = New wxMenu.Create()
		w_menubar.Append(w_menu1, _("File") )
			Local w_menuItem1_1:wxMenuItem = New wxMenuItem.Create(w_menu1, menuID_QUIT, _("Quit"), "", wxITEM_NORMAL)
			w_menu1.AppendItem(w_menuItem1_1)
					
		Local w_menu2:wxMenu = New wxMenu.Create()
		w_menubar.Append(w_menu2, _("Edit") )
		
		Local w_menu3:wxMenu = New wxMenu.Create()
		w_menubar.Append(w_menu3, _("Program") )

		Local w_menu4:wxMenu = New wxMenu.Create()
		w_menubar.Append(w_menu4, _("Info") )

		Local w_menuItem4_1:wxMenuItem = New wxMenuItem.Create(w_menu4, menuID_HELP, _("Help"), "", wxITEM_NORMAL)
		Local w_menuItem4_2:wxMenuItem = New wxMenuItem.Create(w_menu4, menuID_ABOUT, _("About"), "", wxITEM_NORMAL)
		w_menu4.AppendItem(w_menuItem4_1)
		w_menu4.AppendItem(w_menuItem4_2)
		
		myframe.SetMenuBar(w_menubar)
		
	EndMethod

	
	Method InitToolbar()	

		'Toolbar
		w_toolbar = New wxToolBar.Create(myframe, wxID_ANY,,,,, wxTB_HORIZONTAL | wxTB_TEXT | wxTB_HORZ_TEXT | wxTB_FLAT)
		w_toolbar.AddTool(userID_NEW, _("New"), ArtProvider.getBitmap(userID_NEW), wxNullBitmap, wxITEM_NORMAL, "New file", "")
		w_toolbar.AddTool(userID_OPEN, _("Open"), ArtProvider.getBitmap(userID_OPEN), wxNullBitmap, wxITEM_NORMAL, "Open file", "")
		w_toolbar.AddTool(userID_CLOSE, _("Close"), ArtProvider.getBitmap(userID_CLOSE), wxNullBitmap, wxITEM_NORMAL, "Close file", "")
		w_toolbar.AddTool(userID_SAVE, _("Save"), ArtProvider.getBitmap(userID_SAVE), wxNullBitmap, wxITEM_NORMAL, "Save file", "")
			
		w_toolbar.Realize()
		
		w_sizer.Add(w_toolbar, 0, wxEXPAND, 5)	
		
	EndMethod
	
	Method ConnectEvents()
		myframe.Connect(menuID_QUIT, wxEVT_COMMAND_MENU_SELECTED, OnQuit)
		myframe.Connect(menuID_ABOUT, wxEVT_COMMAND_MENU_SELECTED, OnMenuAbout)
		myframe.Connect(menuID_HELP, wxEVT_COMMAND_MENU_SELECTED, OnMenuHelp)
		
		w_toolbar.connect(userID_NEW, wxEVT_COMMAND_TOOL_CLICKED, OnToolNew, Null, Self)
		w_toolbar.connect(userID_OPEN, wxEVT_COMMAND_TOOL_CLICKED, OnToolOpen, Null, Self)
		w_toolbar.connect(userID_CLOSE, wxEVT_COMMAND_TOOL_CLICKED, OnToolClose, Null, Self)
		w_toolbar.connect(userID_SAVE, wxEVT_COMMAND_TOOL_CLICKED, OnToolSave, Null, Self)
		
	EndMethod
	
	Function OnQuit(ev:wxEvent)
		myframe.Close(True)
	EndFunction
	
	Function OnMenuAbout(ev:wxEvent)
		
		Local info:wxAboutDialogInfo = New wxAboutDialogInfo.Create()
		
		info.SetName(APP_TITLE)
		info.SetVersion(APP_VERSION)
		info.SetDescription("Editor for Blitzmax NG")
		info.SetCopyright("Henri Vihonen")

		wxAboutBox(info)
		
	End Function
	
	Function OnMenuHelp(ev:wxEvent)
		
		Rem
		html = New wxHtmlWindow.Create(Self, -1))
		html.SetRelatedFrame(Self, "HTML : %s")
		
		html.SetRelatedStatusBar(0)
		
		'    html.ReadCustomization(wxConfig::Get());
		html.LoadPage(RealPath("test.htm"))
		html.AddProcessor(processor)
		EndRem
		
	End Function
	
	Function OnToolNew(ev:wxEvent)
		Local e:TEditor = TEditor.myEdit
		e.AddNewPage()
	EndFunction

	Function OnToolOpen(ev:wxEvent)
		TEditor.myEdit.AddNewPage(True)
	EndFunction

	Function OnToolClose(ev:wxEvent)
		Local e:TEditor = TEditor.myEdit
		Local index:Int = e.e_book.GetSelection()
		e.e_book.DeletePage(index)
	EndFunction

	Function OnToolSave(ev:wxEvent)
		
	EndFunction
	
EndType


Type TConsole Extends TWindow
	
	Global myCon:TConsole
	Global conPanel:wxPanel
	Global conSizer:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
	
	Function Create()
		myCon = New TConsole
		myCon.OnInit()
	EndFunction
	
	Method OnInit()
		
		conPanel = New wxPanel.Create(myframe, wxID_ANY,,,,, wxTAB_TRAVERSAL)		
		conPanel.SetBackgroundColour(New wxColour.Create(255, 100, 255) )

		w_sizer.Add(conPanel, 1, wxEXPAND, 5)
		conPanel.SetSizer(conSizer)
		
		TEditor.Create()
	EndMethod
	
EndType


Type TEditor Extends TConsole
	
	Global myEdit:TEditor
	Global e_book:wxFlatNotebook
	
	Field keywords_1:String
	Field keywords_2:String
	Field keywords:String
	
	Global _sciList:TList = New TList
	Global _globalID:Int
	
	Function Create()
		myEdit = New TEditor
		TScintilla._parent = myEdit
		myEdit.OnInit()
	EndFunction
	
	Method OnInit()
		
		LoadKeywords()
		
		Local bookStyle:Int = 0
		
		bookStyle:| wxFNB_VC71
		bookStyle :| wxFNB_TABS_BORDER_SIMPLE
		'bookStyle :| wxFNB_NODRAG
		bookStyle :| wxFNB_CUSTOM_DLG
		bookStyle :| wxFNB_NO_X_BUTTON
	
		e_book = New wxFlatNotebook.CreateFNB(conPanel, wxID_ANY,,,,, bookStyle)
		e_book.SetCustomizeOptions(wxFNB_CUSTOM_TAB_LOOK | wxFNB_CUSTOM_LOCAL_DRAG | wxFNB_CUSTOM_FOREIGN_DRAG )
		
		conSizer.Add(e_book, 1, wxEXPAND, 5)		
		conPanel.Layout()

		AddNewPage()
		
		ConnectEvents()
	EndMethod
	
	Method ConnectEvents()
	EndMethod
	
	Method AddNewPage:Int(openFlag:Int = False)
		
		Local name:String, url:String
		
		If openFlag Then
			url = RequestFile("Open file...", "bmx",, CurrentDir() )
			If Not url Then Return False
			name = StripDir(url)
		Else
			name = "untitled" + GetNewID() + ".bmx"
		EndIf
		
		Local sci:TScintilla = GetNewEdit()
		If Not sci Then Notify "Error: Could not create scintilla"; Return False
		
		If openFlag Then
			If Not sci.LoadFile(url) Then Return False
		EndIf
		
		sci.SetFoldLevels(0, sci.GetLineCount() )
		
		_sciList.AddLast(sci)
		e_book.AddPage(sci , name, True)
		
		Return True
	EndMethod
	
	Method GetNewEdit:TScintilla(lexer:Int = wxSCI_LEX_BLITZMAX)
		Local sci:TScintilla = TScintilla( New TScintilla.Create( e_book, wxID_ANY,,,,, 0) )
		
		Local t:String = "'TESTING~n"+..
						"~qHello world~q Hello Double Int 123~n~n"	'+..
						
						Rem
						"Extern~n"+..
						"~tFunction D(a:int, b:int, c:int)~n"+..
						"EndExtern~n~n"+..
						"Rem~n"+..
						"commented~n"+..
						"Endrem~n~n"+..
						"Function Test1()~n"+..
						"~tPrint ~qHello world1~q~n"+..
						"EndFunction~n~n"+..
						"~nConst MY_CONSTANT:Int = 123~n~n"+ ..
						"Function Test2()~n"+..
						"~tPrint ~qHello world2~q~n"+..
						"End Function"
						EndRem
		sci.AddText(t)
		
		Return sci
	EndMethod
	
	Method GetNewID:Int()
		_globalID:+ 1
		Return _globalID
	EndMethod
	
	Method LoadKeywords()
		
		Local keywords_1:String, keywords_2:String
		
		keywords_1 = "Const Else End EndExtern EendFunction EndIf EndRem EndType Extern False Field Function "+..
					"Global If Import Local New Null Print Rem Return SizeOf Then True Type"
		keywords_2 = "Byte Double Float Int Long Ptr String"
		
		TWord.LoadKeywords(keywords_1, wxSCI_B_KEYWORD)
		TWord.LoadKeywords(keywords_2, wxSCI_B_KEYWORD2)
		TWord.SetKeywords()
		
	EndMethod
	
EndType

Type TScintilla Extends wxScintilla

	Global _parent:TEditor
	Field filename:String
	Field _charsEntered:Int
	
	Method OnInit()
		
		' Default style
		'-----------------------------
		'sci.StyleResetDefault()
		Local font:wxFont = New wxFont.CreateWithAttribs(16, wxTELETYPE, wxNORMAL, wxNORMAL)

		StyleSetFontFont(wxSCI_STYLE_DEFAULT, font)
		StyleSetForeground(wxSCI_STYLE_DEFAULT, COLOUR_FRONT)
		StyleSetBackground(wxSCI_STYLE_DEFAULT, COLOUR_BACK)
		StyleClearAll()
		
		'Line number margin
		'-------------------
		Local MY_LINEMARGIN:Int = 0
		SetMarginWidth(MY_LINEMARGIN, 70)
		
		StyleSetForeground(wxSCI_STYLE_LINENUMBER, New wxColour.CreateNamedColour("DARK GREY"))
		StyleSetBackground(wxSCI_STYLE_LINENUMBER, New wxColour.CreateNamedColour("LIGHT BLUE"))
		
		'Fold margin
		'---------------
		Local MY_FOLDMARGIN:Int = 1
		SetMarginWidth(MY_FOLDMARGIN, 14)
		SetMarginMask(MY_FOLDMARGIN,wxSCI_MASK_FOLDERS)
		
		SetFoldMarginColour(True, New wxColour.CreateNamedColour("LIGHT BLUE"))		'Create(150, 210, 240))
		SetFoldMarginHiColour(True, New wxColour.Create(160, 160, 160))
		
		'Set up the markers that will be shown in the fold margin
		MarkerDefine(wxSCI_MARKNUM_FOLDEREND,wxSCI_MARK_BOXPLUSCONNECTED)
		MarkerSetForeground(wxSCI_MARKNUM_FOLDEREND, New wxColour.Create(243,243,243))
		MarkerSetBackground(wxSCI_MARKNUM_FOLDEREND, New wxColour.Create(128,128,128))
		MarkerDefine(wxSCI_MARKNUM_FOLDEROPENMID,wxSCI_MARK_BOXMINUSCONNECTED)
		MarkerSetForeground(wxSCI_MARKNUM_FOLDEROPENMID, New wxColour.Create(243,243,243))
		MarkerSetBackground(wxSCI_MARKNUM_FOLDEROPENMID, New wxColour.Create(128,128,128))
		MarkerDefine(wxSCI_MARKNUM_FOLDERMIDTAIL, wxSCI_MARK_TCORNER)
		MarkerSetForeground(wxSCI_MARKNUM_FOLDERMIDTAIL, New wxColour.Create(243,243,243))
		MarkerSetBackground(wxSCI_MARKNUM_FOLDERMIDTAIL, New wxColour.Create(128,128,128))
		MarkerDefine(wxSCI_MARKNUM_FOLDERTAIL,wxSCI_MARK_LCORNER)
		MarkerSetForeground(wxSCI_MARKNUM_FOLDERTAIL, New wxColour.Create(243,243,243))
		MarkerSetBackground(wxSCI_MARKNUM_FOLDERTAIL, New wxColour.Create(128,128,128))
		MarkerDefine(wxSCI_MARKNUM_FOLDERSUB,wxSCI_MARK_VLINE)
		MarkerSetForeground(wxSCI_MARKNUM_FOLDERSUB, New wxColour.Create(243,243,243))
		MarkerSetBackground(wxSCI_MARKNUM_FOLDERSUB, New wxColour.Create(128,128,128))
		MarkerDefine(wxSCI_MARKNUM_FOLDER,wxSCI_MARK_BOXPLUS)
		MarkerSetForeground(wxSCI_MARKNUM_FOLDER, New wxColour.Create(243,243,243))
		MarkerSetBackground(wxSCI_MARKNUM_FOLDER, New wxColour.Create(128,128,128))
		MarkerDefine(wxSCI_MARKNUM_FOLDEROPEN,wxSCI_MARK_BOXMINUS)
		MarkerSetForeground(wxSCI_MARKNUM_FOLDEROPEN, New wxColour.Create(243,243,243))
		MarkerSetBackground(wxSCI_MARKNUM_FOLDEROPEN, New wxColour.Create(128,128,128))
		
		'Turn the fold markers red when the caret is a line in the group (optional)
		MarkerEnableHighlight(True)
		
		'The margin will only respond To clicks If it set sensitive.
		SetMarginSensitive(MY_FOLDMARGIN,True)
		
		'Set color For G-Code highlighting
		StyleSetForeground(19, New wxColour.Create(255, 130, 0) )
		
		'Caret
		'------
		SetCaretForeground(COLOUR_FRONT)
		
		'Set default lexer
		'------------------
		SetLexerStyle(wxSCI_LEX_BLITZMAX)		'wxSCI_LEX_CONTAINER)	'
		'SetProperty("fold", True)	'Use custom folding
		'SetProperty("fold.compact", False)
		'SetProperty("fold.basic.syntax.based", True)
		
		'Miscellaneous
		'-------------
		AutoCompSetIgnoreCase(True)
		SetTabWidth(3)
		
		UsePopUp(1)
		SetLayoutCache(wxSCI_CACHE_PAGE)
		SetBufferedDraw(1)
		
		ConnectEvents()
	End Method
	
	Method ConnectEvents()
	
		ConnectAny(wxEVT_KEY_DOWN, OnKeyDown)
		'ConnectAny(wxEVT_SCI_CHARADDED, OnCharAdded)
		ConnectAny(wxEVT_SCI_MARGINCLICK, OnMarginClick)
		ConnectAny(wxEVT_SCI_MODIFIED, OnModified)
		ConnectAny(wxEVT_SCI_STYLENEEDED, OnStyleNeeded)
		'ConnectAny(wxEVT_SCI_CHANGE, OnChange)
	EndMethod
	
	Rem
	Function OnChange(ev:wxEvent)
		Local sci:TScintilla = TScintilla( ev.parent )
		If Not sci Then DebugLog "No sci!"; Return
		
		'DebugLog "OnChange"
		Local sev:wxScintillaEvent = wxScintillaEvent(ev)
		If Not sev Then DebugLog "OnChange -> No ScintillaEvent!"; Return
				
		Local curPos:Int = sci.GetCurrentPos()
		Local startPos:Int = sci.WordStartPosition(curPos, True)
		'Local chars:String = sci.getWordChars()
		Local lenEntered:Int = curPos - startPos
		
		
		DebugLog "OnChange -> lenEntered = " + lenEntered + " | start = " + startPos + " | curPos = " + curPos + " | Key = " + sev.GetModificationType()
		
		'Return
		
		If lenEntered > 0 Then
			
			If Not sci.AutoCompActive() Then
			
				sci.AutoCompShow(lenEntered, sci._parent.keywords)	
			EndIf
		Else
			curPos:-1
			startPos = sci.WordStartPosition(curPos, True)
			lenEntered = curPos - startPos
			If lenEntered < 1 Then Return
			
			'DebugLog "OnCharAdded -> lenEntered = " + lenEntered + " | start = " + startPos + " | curPos = " + curPos + " | " 
			DebugLog "OnChange -> *" + sci.GetTextRange(startPos, curPos) + "*"
		EndIf
	EndFunction
	
	Function OnCharAdded(ev:wxEvent)
		Local sci:TScintilla = TScintilla( ev.parent )
		If Not sci Then DebugLog "No sci!"; Return
		
		'DebugLog sci.GetCurrentLine()
		
		Local curPos:Int = sci.GetCurrentPos()
		Local startPos:Int = sci.WordStartPosition(curPos, True)
		'Local chars:String = sci.getWordChars()
		Local lenEntered:Int = curPos - startPos
		
		DebugLog "OnCharAdded -> lenEntered = " + lenEntered + " | start = " + startPos + " | curPos = " + curPos + " | "
		
		If lenEntered > 0 Then
			
			If Not sci.AutoCompActive() Then
			
				sci.AutoCompShow(lenEntered, sci._parent.keywords)	
			EndIf
		Else
			curPos:-1
			startPos = sci.WordStartPosition(curPos, True)
			lenEntered = curPos - startPos
			If lenEntered < 1 Then Return
			
			'DebugLog "OnCharAdded -> lenEntered = " + lenEntered + " | start = " + startPos + " | curPos = " + curPos + " | " 
			DebugLog "OnCharAdded -> *" + sci.GetTextRange(startPos, curPos) + "*"
		EndIf
	EndFunction
	EndRem
	
	Function OnModified(ev:wxEvent)
		
		'DebugLog "OnModified"
		
		'Return
		
		Local sci:TScintilla = TScintilla( ev.parent )
		If Not sci Then DebugLog "No sci!"; Return
		
		Local sev:wxScintillaEvent = wxScintillaEvent(ev)
		If Not sev Then DebugLog "OnModified -> No ScintillaEvent!"; Return
		
		Local modType:Int = sev.GetModificationType()
		
		If modType & wxSCI_MOD_INSERTTEXT Then
			
			'DebugLog "wxSCI_MOD_INSERTTEXT"
			
			Local curPos:Int = sci.GetCurrentPos()
			Local startPos:Int = sci.WordStartPosition(curPos, True)
			'Local chars:String = sci.getWordChars()
			Local lenEntered:Int = curPos - startPos
			Local txt:String = sev.GetText()	'.Trim()
			
			DebugLog "OnModified -> lenEntered = " + lenEntered + " | start = " + startPos + " | curPos = " + curPos + " | text = " + txt
			
			If ( txt.Trim() ) Then
				If lenEntered > 0 Then
					
					If Not sci.AutoCompActive() Then
					
						sci.AutoCompShow(lenEntered, TWord.GetAutoKeywords() )	'sci._parent.keywords)	
					EndIf
				ElseIf txt.length > 1	'Paste
					sci.AutoCapitalize(startPos, startPos + txt.length, False)	'DebugLog "*" + txt + "*"
				EndIf
			
			ElseIf lenEntered > 0
			
				'Check word
				startPos = sci.WordStartPosition(curPos, True)
				lenEntered = curPos - startPos
				If lenEntered < 1 Then Return
					
				'DebugLog "OnCharAdded -> lenEntered = " + lenEntered + " | start = " + startPos + " | curPos = " + curPos + " | " 
				sci.AutoCapitalize(startPos, curPos, True)	'DebugLog "OnModified -> *" + sci.GetTextRange(startPos, curPos) + "*"
			EndIf
			
			'DebugLog " = " + sev.GetModificationType() ) + " | " + sev.GetPosition() + " | " + sev.GetLine()
		EndIf
		
		If modType & wxSCI_MOD_DELETETEXT Then DebugLog "wxSCI_MOD_DELETETEXT"
		If modType & wxSCI_MOD_DELETETEXT Then DebugLog "wxSCI_MOD_DELETETEXT"
		'If modType & wxSCI_MOD_CHANGESTYLE Then DebugLog "wxSCI_MOD_CHANGESTYLE"
		'If modType & wxSCI_MOD_CHANGEFOLD Then DebugLog "wxSCI_MOD_CHANGEFOLD"
		'If modType & wxSCI_PERFORMED_USER Then DebugLog "wxSCI_PERFORMED_USER"
		'If modType & wxSCI_PERFORMED_UNDO Then DebugLog "wxSCI_PERFORMED_UNDO"
		
	EndFunction
	
	Function OnKeyDown(ev:wxEvent)

		Local key_ev:wxKeyEvent = wxKeyEvent(ev)
		Local keyCode:Int = key_ev.GetKeyCode()
		Local sci:TScintilla = TScintilla(ev.sink)
		If Not sci Then Notify "Scintilla not found!!";Return
		Local key:String = Chr(keyCode)
		
		'DebugLog key + " | " + keyCode
		
		Select keyCode
		
			Case 9, 13, 32	'Tab, Enter, Space
				
			
		EndSelect
		
		If key = "F" Then
			If key_ev.ControlDown() Then
				
				Local txt:String = EntryDlg("Find","Find")
				If txt Then
					Print sci.FindText(0, 100, txt, wxSCI_WHOLEWORD | wxSCI_MATCHCASE)
				EndIf
			EndIf
		EndIf
		
		ev.skip()
	EndFunction
	
	Function OnMarginClick(ev:wxEvent)
	
		'DebugLog "OnMarginClicked"
		
		Local sci:TScintilla = TScintilla( ev.parent )
		If Not sci Then DebugLog "OnMarginClicked -> No sci!"; Return
		
		Local sev:wxScintillaEvent = wxScintillaEvent(ev)
		If Not sev Then DebugLog "OnMarginClicked -> No ScintillaEvent!"; Return
		
		Local margin:Int	= sev.GetMargin()
		Local position:Int	= sev.GetPosition()
		Local line:Int		= sci.LineFromPosition(position)
		Local foldLevel:Int = sci.GetFoldLevel(line)
		
		Local headerFlag:Int = (foldLevel & wxSCI_FOLDLEVELHEADERFLAG)
		
		DebugLog foldLevel + " | " + headerFlag
		
		For Local i:Int = 0 Until sci.GetLineCount()
			Print sci.GetFoldLevel(i) + " | " + sci.Getline(i).Trim() + " | " + sci.GetFoldParent(i)
		Next
		
		If (margin = 1 And headerFlag) Then		
			sci.ToggleFold(line)
		EndIf
		
		
	EndFunction
	
	Function OnStyleNeeded(ev:wxEvent)
		
		DebugLog "OnStyleNeeded"
		Rem
		void myFrame::OnStyleNeeded(wxStyledTextEvent& event) {
		/*this is called every time the styler detects a line that needs style, so we style that range.
		This will save a lot of performance since we only style text when needed instead of parsing the whole file every time.*/
		size_t line_end=m_activeSTC->LineFromPosition(m_activeSTC->GetCurrentPos());
		size_t line_start=m_activeSTC->LineFromPosition(m_activeSTC->GetEndStyled());
		/*fold level: May need to include the two lines in front because of the fold level these lines have- the line above
		may be affected*/
		if(line_start>1) {
			line_start-=2;
		} else {
			line_start=0;
		}
		//if it is so small that all lines are visible, style the whole document
		if(m_activeSTC->GetLineCount()==m_activeSTC->LinesOnScreen()){
			line_start=0;
			line_end=m_activeSTC->GetLineCount()-1;
		}
		if(line_end<line_start) {
			//that happens when you select parts that are in front of the styled area
			size_t temp=line_end;
			line_end=line_start;
			line_start=temp;
		}
		//style the line following the style area too (if present) in case fold level decreases in that one
		if(line_end<m_activeSTC->GetLineCount()-1){
			line_end++;
		}
		//get exact start positions
		size_t startpos=m_activeSTC->PositionFromLine(line_start);
		size_t endpos=(m_activeSTC->GetLineEndPosition(line_end));
		int startfoldlevel=m_activeSTC->GetFoldLevel(line_start);
		startfoldlevel &= wxSTC_FOLDFLAG_LEVELNUMBERS; //mask out the flags and only use the fold level
		wxString text=m_activeSTC->GetTextRange(startpos,endpos).Upper();
		//call highlighting function
		this->highlightSTCsyntax(startpos,endpos,text);
		//calculate and apply foldings
		this->setfoldlevels(startpos,startfoldlevel,text);
	 }
		
		EndRem
	EndFunction
	
	Method AutoCapitalize(startPos:Int, endPos:Int, single:Int = True)
		If Not TOptions.opt.autoCap Then Return
		
		DebugLog "AutoCapitalize -> start = " + startPos + " |end = " + endPos + " |txt = " + GetTextRange(startPos, endPos)
		
		Local style:Int
		
		If single Then
			style = GetStyleAt(startPos)
			If style = wxSCI_B_KEYWORD Or style = wxSCI_B_KEYWORD2 Then
				'Todo
			EndIf
		Else
			For Local i:Int = startPos To endPos
				style = GetStyleAt(startPos)
				If style = wxSCI_B_KEYWORD Or style = wxSCI_B_KEYWORD2 Then
					'Todo
				EndIf
			Next
		EndIf
		
	EndMethod
	
	Method SetFoldLevels(start:Int, stop:Int)
		
		Local s:String, e:Int, r:Int, level:Int = GetFoldLevel(start)	'wxSCI_FOLDLEVELBASE
		
		For Local i:Int = start Until stop
			
			s = GetLine(i).Trim().tolower()
			
			SetFoldLevel(i, level)
			
			If s.StartsWith("extern") Then
				SetFoldLevel(i, level | wxSCI_FOLDLEVELHEADERFLAG)
				e = True; level:+1
			ElseIf s.StartsWith("rem")
				SetFoldLevel(i, level | wxSCI_FOLDLEVELHEADERFLAG)
				r = True; level:+1
			ElseIf s.StartsWith("function")
				If e Then Continue
				SetFoldLevel(i, level | wxSCI_FOLDLEVELHEADERFLAG)
				level:+1
			ElseIf s.StartsWith("end")
				If s.StartsWith("endextern") Or s.startswith("end extern")
					e = False; level:-1
					'SetFoldLevel(i, wxSCI_FOLDLEVELBASE)
					Continue
				EndIf
				If s.startswith("endfunction") Or s.startswith("end function")
					level:-1
					'SetFoldLevel(i, wxSCI_FOLDLEVELBASE)
					Continue
				EndIf
				If s.startswith("endrem") Or s.startswith("end rem")
					level:-1
					'SetFoldLevel(i, wxSCI_FOLDLEVELBASE)
					Continue
				EndIf
			EndIf	
		Next
		
		For Local i:Int = 0 Until GetLineCount()	
			Print GetFoldLevel(i) + " | " + Getline(i).Trim() + " | " + GetFoldParent(i)
		Next
	
	EndMethod
	
	
	Method SetLexerStyle(lexer:Int)
		
		Select lexer
			Case wxSCI_LEX_BLITZMAX
				
				DebugLog "lexer = wxSCI_LEX_BLITZMAX"
				
				Local s:TStyle = TStyle.GetStyle(lexer)
				
				StyleSetForeground(wxSCI_B_KEYWORD, s.style_keyword_1 )
				StyleSetForeground(wxSCI_B_KEYWORD2, s.style_keyword_2 )
				StyleSetForeground(wxSCI_B_CONSTANT, s.style_keyword_1 )
				StyleSetForeground(wxSCI_B_PREPROCESSOR, s.style_keyword_1 )
				StyleSetForeground(wxSCI_B_STRING, s.style_string )
				StyleSetForeground(wxSCI_B_NUMBER, s.style_number )
				StyleSetForeground(wxSCI_B_COMMENT, s.style_comment )
				StyleSetForeground(wxSCI_B_COMMENTREM, s.style_comment )
				
				SetLexer(lexer)
				SetKeywords(0, TWord.GetKeyWords(wxSCI_B_KEYWORD) )	'_parent.keywords_1)
				SetKeywords(1, TWord.GetKeyWords(wxSCI_B_KEYWORD2))	'_parent.keywords_2)
				
		EndSelect
		
	EndMethod
	
	
End Type

Type TOptions
	Global opt:TOptions = New TOptions
	Field autoCap:Int = True
	
	Method LoadOptions()
		
	EndMethod
EndType

Type TWord
	Global _autoKeywords:String	' Used for autocompletion
	Global _keywords1:String, _keywords2:String
	
	Field style:Int
	Field name:String
	Field key:String
	
	Global _wordList:TList = New TList
	
	Function LoadKeywords:Int(words:String, style:Int = wxSCI_B_KEYWORD)
		
		If Not words Then Notify "Error: Keywords not found.",True; Return False
		
		Local w:TWord
		Local ar:String[] = words.split(" ")
		
		If Not ar Then Notify "Error: Could not create keywords.",True; Return False
		
		For Local i:Int = 0 Until ar.length
			
			If Not ar[i].Trim() Then Continue
			
			w = New TWord
			w.style	= style
			w.name	= ar[i]
			w.key	= ar[i].tolower()
			
			_wordList.addlast(w)
		Next
		
		Return True
	EndFunction
	
	Function GetKeywords:String(style:Int = wxSCI_B_KEYWORD)
		If style = wxSCI_B_KEYWORD2 Then
			Return _keywords2
		Else
			Return _keywords1
		EndIf
	EndFunction
	
	Function GetAutoKeywords:String()
		Return _autoKeywords
	EndFunction
	
	Function SetKeywords()
		If Not _wordList.count() Then Return
		_wordList.sort(False)
		
		_autoKeywords = ""
		_keywords1 = ""
		_keywords2 = ""
		
		For Local w:TWord = EachIn _wordList
			
			If Not w.key Then Continue
			
			If _autoKeywords Then _autoKeywords:+ " "
			_autoKeywords:+ w.key
			
			If w.style = wxSCI_B_KEYWORD2
				If _keywords2 Then _keywords2:+ " "
				_keywords2:+ w.key
			Else
				If _keywords1 Then _keywords1:+ " "
				_keywords1:+ w.key
			EndIf
		Next
	EndFunction
	
	Method compare:Int(o:Object)
		Local w:TWord = TWord(o)
		Return w.name.compare(Self.name)
	EndMethod
EndType

Type TStyle
	Field lexer:Int = -1
	
	Field style_comment:wxColour = New wxColour.Create(130, 210, 230)
	Field style_string:wxColour = wxGREEN()
	Field style_number:wxColour =  New wxColour.Create(70, 190, 220)
	Field style_keyword_1:wxColour = New wxColour.Create(220, 220, 0) 'Yellow
	Field style_keyword_2:wxColour = New wxColour.Create(148, 148, 255) 'Teak
	
	Global _list:TList = New TList
	
	Function GetStyle:TStyle(lexer:Int)
		Local s:TStyle
		
		For s = EachIn _list
			If s.lexer = lexer Then Return s
		Next

		s = New TStyle
		s.lexer = lexer
		_list.addlast(s)
		
		Return s
	EndFunction
EndType

Function EntryDlg:String(text:String, title:String)

	Local dial:TEntryDialog = New TEntryDialog.Create(text, title)
	Local value:String = dial.GetString()

	dial.Free()
	Return value
EndFunction

Type TEntryDialog Extends wxDialog

	Field m_panel:wxPanel
	Field m_label1:wxStaticText
	Field m_field1:wxTextCtrl
	Field m_staticline:wxStaticLine
	Field m_sdbSizer:wxStdDialogButtonSizer
	Field m_sdbSizerCancel:wxButton
	Field m_sdbSizerOK:wxButton
	Field text:String
	Field value:String
	Field ret:Int
	
	Method Create:TEntryDialog(txt:String, title:String)
		text = txt
		Return TEntryDialog(Super.Create_(Null, wxID_ANY, title, -1, -1, -1, -1, wxDEFAULT_DIALOG_STYLE))
	End Method

	Method OnInit()

		Local bSizer1:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		Local bSizer2:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		Local bSizer3:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		
		m_sdbSizer = New wxStdDialogButtonSizer.CreateSizer()
		m_sdbSizerOK = New wxButton.Create(Self, wxID_OK)
		m_sdbSizerCancel = New wxButton.Create(Self, wxID_CANCEL)
		
		m_panel = New wxPanel.Create(Self, wxID_ANY,,,,, wxTAB_TRAVERSAL)
		m_panel.SetForegroundColour(New wxColour.Create(0,0,0))
		m_panel.SetBackgroundColour(New wxColour.Create(255,255,255))

		m_staticline = New wxStaticLine.Create(Self, wxID_ANY,,,,, wxLI_HORIZONTAL)
		
		m_label1 = New wxStaticText.Create(m_panel, wxID_ANY, text)
		m_label1.Wrap(-1)
		
		m_field1 = New wxTextCtrl.Create(m_panel, wxID_ANY, "",,,200,,0)

		bSizer2.AddCustomSpacer(0, 15, 1, wxEXPAND, 5)
		bSizer3.Add(m_label1, 0, wxBOTTOM|wxRIGHT|wxLEFT, 5)
		bSizer3.Add(m_field1, 0, wxRIGHT|wxLEFT, 5)
		bSizer2.AddSizer(bSizer3, 1, wxEXPAND, 5)
		bSizer2.AddCustomSpacer(0, 15, 1, wxEXPAND, 5)
		bSizer1.Add(m_panel, 1, wxEXPAND, 5)
		bSizer1.Add(m_staticline, 0, wxEXPAND, 5)
		m_sdbSizer.AddButton( m_sdbSizerOK)
		m_sdbSizer.AddButton( m_sdbSizerCancel)
		bSizer1.AddSizer(m_sdbSizer, 0, wxEXPAND|wxTOP|wxBOTTOM, 10)
				
		m_panel.SetSizer(bSizer2)
		m_panel.Layout()
		bSizer2.Fit(m_panel)

		m_sdbSizer.Realize()
		
		SetSizer(bSizer1)
		Layout()
		bSizer1.Fit(Self)
		Center(wxBOTH)
		
		m_sdbSizerCancel.ConnectAny(wxEVT_COMMAND_BUTTON_CLICKED, OnCancel, Null, Self)
		m_sdbSizerOK.ConnectAny(wxEVT_COMMAND_BUTTON_CLICKED, OnOk, Null, Self)
		
		m_sdbSizerOK.SetDefault()
		m_field1.SetFocus()
		
		Centre()
		ret = ShowModal()
		
		If ret Then
			value = m_field1.GetValue()
		Else
			value = ""
		EndIf
		
	End Method

	Method GetString:String()
		Return value
	EndMethod
	
	Function OnCancel(ev:wxEvent)
		Local d:TEntryDialog = TEntryDialog(ev.sink)
		d.EndModal(False)
	End Function

	Function OnOk(ev:wxEvent)
		Local d:TEntryDialog = TEntryDialog(ev.sink)
		d.EndModal(True)
	End Function

End Type



Type ArtProvider Extends wxArtProvider

	' override CreateBitmap, return wxNullBitmap for those you don't care about.
	Method CreateBitmap:wxBitmap(id:String, client:String, w:Int, h:Int)
		Select id		
			Case userID_NEW
				Return wxBitmap.CreateFromFile("incbin::graphics\new.png", wxBITMAP_TYPE_PNG)
			
			Case userID_OPEN
				Return wxBitmap.CreateFromFile("incbin::graphics\open.png", wxBITMAP_TYPE_PNG)

			Case userID_CLOSE
				Return wxBitmap.CreateFromFile("incbin::graphics\close.png", wxBITMAP_TYPE_PNG)
								
			Case userID_SAVE
				Return wxBitmap.CreateFromFile("incbin::graphics\save.png", wxBITMAP_TYPE_PNG)
					
		End Select
		Return wxNullBitmap
	End Method

End Type

