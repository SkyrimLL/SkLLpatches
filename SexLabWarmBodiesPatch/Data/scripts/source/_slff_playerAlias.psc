Scriptname _slff_playerAlias extends ReferenceAlias  

import FrostUtil
SexLabFramework property SexLab                 auto
GlobalVariable Property _baseRate  Auto  

Bool bFrostFallInit = false
Actor kPlayer
Actor kMaster
ObjectReference kPlayerStorageRef = None
ObjectReference kPlayerRef = None
Float frostfallColdLimit = 70.0 ; Too cold to be comfortable

GlobalVariable  property exposurePoints = none  auto hidden
float           property exposureDelta = 0.0    auto hidden
float           property exposureMax = 120.0    autoreadonly
float           property exposureAdjust = -2.0  autoreadonly

Spell Property _heal  Auto
float playersHealth 
float fMasterDistance


Float fRFSU = 0.1
int iGameDateLastCheck
int daysSinceEnslavement
int iDaysSinceLastCheck = -1
int iDaysPassed


Event OnInit()
	; 0.0 - 19.9 = Warm
	; 20.0 - 39.9 = Comfortable
	; 40.0 - 59.9 = Cold
	; 60.0 - 79.9 = Very Cold
	; 80.0 - 99.9 = Freezing
	; 100.0 - 120.0 = Freezing to Death
 
	maintenance()

    RegisterForSingleUpdate( fRFSU * 5 ) ;performance

EndEvent


event OnPlayerLoadGame()
	exposurePoints = none
	kPlayer        = Game.GetPlayer() as Actor
	kPlayerRef = Game.GetPlayer() 
	kPlayerStorageRef = StorageUtil.GetFormValue( kPlayerRef, "_SD_iSanguinePlayerStorage") as ObjectReference

	maintenance()
 
    RegisterForSingleUpdate( fRFSU * 2 ) ;performance

endEvent


function maintenance()
	If (FrostUtil.GetAPIVersion() > 0) && !bFrostFallInit
		; exposurePoints.SetValue( FrostUtil.GetPlayerExposure() )
		bFrostFallInit = true
		Debug.Notification("[SLFF] Frostfall 3.0 update detected" )
		Debug.Trace("[SLFF] FrostFall exposure points found")
	elseIf bFrostFallInit
		Debug.Trace("[SLFF] FrostFall already initialized")
	else
		Debug.Trace("[SLFF] FrostFall exposure points NOT found")
	Endif

	RegisterForModEvent("AnimationEnd",   "OnSexLabEnd")
	RegisterForModEvent("StageStart", "stageStart")

	RegisterForModEvent("SLFFModExposure", "OnSLFFModExposure")
endFunction

event OnSLFFModExposure(String _eventName, String _args, Float _argc = 1.0, Form _sender)
 	Actor kActor = _sender as Actor
 	Actor PlayerActor = Game.GetPlayer()

 	If (kActor == None)
 		kActor = PlayerActor
 	Endif

	if bFrostFallInit && (StorageUtil.GetFloatValue(kActor, "_SLH_fHormoneSexDrive") >= 20)
 	    updateExposure()

		debugTrace("[SLFF] Receiving event 'Mod exposure'")
		if (_args != "") 
			debug.notification(_args)
		endIf
		FrostUtil.ModPlayerExposure(  (-1.0 * _argc * _baseRate.GetValue()) * 0.1  )

	endIf
endEvent

;how much gold hypnosis victim earns each day
Event OnLocationChange(Location akOldLoc, Location akNewLoc)
	float _SLH_fHormonePigmentationToken = StorageUtil.GetFloatValue(kPlayer, "_SLH_fHormonePigmentationToken") 
	kPlayerRef = Game.GetPlayer() 
	kPlayer        = kPlayerRef as Actor
	; Debug.Notification("[SLFF] Changing location - Exposure: " + FrostUtil.GetPlayerExposure())

	updateExposure()

	; Base bonus for changing location
	if (FrostUtil.GetPlayerExposure() >= (frostfallColdLimit / 4))
		FrostUtil.ModPlayerExposure( -0.2 * _baseRate.GetValue() )
	endIf

	if kPlayerRef.IsInInterior()
		StorageUtil.SetFloatValue(kPlayer, "_SLH_fHormonePigmentationToken", _SLH_fHormonePigmentationToken - 0.1)
	else
		StorageUtil.SetFloatValue(kPlayer, "_SLH_fHormonePigmentationToken", _SLH_fHormonePigmentationToken + 0.1)
	endif

	debugTrace("[SLFF] Changing location - _SLH_fHormonePigmentationToken: " + StorageUtil.GetFloatValue(kPlayer, "_SLH_fHormonePigmentationToken")) 
