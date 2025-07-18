
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
Import wx.wxTreeCtrl
Import wx.wxSplitterWindow

Import wx.wxScintilla
Import wx.wxClipboard
Import wx.wxTextDataObject
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
Const APP_VERSION:String = "0.3.0"	' 
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

Const DEFAULT_EDITOR:Int = wxSCI_LEX_BLITZMAX

Const KEY_NEWLINE:Int = 370	'Numpad enter
Const KEY_DEL:Int = 127

Const wxEVT_MY_MODIFIED:Int = 1
Const MODIFIED_STATUSBAR:Int = 2
Const MODIFIED_FOLDLEVELS:Int = 3
Const MODIFIED_ADD:Int = 4
Const MODIFIED_DELETE:Int = 5
Const MODIFIED_SELECT:Int = 6
Const MODIFIED_SELECT_LINE:Int = 7
Const MODIFIED_TREE_ADD:Int = 8
Const MODIFIED_TREE_UPDATE:Int = 9
Const MODIFIED_TREE_DELETE:Int = 10

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
		myframe	= wxFrame(New wxFrame.Create(Null, wxID_ANY, APP_TITLE + "   Ver." + APP_VERSION, 770, 100, 900, height, wxDEFAULT_FRAME_STYLE | wxTAB_TRAVERSAL) )
		'myframe.SetForegroundColour(wxSystemSettings.GetColour(wxSYS_COLOUR_WINDOW) )
		myframe.SetBackgroundColour(New wxColour.Create(255, 255, 200) )
		
		'Local icon:wxIcon = New wxIcon.Create()
		'icon.LoadFile("graphics/icon.ico", wxBITMAP_TYPE_ICO)
		'If Not icon.IsOk() Then Throw("Can't load 'Icon.ico'")
		
		myframe.SetIcon( wxIcon.CreateFromFile("incbin::graphics\app.png", wxBITMAP_TYPE_PNG)  )
		'myframe.SetIcon( wxIcon.CreateFromFile("graphics\icon.png", wxBITMAP_TYPE_PNG) )
		
		'Create help window
		'myHelpFrame = wxFrame(New wxFrame.Create(Null, wxID_ANY, "Guide", - 1, - 1, width, height, wxDEFAULT_FRAME_STYLE | wxTAB_TRAVERSAL) )
		'myHelpWin = New wxHtmlWindow.Create(myHelpFrame, -1)
		'myHelpWin.LoadPage(RealPath("help.htm"))
			
		'DebugLog "Maxsize = " + w + " | " + h
		
		myframe.refresh()
		
		TWindow.Create()
		TConsole.Create()
		
		myframe.Layout()
		'myframe.Center(wxBOTH)
		myframe.show()
		'myHelpFrame.show()
				
		Return True
	End Method
	
End Type

Const editSTB_SIZEGRIP:Int = $0010

Type TWindow Extends TApp
	
	Global myEditor:TEditor
	Global myExplorer:TExplorer
	'Global mySplitter:TSplitter
	
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
	
	Method OnInit:Int()
		
		myFrame.SetSizer(w_sizer)
		
		w_statusbar = myframe.CreateStatusBar(1, 0 | editSTB_SIZEGRIP, wxID_ANY)
		
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
		myEditor.NewEditor()
	EndFunction

	Function OnToolOpen(ev:wxEvent)
		myEditor.OpenEditor()
	EndFunction

	Function OnToolClose(ev:wxEvent)
		myEditor.CloseCurrentEdit()
	EndFunction

	Function OnToolSave(ev:wxEvent)
		
		Local sci:TScintilla = myEditor.GetCurrentEdit()
		If Not sci Then DebugLog "OnToolSave -> No sci!"; Return
		If Not sci.file Then DebugLog "OnToolSave -> No file!"; Return
		
		'Print ""
		
		'For Local i:Int = 0 To sci.GetLineCount()	
		'	Print i + " | level = " + sci.GetFoldLevel(i) + " | " + sci.Getline(i).Trim() + " | " + sci.GetFoldParent(i)
		'Next
		
	EndFunction
	
EndType


Type TConsole Extends TWindow
	
	Global myCon:TConsole
	Global conPanel:wxPanel
	Global conSplitter:wxSplitterWindow
	Global conSizer:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
	'Global wxSplitterWindow
	
	
	Function Create()
		myCon = New TConsole
		myCon.OnInit()
	EndFunction
	
	Method OnInit:Int()
		
		conPanel = New wxPanel.Create(myframe, wxID_ANY,,,,, wxTAB_TRAVERSAL)
		conPanel.SetBackgroundColour(New wxColour.Create(255, 100, 255) )

		conSplitter = New wxSplitterWindow.Create(conPanel, wxID_ANY,,,,, wxSP_3D | wxSP_LIVE_UPDATE)		
		
		TEditor.Create()
		TExplorer.Create()
		
		'Testing code
		myEditor.NewEditor()
		myEditor.TestEditor()
		
		conPanel.SetSizer(conSizer)
		conPanel.Layout()
		w_sizer.Add(conPanel, 1, wxEXPAND, 5)
		
		conSplitter.SplitVertically(TEditor.e_panel, TExplorer.x_panel, 600)
		conSplitter.SetMinimumPaneSize(5)
		conSizer.Add(conSplitter, 1, wxEXPAND, 5)

	EndMethod
	
EndType


