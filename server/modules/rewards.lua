---Rewards Management Module
---@class RewardsModule
local RewardsModule = {}

local PlayerModule = require('server.modules.player')
local ExperienceModule = require('server.modules.experience')
local Inventory = require('shared.inventory')
local Utils = require('shared.utils')

---Calculate delivery payout
---@param distance number Delivery distance in meters
---@param level number Player level
---@param deliveryCount number Number of deliveries completed
---@return number Payout amount
function RewardsModule.calculateDeliveryPayout(distance, level, deliveryCount)
    local basePayout = Config.BasePayout
    local distanceBonus = (distance / 1000) * Config.DistanceMultiplier
    local deliveryBonus = deliveryCount * Config.AdditionalPayoutPerDelivery
    local levelBonus = level * 10
    
    return math.floor(basePayout + distanceBonus + deliveryBonus + levelBonus)
end

---Give money to player
---@param source number Player source ID
---@param amount number Amount to give
---@param type string Money type ('cash', 'bank')
---@return boolean Success status
function RewardsModule.giveMoney(source, amount, type)
    return PlayerModule.addMoney(source, type, amount)
end

---Take money from player
---@param source number Player source ID
---@param amount number Amount to take
---@param type string Money type ('cash', 'bank')
---@return boolean Success status
function RewardsModule.takeMoney(source, amount, type)
    return PlayerModule.removeMoney(source, type, amount)
end

---Give item to player
---@param source number Player source ID
---@param item string Item name
---@param amount number Amount to give
---@return boolean Success status
function RewardsModule.giveItem(source, item, amount)
    return PlayerModule.addItem(source, item, amount)
end

