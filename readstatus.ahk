#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#Include JSON.ahk

;yes, all these need to be global
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

; read out ED's Status.json and (for now) extract the flag bits. There's more useful information in that file,
; see https://elite-journal.readthedocs.io/en/latest/Status%20File/ - I just don't know what else I could/should use
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

; check the status and switch position for hardpoints and trigger ED if they don't match
checkHardpoints(flipstate)
{
	GetEDStatus()
	if( Docked )	; can't deploy hardpoints while docked
		return
	if( Landed )	; can't deploy hardpoints while landed
		return
	if( InFighter )	; can't retract hardpoints while in the fighter
		return
	if( InSRV )		; SRV: flip switches between main view and turret view, hardpoints are always deployed
	{
		if( (!flipstate) && SRV_Turret )	; flip is down, turret is active -> ok
			return
		if( flipstate && (!SRV_Turret) )	; flip is up, turret is inactive -> ok
			return
		send H								; send toggle
		return
	}
	if( InMainShip )	; in the ship (and not docked or landed), flip deploys/retracts hardpoints
	{
		if( (!flipstate) && Hardpoints )	; flip is down, hardpoints deployed -> ok
			return
		if( flipstate && (!Hardpoints) )	; flip is up, hardpoints retracted -> ok
			return
		send H								; send toggle
		return
	}
	return
}

; check the status and switch position for cockpit mode and trigger ED if they don't match
checkCombatMode(flipstate)
{
	GetEDStatus()
	if( InSRV || InFighter || InMainShip )	; only do something if we're in the fighter, SRV or main ship
	{
		if( (!flipstate) && (!AnalysisMde) )	; flip is down, we're in combat mode -> ok
			return
		if( flipstate && AnalysisMde )			; flip is up, we're in analysis mode -> ok
			return
		send M									; send toggle
		return
	}
	return
}

;initialize: read out current flags and button states, send commands if they don't match
SetKeyDelay, 10, 20		; ED needs some delay between keys and some tangible duration. So far, these values work on my rig
GetEDStatus()
oldEDFlags := EDFlags
checkHardpoints(GetKeyState("1Joy1"))
checkCombatMode(GetKeyState("2Joy1"))
;MsgBox, % "EDFlags = " . EdFlags
setTimer, WaitForStatusChange, 100			; start monitoring status.json for changes

;now run the loop

; 1joy1 is the flip switch on the right stick -> hardpoints
1Joy1::
	;MsgBox, 1Joy1 up
	checkHardpoints(1)
	setTimer, WaitForHardpointsDn, 20
	return

; 2joy1 is the flip switch on the left stick -> Cockpit mode	
2joy1::
	;MsgBox, 2Joy1 up
	checkCombatMode(1)
	setTimer, WaitForCombatModeDn, 20
	return

; flip is up -> poll status
WaitForHardpointsDn:
	if (GetKeyState("1joy1"))	; trigger still up, do nothing
		return
	; flip trigger is down
	;MsgBox, 1joy1 dn
	checkHardpoints(0)
	setTimer, WaitForHardpointsDn, off
	return
	
; flip is up -> poll status
WaitForCombatModeDn:
	if (GetKeyState("2joy1"))	; trigger still up, do nothing
		return
	; flip trigger is down
	;MsgBox, 2joy1 dn
	checkCombatMode(0)
	setTimer, WaitForCombatModeDn, off
	return

; monitor status.json for change - since we're only checking the flags right now, I use the flags as cnage indicator
; may need to switch to include other indicators if necessary - timestamp only has a one second resolution	
WaitForStatusChange:
	GetEDStatus()
	if( oldEDFlags == EDFlags )
		return						; nothing changed
	checkHardpoints(GetKeyState("1Joy1"))
	checkCombatMode(GetKeyState("2Joy1"))
	oldEDFlags := EDFlags
	return
	
; don't forget this - AHK is otherwise rather clingy
^x::ExitApp	
