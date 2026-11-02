# Move UI Changelog

Version history for Move UI, the Azeroth Survivors-focused adaptation of MoveAnything.

## 1.3.0 — Modular runtime architecture

- Refactored the monolithic runtime into focused frame-catalog, run-clock, registry, mover, visibility, compatibility-hook, and command modules.
- Separated the Add-on Tools panel, minimap launcher, and standalone-addon bubble integration.
- Preserved legacy XML callbacks, frame identifiers, saved-variable names, slash commands, and the established Move UI behavior.
- Kept Interface 11200 and the legacy Lua 5.0-style runtime compatibility.
- Consolidated the source architecture without intentionally changing user-facing behavior.

## 1.2.9 — Unified Add-on Tools and minimap launcher

- Added a classic, draggable Move UI minimap bubble with a saved position.
- Supports round and square minimap layouts.
- Left-click opens the main Move UI window; right-click opens Add-on Tools.
- Added `/movetools` as a chat-command shortcut.
- Added BigCursor status, enable/disable, and settings controls.
- Added LocalClock Options and Clock Tools shortcuts.
- When Move UI is loaded, its unified launcher hides and disables the standalone BigCursor and LocalClock minimap bubbles.
- BigCursor and LocalClock source files and standalone packages remain unchanged.
- BigCursor remains a utility and is not added to the movable-frame list.
- Preserved the existing mover behavior, alignment grid, run timer, and LocalClock frame/alarm integration.
- Moved the Add-on Tools button into the title area to prevent it from overlapping the Hide column heading.

## 1.2.8 — LocalClock alarm warning mover

- Added `LocalClockAlarmWarning` as a separate managed frame under Center Screen Alerts.
- Position, scale, hide/show, saved settings, and reset now target the actual LocalClock alarm banner.
- The existing Raid Warning mover remains dedicated to the game's native `RaidWarningFrame`.
- No changes to minimap behavior, LocalClock clock positioning, or the run timer / boss countdown implementation.

## 1.2.7 — Raid Warning mover

- Added the game's `RaidWarningFrame` to the managed frame list under Center Screen Alerts.
- Raid Warning uses the standard Move UI move, scale, hide/show, saved-position, and reset controls.
- The setting applies to all messages displayed through the game's Raid Warning frame, including LocalClock alarm warnings.
- No changes to warning-message logic, LocalClock, or the existing run timer / boss countdown implementation.

## 1.2.6 — LocalClock independent positioning and visibility

- Added separate Move UI mover registration for `LocalClockDisplayFrame`.
- Kept its saved offset relative to `MinimapCluster`, allowing it to follow minimap movement while remaining independently positioned.
- Allowed LocalClock to be shown independently when explicitly enabled, even while the minimap is hidden.
- Added visibility handling so temporary minimap suppression does not overwrite LocalClock's own saved Show/Hide preference.
- Preserved minimap-relative scaling while allowing Move UI's size control to apply an additional saved scale multiplier.
- Preserved the run timer / boss countdown implementation from 1.2.5.

## 1.2.5 — LocalClock minimap docking compatibility

- Removed the obsolete standalone `LocalClockFrame` mover entry. LocalClock 1.2.0 docks its additional time-zone display below the native minimap clock; both elements follow `MinimapCluster` as one assembly.
- Removed the old one-time LocalClock position-refresh hook.
- Preserved the tested 1.2.3 run timer / next-boss countdown implementation and its visibility behavior.
- No PaperDoll or unrelated frame behavior changes.

## 1.2.3 — Run Timer / Boss Countdown

- Added a managed Run Timer / Boss Countdown frame.
- Displays elapsed run time and the next scheduled boss/countdown using the documented Azeroth Survivors addon API.
- Uses the standard Move UI mover, saved-position, scale, hide/show, and reset behavior.
- Hides the game's native run-clock / next-boss HUD while the replacement is visible.
- Restores the original native HUD preference when the replacement is hidden or the player logs out.
- Retained Interface 11200 compatibility and Lua 5.0-compatible syntax.

## 1.2.2 — Maintenance cleanup

- Removed unused legacy debug helpers and the unused MALocator debug frame.
- Removed an unused scale helper and an unused local variable.
- No mover, saved-position, reset, or grid behavior was intentionally changed.

## 1.2.1 — Hotfix

- Corrected a Lua long-comment delimiter around `MoveAnything_GetRelativeBottomLeft`.
- Fixed an issue where the remainder of `MoveAnything.lua` could be treated as a comment, preventing updater callbacks from loading.

## 1.2.0 — Main-bar end-cap positioning

- Restored a consistent MainMenuBar-relative positioning path for the left and right main-bar end caps.
- Capture, mover placement, saved coordinates, refresh, and Reset now use the same positioning-parent helper.
- Avoided coordinate-system changes when resetting positions.

## 1.1.9 — Main-bar positioning corrections

- Corrected parent-relative position capture to use the parent/frame scale ratio from the original MoveAnything positioning logic.
- Reverted the unverified MainMenuBar positioning override introduced in 1.1.7.
- Aligned the left and right main-bar end caps in UIParent coordinates for mover placement, saved coordinates, reload placement, and reset; the end caps were not scalable in this build.

## 1.1.1 — Experience bar and end caps

- Restored the Experience Bar entry.
- Added separate Left and Right gargoyle (bar end-cap) entries.

## 1.1.0 — Minimap clock and button mover corrections

- Restored the minimap day/night clock mover using the original MoveAnything frame identifier `GameTimeFrame`.
- Corrected the earlier `MiniMapDayNightFrame` entry, which was not a valid target in the inherited frame list.
- Removed vertical button movers.
- Horizontal spell and character/talent movers now anchor to live game-button positions and restore captured original anchors on reset instead of forcing legacy MainMenuBarArtFrame coordinates.

## 1.0.8-AS — Minimap clock audit

- Restored the MiniMap Day-Night Clock mover entry for further in-game verification. This was subsequently corrected to use `GameTimeFrame` in 1.1.0.

## 1.0.7-AS — Azeroth Survivors frame-list cleanup

- Removed the MiniMap Mail Notification mover because Azeroth Survivors does not use in-game mail.
