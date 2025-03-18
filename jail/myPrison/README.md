# myPrison Integration (Need to edit in myPrison!)

myPrsion/server.lua
Change:
```
RegisterServerEvent('myJail:releaseFromJail')
AddEventHandler('myJail:releaseFromJail', function(otherIdentifier, escaped_)
    local xPlayer = ESX.GetPlayerFromId(source)

    local dateString = os.date("%x")
	if Config.dateFormat == 'de' then
		dateString = os.date("%d.%m.%Y | %H:%M")
	else
		dateString = os.date("%x | %H:%M")
	end

    MySQL.Async.execute('UPDATE prison_log SET releaseTime = @releaseTime, `escaped` = @escaped WHERE (identifier = @identifier AND releaseTime = @releaseTimeOld)', {
        ['@releaseTime'] = dateString,
        ['@escaped'] = escaped_ or 0,
        ['@releaseTimeOld'] = '0',
        ['@identifier'] = otherIdentifier or xPlayer.identifier,
    })

    if escaped_ == 1 or not Config.removeItemsAndWeapons then
        MySQL.Async.execute('DELETE FROM prison_inmates WHERE identifier = @identifier', {
            ['@identifier'] = otherIdentifier or xPlayer.identifier,
        })
    end

    if otherIdentifier ~= nil then
        local players = ESX.GetPlayers()
        for i, playerid in pairs(players) do
            local xPlayerOnline = ESX.GetPlayerFromId(playerid)
            if xPlayerOnline.identifier == otherIdentifier then
                TriggerClientEvent('myJail:syncRelease', xPlayerOnline.source, xPlayer.name)
                break
            end
        end

    end
end)
```

To this:

```
RegisterServerEvent('myJail:releaseFromJail')
AddEventHandler('myJail:releaseFromJail', function(otherIdentifier, escaped_)
    local xPlayer = ESX.GetPlayerFromId(source)

    local dateString = os.date("%x")
	if Config.dateFormat == 'de' then
		dateString = os.date("%d.%m.%Y | %H:%M")
	else
		dateString = os.date("%x | %H:%M")
	end

    MySQL.Async.execute('UPDATE prison_log SET releaseTime = @releaseTime, `escaped` = @escaped WHERE (identifier = @identifier AND releaseTime = @releaseTimeOld)', {
        ['@releaseTime'] = dateString,
        ['@escaped'] = escaped_ or 0,
        ['@releaseTimeOld'] = '0',
        ['@identifier'] = otherIdentifier or xPlayer.identifier,
    })

    if escaped_ == 1 or not Config.removeItemsAndWeapons then
        MySQL.Async.execute('DELETE FROM prison_inmates WHERE identifier = @identifier', {
            ['@identifier'] = otherIdentifier or xPlayer.identifier,
        })
    end

    MySQL.Async.execute('DELETE FROM lbtablet_police_jail WHERE prisoner = @identifier', {
            ['@identifier'] = otherIdentifier or xPlayer.identifier,
    }) -- LB-Tablet Integration

    if otherIdentifier ~= nil then
        local players = ESX.GetPlayers()
        for i, playerid in pairs(players) do
            local xPlayerOnline = ESX.GetPlayerFromId(playerid)
            if xPlayerOnline.identifier == otherIdentifier then
                TriggerClientEvent('myJail:syncRelease', xPlayerOnline.source, xPlayer.name)
                break
            end
        end

    end
end)
```

And change:
```
RegisterServerEvent('myJail:sendToJail')
AddEventHandler('myJail:sendToJail', function(playerSource, playerName, arrestReason, arrestSeconds, jail)

    local xPlayer = ESX.GetPlayerFromId(playerSource)
    local xPlayerOfficer = ESX.GetPlayerFromId(source)

    if xPlayer ~= nil and xPlayerOfficer ~= nil then
        xPlayerOfficer.showNotification('~o~' .. xPlayer.name .. Translation[Config.Locale]['server_imprisoned'] .. arrestSeconds .. Translation[Config.Locale]['server_imprisoned2'] .. arrestReason)
        addJailEntry(xPlayer.identifier, playerName, arrestReason, arrestSeconds, xPlayerOfficer.name, jail)  
        TriggerClientEvent('myJail:enterJail', xPlayer.source, jail, arrestSeconds, xPlayerOfficer.name, arrestReason)
    else
        -- player was not found
        -- message to source?
    end

end)
```

to this:
```
RegisterServerEvent('myJail:sendToJail')
AddEventHandler('myJail:sendToJail', function(playerSource, playerName, arrestReason, arrestSeconds, jail)

    local xPlayer = ESX.GetPlayerFromId(playerSource)
    local xPlayerOfficer = ESX.GetPlayerFromId(source)

    if xPlayer ~= nil and xPlayerOfficer ~= nil then
        xPlayerOfficer.showNotification('~o~' .. xPlayer.name .. Translation[Config.Locale]['server_imprisoned'] .. arrestSeconds .. Translation[Config.Locale]['server_imprisoned2'] .. arrestReason)
        addJailEntry(xPlayer.identifier, playerName, arrestReason, arrestSeconds, xPlayerOfficer.name, jail)
        local jailId = exports["lb-tablet"]:LogJailed(xPlayer.identifier, xPlayerOfficer.name, arrestReason, arrestSeconds) 
        TriggerClientEvent('myJail:enterJail', xPlayer.source, jail, arrestSeconds, xPlayerOfficer.name, arrestReason)
    else
    end

end)
```

Thats it!
Now you are able to see inmates in your lb-tablet.
No Jail / Unjail Functions done yet, no need for myself.
