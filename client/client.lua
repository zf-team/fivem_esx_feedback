ESX = exports["es_extended"]:getSharedObject()

ComponentIds = {
    ['mask'] = 1,        -- Maske
    ['arms'] = 3,        -- Arme und Hände
    ['pants'] = 4,       -- Hose
    ['bag'] = 5,         -- Tasche / Rucksack
    ['shoes'] = 6,       -- Schuhe
    ['accessory'] = 7,   -- Accessoires (Ketten, Armbänder)
    ['undershirt'] = 8,  -- Untershirt
    ['bodyArmor'] = 9,   -- Körperpanzer
    ['decals'] = 10,     -- Decals
    ['shirt'] = 11       -- Oberkörper (Shirts, Jacken)
}

PropIds = {
    ['hat'] = 0,         -- Hut / Helm
    ['glasses'] = 1,     -- Brillen
    ['earrings'] = 2     -- Ohrringe
}

clothsToggle = false     -- Kleidung aus/an (false = aus, true = an)

sendFeedback = false     -- Feedback gesendet (false = nicht gesendet, true = gesendet)

playTimes = {}

RegisterNetEvent('esx_feedback:sendNoti') -- Send notification to player 
AddEventHandler('esx_feedback:sendNoti', function()
    local playTime = playTimes[ESX.GetPlayerData().identifier]
    local hoursPlayed = math.floor(playTime / 60)
    local hoursRemaining = math.floor((Config.Time.u - playTime) / 60)

    ESX.ShowHelpNotification('Du hast bist bereits seit ' .. hoursPlayed .. ' Stunden auf diesen Server. Du kannst ein Feedbackgespräch halten indem du zu den markierten Bereich in deiner Minimap fährst um ein Termin zu vereinbaren. Bitte beachte das du nur bis zu ' .. hoursRemaining .. ' Stunden Zeit hast um ein Feedbackgespräch zu halten.')
    SetNewWaypoint(Config.Npc.Coords.x, Config.Npc.Coords.y)
end)

RegisterNetEvent('esx_feedback:changeClothes')
AddEventHandler('esx_feedback:changeClothes', function ()
    local ped = GetPlayerPed(-1)

    if clothsToggle == false then
        for k, v in pairs(Config.Components) do
            if ComponentIds[k] then
                SetPedComponentVariation(ped, ComponentIds[k], v.drawableId, v.textureId, 0)
            end
        end
    
        for k, v in pairs(Config.Props) do
            if PropIds[k] then
                SetPedPropIndex(ped, PropIds[k], v.propId, v.textureId, true)
            end
        end
    
        ESX.ShowHelpNotification('Deine Kleidung wurde geändert.')
        clothsToggle = true
    else
        ESX.ShowHelpNotification('Deine Kleidung wurde zurückgesetzt.')
        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
            TriggerEvent('skinchanger:loadSkin', skin)
        end)
        clothsToggle = false
    end

    

end)
    




local npcModel = GetHashKey(Config.Npc.Model)
local npcSpawned = false 


function loadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(500)
    end
end


function spawnNPC(coords) -- Spawns the NPC
    loadModel(npcModel)

    local npcPed = CreatePed(4, npcModel, coords.x, coords.y, coords.z, 0.0, false, true)

    SetEntityInvincible(npcPed, true)
    SetBlockingOfNonTemporaryEvents(npcPed, true)
    TaskStartScenarioInPlace(npcPed, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
    
    npcSpawned = npcPed -- Save the ped
end

CreateThread(function () -- thread for the NPC
    while true do
        local sleep = 100
        local playerPos = GetEntityCoords(PlayerPedId())
        local coords = Config.Npc.Coords 
        local groundZ, newZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, 0)
        
        local distance = #(playerPos - coords)

        local playTime = playTimes[ESX.GetPlayerData().identifier]        

        if distance <= 200  then  
            sleep = 1
            DrawMarker(1, coords.x, coords.y, newZ, 0.0, 0.0, 0.0, 0.0, 0, 0.0, 2.0, 2.0, 2.0, 255, 128, 0, 50, false, true, 2, false, nil, nil, false)

            if not npcSpawned then
                local newCoords = vector3(coords.x, coords.y, newZ)
                spawnNPC(newCoords)
            end
        else
            if npcSpawned then
                TriggerEvent('esx_feedback:deleteNpc')
            end
        end

        if distance <= 5 then
            if playTime ~= nil then
                if playTime < Config.Time.f then
                    ESX.ShowHelpNotification('Du hast noch nicht genug Spielzeit um ein Feedbackgespräch zu halten.')
                elseif playTime >= Config.Time.u then
                    ESX.ShowHelpNotification('Du hast bereits ein Feedbackgespräch gehalten.')
                elseif sendFeedback then
                    ESX.ShowHelpNotification('Du hast bereits ein Feedbackgespräch vereinbart.')
                else
                    ESX.ShowHelpNotification('Drücke ~INPUT_CONTEXT~ um ein Feedbackgespräch zu vereinbaren.')

                    if IsControlJustReleased(0, 38) then
                        ESX.Scaleform.ShowFreemodeMessage("~o~Feedbackgespräch Termin vereinbart", "Es wird sich in kürze ein Moderator melden", 10)
                        TriggerServerEvent('esx_feedback:sendToDiscord')
                        sendFeedback = true
                        
                    end
                end
            end
        end
        
        Wait(sleep)
    end
end)

CreateThread(function () -- thread for checking if the NPC is still at the same position
    while true do
        Wait(300)
        if npcSpawned then
            local NpcPos = GetEntityCoords(npcSpawned)

            if math.floor(NpcPos.x) ~= math.floor(Config.Npc.Coords.x) or math.floor(NpcPos.y) ~= math.floor(Config.Npc.Coords.y) then
                TriggerEvent('esx_feedback:deleteNpc')
                local groundZ, newZ = GetGroundZFor_3dCoord(Config.Npc.Coords.x, Config.Npc.Coords.y, Config.Npc.Coords.z, 0)
                local newCoords = vector3(Config.Npc.Coords.x, Config.Npc.Coords.y, newZ)

                spawnNPC(newCoords)
            end
        end
        
    end
    
end)

CreateThread(function () -- thread for checking the playtime
    while true do
        TriggerServerEvent('esx_feedback:checkUserTime')
        TriggerServerEvent('esx_feedback:sendUserTime')
        Wait(40000)
    end
    
end)

RegisterNetEvent('esx_feedback:deleteNpc') -- Deletes the NPC
AddEventHandler('esx_feedback:deleteNpc', function()
    if npcSpawned then
        DeleteEntity(npcSpawned)
        npcSpawned = false
    end
end)

RegisterNetEvent('esx_feedback:updatePlayTime') -- Updates the playtime
AddEventHandler('esx_feedback:updatePlayTime', function (playTime)
    playTimes[ESX.GetPlayerData().identifier] = playTime
end)

RegisterNetEvent('esx_feedback:notify')
AddEventHandler('esx_feedback:notify', function (message)
    ESX.ShowHelpNotification(message)
end)
