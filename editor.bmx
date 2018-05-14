'
' TranslatorX
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

Import wx.wxHtmlWindow
Import wx.wxFileSystem
Import wx.wxInternetFSHandler

Import brl.standardio
Import brl.random

Import "..\Pub\Functions\helper_functions.bmx"
Import "..\Pub\wxDataview\TListview.bmx"
Import "..\Pub\wxDialog\TDialog.bmx"
Import "..\Pub\PDF\PDF_Document.bmx"
Import "..\Pub\Database\database_functions.bmx"

Import "manifest\wx_rc.o"

'---------------------------------
'Application info
'---------------------------------
Const APP_TITLE:String = "Editor"
Const APP_VERSION:String = "0.1"	' 
'----------------------------------



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
	Global mywin:TWindow
	Global myGroup1:TGroup1
	Global mycon:TConsole
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
		myframe.SetBackgroundColour(New wxColour.Create(238, 238, 238) )
		
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
		
		mywin	 = TWindow.Create()
		mycon	 = TConsole.Create()
		myGroup1 = TGroup1.Create()
		
		myframe.show()
		'myHelpFrame.show()
		
		Return True
	End Method
	
	
End Type

Type TWindow Extends TApp
	
	Field m_statusbar:wxStatusBar
	Field m_menubar:wxMenuBar
	Field m_toolbar:wxToolBar
	'Field m_menu1:wxMenu
	'Field m_menu2:wxMenu
	
	Global imageListMain:wxImageList
	Global imageListDetail:wxImageList
	Global m_sizer:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
	
	Function Create:TWindow()
		Local w:TWindow = New TWindow
		w.OnInitMenu()
		w.OnInitToolbar()
		w.ConnectEvents()
		Return w
	EndFunction
	
	Method OnInitMenu()
		
		'Create imagelists for listviews
		'imageListMain = New wxImageList.Create(32, 16)
		'imageListMain.Add( wxBitmap.CreateFromFile( "incbin::graphics\small_ok.png", wxBITMAP_TYPE_PNG ) )
		'imageListMain.Add( wxBitmap.CreateFromFile( "incbin::graphics\small_not_ok.png", wxBITMAP_TYPE_PNG ) )
		'imageListMain.Add( wxBitmap.CreateFromFile( "incbin::graphics\small_late.png", wxBITMAP_TYPE_PNG ) )
		
		m_statusbar = myframe.CreateStatusBar(1, 0 | wxST_SIZEGRIP, wxID_ANY)
		
		'Create main window menu's
		'--------------------------
		m_menubar = New wxMenuBar.Create()

		Local m_menu1:wxMenu = New wxMenu.Create()
		m_menubar.Append(m_menu1, _("File") )
			Local m_menuItem1_1:wxMenuItem = New wxMenuItem.Create(m_menu1, menuID_QUIT, _("Quit"), "", wxITEM_NORMAL)
			m_menu1.AppendItem(m_menuItem1_1)
					
		Local m_menu2:wxMenu = New wxMenu.Create()
		m_menubar.Append(m_menu2, _("Edit") )
		
		Local m_menu3:wxMenu = New wxMenu.Create()
		m_menubar.Append(m_menu3, _("Program") )

		Local m_menu4:wxMenu = New wxMenu.Create()
		m_menubar.Append(m_menu4, _("Info") )

		Local m_menuItem4_1:wxMenuItem = New wxMenuItem.Create(m_menu4, menuID_HELP, _("Help"), "", wxITEM_NORMAL)
		Local m_menuItem4_2:wxMenuItem = New wxMenuItem.Create(m_menu4, menuID_ABOUT, _("About"), "", wxITEM_NORMAL)
		m_menu4.AppendItem(m_menuItem4_1)
		m_menu4.AppendItem(m_menuItem4_2)
		
		myframe.SetMenuBar(m_menubar)
		
	EndMethod
	
	Method OnInitToolbar()	

		'Toolbar
		m_toolbar = New wxToolBar.Create(myframe, wxID_ANY,,,,, wxTB_HORIZONTAL | wxTB_TEXT | wxTB_HORZ_TEXT | wxTB_FLAT)
		m_toolbar.AddTool(userID_NEW, _("New"), ArtProvider.getBitmap(userID_NEW), wxNullBitmap, wxITEM_NORMAL, "New file", "")
		m_toolbar.AddTool(userID_OPEN, _("Open"), ArtProvider.getBitmap(userID_OPEN), wxNullBitmap, wxITEM_NORMAL, "Open file", "")
		m_toolbar.AddTool(userID_CLOSE, _("Close"), ArtProvider.getBitmap(userID_CLOSE), wxNullBitmap, wxITEM_NORMAL, "Close file", "")
		m_toolbar.AddTool(userID_SAVE, _("Save"), ArtProvider.getBitmap(userID_SAVE), wxNullBitmap, wxITEM_NORMAL, "Save file", "")
			
		m_toolbar.Realize()
		
		m_sizer.Add(m_toolbar, 0, wxEXPAND, 5)	
		
	EndMethod
	
	Method ConnectEvents()
		myframe.Connect(menuID_QUIT, wxEVT_COMMAND_MENU_SELECTED, OnQuit)
		myframe.Connect(menuID_ABOUT, wxEVT_COMMAND_MENU_SELECTED, OnMenuAbout)
		myframe.Connect(menuID_HELP, wxEVT_COMMAND_MENU_SELECTED, OnMenuHelp)
		
		m_toolbar.connect(userID_NEW, wxEVT_COMMAND_TOOL_CLICKED, OnToolNew, Null, Self)
		m_toolbar.connect(userID_OPEN, wxEVT_COMMAND_TOOL_CLICKED, OnToolOpen, Null, Self)
		m_toolbar.connect(userID_CLOSE, wxEVT_COMMAND_TOOL_CLICKED, OnToolClose, Null, Self)
		m_toolbar.connect(userID_SAVE, wxEVT_COMMAND_TOOL_CLICKED, OnToolSave, Null, Self)
		
	EndMethod
	
	Function OnQuit(ev:wxEvent)
		myframe.Close(True)
	EndFunction
	
	Function OnMenuAbout(ev:wxEvent)
		
		Local info:wxAboutDialogInfo = New wxAboutDialogInfo.Create()
		
		info.SetName(AppTitle)
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
		
	EndFunction

	Function OnToolOpen(ev:wxEvent)
		
	EndFunction

	Function OnToolClose(ev:wxEvent)
		
	EndFunction

	Function OnToolSave(ev:wxEvent)
		
	EndFunction
	
	Function ClearFields(parent:Object)

		Local win:wxWindow = wxWindow(parent)
		If Not win Then Return
		
		Local kids:wxWindow[] = win.GetChildren()
		For Local kid:wxWindow = EachIn kids
		
			If kid.GetChildren() Then ClearFields(kid)
		
			Local tmpField:wxTextCtrl = wxTextCtrl(kid)
			If tmpField Then
				tmpField.SetValue("")
			EndIf
			
			Local tmpCombo:wxComboBox = wxComboBox(kid)
			If tmpCombo Then
				tmpCombo.SelectItem(0)
				'tmpCombo.Clear()
				'tmpCombo.SetValue("")
			EndIf
			
			Local tmpChoice:wxChoice = wxChoice(kid)
			If tmpChoice Then
				tmpChoice.SelectItem(0)
			EndIf
			
			Local tmpLV:TListview = TListview(kid)
			If tmpLV Then
				If Not tmpLV.IsGlobal() Then tmpLV.DeleteAllItems()
			EndIf
		Next
	EndFunction
	
	
