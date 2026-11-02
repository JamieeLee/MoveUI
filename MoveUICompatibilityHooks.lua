-- Move UI game compatibility hooks
-- Container, tooltip, talent-button, UIPanel, and action-bar compatibility hooks.
-- Extracted from the tested 1.2.9 runtime; behavior intentionally preserved.

function MoveAnything_FindContainerFrame( id )
	local i = 1;
	local container;
	while( 1 ) do
		container = getglobal( "ContainerFrame"..i );
		if( not container ) then break; end
		if( container:IsVisible() and container:GetID() == id ) then
			return container;
		end
		i = i + 1;
	end
	return nil;
end

function MoveAnything_GrabContainerFrame( container, movableBag )
	if( movableBag and MoveAnything_IsFrameHooked( movableBag:GetName() ) ) then
		MoveAnything_PreventExternalMovement( container );
		container.MAContainerOriginalScale = MAGetScale( container );
		movableBag:Show();
		container:HiddenClearAllPoints();
		container:HiddenSetScale( MAGetScale( movableBag ) );
		--container:HiddenSetPoint( "BOTTOMLEFT", "UIParent", "BOTTOMLEFT", movableBag:GetLeft(), movableBag:GetBottom() );
		container:HiddenSetPoint( "BOTTOMLEFT", movableBag:GetName(), "BOTTOMLEFT", 0, 0 );
		movableBag.attachedChildren = {};
		table.insert( movableBag.attachedChildren, container );
	end
end

function MoveAnything_RemoveContainerFromList( container )
	-- Remove this bag from the list and collapse the rest of the entries
	local index = 1;
	local tempIndex;
	while ContainerFrame1.bags[index] do
		if ( ContainerFrame1.bags[index] == container:GetName() ) then
			ContainerFrame1.bagsShown = ContainerFrame1.bagsShown - 1;
			local tempIndex = index;
			while ContainerFrame1.bags[tempIndex] do
				if ( ContainerFrame1.bags[tempIndex + 1] ) then
					ContainerFrame1.bags[tempIndex] = ContainerFrame1.bags[tempIndex + 1];
				else
					ContainerFrame1.bags[tempIndex] = nil;
				end
				tempIndex = tempIndex + 1;
			end
		end
		index = index + 1;
	end
	updateContainerFrameAnchors();
end

-- TOOLTIP HOOKS
MoveAnything_OriginalSetDefaultAnchor = GameTooltip_SetDefaultAnchor;
function GameTooltip_SetDefaultAnchor(tooltip, parent)
	if( MoveAnything_IsFrameHooked( "TooltipMover" ) and tooltip == GameTooltip ) then
		-- anchor the tooltip to the side of the mover that is closest to the edge
		local l, r, t, b, a, anchor;
		l = TooltipMover:GetLeft() - UIParent:GetLeft();
		r = UIParent:GetRight() - TooltipMover:GetRight();
		t = UIParent:GetTop() - TooltipMover:GetTop();
		b = TooltipMover:GetBottom() - UIParent:GetBottom();
		a = t;
		anchor = "TOP";
		if( l < a ) then a = l; anchor = "LEFT"; end
		if( r < a ) then a = r; anchor = "RIGHT"; end
		if( b < a ) then a = b; anchor = "BOTTOM"; end

		tooltip:ClearAllPoints();
		tooltip:SetOwner(parent, "ANCHOR_NONE");
		tooltip:SetPoint( anchor, "TooltipMover", anchor, 0, 0 );
		tooltip.default = 1;
	else
		tooltip:ClearAllPoints();
		MoveAnything_OriginalSetDefaultAnchor( tooltip, parent );
	end
end
MoveAnything_OriginalGameTooltip_OnHide = GameTooltip_OnHide;
function GameTooltip_OnHide()
	MoveAnything_AllowExternalMovement( this );
	MoveAnything_OriginalGameTooltip_OnHide();
end

-- BAG FRAME HOOKS
MoveAnything_BagFrames = {};
MoveAnything_OriginalGenerateFrame = ContainerFrame_GenerateFrame;
function ContainerFrame_GenerateFrame(frame, size, id)
	local bag = MoveAnything_BagFrames[id]
	MoveAnything_OriginalGenerateFrame( frame, size, id );
	MoveAnything_GrabContainerFrame( frame, bag );
end
MoveAnything_OriginalOnHide = ContainerFrame_OnHide;
function ContainerFrame_OnHide()
	local bag = MoveAnything_BagFrames[this:GetID()];
	if( bag and MoveAnything_IsFrameHooked( bag:GetName() ) ) then
		MoveAnything_AllowExternalMovement( this );
		if( this.MAContainerOriginalScale ) then
			this:SetScale( this.MAContainerOriginalScale );
			this.MAContainerOriginalScale = nil;
		end
		this:ClearAllPoints();
		-- we removed the container from the list before, but now we have to add
		-- it back, since the container code is going to try to remove it, and doesn't
		-- particularly care if it's already gone
		ContainerFrame1.bagsShown = ContainerFrame1.bagsShown + 1;
		ContainerFrame1.bags[ContainerFrame1.bagsShown] = this:GetName();
	end
	MoveAnything_OriginalOnHide();
