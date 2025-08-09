---Experience Management Module
---@class ExperienceModule
local ExperienceModule = {}

local PlayerModule = require('server.modules.player')

local LevelConfig = {
    [1] = { min = 0, max = 1500, xpRange = {2, 6} },
    [2] = { min = 1500, max = 4000, xpRange = {4, 9} },
    [3] = { min = 4000, max = 7000, xpRange = {6, 12} },
    [4] = { min = 7000, max = 10000, xpRange = {7, 13} },
    [5] = { min = 10000, max = 15000, xpRange = {8, 15} },
    [6] = { min = 15000, max = 20000, xpRange = {9, 16} },
    [7] = { min = 20000, max = 25000, xpRange = {10, 18} },
    [8] = { min = 25000, max = 30000, xpRange = {11, 20} },
    [9] = { min = 30000, max = 35000, xpRange = {12, 22} },
    [10] = { min = 35000, max = 40000, xpRange = {13, 25} }
}

---Get player experience from metadata
---@param source number Player source ID
---@return number Player experience
function ExperienceModule.getPlayerExp(source)
    return PlayerModule.getPlayerMetadata(source, Config.XP.MetaDataName) or 0
end

---Set player experience in metadata
---@param source number Player source ID
---@param exp number Experience amount
function ExperienceModule.setPlayerExp(source, exp)
    return PlayerModule.setPlayerMetadata(source, Config.XP.MetaDataName, exp)
end

---Add experience to player
---@param source number Player source ID
---@param amount number Experience amount to add
---@return number New total experience
function ExperienceModule.addPlayerExp(source, amount)
    local currentExp = ExperienceModule.getPlayerExp(source)
    local newExp = currentExp + amount
    ExperienceModule.setPlayerExp(source, newExp)
    
    -- Check for level up
    local newLevel = ExperienceModule.calculateLevel(newExp)
    local oldLevel = ExperienceModule.calculateLevel(currentExp)
    
    if newLevel > oldLevel then
        ExperienceModule.handleLevelUp(source, oldLevel, newLevel, newExp)
    end
    
    return newExp
end

---Remove experience from player
---@param source number Player source ID
---@param amount number Experience amount to remove
---@return number New total experience
function ExperienceModule.removePlayerExp(source, amount)
    local currentExp = ExperienceModule.getPlayerExp(source)
    local newExp = math.max(0, currentExp - amount)
    ExperienceModule.setPlayerExp(source, newExp)
    
    return newExp
end

---Calculate player level from experience using LevelConfig
---@param exp number Player experience
---@return number level Player level
---@return table config Level configuration
function ExperienceModule.calculateLevel(exp)
    for level, config in pairs(LevelConfig) do
        if exp >= config.min and exp < config.max then
            return level, config
        end
    end
    return 10, LevelConfig[10]
end

---Get experience needed for next level
---@param source number Player source ID
---@return number Experience needed for next level
function ExperienceModule.getExpToNextLevel(source)
    local xp = ExperienceModule.getPlayerExp(source)
    local level, config = ExperienceModule.calculateLevel(xp)
    
    if level >= 10 then
        return 0
    end
    
    return config.max - xp
end

---Get player level
---@param source number Player source ID
---@return number Player level
function ExperienceModule.getPlayerLevel(source)
    local xp = ExperienceModule.getPlayerExp(source)
    local level = ExperienceModule.calculateLevel(xp)
    return level
end

---Get XP reward based on current level
---@param source number Player source ID
---@return number XP reward
function ExperienceModule.getDeliveryXP(source)
    local xp = ExperienceModule.getPlayerExp(source)
    local level, config = ExperienceModule.calculateLevel(xp)
    return math.random(config.xpRange[1], config.xpRange[2])
end

---Handle level up event
---@param source number Player source ID
---@param oldLevel number Previous level
---@param newLevel number New level
---@param newExp number New experience total
function ExperienceModule.handleLevelUp(source, oldLevel, newLevel, newExp)
    local level, levelName = ExperienceModule.getLevelDisplayInfo(source)
    
    Utils.notify(source, _L('level_up', newLevel, levelName, newExp), 'success')
end

---Get level display info
---@param source number Player source ID
---@return number level Player level
---@return string levelName Level name
function ExperienceModule.getLevelDisplayInfo(source)
    local level = ExperienceModule.getPlayerLevel(source)
    local levelName = Config.LevelColors[level] and Config.LevelColors[level].name or 'Unknown'
    return level, levelName
end



---Update player XP with proper level checking
---@param source number Player source ID
---@param xpGain number XP to add
---@return number New total XP
function ExperienceModule.updatePlayerXP(source, xpGain)
    local currentXP = ExperienceModule.getPlayerExp(source)
    local newXP = currentXP + xpGain
    
    ExperienceModule.setPlayerExp(source, newXP)
    return newXP
end

---Remove player XP with minimum 0 check
---@param source number Player source ID
---@param xpLoss number XP to remove
---@return number New total XP
function ExperienceModule.removePlayerXP(source, xpLoss)
    local currentXP = ExperienceModule.getPlayerExp(source)
    local newXP = math.max(0, currentXP - xpLoss)
    
    ExperienceModule.setPlayerExp(source, newXP)
    return newXP
end

---Get experience reward for pizza making
---@return number Experience reward
function ExperienceModule.getPizzaMakingXP()
    return math.random(1, 3)
end

return ExperienceModule 