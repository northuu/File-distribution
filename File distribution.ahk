;-------------------------------------------------------------------------------
; Name:		File distribution
; Purpose:	Moving files to selected folders based on users input.	
;
; Author:	Mateusz Gołębiowski
;
; Created:	21-04-2017
;-------------------------------------------------------------------------------
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;global variables:
global Shared_Log := "\\dsg.dk\dsg-dfs-data\DSA\SSC\_Common\RPAlogs\Bartlomiej Leszczynski File Distribution\Log PDF " A_YYYY "-" A_MM "-" A_DD " " A_Hour " " A_Min " " A_Sec ".txt"
global Log_File_Path := A_ScriptDir "\Log " A_YYYY "-" A_MM "-" A_DD " " A_Hour " " A_Min " " A_Sec ".txt" ; Location1 before A_SriptDir
global NextSegment := ""
global Gui2Status := 0
global ButtonAmount :=
global ButtonNameArray := 
global CopiedFiles := Object()
global CheckboxStatus := Object()
Locations := LoadLocations("Locations.txt")
Clipboard := 
DefaultGuiCreate()
return

OnClipboardChange:
CopiedFiles := StrSplit(Clipboard, "`n", "`r")
Log(CopiedFiles._MaxIndex(), " files selected.")
Gui, Default:Default
SB_SetText(CopiedFiles.Length() " files copied at " A_Hour ":" A_Min ":" A_Sec)
return

Opt1Button:
	FileMoveOpt1(Locations, NextSegment)
return

Opt2Button:
	;Gui, Default:Submit, NoHide
	If (Gui2Status = 0)
	{
		SelectingGuiCreate(Locations)
		Gui2Status = 1
	}
	Else
	{
		Gui, 2:Show
	}
return

MoveButton:
	FileMoveOpt2(Locations, NextSegment, ButtonAmount)
	Gui, 2:Submit
	;Gui, Default:Show
return