endEvent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)

	If (akAggressor != None) && bFrostFallInit && (FrostUtil.GetPlayerExposure() >= frostfallColdLimit)
		; exposureDelta = exposureMax - FrostUtil.GetPlayerExposure()

		; exposurePoints.Mod( minFloat( 1.0, exposureDelta) )
		debugTrace("[SLFF] Heat from combat " + FrostUtil.GetPlayerExposure())
		FrostUtil.ModPlayerExposure( _baseRate.GetValue() )

	EndIf

	If (akAggressor != None) 
		float _SLH_fHormoneMetabolismToken = StorageUtil.GetFloatValue(kPlayer, "_SLH_fHormoneMetabolismToken") 
		StorageUtil.SetFloatValue(kPlayer, "_SLH_fHormoneMetabolismToken", _SLH_fHormoneMetabolismToken + 0.1)
		debugTrace("[SLFF] Metabolism from combat - _SLH_fHormoneMetabolismToken: " + StorageUtil.GetFloatValue(kPlayer, "_SLH_fHormoneMetabolismToken")) 	
	EndIf
EndEvent

event stageStart(string eventName, string argString, float argNum, form sender)
	if bFrostFallInit && SexLab.HookActors(argString).Find(kPlayer) >= 0
 	    updateExposure()

		if (FrostUtil.GetPlayerExposure() >= (frostfallColdLimit/2)) && (FrostUtil.GetCurrentTemperature() < 10) ; it's cold
			; exposurePoints.Mod( minFloat(exposureAdjust, exposureDelta) ) 
			debugTrace("[SLFF] Heat from sex - cold temp " + FrostUtil.GetPlayerExposure())
			FrostUtil.ModPlayerExposure( exposureAdjust * _baseRate.GetValue() )

		elseif (FrostUtil.GetPlayerExposure() >= (frostfallColdLimit / 2) )
			debugTrace("[SLFF] Heat from sex - warm temp "  + FrostUtil.GetPlayerExposure())
			FrostUtil.ModPlayerExposure( exposureAdjust * _baseRate.GetValue() )
		endIf
	endIf
endEvent

event OnSexLabEnd(string eventName, string argString, float argNum, form sender)
	if bFrostFallInit && SexLab.HookActors(argString).Find(kPlayer) >= 0
   		updateExposure()

		if (FrostUtil.GetPlayerExposure() >= (frostfallColdLimit/2)) && (FrostUtil.GetCurrentTemperature() < 10) ; it's cold
			; exposurePoints.Mod( minFloat(exposureAdjust, exposureDelta) ) 
			debugTrace("[SLFF] Heat from sex end - cold temp "  + FrostUtil.GetPlayerExposure())
			FrostUtil.ModPlayerExposure( (exposureAdjust  * _baseRate.GetValue() )/ 2 )

		elseif (FrostUtil.GetPlayerExposure() >= (frostfallColdLimit / 2) )
			debugTrace("[SLFF] Heat from sex end - warm temp " + FrostUtil.GetPlayerExposure())
			FrostUtil.ModPlayerExposure( (exposureAdjust  * _baseRate.GetValue()) / 2 )
		endIf
	endIf
endEvent


