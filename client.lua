local QBCore = exports['qb-core']:GetCoreObject()
local isClaiming = false
local claimTimer = Config.ClaimDuration
local claimPed = nil
local claimBlip = nil
local lastClaimedBy = nil
local claimedBy = nil
local showTimerUI = false
local textUIDisplayed = false

RegisterNetEvent('neon_claiming:startClaim', function(coords)
    if not isClaiming then
        isClaiming = true
        claimTimer = Config.ClaimDuration

        -- Adjust the height for the ped spawn
        local pedSpawnHeight = coords.z - 1.0

        -- Spawn the ped
        local model = GetHashKey(Config.PedModel)
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(1)
        end
        claimPed = CreatePed(4, model, coords.x, coords.y, pedSpawnHeight, 0.0, false, true)
        FreezeEntityPosition(claimPed, true)
        SetEntityInvincible(claimPed, true)
        SetBlockingOfNonTemporaryEvents(claimPed, true)

        -- Add interaction based on config
        if Config.Interaction == 'target' then
            addTargetInteraction()
        end

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
                StopClaim(true)
            end
        end)
    end
end)

RegisterNetEvent('neon_claiming:stopClaim', function()
    if isClaiming then
        StopClaim(false)
    end
end)

function StopClaim(showWinner)
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
    SendNUIMessage({ action = 'hideTimer' })
    
    if Config.Interaction == 'target' then
        removeTargetInteraction()
    end

    if Config.Interaction == 'ox' then
        lib.hideTextUI()
        textUIDisplayed = false
    end

    if showWinner and lastClaimedBy then
        TriggerServerEvent('neon_claiming:notifyAll', lastClaimedBy .. " has won the claim!")
    else
        TriggerServerEvent('neon_claiming:notifyAll', "The claim has been stopped!")
    end
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

function isPlayerDead()
    if Config.Ambulance == 'wasabi' then
        return exports['wasabi_ambulance']:isPlayerDead()
    elseif Config.Ambulance == 'qb' then
        local PlayerData = QBCore.Functions.GetPlayerData()
        return PlayerData.metadata.isdead or PlayerData.metadata.inlaststand
    else
        -- Add other ambulance script checks here if needed
        return false
    end
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
                    if Config.Interaction == 'drawtext' then
                        DrawText3D(pedCoords.x, pedCoords.y, pedCoords.z, "[E] Claim Zone")
                        if IsControlJustReleased(0, 38) then -- E key
                            if isPlayerDead() then
                                QBCore.Functions.Notify("You cannot claim while dead!", "error")
                            else
                                TriggerServerEvent('neon_claiming:claimZone')
                            end
                        end
                    elseif Config.Interaction == 'ox' then
                        if not textUIDisplayed then
                            lib.showTextUI('[E] Claim Zone', {
                                position = 'right-center',
                                icon = 'fas fa-flag'
                            })
                            textUIDisplayed = true
                        end
                        if IsControlJustReleased(0, 38) then -- E key
                            if isPlayerDead() then
                                QBCore.Functions.Notify("You cannot claim while dead!", "error")
                            else
                                TriggerServerEvent('neon_claiming:claimZone')
                            end
                        end
                    end
                end
            else
                if Config.Interaction == 'ox' and textUIDisplayed then
                    lib.hideTextUI()
                    textUIDisplayed = false
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

function addTargetInteraction()
    if Config.Target == 'ox_target' then
        exports.ox_target:addLocalEntity(claimPed, {
            {
                name = 'claim_zone',
                icon = 'fas fa-flag',
                label = 'Claim Zone',
                canInteract = function(entity, distance, data)
                    return isAllowedToClaim() and not isPlayerDead()
                end,
                onSelect = function(data)
                    TriggerServerEvent('neon_claiming:claimZone')
                end
            }
        })
    elseif Config.Target == 'qb-target' then
        exports['qb-target']:AddTargetEntity(claimPed, {
            options = {
                {
                    type = 'client',
                    event = 'neon_claiming:claimZone',
                    icon = 'fas fa-flag',
                    label = 'Claim Zone',
                    canInteract = function()
                        return isAllowedToClaim() and not isPlayerDead()
                    end
                }
            },
            distance = Config.ClaimRadius
        })
    end
end

function removeTargetInteraction()
    if Config.Target == 'ox_target' then
        exports.ox_target:removeLocalEntity(claimPed, 'claim_zone')
    elseif Config.Target == 'qb-target' then
        exports['qb-target']:RemoveTargetEntity(claimPed)
    end
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

RegisterNetEvent('neon_claiming:claimZone', function()
    if isAllowedToClaim() then
        if isPlayerDead() then
            QBCore.Functions.Notify("You cannot claim while dead!", "error")
        else
            TriggerServerEvent('neon_claiming:claimZone')
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if Config.Interaction == 'ox' then
            lib.hideTextUI()
        end
    end
end)