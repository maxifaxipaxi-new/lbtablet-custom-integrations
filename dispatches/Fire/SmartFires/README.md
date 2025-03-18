# SmartFires Integration
Integrating SmartFire from LondonScripts into LB-Tablet Dispatch System.

--> sv_utils.lua:382
Replace:
```LUA
function triggerFireNotification(id, message)

    if main.notifications.Cooldown.Enabled and notificationCooldown then
        return nil
    end

    local count, playerTable = checkJobsForAutomaticFires()

    if usingJobCheck then
        for k, v in pairs(playerTable) do
            TriggerClientEvent("Client:automaticFireAlert", k, id)
        end
    else
        TriggerClientEvent("Client:automaticFireAlert", -1, id)
    end

    if main.fireAlerts.infernoPager.enabled then
        local message = {firstToUpper(fires[id].type), translations.fireDescription}
        if fires[id].automatic.created then
            message = {fires[id].automatic.type, translations.fireDescription}
        end
        TriggerClientEvent("Fire-EMS-Pager:PlayTones", -1, main.fireAlerts.infernoPager.pagersToTrigger, true, message)
    end

    if main.fireAlerts.psDispatch.enabled then
        local dispatchData = {
            coords = fires[id].coords,
            message = message,
            code = main.fireAlerts.psDispatch.code,
            codeName = main.fireAlerts.psDispatch.codeName,
            sprite = main.fireAlerts.psDispatch.sprite,
            color = main.fireAlerts.psDispatch.color,
            scale = main.fireAlerts.psDispatch.scale,
            length = main.fireAlerts.psDispatch.length,
            jobs = main.fireAlerts.psDispatch.jobs,
            priority = main.fireAlerts.psDispatch.priority,
            flash = main.fireAlerts.psDispatch.flash,
            icon = main.fireAlerts.psDispatch.icon,
            sound = main.fireAlerts.psDispatch.sound,
            alertTime = nil,
            alert = {
                sprite = main.fireAlerts.psDispatch.sprite,
                color = main.fireAlerts.psDispatch.color,
                scale = main.fireAlerts.psDispatch.scale,
                flash = main.fireAlerts.psDispatch.flash,
                sound = main.fireAlerts.psDispatch.sound,
                length = main.fireAlerts.psDispatch.length,
            },
        }
    
        TriggerEvent('ps-dispatch:server:notify', dispatchData)
    end

    if main.fireAlerts.qsDispatch.enabled then
        TriggerEvent((main.fireAlerts.qsDispatch.resourceName .. ':server:CreateDispatchCall'), {
            job = main.fireAlerts.qsDispatch.jobs,
            callLocation = fires[id].coords,
            callCode = main.fireAlerts.qsDispatch.callCode,
            message = message,
            flashes = main.fireAlerts.qsDispatch.flashes,
            image = main.fireAlerts.qsDispatch.image,
            blip = {
                sprite = main.fireAlerts.qsDispatch.blipSprite,
                scale = main.fireAlerts.qsDispatch.blipScale,
                colour = main.fireAlerts.qsDispatch.blipColour,
                flashes = main.fireAlerts.qsDispatch.blipflash,
                text = main.fireAlerts.qsDispatch.blipText,
                time = main.fireAlerts.qsDispatch.blipTime,
            }
        })
    end

    if main.fireAlerts.coreDispatch.enabled then
        for k, v in pairs(main.fireAlerts.coreDispatch.jobs) do
            exports['core_dispatch']:addCall(main.fireAlerts.coreDispatch.code, message, {}, {fires[id].coords.x, fires[id].coords.y, fires[id].coords.z}, v, main.fireAlerts.coreDispatch.notificationTime, main.fireAlerts.coreDispatch.blipSprite, main.fireAlerts.coreDispatch.blipColour, main.fireAlerts.coreDispatch.priority)
        end
    end

    if main.fireAlerts.emergencyDispatch.enabled then
        TriggerEvent('emergencydispatch:emergencycall:new', "fire", message, fires[id].coords, true)
    end

    if main.fireAlerts.rcoreDispatch.enabled then

        local data = {
            code = main.fireAlerts.rcoreDispatch.displayCode, 
            default_priority = main.fireAlerts.rcoreDispatch.priority, 
            coords = fires[id].coords, 
            job = main.fireAlerts.rcoreDispatch.jobs, 
            text = main.fireAlerts.rcoreDispatch.blipName, 
            type = 'alerts', 
            blip_time = main.fireAlerts.rcoreDispatch.blipTime, 
            image = main.fireAlerts.rcoreDispatch.imageUrl,
            custom_sound = main.fireAlerts.rcoreDispatch.soundUrl, 
            blip = { -- Blip table - optional, remove this table to disable blips
                sprite = main.fireAlerts.rcoreDispatch.blipSprite, 
                colour = main.fireAlerts.rcoreDispatch.blipColour, 
                scale = main.fireAlerts.rcoreDispatch.blipScale, 
                text = main.fireAlerts.rcoreDispatch.blipName, 
                flashes = main.fireAlerts.rcoreDispatch.blipFlash, 
                radius = main.fireAlerts.rcoreDispatch.radius, 
            }
        }
        
        TriggerEvent(main.fireAlerts.rcoreDispatch.resourceName .. ':server:sendAlert', data)
    end

    if main.fireAlerts.cdDispatch.enabled then
        TriggerClientEvent('cd_dispatch:AddNotification', -1, {
            job_table = main.fireAlerts.cdDispatch.jobs,
            coords = fires[id].coords,

            title = main.fireAlerts.cdDispatch.title,
            message = message,
            flash = 0,
            unique_id = tostring(math.random(0000000,9999999)),
            blip = {
                sprite = 431,
                scale = 1.2,
                colour = 3,
                flashes = false,
                text = message,
                time = (5*60*1000),
                sound = 1,
            }
        })
    end

    if main.fireAlerts.sonoranCAD.enabled then
        -- Fetch the street name from first client in players table

        local postal = ""

        if main.fireAlerts.sonoranCAD.useNearestPostal then
            postal = exports['nearest-postal']:getPostalServer(fires[id].coords)
        end

        exports.sonorancad.call911("Fire", fires[id].coords, message, postal)
    end

    if main.fireAlerts.nightsSoftwareMdt.enabled then
        local player = GetPlayers()[1]
        TriggerClientEvent("Client:fetchStreetName", player, id, fires[id].coords)

        local timeout = false
        Citizen.SetTimeout(2000, function()
            timeout = true
        end)

        while fires[id].streetName == nil and not timeout do 
            Wait(0)
        end

        if fires[id].streetName == nil then
            fires[id].streetName = "Unknown Address"
        end

        exports.night_shifts:CreateEmergencyCallViaServer(true --[[isEmergency]], 
            false --[[isPoliceRequired]], 
            false --[[isAmbulanceRequired]], 
            true --[[isFireRequired]], 
            false --[[isTowRequired]], 
            message, 
            fires[id].streetName,
            "" --[[string]], 
            "Fire Department" --[[string]], 
            fires[id].coords --[[vector3]], 
            "Fire Department" --[[string]])
    end

    if main.fireAlerts.codeMDispatch.enabled then
        TriggerClientEvent("Client:fireNotificationCodeM", -1, fires[id].coords, message)
    end

    -- LB-Tablet Dispatch

    local fireDispatch = {
        priority = 'high',
        code = '10-52',
        title = 'Brand gemeldet',
        description = 'Es wurde ein Brand gemeldet.',
        location = {
            label = 'Notruf Feuer',
            coords = { x = fires[id].coords.x, y = fires[id].coords.y }
        },
        time = 600,
        job = 'ambulance'
    }
    exports['lb-tablet']:AddDispatch(fireDispatch)

    -- LB-Tablet Dispatch

    if main.notifications.Cooldown.Enabled and not notificationCooldown then
        notificationCooldown = true
        Citizen.SetTimeout(main.notifications.Cooldown.Duration, function()
            notificationCooldown = false
        end)
    end
end
```
With:
```LUA
function triggerFireNotification(id, message)

    local count, playerTable = checkJobsForAutomaticFires()

    if usingJobCheck then
        for k, v in pairs(playerTable) do
            TriggerClientEvent("Client:automaticFireAlert", k, id)
        end
    else
        TriggerClientEvent("Client:automaticFireAlert", -1, id)
    end
    
    local fireDispatch = {
        priority = 'high',
        code = '10-52',
        title = 'Brand gemeldet',
        description = 'Es wurde ein Brand gemeldet.',
        location = {
            label = 'Notruf Feuer',
            coords = { x = fires[id].coords.x, y = fires[id].coords.y }
        },
        time = 600,
        job = 'ambulance'
    }
    exports['lb-tablet']:AddDispatch(fireDispatch)
end
```

That's it!
