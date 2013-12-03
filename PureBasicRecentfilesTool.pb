;
; PureBasicRecentfiles
;
; written 2013 by Peter Tübben
;

EnableExplicit

Structure sRecentFile
  ID.s
  Fullname.s
  Filename.s
  PathName.s
  FileExists.i
  DateCreatedRaw.i
  DateCreated.s
  DateAccessedRaw.i
  DateAccessed.s
  DateModifiedRaw.i
  DateModified.s
EndStructure

Structure sPureBasicPrefs
  Filename.s
  MD5.s
  HistorySize.s
  List RecentFile.sRecentFile()
EndStructure

Global PureBasicPrefs.sPureBasicPrefs

#AppName = "PureBasicRecentfilesTool"

Enumeration ; Windows
  #frmMain
EndEnumeration

Enumeration ; Gadgets
  #frmMain_lblFilter
  #frmMain_txtFilter
  #frmMain_cmdDeleteFilter
  #frmMain_cboSort
  #frmMain_RecentFiles
  #frmMain_lblSearchInFiles
  #frmMain_txtSearchInFiles
  #frmMain_cmdSearchInFiles
EndEnumeration

Enumeration ; Menu/Toolbar-Items
  #frmMain_Shortcut_Return
EndEnumeration

Declare frmMain_cmdDeleteFilter_Click()