Type TEditor Extends TConsole
	
	Global e_panel:wxPanel
	Global e_book:wxFlatNotebook
	
	Global _sciList:TList = New TList
	Global _globalID:Int
	
	Function Create()
		myEditor = New TEditor
		TScintilla._parent = myEditor
		myEditor.OnInit()
	EndFunction
	
	Method OnInit:Int()
		
		LoadKeywords()
		
		Local e_sizer:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		e_panel = New wxPanel.Create(conSplitter, wxID_ANY,,,,, wxTAB_TRAVERSAL)
		e_panel.SetBackgroundColour( New wxColour.Create(100, 220, 200) )
		e_panel.SetSizer(e_sizer)
		
		Local bookStyle:Int
		
		'bookStyle:| wxFNB_VC71
		'bookStyle:| wxFNB_TABS_BORDER_SIMPLE
		'bookStyle:| wxFNB_CUSTOM_ALL
		'bookStyle:| wxFNB_NODRAG
		bookStyle:| wxFNB_CUSTOM_DLG
		bookStyle:| wxFNB_CUSTOM_CLOSE_BUTTON
		bookStyle:| wxFNB_DROPDOWN_TABS_LIST
		bookStyle:| wxFNB_NO_X_BUTTON
		
		e_book = New wxFlatNotebook.CreateFNB(e_panel, wxID_ANY,,,,, bookStyle)
		e_book.SetCustomizeOptions(wxFNB_CUSTOM_TAB_LOOK | wxFNB_CUSTOM_LOCAL_DRAG | wxFNB_CUSTOM_FOREIGN_DRAG )
		
		e_sizer.Add(e_book, 1, wxEXPAND, 5)	
		e_panel.Layout()

		ConnectEvents()
	EndMethod
	
	Method ConnectEvents()
		e_book.connect(wxID_ANY, wxEVT_COMMAND_FLATNOTEBOOK_PAGE_CHANGING, OnPageChange, Self, Self )
	EndMethod
	
	Function OnPageChange(ev:wxEvent)
		
		Local nev:wxFlatNotebookEvent = wxFlatNotebookEvent(ev)
		If Not nev Then DebugLog "No flatnotebook event"; Return
		
		DebugLog "Current page = " + nev.GetSelection() + " | old = " + nev.GetOldSelection()
		
		Local index:Int = nev.GetSelection()
		Local oldIndex:Int = nev.GetOldSelection()
		
		If index = oldIndex Then Return
		
		Local book:wxFlatNotebook = wxFlatNotebook(ev.parent)
		If Not book Then DebugLog "No book"; Return
		
		Local sci:TScintilla = TScintilla(book.GetPage(index) )
		If Not sci Then DebugLog "No scintilla!"; Return
		
		TEditor.SetActive(sci)
		
	EndFunction
	
	Method TestEditor()
		
		Local t:String = ""+..
			"'TEST~n"+..
			"~qHello world~q Hello Double Int 123~n~n"+..
			"Extern~n"+..
			"~tFunction D(a:int, b:int, c:int)~n"+..
			"EndExtern~n~n"+..
			"Rem~n"+..
			"commented~n"+..
			"Endrem~n~n"+..
			"Function Test1()~n"+..
			"~tPrint ~qHello world1~q~n~n"+..
			"~tFunction Test_sub1()~n"+..
			"~t~tPrint ~qHello sub1~q~n"+..
			"~tEndFunction~n~n"+..
			"EndFunction~n~n"+..
			"~nConst MY_CONSTANT:Int = 123~n~n"+ ..
			"Function Test2()~n"+..
			"~tPrint ~qHello world2~q~n"+..
			"End Function~n~n"+..
			"Type TestType~n~n"+..
			"~tField x:Int = 1~n"+..
			"~tField y:Int = 2~n"+..
			"~tField z:Int = 3~n~n"+..
			"~tGlobal list:TList = New Tlist~n~n"+..
			"~tMethod Draw()~n~n"+..
			"~t~t'Todo~n"+..
			"~tEndMethod~n"+..
			"EndType~n"+..
			""+..
			""+..
			""

		'sci.EmptyUndoBuffer()
		
		Local sci:TScintilla = GetCurrentEdit()
		sci.file.text = t
		sci.AnalyzeFile()
	EndMethod
	
	Method CloseCurrentEdit()
		
		Local index:Int = e_book.GetSelection()
		
		DebugLog "CloseEdit -> index = " + index
		
		Local sci:TScintilla = GetCurrentEdit()
		If Not sci Then
			Notify "Error: No editor to close."
		Else
			TExplorer.RemoveTree(sci._tree)
			RemoveEdit(sci)
		EndIf
		
		e_book.DeletePage(index)
		index = e_book.GetSelection()
		
		If index = -1 Then	'Last open editor instance
			DebugLog "CloseEdit -> Last!"
			
			NewEditor(DEFAULT_EDITOR, True)
		Else
			TEditor.SetActive( GetCurrentEdit() )
		EndIf
		
		'DebugLog "CloseEdit -> index_after = " + index
		
	EndMethod
	
	Method GetCurrentEdit:TScintilla()
		Return TScintilla( e_book.GetCurrentPage() )
	EndMethod
	
	Method GetNewID:Int()
		_globalID:+ 1
		Return _globalID
	EndMethod
	
	Function GetSciList:TList()
		Return _sciList
	EndFunction
	
	Method LoadKeywords()
		
		Local keywords_1:String, keywords_2:String, traceWords:String
		
		keywords_1 = "Abs Abstract Alias And Asc Assert Case Catch Chr Const Continue Default DefData Delete EachIn " +..
					"Else ElseIf End EndExtern EndFunction EndIf EndMethod EndRem EndSelect EndTry EndType Exit Extends Extern " +..
					"False Field Final For Forever Framework Function Global Goto If Import Incbin IncbinLen IncbinPtr Include " +..
					"Len Local Max Method Min Mod Module ModuleInfo New Next Not Null Object Or Pi Print Private Public ReadData " +..
					"Release Rem Repeat RestoreData Return Sar Select Self Sgn Shl Shr SizeOf Step Strict Super Then Throw " +..
					"To True Try Type Until Var VarPtr Wend While"
					
		keywords_2 = "Byte Double Float Int Long Ptr Short String"
		
		traceWords = "Function Type Method"
		
		TWord.LoadKeywords(keywords_1, wxSCI_B_KEYWORD)
		TWord.LoadKeywords(keywords_2, wxSCI_B_KEYWORD2)
		TWord.SetTraceWords(traceWords)
		TWord.SetKeywords()
		
	EndMethod
	
	Method NewEditor:Int(lexer:Int = DEFAULT_EDITOR, initial:Int = False)
		Local sci:TScintilla = TScintilla( New TScintilla.Create( e_book, wxID_ANY,,,,, 0) )
		If Not sci Then Notify "Error: Could not create scintilla"; Return False
		
		'If all instances are closed then reset file numbering
		If initial Then _globalID = 0
		
		Local name:String
		
		name = "untitled" + GetNewID() + ".bmx"
		sci.file = TFile.Create(name)
		sci._tree = myExplorer.NewTree(name)
		
		_sciList.AddLast(sci)
		e_book.AddPage(sci , name, True)
		
		Return True
	EndMethod
	
	Method OpenEditor:Int()
		
		Local file:TFile = TFile.LoadFile()
		If Not file Then Return False
		
		Local sci:TScintilla = TScintilla( New TScintilla.Create( e_book, wxID_ANY,,,,, 0) )
		If Not sci Then Notify "Error: Could not create scintilla"; Return False
		
		sci._tree = myExplorer.NewTree(file.name)
		sci.file = file
		
		_sciList.AddLast(sci)
		e_book.AddPage(sci , file.name, True)
		
		sci.AnalyzeFile()
		
		Return True
		
	EndMethod
	
	Method RemoveEdit(sci:TScintilla)
		If Not sci Then Return
		
		_sciList.remove(sci)
	EndMethod
	
	Function SetActive(sci:TScintilla)
		If Not sci Then Return
		
		TExplorer.SetActive(sci)
	EndFunction
	
	Function SetEvent(id:Int, lines:Int = 0)
		
		Local sci:TScintilla = myEditor.GetCurrentEdit()
		If Not sci Then Return
		
		sci.SetEvent(id, lines)
	EndFunction
	
	Function SetPosition(curPos:Int, prevPos:Int, line:Int, sel_start:Int, sel_end:Int)
		myWin.w_statusbar.SetStatusText("curPos = "+curPos+" | previousPos = "+prevPos+" | line = "+line+" | sel_start = "+sel_start+" | sel_end = "+sel_end)
	EndFunction
	
EndType

Rem
Type TSplitter Extends TConsole
	
	Field s_line:wxStaticLine
	
	Function Create()
		mySplitter = New TSplitter
		mySplitter.OnInit()
	EndFunction
	
	Method OnInit:Int()
			
		s_line = New wxStaticLine.Create(conPanel , wxID_ANY,,,5,, wxLI_VERTICAL );
		conSizer.Add( s_line, 0, wxEXPAND | wxALL, 5 )
	EndMethod
	
	Method ConnectEvents()
	EndMethod
	
EndType
EndRem

