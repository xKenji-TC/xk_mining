local CT, RNE, TSE = CreateThread, RegisterNetEvent, TriggerServerEvent
local mining, mine = false, false
local rock, position = nil, nil

CT(function()
    while not ESX.PlayerData.ped do
        Wait(1000)
    end
    local blip = AddBlipForCoord(Config.ped.coords)
    SetBlipSprite(blip, 317)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 5)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName('Mining')
    EndTextCommandSetBlipName(blip)
    local model = GetHashKey(Config.ped.model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
    end
    local ped = CreatePed(4, model, Config.ped.coords.x, Config.ped.coords.y, Config.ped.coords.z - 1, Config.ped.heading, false, true)
    SetModelAsNoLongerNeeded(model)
    FreezeEntityPosition(ped, true)
    SetEntityProofs(ped, true, true, true, true, true, true, 1, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    exports.ox_target:addLocalEntity(ped, {
        {
            name = 'mining',
            event = 'mining:start',
            label = 'Start Mining'
        },
        {
            name = 'mining2',
            event = 'mining:stop',
            label = 'Stop Mining'
        }
    })
    while true do
        local sleep = 2000
        if mining then
            sleep = 1
            DrawMarker(2, position.x, position.y, position.z + 0.2, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.4, 0.4, 0.3, 255, 200, 100, 255, false, false, 2, true, false, false, false)
        end
        Wait(sleep)
    end
end)

RNE('mining:start', function()
    if mining then
        ESX.ShowNotification('You already started the job.', 'error')
    else
        mining = true
        ESX.ShowNotification('You have started mining.', 'success')
        while mining do
            while rock do
                Wait(1000)
            end
            if mining then
                local model = GetHashKey(Config.rocks[math.random(1, 3)])
                RequestModel(model)
                while not HasModelLoaded(model) do
                    Wait(100)
                end
                position = Config.rockpos[math.random(1, 8)]
                rock = CreateObject(model, position.x, position.y, position.z - 1, false, true, false)
                SetModelAsNoLongerNeeded(model)
                FreezeEntityPosition(rock, true)
                exports.ox_target:addLocalEntity(rock, {
                    {
                        name = 'mine',
                        event = 'mining:mine',
                        label = 'Mine'
                    }
                })
            end
            Wait(1000)
        end
    end
end)

RNE('mining:stop', function()
    if mining then
        mining = false
        if rock then
            DeleteObject(rock)
            rock = nil
        end
        ESX.ShowNotification('You have stopped mining.', 'success')
    else
        ESX.ShowNotification('You have not started the job yet.', 'error')
    end
end)

RNE('mining:mine', function(data)
    if mine then
        ESX.ShowNotification('You are still mining.', 'error')
    else
        if exports.ox_inventory:Search('count', 'pickaxe') > 0 then
            mine = true
            FreezeEntityPosition(ESX.PlayerData.ped, true)
            RequestAnimDict('melee@hatchet@streamed_core')
            while not HasAnimDictLoaded('melee@hatchet@streamed_core') do Wait(100) end
            RequestModel('prop_tool_pickaxe')
            while not HasModelLoaded('prop_tool_pickaxe') do Wait(100) end
            local coords = GetEntityCoords(ESX.PlayerData.ped)
            local pickaxe = CreateObject('prop_tool_pickaxe', coords, true, true, false)
            SetModelAsNoLongerNeeded('prop_tool_pickaxe')
            AttachEntityToEntity(pickaxe, ESX.PlayerData.ped, GetPedBoneIndex(ESX.PlayerData.ped, 57005), 0.05, -0.20, -0.08, -105.0, 180.0, -10.0, 1, 1, 0, 1, 0, 1)
            TaskPlayAnim(ESX.PlayerData.ped, 'melee@hatchet@streamed_core', 'plyr_rear_takedown_b', 16.0, 16.0, -1, 1, 0, 0, 0, 0 )
            RemoveAnimDict('melee@hatchet@streamed_core')
            Wait(8000)
            FreezeEntityPosition(ESX.PlayerData.ped, false)
            DeleteObject(pickaxe)
            ClearPedTasks(ESX.PlayerData.ped)
            TSE('mining:mined', math.random(1, 21))
            DeleteObject(data.entity)
            rock = nil
            mine = false
        else
            ESX.ShowNotification("You don't have a pickaxe.", 'error')
        end
    end
end)