-- Move UI mover and options interactions
-- Mover lifecycle, positioning, sizing, attachment, nudging, and options-list selection.
-- Extracted from the tested 1.2.9 runtime; behavior intentionally preserved.

function MoveAnything_SizingAnchor( button )
	local s, e = string.find( button:GetName(), "Resize_" )
	local anchorto = string.sub( this:GetName(), e + 1 );
	local anchor;

	if( anchorto == "LEFT" ) then anchor = "RIGHT";
	elseif( anchorto == "RIGHT" ) then anchor = "LEFT";
	elseif( anchorto == "TOP" ) then anchor = "BOTTOM";
	elseif( anchorto == "BOTTOM" ) then anchor = "TOP";
	end

	return anchorto, anchor;
end

function MoveAnything_Move( moveFrameName, helpfulName )
	if( MoveAnything_MoveOnlyWhenVisible[ moveFrameName ] ) then
		local frame = getglobal( moveFrameName );
		if( frame == nil or not frame:IsVisible() ) then
			Error( "That window may only be moved when it is visible" );
			return;
		end
	end

	if( not MoveAnything_FindMAFrame( moveFrameName ) ) then
		local frame = MoveAnything_FindAvailableFrame();
		if( frame == nil ) then
			Error( "You can only move "..MOVEANYTHING_MOVEATONETIME.." frames at once." );
		elseif( getglobal( moveFrameName ) == nil ) then
			Error( "\""..moveFrameName.."\" is not a valid frame name." );
		else
			local moveFrame = getglobal( moveFrameName );
			MoveAnything_AddFrameToMovableList( moveFrameName, helpfulName );
			MoveAnything_HookFrame( moveFrameName );
			MoveAnything_Attach( frame, getglobal( moveFrameName ) );
			if( moveFrame.OnMoveAnythingPostAttach ) then
				moveFrame.OnMoveAnythingPostAttach( moveFrame );
			end
			if( MAOptions:IsVisible() ) then
				MoveAnythingOptions_Update();
			end
		end
	end
end

function MA_Mover(dir)
	if ( dir > 0 ) then
		if ( CurrentMover < 20 ) then
			CurrentMover = CurrentMover + 1;
		else
			return;
		end
	else
		if ( CurrentMover > 1 ) then
			CurrentMover = CurrentMover - 1;
		else
			return;
		end
	end
	MA_NudgerFrameRefresh();
end

function MA_GetFirstMover()
	for i = 1, 20 do
		if ( getglobal("MoveAnything"..i):IsVisible() ) then
			return i;
		end
	end
end

function MoveAnythingOptions_OnHide()
	MA_MoverOnHide();
end

function MA_MoverOnShow()
	ResizingNudger:Show();
	CurrentMover = tonumber(this:GetID());
	MA_NudgerFrameRefresh();
end

function MA_MoverOnHide()
	if ( MA_GetFirstMover() ) then
		CurrentMover = MA_GetFirstMover();
		MA_NudgerFrameRefresh();
	elseif ( MAOptions:IsVisible() ) then
		CurrentMover = 1;
		MA_NudgerFrameRefresh(1);
	else
		ResizingNudger:Hide();
	end
end

function MA_NudgerOnShow()
	MA_NudgerFrameRefresh();
end

function MA_NudgerFrameRefresh(reset)
	if ( CurrentMover < 20 ) then
		ResizingNudger_MoverPlus:Enable();
	else
		ResizingNudger_MoverPlus:Disable();
	end
	if ( CurrentMover > 1 ) then
		ResizingNudger_MoverMinus:Enable();
	else
		ResizingNudger_MoverMinus:Disable();
	end

	local labelText = "Move UI "..CurrentMover.."/20";
	if ( not reset and getglobal("MoveAnything"..CurrentMover).tagged ) then
		labelText = labelText.."\n"..getglobal("MoveAnything"..CurrentMover).tagged:GetName();
	end
	ResizingNudgerTitle:SetText(labelText);
end

	return frameName;
end

