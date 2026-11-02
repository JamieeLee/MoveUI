-- Move UI visibility and options state
-- Hide/show integration, LocalClock visibility notifications, and options refresh/reset behavior.
-- Extracted from the tested 1.2.9 runtime; behavior intentionally preserved.

function MoveAnything_HiddenShow( this )
	this.MAWantsToBeVisible = true;
end

function MoveAnything_HiddenHide( this )
	this.MAWantsToBeVisible = false;
end

function MoveAnything_HiddenIsVisible( this )
	return this.MAWantsToBeVisible;
end

local function MoveAnything_NotifyLocalClockVisibility( frame, visible )
	if ( not frame or not frame.GetName ) then return; end
	local name = frame:GetName();
	if ( name == "LocalClockDisplayFrame" and LocalClock_OnMoveUIVisibilityChanged ) then
		LocalClock_OnMoveUIVisibilityChanged( visible );
	elseif ( name == "MinimapCluster" and LocalClock_OnMinimapVisibilityChanged ) then
		LocalClock_OnMinimapVisibilityChanged( visible );
	end
end

function MoveAnything_HideFrame( frame )
	if ( not frame ) then return; end
	if ( not MoveAnything_IsFrameHooked( frame:GetName() ) ) then
		MoveAnything_HookFrame( frame:GetName() );
	end
	local opt = MoveAnything_FindFrameOptions( frame:GetName(), "HideFrame" );
	opt.hidden = true;
	frame.MAWantsToBeVisible = frame:IsVisible();
	if( MoveAnything_HideList[ frame:GetName() ] ) then
		for hIndex, hideEntry in MoveAnything_HideList[ frame:GetName() ] do
			local val = getglobal( hideEntry[1] );
			local hideType;
			for i = 2, table.getn( hideEntry ) do
				hideType = hideEntry[i];
				if( type( hideType ) == "function" ) then
					hideType( false );
				elseif( hideType == "DISABLEMOUSE" ) then
					val:EnableMouse( false );
				elseif( hideType == "FRAME" ) then
					MoveAnything_PreventExternalVisibility( val );
				elseif( hideType == "WH" ) then
					MoveAnything_StopMoving( frame:GetName() );
					val:SetWidth( 1 );
					val:SetHeight( 1 );
				else
					val:DisableDrawLayer( hideType );
				end
			end
		end
	elseif( MoveAnything_HideUsingWH[ frame:GetName() ] ) then
		MoveAnything_StopMoving( frame:GetName() );
		frame:SetWidth( 1 );
		frame:SetHeight( 1 );
	else
		MoveAnything_PreventExternalVisibility( frame );
	end
	MoveAnything_NotifyLocalClockVisibility( frame, false );
end

function MoveAnything_ShowFrame( frame )
	-- if being hidden is the only thing we're controlling with this frame
	-- do a full reset instead of a simple show
	if ( not frame ) then return; end
	local opt = MoveAnything_FindFrameOptions( frame:GetName(), "ShowFrame" );
	if( opt and opt.hidden ) then
		if( not opt.movable ) then
			MoveAnything_ResetFrameOptions( frame:GetName() );
			return;
		end
	end

	if( opt ) then
		opt.hidden = false;
	end
	if( MoveAnything_HideList[ frame:GetName() ] ) then
		for hIndex, hideEntry in MoveAnything_HideList[ frame:GetName() ] do
			local val = getglobal( hideEntry[1] );
			local hideType;
			for i = 2, table.getn( hideEntry ) do
				hideType = hideEntry[i];
				if( type( hideType ) == "function" ) then
					hideType( true );
				elseif( hideType == "DISABLEMOUSE" ) then
					val:EnableMouse( true );
				elseif( hideType == "FRAME" ) then
					MoveAnything_AllowExternalVisibility( val );
				elseif( hideType == "WH" ) then
					val:SetWidth( opt.originalWidth );
					val:SetHeight( opt.originalHeight );
				else
					val:EnableDrawLayer( hideType );
				end
			end
		end
	elseif( MoveAnything_HideUsingWH[ frame:GetName() ] ) then
		frame:SetWidth( opt.originalWidth );
		frame:SetHeight( opt.originalHeight );
	else
		MoveAnything_AllowExternalVisibility( frame );
	end
	MoveAnything_NotifyLocalClockVisibility( frame, true );
end