Type TExplorer Extends TConsole
	
	Global x_panel:wxPanel
	Global x_codePanel:wxPanel
	Global x_book:wxFlatNotebook
	
	Global x_codeSizer:wxBoxSizer = New wxBoxSizer.Create( wxVERTICAL )
	Field x_codeBar:wxStaticText
	'Field x_tree:TTreeCtrl
	
	Function Create()
		myExplorer = New TExplorer
		TTreeCtrl._parent = myExplorer
		myExplorer.OnInit()
	EndFunction
	
	Method OnInit:Int()
		
		Local x_sizer:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		x_panel = New wxPanel.Create(conSplitter, wxID_ANY,,,,, wxTAB_TRAVERSAL)
		x_panel.SetBackgroundColour( New wxColour.Create(200, 100, 200) )
		
		Local bookStyle:Int
		
		bookStyle :| wxFNB_CUSTOM_DLG
		bookStyle :| wxFNB_CUSTOM_CLOSE_BUTTON
		bookStyle :| wxFNB_DROPDOWN_TABS_LIST
		bookStyle :| wxFNB_NO_X_BUTTON
				
		x_book = New wxFlatNotebook.CreateFNB(x_panel, wxID_ANY,,,,, bookStyle)
		x_book.SetCustomizeOptions(wxFNB_CUSTOM_TAB_LOOK | wxFNB_CUSTOM_LOCAL_DRAG | wxFNB_CUSTOM_FOREIGN_DRAG )
		
		x_codePanel = New wxPanel.Create( x_book, wxID_ANY,,,,, wxTAB_TRAVERSAL )
		'Local x_codeSizer:wxBoxSizer = New wxBoxSizer.Create( wxVERTICAL )
		
		Local x_barPanel:wxPanel = New wxPanel.Create( x_codePanel, wxID_ANY,,,,, wxTAB_TRAVERSAL )
			'x_barPanel.SetForegroundColour( New wxColour.Create( 64, 0, 64 ) )
			'x_barPanel.SetBackgroundColour( New wxColour.Create( 251, 202, 245 ) )
			
		Local x_barSizer:wxBoxSizer = New wxBoxSizer.Create( wxVERTICAL )
		
		x_codeBar = New wxStaticText.Create( x_barPanel, wxID_ANY, "",,,,, 0 )
		
		x_panel.SetSizer(x_sizer)
		x_sizer.Add(x_book, 1, wxEXPAND, 5)
		
		x_barSizer.Add( x_codeBar, 0, wxALL, 5 )
		
		x_barPanel.SetSizer( x_barSizer )
		x_barPanel.Layout()
		x_codeSizer.Add( x_barPanel, 0, wxLEFT|wxRIGHT|wxTOP|wxEXPAND, 0 )
		
		'x_tree = TTreeCtrl(New TTreeCtrl.Create( x_codePanel, wxID_ANY,,,,, wxTR_DEFAULT_STYLE|wxTR_HIDE_ROOT ))
		'x_codeSizer.Add( x_tree, 1, wxBOTTOM|wxEXPAND|wxLEFT|wxRIGHT, 0 )
		
		x_codePanel.SetSizer( x_codeSizer )
		x_codePanel.Layout()
		x_codeSizer.Fit( x_codePanel )
		x_book.AddPage( x_codePanel, ("Code tree"), False )
		
		ConnectEvents()
	EndMethod
	
	Method ConnectEvents()
	EndMethod
	
	Rem
	Method CloseCurrentTree:Int()
		Local sci:TScintilla = TEditor.myEditor.GetCurrentEdit()
		If Not sci Then Notify("Error: Could not close current tree", True); Return False
		
		sci._tree.DeleteAllItems()
		sci._tree.Destroy()
	EndMethod
	EndRem
	
	Function GetCurrentTree:TTreeCtrl()
		Local sci:TScintilla = TEditor.myEditor.GetCurrentEdit()
		If Not sci Then Notify("Error: Could not get current tree", True); Return Null
		
		Return sci._tree
	EndFunction
	
	Method NewTree:TTreeCtrl(name:String)	', isShown:Int = True)
		
		Local tree:TTreeCtrl = TTreeCtrl(New TTreeCtrl.Create( x_codePanel, wxID_ANY,,,,, wxTR_DEFAULT_STYLE|wxTR_HIDE_ROOT ))
		x_codeSizer.Add( tree, 1, wxBOTTOM|wxEXPAND|wxLEFT|wxRIGHT, 0 )
		
		tree._tag = name
		
		SetFile(name)
		'If Not isShown Then tree.Hide()
		
		For Local sci:TScintilla = EachIn TEditor.GetSciList()
			sci._tree.Hide()
		Next
		
		Refresh()
		
		Return tree
	EndMethod
		
	Function Refresh()
		x_codeSizer.Layout()
	EndFunction

	Function RemoveTree:Int(tree:TTreeCtrl)
		
		If Not tree Then Notify("Error: Could not remove tree", True); Return False
		tree.DeleteAllItems()
		tree.Destroy()
		
		Return True
	EndFunction
		
	Function SetActive(sci:TScintilla)
		
		If Not sci Then Return
		
		
		
		For Local tmpSci:TScintilla = EachIn TEditor.GetSciList()
			
			If tmpSci = sci Then
				sci._tree.Show()
				myExplorer.SetFile(sci.file.name)
				Continue
			EndIf
			
			tmpSci._tree.Hide()
		Next
		
		TExplorer.Refresh()
	EndFunction
	
	Function SetEvent(m:TModified)
		
		DebugLog "TExplorer - SetEvent | m = " + (m <> Null)
		If Not m Then Return
		
		Local tree:TTreeCtrl = TExplorer.GetCurrentTree()
		If Not tree Then Return
		
		tree.SetEvent(m)
	EndFunction
	
	Method SetFile(name:String)
		x_codeBar.SetLabel(name)
	EndMethod
EndType


