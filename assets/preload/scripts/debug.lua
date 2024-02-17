luaDebugMode = true;

function onUpdatePost(elapsed)
	local check = getProperty('startingSong') or getProperty('endingSong')
	if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.ONE') and not check then
		setPropertyFromClass('Conductor', 'songPosition', getPropertyFromClass('Conductor', 'songPosition') - 5000) 
		setPropertyFromClass('flixel.FlxG', 'sound.music.time', getPropertyFromClass('Conductor', 'songPosition'))
		setProperty('vocals.time', getPropertyFromClass('Conductor', 'songPosition'))
		debugPrint("Rewinded 5 seconds.")
	elseif getPropertyFromClass('flixel.FlxG', 'keys.justPressed.TWO') and not check then
		setPropertyFromClass('Conductor', 'songPosition', getPropertyFromClass('Conductor', 'songPosition') + 5000) 
		setPropertyFromClass('flixel.FlxG', 'sound.music.time', getPropertyFromClass('Conductor', 'songPosition'))
		setProperty('vocals.time', getPropertyFromClass('Conductor', 'songPosition'))
		debugPrint("Fast-forwarded 5 seconds.")
	elseif getPropertyFromClass('flixel.FlxG', 'keys.justPressed.THREE') then
		setProperty('songSpeed', getProperty('songSpeed') - 0.1)
		debugPrint("Scroll speed is ", getProperty('songSpeed'), ".")
	elseif getPropertyFromClass('flixel.FlxG', 'keys.justPressed.FOUR') then
		setProperty('songSpeed', getProperty('songSpeed') + 0.1)
		debugPrint("Scroll speed is ", getProperty('songSpeed'), ".")
	elseif getPropertyFromClass('flixel.FlxG', 'keys.justPressed.FIVE') then
		setProperty('defaultCamZoom', getProperty('defaultCamZoom') - 0.1)
		doTweenZoom('c', 'camGame', getProperty('defaultCamZoom'), 0.05, 'linear')
		debugPrint("Zoom is " .. tostring(getProperty("defaultCamZoom")), ".")
	elseif getPropertyFromClass('flixel.FlxG', 'keys.justPressed.SIX') then
		setProperty('defaultCamZoom', getProperty('defaultCamZoom') + 0.1)
		doTweenZoom('c', 'camGame', getProperty('defaultCamZoom'), 0.05, 'linear')
		debugPrint("Zoom is " .. tostring(getProperty("defaultCamZoom")), ".")
	elseif getPropertyFromClass('flixel.FlxG', 'keys.justPressed.NINE') then
		setProperty('cpuControlled', not getProperty('cpuControlled'))
		debugPrint(getProperty('cpuControlled') and "Auto Mode Enabled." or "Auto Mode Disabled.")
	elseif getPropertyFromClass('flixel.FlxG', 'keys.justPressed.F11') then
		if not getPropertyFromClass("openfl.Lib", "application.window.fullscreen") then
			setPropertyFromClass("openfl.Lib", "application.window.fullscreen", true)
		else
			setPropertyFromClass("openfl.Lib", "application.window.fullscreen", false)
		end
	end
end

function onPause()
	setPropertyFromClass("PlayState", "chartingMode", true)
	return Function_Continue
end

function onDestroy()
	setPropertyFromClass("PlayState", "chartingMode", false)
end