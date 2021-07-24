#NoEnv
SendMode Input 
SetWorkingDir %A_ScriptDir% 

; #Include <Functions>
#Include %A_MyDocuments%\AHK_Library\Functions.ahk

CreateWindow()

useCursor := True
;Variables —————————————————————————————————————————————————————————
;———————————————————————————————————————————————————————————————————
Move := new Move()
;Botones ———————————————————————————————————————————————————————————
;———————————————————————————————————————————————————————————————————

1::
	Move.Random(0, 45)
Return 

2::ExitApp Return
^F1:: Reload Return

^F5:: Move.Random(-90, 0) Return

^F7:: ExitApp Return

;Interfaz ——————————————————————————————————————————————————————————
;———————————————————————————————————————————————————————————————————

Class Move
{
	
	__NEW()
	{
		This.setLastCoor()
		This.degreesNow := 90
	}
	
	Random(degreesMinRange, degreesMaxRange)
	{
		randDegrees := Rand(degreesMinRange, degreesMaxRange)
		
		If Rand(0, 1)
		{
			If((This.degreesNow + randDegrees) > degreesMaxRange)
				This.Left(degreesMaxRange - Abs(This.degreesNow))
			Else	
				This.Left(randDegrees)
		}
		Else
		{
			If((This.degreesNow - randDegrees) < degreesMinRange)
				This.Right(degreesMinRange - Abs(This.degreesNow))
			Else	
				This.Right(randDegrees)
		}
		
		Print("Grados: " This.degreesNow)
	
	}	
	
	deegresToMs(degrees)
	{
		Return degrees*2000/360
	}
	
	msToDeegres(ms)
	{
		Return ms*360/2000
	}
	
	Left(degrees, exact := False)
	{
		If(degrees < 0)
			This.Right(Abs(degrees))
		Else
		{
			If !exact
				degrees := degrees + This.RandDegrees()
				
			SendClick(This.lastCoorX, This.lastCoorY, "X1", False,,, "D")
			Sleep(This.deegresToMs(degrees))
			SendClick(This.lastCoorX, This.lastCoorY, "X1", False,,, "U")
			This.degreesNow += degrees
		}
	}
	
	Right(degrees, exact := False)
	{
		If(degrees < 0)
			This.Left(Abs(degrees))
		Else
		{
			SendClick(This.lastCoorX, This.lastCoorY, "X2", False,,, "D")
			Sleep(This.deegresToMs(degrees))
			SendClick(This.lastCoorX, This.lastCoorY, "X2", False,,, "U")
			This.degreesNow -= degrees
		}
	}
	
	Jump()
	{	
	}
	
	RandDegrees(minRandDegrees := -5, maxRandDegrees := 5)
	{
		; This.lastRandDegrees := Rand(minRandDegrees*10, maxRandDegrees*10)/10
		Return Rand(minRandDegrees*1000, maxRandDegrees*1000)/1000
	}
	
	setLastCoor()
	{	
		This.lastCoorX := Rand(Window._X/2 + 50, Window._X - 50)
		This.lastCoorY := Rand(Window._Y/3, Window._Y*2/3 - 30)
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