;--- Showing tooltip
LeftClickOnStatusBar:
If (A_GuiEvent = "Normal" and CopiedFiles.Length() > 0)
{
	FileListForMsgbox :=
	For i, file in CopiedFiles
	{
		
		TempFileName := StrSplit(file, "\")
		FileListForMsgbox .= i " " TempFileName[TempFileName._MaxIndex()] "`r`n"
	}
	ToolTip % FileListForMsgbox
}
return

;----Closing tooltip after clicking on it
~LButton::
MouseGetPos,x,y,ToolTipWindow
If (ToolTipWindow = WinExist("ahk_class tooltips_class32"))
{
	ToolTip
}
return

Log(text*)
{
	For key, value in text
		logtext .= " " . value
	FormatTime, NowTime,, hh:mm:ss
	FileAppend, %NowTime% - %logtext%`r`n, %Log_File_Path%
	FileAppend, %NowTime% - %logtext%`r`n, %Shared_Log%
}

LoadLocations(FilePath)
{
	IfExist, %FilePath%
	{
		FileRead, LocationList, %FilePath%
	}
	else
	{
		Msgbox,262144,, Can't open %FilePath%.
		ExitApp
	}
	LocationArray := Object()
	NextSegment :=
	Loop, Parse, LocationList, `n, `r
	{
		If (A_LoopField = "#NextSegment")
		{
			NextSegment := A_Index
			Continue
		}
		LocationArray.Push(A_LoopField)
		If (NextSegment = "")
		{
			Log("First option path: ", A_LoopField)
		}
		else if (A_LoopField != "#NextSegment" )
		{
			Log("Second option path: ", A_LoopField)
		}
	}
	If (NextSegment = "")
	{
		Msgbox,262144,, Locations.txt file is corrupted. Read Instruction.txt %NextSegment%
		ExitApp
	}
	return LocationArray
}

FileMoveOpt1(Locations, NextSegment)
{
	Counter := (NextSegment - 1) * CopiedFiles.Length()
	CurrentCounter := 0
	Loop % NextSegment - 1
	{
		CurrentLocation := Locations[A_Index]
		IfNotExist, %CurrentLocation%
		{
			Log(CurrentLocation, " doesn't exist or can't be accessed.")
			Msgbox,262144,, %CurrentLocation% doesn't exist or can't be accessed.
			ExitApp
		}
		If (CopiedFiles.Length()=0)
		{
			Msgbox, 262144,,Select at least one file.
			return
		}
		For i, SingleFile in CopiedFiles
		{
			FileCopy, %SingleFile%, %CurrentLocation%
			If (ErrorLevel > 0)
			{
				Log("Error durring copying ", SingleFile, " to ", CurrentLocation)
				Msgbox,262144,, Error occured durring copying, see log file for details.
				Return
			}
			CurrentCounter := CurrentCounter + 1
			CurrentPercent := CurrentCounter/Counter*100
			GuiControl,, ProgressBar, %CurrentPercent%
		}
	}
	CopiedFiles := Object()
	Msgbox, 262144,,Done
	GuiControl,, ProgressBar, 0
	;without deleting yet, I will add it after everything else is working
}

FileMoveOpt2(Locations, NextSegment, ButtonAmount)
{
	Gui, Default:Default
	Gui, 2:Submit, NoHide
	If (ButtonAmount=0)
	{
		Msgbox, 262144,,Select at least one folder.
	}
	;--------------Creating an array of selected locations
	SelectedFolders := Object()
	Loop %ButtonAmount%
	{
		if (CheckboxStatus%A_Index% = 1)
		{
			SelectedFolders.Push(Locations[NextSegment - 1 + A_Index])
			Log("Selected folder", Locations[NextSegment - 1 + A_Index])
		}
	}
	If (CopiedFiles.Length()=0)
		{
			Msgbox, 262144,,Select at least one file.
			return
		}
	Counter := SelectedFolders._MaxIndex() * CopiedFiles.Length()
	CurrentCounter := 0
	;--------------Copying folder by folder
	Loop % SelectedFolders._MaxIndex()
	{
		CurrentLocation := SelectedFolders[A_Index]
		IfNotExist, %CurrentLocation%
		{
			Log(CurrentLocation, " doesn't exist or can't be accessed.")
			Msgbox,262144,, %CurrentLocation% doesn't exist or can't be accessed.
			ExitApp
		}
		For i, SingleFile in CopiedFiles
		{
			FileCopy, %SingleFile%, %CurrentLocation%
			If (ErrorLevel > 0)
			{
				Log("Error durring copying ", SingleFile, " to ", CurrentLocation)
				Msgbox,262144,, Error occured durring copying, see log file for details.
				Return
			}
			CurrentCounter := CurrentCounter + 1
			CurrentPercent := CurrentCounter/Counter*100
			GuiControl,, ProgressBar, %CurrentPercent%
		}
	}
	CopiedFiles := Object()
	Msgbox, 262144,,Done
	GuiControl,, ProgressBar, 0
	;without deleting yet, I will add it after everything else is working

}

DefaultGuiCreate()
{
global
Gui, Default:Font, s10
Gui, Default:Add, Button, x15 y15 w120 h23 gOpt1Button, &Option 1
Gui, Default:Add, Button, x15 y55 w120 h23 gOpt2Button, &Option 2
Gui, Default:Add, StatusBar, gLeftClickOnStatusBar
Gui  Default:Add, Progress, x15 y95 w120 h20 -Smooth vProgressBar, 0
Gui, Default:+AlwaysOnTop
Gui, Default:Show, w190 h150, Select action
return
}

SelectingGuiCreate(Locations)
{
	global
	Gui, Default:Submit, NoHide
	Gui, 2:+AlwaysOnTop
	Gui, 2:Add, Text, x15 y15, Select folders
	ButtonAmount := Locations._MaxIndex() - NextSegment + 1
	local Checkbox_Y := 35
	Loop %ButtonAmount%
	{
		local CurrentButtonName := Locations[NextSegment - 1 + A_Index]
		ButtonNameArray := StrSplit(CurrentButtonName, "\")
		local ButtonName := ButtonNameArray[ButtonNameArray._MaxIndex()-1] . ButtonNameArray[ButtonNameArray._MaxIndex()]
		Gui, 2:Add, Checkbox, x15 y%Checkbox_Y% vCheckboxStatus%A_Index%, %ButtonName%
		
		Checkbox_Y += 20
	}
	Gui, 2:Add, Button, x15 y%Checkbox_Y% w60 h23 gMoveButton, Move
	Checkbox_Y := Checkbox_Y + 40
	Gui, 2:Show, w150 h%Checkbox_Y%, Select action
}
DefaultGuiClose:
ExitApp

2GuiClose:
Gui, 2:Submit
return


;Bugs:
;If after moving, the button will be hit again without selecting new files
;it will show Msgbox, Done, while doing nothing.