local QBCore = exports['qb-core']:GetCoreObject()
local isClaiming = false
local claimTimer = Config.ClaimDuration
local claimPed = nil
local claimBlip = nil
local lastClaimedBy = nil
local claimedBy = nil
local showTimerUI = false

RegisterNetEvent('neon_claiming:startClaim', function(coords, pedModel)
    if not isClaiming then
        isClaiming = true
        claimTimer = Config.ClaimDuration

        -- Adjust the height for the ped spawn
        local pedSpawnHeight = coords.z - 1.0

        -- Spawn the ped
        local model = GetHashKey(pedModel)
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(1)
        end
        claimPed = CreatePed(4, model, coords.x, coords.y, pedSpawnHeight, 0.0, false, true)
        FreezeEntityPosition(claimPed, true)
        SetEntityInvincible(claimPed, true)
        SetBlockingOfNonTemporaryEvents(claimPed, true)

        -- Create the blip zone
        claimBlip = AddBlipForRadius(coords.x, coords.y, coords.z, Config.ClaimZoneRadius * 2.0)
        SetBlipColour(claimBlip, 1) -- Red color
        SetBlipAlpha(claimBlip, 128) -- Transparency

        -- Notify players and start the timer
        if isAllowedToClaim() then
            showTimerUI = true
            TriggerServerEvent('neon_claiming:notifyAll', "A claim has started! The zone is now active.")
            SendNUIMessage({
                action = 'updateTimer',
                time = string.format("%02d:%02d", math.floor(claimTimer / 60), claimTimer % 60)
            })
        end

        Citizen.CreateThread(function()
            while isClaiming and claimTimer > 0 do
                Wait(1000)
                claimTimer = claimTimer - 1
                if showTimerUI then
                    SendNUIMessage({
                        action = 'updateTimer',
                        time = string.format("%02d:%02d", math.floor(claimTimer / 60), claimTimer % 60)
                    })
                end
            end
            if claimTimer <= 0 then
                StopClaim()
            end
        end)
    end
end)

RegisterNetEvent('neon_claiming:stopClaim', function()
    if isClaiming then
        StopClaim()
    end
end)

function StopClaim()
    isClaiming = false
    DeleteEntity(claimPed)
    RemoveBlip(claimBlip)
    showTimerUI = false
    TriggerServerEvent('neon_claiming:notifyAll', "The claim has been stopped!")
    SendNUIMessage({ action = 'hideTimer' })
end

function isAllowedToClaim()
    local PlayerData = QBCore.Functions.GetPlayerData()
    local job = PlayerData.job.name
    local gang = PlayerData.gang.name

    if claimedBy and (job == claimedBy or gang == claimedBy) then
        return false
    end

    for _, allowedJob in ipairs(Config.AllowedJobs) do
        if job == allowedJob then
            return true
        end
    end

    for _, allowedGang in ipairs(Config.AllowedGangs) do
        if gang == allowedGang then
            return true
        end
    end

    return false
end

Citizen.CreateThread(function()
    while true do
        Wait(0)

        if isClaiming and claimPed ~= nil then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local pedCoords = GetEntityCoords(claimPed)
            local distance = #(playerCoords - pedCoords)

            if distance < Config.ClaimRadius then
                if isAllowedToClaim() then
                    QBCore.Functions.DrawText3D(pedCoords.x, pedCoords.y, pedCoords.z, "[E] Claim Zone") -- Centered text
                    if IsControlJustReleased(0, 38) then -- E key
                        TriggerServerEvent('neon_claiming:claimZone')
                    end
                end
            end
        end
    end
end)

function drawText(x, y, scale, text)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

RegisterNetEvent('neon_claiming:notifyClaim', function(claimedBy)
    lastClaimedBy = claimedBy
    if isAllowedToClaim() then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"Claiming", claimedBy .. " has claimed the zone!"}
        })
    end
end)

RegisterNetEvent('neon_claiming:notify', function(message)
    if isAllowedToClaim() then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"Claiming", message}
        })
    end
end)