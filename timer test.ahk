#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

FileInstall, log.txt, log1.txt

Tooltip, "O chuj"
ToolTipTime := A_Now

Loop
{
If (A_Now - ToolTipTime > 5)
{
	ToolTip
}
}