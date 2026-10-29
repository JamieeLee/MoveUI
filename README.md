# Move UI

**A lightweight UI mover for Azeroth Survivors.**

Move UI adapts the classic MoveAnything-style interface for Azeroth Survivors, focusing on moving supported interface frames while removing obsolete World of Warcraft features that the game does not use.

![Move UI in Azeroth Survivors](assets/move-ui-preview.jpg)

## Current status

This is an early, in-progress build. It has been tested in-game, but not every frame or reset behavior has been fully verified.

### Current features

- Move supported UI frames using on-screen mover controls.
- Hide supported frames where applicable.
- Reset individual frames or reset all supported frame positions.
- Display a full-screen alignment grid while arranging the interface.
- Display an FPS readout.
- Use a cleaned-up Move UI options window.

### Design goals

- Move whole UI assemblies where possible instead of exposing every button as a separate mover.
- Keep the existing game UI's internal layout intact.
- Remove menu entries for WoW systems that Azeroth Survivors does not provide.
- Keep useful existing features and add game-specific features only when they are verified.

## Installation

1. Download or clone this repository.
2. Copy the `MoveUI` addon folder into Azeroth Survivors' `Interface/AddOns` directory.
3. Make sure `MoveUI.toc` is directly inside the `MoveUI` folder.
4. Launch the game and enter `/move` to open the Move UI menu.

## Known issues

- Some character or enemy frames may render underneath the alignment grid.
- Toolbar alignment and reset positions need further testing against Azeroth Survivors' actual default UI.
- The real-world clock is a possible future feature; it is not currently implemented.
- Not every legacy frame entry has been fully audited yet.

## Development

The project is being adapted incrementally. Internal legacy identifiers are being preserved where changing them could break compatibility; visible labels and obsolete menu entries are being cleaned up separately.

Please report reproducible issues with the frame name, what action you took, and what happened.

## Credits and licensing

Move UI is derived from the legacy MoveAnything addon. Original authorship, attribution, and license requirements must be preserved in accordance with the original project's license. The repository's license status should be confirmed before redistribution.
