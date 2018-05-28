
'
' Editor
'
'
'
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
Const APP_VERSION:String = "0.1"	' 
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
	'Global group1:wxPanel
	Global conSizer:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
	
	Function Create()
		myCon = New TConsole
		myCon.OnInit()
	EndFunction
	
	Method OnInit()
		
		conPanel = New wxPanel.Create(myframe, wxID_ANY,,,,, wxTAB_TRAVERSAL)		
			conPanel.SetBackgroundColour(New wxColour.Create(255, 100, 255) )
		'group1 = New wxPanel.Create(conPanel, wxID_ANY,,,,, wxTAB_TRAVERSAL)		
		'group1 = New wxScrolledWindow.Create(conPanel, wxID_ANY,,,,, wxHSCROLL | wxVSCROLL)
		'group1.SetScrollRate(5, 5)
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
	
	Method AddNewPage:wxWindow()
		Local name:String = "untitled" + GetNewID() + ".bmx"
		Local sci:TScintilla = GetNewEdit()
		If Not sci Then Notify "Error: Could not create scintilla"; Return Null
		e_book.AddPage(sci , name, True)
	EndMethod
	
	Method GetNewEdit:TScintilla(lexer:Int = wxSCI_LEX_BLITZMAX)
		Local sci:TScintilla = TScintilla( New TScintilla.Create( e_book, wxID_ANY,,,,, 0) )
		
		Local t:String = "'TESTING~nFunction() ~qHello world~q Hello Double Int 123~n~nRem~ncommented~nEndrem~n~n"
		sci.AddText(t)
		sci.SetLexerStyle(lexer)
		
		Return sci
	EndMethod
	
	Method GetNewID:Int()
		_globalID:+ 1
		Return _globalID
	EndMethod
	
	Method LoadKeywords()
		
		keywords_1 = "endrem function print rem"
		keywords_2 = "double float int string"
		keywords = keywords_1 + " " + keywords_2
		
		DebugLog keywords
		
	EndMethod
	
EndType