function MA_NudgerOnUpdate()
	-- Show readable names while preserving all internal frame identifiers.
	local obj = GetMouseFocus();
	local text = "MouseOver: ";
	local label = ResizingNudgerMouseOver;

	if (obj and obj ~= WorldFrame and obj:GetName()) then
		text = text..MoveUI_DisplayFrameName(obj:GetName());
		if (obj:GetParent()  and obj:GetParent() ~= WorldFrame and obj:GetParent():GetName() ) then
			text = text.."\nParent: "..MoveUI_DisplayFrameName(obj:GetParent():GetName());
			if (obj:GetParent():GetParent() and obj:GetParent():GetParent() ~= WorldFrame and obj:GetParent():GetParent():GetName()) then
				text = text.."\nParent's Parent: "..MoveUI_DisplayFrameName(obj:GetParent():GetParent():GetName());
			end
		end
	end

	if ( not string.find(text, "ResizingNudger") ) then
		label:SetText(text);
	else
		label:SetText("MouseOver: ");
	end
end

function MoveAnything_MoveFrameUnderCursor()
	local obj = GetMouseFocus();
	if (obj and obj ~= WorldFrame and obj ~= UIParent and obj:GetName()) then
		MoveAnything_ToggleMove( obj:GetName() );
	end
end

function MA_Center(lock)
	local mover = getglobal("MoveAnything"..CurrentMover);
	if ( lock == 0 ) then
		-- Both
		mover:ClearAllPoints();
		mover:SetPoint("CENTER",0,0);
	else
		local x, y;
		x = mover:GetLeft();
		y = mover:GetBottom();

		mover:ClearAllPoints();
		if ( lock == 1 ) then
			--Horizontal
			mover:SetPoint("CENTER",0,0);
			x = mover:GetLeft();
			mover:ClearAllPoints();
			mover:SetPoint("BOTTOMLEFT",x,y);
		elseif ( lock == 2 ) then
			-- Vertical
			mover:SetPoint("CENTER",0,0);
			y = mover:GetBottom();
			mover:ClearAllPoints();
			mover:SetPoint("BOTTOMLEFT",x,y);
		end
	end

	MoveAnything_UpdatePosition(mover);
end

function MA_Nudge(dir, button)
	local x, y, offsetX, offsetY, parent, mover, offsetAmount;
	mover = getglobal("MoveAnything"..CurrentMover);

	if ( not mover:IsVisible() ) then
		return;
	end

	x = mover:GetLeft();
	y = mover:GetBottom();

	if ( button == "RightButton" ) then
		if ( IsShiftKeyDown() ) then
			offsetAmount = 250;
		else
			offsetAmount = 50;
		end
	else
		if ( IsShiftKeyDown() ) then
			offsetAmount = 10;
		else
			offsetAmount = 1;
		end
	end

	if ( dir == 1 ) then
		offsetX = 0;
		offsetY = offsetAmount;
	elseif ( dir == 2 ) then
		offsetX = 0;
		offsetY = -offsetAmount;
	elseif ( dir == 3 ) then
		offsetX = -offsetAmount;
		offsetY = 0;
	elseif ( dir == 4 ) then
		offsetX = offsetAmount;
		offsetY = 0;
	end

	mover:ClearAllPoints();
	mover:SetPoint("BOTTOMLEFT","UIParent","BOTTOMLEFT",x + offsetX, y + offsetY);
	MoveAnything_UpdatePosition(mover);
end

function MoveAnything_UpdatePosition( moveFrame )
	local x, y, parent;
	x = nil;
	y = nil;
	parent = nil;
	if( moveFrame.tagged ) then
		if( MoveAnything_DetachFromParent[ moveFrame.tagged:GetName() ] ) then
			x = moveFrame:GetLeft();
			y = moveFrame:GetBottom();
			parent = UIParent;
		else
			x, y = MoveAnything_GetRelativeBottomLeft( moveFrame.tagged );
			parent = MoveAnything_GetPositionParent( moveFrame.tagged );
		end
		local opt = MoveAnything_FindFrameOptions( moveFrame.tagged:GetName(), "UpdatePosition" );
		opt.x = x;
		opt.y = y;
	end
	return x, y, parent;
end

function MoveAnything_StopMoving( moveFrameName )
	local frame = MoveAnything_FindMAFrame( moveFrameName );
	if( frame ) then
		MoveAnything_Detach( frame );
		if( MAOptions:IsVisible() ) then
			MoveAnythingOptions_Update();
		end
	end
