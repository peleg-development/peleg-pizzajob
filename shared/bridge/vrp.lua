---VRP Framework Bridge Implementation
---@class VRPBridge
---@field name string Framework name
---@field core table VRP core object
local VRPBridge = {}

---@type VRPBridge
local bridge = {}

local Proxy = module("vrp", "lib/Proxy")
local Tunnel = module("vrp", "lib/Tunnel")
local vRP = Proxy.getInterface("vRP")
local vRPclient = Tunnel.getInterface("vRP", "pizza_job")

bridge.name = 'vrp'
bridge.core = vRP

---Get player data from VRP
---@param source number Player source ID
---@return table|nil Player data or nil if not found
function bridge.getPlayerData(source)
    local user_id = vRP.getUserId({source})
    if not user_id then return nil end
    
    return {
        source = source,
        identifier = user_id,
        name = vRP.getPlayerName({source}),
        job = nil,
        inventory = vRP.getInventory({user_id}),
        money = {
            cash = vRP.getMoney({user_id}),
            bank = vRP.getBankMoney({user_id}),
            black_money = 0
        }
    }
end

---Get player money by type
---@param source number Player source ID
---@param type string Money type ('cash', 'bank', 'black_money')
---@return number Money amount
function bridge.getPlayerMoney(source, type)
    local user_id = vRP.getUserId({source})
    if not user_id then return 0 end
    
    if type == 'cash' then
        return vRP.getMoney({user_id})
    elseif type == 'bank' then
        return vRP.getBankMoney({user_id})
    elseif type == 'black_money' then
        return 0
    end
    
    return 0
end

---Add money to player
---@param source number Player source ID
---@param type string Money type ('cash', 'bank', 'black_money')
---@param amount number Amount to add
---@return boolean Success status
function bridge.addPlayerMoney(source, type, amount)
    local user_id = vRP.getUserId({source})
    if not user_id then return false end
    
    if type == 'cash' then
        vRP.giveMoney({user_id, amount})
    elseif type == 'bank' then
        vRP.giveBankMoney({user_id, amount})
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
    local user_id = vRP.getUserId({source})
    if not user_id then return false end
    
    if type == 'cash' then
        return vRP.tryPayment({user_id, amount})
    elseif type == 'bank' then
        return vRP.tryBankPayment({user_id, amount})
    else
        return false
    end
end

---Add item to player inventory
---@param source number Player source ID
---@param item string Item name
---@param amount number Amount to add
---@return boolean Success status
function bridge.addPlayerItem(source, item, amount)
    local user_id = vRP.getUserId({source})
    if not user_id then return false end
    
    return vRP.giveInventoryItem({user_id, item, amount, true})
end

---Remove item from player inventory
---@param source number Player source ID
---@param item string Item name
---@param amount number Amount to remove
---@return boolean Success status
function bridge.removePlayerItem(source, item, amount)
    local user_id = vRP.getUserId({source})
    if not user_id then return false end
    
    return vRP.tryGetInventoryItem({user_id, item, amount, true})
end

---Get player item count
---@param source number Player source ID
---@param item string Item name
---@return number Item count
function bridge.getPlayerItem(source, item)
    local user_id = vRP.getUserId({source})
    if not user_id then return 0 end
    
    return vRP.getInventoryItemAmount({user_id, item})
end

---Send notification to player
---@param source number Player source ID
---@param message string Message to send
---@param type string Notification type
function bridge.notify(source, message, type)
    vRPclient.notify(source, {message})
end

---Add command to VRP
---@param name string Command name
---@param description string Command description
---@param callback function Command callback function
function bridge.addCommand(name, description, callback)
    local function vrpCallback(player)
        local source = vRP.getUserSource({player})
        if source then
            callback(source)
        end
    end
    
    vRP.registerConsoleCommand({name, vrpCallback})
end

return bridge 