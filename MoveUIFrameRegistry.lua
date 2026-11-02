-- Move UI frame registry and hooking
-- Frame discovery, saved settings, registration, and external movement/visibility protection.
-- Extracted from the tested 1.2.9 runtime; behavior intentionally preserved.

function MoveAnything_AddPredefinedFrames( frameList )
	for i, val in frameList do
		if( val[1] ) then
			if( val[1] == "Separator" ) then
				MoveAnything_AddSeparator( val[2], true );
			else
				MoveAnything_AddFrameToMovableList( val[1], val[2], true );
			end
		end
	end
end

function MoveAnything_AddDefaultFrames()
	MoveAnything_AddPredefinedFrames( MoveAnything_DefaultFrameList );
	MoveAnything_AddPredefinedFrames( MoveAnything_PredefinedCustomFrameList );
end

function MoveAnything_ScaleAllowed( frameName )
	if( MoveAnything_NoScale[ frameName ] or MoveAnything_ScaleWH[ frameName ] ) then
		return false;
	end
	return true;
end

function MAGetParent( frame )
	if ( not frame or not frame.GetParent ) then return; end
	if( frame:GetParent() == nil ) then
		return UIParent;
	end

	return frame:GetParent();
end

-- The end caps' visible layout is relative to MainMenuBar even though
-- GetParent() may report UIParent. Keep capture, mover, saved position and
-- reset calculations on this same reference to preserve the native layout.
function MoveAnything_GetPositionParent( frame )
	if ( frame and frame.GetName ) then
		local name = frame:GetName();
		if ( name == "MainMenuBarLeftEndCap" or name == "MainMenuBarRightEndCap" ) then
			return MainMenuBar;
		end
		-- LocalClock lives under UIParent so it can be shown independently
		-- while MinimapCluster is hidden, but its saved/moved position is
		-- always expressed relative to the minimap assembly.
		if ( name == "LocalClockDisplayFrame" and MinimapCluster ) then
			return MinimapCluster;
		end
	end
	return MAGetParent( frame );
end

function MAGetScale( frame, effective )
	-- Some Azeroth Survivors UI objects are not full WoW Frames and do not
	-- expose GetScale/GetEffectiveScale. Treat those as normal UI scale.
	if ( not frame or not frame.GetScale ) then
		return 1;
	end

	local scale = frame:GetScale();
	if ( scale == nil ) then
		scale = 1;
	end

	if ( effective ) then
		if ( frame.GetEffectiveScale ) then
			local effectiveScale = frame:GetEffectiveScale();
			if ( effectiveScale ~= nil ) then
				return effectiveScale;
			end
		end
	end
	return scale;
end

function MoveAnything_RefreshPositions()
	if( not MoveAnything_InitRun ) then
		return;
	end

	local frame, parent;
	for i, opt in MoveAnything_FrameOptions do
		frame = getglobal( opt.name );
		if( frame ) then
			if( opt.movable or opt.hidden ) then
				MoveAnything_HookFrame( opt.name );
			end
			if( opt.movable ) then
				if( MoveAnything_DetachFromParent[ opt.name ] ) then
					parent = UIParent;
				else
					parent = MoveAnything_GetPositionParent( frame );
				end
				frame:HiddenClearAllPoints();
				frame:HiddenSetPoint( "BOTTOMLEFT", parent:GetName(), "BOTTOMLEFT", opt.x, opt.y );
				if( opt.scale ) then
					local savedScale = opt.scale;
					if ( opt.name == "LocalClockDisplayFrame" ) then
						savedScale = savedScale * ( frame.LocalClockMinimapScale or 1 );
					end
					frame:HiddenSetScale( savedScale );
					if( frame.attachedChildren ) then
						for i, v in frame.attachedChildren do
							v:HiddenSetScale( opt.scale );
						end
					end
				end
			end
			if( opt.hidden ) then
				MoveAnything_HideFrame( frame );
			end
		end
	end
end

function MoveAnything_CurrentSettingsName()
	local settingname = "default";

	if( MoveAnything_UseCharacterSettings ) then
		settingname = GetCVar( "realmName" ).." "..UnitName( "player" );
	end

	return settingname;
end

function MoveAnything_CopySettings( fromName, toName )
	if( MoveAnything_CharacterSettings[toName] == nil ) then
		MoveAnything_CharacterSettings[toName] = {};
	end
	for i, val in MoveAnything_CharacterSettings[fromName] do
		MoveAnything_CharacterSettings[toName][i] = val;
	end
	MoveAnything_FrameOptions = MoveAnything_CharacterSettings[MoveAnything_CurrentSettingsName()];
	MoveAnything_RefreshPositions();
