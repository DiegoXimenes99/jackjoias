fx_version 'cerulean'
game 'gta5'

author 'Jewelry Shop Script'
description 'Loja de Joias com preços flutuantes para QBCore + ox_inventory'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/**'
}

dependencies {
    'qb-core',
    'ox_inventory',
    'ox_target'
}

lua54 'yes'