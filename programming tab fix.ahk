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

#d::  ;windows+d to apply or remove comments
localComments()
Return

#c::  ;windows+c or windows+x to copy something extra
#x::  ;
extraCopy()
Return

#v::  ;windows+v to paste something extra
extraPaste()
Return


Return



determineLanguage() ; this figures out what language its looking at
{
	
	originalClipboard := clipboard
	Click ; click to put focus on the text
	Send ^a ; select all
	clipboard := ""  ; Start off empty to allow ClipWait, 1 to detect when the text has arrived.
	Send ^c ; cut all text
	ClipWait, 1  ; Wait for the clipboard to contain text.
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
	multiLineComment := false
	
	Lines := StrSplit(Clipboard, LineDelimiter) ; Split the clipboard content into lines
	JoinedClipboard := ""
	
	for index, line in Lines ; Loop through each line
	{
		
		localCount := 0
		isComment := multiLineComment
		isQuote := false
		
		CleanedString := ""
		CleanedString := RegExReplace(line, "^[ \t]+") ; remove both spaces and tabs from the beginning
		
		
		
		Loop, Parse, CleanedString ; Loop through the characters in the current CleanedString element
		{
			firstTwoChars := SubStr(CleanedString, A_Index, 2)
			firstChar := SubStr(CleanedString, A_Index, 1)
			; MsgBox %c%
			
			doubleQuote := """"
			singleQuote := SubStr(doubleQuote, 1, 1)
			
			if (firstChar == singleQuote && !isQuote) {
				isQuote := true
			}else if(firstChar == singleQuote && isQuote){
				isQuote := false
			}
			
			
			if (firstTwoChars = "//" && !isQuote) {
				; Check if the previous character is also '/' to prevent comments from causing issues
				isComment := true
			}
			
			if (firstTwoChars = "/*" && !isQuote) {
				; Check for multi-line comment start
				multiLineComment := true
				isComment := true
			}
			
			
			if (firstTwoChars = "*/" && !isQuote) {
				; Check for multi-line comment end
				multiLineComment := false
				isComment := false
			}
			
			if (firstChar = "}" && !isComment && !isQuote) {
				localCount--
			}
			
			if (firstChar = "{" && !isComment && !isQuote) {
				localCount++
			}
		}
		
		
		
		
		
		specialCase := false ; Initialize specialCase as false
		
		; Check if the first character in inputVector[i] is '}' and handle the special case
		firstChar := SubStr(CleanedString, 1, 1 && localCount == 0)
		if (firstChar = "}") {
			tabCount-- ; Decrement tabCount
			specialCase := true ; Set specialCase to true
		}
		
		
		
		; Adjust tabCount only if it has gone backward
		if (localCount < 0) {
			tabCount += localCount
		}
		
		
		
		
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
		
		; undo the special case
		if (firstChar = "}") {
			tabCount++ ; Decrement tabCount
		}
		
		
		; Adjust tabCount only if it has gone forward, AFTER tabbing the line. This is for the next line.
		if (localCount > 0) {
			tabCount += localCount
		}
		
		JoinedClipboard := JoinedClipboard . replacementString . "`n" ; join the lines back together
		
		
	} ; end of loop
	
	JoinedClipboard := SubStr(JoinedClipboard, 1, -1) ; Remove the trailing newline character
	replaceClipboard(JoinedClipboard) ; put the modified code in the clipboard
	
	Send ^v ; paste from clipboard
	Sleep, 50 ; wait for paste to finish
	
	replaceClipboard(originalClipboard) ; put the original in the clipboard
	
	Return
}








fixPython() ; this is the main function
{
	
	; Set the delimiter for splitting lines
	LineDelimiter := "`n" ; Use `r`n for Windows line endings
	
	Lines := StrSplit(Clipboard, LineDelimiter) ; Split the clipboard content into lines
	JoinedClipboard := ""
	
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
		
		
		JoinedClipboard := JoinedClipboard . replacementString . "`n" ; join the lines back together
		
		
	} ; end of loop
	
	JoinedClipboard := SubStr(JoinedClipboard, 1, -1) ; Remove the trailing newline character
	replaceClipboard(JoinedClipboard) ; put the modified code in the clipboard
	
	Send ^v ; paste from clipboard
	Sleep, 50 ; wait for paste to finish
	
	replaceClipboard(originalClipboard) ; put the original in the clipboard
	
	Return
}







localComments() ; this is the main function
{
	
	originalClipboard := clipboard
	clipboard := ""  ; Start off empty to allow ClipWait to detect when the text has arrived.
	Send ^c ; cut all text
	ClipWait, 1  ; Wait for the clipboard to contain text.
	clipboard := ClipboardAll ; Get the clipboard content
	
	
	addCommentMode := False
	
	; Set the delimiter for splitting lines
	LineDelimiter := "`n" ; Use `r`n for Windows line endings
	
	Lines := StrSplit(Clipboard, LineDelimiter) ; Split the clipboard content into lines
	JoinedClipboard := ""
	
	containsUncommentedCode := False
	for index, line in Lines ; Loop through each line
	{
		CleanedString := ""
		CleanedString := RegExReplace(line, "^[ \t]+") ; remove both spaces and tabs from the beginning
		CleanedString := StrReplace(CleanedString, "`r`n`t ") ; remove carriage return, newline char, tabs and spaces
		CleanedString := RegExReplace(CleanedString, "[\x00-\x1F\x7F-\xFF]") ; remove non printable characters
		
		FirstTwoChars := SubStr(CleanedString, 1, 2)
		if(FirstTwoChars != "//" && StrLen(CleanedString) > 0){
			containsUncommentedCode := True
		}
	}
	
	
	
	Lines := StrSplit(Clipboard, LineDelimiter) ; Split the clipboard content into lines
	
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
		
		; Insert slashes at the beginning of the string
		if(containsUncommentedCode){
			if (RegExMatch(CleanedString, "[^ \t\n\r]")) {
				CleanedString := "//" . CleanedString
				; MsgBox, The string contains characters other than spaces or tabs.
			}
		}
		else{
			CleanedString := SubStr(CleanedString, 3) ; if it is a removal scenario
		}
		
		
		replacementString := leadingWS CleanedString
		
		JoinedClipboard := JoinedClipboard . replacementString . "`n" ; join the lines back together
		
	} ; end of loop
	
	
	JoinedClipboard := SubStr(JoinedClipboard, 1, -1) ; Remove the trailing newline character
	replaceClipboard(JoinedClipboard) ; put the modified code in the clipboard
	
	Send ^v ; paste from clipboard
	Sleep, 50 ; wait for paste to finish
	
	replaceClipboard(originalClipboard) ; put the original in the clipboard
	
	Return
}


extraCopy() ; store an extra clipboard
{
	originalClipboard := clipboard
	clipboard := ""  ; Start off empty to allow ClipWait to detect when the text has arrived.
	Send ^c ; cut all text
	ClipWait, 1  ; Wait for the clipboard to contain text.
	clipboard := ClipboardAll ; Get the clipboard content
	
	extraClipboardCopy := clipboard
	
	replaceClipboard(originalClipboard) ; put the original in the clipboard
	
	Return
}


extraPaste() ; paste the extra clipboard
{
	originalClipboard := clipboard
	
	replaceClipboard(extraClipboardCopy) ; put the copy in the clipboard
	
	Send ^v ; paste all text
	Sleep, 50 ; wait for paste to finish
	
	replaceClipboard(originalClipboard) ; put the original in the clipboard
	
	Return
}


replaceClipboard(clipboardToRestore) ; swap the clipboard to something else. This involves some waiting.
{
	clipboard := ""  ; Start off empty to allow ClipWait, 1 to detect when the text has arrived.
	clipboard := clipboardToRestore
	
	; just in case the clipboard was originally empty, dont wait in that case
	if(clipboardToRestore != ""){ 
		ClipWait, 1  ; Wait for the clipboard to contain text.
	}
	
	Return
}



