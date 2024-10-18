ESX = exports["es_extended"]:getSharedObject()

function getPlayerInfo(id) -- Get player info from local file
    local file = io.open(Config.LocalFilePath, 'r')
    local _, lisence = string.match(id, "(%w+):([%w%d]+)")
    if file then
        local content = file:read('*a')
        file:close()

        local data = json.decode(content)
        for k, v in pairs(data.players) do
            if v.license == lisence then
                return v
            end
        end
    end
end

function sendWebhook(msg) -- Send webhook to discord
    PerformHttpRequest(Config.DiscordWebhook.Url, function(err, text, headers) 
        print("WebHook gesendet! Statuscode: " .. err)
    end, "POST", json.encode(msg), {["Content-Type"] = "application/json"})
end



RegisterNetEvent('esx:playerLoaded', function(player, xPlayer, isNew) -- Check when player is loaded
    local players = MySQL.query.await('SELECT * FROM checked_users WHERE id = @identifier', {
        ['@identifier'] = xPlayer.identifier
    })

    if #players == 0 then -- If player is not in the database, add him
        MySQL.Async.execute('INSERT INTO checked_users (id, checked) VALUES (@id, @checked)', {
            ['@id'] = xPlayer.identifier,
            ['@checked'] = false
        })
    else    
        local playerInfo = getPlayerInfo(xPlayer.identifier)
        if playerInfo.playTime > Config.Time.u and players[1].checked then -- If player has more than x hours playTime, ban him
            DropPlayer(player.source, 'Du hast dein Feedbackgespräch nicht rechtzeitig gehalten. Bitte melde dich im Discord Support.')
        end
    end
end)

RegisterNetEvent('esx_feedback:sendUserTime', function () -- Update player playTime
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local playerInfo = getPlayerInfo(xPlayer.identifier)
        TriggerClientEvent('esx_feedback:updatePlayTime', xPlayer.source, playerInfo.playTime)
    end
    
end) -- Check player for the playTime


RegisterNetEvent('esx_feedback:checkUserTime', function() -- Check player for the playTime
    local xPlayer = ESX.GetPlayerFromId(source)
    if  xPlayer then 
        local players = MySQL.query.await('SELECT * FROM checked_users WHERE id = @identifier', {
            ['@identifier'] = xPlayer.identifier
        })
    

        local playerInfo = getPlayerInfo(xPlayer.identifier)

        if players[1].checked == false then -- If player is not checked, check for playTime

            if playerInfo.playTime == Config.Time.f or playerInfo.playTime == Config.Time.u-120 or playerInfo.playTime == Config.Time.u-60 then -- If player has x hours playTime, send him a notification
                TriggerClientEvent('esx_feedback:sendNoti', xPlayer.source)
            elseif playerInfo.playTime >= Config.Time.u then -- If player has more than x hours playTime, ban him
                --DropPlayer(xPlayer.source, 'Du hast dein Feedbackgespräch nicht rechtzeitig gehalten. Bitte melde dich im Discord Support.')
            end
        end
     end
end)


RegisterNetEvent('esx_feedback:sendToDiscord') -- Send player info to discord
AddEventHandler('esx_feedback:sendToDiscord', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerInfo = getPlayerInfo(xPlayer.identifier)

    local discordid = false

    for k, id in ipairs(playerInfo.ids) do
        local prefix, id = string.match(id, "(%w+):(%d+)")
        if prefix == 'discord' then
            discordid = id
        end
    end

    local phoneNumber = MySQL.query.await('SELECT phone_number FROM users WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    })
    phoneNumber = phoneNumber[1].phone_number

    local playTimeHours = playerInfo.playTime / 60
    local convertedTime = math.floor(playTimeHours) .. 'Stunden ' .. math.floor(playTimeHours % 1 * 60) .. ' Minuten'

    local msg = {
        username = Config.DiscordWebhook.Name,
        embeds = {
            {
                title = '`📨` Neues Feedback',
                color = Config.DiscordWebhook.Color,
                fields = {
                    {
                        name = "Ingame Name",
                        value= '> `'..xPlayer.getName()..'`'
                    },
                    {
                        name = "Discord ID",
                        value= '> `'..discordid..'`',
                        inline = true
                    },
                    {
                        name = "Discord User",
                        value= '> <@'..discordid..'>',
                        inline = true
                    },
                    {
                        name = "Telefon Nummer",
                        value= '> `'..phoneNumber..'`'
                    },
                    {
                        name = "Spielzeit",
                        value= '> `'..convertedTime..'`'
                    },
                },
                footer = {
                    text = 'Feedback gesendet am ' .. os.date('%d.%m.%Y um %H:%M:%S')
                }
            }
        }
    }

    sendWebhook(msg)
end)

RegisterCommand('checked', function(source, args, rawCommand) -- Set player to checked
    local playerId = args[1]
    local xPlayer = ESX.GetPlayerFromId(playerId)

    for _, u in Config.Admins do
        if u == xPlayer.identifier then
            TriggerClientEvent('esx_feedback:notify', source, 'Du kannst keine Admins als geprüft markieren.')
            return
        end
    end

    local players = MySQL.query.await('SELECT * FROM checked_users WHERE id = @identifier', {
        ['@identifier'] = xPlayer.identifier
    })
    
    if players[1].checked == false then
        MySQL.Async.execute('UPDATE checked_users SET checked = @checked WHERE id = @identifier', {
            ['@checked'] = true,
            ['@identifier'] = xPlayer.identifier
        })
    end

    TriggerClientEvent('esx_feedback:notify', xPlayer.source, 'Du wurdest von ein Admin als geprüft markiert.')
    TriggerClientEvent('esx_feedback:notify', source, 'Du hast den Spieler '.. xPlayer.getName() ..' als geprüft markiert.')
end)

RegisterCommand('outfit', function(source, args, rawCommand) -- Set player to checked
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerInfo = getPlayerInfo(xPlayer.identifier)

    TriggerClientEvent('esx_feedback:changeClothes', source)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for k, playerid in pairs(GetPlayers()) do
            TriggerClientEvent('esx_feedback:deleteNpc', playerid)
        end
    end
end)

