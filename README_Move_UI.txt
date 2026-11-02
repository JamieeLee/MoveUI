MOVE UI — AZEROTH SURVIVORS
Build 1.2.9

OVERVIEW
Move UI is a lightweight frame-positioning tool adapted from the legacy MoveAnything addon for the WoW-client-derived UI used by Azeroth Survivors. It keeps the game's existing UI intact and focuses on moving supported frames and complete UI assemblies.

INSTALLATION
1. Close Azeroth Survivors.
2. Back up or remove the previous MoveUI addon folder.
3. Extract this archive so the files are inside AddOns/MoveUI/ (the folder must contain MoveUI.toc).
4. Launch the game and enable Move UI if the addon list requires it.

BASIC USE
- Type /move to open or toggle the Move UI controls.
- Under Center Screen Alerts, select Raid Warning to move, scale, hide/show, or reset the game's native raid-warning display.
- Select LocalClock Alarm Warning to move, scale, hide/show, or reset the dedicated LocalClock alarm banner. This is the frame that displays LocalClock's "YOUR TIME IS UP!" alert.
- Select a listed frame to move it. Use the available reset controls to restore its saved/default positioning where supported.
- Use the standard Hide checkbox to show or hide supported frames.
- Resize supported frames with the mover's resize handles. Saved scale is restored after reload.
- The full-screen blue alignment grid is included, with 32-unit spacing. Use /movegrid to toggle it independently.
- Close should close the options window and end active mover overlays.

NEW IN 1.2.3 — RUN TIMER / BOSS COUNTDOWN
- Added a managed frame named "Run Timer / Boss Countdown".
- The frame displays the current run elapsed time and the next scheduled boss name/countdown.
- It reads the documented Azeroth Survivors addon API: AZS_GetPhase(), AZS_GetRunTime(), and AZS_GetUpcomingBosses().
- The game's built-in run-clock / next-boss HUD is suppressed while the Move UI replacement frame is visible.
- Hiding the replacement through Move UI restores the game's original run-clock HUD preference. Showing the replacement suppresses the native HUD again.
- Position, scale, hide/show state, and reset behavior use the existing Move UI managed-frame system.
- The original native HUD preference is restored when the replacement is hidden and on logout.
- This is the gameplay run timer and next-boss countdown. It is not the separate LocalClock real-world time addon or the minimap day/night clock.

CURRENT FRAME-LIST APPROACH
- Bottom Bar is the single mover for the main toolbar assembly; individual action-button movers are intentionally omitted.
- Experience Bar is retained as an individual mover, along with separate Left and Right gargoyle (bar end-cap) entries.
- Spell buttons and Character/Talent buttons are managed as horizontal assemblies rather than individual buttons.
- Run Timer / Boss Countdown is a single managed frame assembly. Move UI creates its own replacement frame using the game's published run-time and upcoming-boss APIs, then hides the native run-clock HUD only while the replacement is shown.
- Move FPS is retained. It is distinct from the removed legacy lag-meter entry.
- LocalClock 1.2.1 registers `LocalClockDisplayFrame` as its own `Local Clock (Time Zone)` mover. Its saved position is expressed relative to MinimapCluster, so it follows minimap movement while remaining independently movable.
- The native-clock surround remains attached to MinimapCluster and is not controlled by LocalClock's Hide checkbox. Hiding the minimap hides the native surround and suppresses LocalClock; LocalClock can be explicitly shown by its own Move UI Show checkbox while the minimap remains hidden.
- LocalClock's own Hide checkbox affects only the additional time-zone display. When the minimap is hidden, the same checkbox shows the temporary "hidden with minimap" state; unchecking it allows LocalClock to appear independently while the minimap stays hidden.
- The temporary minimap-suppression state does not overwrite LocalClock's saved Show/Hide preference and is recalculated on login. Hiding LocalClock itself remains independent: it stays hidden when the minimap is shown again.
- Quest Log remains listed for now. A future run-quest timer/tracker would be a separate Azeroth Survivors feature, not a replacement for the game's quest log.
- WoW-only entries that do not apply to Azeroth Survivors have been removed from the visible frame list, including bank UI, auction house, macros, mailbox, battleground flags, trade window, merchant inventory, flight paths, trade skills, spell book, talent tree, pet stable, dice-roll frames, meeting stone, and nonexistent action bars.
- MiniMap Day-Night Clock remains listed separately as GameTimeFrame where the client exposes it. It is not the run timer / next-boss countdown, and it is not LocalClock.

