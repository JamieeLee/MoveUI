MOVE UI — AZEROTH SURVIVORS
Build 1.0.3

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
- The full-screen blue alignment grid is included. Use /movegrid to toggle it independently.
- Close should close the options window and end active mover overlays.

CURRENT FRAME-LIST APPROACH
- Bottom Bar is the single mover for the main toolbar assembly; individual action-button movers are intentionally omitted.
- Experience Bar and Max Level Bar remain separate entries.
- Move FPS is retained. It is distinct from the removed legacy lag-meter entry.
- Quest Log remains listed for now. A future run-quest timer/tracker would be a separate Azeroth Survivors feature, not a replacement for the game's quest log.
- WoW-only entries that do not apply to Azeroth Survivors have been removed from the visible frame list, including bank UI, auction house, macros, mailbox, battleground flags, trade window, merchant inventory, flight paths, trade skills, spell book, talent tree, pet stable, dice-roll frames, meeting stone, and nonexistent action bars.
- The MiniMap Day-Night Clock entry is not listed because that frame does not currently exist in the game. A real-world clock based on the client-supported time API is a possible future feature and is not implemented in this build.

KNOWN LIMITATIONS / TESTING
- This build has not been runtime-tested inside Azeroth Survivors. Confirm that the addon loads and test the grid/menu layering in-game.
- Toolbar alignment and reset behavior are still under investigation. Reset behavior may need Azeroth Survivors-specific default anchors rather than legacy WoW assumptions.
- The grid is set to LOW frame strata so the options window and UI controls should render above it. If the game uses unusual strata, the visual order may need adjustment after in-game testing.
- The MainMenuBarArtFrame mover remains omitted because moving that stock artwork previously caused a freeze/white screen.
- Internal legacy frame/function identifiers are retained for compatibility. Only user-facing diagnostic display names are translated to Move UI wording.

This build preserves the existing working full-screen grid geometry and spacing. No claim is made that all listed frame moves or resets have been verified in the game runtime.
