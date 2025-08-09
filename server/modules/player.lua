---Player Management Module
---Handles player data, inventory, and metadata operations using the bridge system
---@class PlayerModule
local PlayerModule = {}

local Bridge = require('shared.bridge.init')
local Inventory = require('shared.inventory')

---Get player data using the bridge system
---@param source number Player source ID
---@return table|nil Player data or nil if not found
function PlayerModule.getPlayerData(source)
    return Bridge.getPlayerData(source)
end

---Get player metadata
---@param source number Player source ID
---@param key string Metadata key
---@return any Metadata value
function PlayerModule.getPlayerMetadata(source, key)
    local Player = PlayerModule.getPlayerData(source)
    if not Player then return nil end
    
    if Bridge.name == 'esx' then
        local xPlayer = Bridge.core.GetPlayerFromId(source)
        return xPlayer and xPlayer.getMetaData(key) or nil
    elseif Bridge.name == 'qb' then
        local qbPlayer = Bridge.core.Functions.GetPlayer(source)
        return qbPlayer and qbPlayer.PlayerData.metadata[key] or nil
    elseif Bridge.name == 'vrp' then
        local user_id = Bridge.core.getUserId({source})
        if user_id then
            return Bridge.core.getUserDataTable({user_id})[key]
        end
    end
    
    return nil
end

---Set player metadata
---@param source number Player source ID
---@param key string Metadata key
---@param value any Metadata value
---@return boolean Success status
function PlayerModule.setPlayerMetadata(source, key, value)
    local Player = PlayerModule.getPlayerData(source)
    if not Player then return false end
    
    if Bridge.name == 'esx' then
        local xPlayer = Bridge.core.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.setMetaData(key, value)
            return true
        end
    elseif Bridge.name == 'qb' then
        local qbPlayer = Bridge.core.Functions.GetPlayer(source)
        if qbPlayer then
            qbPlayer.Functions.SetMetaData(key, value)
            return true
        end
    elseif Bridge.name == 'vrp' then
        local user_id = Bridge.core.getUserId({source})
        if user_id then
            local userData = Bridge.core.getUserDataTable({user_id})
            userData[key] = value
            return true
        end
    end
    
    return false
end

---Give money to player
---@param source number Player source ID
---@param type string Money type ('cash', 'bank', 'black_money')
---@param amount number Amount to give
---@return boolean Success status
function PlayerModule.addMoney(source, type, amount)
    return Bridge.addPlayerMoney(source, type, amount)
end

---Remove money from player
---@param source number Player source ID
---@param type string Money type ('cash', 'bank', 'black_money')
---@param amount number Amount to remove
---@return boolean Success status
function PlayerModule.removeMoney(source, type, amount)
    return Bridge.removePlayerMoney(source, type, amount)
end

---Get player money
---@param source number Player source ID
---@param type string Money type ('cash', 'bank', 'black_money')
---@return number Money amount
function PlayerModule.getMoney(source, type)
    return Bridge.getPlayerMoney(source, type)
end

---Give item to player
---@param source number Player source ID
---@param item string Item name
---@param amount number Amount to give
---@return boolean Success status
function PlayerModule.addItem(source, item, amount)
    local success = Inventory.addItem(source, item, amount)
    if success and Config.Inventory == 'qb' and Bridge.name == 'qb' then
        TriggerClientEvent('inventory:client:ItemBox', source, Bridge.core.Shared.Items[item], 'add')
    end
    return success
end

---Remove item from player
---@param source number Player source ID
---@param item string Item name
---@param amount number Amount to remove
---@return boolean Success status
function PlayerModule.removeItem(source, item, amount)
    local success = Inventory.removeItem(source, item, amount)
    if success and Config.Inventory == 'qb' and Bridge.name == 'qb' then
        TriggerClientEvent('inventory:client:ItemBox', source, Bridge.core.Shared.Items[item], 'remove')
    end
    return success
end

---Get item count from player inventory
---@param source number Player source ID
---@param item string Item name
---@return number Item count
function PlayerModule.getItemCount(source, item)
    return Inventory.getItemCount(source, item)
end

---Check if player has item
---@param source number Player source ID
---@param item string Item name
---@param amount number Required amount (default: 1)
---@return boolean Has item
function PlayerModule.hasItem(source, item, amount)
    amount = amount or 1
    return PlayerModule.getItemCount(source, item) >= amount
end

return PlayerModule