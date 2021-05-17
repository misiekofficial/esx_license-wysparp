resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'ESX License'

version '1.0.1'

client_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'client/client.lua',
}

server_scripts {
	'@async/async.lua',
	'@mysql-async/lib/MySQL.lua',
	'server/server.lua'
}