Type TScintilla Extends wxScintilla

	Global _parent:TEditor
	Field filename:String
	
	' margin variables
	Field lineNrID:Int
	Field lineNrMargin:Int
	Field foldingID:Int
	Field foldingMargin:Int
	Field dividerID:Int


	Method OnInit()
		
		
		AutoCompSetIgnoreCase(True)
		
		filename = ""
		'm_language = Null;
		
		lineNrID = 0
		lineNrMargin = TextWidth(wxSCI_STYLE_LINENUMBER, "_999999")
		foldingID = 1
		foldingMargin = 16
		dividerID = 2

	



		' set visibility
		SetVisiblePolicy(wxSCI_VISIBLE_STRICT | wxSCI_VISIBLE_SLOP, 1)
		SetXCaretPolicy(wxSCI_CARET_EVEN | wxSCI_VISIBLE_STRICT | wxSCI_CARET_SLOP, 1)
		SetYCaretPolicy(wxSCI_CARET_EVEN | wxSCI_VISIBLE_STRICT | wxSCI_CARET_SLOP, 1)
		
		' markers
		MarkerDefine(wxSCI_MARKNUM_FOLDER, wxSCI_MARK_BOXPLUS)
		MarkerSetBackground(wxSCI_MARKNUM_FOLDER, New wxColour.CreateNamedColour("BLACK"))
		MarkerSetForeground(wxSCI_MARKNUM_FOLDER, New wxColour.CreateNamedColour("WHITE"))
		MarkerDefine(wxSCI_MARKNUM_FOLDEROPEN, wxSCI_MARK_BOXMINUS)
		MarkerSetBackground(wxSCI_MARKNUM_FOLDEROPEN, New wxColour.CreateNamedColour("BLACK"))
		MarkerSetForeground(wxSCI_MARKNUM_FOLDEROPEN, New wxColour.CreateNamedColour("WHITE"))
		MarkerDefine(wxSCI_MARKNUM_FOLDERSUB, wxSCI_MARK_EMPTY)
		MarkerDefine(wxSCI_MARKNUM_FOLDEREND, wxSCI_MARK_SHORTARROW)
		MarkerDefine(wxSCI_MARKNUM_FOLDEROPENMID, wxSCI_MARK_ARROWDOWN)
		MarkerDefine(wxSCI_MARKNUM_FOLDERMIDTAIL, wxSCI_MARK_EMPTY)
		MarkerDefine(wxSCI_MARKNUM_FOLDERTAIL, wxSCI_MARK_EMPTY)

		' miscelaneous
		UsePopUp(0)
		SetLayoutCache(wxSCI_CACHE_PAGE)
		SetBufferedDraw(1)
		
		ConnectAny(wxEVT_KEY_DOWN, OnKeyDown)
		ConnectAny(wxEVT_SCI_CHARADDED, OnCharAdded)
		
	End Method
	
	Function OnCharAdded(ev:wxEvent)
		Local sci:TScintilla = TScintilla( ev.parent )
		If Not sci Then DebugLog "No sci!"; Return; Else DebugLog "sci found!"
		
		Local curPos:Int = sci.GetCurrentPos()
		Local startPos:Int = sci.WordStartPosition(curPos, True)
		
		Local lenEntered:Int = curPos - startPos
		
		If lenEntered > 0 Then
			
			'DebugLog "OnCharAdded -> lenEntered" 
			
			If Not sci.AutoCompActive() Then
			
				'DebugLog "OnCharAdded -> Autocomplite. Len = " + lenEntered
				'DebugLog sci._parent.keywords
				
				sci.AutoCompShow(lenEntered, sci._parent.keywords)
				
				DebugLog sci.AutoCompActive()
			EndIf
		EndIf
		
	EndFunction
	
	Function OnKeyDown(ev:wxEvent)

		Local key_ev:wxKeyEvent = wxKeyEvent(ev)
		Local keyCode:Int = key_ev.GetKeyCode()
		Local sci:TScintilla = TScintilla(ev.sink)
		If Not sci Then Notify "Scintilla not found!!";Return
		Local key:String = Chr(keyCode)
		
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
	

	
	Method SetLexerStyle(lexer:Int)
		
		Select lexer
			Case wxSCI_LEX_BLITZMAX
				
				DebugLog "lexer = wxSCI_LEX_BLITZMAX"
				
				Local s:TStyle = TStyle.GetStyle(lexer)
				
				
				' Default style
				'-----------------------------
				'sci.StyleResetDefault()
				
				Local margin:Int = TextWidth(wxSCI_STYLE_LINENUMBER, "_999999")
				
				DebugLog margin
				
				Local font:wxFont = New wxFont.CreateWithAttribs(16, wxTELETYPE, wxNORMAL, wxNORMAL)
				SetMarginWidth(0, margin)
				StyleSetFontFont(wxSCI_STYLE_DEFAULT, font)
				
				StyleSetForeground(wxSCI_STYLE_DEFAULT, COLOUR_FRONT)
				StyleSetBackground(wxSCI_STYLE_DEFAULT, COLOUR_BACK)
				StyleClearAll()
				
				StyleSetForeground(wxSCI_STYLE_LINENUMBER, New wxColour.CreateNamedColour("DARK GREY"))
				StyleSetBackground(wxSCI_STYLE_LINENUMBER, New wxColour.CreateNamedColour("LIGHT BLUE"))
				SetCaretForeground(COLOUR_FRONT)
				'StyleSetForeground(wxSCI_STYLE_INDENTGUIDE, New wxColour.CreateNamedColour("DARK GREY"))
				
				'SetViewEOL(commonPrefs.displayEOLEnable)
				'SetIndentationGuides(commonPrefs.indentGuideEnable)
				'	' Apply default style
				'--------------------------------------------------
				
				
				' Lexer style
				
				'etStyle([wxSCI_B_COMMENT, wxSCI_B_COMMENTREM], comments)
				'SetStyle([wxSCI_B_KEYWORD, wxSCI_B_CONSTANT, wxSCI_B_PREPROCESSOR], keywords)
				'SetStyle([wxSCI_B_KEYWORD2], keywords2)
				'SetStyle([wxSCI_B_KEYWORD3], keywords3)
				'SetStyle([wxSCI_B_KEYWORD4], keywords4)
				
				'StyleSetBackground(wxSCI_B_DEFAULT, COLOUR_BACK )
				StyleSetForeground(wxSCI_B_KEYWORD, s.style_keyword_1 )
				StyleSetForeground(wxSCI_B_KEYWORD2, s.style_keyword_2 )
				StyleSetForeground(wxSCI_B_STRING, s.style_string )
				StyleSetForeground(wxSCI_B_NUMBER, s.style_number )
				StyleSetForeground(wxSCI_B_COMMENT, s.style_comment )
				StyleSetForeground(wxSCI_B_COMMENTREM, s.style_comment )
				
				SetLexer(lexer)
				SetKeywords(0, _parent.keywords_1)
				SetKeywords(1, _parent.keywords_2)
				
		EndSelect
		
	EndMethod
	
