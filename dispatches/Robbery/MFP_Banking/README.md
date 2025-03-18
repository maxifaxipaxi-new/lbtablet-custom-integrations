# MFP_Banking & ATM Robbery
Here a simple integration for Dispatches when somebody is robbing an atm via mfp_banking script.
Make sure to change locales!

--> client.lua:38
```LUA

RegisterNetEvent('panicbutton:alarm')
AddEventHandler('panicbutton:alarm', function(pos)
    if PlayerData ~= nil and ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == Config.policeJob then
        local blip = AddBlipForCoord(pos.x, pos.y, pos.z)
        SetBlipSprite(blip, Config.DispatchBlip.Sprite)
        SetBlipDisplay(blip, 6)
        SetBlipScale(blip, Config.DispatchBlip.Size)
        SetBlipColour(blip, Config.DispatchBlip.Colour)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING");
        AddTextComponentString(Translation[Config.Locale]['atm_rob_police_blip'])
        EndTextCommandSetBlipName(blip)

        Citizen.Wait(Config.BlipTimer * 1000)
        RemoveBlip(blip)
    end
    dispatchNotify()
    

end)

function dispatchNotify()
    local ped = PlayerPedId()
    local myPos = GetEntityCoords(ped)
    local streetHash = GetStreetNameAtCoord(myPos.x, myPos.y, myPos.z)
    local streetName = GetStreetNameFromHashKey(streetHash) or "Unbekannte Location"

    local hours, minutes, seconds = GetClockHours(), GetClockMinutes(), GetClockSeconds()
    local gameTime = string.format("%02d:%02d:%02d", hours, minutes, seconds)
    local playerSex = "Unknown"
    
    local policeDispatch = {
            priority = 'high',
            code = '10-87',
            title = 'ATM Issues',
            description = 'A person ('..playerSex..') is causing alarm at the atm next to '..streetName,
            location = {
                label = 'ATM Issues',
                coords = { x = myPos.x, y = myPos.y }
            },
            time = 300,
            job = 'police',
            fields = {
                { icon = 'map-marker', label = 'Location', value = streetName },
                { icon = 'clock', label = 'Time', value = gameTime }
            }
        }
        
        Citizen.Wait(500)
        TriggerServerEvent('tablet:dispatch:triggerDispatch', policeDispatch)
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
