---Shared Utilities Module
---@class Utils
local Utils = {}
local Target = require('shared.bridge.target.init')

---Send notification to player using ox_lib
---@param source number Player source ID
---@param message string Message to send
---@param type string Notification type ('success', 'error', 'inform', 'warning')
function Utils.notify(source, message, type)
    type = type or 'inform'
    
    if IsDuplicityVersion() then
        if Config.Notify == 'qb' then
            TriggerClientEvent("QBCore:Notify", source, message, type)
        elseif Config.Notify == 'okok' then
            TriggerClientEvent('okokNotify:Alert', source, {
                message = message,
                type = type,
                duration = 5000
            })
        elseif Config.Notify == 'ox' then
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Pizza Job',
                description = message,
                type = type == 'success' and 'success' or type == 'error' and 'error' or 'inform',
                position = 'top',
            })
        elseif Config.Notify == 'esx' then
            TriggerClientEvent('esx:showNotification', source, message)
        else
            TriggerClientEvent('ox_lib:notify', source, {
                type = type,
                description = message
            })
        end
    else
        if Config.Notify == 'qb' then
            TriggerEvent("QBCore:Notify", source, message)
        elseif Config.Notify == 'okok' then
            exports['okokNotify']:Alert("Pizza Job", source, 5000, message)
        elseif Config.Notify == 'ox' then
            lib.notify({
                title = 'Pizza Job',
                description = source,
                type = message == 'success' and 'success' or message == 'error' and 'error' or 'inform',
                position = 'top',
            })
        elseif Config.Notify == 'esx' then
            TriggerEvent('esx:showNotification', source)
        else
            lib.notify({
                type = message,
                description = source
            })
        end
    end
end

---Get localized string
---@param key string Localization key
---@param ... any Format parameters
---@return string Localized string
function Utils.locale(key, ...)
    return _L(key, ...)
end

---Calculate distance between two coordinates
---@param coords1 vector3 First coordinate
---@param coords2 vector3 Second coordinate
---@return number Distance in meters
function Utils.getDistance(coords1, coords2)
    return #(coords1 - coords2)
end

---Check if player is in vehicle
---@param ped number Player ped ID
---@return boolean True if in vehicle
function Utils.isInVehicle(ped)
    return IsPedInAnyVehicle(ped, false)
end

---Get player's current vehicle
---@param ped number Player ped ID
---@return number|nil Vehicle entity ID or nil
function Utils.getCurrentVehicle(ped)
    if Utils.isInVehicle(ped) then
        return GetVehiclePedIsIn(ped, false)
    end
    return nil
end

---Check if vehicle is a delivery vehicle
---@param vehicle number Vehicle entity ID
---@return boolean True if delivery vehicle
function Utils.isDeliveryVehicle(vehicle)
    if not vehicle or not DoesEntityExist(vehicle) then return false end
    
    local model = GetEntityModel(vehicle)
    for _, vehicleData in pairs(Config.VehicleGarage.Vehicles) do
        if GetHashKey(vehicleData.model) == model then
            return true
        end
    end
    return false
end

---Get random delivery location
---@return vector3 Random delivery coordinates
function Utils.getRandomDeliveryLocation()
    return Config.JobLocs[math.random(#Config.JobLocs)]
end

---Add target interactions to a world entity
---@param entity number
---@param options table[]
function Utils.addTargetEntity(entity, options)
    Target.addTargetEntity(entity, options)
end

---Add a target zone at coordinates
---@param coords vector3
---@param options table[]
---@param id string|nil
function Utils.addTargetZone(coords, options, id)
    Target.addTargetZone(coords, options, id)
end

---Calculate delivery payout based on distance and level
---@param distance number Distance in meters
---@param level number Player level
---@param deliveryCount number Number of deliveries completed
---@return number Payout amount
function Utils.calculatePayout(distance, level, deliveryCount)
    local basePayout = Config.BasePayout
    local distanceBonus = (distance / 1000) * Config.DistanceMultiplier
    local deliveryBonus = deliveryCount * Config.AdditionalPayoutPerDelivery
    local levelBonus = level * 10
    
    return math.floor(basePayout + distanceBonus + deliveryBonus + levelBonus)
end

---Format time in MM:SS format
---@param seconds number Time in seconds
---@return string Formatted time string
function Utils.formatTime(seconds)
    seconds = tonumber(seconds) or 0
    if seconds < 0 then seconds = 0 end
    local minutes = math.floor(seconds / 60)
    local remainingSeconds = math.floor(seconds % 60)
    return string.format('%02d:%02d', minutes, remainingSeconds)
end

---Get level color and name
---@param level number Player level
---@return table Color and name data
function Utils.getLevelInfo(level)
    return Config.LevelColors[level] or { color = '#ffffff', name = 'Unknown' }
end

---Calculate experience needed for next level
---@param currentExp number Current experience
---@param currentLevel number Current level
---@return number Experience needed for next level
function Utils.getExpForNextLevel(currentExp, currentLevel)
    if currentLevel >= #Config.XP.Levels then
        return 0
    end
    
    local nextLevelExp = Config.XP.Levels[currentLevel]
    return math.max(0, nextLevelExp - currentExp)
end

---Calculate level progress percentage
---@param currentExp number Current experience
---@param currentLevel number Current level
---@return number Progress percentage (0-100)
function Utils.getLevelProgress(currentExp, currentLevel)
    if currentLevel >= #Config.XP.Levels then
        return 100
    end
    
    local currentThreshold = currentLevel > 1 and Config.XP.Levels[currentLevel - 1] or 0
    local nextThreshold = Config.XP.Levels[currentLevel]
    local progress = ((currentExp - currentThreshold) / (nextThreshold - currentThreshold)) * 100
    
    return math.max(0, math.min(100, progress))
end

---Check if player has required level for vehicle
---@param vehicleLevel number Required vehicle level
---@param playerLevel number Player level
---@return boolean True if player meets level requirement
function Utils.hasRequiredLevel(vehicleLevel, playerLevel)
    return playerLevel >= vehicleLevel
end

---Get vehicle info by model
---@param model string Vehicle model name
---@return table|nil Vehicle data or nil
function Utils.getVehicleInfo(model)
    for _, vehicleData in pairs(Config.VehicleGarage.Vehicles) do
        if vehicleData.model == model then
            return vehicleData
        end
    end
    return nil
end

---Validate configuration
---@return boolean True if config is valid
function Utils.validateConfig()
    if not Config.JobStartLocation then
        print('^1[ERROR] JobStartLocation not configured^7')
        return false
    end
    
    if not Config.VehicleGarage or not Config.VehicleGarage.Vehicles then
        print('^1[ERROR] VehicleGarage configuration missing^7')
        return false
    end
    
    if not Config.JobLocs or #Config.JobLocs == 0 then
        print('^1[ERROR] No delivery locations configured^7')
        return false
    end
    
    return true
end

---Debug print function
---@param message string Debug message
---@param level string Debug level ('info', 'warning', 'error')
function Utils.debug(message, level)
    if Config.Debug then
        local color = level == 'error' and '^1' or level == 'warning' and '^3' or '^5'
        print(color .. '[PIZZA DEBUG] ' .. message .. '^7')
    end
end

return Utils 