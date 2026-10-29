Move UI 1.1.3

Fix: guard GetFrameLevel during mover attachment. Some Azeroth Survivors UI objects do not expose this method; the mover now follows the original MoveAnything compatibility check instead of throwing an error.

MOVE UI — AZEROTH SURVIVORS
Build 1.0.8

OVERVIEW
Move UI is a lightweight frame-positioning tool adapted from the legacy MoveAnything addon for the WoW-client-derived UI used by Azeroth Survivors. It keeps the game's existing UI intact and focuses on moving supported frames rather than rebuilding individual buttons.

INSTALLATION
1. Close Azeroth Survivors.
2. Back up or remove the previous MoveUI addon folder.
3. Extract this archive so the files are inside AddOns/MoveUI/ (the folder must contain MoveUI.toc).
4. Launch the game and enable Move UI if the addon list requires it.

BASIC USE
- Type /move to open or toggle the Move UI controls.
- Select a listed frame to move it. Use the available reset controls to restore its saved/default positioning where supported.
- The frame list keeps Bag 1, but removes redundant bag-button controls and Bag 2–5 entries. Durability/damage/portrait combined entry is removed.
- The full-screen blue alignment grid is included, with 32-unit spacing. Use /movegrid to toggle it independently.
- Close should close the options window and end active mover overlays.

CURRENT FRAME-LIST APPROACH
- Bottom Bar is the single mover for the main toolbar assembly; individual action-button movers are intentionally omitted.
- Experience Bar and Max Level Bar are omitted as individual movers; the intent is to manage the bottom-bar assembly as a frame.
- Move FPS is retained. It is distinct from the removed legacy lag-meter entry.
- Local Clock is listed as a managed frame when the separate LocalClock addon is installed. Move UI reapplies saved frame positions after login so the clock addon’s startup placement does not overwrite a Move UI layout.
- Quest Log remains listed for now. A future run-quest timer/tracker would be a separate Azeroth Survivors feature, not a replacement for the game's quest log.
- WoW-only entries that do not apply to Azeroth Survivors have been removed from the visible frame list, including bank UI, auction house, macros, mailbox, battleground flags, trade window, merchant inventory, flight paths, trade skills, spell book, talent tree, pet stable, dice-roll frames, meeting stone, and nonexistent action bars.
- MiniMap Day-Night Clock is listed as its own mover (`MiniMapDayNightFrame`) alongside the minimap and tracking controls. If the client exposes this legacy frame, it can be moved independently; if it does not exist in the current build, the entry may be unavailable. The separate LocalClock addon remains supported as a movable frame.

KNOWN LIMITATIONS / TESTING
- This build has not been runtime-tested inside Azeroth Survivors. Confirm that the addon loads, test grid/menu layering, and verify that LocalClock movement persists across a restart.
- Added separate horizontal/vertical movers for spell buttons and character/talent buttons while preserving the whole main-bar mover. Reset safety now avoids nil saved-scale errors; in-game reset positions still require runtime verification.
- The grid is set to LOW frame strata so the options window and UI controls should render above it. If the game uses unusual strata, the visual order may need adjustment after in-game testing.
- The MainMenuBarArtFrame mover remains omitted because moving that stock artwork previously caused a freeze/white screen.
- Internal legacy frame/function identifiers are retained for compatibility. Only user-facing diagnostic display names are translated to Move UI wording.

This build preserves the full-screen grid layout and uses 32-unit spacing. No claim is made that all listed frame moves or resets have been verified in the game runtime.


Build 1.0.7-AS audit note:
- Removed the MiniMap Mail Notification mover because Azeroth Survivors does not use in-game mail.


Build 1.0.8-AS audit note:
- Restored the MiniMap Day-Night Clock mover entry as requested. The frame name is based on the legacy client convention and still needs in-game confirmation in Azeroth Survivors.


Version 1.1.0: Restored the minimap day/night clock mover using the original MoveAnything frame identifier GameTimeFrame. The prior MiniMapDayNightFrame entry was not a valid target in the inherited frame list.


1.1.0: Removed vertical button movers. Horizontal spell and character/talent movers now anchor to the live game button position and restore captured original anchors on reset instead of forcing legacy MainMenuBarArtFrame coordinates.


Version 1.1.1
- Restored the Experience bar entry.
- Added separate Left and Right gargoyle (bar end-cap) entries.


Build 1.1.9: Corrected parent-relative position capture to use the parent/frame scale ratio from the original MoveAnything positioning logic. Reverted the unverified MainMenuBar positioning override introduced in 1.1.7.


Build 1.1.9: Position the left and right main-bar end caps in UIParent coordinates, matching the detached-frame path for mover placement, saved coordinates, reload placement, and reset. Prevent scaling these decorative end caps.


Build 1.2.0: restored the consistent MainMenuBar-relative positioning path for both end caps. Capture, mover placement, saved coordinates, refresh, and Reset now use the same positioning-parent helper. The end caps are no longer treated as detached UIParent frames, avoiding coordinate-system changes when resetting positions.


Build 1.2.1 hotfix: corrected a Lua long-comment delimiter around MoveAnything_GetRelativeBottomLeft. In 1.2.0, this caused the remainder of MoveAnything.lua to be treated as a comment, preventing updater callbacks from loading.


Version 1.2.2 maintenance cleanup:
- Removed unused legacy debug helpers and the unused MALocator debug frame.
- Removed an unused scale helper and an unused local variable.
- No mover, saved-position, reset, or grid behavior was intentionally changed.
