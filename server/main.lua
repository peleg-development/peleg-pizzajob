print("^2KRS PizzaJob ^7v^12^7.^44 ^7- ^2PizzaJob Script by ^1KRS^7")
local Bridge = require('shared.bridge.init')
local PlayerModule = require('server.modules.player')
local ExperienceModule = require('server.modules.experience')
local RewardsModule = require('server.modules.rewards')
local Utils = require('shared.utils')

-- Active delivery registry for basic verification
local ActiveDeliveries = {}
---@diagnostic disable-next-line: undefined-global
lib.callback.register('peleg-PizzaJob:CallBacks:getexp', function(source)
    local xp = PlayerModule.getPlayerMetadata(source, Config.XP.MetaDataName) or 0
    return xp
end)

---@diagnostic disable-next-line: undefined-global
lib.callback.register('peleg-PizzaJob:CallBacks:getnextlevelin', function(source)
    return ExperienceModule.getExpToNextLevel(source)
end)

---@diagnostic disable-next-line: undefined-global
lib.callback.register('peleg-PizzaJob:CallBacks:getlevel', function(source)
    return ExperienceModule.getPlayerLevel(source)
end)

---@diagnostic disable-next-line: undefined-global
lib.callback.register('peleg-PizzaJob:CallBacks:hasdeliverybox', function(source)
    return PlayerModule.hasItem(source, 'pizza_delivery_box')
end)

---@diagnostic disable-next-line: undefined-global
lib.callback.register('peleg-PizzaJob:CallBacks:getselectedvehicle', function(source)
    return PlayerModule.getPlayerMetadata(source, 'pizza_selected_vehicle') or 'foodbike'
end)

---@diagnostic disable-next-line: undefined-global
lib.callback.register('peleg-PizzaJob:CallBacks:getPizzaBoxCount', function(source)
    return PlayerModule.getItemCount(source, 'pizza_delivery_box')
end)

if Config.XP.Command then
    Bridge.addCommand('pizzaexp', 'Check your pizza delivery experience', function(source)
        local src = source
        local level, levelName = ExperienceModule.getLevelDisplayInfo(src)
        local currentXP = ExperienceModule.getPlayerExp(src)
        local nextLevelExp = ExperienceModule.getExpToNextLevel(src)
        
        Utils.notify(src, _L('current_level_info', level, levelName, currentXP, nextLevelExp), 'inform')
    end)
end

-- Server-authoritative delivery picker
 ---@diagnostic disable-next-line: undefined-global
 lib.callback.register('peleg-pizzajob:server:newDelivery', function(source)
     local locs = Config.JobLocs or {}
     if #locs == 0 then return nil end
     local idx = math.random(#locs)
     local coords = locs[idx]
     local ped = GetPlayerPed(source)
     local startCoords = (ped and ped ~= 0) and GetEntityCoords(ped) or nil
     ActiveDeliveries[source] = { coords = coords, startedAt = GetGameTimer(), startCoords = startCoords }
     return coords
 end)

RegisterNetEvent('peleg-pizzajob:server:givePizzaBox', function()
    local src = source
    local Player = PlayerModule.getPlayerData(src)
    
    if Player then
        PlayerModule.addItem(src, 'pizza_delivery_box', 1)
        
        if Config.XP.Use then
            local baseXP = ExperienceModule.getPizzaMakingXP()
            local newExp = ExperienceModule.updatePlayerXP(src, baseXP)
            
            local level, levelName = ExperienceModule.getLevelDisplayInfo(src)
            
            Utils.notify(src, _L('pizza_made_xp', baseXP, level, levelName, newExp), 'success')
        end
    end
end)

RegisterNetEvent('peleg-pizzajob:server:completeDelivery', function(deliveryCount, deliveryTime)
    local src = source
    local data = ActiveDeliveries[src]
    if not data then
        Utils.notify(src, _L('cannot_deliver_conditions'), 'error')
        return
    end
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return end
    local pc = GetEntityCoords(ped)
    local dc = data.coords
    local dist = #(pc - dc)
    if dist > 6.0 then
        Utils.notify(src, _L('cannot_deliver_conditions'), 'error')
        return
    end
    if not RewardsModule.hasPizzaBox(src) then
        Utils.notify(src, _L('no_pizza_boxes'), 'error')
        return
    end
    RewardsModule.removePizzaBox(src)
    RewardsModule.checkRandomRewards(src)
    if Config.XP.Use then
        local exp = ExperienceModule.getDeliveryXP(src)
        ExperienceModule.updatePlayerXP(src, exp)
    end
    local payoutDistance = 0.0
    if data.startCoords then
        payoutDistance = Utils.getDistance(data.startCoords, dc)
    else
        payoutDistance = Utils.getDistance(pc, dc)
    end
    local level = ExperienceModule.getPlayerLevel(src)
    local payout = RewardsModule.calculateDeliveryPayout(payoutDistance, level, deliveryCount)
    RewardsModule.giveMoney(src, payout, Config.PayCheckType)
    Utils.notify(src, _L('received_delivery_payment', payout), 'success')
    ActiveDeliveries[src] = nil
end)

RegisterNetEvent('peleg-pizzajob:server:failDelivery', function()
    local src = source
    RewardsModule.processDeliveryFailure(src)
end)

RegisterNetEvent('peleg-pizzajobL:server:Fail', function()
    local src = source
    RewardsModule.processDeliveryFailure(src)
end)

RegisterNetEvent("peleg-pizzajobL:server:Fail", function()
    local src = source
    
    if Config.TakeMoney then
        RewardsModule.takeMoney(src, Config.TakeMoneyAmount, Config.PayCheckType)
        Utils.notify(src, _L('delivery_failed_money', Config.TakeMoneyAmount), 'error')
    end
    
    if Config.TakeEXP then
        local newExp = ExperienceModule.removePlayerXP(src, Config.ExpTakeAmount)
        Utils.notify(src, _L('delivery_failed_xp', Config.ExpTakeAmount), 'error')
    end
end)

RegisterNetEvent('peleg-pizzajob:server:saveSelectedVehicle', function(vehicleModel)
    local src = source
    PlayerModule.setPlayerMetadata(src, 'pizza_selected_vehicle', vehicleModel)
end)

RegisterNetEvent('peleg-pizzajob:server:storePizzas', function(quantity)
    local src = source
    local hasEnough = PlayerModule.hasItem(src, 'pizza_delivery_box', quantity)
    
    if hasEnough then
        PlayerModule.removeItem(src, 'pizza_delivery_box', quantity)
        Utils.notify(src, _L('stored_pizzas_success', quantity), 'success')
    else
        Utils.notify(src, _L('not_enough_pizza_boxes'), 'error')
    end
end)
