ESX = exports["es_extended"]:getSharedObject()

local PlayerData = {}
local pPed = GetPlayerPed(-1)
local keys = {} -- Mettez en place la table pour stocker les clés de voiture
local ownedVehicles = {} -- Récupérer les données depuis la table owned_vehicles pour le joueur actuel
local playerKeys = {} -- Récupérez les données depuis la table SQL player_keys pour le joueur actuel

MDscript = {
    WeaponData = {},
	ItemIndex = {},
    ItemSelected = {},
    ItemSelected2 = {},
	mykey = {},
	billing = {},
	BillData = {},
    Menu = false,
    bank = nil,
    sale = nil,
    map = true,
	cinema = false,
   vehList = {
        "Avant Gauche",
        "Avant Droite",
        "Arrière Gauche",
        "Arrière Droite"
    },
    vehList2 = {
        "Avant Droite",
        "Arrière Gauche",
        "Arrière Droite",
        "Avant Gauche",
    },
    cardList = {
        "Montrer",
        "Regarder"
    },
	LimitateurIndex = 1,
	voiture_limite = {
		"30 km/h",
        "50 km/h",
        "80 km/h",
		"100 km/h",
		"120 km/h",
        "150 km/h",
        "Désactiver"
    },
    vehIndex = 1,
    vehIndex2 = 1,
    cardIndex = 1,
    DoorState = {
        FrontLeft = false,
        FrontRight = false,
        BackLeft = false,
        BackRight = false,
        Hood = false,
        Trunk = false
    },
    WindowState = {
        FrontLeft = false,
        FrontRight = false,
        BackLeft = false,
        BackRight = false,
    },
}

Citizen.CreateThread(function()
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
	if Config.DoubleJob then
		while ESX.GetPlayerData().job2 == nil do
			Citizen.Wait(10)
		end
	end

	RMenu.Add('location', 'main', RageUI.CreateMenu(Config.MenuTitre, "~b~ID [ ~w~" .. GetPlayerServerId(NetworkGetEntityOwner(GetPlayerPed(-1))) .."~g~ ] Nom [ ~w~" .. GetPlayerName(PlayerId()) .. " ~b~]"))
	-- Menu Principal
	RMenu.Add('location', 'papier', RageUI.CreateSubMenu(RMenu:Get('location', 'main'), "Mes papiers", "Mes papiers"))
	--RMenu.Add('location', 'clé', RageUI.CreateSubMenu(RMenu:Get('location', 'main'), "Mes Clés", "Mes Clés"))
	RMenu.Add('location', 'Divers', RageUI.CreateSubMenu(RMenu:Get('location', 'main'), "Divers", "Divers"))
	RMenu.Add('location', 'portefeuille', RageUI.CreateSubMenu(RMenu:Get('location', 'main'), "Portefeuille", "Portefeuille"))
	RMenu.Add('location', 'Gestionentreprise', RageUI.CreateSubMenu(RMenu:Get('location', 'main'), "Emplois", "Gestions de votre entreprise"))
	RMenu.Add('location', 'Gestion_car', RageUI.CreateSubMenu(RMenu:Get('location', 'main'), "Gestion Véhicule", "Gestion de votre Véhicule"))	
	RMenu.Add('location', 'portefeuille_money', RageUI.CreateSubMenu(RMenu:Get('location', 'portefeuille'), "Portefeuille", "Actions sur votre portefeuille"))
	RMenu.Add('location', 'portefeuille_use', RageUI.CreateSubMenu(RMenu:Get('location', 'portefeuille'), "Portefeuille", "Actions sur votre portefeuille"))	
	Menu = false
end)

local hasCinematic = false
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if IsPauseMenuActive() then
		elseif hasCinematic then
		TriggerEvent('ui:toggle', false)
            DrawRect(1.0, 1.0, 2.0, 0.25, 0, 0, 0, 255)
            DrawRect(1.0, 0.0, 2.0, 0.25, 0, 0, 0, 255)
            ThefeedHideThisFrame()
		elseif interface then
            ThefeedHideThisFrame()
		else
			Citizen.Wait(700)
			TriggerEvent('ui:toggle', true)
		end
	end
