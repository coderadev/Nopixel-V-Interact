local settings = require 'config.settings'
local txd = CreateRuntimeTxd('interact_txd')

for _, v in pairs(settings.Textures) do
    CreateRuntimeTextureFromImage(txd, tostring(v), "ui/hud/"..v..".png")
end