End Type

Type TWords
	Field name:String
	Field key:String
	
	Method Compare:Int(o:Object)
		
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

Rem
Function SYS_CheckIndex:Int()
	Local sql:String
	sql =	"SELECT a.name, b.name, a.create_table, a.create_sql FROM sys_index a " + ..
			"LEFT JOIN sqlite_master b ON a.name=b.name " + ..
			"WHERE b.name Is Null"
	If Not OpenTX() Then Return False
	Local query:TDatabaseQuery = txdb.executequery(sql)
	If txdb.hasError() errorAndClose(txdb, sql) ; Return False
	
	While query.nextrow()
		Local rec:TQueryRecord = query.rowrecord()
		Local se:TSYS_error = New TSYS_error
		se.index_name		= rec.value(0).getstring()
		se.create_table		= rec.value(2).getstring()
		se.create_sql		= rec.value(3).getstring()
		se.error = "Missing index: " + se.index_name
	Wend
	CloseTX()
	
	If Not TSYS_error.list Return True
	For Local se:TSYS_error = EachIn TSYS_error.list
		If Not se.CreateIndex() Return False
		DebugLog "Creating index " + se.index_name
	Next
	TSYS_error.list.clear(); TSYS_error.list = Null
	
	Return True	
EndFunction
EndRem

Rem
Function SYS_WriteLog:Int(error:String)
	If Not error Then Return False
	
	Local se:TSYS_error = New TSYS_error
	se.error = error.Trim()
	se.WriteLog()
	
	Return True
EndFunction

Type TSYS_error
	Field index_name:String
	Field create_table:String
	Field create_sql:String
	Field error:String
	Global list:TList
	
	Method New()
		If list = Null list = New TList
		list.addlast(Self)
	EndMethod
	
	Method CreateIndex:Int()
		'If Not OpenTX() Return False
		
		'Recreate missing index
		txdb.executequery(create_sql)
		If txdb.haserror() Then errorAndClose(txdb, create_sql) ; Return False
		
		'Write log entry
		WriteLog()
		
		'CloseTX()
		Return True
	EndMethod
	
	'Write log entry
	Method WriteLog:Int()
		
		'If Not OpenTX() Then Return False
		Local sql:String = "INSERT INTO sys_error(id, createdate, createuser, error) " + ..
							"VALUES(Null,'" + datetime() + "','" + globalUserShort + "','" + error + "')"
		txdb.executequery(sql)
		If txdb.haserror() Then errorAndClose(txdb, sql) ; Return False
		'CloseTX()
		
		Return True
	EndMethod
EndType
EndRem

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