Type TScintilla Extends wxScintilla

	Global _parent:TEditor	
	Global _evtQueue:TList = New TList
	
	'Linked treeview
	Field _tree:TTreeCtrl
	
	'File info
	Field file:TFile
	
	'Caret tracking
	Field _caretPos:Int = -1
	Field _updatePos:Int
	
	'Search text
	Field _searchText:String
	
	Field sciMenu:wxMenu
	
	Method OnInit:Int()
		
		' Default style
		'-----------------------------
		'sci.StyleResetDefault()
		'Local font:wxFont = New wxFont.CreateWithAttribs(13, wxTELETYPE, wxNORMAL, wxNORMAL,, "consolas")
		Local font:wxFont = New wxFont.CreateWithAttribs(13, wxMODERN , wxNORMAL, wxNORMAL,, "consolas")
		
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
		SetLexerStyle(wxSCI_LEX_BLITZMAX)	'	wxSCI_LEX_CONTAINER)	'
		'SetProperty("fold", True)	'Use custom folding
		'SetProperty("fold.compact", False)
		'SetProperty("fold.basic.syntax.based", True)
		
		'RightClick menu
		'---------------
		sciMenu = New wxMenu.Create()
		sciMenu.Append(wxID_UNDO)
		sciMenu.Append(wxID_REDO)
		sciMenu.AppendSeparator()
		sciMenu.Append(wxID_CUT)
		sciMenu.Append(wxID_COPY)
		sciMenu.Append(wxID_PASTE)
		sciMenu.Append(wxID_DELETE)
		sciMenu.AppendSeparator()
		sciMenu.Append(wxID_SELECTALL)
		sciMenu.AppendSeparator()
		sciMenu.Append(wxID_FIND)
		sciMenu.Append(wxID_REPLACE)
		
		
		'Miscellaneous
		'-------------
		AutoCompSetIgnoreCase(True)
		SetTabWidth(3)
		
		
		UsePopUp(0)
		SetLayoutCache(wxSCI_CACHE_PAGE)
		SetBufferedDraw(1)
		
		ConnectEvents()
	End Method
	
	Method ConnectEvents()
		
		'Context Menu
		ConnectAny(wxEVT_CONTEXT_MENU, OnMenu)
		ConnectAny(wxEVT_COMMAND_MENU_SELECTED, OnMenuSelected)
		
		
		ConnectAny(wxEVT_KEY_DOWN, OnKeyDown)
		ConnectAny(wxEVT_SCI_CHARADDED, OnCharAdded)
		ConnectAny(wxEVT_SCI_MARGINCLICK, OnMarginClick)
		ConnectAny(wxEVT_SCI_MODIFIED, OnModified)
		'ConnectAny(wxEVT_SCI_STYLENEEDED, OnStyleNeeded)
		ConnectAny(wxEVT_SCI_UPDATEUI, OnUpdateUI)
		'ConnectAny(wxEVT_SCI_CHANGE, OnChange)
		ConnectAny(wxEVT_SCI_AUTOCOMP_SELECTION, OnAutocompSelection)
		ConnectAny(wxEVT_MY_MODIFIED, OnMyModified)
	EndMethod
	
	Function OnAutocompSelection(ev:wxEvent)
		
		Local sci:TScintilla = TScintilla( ev.parent )
		If Not sci Then DebugLog "No sci!"; Return
		
		DebugLog "OnAutocompSelection -> " + sci._caretPos
		
	EndFunction
	
	
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
		
		DebugLog "OnChange -> lenEntered = " + lenEntered + " | start = " + startPos + " | curPos = " + curPos + " | Key = " + sev.GetModificationType()+..
				"|Length="+sev.GetLength()+"|line="+sev.GetLine()+"|text="+sev.GetText()+"|linesAdded="+sev.GetLinesAdded()
		
	EndFunction
	
	Function OnCharAdded(ev:wxEvent)
		
		Local sci:TScintilla = TScintilla( ev.parent )
		If Not sci Then DebugLog "No sci!"; Return
		
		Local curPos:Int = sci.GetCurrentPos()
		Local startPos:Int = sci.WordStartPosition(curPos, True)
		'Local chars:String = sci.getWordChars()
		Local lenEntered:Int = curPos - startPos
		Local charEntered:Int = sci.GetCharAt(curPos - 1)
		Local charNext:Int = sci.GetCharAt(curPos)
		Local isLetter:Int = charEntered > 64 And charEntered < 91 Or charEntered > 96 And charEntered < 123
		Local isNextLetter:Int = charNext > 64 And charNext < 91 Or charNext > 96 And charNext < 123

		sci.SetPreviousPos( curPos )
		
		'DebugLog "OnCharAdded -> isLetter = " + isLetter + " | start = " + startPos + " | curPos = " + curPos + " | charEntered = " + charEntered + " | prevPos = " + sci.GetPreviousPos()
		
		If lenEntered > 1 Then
			If Not isNextLetter
				If Not sci.AutoCompActive() Then
					sci.AutoCompShow(lenEntered, TWord.GetAutoKeywords())
				EndIf		
			EndIf
		EndIf
		
		Rem
		ElseIf lenEntered = 0
			
			If sci.GetPreviousPos() > -1 Then
				Print "OnCharAdded -> UPDATE POSITION"
			EndIf
		EndIf
		EndRem
		
	EndFunction
	
	
	
	Function OnKeyDown(ev:wxEvent)

		Local sci:TScintilla = TScintilla(ev.sink)
		If Not sci Then Notify "Scintilla not found!!"; Return
		
		Local key_ev:wxKeyEvent = wxKeyEvent(ev)
		If Not key_ev Then Return
		
		Local keyCode:Int = key_ev.GetKeyCode()
		Local curPos:Int = sci.GetCurrentPos()
		
		'Local key:String = Chr(keyCode)
		'DebugLog key + " | " + keyCode
		
		Select keyCode
		
		Case KEY_BACKSPACE, KEY_DEL
			
			sci.SetPreviousPos( curPos - 1, True )
			
		Case KEY_TAB, KEY_ENTER, KEY_SPACE, KEY_NEWLINE
			
			If sci.AutoCompActive() Then
				ev.skip()
				Return
			EndIf
			
			Local startPos:Int = sci.WordStartPosition(curPos, True)
			Local lenEntered:Int = curPos - startPos
			Local txt:String = sci.GetTextRange(startPos, curPos)
			Local line:Int = sci.LineFromPosition(curPos)
			
			If lenEntered > 0 Or keyCode = KEY_ENTER Or keyCode = KEY_NEWLINE Then
			
				DebugLog "KEY_ENTER -> line = " + line + " | text = " + txt
				
				' Update tree
				Local m:TModified = TModified.CreateLine(MODIFIED_TREE_UPDATE, line, 1)	'Single press means count = 1
				TExplorer.SetEvent(m)
				
				sci.SetSavePoint()
				sci.Analyze(startPos, curPos)
			EndIf
			
			sci.SetPreviousPos(curPos + 2, True)
		
		Case KEY_X

			If key_ev.ControlDown() Then
				sci.Cut()
				Return
			EndIf
			
		Case KEY_V
			
			If key_ev.ControlDown() Then
				sci.Paste()
				Return
			EndIf
		
		Case KEY_F

			If key_ev.ControlDown() Then
				sci.Find()
			EndIf	
			
		Case WXK_UP
		
			If key_ev.ShiftDown() Then
				
				If sci.GetPreviousPos() > -1 Then
							
					Local curPos:Int = sci.GetCurrentPos()
					'If sci._updatePos Then
					'	sci.SetPreviousPos(curPos); sci._updatePos = False
					'EndIf
					
					
					Local prevPos:Int = sci.GetPreviousPos()
					Local prevStartPos:Int = sci.WordStartPosition(prevPos, True)
					Local prevEndPos:Int = sci.WordEndPosition(prevPos, True)
					
					'DebugLog "WXK_UP -> prevPos = " + sci.GetPreviousPos() + " |prevStart = " + prevStartPos + " |prevEnd = " + prevEndPos + " |txt = " + sci.GetTextRange(prevStartPos, prevEndPos)
					
					If curPos > prevStartPos Or curPos <= prevEndPos Then
						
						DebugLog "WXK_UP -> UPDATE!"
						
						sci.Analyze(prevStartPos, prevEndPos)
						sci.SetPreviousPos(-1)
						
					EndIf
					
				EndIf
				
			EndIf
		Case WXK_DOWN
		
				If key_ev.ShiftDown() Then
				
				If sci.GetPreviousPos() > -1 Then
							
					Local curPos:Int = sci.GetCurrentPos()
					'If sci._updatePos Then
					'	sci.SetPreviousPos(curPos); sci._updatePos = False
					'EndIf
					
					
					Local prevPos:Int = sci.GetPreviousPos()
					Local prevStartPos:Int = sci.WordStartPosition(prevPos, True)
					Local prevEndPos:Int = sci.WordEndPosition(prevPos, True)
					
					'DebugLog "WXK_UP -> prevPos = " + sci.GetPreviousPos() + " |prevStart = " + prevStartPos + " |prevEnd = " + prevEndPos + " |txt = " + sci.GetTextRange(prevStartPos, prevEndPos)
					
					If curPos > prevStartPos Or curPos <= prevEndPos Then
						
						DebugLog "WXK_DOWN -> UPDATE!"
						
						sci.Analyze(prevStartPos, prevEndPos)
						sci.SetPreviousPos(-1)
						
					EndIf
					
				EndIf
				
			EndIf
			
		EndSelect
		
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
		
		If (margin = 1 And headerFlag) Then		
			sci.ToggleFold(line)
		EndIf
		
		
	EndFunction
	
	Function OnMenu(ev:wxEvent)
	
		DebugLog "OnMenu"
	
		Local sci:TScintilla = TScintilla(ev.parent)
		If Not sci Then DebugLog "OnContextMenu -> No sci!"; ev.skip(); Return 
		
		Local x:Int, y:Int
		wxContextMenuEvent(ev).GetPosition(x, y)
		
		' If from keyboard
		If x = - 1 And y = - 1 Then
			Local w:Int, h:Int
			sci.GetSize(w, h)
			x = w / 2
			y = h / 2
		Else
			sci.ScreenToClient(x, y)
		End If
		
		sci.ShowContextMenu(x, y)
		ev.skip()
	End Function


	Function OnMenuSelected(ev:wxEvent)
	
		DebugLog "OnMenuSelected"
		
		Local sci:TScintilla = TScintilla(ev.parent)
		If Not sci Then DebugLog "OnMenuSelected -> No sci"; ev.Skip(); Return
		
		'DebugStop
		
		'Local cev:wxCommandEvent = wxCommandEvent(ev)
		'If Not cev Then DebugLog "OnMenuSelected -> No menu!"; ev.skip(); Return
		
		sci.ProcessMenu( ev.GetID() )
		
		ev.skip()
	EndFunction
	
	Function OnModified(ev:wxEvent)
		
		'DebugLog "TScintilla -> OnModified"
		
		Local sci:TScintilla = TScintilla( ev.parent )
		If Not sci Then DebugLog "No sci!"; Return
		
		Local sev:wxScintillaEvent = wxScintillaEvent(ev)
		If Not sev Then DebugLog "OnModified -> No ScintillaEvent!"; Return
		
		Local modType:Int = sev.GetModificationType()
		
		'If modType & wxSCI_MOD_DELETETEXT Then DebugLog "wxSCI_MOD_DELETETEXT"
		'If modType & wxSCI_MOD_CHANGESTYLE Then DebugLog "wxSCI_MOD_CHANGESTYLE"
		'If modType & wxSCI_MOD_CHANGEFOLD Then DebugLog "wxSCI_MOD_CHANGEFOLD"
		'If modType & wxSCI_PERFORMED_USER Then DebugLog "wxSCI_PERFORMED_USER"
		
		If modType & wxSCI_PERFORMED_UNDO Or modType & wxSCI_PERFORMED_REDO Then
			If modType & wxSCI_MOD_DELETETEXT
				DebugLog "UNDO/REDO (Delete):  Length="+sev.GetLength()+"|line="+sev.GetLine()+"|text="+sev.GetText()+"|linesAdded="+sev.GetLinesAdded()
				sci.SetEvent(MODIFIED_DELETE, sev.GetLinesAdded() )
			ElseIf modType & wxSCI_MOD_INSERTTEXT
				DebugLog "UNDO/REDO (Insert):  Length="+sev.GetLength()+"|line="+sev.GetLine()+"|text="+sev.GetText()+"|linesAdded="+sev.GetLinesAdded()
				sci.SetEvent(MODIFIED_ADD, sev.GetLinesAdded() )
			EndIf
		EndIf
		
	EndFunction
	
	Function OnMyModified(ev:wxEvent)
		
		'DebugLog "TScintilla -> OnMyModified"
		
		Local sci:TScintilla = TScintilla( ev.parent )
		If Not sci Then DebugLog "No sci!"; Return
		
		For Local m:TModified = EachIn _evtQueue
			
			Select m.id
			
			Case MODIFIED_STATUSBAR			
				
				Local curPos:Int = sci.GetCurrentPos()
				Local prevPos:Int = sci.GetPreviousPos()
				Local sel_start:Int, sel_end:Int
				sci.GetSelection(sel_start, sel_end)
				_parent.SetPosition( curPos, prevPos, sci.LineFromPosition(curPos), sel_start, sel_end )
				
			Case MODIFIED_FOLDLEVELS
				
				Local start:Int = sci.LineFromPosition( sci.GetCurrentPos() ) - 1
				Local stop:Int = start + 1
				
				'DebugLog "OnMyModified -> FOLDLEVELS | start = " + start + " | stop = " + stop
				'DebugLog "OnMyModified -> FOLDLEVELS | level = " + sci.GetFoldLevel(start) + " | startLine = " + sci.GetLine( sci.LineFromPosition(start) )
				'DebugLog "OnMyModified -> FOLDLEVELS | level = " + sci.GetFoldLevel(stop) + " | stopLine = " + sci.GetLine( sci.LineFromPosition(start) )
				
				sci.SetFoldLevels(start, stop)
				
			Case MODIFIED_ADD
				
				Local line:Int = m.line
				Local start:Int = sci.LineFromPosition( sci.GetCurrentPos() ) - 2
				Local stop:Int = start + line
				
				DebugLog "OnMyModified -> ADD | start = " + start + " | stop = " + stop
				
				sci.SetFoldLevels(start, stop)
				
			Case MODIFIED_DELETE
				
				'Local start:Int = sci.LineFromPosition( sci.GetCurrentPos() ) - 1
				'Local stop:Int = start + 1
				
				'DebugLog "OnMyModified -> DELETE | start = " + start + " | stop = " + stop
			
			'Case MODIFIED_SELECT
				
			'	DebugLog "MODIFIED_SELECT -> curPos = " + sci.GetCurrentPos() + " | lines = " + m.lines
			
			Case MODIFIED_SELECT_LINE
				
				Local line:Int = m.line
				Local start:Int = sci.GetLineIndentPosition(line)
				Local stop:Int = sci.GetLineEndPosition(line)
				
				DebugLog "OnMyModified -> SELECT | start = " + start + " | stop = " + stop
				
				sci.GotoLine(line)
				sci.SetSelection(start, stop)
				sci.SetFocus()
			Default
				DebugLog "OnMyModified -> ID not found!"
			EndSelect
		Next
		
		_evtQueue.Clear()
	EndFunction
	
	
	Function OnStyleNeeded(ev:wxEvent)
		
		DebugLog "OnStyleNeeded"
	
	
		Rem	
		void myFrame::OnStyleNeeded(wxStyledTextEvent& event) {
		/*this is called every time the styler detects a line that needs style, so we style that range.
		This will save a lot of performance since we only style text when needed instead of parsing the whole file every time.*/
		size_t line_end=m_activeSTC->LineFromPosition(m_activeSTC->GetCurrentPos());
		size_t line_start=m_activeSTC->LineFromPosition(m_activeSTC->GetEndStyled());
		/*fold level: May need To Include the two lines in front because of the fold level these lines have- the line above
		May be affected*/
		If(line_start>1) {
			line_start-=2;
		} Else {
			line_start=0;
		}
		//If it is so small that all lines are visible, style the whole document
		If(m_activeSTC->GetLineCount()==m_activeSTC->LinesOnScreen()){
			line_start=0;
			line_end=m_activeSTC->GetLineCount()-1;
		}
		If(line_end<line_start) {
			//that happens when you Select parts that are in front of the styled area
			size_t temp=line_end;
			line_end=line_start;
			line_start=temp;
		}
		//style the line following the style area too (If present) in Case fold level decreases in that one
		If(line_end<m_activeSTC->GetLineCount()-1){
			line_end++;
		}
		//get exact start positions
		size_t startpos=m_activeSTC->PositionFromLine(line_start);
		size_t endpos=(m_activeSTC->GetLineEndPosition(line_end));
		Int startfoldlevel=m_activeSTC->GetFoldLevel(line_start);
		startfoldlevel &= wxSTC_FOLDFLAG_LEVELNUMBERS; //mask out the flags And only use the fold level
		wxString text=m_activeSTC->GetTextRange(startpos,endpos).Upper();
		//call highlighting Function
		this->highlightSTCsyntax(startpos,endpos,text);
		//calculate And apply foldings
		this->setfoldlevels(startpos,startfoldlevel,text);
	 }
	EndRem
		
	EndFunction
	
	Function OnUpdateUI(ev:wxEvent)
		
		'DebugLog "OnUpdateUI"
		
		Local sci:TScintilla = TScintilla( ev.parent )
		If Not sci Then DebugLog "No sci!"; Return
		
		'Show current position in statusbar
		'Local data:TData = New TData
		'data.curPos = curPos
		If sci.GetPreviousPos() > -1 Then
						
			Local curPos:Int = sci.GetCurrentPos()
			If sci._updatePos Then
				sci.SetPreviousPos(curPos); sci._updatePos = False
			EndIf
			
			
			Local prevPos:Int = sci.GetPreviousPos()
			Local prevStartPos:Int = sci.WordStartPosition(prevPos, True)
			Local prevEndPos:Int = sci.WordEndPosition(prevPos, True)
			
			'DebugLog "OnUpdateUI -> prevPos = " + sci.GetPreviousPos() + " |prevStart = " + prevStartPos + " |prevEnd = " + prevEndPos + " |txt = " + sci.GetTextRange(prevStartPos, prevEndPos)
			
			If curPos < prevStartPos Or curPos > prevEndPos Then
				
				DebugLog "OnUpdateUI -> UPDATE!"
				
				sci.Analyze(prevStartPos, prevEndPos)
				sci.SetPreviousPos(-1)
			EndIf
			
		EndIf
		
		sci.SetEvent(MODIFIED_STATUSBAR)
	EndFunction
	
	
	Method Analyze(startPos:Int, endPos:Int, isPaste:Int = False, file:TFile = Null)
		
		'DebugLog "Analyze -> prevPos = " + GetPreviousPos() + " |start = " + startPos + " |End = " + endPos + " |txt = " + GetTextRange(startPos, endPos)
		
		Local txt:String
		Local curPos:Int = GetCurrentPos()

		If Not isPaste Then 
			
			If startPos = endPos Then
				If TOptions.opt.folding Then SetEvent(MODIFIED_FOLDLEVELS)
				Return
			EndIf
			
			txt = TWord.GetName( GetTextRange(startPos, endPos) )
			
			If TWord.isMatch() Then
				
				'DebugLog "Analyze -> isMatch!(" + txt + ") | curPos = " + curPos
				
				If TOptions.opt.autoCap Then
					
					Local selStart:Int, selEnd:Int, isSelected:Int
					GetSelection(selStart, selEnd)
					
					isSelected = (selEnd - selStart > 0)
					'If isSelected Then DebugLog "isMatch -> SELECTION EXISTS!"
					
					SetUndoCollection(False)
					DeleteRange(startPos, endPos - startPos)
					InsertText(startPos, txt)
					'AddText(txt)
					SetUndoCollection(True)	
					SetSelection(curPos, curPos)
					
					If isSelected Then SetSelection(selStart, selEnd)
				EndIf
				
				If TOptions.opt.folding Then
					
					Local start:Int = LineFromPosition(startPos)
					Local stop:Int = LineFromPosition(endPos)
					SetFoldLevels(start, stop)
				EndIf
				
			EndIf
		Else
		
			txt = GetClipboard()
			
			'DebugLog "Analyze -> Paste(" + txt + ") | curPos = " + curPos + " | stop = " + (curPos + txt.length)
			
			If txt Then
				
				If TOptions.opt.autoCap Then txt = TWord.Parse(txt, LineFromPosition(curPos))
				
				'Check selected text and clear before adding
				Local selStart:Int, selEnd:Int
				GetSelection(selStart, selEnd)
				
				If (selStart - selEnd) <> 0 Then DeleteBack()
				
				AddText(txt)
				EnsureCaretVisible()
				SetPreviousPos( curPos)
			
				If TOptions.opt.folding Then
					
					Local start:Int = LineFromPosition(curPos)
					Local stop:Int = LineFromPosition(curPos + txt.length )
					
					SetFoldLevels(start, stop)
				EndIf
				
			EndIf
		EndIf
		
	EndMethod
	
	
	Method AnalyzeFile()
		
		If Not file Then Notify("Error: File is missing.", True); Return
		'DebugLog "Analyze -> prevPos = " + GetPreviousPos() + " |start = " + startPos + " |End = " + endPos + " |txt = " + GetTextRange(startPos, endPos)
		
		Local curPos:Int = GetCurrentPos()
		
		DebugLog "AnalyzeFile --> " + file.name	'~n" + file.text	' + ") | curPos = " + curPos + " | stop = " + (curPos + txt.length)
		
		If file.text Then
			
			file.text = TWord.Parse(file.text)
			
			AddText(file.text)
			EmptyUndoBuffer()
			'EnsureCaretVisible()
			'SetPreviousPos( curPos)
		
			If TOptions.opt.folding Then
				
				Local start:Int = LineFromPosition(curPos)
				Local stop:Int = LineFromPosition(curPos + file.text.length )
				
				SetFoldLevels(start, stop)
			EndIf
			
		EndIf
	
	EndMethod
			
	Method Cut()
		
		Super.Cut()
		
		Local start:Int = GetCurrentLine()
		Local stop:Int = start
		
		SetFoldLevels(start, stop)
		
	EndMethod
	
	Method DeleteBack()
		
		Super.DeleteBack()
		
		Local start:Int = GetCurrentLine()
		Local stop:Int = start
		
		SetFoldLevels(start, stop)
		
	EndMethod
	
	Method Find()
		
		Local txt:String = EntryDlg("Find", "Find", _searchText)
		_searchText = txt

		If txt Then
			
			Local curPos:Int = GetCurrentPos()
			Local endPos:Int = GetTextLength()
			Local hitPos:Int = FindText(curPos, endPos, txt, 0)
			
			If hitPos > -1 Then
			
				SetSelection(hitPos, hitPos + txt.length)
				EnsureCaretVisible()
			Else
				'Wrap search from beginning
				hitPos = FindText(0, endPos, txt, 0)
				
				If hitPos > -1 Then
				
					SetSelection(hitPos, hitPos + txt.length)
					EnsureCaretVisible()
				EndIf
			EndIf
		EndIf
	EndMethod
	
	Method GetClipboard:String()
		
		Local clip:wxClipboard = wxClipboard.Get()
		Local text:String
		
		If clip Then
			If clip.Open()
				Local data:wxTextDataObject = New wxTextDataObject.Create("")
				clip.GetData(data)
				text  = data.GetText()
				clip.close()
			EndIf
		EndIf
		
		Return text
	EndMethod
	
	Method GetPreviousPos:Int()
		Return _caretPos
	EndMethod
	
	Method Paste()
		
		Local curPos:Int = GetCurrentPos()
		
		Analyze(curPos, curPos, True)
		SetPreviousPos(curPos + 1, True)
	EndMethod
	
	Method ProcessMenu(id:Int)
		
		Select id
		
		Case wxID_UNDO		Undo()
		Case wxID_REDO		Redo()
		Case wxID_CUT		Cut()
		Case wxID_COPY		Copy()
		Case wxID_PASTE		Paste()
		Case wxID_DELETE	DeleteBack()
		Case wxID_SELECTALL	SelectAll()
		Case wxID_FIND		Find()
		Case wxID_REPLACE	Replace()
			
		Default
			
		EndSelect

	EndMethod
	
	Method Replace()
	EndMethod
	
	Method SetEvent(id:Int, line:Int = 0)
		
		Local m:TModified = New TModified
		m.id = id
		m.line = line
		_evtQueue.AddLast(m)
		
		Local evt:wxCommandEvent = wxCommandEvent.CreateEvent(wxEVT_MY_MODIFIED, wxID_ANY)
		wxWindow(Self).GetEventHandler().AddPendingEvent(evt)
		
	EndMethod

	Method SetFoldLevels(start:Int, stop:Int)
		
		If Not TOptions.opt.folding Then Return
		
		Local s:String, e:Int, r:Int, prev:Int = start - 1
		
		'Determine starting level
		'-------------------------
		Local level:Int = GetFoldLevel(prev)	'wxSCI_FOLDLEVELBASE
		Local p:String = GetLine(prev).Trim().tolower()
		
		If p.StartsWith("end")
			If p.StartsWith("endextern") Or p.startswith("end extern")
				level:-1
			ElseIf p.startswith("endfunction") Or p.startswith("end function")
				level:-1
			ElseIf p.startswith("endrem") Or p.startswith("end rem")
				level:-1
			ElseIf p.startswith("endtype") Or p.startswith("end type")
				level:-1
			EndIf
		ElseIf (level & wxSCI_FOLDLEVELHEADERFLAG)
			level = (level & wxSCI_FOLDLEVELNUMBERMASK) + 1
		Else
			level = (level & wxSCI_FOLDLEVELNUMBERMASK)
		EndIf	
		
		'Set fold levels
		'----------------
		For Local i:Int = start To stop
			
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
			ElseIf s.StartsWith("type")
				If e Then Continue
				SetFoldLevel(i, level | wxSCI_FOLDLEVELHEADERFLAG)
				level:+1
			ElseIf s.StartsWith("end")
				If s.StartsWith("endextern") Or s.startswith("end extern")
					e = False; level:-1
					Continue
				EndIf
				If s.startswith("endfunction") Or s.startswith("end function")
					level:-1
					Continue
				EndIf
				If s.startswith("endrem") Or s.startswith("end rem")
					level:-1
					Continue
				EndIf
				If s.startswith("endtype") Or s.startswith("end type")
					level:-1
					Continue
				EndIf
			EndIf	
		Next
	
	EndMethod
	
	Method SetPreviousPos(pos:Int, update:Int = False)
		_caretPos = pos; _updatePos = update
	EndMethod
	
	Method SetLexerStyle(lexer:Int)
		
		Select lexer
			Case wxSCI_LEX_BLITZMAX
				
				Local s:TStyle = TStyle.GetStyle(lexer)
				
				StyleSetForeground(wxSCI_B_KEYWORD, s.style_keyword_1 )
				StyleSetForeground(wxSCI_B_KEYWORD2, s.style_keyword_2 )
				StyleSetForeground(wxSCI_B_CONSTANT, s.style_keyword_1 )
				StyleSetForeground(wxSCI_B_PREPROCESSOR, s.style_keyword_1 )
				StyleSetForeground(wxSCI_B_STRING, s.style_string )
				StyleSetForeground(wxSCI_B_NUMBER, s.style_number )
				StyleSetForeground(wxSCI_B_COMMENT, s.style_comment )
				StyleSetForeground(wxSCI_B_COMMENTREM, s.style_comment )
					StyleSetItalic(wxSCI_B_COMMENT, True)
					StyleSetItalic(wxSCI_B_COMMENTREM, True)
				SetLexer(lexer)
				SetKeywords(0, TWord.GetKeyWords(wxSCI_B_KEYWORD) )	'_parent.keywords_1)
				SetKeywords(1, TWord.GetKeyWords(wxSCI_B_KEYWORD2))	'_parent.keywords_2)
				
		EndSelect
		
	EndMethod
	
	Method ShowContextMenu(x:Int, y:Int)
		PopupMenu(sciMenu, x, y)
		'menu.Free()
	End Method


