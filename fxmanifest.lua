fx_version 'adamant'
game 'gta5'

author 'Créateur : Mathéo#2802 et Correction : CookieSan#5805'
description 'MenuF5'
version '1.0.0'

dependency {
    'es_extended',
    'esx_billing',
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    '@es_extended/locale.lua',
    'config.lua',
    'server/*.lua',
}

client_scripts {
    "src/RMenu.lua",
    "src/menu/RageUI.lua",
    "src/menu/Menu.lua",
    "src/menu/MenuController.lua",
    "src/components/*.lua",
    "src/menu/elements/*.lua",
    "src/menu/items/*.lua",
    "src/menu/panels/*.lua",
    "src/menu/windows/*.lua",
}

-- Ajoutez cette ligne pour référencer le dossier "textures" contenant votre banniere_menu.png
files {
    'banniere_menu.png',
}

client_scripts {
    '@es_extended/locale.lua',
    'config.lua',
    'client/*.lua',
}

shared_script '@es_extended/imports.lua'