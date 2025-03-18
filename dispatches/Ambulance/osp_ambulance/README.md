# OSP_Ambulance
Here a simple integration for Dispatches from dead people via osp_ambulance, an ambulancejob. 
Make sure to change locales!

--> client/client_open.lua:1108
```LUA
function dispatchNotify()
    local ped = PlayerPedId()
    local myPos = GetEntityCoords(ped)
    local streetHash = GetStreetNameAtCoord(myPos.x, myPos.y, myPos.z)
    local streetName = GetStreetNameFromHashKey(streetHash) or "Unbekannte Location"

    local hours, minutes, seconds = GetClockHours(), GetClockMinutes(), GetClockSeconds()
    local gameTime = string.format("%02d:%02d:%02d", hours, minutes, seconds)
    local playerSex = "Geschlecht Unbekannt"
    
    local ambulanceDispatch = {
            priority = 'high',
            code = '10-52',
            title = 'Medizinischer Notfall',
            description = 'Eine verletzte Person ('..playerSex..') benötigt Hilfe nähe '..streetName..'.',
            location = {
                label = 'Medizinischer Notruf',
                coords = { x = myPos.x, y = myPos.y }
            },
            time = 300,
            job = 'ambulance',
            fields = {
                { icon = 'map-marker', label = 'Ort', value = streetName },
                { icon = 'clock', label = 'Uhrzeit', value = gameTime }
            }
        }
        
        Citizen.Wait(500)
        TriggerServerEvent('tablet:dispatch:triggerDispatch', ambulanceDispatch)
end
```

--> server/main.lua (Based on code from @_maximusprime )
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
