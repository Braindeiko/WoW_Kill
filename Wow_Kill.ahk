#NoEnv
SendMode Input 
SetWorkingDir %A_ScriptDir% 

; #Include <Functions>
#Include %A_MyDocuments%\AHK_Library\Functions.ahk

CreateWindow()

;Variables —————————————————————————————————————————————————————————
;———————————————————————————————————————————————————————————————————
Action := new Action()
;Botones ———————————————————————————————————————————————————————————
;———————————————————————————————————————————————————————————————————

F5:: Action.Start("UseClick") Return
F6:: Action.Start("UseMacro") Return
|:: 
	Action.ChangeType()
	If(GetKeyState("|") And Action.Start)
	{
		initPress := A_TickCount
		While(GetKeyState("|"))
		{
			If((A_TickCount - initPress) >= 250)
			{
				Reload
				Return
			}
		}
	}
Return

!F12::
	SoundPlay, %dirImage%soundLoot.mp3
	Run, %comspec% /c SndVol.exe,, Hide
Return
;Interfaz ——————————————————————————————————————————————————————————
;———————————————————————————————————————————————————————————————————

Class Action
{
	nClicks := ClicksRandom := lastCast := lastSecondCast := errorLoot := Start := 0
	
	__NEW()
	{
		This.ChangeType()
	}
	
	Start(Mode)
	{
		This.Mode := Mode, This.Start := True
		If This.secondCast := False
			This.setRandDelay_SecondCast()
		Print("S T A R T")
Loop
{
	If(This.Type == "KILL")
	{
		This.tapButton()
		This.lastType := "KILL"
	}
	Else If (This.Type == "LOOT")
	{
		This.tryChangeForm()
		If(This.readyToLoot())
		{		
			This.comprobateErrorLoot()
			
			BlockInput, On
			
			If GetKeyState("W")
				SendKey("{W UP}")
			If GetKeyState("A")
				SendKey("{A UP}")
			If GetKeyState("S")
				SendKey("{S UP}")
			If GetKeyState("D")
				SendKey("{D UP}")
				
			This.tapButton()
			BlockInput, Off
			SoundPlay, %dirImage%soundLoot.mp3
			This.setSleep()
			
			; If ((This.Type == "LOOT") And (This.Form == "Travel"))
			; {
				; Sleep(0, 50)
				; Sendkey("{Space down}")
				; Sleep(140, 230)
				; Sendkey("{Space up}")
			; }
		}
		This.lastType := "LOOT"
		Sleep(16)
	}
}
	}
	
	comprobateErrorLoot()
	{
		If((A_TickCount - This.lastLoot) <= 700)
		{
			This.errorLoot++
			If(This.errorLoot > 2)
				Reload
		}
		Else
			This.errorLoot := 0
	}
	
	tapButton()
	{
		TypeNow := This.Type, This.nClicks++
		This.setTaps()
		This.setLastCoor()
		
		Print("[Btn " This.Type "]")
		Loop % This.nTaps
		{
			This.buttonAction()
			Sleep(0, 70)
		}
		
		If(TypeNow != This.Type)
			Return
			
		If(This.Type == "KILL")
		{
			This.TypeKill()
			This.HumanMistake()
			This.SecondCast()
			This.setSleep()
			This.waitCD()
		}
		
		If(GetKeyState("F5"))
		{
			initPress := A_TickCount
			While(GetKeyState("F5"))
			{
				If((A_TickCount - initPress) >= 50)
					ExitApp
			}
		}
	}
	
	SecondCast()
	{
		If(This.secondCast)
		{
			If(This.readyToSecondCast(10000))
			{
				Sleep(100)
				Loop % Rand(3, 7)
				{
					Sleep(0, 60)
					This.buttonLoot()
				}
				This.lastSecondCast := A_TickCount
				Print("[Loot]")
			}
		}
	}
	
	waitCD()
	{
		While((A_TickCount - This.lastCast) <= 1300)
		{
			This.comprobateCD()
			If ((!This.CD) || (This.CD == "Finishing"))
				Break
		}
		Print("CD: " A_TickCount - This.lastCast)
		Sleep(0, 50)
		Return This.CD
	}
	
	comprobateCD()
	{	
		If This.inHUD("CD_Active")
		{
			If This.inHUD("CD_Finishing")
				This.CD := "Finishing"
			Else
				This.CD := True
		}
		Else If This.inHUD("CD_Finishing")
			This.CD := "Finishing"
		Else
			This.CD := False
	}

	setTaps()
	{
		If(This.Type == "KILL")
			This.nTaps := Rand(3, 8)
		Else If (This.Type == "LOOT")
			This.nTaps := Rand(2, 3)
	}
	
	setLastCoor()
	{	
		If(This.nClicks >=  This.ClicksRandom)
		{
			This.nClicks := 0
			This.ClicksRandom := Rand(5, 20)	
			
			If(This.Mode == "UseMacro")
			{
				This.lastCoorX := Rand(Window.W/4 + 50, Window.W - 50)
				This.lastCoorY := Rand(Window.H/4, Window.H*2/3 - 30)
			}
			Else If(This.Mode == "UseClick")
			{
				This.lastCoorX := Rand(Window.W/2 + 50, Window.W - 50)
				This.lastCoorY := Rand(Window.H/3, Window.H*2/3 - 30)
			}
			
		}
	}
	
	setSleep()
	{
		If(This.Mode == "UseMacro")
		{
			If(This.Type == "KILL")
				Sleep(150, 400)
			Else If (This.Type == "LOOT")
				Sleep(330, 400)
		}
		Else If(This.Mode == "UseClick")
		{
			If(This.Type == "KILL")
				Sleep(188, 450)
			Else If (This.Type == "LOOT")
				Sleep(330, 400)
		}
	}
	
	buttonAction(Type := "")
	{
		
		auxType := This.Type
		auxMode := This.Mode
		
		If(Type != "")
			This.Type := Type
; ---------------------------------------------------------------------
		
		If(This.Type == "KILL")
		{
			Button := "WU"
			This.lastCast := A_TickCount
		}
		Else If(This.Type == "LOOT")
		{
			Button := "WD"
			This.lastLoot := A_TickCount
			This.Mode := "UseClick"
		}
			
		If(This.Mode == "UseMacro")
		{
			SendClick(This.lastCoorX, This.lastCoorY, Button, False)
		}
		Else If(This.Mode == "UseClick")
		{
			useCursor := True
			SendClick("", "", Button, False)
			useCursor := False
		}
; ---------------------------------------------------------------------
		This.Type := auxType
		This.Mode := auxMode
	}

; L O O T {
	tryChangeForm()
	{
		If(This.lastType == "KILL")
			If This.inHUD("inCombat")
				This.buttonForm("Feline")
			Else
				This.buttonForm("Travel")
				
		If(This.Form == "Feline")
			If !This.inHUD("inCombat")
				This.buttonForm("Travel")
	}
	
	readyToLoot()
	{
		Return IsMatchCursor(dirImage "cursorLoot.bmp")
	}
	
	buttonForm(Form)
	{
		This.waitCD()
		
		If(Form == "Travel")
			SendKey("{F12}")
		Else If(Form == "Feline")
			SendKey("{F11}")
		
		This.Form := Form
		This.lastCast := A_TickCount
		
		Sleep(250)
		Print("Forma " This.Form)
	}
;}	

; K I L L {
	setRandDelay_SecondCast(minSeconds := 0, maxSeconds := 7)
	{
		This.randDelay_SecondCast := Rand(minSeconds * 1000, maxSeconds * 1000)
	}
	
	readyToSecondCast(ms)
	{		
		If ((A_TickCount - This.lastSecondCast) > (ms + This.randDelay_SecondCast)){
			This.setRandDelay_SecondCast()
			Return True
		}
		Else
			Return False
	}
;}
	HumanMistake()
	{
		If(Rand(1, 100) == 1)
		{
			If Rand(0, 1)
				Sleep(100, 500)
			Else
			{
				If Rand(0, 1)
					This.buttonAction("KILL")
				Else
					This.buttonAction("LOOT")
			}
			Print("HumanMistake")
		}
	}
	
	ChangeType()
	{
		If (This.Type == "KILL")
			This.Type := "LOOT", This.lastType := "KILL"
		Else
			This.Type := "KILL", This.lastType := "LOOT"
		; Clear()
		Print("--> " This.Type " <---")
	}

	inHUD(name)
	{
		Win.Get()
		Return Image(A, name, "", Window.W*(1/3), 0, Window.W*(2/3), 100)
	}
}

;Metodos ——————————————————————————————————————————————————————————
;——————————————————————————————————————————————————————————————————


CreateWindow(titleWindow := False, dirWindow := False){
	
	global Window := new Window(titleWindow, dirWindow)
	Window.Open()
	Window.Wait()
	Window.Activate()
	Window.Get()
	; Window.Move(0, 0, 800, 600)
}