# Lation247Robbery Integrations
Integrating Dispatches when somebody is robbing a 24/7

client/functions.lua:164

add the following into PoliceDispatch = function(data).

```LUA
elseif Config.Police.dispatch == 'lb-tablet' then
        local ped = PlayerPedId()
        local myPos = GetEntityCoords(ped)
        local streetHash = GetStreetNameAtCoord(myPos.x, myPos.y, myPos.z)
        local streetName = GetStreetNameFromHashKey(streetHash) or "Unbekannte Location"

        -- Placeholder for player sex (FiveM does not provide this natively)
        local hours, minutes, seconds = GetClockHours(), GetClockMinutes(), GetClockSeconds()
        local gameTime = string.format("%02d:%02d:%02d", hours, minutes, seconds)
        local playerSex = "Unknown"

        local policeDispatch = {
                priority = 'high',
                code = '10-88',
                title = 'Shop Robbery',
                description = 'A 24/7 is getting robbed next to '..streetName..'.',
                location = {
                    label = 'Shop Robbery',
                    coords = { x = myPos.x, y = myPos.y } -- Ensuring correct format
                },
                time = 400, -- Dispatch lasts for 5 minutes
                job = 'police', -- Police only
                fields = {
                    { icon = 'map-marker', label = 'Ort', value = streetName },
                    { icon = 'clock', label = 'Uhrzeit', value = gameTime }
                }
            }
    
        TriggerServerEvent('tablet:dispatch:triggerDispatch', policeDispatch)
```

Change config.lua:

```LUA
Config.Police = {
    require = true,
    count = 1,
    jobs = { 'police' },
    dispatch = 'lb-tablet',
    risk = true,
    percent = 10
}
```

--> server/functions.lua (Based on code from @_maximusprime )
*Only needed one time anywhere to be registered!*

```LUA
local timeouts = {}

local function canTriggerDispatch(src)
    local gameTime = GetGameTimer()
    if timeouts[src] and timeouts[src] < gameTime then
        timeouts[src] = gameTime
        return true
    elseif not timeouts[src] then
        timeouts[src] = gameTime
        return true
    else
        return false
    end
end

RegisterNetEvent('tablet:dispatch:triggerDispatch', function (data)
    local src = source

    if not canTriggerDispatch(src) then return end

    if #data == 0 then
        exports['lb-tablet']:AddDispatch(data)
    else
        for i = 1, #data do
            local nData = data[i]
            exports['lb-tablet']:AddDispatch(nData)
        end
    end
end)
``` 
