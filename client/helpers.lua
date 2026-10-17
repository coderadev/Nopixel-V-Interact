local settings = require 'config.settings'
local textures = settings.Textures

local SetDrawOrigin = SetDrawOrigin
local DrawSprite = DrawSprite
local ClearDrawOrigin = ClearDrawOrigin
local DoesEntityExist = DoesEntityExist
local GetEntityBonePosition_2 = GetEntityBonePosition_2
local GetEntityBoneIndexByName = GetEntityBoneIndexByName
local GetOffsetFromEntityInWorldCoords = GetOffsetFromEntityInWorldCoords
local IsEntityAPed = IsEntityAPed
local GetEntityCoords = GetEntityCoords

local utils = {}

function utils.getNet(entity)
    return NetworkGetNetworkIdFromEntity(entity)
end

function utils.getEntity(netID)
    return NetworkGetEntityFromNetworkId(netID)
end

function utils.getTrunkOffset(entity)
    local min, _ = GetModelDimensions(GetEntityModel(entity))
    return GetOffsetFromEntityInWorldCoords(entity, 0.0, min.y - 0.5, 0.0)
end

function utils.getCoordsFromInteract(interaction)
    if interaction.entity then
        if DoesEntityExist(interaction.entity) then
            if interaction.bone then
                return GetEntityBonePosition_2(interaction.entity, GetEntityBoneIndexByName(interaction.entity, interaction.bone))
            elseif interaction.model then
                return GetOffsetFromEntityInWorldCoords(interaction.entity, 0.0 + interaction.offset.x, 0.0 + interaction.offset.y, 0.0 + interaction.offset.z)
            else
                if IsEntityAPed(interaction.entity) then
                    if interaction.offset and interaction.offset ~= vec3(0.0, 0.0, 0.0) then
                        return GetOffsetFromEntityInWorldCoords(interaction.entity, 0.0 + interaction.offset.x, 0.0 + interaction.offset.y, 0.0 + interaction.offset.z)
                    end
                    return GetEntityBonePosition_2(interaction.entity, 0) -- SKEL_ROOT
                else
                    if interaction.offset and interaction.offset ~= vec3(0.0, 0.0, 0.0) then
                        return GetOffsetFromEntityInWorldCoords(interaction.entity, 0.0 + interaction.offset.x, 0.0 + interaction.offset.y, 0.0 + interaction.offset.z)
                    end
                    return GetEntityCoords(interaction.entity)
                end
            end
        end
    end

    return vec3(0.0, 0.0, 0.0)
end

local TXD = 'interact_txd'
local prompt = settings.Prompt
local font = require 'client.glyphs'
local glyphs = font.glyphs
local GetAspectRatio = GetAspectRatio
local DrawSpriteUv = DrawSpriteUv
local string_upper = string.upper
local string_sub = string.sub

-- Draws text from the font atlas. x is the left edge, centerY the vertical centre of the capitals.
-- Returns the drawn width. Must be called with a draw origin set if x/y are relative.
local function drawGlyphs(text, x, centerY, capHeight, aspect, r, g, b, a)
    local k = capHeight / font.capHeight
    local h = font.lineHeight * k
    local cy = centerY + capHeight * 0.5 - font.ascent * k + h * 0.5
    local kx = k / aspect
    local vh = font.lineHeight / font.height
    local pen = x

    for i = 1, #text do
        local glyph = glyphs[string_sub(text, i, i)] or glyphs['?']
        if glyph.w > 0 then
            local u, v = glyph.x / font.width, glyph.y / font.height
            DrawSpriteUv(TXD, textures.font, pen + (glyph.xoff + glyph.w * 0.5) * kx, cy, glyph.w * kx, h,
                u, v, u + glyph.w / font.width, v + vh, 0.0, r, g, b, a)
        end
        pen += glyph.adv * kx
    end

    return pen - x
end

local function measureText(text, capHeight, aspect)
    local kx = capHeight / font.capHeight / aspect
    local width = 0
    for i = 1, #text do
        width += (glyphs[string_sub(text, i, i)] or glyphs['?']).adv * kx
    end
    return width
end

local function drawText(text, x, centerY, capHeight, aspect, color, alpha)
    if prompt.shadowAlpha > 0 then
        local offset = capHeight * 0.08
        drawGlyphs(text, x + offset / aspect, centerY + offset, capHeight, aspect, 0, 0, 0, math.floor(prompt.shadowAlpha * alpha / 255))
    end
    drawGlyphs(text, x, centerY, capHeight, aspect, color[1], color[2], color[3], alpha)
end

-- Ring dot marking an interaction point.
function utils.drawDot(coords)
    local size = prompt.dotSize
    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
    DrawSprite(TXD, textures.dot, 0.0, 0.0, size / GetAspectRatio(false), size, 0.0, 255, 255, 255, 255)
    ClearDrawOrigin()
end

-- Small dot in the middle of the screen used to hover between points.
function utils.drawCrosshair()
    local size = prompt.crosshairSize
    DrawSprite(TXD, textures.crosshair, 0.5, 0.5, size / GetAspectRatio(false), size, 0.0, 255, 255, 255, 255)
end

-- "[E] LABEL" drawn in place of the dot. The key badge sits on the point, the label to its right.
-- With several options the selected row stays on the point, the others are dimmed above/below it.
function utils.drawPrompt(coords, options, selection)
    local aspect = GetAspectRatio(false)
    local keyH = prompt.keySize
    local keyW = keyH / aspect
    local labelX = keyW * 0.5 + prompt.keyGap / aspect
    local keyTextX = -measureText(prompt.key, prompt.keyTextHeight, aspect) * 0.5
    local key, textColor, keyColor, keyTextColor = prompt.key, prompt.textColor, prompt.keyColor, prompt.keyTextColor

    SetDrawOrigin(coords.x, coords.y, coords.z, 0)

    for i = 1, #options do
        local y = (i - selection) * prompt.rowSpacing
        local label = options[i].label or ''
        if prompt.uppercase then label = string_upper(label) end

        if i == selection then
            DrawSprite(TXD, textures.key, 0.0, y, keyW, keyH, 0.0, keyColor[1], keyColor[2], keyColor[3], keyColor[4])
            drawGlyphs(key, keyTextX, y, prompt.keyTextHeight, aspect, keyTextColor[1], keyTextColor[2], keyTextColor[3], keyTextColor[4])
            drawText(label, labelX, y, prompt.textHeight, aspect, textColor, textColor[4])
        else
            drawText(label, labelX, y, prompt.textHeight, aspect, textColor, prompt.dimmedAlpha)
        end
    end

    ClearDrawOrigin()
end

return utils