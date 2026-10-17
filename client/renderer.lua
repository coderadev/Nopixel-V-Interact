local interactions = require 'client.api'
local utils = require 'client.helpers'
local settings = require 'config.settings'
local CURRENT_SELECTION = 1
local CURRENT_OPTION = 0

-- CACHE
local Wait = Wait
local IsControlJustPressed = IsControlJustPressed
local IsNuiFocused = IsNuiFocused
local IsPedDeadOrDying = IsPedDeadOrDying
local IsPedCuffed = IsPedCuffed

local visibleOptions = {}

-- Collects the options whose canInteract passes into visibleOptions and returns how many there are.
local function getVisibleOptions(interaction)
    table.wipe(visibleOptions)
    local amount = 0
    local options = interaction.options
    for i = 1, #options do
        local option = options[i]
        local ok = true
        if option.canInteract then
            ok = false
            pcall(function() ok = option.canInteract(interaction.entity, interaction.coords, option.args) end)
        end
        if ok then
            amount += 1
            visibleOptions[amount] = option
        end
    end
    return amount
end

local function triggerOption(interaction, option)
    if option.action then
        pcall(function() option.action(interaction.entity, interaction.coords, option.args) end)
    elseif option.serverEvent then
        TriggerServerEvent(option.serverEvent, option.args)
    elseif option.event then
        TriggerEvent(option.event, option)
    end
end

local nearby = {}
local screenCoords, screenCount = {}, 0
local hoverRadius = settings.Prompt.hoverRadius
local GetAspectRatio = GetAspectRatio
local math_sqrt = math.sqrt

local function CreateInteractions()
    local aspect = GetAspectRatio(false)
    local active, activeCoords, activeAmount, activeIndex
    local bestDist = hoverRadius
    screenCount = 0

    -- Pass 1: find every on-screen point and pick the in-range one closest to the crosshair.
    for i = 1, #nearby do
        local interaction = nearby[i]
        local coords = interaction.coords or utils.getCoordsFromInteract(interaction)
        local onScreen, sx, sy = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)

        if onScreen then
            local amount = getVisibleOptions(interaction)

            if amount > 0 then
                screenCount += 1
                screenCoords[screenCount] = coords

                if interaction.curDist <= interaction.interactDst then
                    local dx, dy = (sx - 0.5) * aspect, sy - 0.5
                    local dist = math_sqrt(dx * dx + dy * dy)
                    if dist < bestDist then
                        bestDist = dist
                        active, activeCoords, activeAmount, activeIndex = interaction, coords, amount, screenCount
                    end
                end
            end
        end
    end

    if screenCount == 0 then
        CURRENT_OPTION = 0
        return
    end

    -- Pass 2: dots for everything except the hovered point, which gets the prompt instead.
    for i = 1, screenCount do
        if i ~= activeIndex then
            utils.drawDot(screenCoords[i])
        end
    end

    if settings.Prompt.crosshair then
        utils.drawCrosshair()
    end

    if not active then
        CURRENT_OPTION = 0
        return
    end

    -- Rebuild the option list for the hovered point (pass 1 overwrote it while scanning).
    getVisibleOptions(active)

    -- Bone and model interactions have no id, so fall back to the entity.
    local key = active.id or active.entity
    if key ~= CURRENT_OPTION then
        CURRENT_OPTION = key
        CURRENT_SELECTION = 1
    end

    if CURRENT_SELECTION > activeAmount then
        CURRENT_SELECTION = activeAmount
    end

    if CURRENT_SELECTION > 1 and (IsControlJustPressed(0, 172) or IsControlJustPressed(0, 15)) then
        CURRENT_SELECTION -= 1
    elseif CURRENT_SELECTION < activeAmount and (IsControlJustPressed(0, 173) or IsControlJustPressed(0, 14)) then
        CURRENT_SELECTION += 1
    end

    utils.drawPrompt(activeCoords, visibleOptions, CURRENT_SELECTION)

    if IsControlJustPressed(0, 38) then
        triggerOption(active, visibleOptions[CURRENT_SELECTION])
    end
end

local function isDisabled()
    if LocalPlayer.state.interactionsDisabled then
        return true
    end

    if settings.Disable.onDeath and (IsPedDeadOrDying(cache.ped) or LocalPlayer.state.isDead) then
        return true
    end

    if settings.Disable.onNuiFocus and IsNuiFocused() then
        return true
    end

    if settings.Disable.onVehicle and cache.vehicle then
        return true
    end

    if settings.Disable.onHandCuff and IsPedCuffed(cache.ped) then
        return true
    end

    return false
end

-- Fast thread
CreateThread(function ()
    lib.requestStreamedTextureDict('interact_txd')
    while true do
        local wait = 500
        if next(nearby) and not isDisabled() then
            wait = 0
            CreateInteractions()
        end
        Wait(wait)
    end
end)

-- Slow checker thread
CreateThread(function()
    while true do
        nearby = interactions.getNearbyInteractions()
        Wait(500)
    end
end)
