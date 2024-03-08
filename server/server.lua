ESX = exports["es_extended"]:getSharedObject()

ESX.RegisterServerCallback('mechanic:getSocietyMoney', function(source, cb, soc)
	local money = nil
		MySQL.Async.fetchAll('SELECT * FROM addon_account_data WHERE account_name = @society ', {
			['@society'] = soc,
		}, function(data)
			for _,v in pairs(data) do
				money = v.money
			end
			cb(money)
		end)
end)

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- MENU BOSS2 --------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ESX.RegisterServerCallback('esx_vehiculeshop:getOwnedVehicles', function(source, callback)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerKeys = {} -- Récupérez les données depuis la table SQL player_keys pour le joueur actuel

    -- Exemple de requête SQL avec MySQL pour récupérer les clés des véhicules du joueur
    MySQL.Async.fetchAll('SELECT * FROM player_keys WHERE owner = @owner AND type = "vehicle"', {
        ['@owner'] = xPlayer.identifier
    }, function(result)
        if result then
            for _, row in ipairs(result) do
                -- Assurez-vous que le format des données correspond à ce que le menu MD_MenuF5 attend
                local keyData = {
                    plate = row.plate,
                    modelName = row.model
                }
                table.insert(playerKeys, keyData)
            end
        end
        callback(playerKeys)
    end)
end)

ESX.RegisterServerCallback('esx_policejob:getOwnedVehicles', function(source, callback)
    local xPlayer = ESX.GetPlayerFromId(source)
    local ownedVehicles = {} -- Récupérez les données depuis la table SQL owned_vehicles pour le joueur actuel

    -- Exemple de requête SQL avec MySQL
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner', {
        ['@owner'] = xPlayer.identifier
    }, function(result)
        if result then
            for _, row in ipairs(result) do
                table.insert(ownedVehicles, row)
            end
        end
        callback(ownedVehicles)
    end)
end)

ESX.RegisterServerCallback('esx_ambulancejob:getOwnedVehicles', function(source, callback)
    local xPlayer = ESX.GetPlayerFromId(source)
    local ownedVehicles = {} -- Récupérez les données depuis la table SQL owned_vehicles pour le joueur actuel

    -- Exemple de requête SQL avec MySQL
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner', {
        ['@owner'] = xPlayer.identifier
    }, function(result)
        if result then
            for _, row in ipairs(result) do
                table.insert(ownedVehicles, row)
            end
        end
        callback(ownedVehicles)
    end)
end)