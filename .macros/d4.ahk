#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
; SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
; SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; For q w e r + pot:

; TODO change the toggle to d-pad
; FIXME complains that Toggle isnt defined

; globals
Toggle := ""
Random lrand, 2500, 3000
Random srand, 0,2
; Random hort 0,2

F1::
If (Toggle = "")
{

; NOTE timer for each loop, 3s per pot
SetTimer, Loop1, 3000
SetTimer, Loope, 0
SetTimer, Loopr, 0
SetTimer, Loopq, 0
SetTimer, Loopw, 0
}
Else
 Pause
If (Toggle := !Toggle)
{
; NOTE Sleep between loop
 Gosub, Loop1
 Sleep srand
 Gosub, Loope
 Sleep srand
 Gosub, Loopr
 Sleep srand
 Gosub, Loopq
 Sleep srand
 Gosub, Loopw
 Sleep srand
}
return

Loop1:
Send, 1 ; Sends 1
return
Loope:
Send, e ; Sends e
return
Loopr:
Send, r ; Sends r
return
Loopq:
Send, q ; Sends q
return
Loopw:
Send, w ; Sends w
return

F2::
Reload


; Note: If you open the map while the script is active it opens the quest journal (bound to q by default, and you can't change this sadly) which causes stutter but is manageable, if you wanna use qwer. No issues if 1234. Slower pot spam or they'll run out too fast.

; Insta casting potion will mean you can't keep open inventory, it insta closes. Gotta be like 3000 or 5000. I started 5000 but now use 3000. It's good cuz pot is heals over 3s after the burst heal.

;F1::
;If (Toggle = "")
;{
;SetTimer, Loop1, 5000
;}
;Else
; Pause
;If (Toggle := !Toggle)
;{
; Gosub, Loop1
; Sleep 0
;}
;return

;F2::Reload

;Loop1:
;Send, 2 ; Sends 2
;return

;This uses a potion(number 2 for me) every 5000ms. If you want it more often or less, you change the 5000 to whatever you want. 5000 is 5 seconds. 500 is a half-second. You can adjust it whenever you want, if you wanna make it just a touch faster or a touch slower you can use 5111 or 4250 etc etc. 

;replace the number 2 with whatever ur potion button is, and change the timer to whatever u want. and just turn it on and off with f1/f2. You'll notice pretty quick if it's still on when ur outside of Diablo cuz it will input a 2 every however often.

