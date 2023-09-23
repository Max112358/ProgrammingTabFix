#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


; The purpose of this script is to instantly fix any indentation errors in a program. 
; It uses curly braces to move in one indentation level every time scope changes
; Its meant for C based languages, so python or something it wont work.

#r::Reload ; windows+r to reload script

#q::ExitApp ; windows+q to quit

#p::Pause  ; Press windows+P to pause. Press it again to resume.

#x::
Suspend, Permit
Suspend, Toggle
Return

#f::  ;windows+f to indent with tabs
TabCharacter := "`t"
fixTabs(TabCharacter)
Return

#h::  ;windows+h to ndent with spaces
TabCharacter := " "
fixTabs(TabCharacter)
Return


Return


fixTabs(TabCharacter) ; this is the main function
{
	
	
	; Set the delimiter for splitting lines
	LineDelimiter := "`n" ; Use `r`n for Windows line endings
	tabCount := 0
	
	
	originalClipboard := clipboard
	
	
	Click ; click the item button to open the trade page
	Send ^a ; select all
	clipboard := ""  ; Start off empty to allow ClipWait to detect when the text has arrived.
	Send ^c ; cut all text
	ClipWait  ; Wait for the clipboard to contain text.
	Clipboard := ClipboardAll ; Get the clipboard content
	Lines := StrSplit(Clipboard, LineDelimiter) ; Split the clipboard content into lines
	
	currentLine := 1
	for index, line in Lines ; Loop through each line
	{
		
		
	IfInString, line, }
	{
		tabCount--
	}
	
	if (tabCount < 0)
	{
		tabCount := 0
	}
	
	CleanedString := ""
	CleanedString := RegExReplace(line, "^[ \t]+") ; remove both spaces and tabs from the beginning
	
	
	; Initialize an empty string
	replacementString := ""
	
	; Insert tabs at the beginning of the string
	Loop % tabCount
	{
		replacementString := replacementString . TabCharacter
	}
	
	; Append the rest of the string
	replacementString := replacementString CleanedString
	
	; Display the resulting string
	; MsgBox %replacementString%
	
	
	Lines[currentLine] := replacementString
	
	
	IfInString, line, {
		{
			tabCount++
		}
		
		
		currentLine++
		
		joinedClipboard := ""
		for joinIndex, line in Lines ; Loop through each line
		{
			joinedClipboard := joinedClipboard . line . "`n"
		}
		; Set the modified content back to the clipboard
		clipboard := joinedClipboard
		
	} ; end of loop
	
	
	Clipboard := SubStr(Clipboard, 1, -1) ; Remove the trailing newline character
	
	Send ^v ; paste from clipboard
	
	restore := True ; some guy recommended this as the proper way to do clipboard restores, because clipboard pasting is asynchronous
	If (restore) {
		Sleep, 150
		While DllCall("user32\GetOpenClipboardWindow", "Ptr")
		Sleep, 150
		Clipboard := originalClipboard
	}
	
	Return
}

