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

1::

If(1 == 0)
	Reload
Else
	Print("test")
F5:: 
Action.Start("UseMacro")
; Action.Start("UseClick")
Return

|:: Action.changeType() Return

F1:: reload Return

F7:: exitapp

;Interfaz ——————————————————————————————————————————————————————————
;———————————————————————————————————————————————————————————————————

Class Action
{
	
	__NEW()
	{
		This.changeType()
	}
	
	Start(Mode)
	{
		This.nClicks := 0, This.ClicksRandom := 0, This.lastCast := 0
		
		This.Mode := Mode
		This.setCoor()
		
		This.SecondCast := False
		This.setDelayLoot()
		
		Print("S T A R T")
		
		Loop
		{
			If(This.Type == "KILL")
			{
				This.tapButton()
				This.waitCD()				
					
				This.lastType := "KILL"
			}			
			Else If (This.Type == "LOOT")
			{
				If(This.lastType == "KILL")
					If This.inCombat()
						This.buttonForm("Feline")
					Else
						This.buttonForm("Travel")
				
				If(This.Form == "Feline")
					If !This.inCombat()
						This.buttonForm("Travel")
				
				If(This.targetDead())
				{	
					If(This.Form == "Feline")
						This.tapButton()
					Else
					{
						While(This.targetDead())
						{
							This.tapButton()
						}
					}
						
					
				}
				This.lastType := "LOOT"
			}

		}
		
	}
	
	tapButton()
	{
		
		This.setTaps()
		This.setLastCoor()
		
		Print("[Btn " This.Type "]")
		
		Loop % This.nTaps
		{
			Sleep(0, 70)
			If(This.Type == "KILL")
				This.buttonKill()
			Else If (This.Type == "LOOT")
				This.buttonLoot()
		}
		
		If(This.Type == "KILL")
			This.HumanMistake()
		This.nClicks++
		This.setSleep()
		
		
		If(This.SecondCast && (This.Type == "KILL"))
		{
			If(This.ReadyToLoot(5000))
			{
				Sleep(100)
				Loop % Rand(3, 7)
				{
					Sleep(0, 60)
					This.buttonLoot()
				}
				Print("[Loot]")
			}
		}
	}
	
	waitCD()
	{
		Print("Esperando CD")
		While((A_TickCount - This.lastCast) <= 1400)
		{
			This.getCD()
			If ((!This.CD) || (This.CD == "Finishing"))
				Break
		}
		
		Sleep(0, 100)
	}
	
	getCD()
	{
		initX := 550, initY := 50
		finishX := 1030, finishY := 50
		
		If !Image(A, "CD", "", initX-50, initY-50, initX+50, initY+50)
			This.CD := False
		Else If Image(A, "CD", "", finishX-50, finishY-50, finishX+50, finishY+50)
			This.CD := "Finishing"
		Else
			This.CD := True
	}
	
	inCombat()
	{
		X := 220, Y := 27
		Return Image(A, "inCombat", "", X-20, Y-20, X+20, Y+20)	
	}
	
	targetDead()
	{ 
		If(Image(A, "targetDead", "", This.X - 150, This.Y - 50, This.X + 150, This.Y + 50))
		{
			This.lastFound := A_TickCount
			Return True
		}
		Else
			Return False
	}
	
	setTaps()
	{
		If(This.Type == "KILL")
			This.nTaps := Rand(3, 8)
		Else If (This.Type == "LOOT")
			This.nTaps := Rand(3, 7)
	}
	
	setLastCoor()
	{	
		If(This.nClicks >=  This.ClicksRandom)
		{
			This.nClicks := 0, This.ClicksRandom := Rand(5, 20)	
			This.lastCoorX := Rand(Window._X/2 + 50, Window._X - 50)
			This.lastCoorY := Rand(Window._Y/3, Window._Y*2/3 - 30)
		}
	}
	
	setSleep()
	{
		If(This.Mode = "UseMacro")
			Sleep(150, 430)
		Else If(This.Mode = "UseClick")
		{
			If(This.Type == "KILL")
				Sleep(188, 450)
			Else If (This.Type == "LOOT")
				Sleep(130, 300)
				; Sleep(70, 130)

		}
	}
	
	buttonKill()
	{
		If(This.Mode = "UseMacro")
		{
			SendClick(This.lastCoorX, This.lastCoorY, "WU", False)
		}
		Else If(This.Mode = "UseClick")
		{
			useCursor := True
			Window.Activate()
			SendClick("", "", "WU", False)
		}
		
		This.lastCast := A_TickCount
		
	}
	
	buttonLoot()
	{
		If(This.Mode = "UseMacro")
		{
			SendClick(This.lastCoorX, This.lastCoorY, "WD", False)
		}
		Else If(This.Mode = "UseClick")
		{
			useCursor := True
			Window.Activate()
			SendClick("", "", "WD", False)
		}
		
		This.lastCast := A_TickCount
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
		
		Print("Forma " This.Form)
	}
	
	HumanMistake()
	{
		If(Rand(1, 100) == 1)
		{
			If Rand(0, 1)
				Sleep(100, 500)
			Else
			{
				If Rand(0, 1)
					This.buttonKill()
				Else
					This.buttonLoot()
			}
			Print("HumanMistake")
		}
	}
	
	setDelayLoot(minSeconds := 0, maxSeconds := 7)
	{
		this.delayLoot := Rand(minSeconds * 1000, maxSeconds * 1000)
	}
	
	ReadyToLoot(ms)
	{
			
		If ((A_TickCount - this.startCast) > (ms + this.delayLoot)){
				this.startCast := A_TickCount
				This.setDelayLoot()
				Return True
		}
		Else
			Return False
	}
	
	setCoor()
	{
		This.X := 1375
		This.Y := 800
	}
	
	changeType()
	{
		If (This.Type == "KILL")
			This.Type := "LOOT"
		Else
			This.Type := "KILL"
		Clear()
		Print("--> " This.Type " <---")
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
}