End Type

Type TTreeCtrl Extends wxTreeCtrl
	
	Field _tag:String	'For debug
	
	Global _parent:TExplorer
	Global _evtQueue:TList = New TList

	Field menu:wxMenu
	Field _root:wxTreeItemId
	
	Field _traceList:TList = New TList
		
	Method OnInit:Int()
		
		ConnectEvents()
	EndMethod
		
	Method ConnectEvents()
		
		'Context Menu
		ConnectAny(wxEVT_CONTEXT_MENU, OnMenu)
		'ConnectAny(wxEVT_COMMAND_MENU_SELECTED, OnMenuSelected)
		ConnectAny(wxEVT_COMMAND_TREE_ITEM_ACTIVATED, OnItemActivated)
		ConnectAny(wxEVT_MY_MODIFIED, OnMyModified)
	EndMethod
	
	Function OnItemActivated(ev:wxEvent)
		
		Local tree:TTreeCtrl = TTreeCtrl( ev.parent )
		If Not tree Then DebugLog "No tree!"; Return
		
		Local tev:wxTreeEvent = wxTreeEvent(ev)
		If Not tev Then DebugLog "OnItemActivated -> No tree event"; Return
		
		Local item:wxTreeItemId = wxTreeItemId(tev.GetItem())
		If Not item Then DebugLog "OnItemActivated -> No tree item"; Return
		
		Local w:TWord = TWord( tree.GetItemData(item) )
		If Not w Then DebugLog "OnItemActivated -> No word!"; Return
		
		TEditor.SetEvent(MODIFIED_SELECT_LINE, w.line)
		 
	EndFunction
	
	Function OnMenu(ev:wxEvent)
		Local lv:TTreeCtrl = TTreeCtrl(ev.parent)
		
		Local x:Int, y:Int
		wxContextMenuEvent(ev).GetPosition(x, y)
		
		' If from keyboard
		If x = -1 And y = -1 Then
			Local w:Int, h:Int
			lv.GetSize(w, h)
			x = w / 2
			y = h / 2
		Else
			lv.ScreenToClient(x, y)
		End If
		
		lv.ShowContextMenu(x, y)
	End Function
	
	Function OnMyModified(ev:wxEvent)
		
		DebugLog "TTreeCtrl -> OnMyModified"
		
		Local tree:TTreeCtrl = TTreeCtrl( ev.parent )
		If Not tree Then DebugLog "No tree!"; Return

		For Local m:TModified = EachIn _evtQueue
			
			Select m.id
			
			Case MODIFIED_TREE_ADD			
				
				DebugLog "TTreeCtrl -> OnMyModified -> MODIFIED_TREE_ADD -> " + tree._tag
					
				tree.AddTraceable(m.word)
			
			Case MODIFIED_TREE_DELETE		
				
				DebugLog "TTreeCtrl -> OnMyModified -> MODIFIED_TREE_DELETE -> line = " + m.line
			
			Case MODIFIED_TREE_UPDATE		
				
				DebugLog "TTreeCtrl -> OnMyModified -> MODIFIED_TREE_UPDATE -> line = " + m.line
				
				tree.UpdateTree(m.line)
			
			Default
				DebugLog "OnMyModified -> ID not found!"
			EndSelect
		Next
		
		_evtQueue.Clear()
	EndFunction
	
	Method AddItem:wxTreeItemId(item:String, parent:wxTreeItemId=Null, extra:Object=Null)
		
		If Not _root Then _root = AddRoot("Root")
		If Not parent Then parent = _root
		
		Local id:wxTreeItemId	
		id = AppendItem(parent, item,,, extra)
		
		Return id
		
	EndMethod
	
	Method AddTraceable(w:TWord)
		DebugLog "AddTraceable -> line = " + w.line + " | " + w.name
		If Not w Then Return
		
		_traceList.addlast(w)
		AddItem(w.name,, w)
	EndMethod
	
	Method GetTreeviewItem:String(index:Int, col:Int)
	EndMethod
	
	Method GetSelectedItem:wxTreeItemId()
		Return GetSelection()
	EndMethod
	
	Method GetSelectedItems:wxTreeItemId[]()
		Return GetSelections()
	EndMethod
	
	Method SetEvent(m:TModified)	'id:Int, lines:Int = 0)
		
		If Not m Then Return
		_evtQueue.AddLast(m)
		
		Local evt:wxCommandEvent = wxCommandEvent.CreateEvent(wxEVT_MY_MODIFIED, wxID_ANY)
		wxWindow(Self).GetEventHandler().AddPendingEvent(evt)
		
	EndMethod
	
	Method ShowContextMenu(x:Int, y:Int)
		
		If Not menu Then Return
		
		PopupMenu(menu, x, y)
		
		'menu.Free()
	End Method
	
	Method UpdateTree(line:Int, count:Int = 1)
		
		For Local w:TWord = EachIn _traceList
			If w.line => line Then
				w.line:+ count
			EndIf
		Next
	EndMethod