end

function MoveAnything_Init()
	if( MoveAnything_InitRun ) then
		return;
	end

	MoveAnything_CreateRunClock();
	MoveAnything_AddDefaultFrames();

	-- update settings from old versions
	if( MoveAnything_FrameOptions ~= nil ) then
		MoveAnything_CharacterSettings["default"] = MoveAnything_FrameOptions;
		MoveAnything_FrameOptions = nil;
	end

	local settingname = MoveAnything_CurrentSettingsName();

	if( MoveAnything_CharacterSettings[settingname] == nil ) then
		MoveAnything_CharacterSettings[settingname] = {};
	end
	MoveAnything_FrameOptions = MoveAnything_CharacterSettings[settingname];

	-- now add all the custom frames
	for i, v in MoveAnything_CustomFrames do
		if( not MoveAnything_FindFrame( v.name ) ) then
			-- pass true for isDefault, so it doesn't get re-added to the custom list
			MoveAnything_AddFrameToMovableList( v.name, v.helpfulname, true );
		end
	end

	MoveAnything_InitRun = true;

	MoveAnything_RefreshPositions();
end

function MoveAnything_GetFrameCount()
	return table.getn( MoveAnything_Frames );
end

function MoveAnything_ClearFrameOptions( frameName )
	MoveAnything_FrameOptions[frameName] = nil;
	MoveAnything_RemoveIfCustom( frameName );
end

function MoveAnything_FindFrameOptions( frameName, why )
	if( MoveAnything_FrameOptions == nil ) then
		return;
	end
	return MoveAnything_FrameOptions[frameName];
end

function MoveAnything_FindFrame( frameName )
	for i in MoveAnything_Frames do
		if( MoveAnything_Frames[i].name == frameName ) then
			return MoveAnything_Frames[i];
		end
	end
	return nil;
end

function MoveAnything_RemoveIfCustom( frameName )
	local removed = false;
	for i,v in MoveAnything_CustomFrames do
		if( v.name == frameName ) then
			table.remove( MoveAnything_CustomFrames, i );
			removed = true;
			break;
		end
	end
	if( removed ) then
		for i,v in MoveAnything_Frames do
			if( v.name == frameName ) then
				table.remove( MoveAnything_Frames, i );
				break;
			end
		end
	end
end

function MoveAnything_PreventExternalVisibility( frame )
	frame.MAWantsToBeVisible = frame:IsVisible();
	frame:Hide();
	frame.HiddenShow = frame.Show;
	frame.HiddenHide = frame.Hide;
	frame.HiddenIsVisible = frame.IsVisible;
	frame.Show = MoveAnything_HiddenShow;
	frame.Hide = MoveAnything_HiddenHide;
	frame.IsVisible = MoveAnything_HiddenIsVisible;
	if( frame.attachedChildren ) then
		for i, val in frame.attachedChildren do
			MoveAnything_PreventExternalVisibility( val );
		end
	end
end

function MoveAnything_AllowExternalVisibility( frame )
	frame.Show = frame.HiddenShow;
	frame.Hide = frame.HiddenHide;
	frame.IsVisible = frame.HiddenIsVisible;
	frame.HiddenShow = nil;
	frame.HiddenHide = nil;
	frame.HiddenIsVisible = nil;
	if( frame.MAWantsToBeVisible ) then
		frame.MAWantsToBeVisible = nil
		frame:Show();
	end
	if( frame.attachedChildren ) then
		for i, val in frame.attachedChildren do
			MoveAnything_AllowExternalVisibility( val );
		end
	end
end

function MoveAnything_PreventExternalMovement( frame )
	if( frame.HiddenSetPoint == nil ) then
		frame.HiddenSetPoint = frame.SetPoint;
		frame.SetPoint = function() end;
	end
	if( frame.HiddenSetAllPoints == nil ) then
		frame.HiddenSetAllPoints = frame.SetAllPoints;
		frame.SetAllPoints = function() end;
	end
	if( frame.HiddenClearAllPoints == nil ) then
		frame.HiddenClearAllPoints = frame.ClearAllPoints;
		frame.ClearAllPoints = function() end;
	end
	if( frame.HiddenSetScale == nil ) then
		frame.HiddenSetScale = frame.SetScale;
		frame.SetScale = function() end;
	end
	if( frame.attachedChildren ) then
		for i, val in frame.attachedChildren do
			MoveAnything_PreventExternalMovement( val );
		end
	end
