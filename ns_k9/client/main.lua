local k9 = false
ESX = nil
local PlayerData = {}

Citizen.CreateThread(function()
    while ESX == nil do TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) Wait(0) end
    while ESX.GetPlayerData().job == nil do Wait(0) end
    PlayerData = ESX.GetPlayerData()
    if Config.Command then
        RegisterCommand(Config.Command, function()
            TriggerEvent('ns_k9:openMenu')
        end)
    end
    while true do
        local sleep = 250
        if DoesEntityExist(k9) then
            sleep = 0
            if GetDistanceBetweenCoords(GetEntityCoords(k9), GetEntityCoords(PlayerPedId()), true) >= Config.TpDistance and not IsEntityPlayingAnim(k9, 'creatures@rottweiler@amb@world_dog_sitting@base', 'base', 3) and not IsPedInAnyVehicle(k9, false) then
                SetEntityCoords(k9, GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, -1.0, -0.98))
            end
            if GetDistanceBetweenCoords(GetEntityCoords(k9), GetEntityCoords(PlayerPedId()), true) >= 2.0 and not IsPedInAnyVehicle(k9, true) and not IsEntityPlayingAnim(k9, 'creatures@rottweiler@amb@world_dog_sitting@base', 'base', 3) and IsPedStill(k9) then
                TaskGoToCoordAnyMeans(k9, GetEntityCoords(PlayerPedId()), 5.0, 0, 0, 786603, 0xbf800000)
                sleep = 500
            end
        end
        Wait(sleep)
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer   
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

RegisterNetEvent('ns_k9:openMenu')
AddEventHandler('ns_k9:openMenu', function()
    mainMenu()
end)

RegisterNetEvent('ns_k9:hasDrugs')
AddEventHandler('ns_k9:hasDrugs', function(hadIt)
    if hadIt then
        exports['ns_notify']:sendNotification(Strings['drugs_found'], {type='success', horizontal="right", variant='filled', duration=1500})
        loadDict('missfra0_chop_find')
        TaskPlayAnim(k9, 'missfra0_chop_find', 'chop_bark_at_ballas', 8.0, -8, -1, 0, 0, false, false, false)
    else
        exports['ns_notify']:sendNotification(Strings['no_drugs'], {type='error', horizontal="right", variant='filled', duration=1500})
    end
end)