EndType

Type TFile
	
	Field name:String
	Field url:String
	Field ext:String
	
	Field text:String
	
	Function Create:TFile(name:String)
		If Not name Then Return Null
		
		Local f:TFile = New TFile
		f.name	= name
		f.ext	= ExtractExt(name)
		
		Return f
	EndFunction
	
	Function LoadFile:TFile()
		
		Local f:TFile = New TFile
		f.url = RequestFile("Open file...", "bmx",, CurrentDir() )
		If Not f.url Then Return Null
		f.name	= StripDir(f.url)
		f.ext	= ExtractExt(f.url)
		
		Try
			f.text	= LoadText(f.url)
		Catch exception:Object
			Notify("Error: Could not load file", True)
			Return Null
		EndTry
		
		Return f
		
	EndFunction
	
	Method Save:Int()
		
		Try
			SaveText(text, url)
		Catch exception:Object
			Notify("Error: Could not save file", True)
			Return False
		EndTry
		
		Return True
		
	EndMethod
	
EndType

Type TOptions
	Global opt:TOptions = New TOptions
	
	Field autoCap:Int = True
	Field folding:Int = True
	
	Method LoadOptions()
		
	EndMethod
EndType

Rem
Type TInstance
	Field sci:TScintilla
	Field tree:TTreeCtrl
	
	Global list:TList = New TList
	
	Function InitNewInstance:Int()
		Local in:TInstance = New TInstance
		
		in.sci = TEditor.myEditor.NewEditor()
		If Not in.sci Then Notify("Error: Could not create new instance", True); Return False
		
		in.tree = TExplorer.myExplorer.NewTree()
		If Not in.tree Then Notify("Error: Could not create new instance", True); Return False
		
	EndFunction
	
	Function GetCurrentInstance:TInstance()
		Local sci:TScintilla = TEditor.myEditor.GetCurrentEdit()
		If Not sci Then Notify("Error: Could not find open instance", True); Return Null
		
		For Local in:TInstance = EachIn list
			If in.sci = sci Then Return in
		Next
		
		Notify("Error: Could not find open instance", True); Return Null
	EndFunction
