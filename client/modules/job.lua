---Job Management Module
---@class JobModule
local JobModule = {}

-- Load dependencies
local Utils = require('shared.utils')
local VehicleModule = nil

---Inject vehicle module to avoid circular dependency
---@param mod table
function JobModule.setVehicleModule(mod)
    VehicleModule = mod
end

-- Local variables
local isOnDuty = false
local currentDelivery = nil
local deliveryCount = 0
local deliveryTimer = nil
local deliveryStartTime = nil
local playerLevel = 1
local playerExp = 0

---Start pizza delivery job
function JobModule.startJob(skipVehicleCheck)
    if isOnDuty then
        Utils.notify(Utils.locale('already_on_duty'), 'error')
        return
    end
    
    -- VehicleModule will be passed from main.lua to avoid circular dependency
    if not skipVehicleCheck and (not VehicleModule or not VehicleModule.isInDeliveryVehicle()) then
        Utils.notify(Utils.locale('need_delivery_vehicle'), 'error')
        return
    end
    
    isOnDuty = true
    deliveryCount = 0
    JobModule.startNewDelivery()
    
    Utils.notify(Utils.locale('job_started'), 'success')
end

---Stop pizza delivery job
function JobModule.stopJob()
    if not isOnDuty then
        Utils.notify(Utils.locale('not_on_duty'), 'error')
        return
    end
    
    isOnDuty = false
    JobModule.cancelCurrentDelivery()
    VehicleModule.deleteVehicle()
    
    Utils.notify(Utils.locale('job_stopped'), 'inform')
end

---Start new delivery
function JobModule.startNewDelivery()
    if not isOnDuty then return end
    -- ask server to authoritatively pick a delivery
    local deliveryLocation = lib.callback.await('peleg-pizzajob:server:newDelivery', false)
    if not deliveryLocation then return end
    currentDelivery = {
        location = deliveryLocation,
        startTime = GetGameTimer(),
        completed = false
    }
    
    if VehicleModule then
        VehicleModule.createDeliveryBlip(deliveryLocation)
    end
    JobModule.startDeliveryTimer()
    -- Add target/3D interaction at delivery spot: secure flow with progress bar + server check
    Utils.addTargetZone(deliveryLocation, {
        {
            icon = 'fa-solid fa-pizza-slice',
            label = Utils.locale('deliver_pizza'),
            action = function()
                if currentDelivery and not currentDelivery.completed and JobModule.isNearDelivery(GetEntityCoords(PlayerPedId())) then
                    local ok = lib.progressBar({
                        duration = 2000,
                        label = Utils.locale('deliver_the_pizza'),
                        useWhileDead = false,
                        canCancel = true,
                        disable = { move = true, combat = true, car = true },
                        anim = { dict = 'timetable@jimmy@doorknock@', clip = 'knockdoor_idle' }
                    })
                    if not ok then return end
                    JobModule.completeDelivery()
                end
            end,
            canInteract = function()
                return currentDelivery ~= nil and not currentDelivery.completed
            end
        }
    }, 'pizza_delivery_zone')
    
    -- silent start
end

---Complete current delivery
function JobModule.completeDelivery()
    if not currentDelivery or currentDelivery.completed then
        return
    end
    
    local deliveryTime = GetGameTimer() - currentDelivery.startTime
    local distance = Utils.getDistance(GetEntityCoords(PlayerPedId()), currentDelivery.location)
    
    deliveryCount = deliveryCount + 1
    currentDelivery.completed = true
    
    JobModule.stopDeliveryTimer()
    VehicleModule.removeDeliveryBlip()
    
    -- Calculate payout
    local payout = Utils.calculatePayout(distance, playerLevel, deliveryCount)
    
    -- Send completion to server
    TriggerServerEvent('peleg-pizzajob:server:completeDelivery', deliveryCount, payout, deliveryTime)
    
    -- Start next delivery after delay
    SetTimeout(3000, function()
        if isOnDuty then
            JobModule.startNewDelivery()
        end
    end)
end

---Cancel current delivery
function JobModule.cancelCurrentDelivery()
    if currentDelivery then
        JobModule.stopDeliveryTimer()
        VehicleModule.removeDeliveryBlip()
        -- remove target zone if using qb-target (ox_target zones auto overwrite)
        if Config.Target == 'qb-target' and exports['qb-target'] then
            exports['qb-target']:RemoveZone('pizza_delivery_zone')
        end
        currentDelivery = nil
    end
