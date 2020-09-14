#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#Include JSON.ahk
global StatusFilePath := "C:\Users\markus\Saved Games\Frontier Developments\Elite Dangerous\Status.json"

global oldEDFlags 	:= 0
global EDFlags		:= 0
global Docked 		:= 0
global Landed 		:= 0
global GearDown	 	:= 0
global ShieldsUp	:= 0
global Supercruise	:= 0
global FAOff		:= 0
global Hardpoints	:= 0
global InWing		:= 0
global LightsOn	 	:= 0
global CargoScoop	:= 0
global Silent		:= 0
global Scooping	 	:= 0
global SRV_Brake	:= 0
global SRV_Turret	:= 0
global SRV_TurrDn	:= 0
global SRV_Assist   := 0
global Masslocked   := 0
global FSDCharging  := 0
global FSDCooldown	:= 0
global LowFuel		:= 0
global OverHeating  := 0
global HasLatLon	:= 0
global IsInDanger	:= 0
global Interdicted	:= 0
global InMainShip	:= 0
global InFighter	:= 0
global InSRV		:= 0
global AnalysisMde  := 0
global NightVsn	 	:= 0
global AvgAltitude  := 0
global FsdJump		:= 0
global SRVHighBeam  := 0


GetEDStatus()
{
	FileRead, EDstring, % StatusFilePath
	EDStatus := JSON.load(EDstring)

	Docked 		:= EDStatus.Flags & 0x00000001
	Landed 		:= EDStatus.Flags & 0x00000002
	GearDown	:= EDStatus.Flags & 0x00000004
	ShieldsUp	:= EDStatus.Flags & 0x00000008
	Supercruise	:= EDStatus.Flags & 0x00000010
	FAOff		:= EDStatus.Flags & 0x00000020
	Hardpoints	:= EDStatus.Flags & 0x00000040
	InWing		:= EDStatus.Flags & 0x00000080
	LightsOn	:= EDStatus.Flags & 0x00000100
	CargoScoop	:= EDStatus.Flags & 0x00000200
	Silent		:= EDStatus.Flags & 0x00000400
	Scooping	:= EDStatus.Flags & 0x00000800
	SRV_Brake	:= EDStatus.Flags & 0x00001000
	SRV_Turret	:= EDStatus.Flags & 0x00002000
	SRV_TurrDn	:= EDStatus.Flags & 0x00004000
	SRV_Assist  := EDStatus.Flags & 0x00008000
	Masslocked  := EDStatus.Flags & 0x00010000
	FSDCharging := EDStatus.Flags & 0x00020000
	FSDCooldown	:= EDStatus.Flags & 0x00040000
	LowFuel		:= EDStatus.Flags & 0x00080000
	OverHeating := EDStatus.Flags & 0x00100000
	HasLatLon	:= EDStatus.Flags & 0x00200000
	IsInDanger	:= EDStatus.Flags & 0x00400000
	Interdicted	:= EDStatus.Flags & 0x00800000
	InMainShip	:= EDStatus.Flags & 0x01000000
	InFighter	:= EDStatus.Flags & 0x02000000
	InSRV		:= EDStatus.Flags & 0x04000000
	AnalysisMde := EDStatus.Flags & 0x08000000
	NightVsn	:= EDStatus.Flags & 0x10000000
	AvgAltitude := EDStatus.Flags & 0x20000000
	FsdJump		:= EDStatus.Flags & 0x40000000
	SRVHighBeam := EDStatus.Flags & 0x80000000
	
	EDFlags := EDStatus.Flags
}

checkHardpoints(flipstate)
{
	GetEDStatus()
	if( Docked )
		return
	if( Landed )
		return
	if( InFighter )
		return
	if( InSRV )
	{
		if( (!flipstate) && SRV_Turret )
			return
		if( flipstate && (!SRV_Turret) )
			return
		send H
		return
	}
	if( InMainShip )
	{
		if( (!flipstate) && Hardpoints )
			return
		if( flipstate && (!Hardpoints) )
			return
		send H
		return
	}
	return
}

checkCombatMode(flipstate)
{
	GetEDStatus()
	if( InSRV || InFighter || InMainShip )
	{
		if( (!flipstate) && (!AnalysisMde) )
			return
		if( flipstate && AnalysisMde )
			return
		send M
		return
	}
	return
}

;initialize: read out current flags and button states, send commands if they don't match
SetKeyDelay, 10, 20
GetEDStatus()
oldEDFlags := EDFlags
checkHardpoints(GetKeyState("1Joy1"))
checkCombatMode(GetKeyState("2Joy1"))
;MsgBox, % "EDFlags = " . EdFlags
setTimer, WaitForStatusChange, 100

;now run the loop
1Joy1::
	;MsgBox, 1Joy1 up
	checkHardpoints(1)
	setTimer, WaitForHardpointsDn, 20
	return
	
2joy1::
	;MsgBox, 2Joy1 up
	checkCombatMode(1)
	setTimer, WaitForCombatModeDn, 20
	return

WaitForHardpointsDn:
	if (GetKeyState("1joy1"))	; trigger still up, do nothing
		return
	; flip trigger is down
	;MsgBox, 1joy1 dn
	checkHardpoints(0)
	setTimer, WaitForHardpointsDn, off
	return
	
WaitForCombatModeDn:
	if (GetKeyState("2joy1"))	; trigger still up, do nothing
		return
	; flip trigger is down
	;MsgBox, 2joy1 dn
	checkCombatMode(0)
	setTimer, WaitForCombatModeDn, off
	return
	
WaitForStatusChange:
	GetEDStatus()
	if( oldEDFlags == EDFlags )
		return						; nothing changed
	checkHardpoints(GetKeyState("1Joy1"))
	checkHardpoints(GetKeyState("2Joy1"))
	oldEDFlags := EDFlags
	return
	
^x::ExitApp	