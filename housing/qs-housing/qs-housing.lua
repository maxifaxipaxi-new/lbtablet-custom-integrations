if Config.HousingScript ~= "qs-housing" then
    return
end

local resourceName = "qs-housing"

while GetResourceState(resourceName) ~= "started" do
    debugprint("Waiting for housing script to start...")
    Wait(1000)
end

local selectPropertyQuery = ""
local searchPropertiesQuery = ""

if Config.Framework == "esx" then
    selectPropertyQuery = [[
        SELECT
            p.owner,
            p.id,
            CONCAT(u.firstname, ' ', u.lastname) AS `name`,
            p.house
        FROM player_houses p
        LEFT JOIN users u
            ON u.identifier = p.owner
    ]]

    searchPropertiesQuery = selectPropertyQuery .. [[
        WHERE
            CONCAT(u.firstname, ' ', u.lastname) LIKE ?
            OR p.id LIKE ?

        LIMIT ?, ?
    ]]
elseif Config.Framework == "qb" then
    selectPropertyQuery = [[
        SELECT
            p.owner,
            p.id,
            CONCAT(JSON_VALUE(u.charinfo, '$.firstname'), ' ', JSON_VALUE(u.charinfo, '$.lastname')) AS `name`,
            p.house
        FROM player_houses p
        LEFT JOIN players u
            ON u.citizenid = p.owner
    ]]

    searchPropertiesQuery = selectPropertyQuery .. [[
        WHERE
            CONCAT(JSON_VALUE(u.charinfo, '$.firstname'), ' ', JSON_VALUE(u.charinfo, '$.lastname')) LIKE ?
            OR p.id LIKE ?

        LIMIT ?, ?
    ]]
end

local function EncodePropertyId(owner, id)
    return "owner:" .. owner .. ",id:" .. id
end

local function DecodePropertyId(id)
    local owner, propertyId = string.match(id, "owner:(.+),id:([^,]+)$")

    return owner, propertyId and tonumber(propertyId)
end

-- Neue Funktion, die die Hausdaten für einen Spieler abruft
local function GetOwnedHousesForPlayer(owner)
    local houses = MySQL.query.await([[
        SELECT
            ph.house,
            ph.keyholders,
            hl.label,
            hl.coords
        FROM
            player_houses ph
        LEFT JOIN
            houselocations hl ON hl.name = ph.house
        WHERE
            ph.owner = ?
        ORDER BY
            ph.house ASC
    ]], { owner })

    if #houses == 0 then
        return {}  -- Falls keine Häuser vorhanden sind
    end

    for i = 1, #houses do
        local house = houses[i]
        --local keyholders = house.keyholders and json.decode(house.keyholders) or {}

        --house.keyholders = FormatKeyholders(keyholders, owner)
        house.coords = house.coords and json.decode(house.coords)?.enter
        house.locked = false
    end

    return houses
end

RegisterCallback("qs-housing-data:getOwnedHouses", function(source)
    local identifier = GetIdentifier(source)
    return GetOwnedHousesForPlayer(identifier)
end)

local function FormatPropery(property)
    local propertyData = GetOwnedHousesForPlayer(property.owner)

    if propertyData and #propertyData > 0 then
        -- Mehrere Häuser können zurückgegeben werden, also müssen wir sicherstellen, dass wir alle Hausdaten korrekt verarbeiten
        local houseData = propertyData[1]  -- Nimmt das erste Haus aus der Liste der Hausdaten (falls mehrere Häuser existieren)
        property.label = houseData.label or property.id
        property.id = EncodePropertyId(property.owner, property.id)

        property.owner = {
            name = property.name,
            identifier = property.owner
        }

        property.name = nil
        property.id = nil  -- Korrigiert: Wir verwenden jetzt `id` statt `propertyid`

        if houseData.coords then
            property.location = houseData.coords or {}  -- Deserialisiert die Koordinaten
        end
    end

    return property
end

---@param query string
---@param page? number
---@return table[]
function SearchProperties(query, page)
    query = "%" .. query .. "%"

    local properties = MySQL.query.await(
        searchPropertiesQuery,
        { query, query, (page or 0) * 10, 10 }
    )

    for i = 1, #properties do
        properties[i] = FormatPropery(properties[i])
    end

    return properties
end

function GetProperty(id)
    local owner, propertyId = DecodePropertyId(id)

    if not owner or not propertyId then
        debugprint("Failed to decode property id", id)
        return
    end

    local property = MySQL.single.await(
        selectPropertyQuery .. " WHERE p.owner = ? AND p.id = ?",
        { owner, propertyId }
    )

    if not property then
        return
    end

    return FormatPropery(property)
end

---@param identifier string
---@return { id: string, label: string }[]
function GetPlayerProperties(identifier)
    local properties = MySQL.query.await("SELECT owner, id, house FROM player_houses WHERE owner = ?", { identifier })

    if #properties == 0 then
        return {}  -- Falls der Spieler keine Häuser hat
    end

    for i = 1, #properties do
        local property = properties[i]
        local propertyData = GetOwnedHousesForPlayer(property.owner)

        if propertyData and #propertyData > 0 then
            properties[i] = {
                id = EncodePropertyId(property.owner, property.id),
                label = propertyData[1].label or property.id
            }
        end
    end

    return properties
end
