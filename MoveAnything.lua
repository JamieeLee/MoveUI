--[[
  Move UI core bootstrap.
  Runtime systems are organized into focused modules loaded by MoveAnything.xml.
  Legacy global callbacks are intentionally retained for XML templates and addon compatibility.
]]
--[[
	Move UI - Azeroth Survivors compatibility build
	Based on MA! 1.12 by Skrag

	Read the ReadMe
]]
function Print(msg, r, g, b, frame)
	if (not r) then r = 1.0; end
	if (not g) then g = 1.0; end
	if (not b) then b = 1.0; end
	if ( frame ) then
		frame:AddMessage(msg,r,g,b);
	else
		if ( DEFAULT_CHAT_FRAME ) then
			DEFAULT_CHAT_FRAME:AddMessage(msg, r, g, b);
		end
	end
end

function table.find( table, value )
	for i, v in table do
		if( v == value ) then
			return i;
		end
	end
	return nil;
end

------------------------------------------------

BINDING_HEADER_MOVEANYTHING = "Move UI";
MA_LEFTARROW = "<";
MA_RIGHTARROW = ">";
CurrentMover = 1;

StaticPopupDialogs["MOVEANYTHING_RESET_CONFIRM"] = {
	text = "Reset all Move UI settings?",
	button1 = TEXT(YES),
	button2 = TEXT(NO),
	OnAccept = function()
		MoveAnythingOptions_ResetAll();
	end,
	timeout = 0,
	exclusive = 1,
	showAlert = 1
};

MOVEANYTHING_MOVEATONETIME = 20;
MOVEANYTHING_SCROLL_HEIGHT = 25;

function MoveAnything_ToggleVisibilityOnFrame(frame)
	if ( not frame ) then return; end

	local opt = MoveAnything_FindFrameOptions(frame:GetName(),"ShowFrame");
	
	if( opt and opt.hidden == true ) then
	
		MoveAnything_ShowFrame(frame)
	else
		MoveAnything_HideFrame(frame)
	
	end

end

-- The old ad-hoc debug commands and MALocator helper were unused by the addon UI.

function MoveAnythingUpdater_OnUpdate(arg1)
	if MoveAnythingUpdater:GetScale() == UIParent:GetScale() then
		MoveAnythingUpdater:SetScale(0.2)
		MoveAnything_RefreshPositions()
	end
end

