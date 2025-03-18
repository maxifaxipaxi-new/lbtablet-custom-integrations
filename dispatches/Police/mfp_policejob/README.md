# MFP_PoliceJob Integration
Change the following to receive Panicbutton Messages inside of the LB-Tablet.

Go to config/config.lua
```LUA
Config.DispatchScript = 'custom'
-- 'none' for no special dispatch script
-- 'core' for default core dispatch
-- 'aty' for aty_dispatch
-- 'cd_dispatch' for cd_dispatch
-- 'qs-dispatch' for Quasar Dispatch
-- 'custom' for custom script
```
The line under this no add the following code:
```LUA
function OpenCustomDispatch(playerCoords)
    -- add custom dispatch script here if Config.DispatchScript = 'custom'
    	local ped = PlayerPedId()
        local myPos = GetEntityCoords(ped)
        local streetHash = GetStreetNameAtCoord(myPos.x, myPos.y, myPos.z)
        local streetName = GetStreetNameFromHashKey(streetHash) or "Unbekannte Location"

        -- Placeholder for player sex (FiveM does not provide this natively)
        local hours, minutes, seconds = GetClockHours(), GetClockMinutes(), GetClockSeconds()
        local gameTime = string.format("%02d:%02d:%02d", hours, minutes, seconds)
        local playerSex = "Unknown"

            -- Dispatch for **Police** (Low Priority)
        local policeDispatch = {
                priority = 'high',
                code = '10-99',
                title = 'Panicbutton',
                description = 'Officer pressed the Panicbutton next to '..streetName,
                location = {
                    label = 'Panicbutton',
                    coords = { x = myPos.x, y = myPos.y } -- Ensuring correct format
                },
                time = 700, -- Dispatch lasts for 5 minutes
                job = 'police', -- Police only
                fields = {
                    { icon = 'map-marker', label = 'Ort', value = streetName },
                    { icon = 'clock', label = 'Uhrzeit', value = gameTime }
                }
            }
    
        TriggerServerEvent('tablet:dispatch:triggerDispatch', policeDispatch)
end
```

--> server/server.lua (Based on code from @_maximusprime )
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

Thats it! 
Simple but good! :wink:
