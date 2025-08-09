---Vehicle Management Module
---@class VehicleModule
local VehicleModule = {}

-- Load dependencies
local Utils = require('shared.utils')
local JobModule = require('client.modules.job')
JobModule.setVehicleModule(VehicleModule)

-- Local variables
local currentVehicle = nil
local vehicleBlip = nil
local deliveryBlip = nil
local lastSpawnedPlate = nil

---Spawn delivery vehicle
---@param model string Vehicle model name
---@param coords vector4 Spawn coordinates and heading
---@return number|nil Vehicle entity ID or nil on failure
function VehicleModule.spawnVehicle(model, coords)
    local hash = GetHashKey(model)
    
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(0)
    end
    
    local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, coords.w, true, false)
    
    if DoesEntityExist(vehicle) then
        SetEntityAsMissionEntity(vehicle, true, true)
        SetVehicleEngineOn(vehicle, false, true, true)
        SetVehicleFuelLevel(vehicle, 100.0)
        
        -- Set vehicle properties
        SetVehicleNumberPlateText(vehicle, "PIZZA")
        SetVehicleCustomPrimaryColour(vehicle, 255, 255, 255)
        SetVehicleCustomSecondaryColour(vehicle, 255, 255, 255)
        
        -- Set vehicle livery if configured
        if Config.UseDefultVehicles then
            SetVehicleLivery(vehicle, 0)
        end
        
        currentVehicle = vehicle
        VehicleModule.createVehicleBlip(vehicle)
        
        return vehicle
    end
    
    return nil
end

---Delete current vehicle
function VehicleModule.deleteVehicle()
    if currentVehicle and DoesEntityExist(currentVehicle) then
        DeleteEntity(currentVehicle)
        currentVehicle = nil
    end
    
    if vehicleBlip then
        RemoveBlip(vehicleBlip)
        vehicleBlip = nil
    end
end

---Create blip for vehicle
---@param vehicle number Vehicle entity ID
function VehicleModule.createVehicleBlip(vehicle)
    if vehicleBlip then
        RemoveBlip(vehicleBlip)
    end
    
    vehicleBlip = AddBlipForEntity(vehicle)
    SetBlipSprite(vehicleBlip, 1)
    SetBlipColour(vehicleBlip, 2)
    SetBlipScale(vehicleBlip, 0.8)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Utils.locale('delivery_vehicle'))
    EndTextCommandSetBlipName(vehicleBlip)
end

---Create delivery destination blip
---@param coords vector3 Delivery coordinates
function VehicleModule.createDeliveryBlip(coords)
    if deliveryBlip then
        RemoveBlip(deliveryBlip)
    end
    
    deliveryBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(deliveryBlip, 1)
    SetBlipColour(deliveryBlip, 2)
    SetBlipScale(deliveryBlip, 0.8)
    SetBlipRoute(deliveryBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Utils.locale('delivery_destination'))
    EndTextCommandSetBlipName(deliveryBlip)
end

---Remove delivery blip
function VehicleModule.removeDeliveryBlip()
    if deliveryBlip then
        RemoveBlip(deliveryBlip)
        deliveryBlip = nil
    end
end

---Check if player is in delivery vehicle
---@return boolean True if in delivery vehicle
function VehicleModule.isInDeliveryVehicle()
    local ped = PlayerPedId()
    local vehicle = Utils.getCurrentVehicle(ped)
    
    if vehicle and vehicle == currentVehicle then
        return Utils.isDeliveryVehicle(vehicle)
    end
    
    return false
end

---Get current vehicle info
---@return table Vehicle information
function VehicleModule.getCurrentVehicleInfo()
    if not currentVehicle or not DoesEntityExist(currentVehicle) then
        return { name = Utils.locale('no_vehicle'), model = nil }
    end
    
    local model = GetEntityModel(currentVehicle)
    for _, vehicleData in pairs(Config.VehicleGarage.Vehicles) do
        if GetHashKey(vehicleData.model) == model then
            return vehicleData
        end
    end
    
    return { name = Utils.locale('unknown_vehicle'), model = nil }
end

