fx_version 'cerulean'
game 'gta5'

author 'Neon Scripts'
description 'Neon Claiming Script - QBCore'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html'
}