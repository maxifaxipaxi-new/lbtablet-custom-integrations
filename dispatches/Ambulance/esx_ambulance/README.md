# ESX_Ambulancejob integration
## Change the following code to integrate the dispatchsystem into your server!
--> client/main.lua:
```
function SendDistressSignal()
    local ped = PlayerPedId()
    local myPos = GetEntityCoords(ped)
    local streetHash = GetStreetNameAtCoord(myPos.x, myPos.y, myPos.z)
    local streetName = GetStreetNameFromHashKey(streetHash) or "Unbekannte Location"

    local hours, minutes, seconds = GetClockHours(), GetClockMinutes(), GetClockSeconds()
    local gameTime = string.format("%02d:%02d:%02d", hours, minutes, seconds)
    local playerSex = "Unknown"
    
    local ambulanceDispatch = {
            priority = 'high',
            code = '10-52',
            title = 'Medical Dispatch',
            description = 'Injured person ('..playerSex..') found next to '..streetName..'.',
            location = {
                label = 'Medical Dispatch',
                coords = { x = myPos.x, y = myPos.y }
            },
            time = 300,
            job = 'ambulance',
            fields = {
                { icon = 'map-marker', label = 'Lacation', value = streetName },
                { icon = 'clock', label = 'Time', value = gameTime }
            }
        }
        
        Citizen.Wait(500)
        TriggerServerEvent('tablet:dispatch:triggerDispatch', ambulanceDispatch)
end
```

--> server/main.lua (Based on code from @_maximusprime from LB-Team )
(Only required once in the whole server, used by multiple integrations.)
```
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
