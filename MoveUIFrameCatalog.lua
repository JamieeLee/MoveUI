-- Move UI frame catalog and runtime state
-- Default frame definitions, visibility rules, and shared saved-state tables.
-- Extracted from the tested 1.2.9 runtime; behavior intentionally preserved.

MoveAnything_Frames = {};
MoveAnything_CustomFrames = {};
MoveAnything_CharacterSettings = {};
MoveAnything_UseCharacterSettings = false;
MoveAnything_InitRun = false;
MoveAnything_FrameOptions = nil;

MoveAnything_NoScale = { TooltipMover = true, FramerateMover = true };
MoveAnything_ScaleWH = { MainMenuExpBar = true };
-- Keep the two gargoyles on the MainMenuBar-relative path. Their visible
-- artwork is laid out against MainMenuBar in Azeroth Survivors.
MoveAnything_DetachFromParent = { MainMenuBarPerformanceBarFrame = true };
MoveAnything_NoHide = { MAOptions = true };
MoveAnything_HideList = {};
MoveAnything_HideList["MainMenuBar"] = {
	{ "MainMenuBarArtFrame", "BACKGROUND","ARTWORK"},
	{ "PetActionBarFrame", "OVERLAY"},
	{ "ShapeshiftBarFrame", "OVERLAY"},
	{ "MainMenuBar", "DISABLEMOUSE"},
	{ "BonusActionBarFrame", "OVERLAY", "DISABLEMOUSE"},
};
MoveAnything_HideList["MainMenuExpBar"] = {
	{ "MainMenuExpBar", "WH", "BORDER", "OVERLAY"},
	{ "ExhaustionTick", "FRAME"},
	{ "MainMenuExpBar", function( show )
							if( show ) then
								MoveAnything_AllowExternalVisibility( MainMenuExpBar.TextString );
							else
								MoveAnything_PreventExternalVisibility( MainMenuExpBar.TextString );
							end
						end},
};

MoveAnything_HideUsingWH = { MainMenuExpBar = true };

MoveAnything_MoveOnlyWhenVisible = {};
MoveAnything_MoveOnlyWhenVisible["GroupLootFrame1"] = true;
MoveAnything_MoveOnlyWhenVisible["GroupLootFrame2"] = true;
MoveAnything_MoveOnlyWhenVisible["GroupLootFrame3"] = true;
MoveAnything_MoveOnlyWhenVisible["GroupLootFrame4"] = true;

MoveAnything_DefaultFrameList = {

	{ "MAOptions", "Move UI Options Window" },

	{ "Separator", "**** Standard Party Frames ****" },
	{ "PlayerFrame", "Player" },
	{ "TargetFrame", "Target" },
	{ "PartyMemberFrame1", "Party Member 1" },
	{ "PartyMemberFrame2", "Party Member 2" },
	{ "PartyMemberFrame3", "Party Member 3" },
	{ "PartyMemberFrame4", "Party Member 4" },

	{ "Separator", "**** Pets ****" },
	{ "PetFrame", "Pet" },
	{ "PartyMemberFrame1PetFrame", "Party Pet 1" },
	{ "PartyMemberFrame2PetFrame", "Party Pet 2" },
	{ "PartyMemberFrame3PetFrame", "Party Pet 3" },
	{ "PartyMemberFrame4PetFrame", "Party Pet 4" },

	{ "Separator", "**** Bags ****" },
	{ "BagFrame1", "Bag 1 (Backpack)" },

	{ "Separator", "**** Bottom Bar ****" },
	{ "MainMenuBar", "Main bar (whole)" },
	{ "MainMenuExpBar", "Experience bar" },
	{ "MainMenuBarLeftEndCap", "Left gargoyle" },
	{ "MainMenuBarRightEndCap", "Right gargoyle" },
	-- MainMenuBarArtFrame intentionally omitted: moving this stock artwork freezes Azeroth Survivors.
	{ "BasicActionButtonsMover", "Spell buttons" },
	{ "MoveUIRunClockFrame", "Run Timer / Boss Countdown" },
	{ "MicroButtonsMover", "Character and talent buttons" },

	{ "Separator", "**** Minimap ****" },
	{ "MinimapCluster", "MiniMap" },
	{ "MinimapZoneTextButton", "MiniMap Zone Text" },
	{ "MinimapZoomIn", "MiniMap Zoom In Button" },
	{ "MinimapZoomOut", "MiniMap Zoom Out Button" },
	{ "MiniMapTrackingFrame", "MiniMap Tracking" },
	{ "GameTimeFrame", "MiniMap Day-Night Clock" },

	{ "Separator", "**** Center Screen Alerts ****" },
	{ "RaidWarningFrame", "Raid Warning" },
	{ "LocalClockAlarmWarning", "LocalClock Alarm Warning" },

	{ "Separator", "**** Miscellaneous Screen Items ****" },
	{ "StaticPopup1", "Static Popup Frame" },
	{ "UIErrorsFrame", "UI Errors Frame" },
	{ "CastingBarFrame", "Casting Bar" },
	{ "BuffFrame", "Buff Window" },
	{ "TemporaryEnchantFrame", "Item buff/Debuff Windows" },
	{ "TooltipMover", "Tooltip" },
	{ "FramerateMover", "Move FPS" },
	{ "QuestWatchFrame", "Quest Tracker" },
	{ "QuestTimerFrame", "Quest Timer" },
	{ "ComboFrame", "Rogue Combo point counter" },
	{ "MirrorTimer1", "Breath/Fatigue Bar" },

	{ "Separator", "**** General Info Panel Placement ****" },
	{ "UIPanelMover1", "Info Panel 1" },
	{ "UIPanelMover2", "Info Panel 2" },

	{ "Separator", "**** Specific Info Panels ****" },
	{ "CharacterFrame", "Character / Pet / Reputation / Skills" },
	{ "InspectFrame", "Inspect View" },
	{ "LootFrame", "Looting Window" },
	{ "QuestLogFrame", "Quest Log" },
	{ "FriendsFrame", "Friends / Who / Guild / Raid" },
}
