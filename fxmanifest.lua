fx_version 'cerulean'
game 'gta5'

author 'Neon Scripts'
description 'Neon Claiming Script - QBCore'
version '1.0.3'

lua54 'yes'

shared_scripts {
    'config.lua'
}

client_scripts {
    '@ox_lib/init.lua', -- Ensure this line is included to initialize ox_lib
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