---@diagnostic disable: undefined-global
fx_version "adamant"
game "gta5"

author "〃Sirius Studios / NahRyan"
description "FiveM Duty API"
version "BETA"

lua54 "yes"

files {
	'html/index.html',
	'html/js/script.js',
	'html/css/style.css',
	'html/assets/images/*.png',
	'html/assets/fonts/*.ttf',
	'html/assets/sounds/*.mp3',
}

ui_page 'html/index.html'

server_scripts {
    "server/*.lua",
    "config/webhooks.lua",
    '@oxmysql/lib/MySQL.lua',
    "plugins/**/*_server.lua",
}

client_scripts {
    "client/*.lua",
    "utils/bodycam.lua",
    "utils/callbacks.lua",
    "plugins/**/*_client.lua",
    "utils/overhead.lua",
}

shared_scripts {
    "utils/utils.lua",
    '@ox_lib/init.lua',
    'config/config.lua',
    "plugins/**/*_shared.lua",
}

escrow_ignore {
    "config/*",
    "html/*",
    "plugins/*",
}

dependencies {
    "ox_lib",
    "oxmysql",
    '/assetpacks',
}