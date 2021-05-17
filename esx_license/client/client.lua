local Licenses = {}

ESX = nil
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
	if exports['essentialmode']:Session() then
		TriggerServerEvent('esx_license:sync')
		print("[HRP] > Zaladowano ^2Licencje")
	end
end)

RegisterNetEvent('esx_license:sync')
AddEventHandler('esx_license:sync', function(l)
	Licenses = l
	TriggerEvent('esx_license:onUpdate', l)
end)

RegisterNetEvent('esx_license:addLicense')
AddEventHandler('esx_license:addLicense', function(ttype, ttime)
	local any = false
	for _, l in ipairs(Licenses) do
		if l.type == ttype then
			l.time = ttime
			any = true
			break
		end
	end

	if not any then
		table.insert(Licenses, { type = ttype, time = ttime })
		TriggerEvent('esx_license:onUpdate', Licenses)
	end
end)

RegisterNetEvent('esx_license:removeLicense')
AddEventHandler('esx_license:removeLicense', function(ttype)
	local any = false
	for i, l in ipairs(Licenses) do
		if l.type == ttype then
			table.remove(Licenses, i)
			any = true
			break
		end
	end

	if any then
		TriggerEvent('esx_license:onUpdate', Licenses)
	end
end)

local _in = Citizen.InvokeNative
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		local now = _in(0x9A73240B49945C76)

		local rem = {}
		for i, l in ipairs(Licenses) do
			if l.time ~= -1 and l.time < now then
				table.insert(rem, i)
			end
		end

		if #rem > 0 then
			for _, i in ipairs(rem) do
				table.remove(Licenses, i)
			end

			TriggerEvent('esx_license:onUpdate', Licenses)
		end
	end
end)