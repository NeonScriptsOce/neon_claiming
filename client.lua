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

        -- Notify players and start the timer
        if isAllowedToClaim() then
            showTimerUI = true
            TriggerServerEvent('neon_claiming:notifyAll', "A claim has started! The zone is now active.")
            SendNUIMessage({
                action = 'updateTimer',
                time = string.format("%02d:%02d", math.floor(claimTimer / 60), claimTimer % 60)
            })
        end

        -- Create the blip zone for allowed players
        if isAllowedToClaim() then
            claimBlip = AddBlipForRadius(coords.x, coords.y, coords.z, (Config.ClaimZoneRadius or 0) * 2.0)
            SetBlipColour(claimBlip, 1) -- Red color
            SetBlipAlpha(claimBlip, 128) -- Transparency
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
    if claimPed then
        DeleteEntity(claimPed)
        claimPed = nil
    end
    if claimBlip then
        RemoveBlip(claimBlip)
        claimBlip = nil
    end
    showTimerUI = false
    TriggerServerEvent('neon_claiming:notifyAll', "The claim has been stopped!")
    SendNUIMessage({ action = 'hideTimer' })
end

function isAllowedToClaim()
    local PlayerData = QBCore.Functions.GetPlayerData()
    local gang = PlayerData.gang and PlayerData.gang.name or nil

    if claimedBy and claimedBy ~= '' and gang == claimedBy then
        return false
    end

    if not gang then
        return false
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

            if Config.ClaimRadius and distance < Config.ClaimRadius then
                if isAllowedToClaim() then
                    DrawText3D(pedCoords.x, pedCoords.y, pedCoords.z, "[E] Claim Zone") -- Centered text
                    if IsControlJustReleased(0, 38) then -- E key
                        TriggerServerEvent('neon_claiming:claimZone')
                    end
                end
            end
        end
    end
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end

RegisterNetEvent('neon_claiming:notifyClaim', function(claimedBy)
    lastClaimedBy = claimedBy
    if isAllowedToClaim() then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"Claiming: ", claimedBy .. " has claimed the zone!"}
        })
    end
end)

RegisterNetEvent('neon_claiming:notify', function(message)
    if isAllowedToClaim() then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"Claiming: ", message}
        })
    end
end)