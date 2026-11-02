-- Move UI run clock
-- Azeroth Survivors run timer / next-boss display and native HUD visibility lifecycle.
-- Extracted from the tested 1.2.9 runtime; behavior intentionally preserved.

-- Azeroth Survivors run timer / next-boss countdown.
-- The game API exposes the timing data but not a movable native frame.
-- This addon-owned frame recreates that HUD readout so Move UI can move,
-- scale, hide, save, and reset it through the normal managed-frame system.
local function MoveUI_RunClockGetNativeShown()
	if ( AZS_IsHudShown ) then
		local ok, value = pcall( AZS_IsHudShown, "clock" );
		if ( ok ) then
			if ( value == true or value == 1 or value == "1" ) then return true; end
			if ( value == false or value == 0 or value == "0" ) then return false; end
		end
	end
	if ( GetCVar ) then
		local ok, value = pcall( GetCVar, "hudClock" );
		if ( ok and value == "1" ) then return true; end
		if ( ok and value == "0" ) then return false; end
	end
	return nil;
end

local function MoveUI_RunClockSetNativeShown( value )
	local shown = value and true or false;
	if ( AZS_SetHudShown ) then
		local ok = pcall( AZS_SetHudShown, "clock", shown );
		if ( ok ) then return true; end
	end
	if ( SetCVar ) then
		local cvarValue = "0";
		if ( shown ) then cvarValue = "1"; end
		local ok = pcall( SetCVar, "hudClock", cvarValue );
		if ( ok ) then return true; end
	end
	return false;
end

local MoveUI_RunClockOriginalNativeShown = nil;
local MoveUI_RunClockNativeOverrideActive = false;
local MoveUI_RunClockWarningShown = false;

local function MoveUI_RunClockSuppressNative()
	if ( not MoveUI_RunClockNativeOverrideActive ) then
		local original = MoveUI_RunClockGetNativeShown();
		if ( original == nil ) then
			-- The documented getter should provide the preference. If it is
			-- missing in a client build, assume the normal visible default.
			original = true;
		end
		MoveUI_RunClockOriginalNativeShown = original;
	end

	if ( MoveUI_RunClockSetNativeShown( false ) ) then
		MoveUI_RunClockNativeOverrideActive = true;
	elseif ( not MoveUI_RunClockWarningShown ) then
		MoveUI_RunClockWarningShown = true;
		Print( "Move UI: could not hide the game's run clock; the HUD API is unavailable." );
	end
end

local function MoveUI_RunClockRestoreNative()
	if ( not MoveUI_RunClockNativeOverrideActive ) then return; end

	local original = MoveUI_RunClockOriginalNativeShown;
	if ( original == nil ) then original = true; end
	if ( MoveUI_RunClockSetNativeShown( original ) ) then
		MoveUI_RunClockNativeOverrideActive = false;
		MoveUI_RunClockOriginalNativeShown = nil;
	end
end

local function MoveUI_RunClockFormat(seconds)
	seconds = tonumber( seconds ) or 0;
	if ( seconds < 0 ) then seconds = 0; end
	seconds = math.floor( seconds );

	local hours = math.floor( seconds / 3600 );
	local minutes = math.floor( math.mod( seconds, 3600 ) / 60 );
	local secs = math.mod( seconds, 60 );

	if ( hours > 0 ) then
		return string.format( "%d:%02d:%02d", hours, minutes, secs );
	end
	return string.format( "%02d:%02d", minutes, secs );
end

local function MoveUI_RunClockUpdate(runText, bossText)
	local phase = nil;
	if ( AZS_GetPhase ) then
		local ok, value = pcall( AZS_GetPhase );
		if ( ok ) then phase = value; end
	end

	local runTime = nil;
	if ( AZS_GetRunTime ) then
		local ok, value = pcall( AZS_GetRunTime );
		if ( ok and type( value ) == "number" ) then runTime = value; end
	end

	if ( runTime == nil ) then
		runText:SetText( "00:00" );
		if ( phase == "ready" or phase == nil ) then
			bossText:SetText( "Waiting for run" );
		else
			bossText:SetText( "Run timer unavailable" );
		end
		return;
	end

	runText:SetText( MoveUI_RunClockFormat( runTime ) );

	if ( phase == "dead" ) then
		bossText:SetText( "Run ended" );
		return;
	elseif ( phase == "victory" ) then
		bossText:SetText( "Run complete" );
		return;
	end

	local nextBoss = nil;
	if ( AZS_GetUpcomingBosses ) then
		local ok, bosses = pcall( AZS_GetUpcomingBosses );
		if ( ok and type( bosses ) == "table" ) then
			nextBoss = bosses[1];
		end
	end

	if ( nextBoss ) then
		local bossName = nextBoss.name or "Boss";
		local left = nextBoss.left or 0;
		bossText:SetText( "Next boss: " .. bossName .. " in " .. MoveUI_RunClockFormat( left ) );
	else
		bossText:SetText( "No upcoming boss" );
	end
end

function MoveAnything_CreateRunClock()
	if ( MoveUIRunClockFrame ) then return; end


	local frame = CreateFrame( "Frame", "MoveUIRunClockFrame", UIParent );
	frame:SetWidth( 220 );
	frame:SetHeight( 46 );
	frame:SetPoint( "TOP", UIParent, "TOP", 0, -80 );
	frame:SetFrameStrata( "MEDIUM" );
	frame:SetClampedToScreen( true );
	frame:EnableMouse( false );

	local runText = frame:CreateFontString( nil, "OVERLAY", "GameFontNormalLarge" );
	runText:SetPoint( "TOP", frame, "TOP", 0, -1 );
	runText:SetTextColor( 1.0, 0.82, 0.25 );
	runText:SetText( "00:00" );

	local bossText = frame:CreateFontString( nil, "OVERLAY", "GameFontNormalSmall" );
	bossText:SetPoint( "TOP", runText, "BOTTOM", 0, -3 );
	bossText:SetTextColor( 1.0, 1.0, 1.0 );
	bossText:SetText( "Waiting for run" );

	-- Hiding this managed frame restores the game's native run-clock HUD.
	-- Showing it suppresses the native HUD again. This makes Move UI's normal
	-- Hide checkbox behave exactly like other managed components.
	frame:Hide();
	frame:SetScript( "OnShow", function()
		MoveUI_RunClockSuppressNative();
	end );
	frame:SetScript( "OnHide", function()
		MoveUI_RunClockRestoreNative();
	end );

	local updateElapsed = 0;
	frame:SetScript( "OnUpdate", function()
		updateElapsed = updateElapsed + ( arg1 or 0 );
		if ( updateElapsed < 0.2 ) then return; end
		updateElapsed = 0;
		MoveUI_RunClockUpdate( runText, bossText );
	end );

	frame:Show();

	-- Keep logout recovery independent of the managed frame's visibility.
	if ( not MoveUIRunClockLifecycleFrame ) then
		local lifecycle = CreateFrame( "Frame", "MoveUIRunClockLifecycleFrame", UIParent );
		lifecycle:RegisterEvent( "PLAYER_LOGOUT" );
		lifecycle:SetScript( "OnEvent", function()
			if ( event == "PLAYER_LOGOUT" ) then
				MoveUI_RunClockRestoreNative();
			end
		end );
	end

	MoveUI_RunClockUpdate( runText, bossText );
end
