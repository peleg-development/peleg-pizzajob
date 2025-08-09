---@class Bridge
---@field name string Framework name
---@field getPlayerData fun(source: number): table Player data
---@field getPlayerMoney fun(source: number, type: string): number Player money
---@field addPlayerMoney fun(source: number, type: string, amount: number): boolean Add money
---@field removePlayerMoney fun(source: number, type: string, amount: number): boolean Remove money
---@field addPlayerItem fun(source: number, item: string, amount: number): boolean Add item
---@field removePlayerItem fun(source: number, item: string, amount: number): boolean Remove item
---@field getPlayerItem fun(source: number, item: string): number Get item count
---@field notify fun(source: number, message: string, type: string): void Send notification
---@field addCommand fun(name: string, description: string, callback: function): void Add command

---@type Bridge
Bridge = {}

---Detects and initializes the appropriate framework bridge
---@return Bridge
local function InitializeBridge()
    local framework = GetConvar('framework', 'qb-core')
    
    if framework == 'vrp' or GetResourceState('vrp') == 'started' then
        return require('shared.bridge.vrp')
    elseif framework == 'es_extended' or GetResourceState('es_extended') == 'started' then
        return require('shared.bridge.esx')
    elseif framework == 'qb-core' or GetResourceState('qb-core') == 'started' then
        return require('shared.bridge.qb')
    else
        error('No supported framework detected. Please ensure vrp, es_extended or qb-core is running.')
    end
end

Bridge = InitializeBridge()

exports('GetBridge', function()
    return Bridge
end) 

return Bridge