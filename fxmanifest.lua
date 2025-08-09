fx_version 'cerulean'

shared_script "@SecureServe/src/module/module.lua"
shared_script "@SecureServe/src/module/module.js"
file "@SecureServe/secureserve.key"

games { 'gta5' }
lua54 'yes'
name         'peleg-pizzajob'
version      '1.0.0'
description  'A fully immersive pizzajob job with QBX QBCORE ESX and ox_target support.'
author       'KurdY'

client_scripts {
    'client/*.lua',
    'client/modules/*.lua',
}

ui_page 'html/index.html'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'shared/locales.lua',
    'shared/bridge/init.lua',
    'shared/bridge/target/init.lua',
    'shared/utils.lua',
}

server_scripts {
    'server/*.lua'
}

dependencies {
    'ox_lib',
    'qb-core'
}

files {
	'stream/vehicles.meta',
	'stream/carvariations.meta',
	'stream/carcols.meta',
	'stream/handling.meta',
	'stream/dlctext.meta',
	'stream/vehiclelayouts.meta',
	'html/index.html',
	'html/style.css',
	'html/jquery-3.4.1.min.js',
    'html/script.js',
	'shared/bridge/qb.lua',
	'shared/bridge/esx.lua',
	'shared/bridge/vrp.lua',
}
 
data_file 'HANDLING_FILE' 'stream/handling.meta'
data_file 'VEHICLE_METADATA_FILE' 'stream/vehicles.meta'
data_file 'CARCOLS_FILE' 'stream/carcols.meta'
data_file 'VEHICLE_VARIATION_FILE' 'stream/carvariations.meta'
data_file 'DLC_TEXT_FILE' 'stream/dlctext.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'stream/vehiclelayouts.meta'