mainMenu = function()
    if PlayerData.job.name == Config.Job then
        ESX.UI.Menu.CloseAll()
        ESX.UI.Menu.Open(
                'default', GetCurrentResourceName(), 'buy_storage',
            {
                title = Strings['menu_title'],
                align = 'top-left',
                elements = {{label = Strings['spawn_remove'], value = 'spawn_remove'}, {label = Strings['get_in_out'], value = 'get_in_out'}, {label = Strings['sit_stand'], value = 'sit_stand'}, {label = Strings['search_drugs'], value = 'search_drugs'}, {label = Strings['attack_closest'], value = 'attack_closest'}}
            },
            function(data, menu)
                if data.current.value == 'spawn_remove' then
                    if not DoesEntityExist(k9) then
                        RequestModel(882848737)
                        while not HasModelLoaded(882848737) do Wait(0) end
                        k9 = CreatePed(4, 882848737, GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.0, -0.98), 0.0, true, false)
                        SetEntityAsMissionEntity(k9, true, true)
                        exports['ns_notify']:sendNotification(Strings['spawned_k9'], {type='success', horizontal="right", variant='filled', duration=1500})
                    else
                        exports['ns_notify']:sendNotification(Strings['deleted_k9'], {type='success', horizontal="right", variant='filled', duration=1500})
                        DeleteEntity(k9)
                    end
                elseif data.current.value == 'get_in_out' then
                    if not IsPedInAnyVehicle(k9, false) then
                        if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(k9)) <= 10.0 then
                            local vehicle = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 7.5, 0, 70)
                            print(vehicle)
                            if DoesEntityExist(vehicle) then
                                for i = 0, GetVehicleMaxNumberOfPassengers(vehicle) do
                                    if IsVehicleSeatFree(vehicle, i) then
                                        TaskEnterVehicle(k9, vehicle, 15.0, i, 1.0, 1, 0)
                                        break
                                    end
                                end
                            end
                        else
                            exports['ns_notify']:sendNotification(Strings['no_k9'], {type='info', horizontal="right", variant='filled', duration=1500})
                        end
                    else
                        if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(k9)) <= 5.0 then
                            TaskLeaveVehicle(k9, GetVehiclePedIsIn(k9, false), 0)
                        else
                            exports['ns_notify']:sendNotification(Strings['k9_too_far'], {type='error', horizontal="right", variant='filled', duration=1500})
                        end
                    end
                elseif data.current.value == 'attack_closest' then
                    if DoesEntityExist(k9) then
                        if not IsPedDeadOrDying(k9) then
                            if GetDistanceBetweenCoords(GetEntityCoords(k9), GetEntityCoords(PlayerPedId()), true) <= 15.0 then
                                local player, distance = ESX.Game.GetClosestPlayer()
                                if distance ~= -1 then
                                    if distance <= 3.0 then
                                        local playerPed = GetPlayerPed(player)
                                        if not IsPedInCombat(k9, playerPed) then
                                            if not IsPedInAnyVehicle(playerPed, true) then
                                                TaskCombatPed(k9, playerPed, 0, 16)
                                            end
                                        else
                                            ClearPedTasksImmediately(k9)
                                        end
                                    end
                                end
                            end
                        else
                            exports['ns_notify']:sendNotification(Strings['k9_dead'], {type='error', horizontal="right", variant='filled', duration=1500})
                        end
                    else
                        exports['ns_notify']:sendNotification(Strings['no_k9'], {type='info', horizontal="right", variant='filled', duration=1500})
                    end
                elseif data.current.value == 'sit_stand' then
                    if DoesEntityExist(k9) then
                        if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(k9), true) <= 5.0 then
                            if IsEntityPlayingAnim(k9, 'creatures@rottweiler@amb@world_dog_sitting@base', 'base', 3) then
                                ClearPedTasks(k9)
                            else
                                loadDict('rcmnigel1c')
                                loadDict('creatures@rottweiler@amb@world_dog_sitting@base')
                                TaskPlayAnim(k9, 'creatures@rottweiler@amb@world_dog_sitting@base', 'base', 8.0, -8, -1, 1, 0, false, false, false)
                                exports['ns_notify']:sendNotification(Strings['k9_sit'], {type='success', horizontal="right", variant='filled', duration=1500})
                            end
                        else
                            exports['ns_notify']:sendNotification(Strings['k9_too_far'], {type='error', horizontal="right", variant='filled', duration=1500})
                        end
                    else
                        exports['ns_notify']:sendNotification(Strings['no_k9'], {type='info', horizontal="right", variant='filled', duration=1500})
                    end
                elseif data.current.value == 'search_drugs' then
                    if DoesEntityExist(k9) then
                        if not IsPedDeadOrDying(k9) then
                            if GetDistanceBetweenCoords(GetEntityCoords(k9), GetEntityCoords(PlayerPedId()), true) <= 3.0 then
                                local player, distance = ESX.Game.GetClosestPlayer()
                                if distance ~= -1 then
                                    if distance <= 3.0 then
                                        local playerPed = GetPlayerPed(player)
                                        if not IsPedInAnyVehicle(playerPed, true) then
                                            TriggerServerEvent('ns_k9:hasClosestDrugs', GetPlayerServerId(player))
                                        end
                                    end
                                end
                            end
                        else
                            exports['ns_notify']:sendNotification(Strings['k9_dead'], {type='info', horizontal="right", variant='filled', duration=20150000})
                        end
                    else
                        exports['ns_notify']:sendNotification(Strings['no_k9'], {type='info', horizontal="right", variant='filled', duration=1500})
                    end
                end
            end,
        function(data, menu)
            menu.close()
        end)
    else
        exports['ns_notify']:sendNotification(Strings['not_police'], {type='error', horizontal="right", variant='filled', duration=1500})
    end
end

loadDict = function(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) RequestAnimDict(dict) end
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    DoesEntityExist(k9) 
        DeleteEntity(k9)
  end)