---@class Inventory
---@field addItem fun(source: number, item: string, amount: number, metadata?: table, slot?: number): boolean
---@field removeItem fun(source: number, item: string, amount: number, metadata?: table, slot?: number): boolean
---@field getItemCount fun(source: number, item: string, metadata?: table): number
local Inventory = {}

local Bridge = require('shared.bridge.init')

---@return string
local function getInventoryType()
    return (Config and Config.Inventory) or 'qb'
end

---@param resource string
---@return boolean
local function isStarted(resource)
    return GetResourceState(resource) == 'started'
end

---@param source number
---@param item string
---@param amount number
---@param metadata? table
---@param slot? number
---@return boolean
function Inventory.addItem(source, item, amount, metadata, slot)
    local invType = getInventoryType()

    if invType == 'ox' and isStarted('ox_inventory') then
        local result = exports.ox_inventory:AddItem(source, item, amount, metadata, slot)
        return result and result ~= false
    end

    if (invType == 'qb' or invType == 'qs') and Bridge and Bridge.name == 'qb' then
        local Player = Bridge.core.Functions.GetPlayer(source)
        if not Player then return false end
        return Player.Functions.AddItem(item, amount, slot, metadata) and true or false
    end

    return false
end

---@param source number
---@param item string
---@param amount number
---@param metadata? table
---@param slot? number
---@return boolean
function Inventory.removeItem(source, item, amount, metadata, slot)
    local invType = getInventoryType()

    if invType == 'ox' and isStarted('ox_inventory') then
        local result = exports.ox_inventory:RemoveItem(source, item, amount, metadata, slot)
        return result and result ~= false
    end

    if (invType == 'qb' or invType == 'qs') and Bridge and Bridge.name == 'qb' then
        local Player = Bridge.core.Functions.GetPlayer(source)
        if not Player then return false end
        return Player.Functions.RemoveItem(item, amount, slot) and true or false
    end

    return false
end

---@param source number
---@param item string
---@param metadata? table
---@return number
function Inventory.getItemCount(source, item, metadata)
    local invType = getInventoryType()

    if invType == 'ox' and isStarted('ox_inventory') then
        local count = exports.ox_inventory:Search(source, 'count', item)
        return type(count) == 'number' and count or 0
    end

    if (invType == 'qb' or invType == 'qs') and Bridge and Bridge.name == 'qb' then
        local Player = Bridge.core.Functions.GetPlayer(source)
        if not Player then return 0 end
        local itemData = Player.Functions.GetItemByName(item)
        return (itemData and itemData.amount) or 0
    end

    return 0
end

return Inventory

