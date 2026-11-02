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
See [CHANGELOG.md](CHANGELOG.md) in the repository for the consolidated version history.
