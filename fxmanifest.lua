fx_version 'bodacious'
lua54 'yes'
game 'gta5'

author 'Criobits'
description 'Fumo aereo'
version '1.1.0'

shared_scripts {
  'config.lua',
  'utils.lua',
  'shared/items.lua',
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/sv_smoke.lua',
}

client_scripts {
  'client/cl_smoke.lua',
}