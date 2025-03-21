if Config.JailScript ~= "rcore" then
    return
end

function JailPlayer(identifier, time, reason, officerSource)
    local min = math.floor(time / 60)
    local source = GetSourceFromIdentifier(identifier)

    if not source then
        return false
    end

    exports.rcore_prison:Jail(source, min, reason, officerSource)

    return true
end

function UnjailPlayer(identifier)
    local source = GetSourceFromIdentifier(identifier)

    if source then
        exports.rcore_prison:Unjail(source)
        return true
    end

    return false
end

---@param identifier string
function GetRemainingPrisonSentence(identifier)
    local source = GetSourceFromIdentifier(identifier)

    if source then
        local data = exports.rcore_prison:GetPrisonerData(source)

        if not data then
            return 0
        end

        return data.jail_time or 0
    else
        local data = MySQL.scalar.await("SELECT data FROM rcore_prison WHERE owner = ?", { identifier })

        if not data then
            return 0
        end

        data = json.decode(data)

        return data.jail_time or 0
    end
end

AddEventHandler("rcore_prison:server:heartbeat", function(actionType, data)
    debugprint("rcore_prison:server:heartbeat", actionType, data)
    if not data.prisoner then
        return
    end
    Wait(1000)
    if actionType == "PRISONER_NEW" then
        LogJailed(data.prisoner.owner, data.prisoner.officerName, data.prisoner.jail_reason or "", data.prisoner.jail_time)
    elseif actionType == "PRISONER_RELEASED" then
        UpdateJailSentence(data.prisoner.owner, 0)
    end
end)
