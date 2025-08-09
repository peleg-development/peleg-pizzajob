---Pizza Making Module
---@class PizzaModule
local PizzaModule = {}

-- Load dependencies
local Utils = require('shared.utils')

-- Local variables
local isMakingPizzas = false
local pizzaMakingThread = nil
local pizzaProp = nil

---Start pizza making process
function PizzaModule.startMakingPizzas()
    if isMakingPizzas then
        PizzaModule.stopMakingPizzas()
        return
    end
    
    -- Check if physical location is enabled and player is close enough
    if Config.PizzaMakingLocation.Enabled then
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = Utils.getDistance(playerCoords, Config.PizzaMakingLocation.Location)
        
        if distance > 3.0 then
            Utils.notify(Utils.locale('need_pizza_kitchen'), 'error')
            return
        end
    end
    
    isMakingPizzas = true
    PizzaModule.createPizzaProp()
    
    if Config.PizzaMakingLocation.Enabled then
        Utils.notify(Utils.locale('pizza_making_started_kitchen'), 'success')
    else
        Utils.notify(Utils.locale('pizza_making_started_menu'), 'success')
    end
    
    PizzaModule.startPizzaMakingThread()
    
    -- Show stop menu if using menu-based pizza making
    if not Config.PizzaMakingLocation.Enabled then
        PizzaModule.showPizzaMakingMenu()
    end
end

---Stop pizza making process
function PizzaModule.stopMakingPizzas()
    if not isMakingPizzas then return end
    
    isMakingPizzas = false
    PizzaModule.removePizzaProp()
    
    if pizzaMakingThread then
        pizzaMakingThread = nil
    end
    
    Utils.notify(Utils.locale('pizza_making_stopped'), 'error')
    
    -- Show main menu if using menu-based pizza making
    if not Config.PizzaMakingLocation.Enabled then
        JobModule.showJobMenu()
    end
end

---Start pizza making thread
function PizzaModule.startPizzaMakingThread()
    pizzaMakingThread = CreateThread(function()
        while isMakingPizzas do
            -- Check if player moved away from physical location
            if Config.PizzaMakingLocation.Enabled then
                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = Utils.getDistance(playerCoords, Config.PizzaMakingLocation.Location)
                
                if distance > 5.0 then
                    PizzaModule.stopMakingPizzas()
                    Utils.notify(Utils.locale('pizza_making_too_far'), 'error')
                    break
                end
            end
            
            local makingTime = math.random(3000, 6000) -- Random time between 3-6 seconds
            
            local success = lib.progressBar({
                duration = makingTime,
                label = Utils.locale('making_pizza'),
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                    move = true,
                    combat = true,
                },
                anim = {
                    dict = 'amb@prop_human_bbq@male@base',
                    clip = 'base'
                },
                prop = {
                    model = 'prop_pizza_box_01',
                    pos = vector3(0.05, 0.02, -0.02),
                    rot = vector3(0.0, 0.0, 180.0),
                    bone = 18905
                }
            })
            
            if success and isMakingPizzas then
                TriggerServerEvent('peleg-pizzajob:server:givePizzaBox')
                
                Utils.notify(Utils.locale('pizza_made_success'), 'success')
                
                Wait(1000)
            else
                PizzaModule.stopMakingPizzas()
                break
            end
        end
    end)
end

---Create pizza prop
function PizzaModule.createPizzaProp()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    local propHash = GetHashKey('prop_pizza_box_01')
    RequestModel(propHash)
    while not HasModelLoaded(propHash) do
        Wait(0)
    end
    
    pizzaProp = CreateObject(propHash, coords.x, coords.y, coords.z, true, true, true)
    AttachEntityToEntity(pizzaProp, ped, GetPedBoneIndex(ped, 18905), 0.05, 0.02, -0.02, 0.0, 0.0, 180.0, true, true, false, true, 1, true)
end

---Remove pizza prop
function PizzaModule.removePizzaProp()
    if pizzaProp and DoesEntityExist(pizzaProp) then
        DeleteEntity(pizzaProp)
        pizzaProp = nil
    end
end

---Show pizza making control menu
function PizzaModule.showPizzaMakingMenu()
    lib.registerContext({
        id = 'pizza_making_menu',
        title = Utils.locale('making_pizzas_title'),
        options = {
            {
                title = Utils.locale('stop_making_pizzas'),
                description = Utils.locale('stop_making_pizzas_desc'),
                icon = 'fas fa-stop',
                iconColor = 'red',
                onSelect = function()
                    PizzaModule.stopMakingPizzas()
                end
            },
            {
                title = Utils.locale('check_stats'),
                description = Utils.locale('stats_desc'),
                icon = 'fas fa-chart-line',
                iconColor = 'blue',
                onSelect = function()
                    PizzaModule.showStatsMenu()
                end
            }
        }
    })
    
    lib.showContext('pizza_making_menu')
