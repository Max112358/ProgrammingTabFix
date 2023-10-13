#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

global extraClipboardCopy := ""
SetNumLockState, AlwaysOn ; I dont like it when numlock is turned off
SetCapsLockState, AlwaysOff ; I also dont use caps lock ever

; The purpose of this script is to instantly fix any indentation errors in a program. 
; It uses curly braces to move in one indentation level every time scope changes
; There are 2 functions here, one for C based languages with curly braces and one for python type languages that use indentation
; The python side is simply supposed to replace quadruple spaces with a single tab for consistency
; the script should hopefully be able to tell from context what language its looking at, because python does not use curly braces

#r::Reload ; windows+r to reload script

#q::ExitApp ; windows+q to quit


#f::  ;windows+f to indent with tabs
determineLanguage()
Return

#g::  ;windows+g to apply or remove comments
localComments()
Return

#l::  ;windows+l to fix c based language
fixTabs()
Return

#p::  ;windows+p to fix python
fixPython()
Return

#c::  ;windows+c to copy something extra
extraCopy()
Return

#v::  ;windows+v to paste something extra
extraPaste()
Return




Return



determineLanguage() ; this figures out what language its looking at
{
	
	originalClipboard := clipboard
	Click ; click the item button to open the trade page
	Send ^a ; select all
	clipboard := ""  ; Start off empty to allow ClipWait to detect when the text has arrived.
	Send ^c ; cut all text
	ClipWait  ; Wait for the clipboard to contain text.
	clipboard := ClipboardAll ; Get the clipboard content
	
	
	
	; Initialize a variable to count curly braces
	BraceCount := 0
	
	; Loop through the string
	Loop, Parse, clipboard
	{
		; Check if the current character is a space
	if (A_LoopField = "{" || A_LoopField = "}" )
		{
			; Increment the space count
			BraceCount++
		}
	}
	
	
	if(BraceCount > 0){ ; if there are any braces at all its probably not python
		fixTabs()
	}else{
		fixPython()
	}
	
	
	
}














fixTabs() ; this is the main function
{
	
	
	; Set the delimiter for splitting lines
	LineDelimiter := "`n" ; Use `r`n for Windows line endings
	TabCharacter := "`t" ; set the character for indentation
	tabCount := 0
	
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












fixPython() ; this is the main function
{
	
	; Set the delimiter for splitting lines
	LineDelimiter := "`n" ; Use `r`n for Windows line endings
	
	Lines := StrSplit(Clipboard, LineDelimiter) ; Split the clipboard content into lines
	
	currentLine := 1
	for index, line in Lines ; Loop through each line
	{
		
		; Initialize a variable to count spaces
		SpaceCount := 0
		
		; Loop through the string
		Loop, Parse, line
		{
			; Check if the current character is a space
			if (A_LoopField = " ")
			{
				; Increment the space count
				SpaceCount++
			}
			else
			{
				; If a non-space character is encountered, stop the loop
				break
			}
		}
		
		
		
		; Initialize a variable to count tabs
		tabCount := 0
		
		; Loop through the string
		Loop, Parse, line
		{
			; Check if the current character is a space
			if (A_LoopField = "`t")
			{
				; Increment the space count
				tabCount++
			}
			else
			{
				; If a non-space character is encountered, stop the loop
				break
			}
		}
		
		
		if(SpaceCount > 0){
			tabCount := SpaceCount / 4
		}
		
		
		CleanedString := ""
		CleanedString := RegExReplace(line, "^[ \t]+") ; remove both spaces and tabs from the beginning
		
		
		; Initialize an empty string
		replacementString := ""
		
		; Insert tabs at the beginning of the string
		Loop % tabCount
		{
			replacementString := replacementString . "`t"
		}
		
		; Append the rest of the string
		replacementString := replacementString CleanedString
		
		; Display the resulting string
		; MsgBox %replacementString%
		
		
		Lines[currentLine] := replacementString
		
		
		
		
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







localComments() ; this is the main function
{
	
	originalClipboard := clipboard
	clipboard := ""  ; Start off empty to allow ClipWait to detect when the text has arrived.
	Send ^c ; cut all text
	ClipWait  ; Wait for the clipboard to contain text.
	clipboard := ClipboardAll ; Get the clipboard content
	
	CleanedString := ""
	CleanedString := RegExReplace(Clipboard, "^[ \t]+") ; remove both spaces and tabs from the beginning
	
	
	isAComment := False
	FirstTwoChars := SubStr(CleanedString, 1, 2)
	if (FirstTwoChars = "//")
	{
		isAComment := True
	}
	else
	{
		isAComment := False
	}
	
	
	; Set the delimiter for splitting lines
	LineDelimiter := "`n" ; Use `r`n for Windows line endings
	
	Lines := StrSplit(Clipboard, LineDelimiter) ; Split the clipboard content into lines
	
	currentLine := 1
	for index, line in Lines ; Loop through each line
	{
		
		
		CleanedString := ""
		CleanedString := RegExReplace(line, "^[ \t]+") ; remove both spaces and tabs from the beginning
		; MsgBox %CleanedString%
		
		; Get the length of the original line
		origLen := StrLen(line)
		
		; Get the length after trimming whitespace
		newLen := StrLen(CleanedString)
		
		; Calculate the whitespace chars trimmed
		whitespaceCount := origLen - newLen
		
		; Get substring from 0 to last whitespace char 
		leadingWS := SubStr(line, 1, origLen-newLen)

		; Get substring after whitespace 
		; content := SubStr(line, origLen-newLen+1) ; not needed as we already have cleaned string
		
		FirstTwoChars := SubStr(CleanedString, 1, 2)
		; Insert slashes at the beginning of the string
		if(isAComment && FirstTwoChars = "//"){
			CleanedString := SubStr(CleanedString, 3) ; if it is a removal scenario
		}
		else{
			CleanedString := "//" . CleanedString
		}
		

		replacementString := leadingWS CleanedString
		
		Lines[currentLine] := replacementString
		
		
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





extraCopy() ; store an extra clipboard
{
	originalClipboard := clipboard
	clipboard := ""  ; Start off empty to allow ClipWait to detect when the text has arrived.
	Send ^c ; cut all text
	ClipWait  ; Wait for the clipboard to contain text.
	clipboard := ClipboardAll ; Get the clipboard content
	
	extraClipboardCopy := clipboard
	
	restore := True ; some guy recommended this as the proper way to do clipboard restores, because clipboard pasting is asynchronous
	If (restore) {
		Sleep, 150
		While DllCall("user32\GetOpenClipboardWindow", "Ptr")
		Sleep, 150
		Clipboard := originalClipboard
	}
	
	Return
}



extraPaste() ; paste the extra clipboard
{
	originalClipboard := clipboard
	clipboard := ""  ; Start off empty to allow ClipWait to detect when the text has arrived.
	
	
	restore := True ; some guy recommended this as the proper way to do clipboard restores, because clipboard pasting is asynchronous
	If (restore) {
		Sleep, 150
		While DllCall("user32\GetOpenClipboardWindow", "Ptr")
		Sleep, 150
		Clipboard := extraClipboardCopy
	}
	
	Send ^v ; paste all text
	
	restore := True ; some guy recommended this as the proper way to do clipboard restores, because clipboard pasting is asynchronous
	If (restore) {
		Sleep, 150
		While DllCall("user32\GetOpenClipboardWindow", "Ptr")
		Sleep, 150
		Clipboard := originalClipboard
	}
	
	Return
}



