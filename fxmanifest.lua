fx_version "adamant"
game "gta5"

author "〃Sirius Studios / NahRyan"
description "FiveM Duty API"
version "1.0"

lua54 "yes"

escrow_ignore {
    "config/*",
}

server_scripts {
    "server/*.lua",
    "plugins/**/*_server.lua"
}

client_scripts {
    "client/*.lua",
    "plugins/**/*_client.lua"
}

shared_scripts {
    "shared/*.lua",
    "plugins/**/*_shared.lua"
}


dependency '/assetpacks'