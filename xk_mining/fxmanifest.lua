fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'xKenji'

shared_script {
    '@es_extended/imports.lua',
    'config.lua'
}

client_script 'client.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}