Event OnUpdate()
	Int iExposureMod = 1 

    iDaysPassed = Game.QueryStat("Days Passed")


    ; StorageUtil.SetIntValue(BimboActor, "_SLH_bimboTransformGameDays", iDaysPassed - (StorageUtil.GetIntValue(BimboActor, "_SLH_bimboTransformDate") as Int ))    
    ; daysSinceEnslavement = StorageUtil.GetIntValue(BimboActor, "_SLH_bimboTransformGameDays")


    if (iGameDateLastCheck == -1)
        iGameDateLastCheck = iDaysPassed
    EndIf

    iDaysSinceLastCheck = (iDaysPassed - iGameDateLastCheck ) as Int
       
    updateExposure()

	if (StorageUtil.GetIntValue(kPlayer, "_SD_iEnslaved") == 1)
		kMaster = StorageUtil.GetFormValue(kPlayer, "_SD_CurrentOwner") as Actor
		fMasterDistance = kPlayer.GetDistance( kMaster )

		if (fMasterDistance < 150) && (FrostUtil.GetPlayerExposure() >= 40 ) ; Cold and close to master
			FrostUtil.ModPlayerExposure( -5.0 * _baseRate.GetValue() )
			; Debug.Notification("[SLFF]  Master warmth: " + FrostUtil.GetPlayerExposure() )

		elseif (fMasterDistance < 80) && (FrostUtil.GetPlayerExposure() >= 40 ) ; Cold and very close to master
			FrostUtil.ModPlayerExposure( -10.0 * _baseRate.GetValue() )
			; Debug.Notification("[SLFF]  Master heat: " + FrostUtil.GetPlayerExposure() )

		endIf
	endif

	If (StorageUtil.GetIntValue( kPlayer, "_SD_iFrostfallMortality")==1)
		If (FrostUtil.GetPlayerExposure() >= 100 )
		;	Game.GetPlayer().EndDeferredKill()

			If (StorageUtil.GetIntValue( kPlayer, "_SD_iSanguineBlessings") >= 1) && (kPlayerRef.GetParentCell() != kPlayerStorageRef.GetParentCell())

				debugTrace("[SD] Frostfall: Sending SD Dreamworld event " )
				Debug.MessageBox("You collapse after nearly freezing to death and wake up back into Sanguine's lap." )
				SendModEvent("SDDreamworldPull")

			EndIf
		ElseIf (FrostUtil.GetPlayerExposure() >= 80 ) && (Utility.RandomInt(0,100)>90)
			Debug.Notification("You are numb from the cold." )

		Else
		;	Game.GetPlayer().StartDeferredKill()
		EndIf

	EndIf

    ; SD+/Spriggan integration
    If (StorageUtil.GetIntValue(kPlayer, "_SD_iSprigganInfected")==1)
		FrostUtil.ModPlayerExposure( exposureAdjust * 2, 10 )
		playersHealth = kPlayer.GetActorValuePercentage("health")
		if ((playersHealth < 0.8) && (FrostUtil.GetPlayerWetnessLevel()>=1))
		  	; debugTrace("The player has over half their health left")
			_heal.RemoteCast(kPlayer, kPlayer, kPlayer)
		endIf
	endif

	; Parasites integration 
    If ( (StorageUtil.GetIntValue(kPlayer, "_SLP_toggleLivingArmor")==1) || (StorageUtil.GetIntValue(kPlayer, "_SLP_toggleTentacleMonster")==1) )
		FrostUtil.ModPlayerExposure( exposureAdjust * 2, 10 )
		playersHealth = kPlayer.GetActorValuePercentage("health")
		if ((playersHealth < 0.8) && (FrostUtil.GetPlayerWetnessLevel()>=1))
		  	; debugTrace("The player has over half their health left")
			_heal.RemoteCast(kPlayer, kPlayer, kPlayer)
		endIf
	endif

			
    ; Hormones Succubus/Bimbo integration
    If (StorageUtil.GetIntValue(kPlayer, "_SLH_iSuccubus")==1) 
		FrostUtil.ModPlayerExposure( (exposureAdjust * 2) , StorageUtil.GetFloatValue(kPlayer, "_SLH_fHormoneSuccubus") as Int )
	endif

    If (StorageUtil.GetIntValue(kPlayer, "_SLH_iBimbo")==1) 
		FrostUtil.ModPlayerExposure( (exposureAdjust ) , (StorageUtil.GetFloatValue(kPlayer, "_SLH_fHormoneSexDrive") as Int) / 4 )
	endif

    ; SexLab Stories integration
    If (StorageUtil.GetIntValue(none, "_SLS_iPlayerStartNordQueen")==1)

		If (StorageUtil.GetIntValue(kPlayer, "_SLSL_iNordQueenPolymorphStage")<=3)
			FrostUtil.ModPlayerExposure( (exposureAdjust * _baseRate.GetValue()) * 10 )
		endIf

    ElseIf (StorageUtil.GetIntValue(none, "_SLS_iPlayerStartSexbot")==1)

		FrostUtil.ModPlayerExposure( (exposureAdjust * _baseRate.GetValue()) * 10 )

	endif


    ;RegisterForSingleUpdate( fRFSU )
    RegisterForSingleUpdate( fRFSU * 30 ) ;performance
	;debugTrace("[slh+] bimbo OnUpdate, Done")
