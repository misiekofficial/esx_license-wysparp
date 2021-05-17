ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

AddEventHandler('esx:playerLoaded', function(source)
	TriggerEvent('esx_license:getLicenses', source, function(licenses)
		TriggerClientEvent('esx_license:sync', source, licenses)
		TriggerClientEvent('esx_license:onUpdate', licenses)
	end)
end)

function AddLicense(target, type, time, cb)
	local xPlayer = ESX.GetPlayerFromId(target)
	if not xPlayer then
		return
	end

    RemoveLicense(xPlayer.get('character'), type, true, function()
		MySQL.Async.execute('INSERT INTO `user_licenses` (`type`, `owner`, `time`) VALUES (@type, @owner, @time)', {
			['@type']  = type,
			['@owner'] = xPlayer.identifier,
			['@time'] = time
		}, function(rowsChanged)
			TriggerClientEvent('esx_license:addLicense', xPlayer.source, type, time)
			if cb ~= nil then
				cb()
			end
		end)
	end)
end

function RemoveLicense(target, type, character, cb)
	local evt
	if not character then
		local xPlayer = ESX.GetPlayerFromId(target)
		if not xPlayer then
			return
		end

		target = xPlayer.get('character')
		evt = xPlayer.source
	end

	MySQL.Async.fetchAll('DELETE FROM user_licenses WHERE owner = @owner AND type = @type', {
		['@type']  = type,
		['@owner'] = target
	}, function(rowsChanged)
		if evt then
			TriggerClientEvent('esx_license:removeLicense', evt, type)
		end

		if cb then
			cb()
		end
	end)
end

function GetLicense(type, cb)
	MySQL.Async.fetchAll('SELECT `label` FROM `licenses` WHERE `type` = @type', {
		['@type'] = type
	}, function(result)
		cb ({
			type = type,
			label = result[1].label
		})
	end)
end

function GetLicenses(target, full, cb)
	local xPlayer = ESX.GetPlayerFromId(target)
	if not xPlayer then
		cb({})
		return
	end


	MySQL.Async.fetchAll('SELECT `l`.`type`, `l`.`label`, `ul`.`time` FROM `user_licenses` ul LEFT JOIN `licenses` l ON `ul`.`type` = `l`.`type` WHERE `ul`.`owner` = @owner AND (`ul`.`time` = -1 OR `ul`.`time` > UNIX_TIMESTAMP())', {
		['@owner'] = xPlayer.get('character'),
	}, function(result)
		local licenses = {}
		for i = 1, #result, 1 do
			local l = {
				type = result[i].type,
				time = result[i].time
			}
			if full then
				l.label = result[i].label
			end

			table.insert(licenses, l)
		end

		cb(licenses)
	end)
end

function CheckLicense(target, type, cb)
	local xPlayer = ESX.GetPlayerFromId(target)
	if not xPlayer then
		cb(false)
		return
	end

	MySQL.Async.fetchAll('SELECT `time` FROM `user_licenses` WHERE `type` = @type AND (`time` = -1 OR `time` > UNIX_TIMESTAMP() AND `owner` = @owner)', {
		['@type'] = type,
		['@owner'] = xPlayer.get('character')
	}, function(result)
		if #result > 0 then
			cb(true, result[1].time)
		else
			cb(false)
		end
	end)
end

function GetLicensesList(cb)
	MySQL.Async.fetchAll('SELECT * FROM licenses', {}, function(result)
		local licenses = {}

		for i=1, #result, 1 do
			table.insert(licenses, {
				type  = result[i].type,
				label = result[i].label
			})
		end

		cb(licenses)
	end)
end

function GetLicensed(type, cb)
	MySQL.Async.fetchAll('SELECT `c`.`id`, `c`.`identifier`, CONCAT(`c`.`firstname`, " ", `c`.`lastname`) AS `name`, `ul`.`time` FROM `user_licenses` ul LEFT JOIN `users` c ON `ul`.`owner` = `c`.`identifier` WHERE `ul`.`type` = @type AND (`ul`.`time` = -1 OR `ul`.`time` > UNIX_TIMESTAMP())', {
		['@type'] = type
	}, function(result)
		local licensed = {}
		for i = 1, #result, 1 do
			local xPlayer = ESX.GetPlayerFromIdentifier(result[i].identifier)
			if xPlayer then
				result[i].source = xPlayer.source
			end

			result[i].time = (result[i].time == -1 and "Dożywotnio" or os.date("%d/%m/%Y %H:%M:%S", result[i].time))
			table.insert(licensed, result[i])
		end

		cb(licensed)
	end)
end

RegisterNetEvent('esx_license:addLicense')
AddEventHandler('esx_license:addLicense', function(target, type, cb)
	AddLicense(target, type, -1, cb)
end)

RegisterNetEvent('esx_license:removeLicense')
AddEventHandler('esx_license:removeLicense', function(target, type, character, cb)
	RemoveLicense(target, type, character, cb)
end)

RegisterNetEvent('esx_license:addTimedLicense')
AddEventHandler('esx_license:addTimedLicense', function(target, type, time, cb)
	if time ~= -1 then
		time = os.time() + time
	end

	AddLicense(target, type, time, cb)
end)

AddEventHandler('esx_license:getLicense', function(type, cb)
	GetLicense(type, cb)
end)

AddEventHandler('esx_license:getLicenses', function(target, cb)
	GetLicenses(target, false, cb)
end)

AddEventHandler('esx_license:checkLicense', function(target, type, cb)
	CheckLicense(target, type, cb)
end)

AddEventHandler('esx_license:getLicensesList', function(cb)
	GetLicensesList(cb)
end)

ESX.RegisterServerCallback('esx_license:getLicense', function(source, cb, type)
	GetLicense(type, cb)
end)

ESX.RegisterServerCallback('esx_license:getLicensed', function(source, cb, type)
	GetLicensed(type, cb)
end)

ESX.RegisterServerCallback('esx_license:getLicenses', function(source, cb, target)
	if not target then
		target = source
	end

	GetLicenses(target, true, cb)
end)

ESX.RegisterServerCallback('esx_license:getMyLicenses', function(source, cb)
	GetLicenses(source, false, cb)
end)

ESX.RegisterServerCallback('esx_license:checkLicense', function(source, cb, target, type)
	CheckLicense(target, type, cb)
end)

ESX.RegisterServerCallback('esx_license:getLicensesList', function(source, cb)
	GetLicensesList(cb)
end)