end

function MoveAnything_ToggleMove( moveFrameName )
	if( MoveAnything_FindMAFrame( moveFrameName ) ) then
		MoveAnything_StopMoving( moveFrameName );
	else
		MoveAnything_Move( moveFrameName );
	end
end

function MoveAnything_FindMAFrame( moveFrameName )
	local frame;
	for i = 1, MOVEANYTHING_MOVEATONETIME, 1 do
		frame = getglobal( "MoveAnything"..i );
		if( type(frame) ~= "nil" and frame:IsVisible() and frame.tagged == getglobal( moveFrameName ) ) then
			return frame;
		end
	end
	return nil;
end

function MoveAnything_FindAvailableFrame()
	local frame;
	for i = 1, MOVEANYTHING_MOVEATONETIME, 1 do
		frame = getglobal( "MoveAnything"..i );
		if( not( frame:IsVisible() ) ) then
			return frame;
		end
	end
	return nil;
end

function MoveAnything_OnSizeChanged( this )
	if( this.tagged ) then
		local s, w, h, opt;

		opt = MoveAnything_FindFrameOptions( this.tagged:GetName(), "OnSizeChanged" );

		if( MoveAnything_ScaleWH[ this.tagged:GetName() ] ) then
			this.tagged:SetHeight( this:GetHeight() );
			this.tagged:SetWidth( this:GetWidth() );
			-- if this ever needs to apply to a frame with attached children,
			-- we're going to have to figure out what to do, since setting
			-- the W and H directly is definitely incorrect

			if( opt ) then
				opt.width = this:GetHeight();
				opt.height = this:GetHeight();
			end
		else
			if( this.MASizingAnchor == "LEFT" or this.MASizingAnchor == "RIGHT" ) then
				w = this:GetWidth();
				h = w * (this.tagged:GetHeight() / this.tagged:GetWidth());
				if( h < 16 ) then
					h = 16;
					w = h * (this.tagged:GetWidth() / this.tagged:GetHeight());
				end
			else
				h = this:GetHeight();
				w = h * (this.tagged:GetWidth() / this.tagged:GetHeight());
				if( w < 16 ) then
					w = 16;
					h = w * (this.tagged:GetHeight() / this.tagged:GetWidth());
				end
			end
			s = this:GetWidth() / this.tagged:GetWidth();
			s = s / MAGetScale( this.tagged:GetParent(), 1  ) * UIParent:GetScale();

			if( MoveAnything_ScaleAllowed( this.tagged:GetName() ) ) then
				if( opt ) then
					if ( this.tagged:GetName() == "LocalClockDisplayFrame" ) then
						local minimapScale = this.tagged.LocalClockMinimapScale or 1;
						if ( minimapScale <= 0 ) then minimapScale = 1; end
						opt.scale = s / minimapScale;
					else
						opt.scale = s;
					end
				end

				-- Some Azeroth Survivors frames do not implement SetScale.
				-- PreventExternalMovement cannot save a missing method as HiddenSetScale.
				if this.tagged.HiddenSetScale then
					this.tagged:HiddenSetScale( s );
				elseif this.tagged.SetScale then
					this.tagged:SetScale( s );
				end
				if( this.tagged.attachedChildren ) then
					for i, v in this.tagged.attachedChildren do
						if v.HiddenSetScale then
							v:HiddenSetScale( s );
						elseif v.SetScale then
							v:SetScale( s );
						end
					end
				end
			end
			this:SetWidth( w );
			this:SetHeight( h );
		end
	end
end

function MoveAnything_GetRelativeBottomLeft( tagFrame )
	x = tagFrame:GetLeft();
	if( x ) then
		local positionParent = MoveAnything_GetPositionParent( tagFrame );
		if ( tagFrame:GetName() == "LocalClockDisplayFrame" ) then
			local uiScale = MAGetScale( UIParent, 1 ) or 1;
			local parentScale = MAGetScale( positionParent, 1 ) or 1;
			if ( parentScale <= 0 ) then parentScale = 1; end
			x = ( x - positionParent:GetLeft() ) * uiScale / parentScale;
		else
			x = x - positionParent:GetLeft() * MAGetScale( positionParent ) / MAGetScale( tagFrame );
		end
	end
	y = tagFrame:GetBottom();
	if( y ) then
		local positionParent = MoveAnything_GetPositionParent( tagFrame );
		if ( tagFrame:GetName() == "LocalClockDisplayFrame" ) then
			local uiScale = MAGetScale( UIParent, 1 ) or 1;
			local parentScale = MAGetScale( positionParent, 1 ) or 1;
			if ( parentScale <= 0 ) then parentScale = 1; end
			y = ( y - positionParent:GetBottom() ) * uiScale / parentScale;
		else
			y = y - positionParent:GetBottom() * MAGetScale( positionParent ) / MAGetScale( tagFrame );
		end
	end
	return x,y;