EndType
EndRem

Type TWord
	Global _autoKeywords:String	' Used for autocompletion
	Global _keywords1:String, _keywords2:String
	
	Field style:Int
	Field name:String
	Field key:String
	Field trace:Int
	Field line:Int
	Field traceKey:String
	
	Global _found:Int, _trace:Int, _traceType:String
	Global _wordList:TList = New TList
	'Global _traceList:TList = New TList
	
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
	
	Function GetAutoKeywords:String()
		Return _autoKeywords
	EndFunction
		
	Function GetKeywords:String(style:Int = wxSCI_B_KEYWORD)
		If style = wxSCI_B_KEYWORD2 Then
			Return _keywords2
		Else
			Return _keywords1
		EndIf
	EndFunction
	
	Function GetName:String(key:String)
		If Not key Then Return key
		
		Local tmpKey:String = key.tolower()
		
		For Local w:TWord = EachIn _wordList
			If w.key = tmpKey Then
				_found = True
				If w.trace Then
					_trace = True
					_traceType = tmpKey
				Else
					_trace = False
					_traceType = ""
				EndIf
				
				Return w.name
			EndIf
		Next
		
		_found = False
		_trace = False
		Return key
	EndFunction
	
	Function isMatch:Int()
		Return _found
	EndFunction
	
	Function isTraceable:Int()
		Return _trace
	EndFunction
	
	Function Parse:String(txt:String = "", start:Int = 0)
		
		If Not txt Then Return txt
		
		DebugLog "Parse -> " + start + " | length = " + txt.length 
		
		Local startPos:Int = -1, lineCount:Int = start
		Local isString:Int, isCom:Int, isRem:Int, isNewline:Int, isEnd:Int	', isFirst:Int = 1
		Local isParam:Int
		Local isIdentifier:Int	'isFunction:Int, isMethod:Int, isType:Int
		Local token:String, name:String, char:Int, analyze:Int, txt_ptr:Short Ptr = txt.ToWString()
		Local eol:Int = txt.length	' - 1
		
		Local s:String
		
		For Local i:Int = 0 Until txt.length
			
			s = Chr(txt[i])
			
			If i = eol And startPos > -1 Then analyze = 1
			
			Select txt[i]
				
				Case 39 'Comment
					
					If isString Or isRem Then Continue
					
					'analyze = 1
					isCom = 1
					
				Case 34	'String
					
					If isCom Or isRem Then Continue
					isString = Not isString
					
					If isString And startPos > -1 Then
						analyze = 1
					Else
						startPos = -1
					EndIf

				Case 9, 32	'Tab, Space 
					
					If startPos > -1 And Not isIdentifier Then analyze = 1
					
				Case 10		'Newline
						
					isString = 0
					isCom = 0
					
					If startPos > -1 Then
						isNewline = 1
						analyze = 1
					Else
						isIdentifier = 0
						lineCount:+1
					EndIf
			
				Case 13, 59		' Return, Semicolon ';'
				
					If startPos > -1 Then analyze = 1
						
					Rem
					If txt[i] = 10 Or txt[i] = 13 And startPos > -1 Then isNewline = 1	'Newline / Enter
					If isString Or isCom Then
						
						isString = 0
						isCom = 0
						startPos = -1
							
						If isNewline Then
							'isFirst = 1
							isNewline = 0
						EndIf
						
						Continue
					ElseIf startPos = -1 
						Continue
					EndIf
					
					If startPos > -1 Then analyze = 1; Else isIdentifier = 0
					EndRem
					
				Default
					
					isNewline = 0
					If isString Or isCom Then Continue
					If startPos = -1 Then startPos = i
					
			EndSelect
			
			'Words are analyzed at this point
			'--------------------------------
			If analyze Then
				
				analyze = 0
				name = txt[startPos..i]
				token = name.tolower()
				
				'DebugLog "Analyze -> LineCount = " + lineCount + " | Token = " + token
				
				If Not isIdentifier Then
					
					If token = "end"
						isEnd = 1	'; Continue
					ElseIf token = "endrem" Or token = "end rem" Then
						isRem = 0
					ElseIf token = "rem"
						isRem = 1
					EndIf
					
					name = GetName(token)
					If isMatch() Then
						If TOptions.opt.autoCap And name <> token Then
							For char = 0 Until token.length
								txt_ptr[startPos + char] = name[char]
							Next
						EndIf
						
						isIdentifier = isTraceable()
						
						If isIdentifier And isEnd Then
							isEnd = 0
							isIdentifier = 0
						EndIf
						
						'DebugLog "Keyword: " + name + " | isTraceable = " + isIdentifier
					Else
						'DebugLog "No match."
					EndIf
					
				Else
					ParseTraceable(_traceType, name, lineCount)
					isIdentifier = 0
				EndIf
				
				If isNewline Then
					isNewline = 0
					lineCount:+ 1
				EndIf
				
				startPos = -1
			EndIf
		Next
		
		Return txt.FromWString(txt_ptr)
	EndFunction
	
	Function ParseTraceable(traceType:String, token:String, line:Int = -1)
		
		If Not token Or Not traceType Or line = -1 Then Return
		
		Local key:String
		
		'Is a Function or a Method
		If token.contains("(")
			token = token.Replace(" ", "").Replace("~t", "").Replace(")", "") 
			Local ar1:String[] = token.split("(")
			Local ar2:String[] = ar1[0].split(":")
			Local par:String[] = ar1[1].split(",")
			
			key = traceType.tolower() + "_" + ar2[0]
			token = ":".join(ar2) + "(" + ", ".join(par) + ")"
 
		ElseIf token.contains(":")
			token = token.Replace(" ", "").Replace("~t", "")
			Local ar:String[] = token.split(":")		
		EndIf
		
		'DebugLog token + " | line = " + line + " | key = " + key
		
		Local w:TWord = New TWord
		w.name = token
		w.key = key
		w.line = line
		
		Local m:TModified = TModified.CreateWord(MODIFIED_TREE_ADD, w)
		TExplorer.SetEvent(m)
		
	EndFunction
	
	Function SetTraceWords:Int(words:String)
		If Not words Then Return False
		
		Local ar:String[] = words.split(" ")
		If Not ar Then Notify "Error: Could not set traceable keywords.",True; Return False
		
		For Local i:Int = 0 Until ar.length
			
			Local tmpKey:String = ar[i].Trim().tolower()
			If Not tmpKey Then Continue
			
			For Local w:TWord = EachIn _wordList
				If w.key = tmpKey Then
					w.trace = True; Exit
				EndIf
			Next
		Next
		
		Return True
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
	Field style_keyword_1:wxColour = New wxColour.Create(255, 255, 80)	'(220, 220, 0) 'Yellow
	Field style_keyword_2:wxColour = New wxColour.Create(170, 170, 255)	'(148, 148, 255) 'Teak
	
	Global _list:TList = New TList
	
	Method New()
	EndMethod
	
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

Type TModified

	Field id:Int
	Field line:Int
	Field count:Int
	Field word:TWord
	
	Function CreateLine:TModified(id:Int, line:Int, count:Int = 0)
		Local m:TModified = New TModified
		m.id = id
		m.line = line
		m.count = count
		
		Return m
	EndFunction
	
	Function CreateWord:TModified(id:Int, word:TWord)
		Local m:TModified = New TModified
		m.id = id
		m.word = word
		
		Return m
	EndFunction
	
EndType

Function EntryDlg:String(text:String, title:String, defaultText:String = "")

	Local dial:TEntryDialog = New TEntryDialog.Create(text, title, defaultText)
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
	Field dText:String
	Field value:String
	Field ret:Int
	
	Method Create:TEntryDialog(txt:String, title:String, defaultText:String)
		text = txt
		dText = defaultText
		Return TEntryDialog(Super.Create_(Null, wxID_ANY, title, -1, -1, -1, -1, wxDEFAULT_DIALOG_STYLE))
	End Method

	Method OnInit:Int()

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
		m_field1.SetValue(dText)
		Local lastPos:Int = m_field1.GetLastPosition()
		m_field1.SetSelection(0, lastPos)
		
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