---Show vehicle garage menu
function VehicleModule.showGarageMenu()
    local playerLevel = JobModule.getPlayerLevel()
    local options = {}
    
    for _, vehicleData in pairs(Config.VehicleGarage.Vehicles) do
        local canSpawn = Utils.hasRequiredLevel(vehicleData.level, playerLevel)
        local levelInfo = Utils.getLevelInfo(vehicleData.level)
        
        table.insert(options, {
            title = vehicleData.name,
            description = vehicleData.description,
            icon = 'fas fa-car',
            iconColor = canSpawn and levelInfo.color or '#666666',
            metadata = {
                { label = Utils.locale('required_level'), value = vehicleData.level },
                { label = Utils.locale('level_name'), value = levelInfo.name },
                { label = Utils.locale('status'), value = canSpawn and Utils.locale('available') or Utils.locale('level_required') }
            },
            onSelect = function()
                if canSpawn then
                    VehicleModule.spawnVehicleFromGarage(vehicleData.model)
                else
                    Utils.notify(Utils.locale('level_required_message', vehicleData.level), 'error')
                end
            end
        })
    end
    
    lib.registerContext({
        id = 'vehicle_garage_menu',
        title = Utils.locale('vehicle_garage'),
        options = options
    })
    
    lib.showContext('vehicle_garage_menu')
end

---Spawn vehicle from garage
---@param model string Vehicle model name
function VehicleModule.spawnVehicleFromGarage(model)
    if currentVehicle and DoesEntityExist(currentVehicle) then
        Utils.notify(Utils.locale('vehicle_already_spawned'), 'error')
        return
    end
    
    local spawnCoords = Config.VehicleGarage.SpawnLocation
    local vehicle = VehicleModule.spawnVehicle(model, spawnCoords)
    
    if vehicle then
        local ped = PlayerPedId()
        TaskWarpPedIntoVehicle(ped, vehicle, -1)
        -- Vehicle keys support
        local plate = GetVehicleNumberPlateText(vehicle)
        lastSpawnedPlate = plate
        if GetResourceState('qb-vehiclekeys') == 'started' then
            TriggerEvent('qb-vehiclekeys:client:AddKeys', plate)
        elseif GetResourceState('qbx_vehiclekeys') == 'started' then
            TriggerEvent('qbx_vehiclekeys:client:GiveKeys', plate)
        elseif GetResourceState('wasabi_carlock') == 'started' then
            TriggerEvent('wasabi_carlock:client:GiveKeys', plate)
        elseif GetResourceState('mk_vehiclekeys') == 'started' then
            TriggerEvent('mk_vehiclekeys:client:AddKeys', plate)
        end
        if JobModule and JobModule.startJob then
            Wait(100)
            JobModule.startJob(true)
        end
    else
        Utils.notify(Utils.locale('vehicle_spawn_failed'), 'error')
    end
end

---Check vehicle fuel level
---@return number Fuel percentage (0-100)
function VehicleModule.getFuelLevel()
    if not currentVehicle or not DoesEntityExist(currentVehicle) then
        return 0
    end
    
    return GetVehicleFuelLevel(currentVehicle)
end

---Refuel vehicle
---@param amount number Fuel amount to add
function VehicleModule.refuelVehicle(amount)
    if not currentVehicle or not DoesEntityExist(currentVehicle) then
        return false
    end
    
    local currentFuel = GetVehicleFuelLevel(currentVehicle)
    local newFuel = math.min(100.0, currentFuel + amount)
    SetVehicleFuelLevel(currentVehicle, newFuel)
    
    return true
end

---Get vehicle damage status
---@return table Damage information
function VehicleModule.getVehicleDamage()
    if not currentVehicle or not DoesEntityExist(currentVehicle) then
        return { engine = 0, body = 0, fuel = 0 }
    end
    
    return {
        engine = GetVehicleEngineHealth(currentVehicle),
        body = GetVehicleBodyHealth(currentVehicle),
        fuel = GetVehicleFuelLevel(currentVehicle)
    }
end

---Repair vehicle
function VehicleModule.repairVehicle()
    if not currentVehicle or not DoesEntityExist(currentVehicle) then
        return false
    end
    
    SetVehicleEngineHealth(currentVehicle, 1000.0)
    SetVehicleBodyHealth(currentVehicle, 1000.0)
    SetVehicleFuelLevel(currentVehicle, 100.0)
    
    return true
end

return VehicleModule 