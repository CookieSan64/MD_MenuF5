ESX = exports["es_extended"]:getSharedObject()
local PlayerData = {}
local plyPed = PlayerPedId()

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

RegisterNetEvent('es:activateMoney')
AddEventHandler('es:activateMoney', function(money)
	  ESX.PlayerData.money = money
end)

RegisterNetEvent('esx:setAccountMoney')
AddEventHandler('esx:setAccountMoney', function(account)
	for i=1, #ESX.PlayerData.accounts, 1 do
		if ESX.PlayerData.accounts[i].name == account.name then
			ESX.PlayerData.accounts[i] = account
			break
		end
	end
end)
  
function ShowAboveRadarMessage(msg, flash, saveToBrief, hudColorIndex)
    if saveToBrief == nil then saveToBrief = true end
    AddTextEntry('notif', msg)
    BeginTextCommandThefeedPost('notif')
    if hudColorIndex then ThefeedNextPostBackgroundColor(hudColorIndex) end
    EndTextCommandThefeedPostTicker(flash or false, saveToBrief)
end
 
function OpenCinematic()
	hasCinematic = not hasCinematic
	if hasCinematic then -- show
		SendNUIMessage({openCinema = true})
		DisplayRadar(false)
		TriggerEvent('ui:toggle', false)
	else
		SendNUIMessage({openCinema = false})
		DisplayRadar(true)
		TriggerEvent('ui:toggle', true)
	end
end

function DrawAnim(ad)
    local ped = GetPlayerPed(-1)
    loadAnimDict(ad)
    RequestAnimDict(dict)
    TaskPlayAnim(ped, ad, "check_out_a", 8.0, 0.6, -1, 49, 0, 0, 0, 0 )
    TaskPlayAnim(ped, ad, "check_out_b", 8.0, 0.6, -1, 49, 0, 0, 0, 0 )
    TaskPlayAnim(ped, ad, "check_out_c", 8.0, 0.6, -1, 49, 0, 0, 0, 0 )
    TaskPlayAnim(ped, ad, "intro", 8.0, 0.6, -1, 49, 0, 0, 0, 0 )
    TaskPlayAnim(ped, ad, "outro", 8.0, 0.6, -1, 49, 0, 0, 0, 0 )
end
function loadAnimDict(dict)
	while (not HasAnimDictLoaded(dict)) do
		RequestAnimDict(dict)
		Citizen.Wait(5)
	end
end