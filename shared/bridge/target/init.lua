---@class TargetBridge
---@field addTargetEntity fun(entity: number, options: table[]): void
---@field addTargetZone fun(coords: vector3, options: table[], id?: string, size?: vector3, rotation?: number): void
local TargetBridge = {}

local function isStarted(name)
    return GetResourceState(name) == 'started'
end

local function toOxOptions(options)
    local oxOptions = {}
    for _, opt in ipairs(options or {}) do
        oxOptions[#oxOptions + 1] = {
            name = opt.name or opt.label,
            icon = opt.icon,
            label = opt.label,
            onSelect = opt.action,
            canInteract = opt.canInteract
        }
    end
    return oxOptions
end

local function toQbOptions(options)
    local qbOptions = {}
    for _, opt in ipairs(options or {}) do
        qbOptions[#qbOptions + 1] = {
            icon = opt.icon,
            label = opt.label,
            action = opt.action,
            canInteract = opt.canInteract
        }
    end
    return qbOptions
end

function TargetBridge.addTargetEntity(entity, options)
    local target = (Config and Config.Target) or 'ox_target'

    if target == 'ox_target' and isStarted('ox_target') then
        exports.ox_target:addLocalEntity(entity, toOxOptions(options))
        return
    end

    if target == 'qb-target' and isStarted('qb-target') then
        exports['qb-target']:AddTargetEntity(entity, {
            options = toQbOptions(options),
            distance = 2.0
        })
        return
    end

    -- Fallback: no-op for draw3d here to keep logic simple
end

function TargetBridge.addTargetZone(coords, options, id, size, rotation)
    local target = (Config and Config.Target) or 'ox_target'
    local zoneId = id or ('pizza_zone_' .. math.random(10000, 99999))
    local zoneSize = size or vector3(2.0, 2.0, 2.0)
    local rot = rotation or 0.0

    if target == 'ox_target' and isStarted('ox_target') then
        exports.ox_target:addBoxZone({
            coords = coords,
            size = zoneSize,
            rotation = rot,
            options = toOxOptions(options)
        })
        return
    end

    if target == 'qb-target' and isStarted('qb-target') then
        local length, width = zoneSize.x, zoneSize.y
        exports['qb-target']:AddBoxZone(zoneId, coords, length, width, {
            name = zoneId,
            heading = rot,
            debugPoly = false,
            minZ = coords.z - (zoneSize.z / 2),
            maxZ = coords.z + (zoneSize.z / 2)
        }, {
            options = toQbOptions(options),
            distance = 2.0
        })
        return
    end

    -- Fallback: no-op for draw3d
end

return TargetBridge