KNOWN LIMITATIONS / TESTING
- The existing Run Timer / Boss Countdown implementation from 1.2.3 is preserved unchanged in this build.
- Confirm that Move, Hide, Reset, and resize all work for the new managed frame, and that hiding it restores the original native HUD clock preference.
- Confirm LocalClock's Hide checkbox distinguishes its own hidden preference from temporary minimap suppression, including showing LocalClock alone while the minimap remains hidden.
- Some character or enemy frames may render underneath the alignment grid.
- Toolbar alignment and reset positions need continued testing against Azeroth Survivors' actual default UI.
- The grid is set to LOW frame strata so the options window and UI controls should render above it. If the game uses unusual strata, the visual order may need adjustment after in-game testing.
- The MainMenuBarArtFrame mover remains omitted because moving that stock artwork previously caused a freeze/white screen.
- Internal legacy frame/function identifiers are retained for compatibility. Only user-facing diagnostic display names are translated to Move UI wording.
- Not every listed frame move or reset has been fully verified in the game runtime.

This build preserves the full-screen grid layout and uses 32-unit spacing. The LocalClock independent-mover integration does not modify the run timer / boss countdown implementation. No claim is made that all listed frame moves or resets have been verified in the game runtime.

RELEASE HISTORY
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


Version 1.2.5 - LocalClock minimap docking compatibility
- Removed the obsolete standalone LocalClockFrame mover entry. LocalClock 1.2.0 docks its second time-zone clock below the native minimap clock; the clock border and additional clock follow the MinimapCluster as one assembly.
- Removed the old one-time LocalClockFrame position-refresh hook.
- Preserved the tested 1.2.3 run timer / next-boss countdown implementation and visibility behavior unchanged.
- No PaperDoll or unrelated frame behavior changes.


Version 1.2.6 - LocalClock independent minimap-relative positioning and visibility
- Added Move UI coordinate-parent support for LocalClockDisplayFrame so its position is saved relative to MinimapCluster despite being independently parented for visibility.
- Added independent LocalClock mover registration through the LocalClock addon.
- Added callbacks for LocalClock visibility and MinimapCluster visibility changes.
- Preserved LocalClock's minimap-relative scale while allowing Move UI's size control to apply a saved additional scale multiplier.
- Preserved the run timer / boss countdown implementation from 1.2.5 unchanged.


Version 1.2.7 - Raid Warning mover
- Added RaidWarningFrame under Center Screen Alerts as a standard managed frame.
- Move, scale, hide/show, saved position, and reset use the existing Move UI behavior.
- Scaling the shared Raid Warning frame affects all raid-warning messages, not only LocalClock alarms.
- No changes to LocalClock or the existing Run Timer / Boss Countdown code.


1.2.8: Added the LocalClock Alarm Warning mover. Install LocalClock 1.3.2 or newer to provide the named frame. The regular Raid Warning mover still controls native RaidWarningFrame messages.


ADD-ON TOOLS / MINIMAP BUBBLE TEST — 1.2.8-Tools-Test2
- Adds one Move UI minimap bubble with the same classic tracking-ring appearance and angle-based drag behavior used by BigCursor and LocalClock.
- The Move UI bubble can be dragged around round or square minimaps. Its angle is saved in MoveUIDB and restored on reload.
- Left-click the Move UI bubble to open the main Move UI options window.
- Right-click the Move UI bubble to open the Add-on Tools panel.
- /movetools is a chat-command fallback for Add-on Tools.
- Add-on Tools exposes BigCursor enable/disable/settings and LocalClock Options/Clock Tools.
- When Move UI is loaded, its combined panel replaces the standalone BigCursor and LocalClock minimap bubbles. Move UI hides and disables those two bubble frames at runtime; it does not modify either addon's files or standalone package.
- The LocalClock display, native clock surround, alarm warning frame, and existing managed-frame integration remain separate and unchanged.
- BigCursor remains a cursor utility and is not added to the movable-frame list.
- This is a test build intended for in-game verification.