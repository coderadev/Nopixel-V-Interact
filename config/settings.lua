-- Vehicles with the engine at the back; their trunk sits on a different door index.
local MID_ENGINE_VEHICLES = {
  [`ninef`] = true,
  [`adder`] = true,
  [`vagner`] = true,
  [`t20`] = true,
  [`infernus`] = true,
  [`zentorno`] = true,
  [`reaper`] = true,
  [`comet2`] = true,
  [`comet3`] = true,
  [`jester`] = true,
  [`jester2`] = true,
  [`cheetah`] = true,
  [`cheetah2`] = true,
  [`prototipo`] = true,
  [`turismor`] = true,
  [`pfister811`] = true,
  [`ardent`] = true,
  [`nero`] = true,
  [`nero2`] = true,
  [`tempesta`] = true,
  [`vacca`] = true,
  [`bullet`] = true,
  [`osiris`] = true,
  [`entityxf`] = true,
  [`turismo2`] = true,
  [`fmj`] = true,
  [`re7b`] = true,
  [`tyrus`] = true,
  [`italigtb`] = true,
  [`penetrator`] = true,
  [`monroe`] = true,
  [`ninef2`] = true,
  [`stingergt`] = true,
  [`surfer`] = true,
  [`surfer2`] = true,
  [`gp1`] = true,
  [`autarch`] = true,
  [`tyrant`] = true,
}

local function toggleVehicleDoor(vehicle, door)
  if GetVehicleDoorLockStatus(vehicle) < 2 then
    if GetVehicleDoorAngleRatio(vehicle, door) > 0.0 then
      SetVehicleDoorShut(vehicle, door, false)
    else
      SetVehicleDoorOpen(vehicle, door, false)
    end
  end
end

local Settings = {
  Debug = GetConvar('debug', 'false') == 'true' and true or false, -- Enable / Disable debug mode

  Textures = { -- Do not change (files in ui/hud)
    key = 'key',
    dot = 'dot',
    crosshair = 'crosshair',
    font = 'font',
  },

  -- Sizes are fractions of screen height (divide the pixel size at 1080p by 1080).
  Prompt = {
    key = 'E', -- Letter shown in the key badge (the control itself is INPUT_PICKUP / 38)
    uppercase = true, -- Show labels in uppercase
    textHeight = 0.0125, -- Cap height of the label text (~13px at 1080p)
    keySize = 0.0167, -- Key badge size (~18px)
    keyTextHeight = 0.0095, -- Cap height of the letter inside the badge
    keyGap = 0.0075, -- Space between the badge and the label
    dotSize = 0.0155, -- Interaction point dot (~16px)
    crosshairSize = 0.0055, -- Centre-screen crosshair dot (~6px incl. shadow)
    crosshair = true, -- Draw the crosshair dot while interaction points are nearby
    hoverRadius = 0.06, -- How close (screen space) the crosshair must be to a point to select it
    rowSpacing = 0.024,
    textColor = { 255, 255, 255, 255 },
    keyColor = { 255, 255, 255, 255 },
    keyTextColor = { 20, 20, 20, 255 },
    dimmedAlpha = 140, -- Alpha of non-selected options when a point has several
    shadowAlpha = 110, -- Text drop shadow, 0 to disable
  },

  Disable = {
    onDeath = true, -- Disable interactions on death
    onNuiFocus = true, -- Disable interactions while NUI is focused
    onVehicle = true, -- Disable interactions while in a vehicle
    onHandCuff = true, -- Disable interactions while handcuffed
  },

  -- Nearby object distance check.
  nearbyObjectDistance = 20.0, -- Keep it at 15.0 at minimum.
  nearbyVehicleDistance = 4.0,

  vehicleBoneDefaults = {
    enabled = true,
    bones = {
      ['boot'] = {
        distance = 3.0,
        interactDst = 1.5,
        offset = vec3(0.0, 1.0, 0.0),
        options = {
          {
            name = 'interact:trunk',
            label = 'Trunk',
            action = function(entity)
              toggleVehicleDoor(entity, MID_ENGINE_VEHICLES[GetEntityModel(entity)] and 4 or 5)
            end,
          },
        },
      },
    },
  },
}

return Settings