---Get random item from config
---@return table|nil Random item data
function RewardsModule.getRandomItem()
    local items = {}
    for item, amount in pairs(Config.RandomItems or {}) do
        table.insert(items, {item = item, amount = amount})
    end
    
    if #items > 0 then
        return items[math.random(#items)]
    end
    
    return nil
end

---Get random money amount from config
---@return number Random money amount
function RewardsModule.getRandomMoney()
    if Config.RandomMoneyAmount then
        return math.random(Config.RandomMoneyAmount.min, Config.RandomMoneyAmount.max)
    end
    return 0
end

---Check and apply all random rewards
---@param source number Player source ID
function RewardsModule.checkRandomRewards(source)
    if Config.RandomItem and Config.RandomItemChance and math.random(1, 100) <= Config.RandomItemChance then
        local randomItem = RewardsModule.getRandomItem()
        if randomItem then
            PlayerModule.addItem(source, randomItem.item, randomItem.amount)
        end
    end
    
    if Config.RandomMoney then
        local randomMoney = RewardsModule.getRandomMoney()
        if randomMoney > 0 then
            PlayerModule.addMoney(source, Config.RandomMoneyType or 'cash', randomMoney)
        end
    end
end

---Check random item reward
---@param source number Player source ID
---@return boolean True if item was given
function RewardsModule.checkRandomItemReward(source)
    if not Config.RandomItem then return false end
    
    local chance = math.random(1, 100)
    if chance > Config.RandomItemChance then return false end
    
    local items = {}
    for item, _ in pairs(Config.RandomItems) do
        table.insert(items, item)
    end
    
    if #items == 0 then return false end
    
    local selectedItem = items[math.random(#items)]
    local amount = Config.RandomItems[selectedItem]
    
    if amount > 0 then
        local success = RewardsModule.giveItem(source, selectedItem, amount)
        if success then
            Utils.notify(source, _L('random_item_reward', amount, selectedItem), 'success')
            return true
        end
    end
    
    return false
end

---Check random money reward
---@param source number Player source ID
---@return boolean True if money was given
function RewardsModule.checkRandomMoneyReward(source)
    if not Config.RandomMoney then return false end
    
    local amount = math.random(Config.RandomMoneyAmount.min, Config.RandomMoneyAmount.max)
    local success = RewardsModule.giveMoney(source, amount, Config.RandomMoneyType)
    
    if success then
        Utils.notify(source, _L('random_money_reward', amount), 'success')
        return true
    end
    
    return false
end

---Process delivery rewards
---@param source number Player source ID
---@param distance number Delivery distance in meters
---@param level number Player level
---@param deliveryCount number Number of deliveries completed
---@param deliveryTime number Delivery time in milliseconds
function RewardsModule.processDeliveryRewards(source, distance, level, deliveryCount, deliveryTime)
    local payout = RewardsModule.calculateDeliveryPayout(distance, level, deliveryCount)
    local moneySuccess = RewardsModule.giveMoney(source, payout, Config.PayCheckType)
    
    if moneySuccess then
        Utils.notify(source, _L('delivery_payment_received', payout), 'success')
    end
    
    if Config.XP.Use then
        local expReward = ExperienceModule.getDeliveryXP(source)
        local newExp = ExperienceModule.updatePlayerXP(source, expReward)
        
        local level, levelName = ExperienceModule.getLevelDisplayInfo(source)
        Utils.notify(source, _L('delivery_exp_received', expReward, level, levelName), 'success')
    end
    
    RewardsModule.checkRandomItemReward(source)
    RewardsModule.checkRandomMoneyReward(source)
end

---Process pizza making rewards
---@param source number Player source ID
function RewardsModule.processPizzaMakingRewards(source)
    if Config.XP.Use then
        local expReward = ExperienceModule.getPizzaMakingXP()
        local newExp = ExperienceModule.updatePlayerXP(source, expReward)
        
        local level, levelName = ExperienceModule.getLevelDisplayInfo(source)
        Utils.notify(source, _L('pizza_making_exp_received', expReward, level, levelName), 'success')
    else
        local basePayout = math.random(50, 100)
        local success = RewardsModule.giveMoney(source, basePayout, Config.PayCheckType)
        
        if success then
        Utils.notify(source, _L('pizza_making_payment_received', basePayout), 'success')
        end
    end
end

---Process delivery failure penalties
---@param source number Player source ID
function RewardsModule.processDeliveryFailure(source)
    local penalties = {}
    
    if Config.TakeMoney then
        local success = RewardsModule.takeMoney(source, Config.TakeMoneyAmount, Config.PayCheckType)
        if success then
            table.insert(penalties, Utils.locale('money_penalty', Config.TakeMoneyAmount))
        end
    end
    
    -- Take experience penalty
    if Config.TakeEXP and Config.XP.Use then
        local newExp = ExperienceModule.removePlayerExp(source, Config.ExpTakeAmount)
        table.insert(penalties, Utils.locale('exp_penalty', Config.ExpTakeAmount))
    end
    
    -- Notify player of penalties
    if #penalties > 0 then
        Utils.notify(source, Utils.locale('delivery_failed_penalties', table.concat(penalties, ', ')), 'error')
    end
end

---Give pizza box item
---@param source number Player source ID
---@return boolean Success status
function RewardsModule.givePizzaBox(source)
    return RewardsModule.giveItem(source, 'pizza_delivery_box', 1)
end

---Check if player has pizza box
---@param source number Player source ID
---@return boolean True if has pizza box
function RewardsModule.hasPizzaBox(source)
    return Inventory.getItemCount(source, 'pizza_delivery_box') > 0
end

---Remove pizza box from player
---@param source number Player source ID
---@return boolean Success status
function RewardsModule.removePizzaBox(source)
    return Inventory.removeItem(source, 'pizza_delivery_box', 1)
end

---Get player's current money
---@param source number Player source ID
---@param type string Money type ('cash', 'bank')
---@return number Money amount
function RewardsModule.getPlayerMoney(source, type)
    return Bridge.getPlayerMoney(source, type)
end

---Validate reward configuration
---@return boolean True if config is valid
function RewardsModule.validateConfig()
    if Config.BasePayout < 0 then
        print('^1[ERROR] BasePayout cannot be negative^7')
        return false
    end
    
    if Config.DistanceMultiplier < 0 then
        print('^1[ERROR] DistanceMultiplier cannot be negative^7')
        return false
    end
    
    if Config.AdditionalPayoutPerDelivery < 0 then
        print('^1[ERROR] AdditionalPayoutPerDelivery cannot be negative^7')
        return false
    end
    
    if Config.RandomMoneyAmount.min > Config.RandomMoneyAmount.max then
        print('^1[ERROR] RandomMoneyAmount min cannot be greater than max^7')
        return false
    end
    
    return true
end

return RewardsModule 