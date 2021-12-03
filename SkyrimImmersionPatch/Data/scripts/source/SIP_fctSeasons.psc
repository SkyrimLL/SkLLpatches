Scriptname SIP_fctSeasons extends Quest  

; Spring - MA - Marsh
Weather Property SpringOvercast Auto 	; SkyrimCloudy
Weather Property SpringHeavyRain Auto 	; SkyrimStormRain
Weather Property SpringLightRain Auto 	; SkyrimOvercastRain
Weather Property SpringShowers Auto 	; SkyrimOvercastRainMA
Weather Property SpringCloudy Auto 		; SkyrimCloudyMA

; Summer - TU - Tundra
Weather Property SummerOvercast Auto 	; SkyrimCloudy
Weather Property SummerCloudy Auto 		; SkyrimCloudyTU
Weather Property SummerSun Auto 		; SkyrimClear

; Fall - FF - Fall Forest
Weather Property FallOvercast Auto 		; SkyrimCloudy
Weather Property FallHeavyRain Auto 	; SkyrimStormRain
Weather Property FallLightRain Auto 	; SkyrimOvercastRain
Weather Property FallHeavyFog Auto 		; SkyrimFogMA
Weather Property FallCloudy Auto 		; SkyrimCloudyFF

; Winter - SN -Snow
Weather Property WinterOvercast Auto 	; SkyrimCloudy
Weather Property WinterSnowStorm Auto 	; SkyrimStormSnow
Weather Property WinterSnowFall Auto 	; SkyrimOvercastSnow
Weather Property WinterFog Auto 		; RiftenOvercastFog
Weather Property WinterCloudy Auto 		; SkyrimOvercastSnow

;/
:: For each season, pick a preferred weather type and add a chance of transition to that weather with OnLocationChange
Spring -  LightRain / HeavyRain / Cloudy
Summer -  TundraSun
Fall - HeavyFog / LightRain / HeavyRain / Cloudy
Winter - SnowFall / SnowStorm / Fog
https://www.creationkit.com/index.php?search=weather&title=Special%3ASearch&fulltext=Search

Reference - https://girlplaysgame.com/2015/08/12/skyrim-ultimate-weather-guide-and-console-commands/
/;

Function updateWeather(Int iSeason, Int iPercentSeason)
	Int iRandomNum = utility.RandomInt(0,100)
	; Weather currentWeather = Weather.GetCurrentWeather()

	if (iSeason == 0)
		; Spring -  LightRain / HeavyRain / Cloudy
		if (iRandomNum>60) && ( (iPercentSeason<=25) || (iPercentSeason>=75))
			debug.notification("(Spring Overcast)")
			SpringOvercast.SetActive(true)
		elseif (iRandomNum>80)
			debug.notification("(Spring Heavy Rain)")
			SpringHeavyRain.SetActive(true)
		elseif (iRandomNum>60)
			debug.notification("(Spring Light Rain)")
			SpringLightRain.SetActive(true)
		elseif (iRandomNum>40)
			debug.notification("(Spring Showers)")
			SpringShowers.SetActive(true)
		else
			debug.notification("(Spring Cloudy)")
			SpringCloudy.SetActive(true)
		endif

	elseif (iSeason == 1)
		; Summer -  TundraSun
		if (iRandomNum>60) && ( (iPercentSeason<=25) || (iPercentSeason>=75))
			debug.notification("(Summer Overcast)")
			SummerOvercast.SetActive(true)
		elseif (iRandomNum>70)
			debug.notification("(Summer Cloudy)")
			SummerCloudy.SetActive(true)
		else
			debug.notification("(Summer Sunny)")
			SummerSun.SetActive(true)
		endif

	elseif (iSeason == 2)
		; Fall - HeavyFog / LightRain / HeavyRain / Cloudy
		if (iRandomNum>60) && ( (iPercentSeason<=25) || (iPercentSeason>=75))
			debug.notification("(Fall Overcast)")
			FallOvercast.SetActive(true)
		elseif (iRandomNum>80)
			debug.notification("(Fall Heavy Rain)")
			FallHeavyRain.SetActive(true)
		elseif (iRandomNum>60)
			debug.notification("(Fall Light Rain)")
			FallLightRain.SetActive(true)
		elseif (iRandomNum>40)
			debug.notification("(Fall Heavy Fog)")
			FallHeavyFog.SetActive(true)
		else
			debug.notification("(Fall Cloudy)")
			FallCloudy.SetActive(true)
		endif

	elseif (iSeason == 3)
		; Winter - SnowFall / SnowStorm / Fog
		if (iRandomNum>60) && ( (iPercentSeason<=25) || (iPercentSeason>=75))
			debug.notification("(Winter Overcast)")
			WinterOvercast.SetActive(true)
		elseif (iRandomNum>80)
			debug.notification("(Winter Snow Storm)")
			WinterSnowStorm.SetActive(true)
		elseif (iRandomNum>60)
			debug.notification("(Winter Snow Fall)")
			WinterSnowFall.SetActive(true)
		elseif (iRandomNum>20)
			debug.notification("(Winter Fog)")
			WinterFog.SetActive(true)
		else
			debug.notification("(Winter Cloudy)")
			WinterCloudy.SetActive(true)
		endif
	endif

	; BadWeather.SetActive(true)

EndFunction