EndEvent


function updateExposure()
	; Hormones compatibility - High metabolism = Better cold resistance
	float _SLH_fHormoneMetabolismToken = StorageUtil.GetFloatValue(kPlayer, "_SLH_fHormoneMetabolismToken") 
	float fMetabolismRate = 0.1 + (StorageUtil.GetFloatValue(kPlayer, "_SLH_fHormoneMetabolism") / 100.0)

	If (FrostUtil.GetAPIVersion() > 0) && !bFrostFallInit
		; exposurePoints.SetValue( FrostUtil.GetPlayerExposure() )
		Debug.Notification("[SLFF] Frostfall 3.0 update detected" )
		bFrostFallInit = true
	endIf

	If (  !StorageUtil.HasFloatValue(kPlayer, "_SLFF_fBaseRate" )  )
		StorageUtil.SetFloatValue(kPlayer, "_SLFF_fBaseRate",  _baseRate.GetValue() )
	Endif


	If (  StorageUtil.GetFloatValue(kPlayer, "_SLFF_fBaseRate" ) != _baseRate.GetValue() )
		_baseRate.SetValue(StorageUtil.GetFloatValue(kPlayer, "_SLFF_fBaseRate" ))
	Endif

	if bFrostFallInit && (FrostUtil.GetPlayerExposure() >= frostfallColdLimit)
	    debugTrace("[SLFF] Checkpoint - Exposure: " + FrostUtil.GetPlayerExposure())

		if (kPlayer.IsOnMount())
			debugTrace("[SLFF] Heat from horse "+ FrostUtil.GetPlayerExposure())
			; exposureDelta = exposureMax - FrostUtil.GetPlayerExposure()

			; exposurePoints.Mod( minFloat(exposureAdjust + 5.0, exposureDelta) )
			FrostUtil.ModPlayerExposure( (exposureAdjust * _baseRate.GetValue()) - 5.0  )

		elseif (kPlayer.IsSprinting() )
			debugTrace("[SLFF] Heat from sprinting "+ FrostUtil.GetPlayerExposure()) 

			; exposurePoints.Mod( minFloat(exposureAdjust, exposureDelta) )
			FrostUtil.ModPlayerExposure( (-1.0 * _baseRate.GetValue()) * (fMetabolismRate * 2.0) )	

		elseif (kPlayer.IsRunning() )
			debugTrace("[SLFF] Heat from running "+ FrostUtil.GetPlayerExposure()) 

			; exposurePoints.Mod( minFloat(exposureAdjust / 2.0, exposureDelta) )
			FrostUtil.ModPlayerExposure(  (-1.0 * _baseRate.GetValue()) * fMetabolismRate  )

		else 
			; debugTrace("[SLFF] Heat from idle") 

			; exposurePoints.Mod( minFloat(1.0, exposureDelta) )
			FrostUtil.ModPlayerExposure(  (-1.0 * _baseRate.GetValue()) * (fMetabolismRate / 2.0) )
			; FrostUtil.ModPlayerExposure( -1.0  )

		endif
	endIf

	if (kPlayer.IsSprinting() )
		StorageUtil.SetFloatValue(kPlayer, "_SLH_fHormoneMetabolismToken", _SLH_fHormoneMetabolismToken + 0.2)
		debugTrace("[SLFF] Metabolism from sprinting - _SLH_fHormoneMetabolismToken: " + StorageUtil.GetFloatValue(kPlayer, "_SLH_fHormoneMetabolismToken")) 	

	elseif (kPlayer.IsRunning() )
		StorageUtil.SetFloatValue(kPlayer, "_SLH_fHormoneMetabolismToken", _SLH_fHormoneMetabolismToken + 0.1)
		debugTrace("[SLFF] Metabolism from running - _SLH_fHormoneMetabolismToken: " + StorageUtil.GetFloatValue(kPlayer, "_SLH_fHormoneMetabolismToken")) 	
	endif

endfunction

float function minFloat(float afA, float afB)
	if afA < afB
		return afA
	else
		return afB
	endIf
endFunction


Function debugTrace(string traceMsg)
	; if (StorageUtil.GetIntValue(none, "_SLH_debugTraceON")==1)
		; Debug.Trace("[SLFF]" + traceMsg)
	; endif
endFunction
