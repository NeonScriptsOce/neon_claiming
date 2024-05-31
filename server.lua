local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Commands.Add('startclaim', 'Start a claim zone', {}, true, function(source, args)
    local src = source
    if QBCore.Functions.HasPermission(src, 'admin') then
        local coords = GetEntityCoords(GetPlayerPed(src))
        TriggerClientEvent('neon_claiming:startClaim', -1, coords, Config.PedModel)
    else
        TriggerClientEvent('QBCore:Notify', src, 'You do not have permission to use this command.', 'error')
    end
end, 'admin')

QBCore.Commands.Add('stopclaim', 'Stop the current claim zone', {}, true, function(source, args)
    local src = source
    if QBCore.Functions.HasPermission(src, 'admin') then
        TriggerClientEvent('neon_claiming:stopClaim', -1)
    else
        TriggerClientEvent('QBCore:Notify', src, 'You do not have permission to use this command.', 'error')
    end
end, 'admin')

RegisterNetEvent('neon_claiming:claimZone', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local gang = Player.PlayerData.gang and Player.PlayerData.gang.name or nil
        local gangLabel = Player.PlayerData.gang and Player.PlayerData.gang.label or nil
        if gang then
            if claimedBy and claimedBy == gang then
                TriggerClientEvent('QBCore:Notify', src, 'Your gang has already claimed this zone!', 'error')
                return
            end
            claimedBy = gang
            TriggerClientEvent('neon_claiming:notifyClaim', -1, gangLabel)
            TriggerClientEvent('QBCore:Notify', src, 'You have claimed the zone!', 'success')
        else
            print("Player has no gang")
        end
    end
end)

RegisterNetEvent('neon_claiming:notifyAll', function(message)
    local players = QBCore.Functions.GetPlayers()
    for _, playerId in pairs(players) do
        local Player = QBCore.Functions.GetPlayer(playerId)
        if Player then
            local gang = Player.PlayerData.gang and Player.PlayerData.gang.name or nil
            if gang then
                for _, allowedGang in ipairs(Config.AllowedGangs) do
                    if gang == allowedGang then
                        TriggerClientEvent('neon_claiming:notify', playerId, message)
                        break
                    end
                end
            end
        end
    end
end)