end

function MoveAnything_Attach( moveFrame, tagFrame )
	if( moveFrame.tagged ) then
		MoveAnything_Detach( moveFrame );
	end

	local listOptions = MoveAnything_FindFrame( tagFrame:GetName() );
	local frameOptions = MoveAnything_FindFrameOptions( tagFrame:GetName(), "Attach" );
	frameOptions.movable = true;
	moveFrame.helpfulName = listOptions.helpfulName;

	if( tagFrame.OnBeginMove ) then
		if( not tagFrame:OnBeginMove() ) then
			MoveAnything_Detach( moveFrame );
			return;
		end
	end

	local x, y, moverParent;
	if( tagFrame:GetLeft() == nil ) then tagFrame:Show(); tagFrame:Hide(); end
	if( MoveAnything_DetachFromParent[ tagFrame:GetName() ] ) then
		x = tagFrame:GetLeft() * MAGetScale( tagFrame, 1 ) / UIParent:GetScale();
		y = tagFrame:GetBottom() * MAGetScale( tagFrame, 1 ) / UIParent:GetScale();
		moverParent = UIParent;
	else
		moverParent = MoveAnything_GetPositionParent( tagFrame );
		if ( tagFrame:GetName() == "LocalClockDisplayFrame" ) then
			local uiScale = UIParent:GetEffectiveScale();
			local parentScale = moverParent:GetEffectiveScale();
			if ( not uiScale or uiScale <= 0 ) then uiScale = 1; end
			if ( not parentScale or parentScale <= 0 ) then parentScale = 1; end
			x = ( tagFrame:GetLeft() - moverParent:GetLeft() ) * uiScale / parentScale;
			y = ( tagFrame:GetBottom() - moverParent:GetBottom() ) * uiScale / parentScale;
		else
			x = tagFrame:GetLeft() * MAGetScale( tagFrame, 1 ) / UIParent:GetScale();
			x = x - moverParent:GetLeft() * MAGetScale( moverParent, 1 ) / UIParent:GetScale();
			y = tagFrame:GetBottom() * MAGetScale( tagFrame, 1 ) / UIParent:GetScale();
			y = y - moverParent:GetBottom() * MAGetScale( moverParent, 1 ) / UIParent:GetScale();
		end
	end

	moveFrame:ClearAllPoints();
	moveFrame:SetPoint( "BOTTOMLEFT", moverParent:GetName(), "BOTTOMLEFT", x, y );
	moveFrame:SetWidth( tagFrame:GetWidth() * MAGetScale( tagFrame , 1 ) / UIParent:GetScale() );
	moveFrame:SetHeight( tagFrame:GetHeight() * MAGetScale( tagFrame, 1 ) / UIParent:GetScale() );
	-- Azeroth Survivors UI frames may not expose GetFrameLevel; mirror the
	-- original MoveAnything compatibility guard instead of assuming the method exists.
	if tagFrame.GetFrameLevel then
		moveFrame:SetFrameLevel( tagFrame:GetFrameLevel() + 1 );
	end
	tagFrame:HiddenClearAllPoints();
	tagFrame:HiddenSetPoint( "BOTTOMLEFT", moveFrame:GetName(), "BOTTOMLEFT", 0, 0 );

	moveFrame.tagged = tagFrame;

	moveFrame:Show();
end

function MoveAnything_Detach( moveFrame )
	if( moveFrame.tagged ) then
		local x, y, parent = MoveAnything_UpdatePosition( moveFrame );
		moveFrame.tagged:HiddenClearAllPoints();
		moveFrame.tagged:HiddenSetPoint( "BOTTOMLEFT", parent:GetName(), "BOTTOMLEFT", x, y );
	end
	moveFrame:Hide();
	moveFrame.tagged = nil;