Procedure StartsWith(String.s, StartString.s)
  If Left(String, Len(StartString)) = StartString
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure frmMain_Resize()
  
  ResizeGadget(#frmMain_cboSort,
               WindowWidth(#frmMain) - GadgetWidth(#frmMain_cboSort) - 8,
               #PB_Ignore,
               #PB_Ignore,
               #PB_Ignore)
  
  ResizeGadget(#frmMain_txtFilter,
               GadgetX(#frmMain_lblFilter) + GadgetWidth(#frmMain_lblFilter), 
               #PB_Ignore,
               WindowWidth(#frmMain) - GadgetWidth(#frmMain_cboSort) - GadgetWidth(#frmMain_lblFilter) - GadgetWidth(#frmMain_cmdDeleteFilter) - 8 - 8 - 8 - 8,
               #PB_Ignore)
  
  ResizeGadget(#frmMain_cmdDeleteFilter,
               GadgetX(#frmMain_txtFilter) + GadgetWidth(#frmMain_txtFilter) + 4, 
               #PB_Ignore,
               #PB_Ignore,
               #PB_Ignore)
  
  ResizeGadget(#frmMain_RecentFiles,
               #PB_Ignore,
               #PB_Ignore,
               WindowWidth(#frmMain) - 8 - 8,
               WindowHeight(#frmMain) - GadgetHeight(#frmMain_lblFilter) - 8  - GadgetHeight(#frmMain_lblSearchInFiles) - 8 - 8 - 8)
  
  ResizeGadget(#frmMain_lblSearchInFiles,
               8,
               WindowHeight(#frmMain) - GadgetHeight(#frmMain_lblSearchInFiles) - 5,
               #PB_Ignore,
               #PB_Ignore)
  
  ResizeGadget(#frmMain_txtSearchInFiles, 
               GadgetX(#frmMain_lblSearchInFiles) + GadgetWidth(#frmMain_lblSearchInFiles), 
               WindowHeight(#frmMain) - GadgetHeight(#frmMain_txtSearchInFiles) - 8,
               WindowWidth(#frmMain) - GadgetWidth(#frmMain_lblSearchInFiles) - GadgetWidth(#frmMain_cmdSearchInFiles) - 8 - 8 - 8,
               #PB_Ignore)
  
  ResizeGadget(#frmMain_cmdSearchInFiles, 
               WindowWidth(#frmMain) - GadgetWidth(#frmMain_cmdSearchInFiles) - 8,
               WindowHeight(#frmMain) - GadgetHeight(#frmMain_lblSearchInFiles) - 8,
               #PB_Ignore,
               #PB_Ignore)
  
EndProcedure

Procedure.s LoadTextFile(TextFilename.s)
  
  Protected FF, StringFormat
  Protected ReturnValue.s
  Protected TextBuffer, TextBufferSize
  
  If FileSize(TextFilename) <= 0 : ProcedureReturn "" : EndIf
  FF = ReadFile(#PB_Any, TextFilename)
  If FF = 0 : ProcedureReturn "" : EndIf
  StringFormat = ReadStringFormat(FF)
  TextBufferSize = Lof(FF)
  TextBuffer = AllocateMemory(TextBufferSize)
  If TextBuffer = 0 : CloseFile(FF) : ProcedureReturn "" : EndIf
  ReadData(FF, TextBuffer, TextBufferSize)
  CloseFile(FF)
  ReturnValue = PeekS(TextBuffer, TextBufferSize, StringFormat)
  FreeMemory(TextBuffer)
  
  ProcedureReturn ReturnValue
  
EndProcedure

Procedure DoFileSearch()
  
  Protected FileContent.s
  Protected StringToFind.s
  Protected Found, Counter
  
  frmMain_cmdDeleteFilter_Click()
  
  NewList FilesToSearch.sRecentFile()
  
  For Counter = 0 To CountGadgetItems(#frmMain_RecentFiles) - 1
  	
  	AddElement(FilesToSearch())
  	
	  FilesToSearch()\Filename = GetGadgetItemText(#frmMain_RecentFiles, Counter, 0)
	  FilesToSearch()\Pathname = GetGadgetItemText(#frmMain_RecentFiles, Counter, 1)
	  FilesToSearch()\Fullname = FilesToSearch()\Pathname + "\" + FilesToSearch()\Filename
	  FilesToSearch()\DateCreated = GetGadgetItemText(#frmMain_RecentFiles, Counter, 2)
	  FilesToSearch()\DateModified = GetGadgetItemText(#frmMain_RecentFiles, Counter, 3)
	  FilesToSearch()\DateAccessed = GetGadgetItemText(#frmMain_RecentFiles, Counter, 4)
  	
  Next
  
  ClearGadgetItems(#frmMain_RecentFiles)
  
  ForEach FilesToSearch()
    
    Found = #False
    
    If GetGadgetText(#frmMain_txtSearchInFiles) = ""
      Found = #True
    Else
      
      FileContent = LoadTextFile(FilesToSearch()\Fullname)
      
      If FileContent <> ""
      
      If FindString(LCase(FileContent), LCase(GetGadgetText(#frmMain_txtSearchInFiles)))
        Found = #True
      EndIf
      
      EndIf
      
    EndIf
    
    If Found
    	
    	AddGadgetItem(#frmMain_RecentFiles, -1,
    	              FilesToSearch()\Filename + #LF$ + 
    	              FilesToSearch()\Pathname + #LF$ + 
    	              FilesToSearch()\DateCreated + #LF$ +
    	              FilesToSearch()\DateModified + #LF$ + 
    	              FilesToSearch()\DateAccessed)
    	
    EndIf
    
  Next
  
  ClearList(FilesToSearch())
  
  SetGadgetState(#frmMain_RecentFiles, 0)  
  
  SetActiveGadget(#frmMain_txtSearchInFiles)
  
EndProcedure

Procedure RefillList()
  
  Protected Found
  
  ClearGadgetItems(#frmMain_RecentFiles)
  
  ForEach PureBasicPrefs\RecentFile()
    
    Found = #False
    
    If GetGadgetText(#frmMain_txtFilter) = ""
      Found = #True
    Else
      
      If FindString(LCase(PureBasicPrefs\RecentFile()\Filename + #LF$ + PureBasicPrefs\RecentFile()\Pathname), LCase(GetGadgetText(#frmMain_txtFilter)))
        Found = #True
      EndIf
      
    EndIf
    
    If Found
      
      AddGadgetItem(#frmMain_RecentFiles, -1, PureBasicPrefs\RecentFile()\Filename + #LF$ + PureBasicPrefs\RecentFile()\Pathname + #LF$ + PureBasicPrefs\RecentFile()\DateCreated + #LF$ + PureBasicPrefs\RecentFile()\DateModified + #LF$ + PureBasicPrefs\RecentFile()\DateAccessed)
      
      If Not PureBasicPrefs\RecentFile()\FileExists
        SetGadgetItemColor(#frmMain_RecentFiles, CountGadgetItems(#frmMain_RecentFiles) - 1, #PB_Gadget_FrontColor, #Red)
      EndIf
      
    EndIf
    
  Next
  
  SetGadgetState(#frmMain_RecentFiles, 0)
  
EndProcedure

Procedure DoSort()
	
	Select GetGadgetState(#frmMain_cboSort)
			
		Case 0 ; Keine Sortierung
			SortStructuredList(PureBasicPrefs\RecentFile(), 0, OffsetOf(sRecentFile\ID), #PB_Integer)
			
		Case 1 ; Dateiname
			SortStructuredList(PureBasicPrefs\RecentFile(), 0, OffsetOf(sRecentFile\Filename), #PB_String)
			
		Case 2 ; Pfadname
			SortStructuredList(PureBasicPrefs\RecentFile(), 0, OffsetOf(sRecentFile\PathName), #PB_String)
			
		Case 3 ; Erstellungsdatum
			SortStructuredList(PureBasicPrefs\RecentFile(), #PB_Sort_Descending, OffsetOf(sRecentFile\DateCreatedRaw), #PB_Integer)
			
		Case 4 ; Änderungsdatum
			SortStructuredList(PureBasicPrefs\RecentFile(), #PB_Sort_Descending, OffsetOf(sRecentFile\DateModifiedRaw), #PB_Integer)
			
		Case 5 ; Zugriffsdatum
			SortStructuredList(PureBasicPrefs\RecentFile(), #PB_Sort_Descending, OffsetOf(sRecentFile\DateAccessedRaw), #PB_Integer)
			
	EndSelect
	
	RefillList()
	
	SetActiveGadget(#frmMain_RecentFiles)
	
EndProcedure

Procedure frmMain_cmdDeleteFilter_Click()
	
	SetGadgetText(#frmMain_txtFilter, "")
	RefillList()
	SetActiveGadget(#frmMain_txtFilter)
	
EndProcedure

Procedure frmMain_Open()
  
  Protected WindowFlags
  Protected ListIconGadgetFlags
  
  WindowFlags | #PB_Window_SystemMenu
  WindowFlags | #PB_Window_SizeGadget
  WindowFlags | #PB_Window_ScreenCentered
  WindowFlags | #PB_Window_MinimizeGadget
  WindowFlags | #PB_Window_MaximizeGadget
  
  ListIconGadgetFlags | #PB_ListIcon_AlwaysShowSelection
  ListIconGadgetFlags | #PB_ListIcon_FullRowSelect
  ListIconGadgetFlags | #PB_ListIcon_GridLines
  
  OpenWindow(#frmMain, #PB_Ignore, #PB_Ignore, 800, 600, #AppName, WindowFlags)
  
  TextGadget(#frmMain_lblFilter,    8, 12, 30, 20, "Filter:")
  StringGadget(#frmMain_txtFilter,  0,  8,  0, 20, "")
  ButtonGadget(#frmMain_cmdDeleteFilter, 0, 8, 20, 20, "x")
  GadgetToolTip(#frmMain_cmdDeleteFilter, "Filter löschen")
  BindGadgetEvent(#frmMain_cmdDeleteFilter, @frmMain_cmdDeleteFilter_Click(), #PB_EventType_LeftClick)
  
  ComboBoxGadget(#frmMain_cboSort, 0, 6, 120, #PB_Ignore)
  AddGadgetItem(#frmMain_cboSort, -1, "Keine Sortierung")
  AddGadgetItem(#frmMain_cboSort, -1, "Dateiname")
  AddGadgetItem(#frmMain_cboSort, -1, "Pfad")
  AddGadgetItem(#frmMain_cboSort, -1, "Erstellungsdatum")
  AddGadgetItem(#frmMain_cboSort, -1, "Änderungsdatum")
  AddGadgetItem(#frmMain_cboSort, -1, "Zugriffsdatum")
  SetGadgetState(#frmMain_cboSort, 0)
  
  ListIconGadget(#frmMain_RecentFiles, 8, 36, 0, 0, "Dateiname", 150, ListIconGadgetFlags)
  AddGadgetColumn(#frmMain_RecentFiles, 1, "Pfad", 250)
  AddGadgetColumn(#frmMain_RecentFiles, 2, "Erstellt", 120)
  AddGadgetColumn(#frmMain_RecentFiles, 3, "Geändert", 120)
  AddGadgetColumn(#frmMain_RecentFiles, 4, "Letzter Zugriff", 120)
  
  TextGadget  (#frmMain_lblSearchInFiles, 0, 0,  100, 20, "Suchen in Dateien:")
  StringGadget(#frmMain_txtSearchInFiles, 0, 0,    0, 20, "")
  ButtonGadget(#frmMain_cmdSearchInFiles, 0, 0,   80, 20, "Suchen")
  
  BindGadgetEvent(#frmMain_cmdSearchInFiles, @DoFileSearch(), #PB_EventType_LeftClick)
  BindGadgetEvent(#frmMain_cboSort, @DoSort())
  
  AddKeyboardShortcut(#frmMain, #PB_Shortcut_Return, #frmMain_Shortcut_Return)
  
  WindowBounds(#frmMain, 300, 200, #PB_Ignore, #PB_Ignore)
  
  frmMain_Resize()
  
EndProcedure

Procedure ReadPreferences()
  
  PureBasicPrefs\Filename =  GetEnvironmentVariable("APPDATA") + "\PureBasic\PureBasic.prefs"
  
  PureBasicPrefs\MD5 = MD5FileFingerprint(PureBasicPrefs\Filename)
  
  OpenPreferences(PureBasicPrefs\Filename)
  
  ExaminePreferenceGroups()
  
  While NextPreferenceGroup()
    
    If PreferenceGroupName() = "RecentFiles"
      
      ExaminePreferenceKeys()
      
      While NextPreferenceKey()
        
        If PreferenceKeyName() = "HistorySize"
          PureBasicPrefs\HistorySize = PreferenceKeyValue()
        EndIf
        
        If StartsWith(PreferenceKeyName(), "RecentFile_")
          
          AddElement(PureBasicPrefs\RecentFile())
          
          PureBasicPrefs\RecentFile()\ID = Str(ListSize(PureBasicPrefs\RecentFile()))
          
          PureBasicPrefs\RecentFile()\Fullname = PreferenceKeyValue()
          PureBasicPrefs\RecentFile()\Filename = GetFilePart(PureBasicPrefs\RecentFile()\Fullname)
          PureBasicPrefs\RecentFile()\Pathname = GetPathPart(PureBasicPrefs\RecentFile()\Fullname)
          
          If FileSize(PureBasicPrefs\RecentFile()\Fullname) = -1
            PureBasicPrefs\RecentFile()\FileExists = #False
          Else
            PureBasicPrefs\RecentFile()\FileExists = #True
          EndIf
          
          PureBasicPrefs\RecentFile()\DateCreated  = "--"
          PureBasicPrefs\RecentFile()\DateModified = "--"
          PureBasicPrefs\RecentFile()\DateAccessed = "--"
          
          If PureBasicPrefs\RecentFile()\FileExists
            
            PureBasicPrefs\RecentFile()\DateCreatedRaw  = GetFileDate(PureBasicPrefs\RecentFile()\Fullname, #PB_Date_Created)
            PureBasicPrefs\RecentFile()\DateCreated     = FormatDate("%dd.%mm.%yyyy %hh:%ii:%ss", PureBasicPrefs\RecentFile()\DateCreatedRaw)
            
            PureBasicPrefs\RecentFile()\DateModifiedRaw = GetFileDate(PureBasicPrefs\RecentFile()\Fullname, #PB_Date_Modified)
            PureBasicPrefs\RecentFile()\DateModified    = FormatDate("%dd.%mm.%yyyy %hh:%ii:%ss", PureBasicPrefs\RecentFile()\DateModifiedRaw)
            
            PureBasicPrefs\RecentFile()\DateAccessedRaw = GetFileDate(PureBasicPrefs\RecentFile()\Fullname, #PB_Date_Accessed)
            PureBasicPrefs\RecentFile()\DateAccessed    = FormatDate("%dd.%mm.%yyyy %hh:%ii:%ss", PureBasicPrefs\RecentFile()\DateAccessedRaw)
            
          EndIf
          
        EndIf
        
      Wend
      
      Break
      
    EndIf
    
  Wend
  
  ClosePreferences()
  
EndProcedure

Procedure Main()
  
  Protected WWE, Quit, SelectedItem
  
  ReadPreferences()
  
  frmMain_Open()
  
  SetActiveGadget(#frmMain_txtFilter)
  
  RefillList()
  
  Repeat
    
    WWE = WaitWindowEvent()
    
    Select WWE
        
      Case #PB_Event_Menu
        
        Select EventMenu()
            
          Case #frmMain_Shortcut_Return
            
            Select GetActiveGadget()
                
              Case #frmMain_txtFilter
                
              Case  #frmMain_RecentFiles
                SelectedItem = GetGadgetState(#frmMain_RecentFiles)
                If SelectedItem > -1
                  RunProgram(Chr(34) + GetGadgetItemText(#frmMain_RecentFiles, SelectedItem, 1) + GetGadgetItemText(#frmMain_RecentFiles, SelectedItem, 0) + Chr(34))
                EndIf
                
              Case #frmMain_txtSearchInFiles
                DoFileSearch()
                
            EndSelect
            
        EndSelect
        
      Case #PB_Event_Gadget
        
        Select EventGadget()            
            
          Case #frmMain_RecentFiles
            
            Select EventType()
                
              Case #PB_EventType_LeftDoubleClick
                
                SelectedItem = GetGadgetState(#frmMain_RecentFiles)
                If SelectedItem > -1
                  RunProgram(Chr(34) + GetGadgetItemText(#frmMain_RecentFiles, SelectedItem, 1) + GetGadgetItemText(#frmMain_RecentFiles, SelectedItem, 0) + Chr(34))
                EndIf
                
            EndSelect
            
          Case #frmMain_txtFilter
            
            Select EventType()
            	Case #PB_EventType_Change
            		SetGadgetText(#frmMain_txtSearchInFiles, "")
                RefillList()
            EndSelect
            
        EndSelect
        
      Case #PB_Event_CloseWindow
        
        Quit = #True
        
      Case #PB_Event_SizeWindow
        
        frmMain_Resize()
        
    EndSelect
    
  Until  Quit = #True
  
EndProcedure

Main()
; IDE Options = PureBasic 5.21 LTS (Windows - x86)
; Folding = BA9
; EnableXP
; UseIcon = recent.ico
; Executable = PureBasicRecentfilesTool.exe
; IncludeVersionInfo
; VersionField0 = 1.0
; VersionField1 = 1.0
; VersionField2 = tuebbentools
; VersionField3 = PureBasicRecentfilesTool
; VersionField4 = 1.0
; VersionField5 = 1.0
; VersionField6 = PureBasicRecentfilesTool
; VersionField7 = PureBasicRecentfilesTool
; VersionField8 = PureBasicRecentfilesTool