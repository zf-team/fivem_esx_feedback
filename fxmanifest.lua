fx_version 'cerulean'
game 'gta5'

author 'Marcos'
description 'A Feedbackscript which calls new members after x hours'

client_scripts {
    'client/client.lua',
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
}

server_scripts {
    'server/server.lua',
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
}

shared_scripts {
    'config.lua',
}



