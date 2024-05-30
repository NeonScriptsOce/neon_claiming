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
        local job = Player.PlayerData.job.name
        local gang = Player.PlayerData.gang.name
        claimedBy = job or gang
        TriggerClientEvent('neon_claiming:notifyClaim', -1, Player.PlayerData.job.label or Player.PlayerData.gang.label)
        TriggerClientEvent('QBCore:Notify', src, 'You have claimed the zone!', 'success')
    end
end)

RegisterNetEvent('neon_claiming:notifyAll', function(message)
    local players = QBCore.Functions.GetPlayers()
    for _, playerId in pairs(players) do
        local Player = QBCore.Functions.GetPlayer(playerId)
        if Player then
            local job = Player.PlayerData.job.name
            local gang = Player.PlayerData.gang.name
            for _, allowedJob in ipairs(Config.AllowedJobs) do
                if job == allowedJob then
                    TriggerClientEvent('neon_claiming:notify', playerId, message)
                    break
                end
            end
            for _, allowedGang in ipairs(Config.AllowedGangs) do
                if gang == allowedGang then
                    TriggerClientEvent('neon_claiming:notify', playerId, message)
                    break
                end
            end
        end
    end
end)