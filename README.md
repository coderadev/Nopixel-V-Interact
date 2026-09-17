
A **NoPixel V inspired** world interaction system for FiveM.

Walk up to something, look at it, press **E**. No third-eye menus, no clutter – just the same minimal in-world prompts you've seen on NoPixel V.

**Author:** codera

---

## Features

- **Ring dots** on every nearby interaction point, so players can see everything they can interact with.
- **Crosshair hover** – a small centre-screen dot picks the in-range point closest to it. Move the camera to switch between points.
- **`[E] LABEL` prompt** in a condensed italic HUD font, drawn in-game (no NUI) so it stays locked to the world with no lag.
- **Multiple options per point** – scroll with the arrow keys or mouse wheel; the selected option carries the key badge.
- **`canInteract` filtering** – options that fail their check are hidden; points with nothing to show disappear.
- Coords, local entities, networked entities, entity bones and model-wide interactions.
- Auto-disables on death, NUI focus, in vehicles and while cuffed (configurable).
- Lightweight: ~44 KB of assets downloaded once, zero server-side work, a few sprite draws per frame.

## Installation

1. Place the folder in your resources directory and **name it `interact`** (the folder name is the resource name used by exports).
2. Make sure [ox_lib](https://github.com/overextended/ox_lib) starts first.
3. Add to your `server.cfg`:
   ```cfg
   ensure ox_lib
   ensure interact
   ```

## Controls

| Key | Action |
| --- | --- |
| Camera / mouse | Hover the crosshair over a point |
| `E` | Use the selected option |
| `↑` / `↓` or mouse wheel | Change option when a point has several |

## How distances work

| Field | Meaning | Default |
| --- | --- | --- |
| `distance` | How close the player must be for the **dot** to appear | `8.0` (`10.0` for networked entities / bones) |
| `interactDst` | How close the player must be for the **prompt** to appear and `E` to work | `1.0` |
| `offset` | `vec3` offset from the entity the point is placed at | `vec3(0, 0, 0)` |

---

## Options

Every export takes an `options` list. Each option supports:

```lua
{
    name = 'my:option',       -- optional, used by RemoveInteractionOption and to replace an existing option
    label = 'Pickup Hot Dog - $25',
    canInteract = function(entity, coords, args)
        return true           -- return false to hide this option
    end,

    -- Pick ONE of the following (checked in this order):
    action = function(entity, coords, args) end,
    serverEvent = 'my:server:event', -- TriggerServerEvent(serverEvent, args)
    event = 'my:client:event',       -- TriggerEvent(event, option)

    args = { any = 'data' },
}
```

## Exports

All `Add*` exports take a single table. Since the resource name has no hyphen, you can call exports either as `exports.interact` or `exports['interact']`.

### AddInteraction

Adds a point at fixed coords. Returns the interaction id.

```lua
local id = exports.interact:AddInteraction({
    coords = vec3(55.869, -1545.9351, 29.8501),
    distance = 2.0,
    interactDst = 1.0,
    name = 'laundromat_hack',
    options = {
        {
            label = 'Hack Security',
            event = 'sizan-robbery:client:UseBlueLaptop',
            canInteract = function()
                return true
            end,
        },
    },
})
```

### AddLocalEntityInteraction

Adds a point on a client-side (non-networked) entity. Returns the interaction id.

```lua
local id = exports.interact:AddLocalEntityInteraction({
    entity = ped,
    offset = vec3(0.0, 0.0, 0.3),
    distance = 4.0,
    interactDst = 1.5,
    options = {
        {
            label = 'Talk',
            action = function(entity)
                print(('Talking to %s'):format(entity))
            end,
        },
    },
})
```

### AddEntityInteraction

Adds a point on a networked entity. `netId` accepts a network id or an entity handle; non-networked entities fall back to `AddLocalEntityInteraction`. Returns the interaction id.

```lua
local id = exports.interact:AddEntityInteraction({
    netId = NetworkGetNetworkIdFromEntity(vehicle),
    distance = 5.0,
    interactDst = 1.5,
    options = {
        { label = 'Search Vehicle', serverEvent = 'my:server:searchVehicle' },
    },
})
```

### AddEntityBoneInteraction

Adds a point on an entity bone.

```lua
exports.interact:AddEntityBoneInteraction({
    entity = vehicle,
    bone = 'boot',
    distance = 3.0,
    interactDst = 1.5,
    options = {
        { label = 'Open Trunk', action = function(entity) SetVehicleDoorOpen(entity, 5, false, false) end },
    },
})
```

### AddModelInteraction

Adds a point to every spawned object of the given models.

```lua
exports.interact:AddModelInteraction({
    modelData = {
        { model = 'p_dumpster_t', offset = vec3(0.0, 0.0, 1.0) },
        { model = 'prop_dumpster_02a', offset = vec3(0.0, 0.0, 1.0) },
    },
    distance = 8.0,
    interactDst = 1.0,
    options = {
        {
            label = 'Search Trash',
            action = function(entity, coords, args)
                SearchTrash(entity)
            end,
        },
    },
})
```

### Removing and updating

```lua
exports.interact:RemoveInteraction(id)                  -- remove by id
exports.interact:RemoveInteractionByEntity(entity)      -- remove everything on an entity
exports.interact:RemoveInteractionOption(id, 'my:option') -- remove a single named option
exports.interact:UpdateInteraction(id, newOptions)      -- replace the options list
```

Interactions are removed automatically when the resource that created them stops.

### Disable

```lua
exports.interact:Disable(true)  -- hide and block all interactions
exports.interact:Disable(false)
```

---

## Configuration

Everything lives in [`config/settings.lua`](config/settings.lua).

### Prompt

Sizes are fractions of screen height – divide the pixel size you want at 1080p by 1080.

| Setting | Default | Description |
| --- | --- | --- |
| `key` | `'E'` | Letter shown in the key badge |
| `uppercase` | `true` | Render labels in uppercase |
| `textHeight` | `0.0125` | Label cap height (~13px) |
| `keySize` | `0.0167` | Key badge size (~18px) |
| `keyTextHeight` | `0.0095` | Letter size inside the badge |
| `keyGap` | `0.0075` | Space between badge and label |
| `dotSize` | `0.0155` | Interaction dot size (~16px) |
| `crosshairSize` | `0.0055` | Crosshair dot size |
| `crosshair` | `true` | Show the crosshair while points are nearby |
| `hoverRadius` | `0.06` | How close the crosshair must be to a point to select it |
| `rowSpacing` | `0.024` | Spacing between options on the same point |
| `textColor` / `keyColor` / `keyTextColor` | white / white / near-black | RGBA colours |
| `dimmedAlpha` | `140` | Opacity of non-selected options |
| `shadowAlpha` | `110` | Label drop shadow strength (`0` to disable) |

### Disable

| Setting | Default | Description |
| --- | --- | --- |
| `onDeath` | `true` | Disable while dead |
| `onNuiFocus` | `true` | Disable while NUI has focus |
| `onVehicle` | `true` | Disable while in a vehicle |
| `onHandCuff` | `true` | Disable while cuffed |

---

## Project structure

```
interact/
├── fxmanifest.lua
├── config/
│   ├── settings.lua      -- settings and default values
│   └── logger.lua         -- debug/error logging helper
├── client/
│   ├── api.lua             -- core logic + exports
│   ├── renderer.lua        -- main render loop and input handling
│   ├── helpers.lua         -- helper functions, text/sprite drawing
│   ├── glyphs.lua          -- font metadata
│   ├── sprites.lua         -- builds the runtime texture dictionary
│   └── scanner.lua         -- raycasts the entity in front of the player
├── server/
│   └── main.lua
├── integrations/           -- framework compatibility (ESX / QB / OX)
└── ui/hud/                 -- sprites and font used in-game
```