end)

function GetPlayerKeys()
    ESX.TriggerServerCallback('esx_vehiclelock:getKeys', function(keys)
        for _, key in ipairs(keys) do
            table.insert(MDscript.mykey, key)
        end
    end)
end

-- Fonction pour prêter une clé
function PreterCle(key, allowOutOfVehicle)
    if allowOutOfVehicle then
        -- Vérification si le joueur a une clé pour le véhicule
        local vehProps = ESX.Game.GetVehicleProperties(key.vehicle)
        local foundKey = false
        for _, k in ipairs(ESX.PlayerData.inventory) do
            if k.name == 'vehiclekey' and k.metadata.plate == vehProps.plate then
                foundKey = true
                break
            end
        end
        if not foundKey then
            ESX.ShowNotification("Vous n'avez pas de clé pour ce véhicule.")
            return
        end
    else
        -- Vérification si le joueur est dans un véhicule
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if not DoesEntityExist(vehicle) then
            ESX.ShowNotification("Vous devez être dans un véhicule pour prêter une clé.")
            return
        end
        key.vehicle = vehicle -- Ajouter le véhicule à la clé
    end
    -- Récupération de l'ID du joueur le plus proche
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    if closestDistance ~= -1 and closestDistance <= 3.0 then
        -- Envoi de l'événement pour prêter la clé
        TriggerServerEvent('esx_vehiclelock:giveKey', GetPlayerServerId(closestPlayer), vehProps.plate)
    else
        ESX.ShowNotification("Aucun joueur à proximité.")
    end
end
-- Fonction pour supprimer une clé
function SupprimerCle(key)
    -- Récupérer les propriétés du véhicule associées à la clé
    local vehProps = ESX.Game.GetVehicleProperties(key.vehicle)
    -- Supprimer la clé du serveur
    TriggerServerEvent('esx_vehiclelock:removeKey', vehProps.plate)
end


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------- SCRIPT ----------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('f5', function()
    RageUI.Visible(RMenu:Get('location', 'main'), not RageUI.Visible(RMenu:Get('location', 'main')))
end)
RegisterKeyMapping('f5', 'Ouvrir Le Menu F5', 'keyboard', 'F5')
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------ MENU ---------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Citizen.CreateThread(function()
    while true do

        RageUI.IsVisible(RMenu:Get('location', 'main'), true, true, true, function()
			RageUI.Button("Portefeuille", 'Votre Portefeuille', {RightLabel = "~b~→"},true, function()
            end, RMenu:Get('location', 'portefeuille'))
			--RageUI.Button("Clés", 'Vos Clés', {RightLabel = "~b~→"}, true, function()
			--end, RMenu:Get('location', 'clé'))
			RageUI.Button("Vos papiers", "Vos papiers", {RightLabel = "~b~→"},true, function()
            end, RMenu:Get('location', 'papier'))
			local plyPed = PlayerPedId()
			if IsPedSittingInAnyVehicle(plyPed) then
				RageUI.Button("Gestion Véhicule", "Gestion Véhicule", {RightLabel = "~b~→"}, true, function(Hovered,Active,Selected)
					if Selected then
					end
				end, RMenu:Get('location', 'Gestion_car'))
			else
				RageUI.Button("Gestion Véhicule", "Gestion Véhicule", {RightBadge = RageUI.BadgeStyle.Lock}, true, function(Hovered,Active,Selected)
					if Selected then
					end
				end)
			end
			RageUI.Button("Divers", "Menu Divers", {RightLabel = "~b~→"},true, function()
            end, RMenu:Get('location', 'Divers'))
			end, function()
        end)

-- 	Gestion Clés
        RageUI.IsVisible(RMenu:Get('location', 'clé'), true, true, true, function()
			for _, key in ipairs(MDscript.mykey) do
				RageUI.Button(key.plate .. ' - ' .. key.modelName, nil, {RightLabel = "~b~→"}, true, function(Hovered, Active, Selected)
					if Selected then
						-- Options pour la clé sélectionnée
						RageUI.List('Options', {
							{Name = 'Preter', Value = 1},
							{Name = 'Supprimer', Value = 2}
						}, key, nil, {}, true, function(Hovered, Active, Selected, Index)
							if Selected then
								if Index == 1 then
									-- Preter la clé
									PreterCle(key)
								elseif Index == 2 then
									-- Supprimer la clé
									SupprimerCle(key)
								end
							end
						end)
					end
				end)
			end
		end)
		

			RageUI.IsVisible(RMenu:Get('location', 'papier'), true, true, true, function()
-- 	Carte d'identité
				RageUI.Button("			   ~b~↓ ~s~Carte d'identité ~b~↓", nil, {RightLabel = nil}, true, function(Hovered, Active, Selected)
					if (Selected) then
					end
				end)
				RageUI.Button("~b~Regarder sa ~g~carte d'identité", nil, {RightLabel = nil}, true, function(Hovered, Active, Selected)
					if (Selected) then
						TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()))
					end
				end)
				RageUI.Button("~b~Montrer sa ~g~carte d'identité", nil, {}, true, function(Hovered, Active, Selected)
					if (Selected) then
						local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
						if closestDistance ~= -1 and closestDistance <= 3.0 then
							TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer))
						else
							ESX.ShowNotification('Aucun joueur à proximité')
						end
					end
				end)
