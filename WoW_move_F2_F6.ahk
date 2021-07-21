#NoEnv
SendMode Input 
SetWorkingDir %A_ScriptDir% 

; #Include <Functions>
#Include %A_MyDocuments%\AHK_Library\Functions.ahk

CreateWindow()


;Variables —————————————————————————————————————————————————————————
;———————————————————————————————————————————————————————————————————
Global MaxMove := 1970/2
;Botones ———————————————————————————————————————————————————————————
;———————————————————————————————————————————————————————————————————
f2:: 
SendKey("{a up}")
Sleep(0,10)
SendKey("{d up}")
Reload
Return

f6:: Main()
Return

f8::
SendKey("{a up}")
Sleep(0,10)
SendKey("{d up}")

ExitApp
	
;Interfaz ——————————————————————————————————————————————————————————
;———————————————————————————————————————————————————————————————————

Main(){
	CreateWindow()
	RandMove()
}

RandMove(){
	Loop{
		Move(Rand(1, 4))
		Sleep(0, 500)
		RandomJump()
	}
}


Move(action){
	
	
	If (action == 1)
		MoveLeft()
	If (action == 2)
		MoveRight()
	If ((action == 3) || (action == 4)){
		If Rand(0, 1)
			Sleep(100, 500)
		If Rand(0, 1)
			Sleep(100, 1000)
		If Rand(0, 1)
			Sleep(100, 1500)
	}
}

RandomJump(){
	If(Rand(1, 75) == 25)
		SendKey("{space}")
}

MoveLeft(){
	SendKey("{a down}")	
	Sleep(100, MaxMove)
	SendKey("{a up}")	
}


MoveRight(){
	SendKey("{d down}")	
	Sleep(100, MaxMove)
	SendKey("{d up}")	
}

;Metodos ——————————————————————————————————————————————————————————
;——————————————————————————————————————————————————————————————————


CreateWindow(titleWindow := False, dirWindow := False){
	
	global Window := new Window(titleWindow, dirWindow)
	Window.Open()
	Window.Wait()
	Window.Activate()
	Window.Get()
}