end

---Start delivery timer
function JobModule.startDeliveryTimer()
    if deliveryTimer then
        JobModule.stopDeliveryTimer()
    end
    
    deliveryStartTime = GetGameTimer()
    local timeLimit = Config.TimeLimitPerDelivery * 1000 -- Convert to milliseconds
    
    deliveryTimer = CreateThread(function()
        while currentDelivery and not currentDelivery.completed do
            local elapsed = GetGameTimer() - deliveryStartTime
            local remaining = timeLimit - elapsed
            
            if remaining <= 0 then
                JobModule.failDelivery()
                break
            end
            
            -- Update timer UI every second
            if elapsed % 1000 < 16 then -- Roughly every second
                JobModule.updateTimerUI(remaining / 1000)
            end
            
            Wait(16) -- ~60 FPS
        end
    end)
end

---Stop delivery timer
function JobModule.stopDeliveryTimer()
    if deliveryTimer then
        deliveryTimer = nil
        JobModule.hideTimerUI()
    end
end

---Fail current delivery
function JobModule.failDelivery()
    if not currentDelivery then return end
    
    currentDelivery.completed = true
    JobModule.stopDeliveryTimer()
    VehicleModule.removeDeliveryBlip()
    
    -- Notify server of failure
    TriggerServerEvent('peleg-pizzajob:server:failDelivery')
    
    Utils.notify(Utils.locale('delivery_failed'), 'error')
    
    -- Start new delivery after delay
    SetTimeout(5000, function()
        if isOnDuty then
            JobModule.startNewDelivery()
        end
    end)
end

---Update timer UI
---@param remainingSeconds number Remaining time in seconds
function JobModule.updateTimerUI(remainingSeconds)
    SendNUIMessage({
        type = 'updateTimer',
        time = Utils.formatTime(remainingSeconds),
        progress = (remainingSeconds / Config.TimeLimitPerDelivery) * 100
    })
end

---Hide timer UI
function JobModule.hideTimerUI()
    SendNUIMessage({
        type = 'hideTimer'
    })
end

---Check if player is on duty
---@return boolean True if on duty
function JobModule.isOnDuty()
    return isOnDuty
end

---Get current delivery info
---@return table|nil Current delivery data or nil
function JobModule.getCurrentDelivery()
    return currentDelivery
end

---Get delivery count
---@return number Number of completed deliveries
function JobModule.getDeliveryCount()
    return deliveryCount
end

---Get player level
---@return number Player level
function JobModule.getPlayerLevel()
    return playerLevel
end

---Get player experience
---@return number Player experience
function JobModule.getPlayerExp()
    return playerExp
end

---Update player stats from server
---@param level number New player level
---@param exp number New player experience
function JobModule.updatePlayerStats(level, exp)
    playerLevel = level
    playerExp = exp
end

---Show job menu
function JobModule.showJobMenu()
    local options = {
        {
            title = Utils.locale('job_status'),
            description = Utils.locale('current_job_status'),
            icon = 'fas fa-info-circle',
            iconColor = isOnDuty and '#00ff00' or '#ff0000',
            metadata = {
                { label = Utils.locale('status'), value = isOnDuty and Utils.locale('on_duty') or Utils.locale('off_duty') },
                { label = Utils.locale('deliveries'), value = deliveryCount },
                { label = Utils.locale('level'), value = playerLevel },
                { label = Utils.locale('experience'), value = playerExp }
            }
        }
    }
    
    if not isOnDuty then
        table.insert(options, {
            title = Utils.locale('start_job'),
            description = Utils.locale('start_job_desc'),
            icon = 'fas fa-play',
            iconColor = '#00ff00',
            onSelect = function()
                JobModule.startJob()
            end
        })
    else
        table.insert(options, {
            title = Utils.locale('stop_job'),
            description = Utils.locale('stop_job_desc'),
            icon = 'fas fa-stop',
            iconColor = '#ff0000',
            onSelect = function()
                JobModule.stopJob()
            end
        })
    end
    
    lib.registerContext({
        id = 'job_menu',
        title = Utils.locale('pizza_job'),
        options = options
    })
    
    lib.showContext('job_menu')
end

---Check delivery proximity
---@param coords vector3 Player coordinates
---@return boolean True if near delivery location
function JobModule.isNearDelivery(coords)
    if not currentDelivery then return false end
    
    local distance = Utils.getDistance(coords, currentDelivery.location)
    return distance <= 3.0
end

return JobModule 