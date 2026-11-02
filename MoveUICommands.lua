-- Move UI slash commands and menu integration
-- Slash command handlers and legacy game-menu insertion callback.
-- Extracted from the tested 1.2.9 runtime; behavior intentionally preserved.

local function Error(msg)
    Print(msg, 1.0, 0.2, 0.2)
end

SLASH_MOVEANYTHING1 = "/move"
SlashCmdList["MOVEANYTHING"] = function( msg )
	if( msg == nil or string.len( msg ) == 0 ) then
		MoveAnything_ToggleOptionsMenu();
	else
		MoveAnything_ToggleMove( msg );
	end
end

SLASH_UNMOVEANYTHING1 = "/unmove"
SlashCmdList["UNMOVEANYTHING"] = function( msg )
	if( msg ) then
		MoveAnything_StopMoving( msg );
		local frame = getglobal( msg );
		MoveAnything_AllowExternalMovement( frame );
		frame:ClearAllPoints();
		frame:SetPoint( "CENTER", MAGetParent( frame ):GetName(), "CENTER", 0, 0 );
	end
end

SLASH_MOVEANYTHINGCOPYSETTINGS1 = "/movecopy"
SlashCmdList["MOVEANYTHINGCOPYSETTINGS"] = function( msg )
	if( msg == nil or string.len( msg ) == 0 ) then
		Error( "Syntax: /movecopy ServerName PlayerName" );
		Error( "Use /movelist to see a current list of valid settings" );
		return;
	end

	if( MoveAnything_CharacterSettings[msg] == nil ) then
		Error( "No settings for server/character "..msg );
		Error( "Use /movelist to see a current list of valid settings" );
		return;
	end

	MoveAnything_CopySettings( msg, MoveAnything_CurrentSettingsName() );
end

SLASH_MOVEANYTHINGLISTSETTINGS1 = "/movelist"
SlashCmdList["MOVEANYTHINGLISTSETTINGS"] = function( msg )
	Print( "Server/Character Settings List:", 1.0, 1.0, 0.2 );
	Print( "-------------------------------", 1.0, 1.0, 0.2 );
	for i, val in MoveAnything_CharacterSettings do
		local str = i;
		if( val == MoveAnything_FrameOptions ) then
			str = str.." (Current)";
		end
		Print( str, 1.0, 1.0, 0.2 );
	end
end

SLASH_MOVEANYTHINGDELETESETTINGS1 = "/movedelete"
SLASH_MOVEANYTHINGDELETESETTINGS2 = "/movedel"
SlashCmdList["MOVEANYTHINGDELETESETTINGS"] = function( msg )
	if( msg == nil or string.len( msg ) == 0 ) then
		Error( "Syntax: /movedelete ServerName PlayerName" );
		Error( "Use /movelist to see a current list of valid settings" );
		return;
	end

	if( MoveAnything_CharacterSettings[msg] == nil ) then
		Error( "No settings for server/character "..msg );
		Error( "Use /movelist to see a current list of valid settings" );
		return;
	end

	if( msg == MoveAnything_CurrentSettingsName() ) then
		MoveAnythingOptions_ResetAll();
	else
		MoveAnything_CharacterSettings[msg] = nil;
	end
	MoveAnything_FrameOptions = MoveAnything_CharacterSettings[MoveAnything_CurrentSettingsName()];
	MoveAnything_RefreshPositions();
end

function GameMenu_AddButton( button )
	if( GameMenu_InsertAfter == nil ) then
		GameMenu_InsertAfter = GameMenuButtonMacros;
	end
	if( GameMenu_InsertBefore == nil ) then
		GameMenu_InsertBefore = GameMenuButtonLogout;
	end

	button:ClearAllPoints();
	button:SetPoint( "TOP", GameMenu_InsertAfter:GetName(), "BOTTOM", 0, -1 );
	GameMenu_InsertBefore:SetPoint( "TOP", button:GetName(), "BOTTOM", 0, -1 );
	GameMenu_InsertAfter = button;
	GameMenuFrame:SetHeight( GameMenuFrame:GetHeight() + button:GetHeight() + 2 );
end

if ( GameMenuButtonAddOns ) then
	GameMenu_AddButton(GameMenuButtonAddOns);
end
