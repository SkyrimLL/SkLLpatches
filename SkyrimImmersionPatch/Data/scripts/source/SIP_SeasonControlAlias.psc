Scriptname SIP_SeasonControlAlias extends ReferenceAlias  

SIP_fctSeasons Property fctSeasons Auto

GlobalVariable Property GV_DaysInYear Auto

Int iGameDateLastCheck = -1
Int iDaysSinceLastCheck
Int iDaysPassed
Int iDaysCount  
Int iYearCycle 
Int iSeason

Event OnInit()

	GV_DaysInYear.SetValue(365)

	_maintenance()

EndEvent

Event OnPlayerLoadGame()

	_maintenance()

EndEvent

Function _maintenance()

	UnregisterForAllModEvents()
	Debug.Trace("SkyrimImmersionPatch Seasonal Weather: Reset events")
 
 	RegisterForModEvent("SIPSetDaysInYear",   "OnSetDaysInYearEvent")
 	RegisterForModEvent("SIPSetDaysCount",   "OnSetDaysCountEvent") 

	RegisterForSleep()

EndFunction


Event OnSetDaysInYearEvent(String _eventName, String _args, Float _argc = 1.0, Form _sender)
 	Actor kActor = _sender as Actor
 
 	GV_DaysInYear.SetValue(_argc as Int)

 	Debug.Trace("[SIP] Received OnSetDaysInYearEvent - Set iDaysInYear to " + _argc as Int) 
endEvent

Event OnSetDaysCountEvent(String _eventName, String _args, Float _argc = 1.0, Form _sender)
 	Actor kActor = _sender as Actor
 
 	iDaysCount = _argc as Int

 	Debug.Trace("[SIP] Received OnSetDaysInYearEvent - Set iDaysCount to " + _argc as Int) 
endEvent 

Event OnSleepStart(float afSleepStartTime, float afDesiredSleepEndTime)
	Int iDaysInYear = GV_DaysInYear.GetValue() as Int
 
 	iDaysPassed = Game.QueryStat("Days Passed") 

 	; Initial values
 	if (iGameDateLastCheck == -1)
 		iGameDateLastCheck = iDaysPassed 
 		iDaysCount = 0 
 	endIf 
 
	iDaysSinceLastCheck = (iDaysPassed - iGameDateLastCheck ) as Int

	if (iDaysSinceLastCheck>0)
		; celebrate only once a day
		iDaysCount = iDaysCount + iDaysSinceLastCheck 
 
		iYearCycle = (iDaysCount % iDaysInYear)
	 
		if (iYearCycle == 0) 
	 		iDaysCount = 0 
 
		EndIf
	Endif

	iGameDateLastCheck = iDaysPassed  

	Debug.Trace("[SIP] iDaysCount = " + iDaysCount)
	Debug.Trace("[SIP] iDaysInYear = " + iDaysInYear) 
EndEvent

Event OnLocationChange(Location akOldLoc, Location akNewLoc)
	Actor PlayerActor = Game.GetPlayer() as Actor
	Int iDaysInSeason
	Int iDaysInSeasonTotal
	Int iPercentSeason
	Int iChanceWeatherOverride
	Int iDaysInYear = GV_DaysInYear.GetValue() as Int
 
	iDaysInSeasonTotal = (iDaysInYear / 4)
	iSeason = iDaysCount / iDaysInSeasonTotal
	iDaysInSeason = ( iDaysCount % iDaysInSeasonTotal)

	iPercentSeason = ( iDaysInSeason * 100) /  iDaysInSeasonTotal 

	iChanceWeatherOverride = (100 - ( 2 * Math.abs(50 - iPercentSeason))) as Int

	; cap the chance of weather override to prevent changing weather at every cell location change
	iChanceWeatherOverride = ( (iChanceWeatherOverride * 80) / 100 )

	if (iChanceWeatherOverride<10)
		iChanceWeatherOverride = 10
	endif
 
	;/ 		
	debug.notification("[SIP] iDaysInYear: " + iDaysInYear)
	debug.notification("[SIP] iSeason: " + iSeason)
	debug.notification("[SIP] iPercentSeason: " + iPercentSeason)
	debug.notification("[SIP] iChanceWeatherOverride: " + iChanceWeatherOverride)
	/;
	debug.trace("[SIP] iDaysInYear: " + iDaysInYear)
	debug.trace("[SIP] iSeason: " + iSeason)
	debug.trace("[SIP] iDaysInSeasonTotal: " + iDaysInSeasonTotal)
	debug.trace("[SIP] iDaysCount: " + iDaysCount)
	debug.trace("[SIP] iDaysInSeason: " + iDaysInSeason)
	debug.trace("[SIP] iPercentSeason: " + iPercentSeason)
	debug.trace("[SIP] iChanceWeatherOverride: " + iChanceWeatherOverride)


  	if (Utility.RandomInt(0,100)<iChanceWeatherOverride)
  		fctSeasons.updateWeather(iSeason, iPercentSeason)
  	endif
 
endEvent

float function fMin(float  a, float b)
	if (a<=b)
		return a
	else
		return b
	EndIf
EndFunction

float function fMax(float a, float b)
	if (a<b)
		return b
	else
		return a
	EndIf
EndFunction