EndType


Type TConsole Extends TWindow
	
	Global conPanel:wxPanel
	Global group1:wxPanel
	Global conSizer:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
	
	Function Create:TConsole()
		Local c:TConsole = New TConsole
		c.OnInit()
		Return c
	EndFunction
	
	Method OnInit()
		
		conPanel = New wxPanel.Create(myframe, wxID_ANY,,,,, wxTAB_TRAVERSAL)		
		
		group1 = New wxPanel.Create(conPanel, wxID_ANY,,,,, wxTAB_TRAVERSAL)		
		'group1 = New wxScrolledWindow.Create(conPanel, wxID_ANY,,,,, wxHSCROLL | wxVSCROLL)
		'group1.SetScrollRate(5, 5)
		
	EndMethod
	
EndType


Type TGroup1 Extends TConsole

	Global g1_notebook:wxFlatNotebook
	Global g1_sizer:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
	
	Global g1_main:TGroup1_main
	
	Function Create:TGroup1()
		Local r:TGroup1 = New TGroup1
		r.OnInit()
		
		g1_main = TGroup1_main.Create()
		
		Return r
	EndFunction
	
	Method OnInit()
		
		'Menus
		'g1_mainListview.menu = New wxMenu.Create()
		'Local filterMenu:wxMenuItem = g1_mainListview.menu.AppendSubMenu(g1_mainListview.menu, "Filter", "Filter")		
		'g1_mainListview.menu.Append(listID_FILTER_WEEK, "&Suodata")
		
		
		Local bookStyle:Int = 0
		
		bookStyle:| wxFNB_VC71
		bookStyle :| wxFNB_TABS_BORDER_SIMPLE
		bookStyle :| wxFNB_NODRAG
		bookStyle :| wxFNB_CUSTOM_DLG
		bookStyle :| wxFNB_NO_X_BUTTON
	
		g1_notebook = New wxFlatNotebook.CreateFNB(group1, wxID_ANY,,,,, bookStyle)
		g1_notebook.SetCustomizeOptions(wxFNB_CUSTOM_TAB_LOOK | wxFNB_CUSTOM_LOCAL_DRAG | wxFNB_CUSTOM_FOREIGN_DRAG )
		
		'g1_notebook = New wxFlatNotebook.Create(group1, wxID_ANY,,,,, wxAUI_NB_TAB_MOVE )
		
		

		g1_sizer.Add(g1_notebook, 1, wxEXPAND, 5)
		
		group1.SetSizer(g1_sizer)
		group1.Layout()
		g1_sizer.Fit(group1)

		conSizer.Add(group1, 1, wxEXPAND, 5)

		conPanel.SetSizer(conSizer)
		conPanel.Layout()
		conSizer.Fit(conPanel)
		m_sizer.Add(conPanel, 1, wxEXPAND, 5)	'frameSizer.Add(conPanel, 1, wxEXPAND, 5)
		
		myframe.SetSizer(m_sizer)
		myframe.Layout()
		myframe.Center(wxBOTH)
		
		
		ConnectEvents()
	EndMethod
	
	Method ConnectEvents()
		'g1_toolbar1.connect(userID_REFRESH, wxEVT_COMMAND_TOOL_CLICKED, OnToolRefresh, Null, Self)
		'g1_toolbar3.connect(userID_NEW, wxEVT_COMMAND_TOOL_CLICKED, OnToolRefresh, Null, Self)
		'g1_toolbar3.connect(userID_SEARCH, wxEVT_COMMAND_TOOL_CLICKED, OnToolRefresh, Null, Self)
		'g1_mainListview.Connect(listID_FILTER_WEEK, wxEVT_COMMAND_MENU_SELECTED, OnMenuFilterWeek)
	EndMethod
	
	