end

function MoveAnything_AllowExternalMovement( frame )
	if( frame.HiddenSetPoint ) then
		frame.SetPoint = frame.HiddenSetPoint;
		frame.HiddenSetPoint = nil;
	end
	if( frame.HiddenSetAllPoints ) then
		frame.SetAllPoints = frame.HiddenSetAllPoints;
		frame.HiddenSetAllPoints = nil;
	end
	if( frame.HiddenClearAllPoints ) then
		frame.ClearAllPoints = frame.HiddenClearAllPoints;
		frame.HiddenClearAllPoints = nil;
	end
	if( frame.HiddenSetScale ) then
		frame.SetScale = frame.HiddenSetScale;
		frame.HiddenSetScale = nil;
	end
	if( frame.attachedChildren ) then
		for i, val in frame.attachedChildren do
			MoveAnything_AllowExternalMovement( val );
		end
	end
end

function MoveAnything_HookFrame( frameName )
	local frame = getglobal( frameName );

	if( not MoveAnything_IsFrameHooked( frameName ) ) then
		local opt = MoveAnything_FindFrameOptions( frameName, "HookFrame" );
		if( opt == nil ) then
			MoveAnything_FrameOptions[frameName] = {};
			opt = MoveAnything_FrameOptions[frameName];
			opt.movable = false;
			opt.hidden = false;
		end
		opt.name = frameName;
		opt.originalLeft, opt.originalBottom = MoveAnything_GetRelativeBottomLeft( frame );
		if( MoveAnything_ScaleWH[ frameName ] ) then
			opt.originalWidth = frame:GetWidth();
			opt.originalHeight = frame:GetHeight();
			opt.originalScale = nil;
		else
			opt.originalWidth = nil;
			opt.originalHeight = nil;
			opt.originalScale = MAGetScale( frame );
		end

	end
	if( UIPanelWindows[frame:GetName()] ) then
		local left = GetLeftFrame();
		local center = GetCenterFrame();

		if( frame == left ) then
			UIParent.left = nil;
			if( center ) then
				MovePanelToLeft();
			end
		elseif( frame == center and left ) then
			UIParent.center = nil;
		end
		local opt = MoveAnything_FindFrameOptions( frameName, "Hook UIPanel" );
		if( opt ) then
			opt.UIPanelWindows = UIPanelWindows[frame:GetName()];
		end
		UIPanelWindows[frame:GetName()] = nil;
	end
	if( frame.OnMoveAnythingHook ) then
		frame.OnMoveAnythingHook( frame );
	end
	MoveAnything_PreventExternalMovement( frame );
end

function MoveAnything_IsFrameHooked( frameName )
	if( frameName == nil ) then return; end
	local opt = MoveAnything_FindFrameOptions( frameName, "IsFrameHooked "..frameName );
	if( opt ) then
		if( opt.movable or opt.hidden ) then
			return true;
		end
	end
	return false;
end

function MoveAnything_IsFrameHidden( frameName )
	if( frameName == nil ) then return; end
	local opt = MoveAnything_FindFrameOptions( frameName, "IsFrameHooked "..frameName );
	if( opt ) then
		if( opt.hidden ) then
			return true;
		end
	end
	return false;
end

function MoveAnything_AddFrameToMovableList( frameName, helpfulName, isDefault )
	if( not MoveAnything_FindFrame( frameName ) ) then
		local frame = getglobal( frameName );
		local listOptions = {};
		listOptions.name = frameName;
		listOptions.helpfulName = helpfulName;
		if( listOptions.helpfulName == nil ) then
			listOptions.helpfulName = listOptions.name;
		end
		table.insert( MoveAnything_Frames, listOptions );
		-- if this is not a built-in default frame, we also need to add it to CustomFrames
		if( not isDefault ) then
			table.insert( MoveAnything_CustomFrames, listOptions );
		end
		if( MAOptions:IsVisible() ) then
			MoveAnythingOptions_Update();
		end
	end
end

function MoveAnything_AddSeparator( separatorText, isDefault )
	local listOptions = {};
	listOptions.name = nil;
	listOptions.helpfulName = separatorText;
	table.insert( MoveAnything_Frames, listOptions );
	-- if this is not a built-in default frame, we also need to add it to CustomFrames
	if( not isDefault ) then
		table.insert( MoveAnything_CustomFrames, listOptions );
	end
	if( MAOptions:IsVisible() ) then
		MoveAnythingOptions_Update();
	end
end