-- 	Permis de conduire			
				RageUI.Button("	             ~b~↓ ~s~Permis de conduire ~b~↓", nil, {RightLabel = nil}, true, function(Hovered, Active, Selected)
					if (Selected) then

					end
				end)
				
				RageUI.Button('~b~Regarder son ~g~permis de conduire', nil, {}, true, function(Hovered, Active, Selected)
					if (Selected) then
						TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'driver')
					end
				end)
				
				RageUI.Button('~b~Montrer son ~g~permis de conduire', nil, {}, true, function(Hovered, Active, Selected)
					if (Selected) then
						local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

						if closestDistance ~= -1 and closestDistance <= 3.0 then
							TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer), 'driver')
						else
							ESX.ShowNotification('Aucun joueur à proximité')
						end
					end
				end)
-- 	PPA
				RageUI.Button("			       ~b~↓ ~s~PPA~b~↓", nil, {RightLabel = nil}, true, function(Hovered, Active, Selected)
					if (Selected) then
					end
				end)
				RageUI.Button('~b~Regarder son ~r~permis port d\'armes', nil, {}, true, function(Hovered, Active, Selected)
					if (Selected) then
						TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'weapon')
					end
				end)
				RageUI.Button('~b~Montrer son ~r~permis port d\'armes', nil, {}, true, function(Hovered, Active, Selected)
					if (Selected) then
						local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
						if closestDistance ~= -1 and closestDistance <= 3.0 then
							TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer), 'weapon')
						else
							ESX.ShowNotification('Aucun joueur à proximité')
						end
					end
				end)
				 end, function()
			end)
		
			RageUI.IsVisible(RMenu:Get('location', 'Divers'), true, true, true, function()
                    RageUI.Checkbox("~g~Afficher~s~ / ~r~Désactiver~s~ la map", description, MDscript.map,{},function(Hovered,Ative,Selected,Checked)
                        if Selected then
                            MDscript.map = Checked
                            if Checked then
                                DisplayRadar(true)
                            else
                                DisplayRadar(false)
                            end
                        end
                    end)
					RageUI.Checkbox("~g~Activer~s~ / ~r~Désactiver~s~ le mode Cinématique", description, MDscript.cinema,{},function(Hovered,Ative,Selected,Checked)
                        if Selected then
                            MDscript.cinema = Checked
                            if Checked then
                                hasCinematic = true
								DisplayRadar(false)
                             else
                                 hasCinematic = false
								 DisplayRadar(true)
                            end
                        end
                    end)
			end, function()
			end)
			
-- PORTEFEUILLE          
			RageUI.IsVisible(RMenu:Get('location', 'portefeuille'), true, true, true, function()
				RageUI.Button("				  ~b~↓ ~s~Métiers ~b~↓", nil, {RightLabel = nil}, true, function(Hovered, Active, Selected)
					if (Selected) then
					end
				end)
				RageUI.Button("~b~Emploi", nil, {RightLabel = "~s~[ "..ESX.PlayerData.job.label .. " : "..ESX.PlayerData.job.grade_label .." ~s~]"}, true, function(Hovered, Active, Selected)
                        if Selected then
                        end
                    end)
			end, function()
		    end)

