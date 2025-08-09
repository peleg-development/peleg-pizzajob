---ESX Framework Bridge Implementation
---@class ESXBridge
---@field name string Framework name
---@field core table ESX core object
local ESXBridge = {}

---@type ESXBridge
local bridge = {}

local ESX = exports['es_extended']:getSharedObject()

bridge.name = 'esx'
bridge.core = ESX

---Get player data from ESX
---@param source number Player source ID
---@return table|nil Player data or nil if not found
function bridge.getPlayerData(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return nil end
    
    return {
        source = source,
        identifier = xPlayer.identifier,
        name = xPlayer.getName(),
        job = xPlayer.job,
        inventory = xPlayer.getInventory(),
        money = {
            cash = xPlayer.getMoney(),
            bank = xPlayer.getAccount('bank').money,
            black_money = xPlayer.getAccount('black_money').money
        }
    }
end

---Get player money by type
---@param source number Player source ID
---@param type string Money type ('cash', 'bank', 'black_money')
---@return number Money amount
function bridge.getPlayerMoney(source, type)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return 0 end
    
    if type == 'cash' then
        return xPlayer.getMoney()
    elseif type == 'bank' then
        return xPlayer.getAccount('bank').money
    elseif type == 'black_money' then
        return xPlayer.getAccount('black_money').money
    end
    
    return 0
end

---Add money to player
---@param source number Player source ID
---@param type string Money type ('cash', 'bank', 'black_money')
---@param amount number Amount to add
---@return boolean Success status
function bridge.addPlayerMoney(source, type, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    
    if type == 'cash' then
        xPlayer.addMoney(amount)
    elseif type == 'bank' then
        xPlayer.addAccountMoney('bank', amount)
    elseif type == 'black_money' then
        xPlayer.addAccountMoney('black_money', amount)
    else
        return false
    end
    
    return true
end

---Remove money from player
---@param source number Player source ID
---@param type string Money type ('cash', 'bank', 'black_money')
---@param amount number Amount to remove
---@return boolean Success status
function bridge.removePlayerMoney(source, type, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    
    if type == 'cash' then
        xPlayer.removeMoney(amount)
    elseif type == 'bank' then
        xPlayer.removeAccountMoney('bank', amount)
    elseif type == 'black_money' then
        xPlayer.removeAccountMoney('black_money', amount)
    else
        return false
    end
    
    return true
end

---Add item to player inventory
---@param source number Player source ID
---@param item string Item name
---@param amount number Amount to add
---@return boolean Success status
function bridge.addPlayerItem(source, item, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    
    xPlayer.addInventoryItem(item, amount)
    return true
end

---Remove item from player inventory
---@param source number Player source ID
---@param item string Item name
---@param amount number Amount to remove
---@return boolean Success status
function bridge.removePlayerItem(source, item, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    
    xPlayer.removeInventoryItem(item, amount)
    return true
end

---Get player item count
---@param source number Player source ID
---@param item string Item name
---@return number Item count
function bridge.getPlayerItem(source, item)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return 0 end
    
    local inventoryItem = xPlayer.getInventoryItem(item)
    return inventoryItem and inventoryItem.count or 0
end

---Send notification to player
---@param source number Player source ID
---@param message string Message to send
---@param type string Notification type
function bridge.notify(source, message, type)
    TriggerClientEvent('esx:showNotification', source, message)
end

---Add command to ESX
---@param name string Command name
---@param description string Command description
---@param callback function Command callback function
function bridge.addCommand(name, description, callback)
    ESX.RegisterCommand(name, 'user', callback, false, {help = description})
end

return bridge 