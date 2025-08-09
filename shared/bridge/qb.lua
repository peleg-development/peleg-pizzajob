---QB-Core Framework Bridge Implementation
---@class QBBridge
---@field name string Framework name
---@field core table QB-Core core object
local QBBridge = {}

---@type QBBridge
local bridge = {}

local QBCore = exports['qb-core']:GetCoreObject()

bridge.name = 'qb'
bridge.core = QBCore

---Get player data from QB-Core
---@param source number Player source ID
---@return table|nil Player data or nil if not found
function bridge.getPlayerData(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return nil end
    
    return {
        source = source,
        identifier = Player.PlayerData.citizenid,
        name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        job = Player.PlayerData.job,
        inventory = Player.PlayerData.items,
        money = {
            cash = Player.PlayerData.money.cash,
            bank = Player.PlayerData.money.bank,
            black_money = Player.PlayerData.money.crypto
        }
    }
end

---Get player money by type
---@param source number Player source ID
---@param type string Money type ('cash', 'bank', 'black_money')
---@return number Money amount
function bridge.getPlayerMoney(source, type)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return 0 end
    
    if type == 'cash' then
        return Player.PlayerData.money.cash
    elseif type == 'bank' then
        return Player.PlayerData.money.bank
    elseif type == 'black_money' then
        return Player.PlayerData.money.crypto
    end
    
    return 0
end

---Add money to player
---@param source number Player source ID
---@param type string Money type ('cash', 'bank', 'black_money')
---@param amount number Amount to add
---@return boolean Success status
function bridge.addPlayerMoney(source, type, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    Player.Functions.AddMoney(type, amount)
    return true
end

---Remove money from player
---@param source number Player source ID
---@param type string Money type ('cash', 'bank', 'black_money')
---@param amount number Amount to remove
---@return boolean Success status
function bridge.removePlayerMoney(source, type, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    Player.Functions.RemoveMoney(type, amount)
    return true
end

---Add item to player inventory
---@param source number Player source ID
---@param item string Item name
---@param amount number Amount to add
---@return boolean Success status
function bridge.addPlayerItem(source, item, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    Player.Functions.AddItem(item, amount)
    return true
end

---Remove item from player inventory
---@param source number Player source ID
---@param item string Item name
---@param amount number Amount to remove
---@return boolean Success status
function bridge.removePlayerItem(source, item, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    Player.Functions.RemoveItem(item, amount)
    return true
end

---Get player item count
---@param source number Player source ID
---@param item string Item name
---@return number Item count
function bridge.getPlayerItem(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return 0 end
    
    local itemData = Player.Functions.GetItemByName(item)
    return itemData and itemData.amount or 0
end

---Send notification to player
---@param source number Player source ID
---@param message string Message to send
---@param type string Notification type
function bridge.notify(source, message, type)
    TriggerClientEvent('QBCore:Notify', source, message, type)
end

---Add command to QB-Core
---@param name string Command name
---@param description string Command description
---@param callback function Command callback function
function bridge.addCommand(name, description, callback)
    QBCore.Commands.Add(name, description, {}, false, callback)
end

return bridge 