end

function MoveAnything_ResetFrameOptions( frameName )
	MoveAnything_StopMoving( frameName );
	local frame = getglobal( frameName );
	if ( not frame ) then return; end

	if( frame.OnMoveAnythingPreReset ) then
		frame.OnMoveAnythingPreReset( frame );
	end

	MoveAnything_AllowExternalMovement( frame );
	local opt = MoveAnything_FindFrameOptions( frameName, "Reset Frame Options" );
	local left = nil;
	local bottom = nil;
	local width = nil;
	local height = nil;
	if( opt ) then
		left = opt.originalLeft;
		bottom = opt.originalBottom;
		width = opt.originalWidth;
		height = opt.originalHeight;
		if( opt.hidden ) then
			opt.hidden = false;
			MoveAnything_ShowFrame( frame );
		end
	end
	frame:ClearAllPoints();
	frame:SetPoint( "BOTTOMLEFT", MoveAnything_GetPositionParent( frame ):GetName(), "BOTTOMLEFT", left, bottom );
	if( opt and MoveAnything_ScaleAllowed( frame:GetName() ) and opt.originalScale ) then
		if ( frame:GetName() == "LocalClockDisplayFrame" and frame.HiddenSetScale ) then
			frame:HiddenSetScale( frame.LocalClockMinimapScale or opt.originalScale );
		else
			frame:SetScale( opt.originalScale );
		end
	end
	if( width ) then frame:SetWidth( width ); end
	if( height ) then frame:SetHeight( height ); end
	if( opt and opt.originalScale and frame.attachedChildren ) then
		for i, v in frame.attachedChildren do
			if( MoveAnything_ScaleAllowed( frame:GetName() ) ) then
				v:SetScale( opt.originalScale );
			end
		end
	end

	if( frame.OnMoveAnythingPostReset ) then
		frame.OnMoveAnythingPostReset( frame );
	end

	frame.attachedChildren = nil;
	if( opt and opt.UIPanelWindows ) then
		UIPanelWindows[frameName] = opt.UIPanelWindows;
		if( frame:IsVisible() ) then
			frame:Hide();
			ShowUIPanel( frame );
		end
	end
	MoveAnything_ClearFrameOptions( frameName );
	if( MAOptions:IsVisible() ) then
		MoveAnythingOptions_Update();
	end
end

function MoveAnything_CloseOptionsMenu()
	-- Closing Move UI should end active move mode, not leave mover overlays on screen.
	for i = 1, MOVEANYTHING_MOVEATONETIME, 1 do
		local mover = getglobal( "MoveAnything"..i );
		if( mover and mover.tagged ) then
			MoveAnything_StopMoving( mover.tagged:GetName() );
		end
	end
	MAOptions:Hide();
	if( ResizingNudger ) then ResizingNudger:Hide(); end
	if( MoveAnythingAS_HideGrid ) then MoveAnythingAS_HideGrid(); end
end

function MoveAnything_ToggleOptionsMenu()
	if( MAOptions:IsVisible() ) then
		MoveAnything_CloseOptionsMenu();
	else
		MAOptions:Show();
	end
end

function MoveAnythingOptions_OnShow()
	ResizingNudger:Show();
	MoveAnythingOptions_Update();
end

function MoveAnything_GetIndex( frame )
	local index = tonumber( string.sub( frame:GetName(), string.len( "MAMove" ) + 1, -1 ) );
	return index + FauxScrollFrame_GetOffset( MAScrollFrame );
end

function MoveAnything_GetMovableFrame( optionsListFrame )
	local index = MoveAnything_GetIndex( optionsListFrame );
	return getglobal( MoveAnything_Frames[index].name );
end

function MoveAnything_OnMoveCheck( button )
	local frame = MoveAnything_GetMovableFrame( MAGetParent( button ) );
	if ( not frame ) then return; end
	if( button:GetChecked() ) then
		MoveAnything_Move( frame:GetName() );
	else
		MoveAnything_StopMoving( frame:GetName() );
	end
	if( MAOptions:IsVisible() ) then
		MoveAnythingOptions_Update();
	end
end
