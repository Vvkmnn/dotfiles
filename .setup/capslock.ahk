; Change Caps Lock to Control when held down; otherwise, Escape
;
; Originally based on the answer provided in 
; [this](https://superuser.com/questions/581692/remap-caps-lock-in-windows-escape-and-control)
; StackExchange SuperUser question.
;
; A shortcut should be created for this script and placed in the Windows 10
; user's startup folder to automatically enable the feature on boot/startup.
; The user's startup folder can be found using the following steps:
;
; 1. Windows Key+R. The _Run_ dialog will appear.
; 2. Enter the following: `%appdata%\Microsoft\Windows\Start Menu\Programs\Startup`
; 3. Press Enter key. A file explorer dialog will appear.
; 
; Obviously, [AutoHotkey](https://autohotkey.com/) must be installed for this to work.
*CapsLock::
    Send {Blind}{Ctrl Down}
    cDown := A_TickCount
Return

*CapsLock up::
    If ((A_TickCount-cDown)<150)  ; Modify press time as needed (milliseconds)
            Send {Blind}{Ctrl Up}{Esc}
        Else
	        Send {Blind}{Ctrl Up}
Return