end
MoveAnything_OriginalOnShow = ContainerFrame_OnShow;
function ContainerFrame_OnShow()
	MoveAnything_OriginalOnShow();
	local bag = MoveAnything_BagFrames[this:GetID()];
	if( bag and MoveAnything_IsFrameHooked( bag:GetName() ) ) then
		MoveAnything_RemoveContainerFromList( this );
	end
end

-- TALENT BUTTON HOOK
MoveAnything_OriginalUpdateTalentButton = UpdateTalentButton;
function UpdateTalentButton()
	-- The vertical micro-button layout is intentionally not exposed in Move UI.
	-- Keep the game's own talent-button behavior and let the horizontal mover
	-- reposition the complete group without forcing legacy WoW coordinates.
	MoveAnything_OriginalUpdateTalentButton();
end

--- UI PANEL HOOKS
function MoveAnything_SetLeftFrameLocation()
	local left = GetLeftFrame();
	if( left ) then
		if( MoveAnything_IsFrameHooked( "UIPanelMover1" ) ) then
			left:ClearAllPoints();
			left:SetPoint( "TOPLEFT", "UIPanelMover1", "TOPLEFT" );
			left:SetScale( MAGetScale( UIPanelMover1 ), 1 );
		else
			left:SetScale( 1 );
		end
	end
end

function MoveAnything_SetCenterFrameLocation()
	-- don't mess with the normal center panels, just the ones
	-- that are pushed over from the left
	if( GetLeftFrame() ) then
		local center = GetCenterFrame();
		if( center ) then
			if( MoveAnything_IsFrameHooked( "UIPanelMover2" ) ) then
				center:ClearAllPoints();
				center:SetPoint( "TOPLEFT", "UIPanelMover2", "TOPLEFT" );
				center:SetScale( MAGetScale( UIPanelMover2 ), 1 );
			else
				center:SetScale( 1 );
			end
		end
	end
end

MoveAnything_OriginalShowUIPanel = ShowUIPanel;
function ShowUIPanel(frame)
	MoveAnything_OriginalShowUIPanel(frame);
	MoveAnything_SetLeftFrameLocation();
	MoveAnything_SetCenterFrameLocation();
end
MoveAnything_OriginalMovePanelToLeft = MovePanelToLeft;
function MovePanelToLeft()
	MoveAnything_OriginalMovePanelToLeft();
	MoveAnything_SetLeftFrameLocation();
end
MoveAnything_OriginalMovePanelToCenter = MovePanelToCenter;
function MovePanelToCenter()
	MoveAnything_OriginalMovePanelToCenter();
	MoveAnything_SetCenterFrameLocation();
end
MoveAnything_OriginalCloseAllWindows = CloseAllWindows;
function CloseAllWindows(ignoreCenter)
	local closed = nil, oclosed;
	for i, v in MoveAnything_Frames do
		if( MoveAnything_IsFrameHooked( v.name ) ) then
			local opt = MoveAnything_FindFrameOptions( v.name, "CloseAllWindows" );
			if( opt and opt.UIPanelWindows ) then
				if ( type(getglobal(v.name)) ~= "nil" ) then
					if( getglobal( v.name ):IsVisible() ) then
						getglobal( v.name ):Hide();
						closed = true;
					end
				end
			end
		end
	end
	oclosed = MoveAnything_OriginalCloseAllWindows( ignoreCenter );
	if( oclosed or closed ) then
		return true;
	end
	return nil;
end

--- ACTION BUTTON HOOKS
MoveAnything_OriginalShowBonusActionBar = ShowBonusActionBar;
function ShowBonusActionBar()
	if( MoveAnything_IsFrameHooked( "BasicActionButtonsMover" ) or
		MoveAnything_IsFrameHidden( "MainMenuBar" ) ) then
		for i = 1, 12, 1 do
			getglobal( "ActionButton"..i ):Hide();
			MoveAnything_PreventExternalVisibility( getglobal( "ActionButton"..i ) );
		end
	end
	MoveAnything_OriginalShowBonusActionBar();
end

MoveAnything_OriginalHideBonusActionBar = HideBonusActionBar;
function HideBonusActionBar()
	local hooked = nil;
	local opt = nil;
	if( MoveAnything_IsFrameHooked( "BasicActionButtonsMover" ) ) then
		hooked = "BasicActionButtonsMover";
	end
	if( hooked ) then
		opt = MoveAnything_FindFrameOptions( hooked, "HideBonusActionBar" );
	end
	if( hooked or MoveAnything_IsFrameHidden( "MainMenuBar" ) ) then
		for i = 1, 12, 1 do
			getglobal( "ActionButton"..i ):Show();
			if( (not opt) or (not opt.hidden) ) then
				MoveAnything_AllowExternalVisibility( getglobal( "ActionButton"..i ) );
			end
		end
	end
	MoveAnything_OriginalHideBonusActionBar();
end
