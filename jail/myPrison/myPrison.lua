if Config.JailScript ~= "myPrison" then
    return
end

---@param identifier string
---@param time integer The jail time in seconds
---@param reason string
---@param officerSource number
---@return boolean success
function JailPlayer(identifier, time, reason, officerSource)
    local minutes = math.floor(time / 60)
    local source = GetSourceFromIdentifier(identifier)

    if not source then
        return false
    end

    return false
end

---@param identifier string
---@return boolean success
function UnjailPlayer(identifier)
    TriggerEvent("myJail:releaseFromJail", identifier, false)

    return false
end

---@param identifier string
---@return integer remainingTime seconds
function GetRemainingPrisonSentence(identifier)
    local source = GetSourceFromIdentifier(identifier)

    return MySQL.scalar.await("SELECT remainingTime FROM prison_inmates WHERE identifier = ?", { identifier }) or 0
end