EndType

Type TGroup1_main Extends TGroup1
	
	Global remarks:TMap, orders:TMap, updates:TList
	
	Field _lines:Int, _totalQty:Int
	
	Field g1_mainInfo:wxStaticText
	Field g1_mainPanel:wxPanel
	Field g1_mainListview:TListview
	'Field g1_mainToolbar:wxToolBar
	'Field g1_mainToolChoice:wxChoice
	Field g1_mainLine_1:wxStaticLine
	Field g1_mainLine_2:wxStaticLine
	
	Function Create:TGroup1_main()
		Local r:TGroup1_main = New TGroup1_main
		r.OnInit()
		Return r
	End Function
	
	Method OnInit()
		
		g1_mainPanel = New wxPanel.Create(g1_notebook, wxID_ANY,,,,, wxTAB_TRAVERSAL)

		Local g1_mainSizer:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		g1_mainLine_1 = New wxStaticLine.Create(g1_mainPanel, wxID_ANY,,,,, wxLI_HORIZONTAL)
		g1_mainSizer.Add(g1_mainLine_1, 0, wxEXPAND | wxALL, 5)
		
		'Toolbar

		
		g1_mainLine_2 = New wxStaticLine.Create(g1_mainPanel, wxID_ANY,,,,, wxLI_HORIZONTAL)
		g1_mainSizer.Add(g1_mainLine_2, 0, wxEXPAND | wxALL, 5)

		Rem
		'Editor
				
		g1_mainSizer.Add(g1_mainListview, 1, wxALL | wxEXPAND, 5)	
		EndRem
		
		g1_mainPanel.SetSizer(g1_mainSizer)
		g1_mainPanel.Layout()
		g1_mainSizer.Fit(g1_mainPanel)
		g1_notebook.AddPage(g1_mainPanel, _("untitled.bmx"), True)
		
		ConnectEvents()
	End Method
	
	Method ConnectEvents()
	EndMethod
	
	Method SetInfo(text:String = "")
		'g1_mainInfo.SetLabel("Status: " + text)
		'PollSystem()	'	;myframe.Refresh(); Delay 1
	End Method

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