end

---Show stats menu
function PizzaModule.showStatsMenu()
    local currentLevel = JobModule.getPlayerLevel()
    local currentExp = JobModule.getPlayerExp()
    local currentNextIn = Utils.getExpForNextLevel(currentExp, currentLevel)
    local currentLevelName = Utils.getLevelInfo(currentLevel).name
    
    lib.registerContext({
        id = 'pizza_stats_menu',
        title = Utils.locale('stats_main_title'),
        options = {
            {
                title = Utils.locale('level_title', currentLevel, currentLevelName),
                description = Utils.locale('current_experience', currentExp),
                icon = 'fas fa-star',
                iconColor = Utils.getLevelInfo(currentLevel).color,
                progress = Utils.getLevelProgress(currentExp, currentLevel),
                colorScheme = 'blue',
                readOnly = true,
                metadata = {
                    { label = Utils.locale('next_level_in'), value = currentNextIn > 0 and Utils.locale('experience_needed', currentNextIn) or Utils.locale('max_level') },
                    { label = Utils.locale('progress'), value = string.format('%d%%', Utils.getLevelProgress(currentExp, currentLevel)) }
                }
            },
            {
                title = Utils.locale('back'),
                description = Utils.locale('back_to_pizza_making'),
                icon = 'fas fa-arrow-left',
                onSelect = function()
                    PizzaModule.showPizzaMakingMenu()
                end
            }
        }
    })
    
    lib.showContext('pizza_stats_menu')
end

---Check if player is making pizzas
---@return boolean True if making pizzas
function PizzaModule.isMakingPizzas()
    return isMakingPizzas
end

---Setup pizza making location
function PizzaModule.setupPizzaLocation()
    if not Config.PizzaMakingLocation.Enabled then return end
    
    -- Create blip if enabled
    if Config.PizzaMakingLocation.UseBlip then
        local pizzaKitchenBlip = AddBlipForCoord(Config.PizzaMakingLocation.Location)
        SetBlipSprite(pizzaKitchenBlip, Config.PizzaMakingLocation.BlipSprite)
        SetBlipAsShortRange(pizzaKitchenBlip, true)
        SetBlipScale(pizzaKitchenBlip, 0.8)
        SetBlipColour(pizzaKitchenBlip, Config.PizzaMakingLocation.BlipColor)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Utils.locale('pizza_oven'))
        EndTextCommandSetBlipName(pizzaKitchenBlip)
    end
    
    -- Add target zone for pizza making
    if Config.Target == 'ox_target' then
        exports.ox_target:addBoxZone({
            coords = Config.PizzaMakingLocation.Location,
            size = vector3(2, 2, 3),
            rotation = 0,
            options = {
                {
                    name = 'pizza_making',
                    icon = 'fa-solid fa-pizza-slice',
                    label = Utils.locale('make_pizzas'),
                    onSelect = function()
                        PizzaModule.startMakingPizzas()
                    end,
                    canInteract = function()
                        return not isMakingPizzas
                    end
                }
            }
        })
    end
end

---Draw 3D marker for pizza making location
function PizzaModule.drawPizzaMarker()
    if not Config.PizzaMakingLocation.Enabled or not Config.PizzaMakingLocation.Use3DMarker then
        return
    end
    
    local markerConfig = Config.PizzaMakingLocation
    local playerCoords = GetEntityCoords(PlayerPedId())
    local distance = Utils.getDistance(playerCoords, markerConfig.Location)
    
    if distance <= markerConfig.MarkerDrawDistance then
        DrawMarker(
            markerConfig.MarkerType,
            markerConfig.Location.x,
            markerConfig.Location.y,
            markerConfig.Location.z,
            0.0, 0.0, 0.0,
            0.0, 0.0, 0.0,
            markerConfig.MarkerSize.x,
            markerConfig.MarkerSize.y,
            markerConfig.MarkerSize.z,
            markerConfig.MarkerColor.r,
            markerConfig.MarkerColor.g,
            markerConfig.MarkerColor.b,
            markerConfig.MarkerColor.a,
            markerConfig.MarkerBobUpAndDown,
            markerConfig.MarkerFaceCamera,
            2,
            markerConfig.MarkerRotate,
            nil, nil, false
        )
    end
end

return PizzaModule 