function MoveAnything_OnHideCheck( button )
	local frame = MoveAnything_GetMovableFrame( MAGetParent( button ) );
	if ( not frame ) then return; end
	local frameName = frame:GetName();
	local opt = MoveAnything_FindFrameOptions( frameName, "Hide checkbox" );
	if( button:GetChecked() ) then
		if ( frameName == "LocalClockDisplayFrame" and opt ) then
			opt.minimapSuppressed = nil;
		end
		MoveAnything_HideFrame( frame );
	else
		if ( frameName == "LocalClockDisplayFrame" and opt and opt.minimapSuppressed and not opt.hidden ) then
			-- This checked state came from the minimap being hidden, not the
			-- user's own Hide preference. Allow LocalClock to show independently.
			opt.minimapSuppressed = nil;
			if ( LocalClock_OnMoveUIVisibilityChanged ) then
				LocalClock_OnMoveUIVisibilityChanged( true );
			end
		else
			if ( frameName == "LocalClockDisplayFrame" and opt ) then
				opt.minimapSuppressed = nil;
			end
			MoveAnything_ShowFrame( frame );
		end
	end
	MoveAnythingOptions_Update();
end

function MoveAnything_OnResetCheck( button )
	local frame = MoveAnything_GetMovableFrame( MAGetParent( button ) );
	if ( not frame ) then return; end
	MoveAnything_ResetFrameOptions( frame:GetName() );
end

function MoveAnything_OnCheckCharacterSpecific( button )
	local oldName = MoveAnything_CurrentSettingsName();
	if( button:GetChecked() ) then
		MoveAnything_UseCharacterSettings = true;
		MoveAnything_CopySettings( oldName, MoveAnything_CurrentSettingsName() );
	else
		MoveAnything_UseCharacterSettings = false;
		MoveAnything_CopySettings( oldName, MoveAnything_CurrentSettingsName() );
	end
	MoveAnythingOptions_Update();
end

function MoveAnythingOptions_Update()
	FauxScrollFrame_Update(MAScrollFrame, MoveAnything_GetFrameCount(), 10, MOVEANYTHING_SCROLL_HEIGHT );

	for i=1, 10, 1 do
		local index = FauxScrollFrame_GetOffset(MAScrollFrame) + i;
		if( index <= MoveAnything_GetFrameCount() ) then
			local f = getglobal( "MAMove"..i.."FrameNameText" );
			f:SetText( MoveAnything_Frames[index].helpfulName );
			if( MoveAnything_Frames[index] ) then
				getglobal( "MAMove"..i ):Show();
			end

			local opt = MoveAnything_FindFrameOptions( MoveAnything_Frames[index].name, "MAOptions Update" );
			if( MoveAnything_Frames[index].name ) then
				getglobal( "MAMove"..i.."Backdrop" ):Show();
				getglobal( "MAMove"..i.."Move" ):Show();
			else
				getglobal( "MAMove"..i.."Backdrop" ):Hide();
				getglobal( "MAMove"..i.."Move" ):Hide();
			end

			if( MoveAnything_FindMAFrame( MoveAnything_Frames[index].name ) ) then
				getglobal( "MAMove"..i.."Move" ):SetChecked( 1 );
			else
				getglobal( "MAMove"..i.."Move" ):SetChecked( nil );
			end
			if( opt and ( opt.hidden or opt.minimapSuppressed ) ) then
				getglobal( "MAMove"..i.."Hide" ):SetChecked( 1 );
			else
				getglobal( "MAMove"..i.."Hide" ):SetChecked( nil );
			end

			-- disallow hiding?
			if( not MoveAnything_Frames[index].name or
					MoveAnything_NoHide[ MoveAnything_Frames[index].name ] ) then
				getglobal( "MAMove"..i.."Hide" ):Hide();
			else
				getglobal( "MAMove"..i.."Hide" ):Show();
			end

			-- add a reset button if it's movable
			if( MoveAnything_IsFrameHooked( MoveAnything_Frames[index].name ) ) then
				getglobal( "MAMove"..i.."Reset" ):Show();
			else
				getglobal( "MAMove"..i.."Reset" ):Hide();
			end
		else
			getglobal( "MAMove"..i ):Hide();
		end

	end

	if( MoveAnything_UseCharacterSettings ) then
		MAOptionsCharacterSpecific:SetChecked( 1 );
	else
		MAOptionsCharacterSpecific:SetChecked( nil );
	end
end

function MoveAnythingOptions_ResetAll()
	for i,v in MoveAnything_FrameOptions do
		MoveAnything_ResetFrameOptions( v.name );
	end
	MoveAnything_FrameOptions = {};
end