-- Gestion Véhicule 			
			RageUI.IsVisible(RMenu:Get('location', 'Gestion_car'), true, true, true, function()
                     local pPed = PlayerPedId()
                     local pVeh = GetVehiclePedIsUsing(pPed)
                     local MDscriptodel = GetEntityModel(pVeh)
                     local vName = GetDisplayNameFromVehicleModel(MDscriptodel)
                     local plyVeh = GetVehiclePedIsIn(pPed, false)
                     GetSourcevehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
                     Vengine = GetVehicleEngineHealth(GetSourcevehicle)/10
                     local Vengine2 = math.floor(Vengine)
                    RageUI.Button("Nom véhicule :", nil, {RightLabel = "~b~[ ~w~"..vName.. " ~b~]"}, true, function(Hovered,Active,Selected)
                        if Selected then
                        end
                    end)
                     RageUI.Button("Etat du moteur :", nil, {RightLabel = "~b~[ ~w~"..Vengine2.."% ~b~]"}, true, function(Hovered,Active,Selected)
                         if Selected then
                         end
                     end)
                    RageUI.Button("Allumer/Eteindre votre moteur", nil, {RightBadge = RageUI.BadgeStyle.Car}, true, function(Hovered,Active,Selected) 
                        if Selected then
                            if GetIsVehicleEngineRunning(GetSourcevehicle) then
                                SetVehicleEngineOn(GetSourcevehicle, false, false, true)
                                SetVehicleUndriveable(GetSourcevehicle, true)
                            elseif not GetIsVehicleEngineRunning(GetSourcevehicle) then
                                SetVehicleEngineOn(GetSourcevehicle, true, false, true)
                                SetVehicleUndriveable(GetSourcevehicle, false)
                            end
                        end
                    end)

					RageUI.List("Limitateur", MDscript.voiture_limite, MDscript.LimitateurIndex, nil, {}, true, function(Hovered, Active, Selected, Index)
						if (Selected) then
                            if Index == 1 then
                                SetEntityMaxSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 30.0/3.6)
								ESX.ShowNotification("Limitateur de vitesse défini sur ~b~30 km/h")
							elseif Index == 2 then
								SetEntityMaxSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 50.0/3.6)
								ESX.ShowNotification("Limitateur de vitesse défini sur ~b~50 km/h")
                            elseif Index == 3 then
                               SetEntityMaxSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 80.0/3.6)
								ESX.ShowNotification("Limitateur de vitesse défini sur ~b~80 km/h")
                            elseif Index == 4 then
                                SetEntityMaxSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 100.0/3.6)
								ESX.ShowNotification("Limitateur de vitesse défini sur ~b~100 km/h")
                            elseif Index == 5 then
                                SetEntityMaxSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 120.0/3.6)
								ESX.ShowNotification("Limitateur de vitesse défini sur ~b~120 km/h")
							elseif Index == 6 then
                                SetEntityMaxSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 150.0/3.6)
								ESX.ShowNotification("Limitateur de vitesse défini sur ~b~150 km/h")
							elseif Index == 7 then
                                SetEntityMaxSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 10000.0/3.6)    
								ESX.ShowNotification("Limitateur de vitesse désactivé")
                            end
                        end
                        MDscript.LimitateurIndex = Index
                    end)

                    RageUI.List("Gestion des portes", MDscript.vehList, MDscript.vehIndex, nil, {}, true, function(Hovered, Active, Selected, Index)
                        if (Selected) then        
                            if Index == 1 then
                                if not MDscript.DoorState.FrontLeft then
                                    MDscript.DoorState.FrontLeft = true
                                    SetVehicleDoorOpen(plyVeh, 0, false, false)
                                elseif MDscript.DoorState.FrontLeft then
                                    MDscript.DoorState.FrontLeft = false
                                    SetVehicleDoorShut(plyVeh, 0, false, false)
                                end
                            elseif Index == 2 then
                                if not MDscript.DoorState.FrontRight then
                                    MDscript.DoorState.FrontRight = true
                                    SetVehicleDoorOpen(plyVeh, 1, false, false)
                                elseif MDscript.DoorState.FrontRight then
                                    MDscript.DoorState.FrontRight = false
                                    SetVehicleDoorShut(plyVeh, 1, false, false)
                                end
                            elseif Index == 3 then
                                if not MDscript.DoorState.BackLeft then
                                    MDscript.DoorState.BackLeft = true
                                    SetVehicleDoorOpen(plyVeh, 2, false, false)
                                elseif MDscript.DoorState.BackLeft then
                                    MDscript.DoorState.BackLeft = false
                                    SetVehicleDoorShut(plyVeh, 2, false, false)
                                end
                            elseif Index == 4 then
                                if not MDscript.DoorState.BackRight then
                                    MDscript.DoorState.BackRight = true
                                    SetVehicleDoorOpen(plyVeh, 3, false, false)
                                elseif MDscript.DoorState.BackRight then
                                    MDscript.DoorState.BackRight = false
                                    SetVehicleDoorShut(plyVeh, 3, false, false)
                                end
                            end		 
                        end
                        MDscript.vehIndex = Index
                    end)

                    RageUI.List("Gestion des fenêtres", MDscript.vehList2, MDscript.vehIndex2, nil, {}, true, function(Hovered, Active, Selected, Index)
                        if (Selected) then
                            if Index == 1 then
                                if not MDscript.WindowState.FrontLeft then
                                    MDscript.WindowState.FrontLeft = true
                                    RollUpWindow(plyVeh, 1)
                                elseif MDscript.WindowState.FrontLeft then
                                    MDscript.WindowState.FrontLeft = false
                                    RollDownWindow(plyVeh, 1)
                                 end
                            elseif Index == 2 then
                                if not MDscript.WindowState.FrontRight then
                                    MDscript.WindowState.FrontRight = true
                                    RollUpWindow(plyVeh, 2)
                                elseif MDscript.WindowState.FrontRight then
                                    MDscript.WindowState.FrontRight = false
                                    RollDownWindow(plyVeh, 2)
                                end
                            elseif Index == 3 then
                                if not MDscript.WindowState.BackLeft then
                                    MDscript.WindowState.BackLeft = true
                                    RollUpWindow(plyVeh, 3)
                                elseif MDscript.WindowState.BackLeft then
                                    MDscript.WindowState.BackLeft = false
                                    RollDownWindow(plyVeh, 3)
                                end
                            elseif Index == 4 then
                                if not MDscript.WindowState.BackRight then
                                    MDscript.WindowState.BackRight = true
                                    RollUpWindow(plyVeh, 4)
                                elseif MDscript.WindowState.BackRight then
                                    MDscript.WindowState.BackRight = false
                                    RollDownWindow(plyVeh, 4)
                                end
                            end
                        end
                        MDscript.vehIndex2 = Index
                    end)
                    RageUI.Button("Ouvrir/Fermer le capot", nil, {RightBadge = RageUI.BadgeStyle.Car}, true, function(Hovered,Active,Selected) 
                        if Selected then
					        if not MDscript.DoorState.Hood then
					        	MDscript.DoorState.Hood = true
					        	SetVehicleDoorOpen(plyVeh, 4, false, false)
					        elseif MDscript.DoorState.Hood then
					        	MDscript.DoorState.Hood = false
					        	SetVehicleDoorShut(plyVeh, 4, false, false)
					        end
                        end
                    end)
                    RageUI.Button("Ouvrir/Fermer le coffre", nil, {RightBadge = RageUI.BadgeStyle.Car}, true, function(Hovered,Active,Selected) 
                        if Selected then
                            if not MDscript.DoorState.Trunk then
                                MDscript.DoorState.Trunk = true
                                SetVehicleDoorOpen(plyVeh, 5, false, false)
                            elseif MDscript.DoorState.Trunk then
                                MDscript.DoorState.Trunk = false
                                SetVehicleDoorShut(plyVeh, 5, false, false)
                            end
                        end
                    end)
			end, function()
			end)
            Citizen.Wait(0)
        end
    end)