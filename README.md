# Move UI

**A lightweight UI mover for Azeroth Survivors.**

Move UI adapts and modernizes the classic MoveAnything interface for Azeroth Survivors. The goal is to make repositioning the game's existing interface simple and reliable while removing legacy World of Warcraft features that the game does not use.

![Move UI in Azeroth Survivors](move-ui-preview.png)

## Project Status

Move UI is an active work in progress. The current build has been tested in Azeroth Survivors, and development is focused on improving compatibility with the game's UI, simplifying the frame list, and preserving the original layout of interface elements.

## Features

- **Frame positioning:** Move supported interface frames using on-screen controls.
- **Frame visibility:** Hide supported frames where applicable.
- **Reset controls:** Reset individual frames or reset supported frame positions.
- **Alignment grid:** Display a full-screen grid to help position interface elements accurately.
- **FPS display:** Keep the FPS display available for monitoring performance.
- **Simplified interface:** Remove obsolete menu entries for systems that Azeroth Survivors does not use.
- **Move complete UI assemblies:** Prefer moving an entire interface assembly instead of exposing its individual buttons as separate movers.

## Design Goals

Move UI is designed specifically around Azeroth Survivors rather than attempting to reproduce every feature of the original World of Warcraft addon.

Our priorities are:

- Preserve the game's existing UI layout and the relationships between its components.
- Make moving interface elements straightforward without unnecessarily exposing individual buttons and subcomponents.
- Remove obsolete or unsupported WoW-specific options.
- Keep useful functionality while introducing game-specific improvements where appropriate.
- Maintain compatibility with the game's actual UI API and frame behavior.

## Installation

1. Download or clone this repository.
2. Locate the `MoveUI` addon folder.
3. Copy the `MoveUI` folder into Azeroth Survivors' `Interface/AddOns` directory.
4. Confirm that `MoveUI.toc` is directly inside the `MoveUI` folder.
5. Launch the game and enter `/move` to open the Move UI options window.

The final directory structure should look like this:

```text
Interface/
└── AddOns/
    └── MoveUI/
        ├── MoveUI.toc
        ├── MoveAnything.lua
        ├── MoveAnything.xml
        ├── MoveAnythingGrid.lua
        └── MAPredefinedFrames.lua
```

## Known Issues

Move UI is still being adapted to Azeroth Survivors' interface. Current areas for improvement include:

- **Frame layering:** Some character and enemy frames can appear underneath the alignment grid.
- **Toolbar alignment:** Reset positions and default toolbar geometry need further verification against Azeroth Survivors' original UI.
- **Frame compatibility:** Some legacy frame entries may require additional auditing.
- **Future clock feature:** A clock using the game's supported time functions may be explored in a future update. A clock is not currently implemented as a Move UI feature.

These issues are being tracked as development continues.

## Development

Move UI is being developed incrementally, with changes tested against the actual game wherever possible.

Legacy internal identifiers may be retained when changing them could break compatibility. User-facing labels, obsolete menu entries, and documentation are cleaned up separately to reduce unnecessary risk.

Bug reports are most useful when they include:

- The frame or feature involved.
- The steps taken to reproduce the issue.
- What happened versus what was expected.
- A screenshot, when applicable.

## Credits and Acknowledgments

**Move UI is an adaptation of the original MoveAnything addon for World of Warcraft.**

The original MoveAnything project provided the foundation for moving and managing interface frames. We acknowledge and appreciate the work of its original authors and contributors.

Move UI builds upon that foundation with changes tailored to **Azeroth Survivors**, including interface cleanup, compatibility adjustments, an alignment grid, and the removal of legacy options that do not apply to the game.

This project is independently adapted for Azeroth Survivors. It is not an official release of the original MoveAnything project and is not affiliated with its original developers.

**Credit belongs to the original authors for the work that made this adaptation possible.** Original copyright notices, attribution, and applicable license terms must be retained and respected. 

**Move UI — a modernized, Azeroth Survivors-focused adaptation of MoveAnything.**


**Attribution and Redistribution Notice**

This project is based on the original MoveAnything addon and has been adapted and modified by Jamie Lee for use with Azeroth Survivors.

Reproduction, redistribution, or incorporation of this addon into other Azeroth Survivors addons or projects must include appropriate credit to both Jamie Lee (Move UI) and the original MoveAnything project and its authors. Please do not use or redistribute this work without preserving the applicable attributions.