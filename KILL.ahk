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

|:: Action.ChangeType() Return
^MButton:: Reload Return
!MButton:: ExitApp

;Interfaz ——————————————————————————————————————————————————————————
;———————————————————————————————————————————————————————————————————

Class Action
{
	nClicks := 0, ClicksRandom := 0, lastCast := 0, lastSecondCast := 0
	
	__NEW()
	{
		This.ChangeType()
	}
	
	Start(Mode)
	{
		This.Mode := Mode
		If This.SecondCast := False
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
				; If This.readyToLoot()
					; Print("LOOT")
				This.tryChangeForm()
				If This.readyToLoot()
					This.tapButton()
				This.lastType := "LOOT"
				Sleep(16)
			}
		}
	}
	
	tapButton()
	{
		TypeNow := This.Type		
		This.setTaps()
		This.setLastCoor()
		
		Print("[Btn " This.Type "]")
		Loop % This.nTaps
		{
			Sleep(0, 70)
			This.buttonAction()
		}
		
		This.nClicks++
If(TypeNow != This.Type)
	Return		
		This.setSleep()	
If(TypeNow != This.Type)
		Return		
		This.TypeKill()
		
	}
	
	TypeKill()
	{
		If((This.Type == "KILL"))
		{
			This.HumanMistake()
			This.waitCD()
			
			If(This.SecondCast)
			{
				If(This.readyToSecondCast(5000))
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
			This.nTaps := Rand(2, 5)
	}
	
	setLastCoor()
	{	
		If(This.nClicks >=  This.ClicksRandom)
		{
			This.nClicks := 0, This.ClicksRandom := Rand(5, 20)	
			This.lastCoorX := Rand(Window.W/2 + 50, Window.W - 50)
			This.lastCoorY := Rand(Window.H/3, Window.H*2/3 - 30)
		}
	}
	
	setSleep()
	{
		If(This.Mode = "UseMacro")
			Sleep(150, 400)
		Else If(This.Mode = "UseClick")
		{
			If(This.Type == "KILL")
				Sleep(188, 450)
			Else If (This.Type == "LOOT")
				Sleep(130, 300)
		}
	}
	
	buttonAction(Type := "")
	{
		
		If(Type != "")
			auxType := This.Type, This.Type := Type
; ---------------------------------------------------------------------
		
		If(This.Type == "KILL")
				Button := "WU"
		Else If (This.Type == "LOOT")
				Button := "WD"
		
		If(This.Mode = "UseMacro")
		{
			SendClick(This.lastCoorX, This.lastCoorY, Button, False)
		}
		Else If(This.Mode = "UseClick")
		{
			useCursor := True
			Window.Activate()
			SendClick("", "", Button, False)
		}

; ---------------------------------------------------------------------
		
		If(Type != "")
			This.Type := auxType
			
		This.lastCast := A_TickCount
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