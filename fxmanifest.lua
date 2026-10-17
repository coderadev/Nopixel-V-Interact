fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal 'yes'
lua54 'yes'

name 'interact'
author 'codera'
description ''
version '1.0.0'

files {
    'client/api.lua',
    'client/helpers.lua',
    'client/glyphs.lua',
    'config/settings.lua',
    'config/logger.lua',
    'ui/hud/*.png'
}

shared_scripts {
    '@ox_lib/init.lua',
}

client_scripts {
    'client/sprites.lua',
    'client/renderer.lua',
    'client/scanner.lua'
}

server_scripts {
    'server/main.lua',
}
