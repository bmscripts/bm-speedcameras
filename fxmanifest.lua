fx_version 'cerulean'
game 'gta5'

name 'BM Speed Cameras'
author 'BM Scripts'
description 'Speed camera system for QBox using ox_lib'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'locales/en.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}
