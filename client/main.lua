local VehicleModule = require('client.modules.vehicle')
require('client.modules.job').setVehicleModule(VehicleModule)
local Utils = require('shared.utils')
local QBCore = exports[Config.CoreResourceName]:GetCoreObject()
local Bridge = require('shared.bridge.init')
local Target = require('shared.bridge.target.init')
local npcPed = 0
local level = 0
local nextIn = 0
local exp = 0

---@return number
function GetLevel()
    return lib.callback.await('peleg-PizzaJob:CallBacks:getlevel', false)
end

---@return number
function GetExp()
    return lib.callback.await('peleg-PizzaJob:CallBacks:getexp', false)
end

---@return number
function GetNextLevelIn()
    return lib.callback.await('peleg-PizzaJob:CallBacks:getnextlevelin', false)
end

-- Pizza making variables
local makingPizzas = false
local pizzaMakingThread = nil

-- NPC Initialization
CreateThread(function()
    local npcModel = Config.NpcStart

    RequestModel(npcModel)
    while not HasModelLoaded(npcModel) do
        Citizen.Wait(500)
    end

    local npcCoords = Config.JobStartLocation
    npcPed = CreatePed(4, npcModel, npcCoords.x, npcCoords.y, npcCoords.z - 1.0, 0.0, false, true)
    TaskStandStill(npcPed, -1)
    SetEntityAsMissionEntity(npcPed, true, true)
    SetBlockingOfNonTemporaryEvents(npcPed, true)
    SetEntityInvincible(npcPed, true)
    FreezeEntityPosition(npcPed, true)

    -- Target entries
    Target.addTargetEntity(npcPed, {
        {
            icon = 'fas fa-briefcase',
            label = _L('start_job_menu'),
            action = function()
                TriggerEvent("peleg-pizzajob:client:StartJobFirst")
            end
        },
        {
            icon = 'fas fa-car',
            label = _L('vehicle_garage'),
            action = function()
                VehicleModule.showGarageMenu()
            end
        }
    })
end)

-- Event: Check Configs -- start with ui or not
RegisterNetEvent("peleg-pizzajob:client:StartJobFirst", function ()
    if Config.ShowJobUI then
        level = GetLevel()
        nextIn = GetNextLevelIn()
        exp = GetExp()
        print(exp, level, nextIn)
        SendNUIMessage({ 
            type = 'openPizza',
            level = level,
            nextIn = nextIn,
            exp = exp
         })
        SetNuiFocus(true, true)
    else
        ShowPizzaJobMenu()
    end
end)

-- Function to show ox_lib menu instead of UI
function ShowPizzaJobMenu()
    level = GetLevel()
    nextIn = GetNextLevelIn()
    exp = GetExp()
    
    local levelColor = Config.LevelColors[level] and Config.LevelColors[level].color or '#ffffff'
    local levelName = Config.LevelColors[level] and Config.LevelColors[level].name or 'Unknown'
    
    local levelThresholds = Config.XP.Levels
    local currentThreshold = level > 1 and levelThresholds[level - 1] or 0
    local nextThreshold = levelThresholds[level] or currentThreshold + 1000
    local progress = math.floor(((exp - currentThreshold) / (nextThreshold - currentThreshold)) * 100)
    
    local menuOptions = {
        {
            title = _L('level_stats', level, levelName, exp, nextIn),
            description = _L('level_description', exp),
            icon = 'fas fa-chart-line',
            iconColor = levelColor,
            progress = progress,
            colorScheme = progress <= 25 and 'red' or progress > 25 and progress <= 75 and 'yellow' or progress > 75 and 'green',
            readOnly = true,
            metadata = {
                { label = _L('next_level_in'), value = nextIn > 0 and _L('experience_needed', nextIn) or _L('max_level') },
                { label = _L('current_level'), value = string.format('%s (%d)', levelName, level) }
            }
        },
        {
            title = _L('vehicle_garage'),
            description = _L('garage_desc'),
            icon = 'fas fa-car',
            iconColor = '#42a5f5',
            metadata = {
                { label = _L('current_vehicle'), value = VehicleModule.getCurrentVehicleInfo().name }
            },
            onSelect = function()
                VehicleModule.showGarageMenu()
            end
        }
    }
    
    if not Config.PizzaMakingLocation.Enabled then
        table.insert(menuOptions, {
            title = _L('make_pizzas'),
            description = _L('pizza_making_desc'),
            icon = 'fas fa-pizza-slice',
            iconColor = '#ffa726',
            onSelect = function()
                StartPizzaMaking()
            end
        })
    end
    
    -- Add remaining options
    table.insert(menuOptions, {
        title = _L('stop_job_menu'),
        description = _L('stop_job_desc'),
        icon = 'fas fa-stop',
        iconColor = '#f44336',
        onSelect = function()
            JobFunctions.stopJob()
        end
    })
    
    table.insert(menuOptions, {
        title = _L('start_job_menu'),
        description = _L('start_job_desc'),
        icon = 'fas fa-truck',
        iconColor = '#66bb6a',
        onSelect = function()
            TriggerEvent('peleg-pizzajob:client:StartJob')
        end
    })
    
    lib.registerContext({
        id = 'pizza_job_menu',
        title = _L('pizza_job_main_menu'),
        options = menuOptions
    })
    
    lib.showContext('pizza_job_menu')
end

function StartPizzaMaking()
    if makingPizzas then
        -- Stop pizza making
        makingPizzas = false
        if pizzaMakingThread then
            pizzaMakingThread = nil
        end
        Utils.notify(_L('pizza_making_stopped'), 'error')
        -- Only show menu if physical location is disabled
        if not Config.PizzaMakingLocation.Enabled then
            ShowPizzaJobMenu()
        end
        return
    end
    
    if Config.PizzaMakingLocation.Enabled then
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - Config.PizzaMakingLocation.Location)
        if distance > 3.0 then
            Utils.notify(_L('need_pizza_kitchen'), 'error')
            return
        end
    end
    
    makingPizzas = true
    if Config.PizzaMakingLocation.Enabled then
        Utils.notify(_L('pizza_making_started_kitchen'), 'success')
    else
        Utils.notify(_L('pizza_making_started_menu'), 'success')
    end
    
    pizzaMakingThread = CreateThread(function()
        while makingPizzas do
            if Config.PizzaMakingLocation.Enabled then
                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = #(playerCoords - Config.PizzaMakingLocation.Location)
                if distance > 5.0 then 
                    makingPizzas = false
                    Utils.notify(_L('pizza_making_too_far'), 'error')
                    break
                end
            end
            
            local makingTime = math.random(3000, 6000) 
            
            local success = lib.progressBar({
                duration = makingTime,
                label = 'Making pizza...',
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
            
            if success and makingPizzas then
                TriggerServerEvent('peleg-pizzajob:server:givePizzaBox')
                Utils.notify(_L('pizza_made_success'), 'success')
                Wait(750)
            else
                makingPizzas = false
                Utils.notify(_L('pizza_making_stopped'), 'error')
                break
            end
        end
    end)
    
    if not Config.PizzaMakingLocation.Enabled then
        ShowPizzaMakingMenu()
    end
end

function ShowPizzaMakingMenu()
    lib.registerContext({
        id = 'pizza_making_menu',
        title = _L('making_pizzas_title'),
        options = {
            {
                title = _L('stop_making_pizzas'),
                description = _L('stop_making_pizzas_desc'),
                icon = 'fas fa-stop',
                iconColor = 'red',
                onSelect = function()
                    StartPizzaMaking()
                end
            },
            {
                title = _L('check_stats'),
                description = _L('stats_desc'),
                icon = 'fas fa-chart-line',
                iconColor = 'blue',
                onSelect = function()
                    local currentLevel = GetLevel()
                    local currentExp = GetExp()
                    local currentNextIn = GetNextLevelIn()
                    local currentLevelName = Config.LevelColors[currentLevel] and Config.LevelColors[currentLevel].name or 'Unknown'
                    
                    Utils.notify(_L('level_stats', currentLevel, currentLevelName, currentExp, currentNextIn), 'inform')
                    
                    SetTimeout(100, function()
                        ShowPizzaMakingMenu()
                    end)
                end
            }
        }
    })
    
    lib.showContext('pizza_making_menu')
end

-- Function to create a visual progress bar for level
function GetLevelProgressBar(currentExp, currentLevel)
    local levelThresholds = Config.XP.Levels
    local currentThreshold = currentLevel > 1 and levelThresholds[currentLevel - 1] or 0
    local nextThreshold = levelThresholds[currentLevel] or currentThreshold + 1000
    
    local progress = (currentExp - currentThreshold) / (nextThreshold - currentThreshold)
    local bars = 20
    local filledBars = math.floor(progress * bars)
    
    local progressBar = ''
    for i = 1, bars do
        if i <= filledBars then
            progressBar = progressBar .. '█'
        else
            progressBar = progressBar .. '░'
        end
    end
    
    return string.format('Progress: %s %.1f%%', progressBar, progress * 100)
end

function ShowDetailedStatsMenu(levelName, level, exp, nextIn)
    local progress = math.floor(((exp - (level > 1 and Config.XP.Levels[level - 1] or 0)) / 
        ((Config.XP.Levels[level] or exp + 1000) - (level > 1 and Config.XP.Levels[level - 1] or 0))) * 100)
    
    lib.registerContext({
        id = 'pizza_stats_menu',
        title = _L('stats_main_title'),
        options = {
            {
                title = _L('level_stats', level, levelName, exp, nextIn),
                description = _L('level_description', exp),
                icon = 'fas fa-star',
                iconColor = Config.LevelColors[level] and Config.LevelColors[level].color or '#ffffff',
                progress = progress,
                colorScheme = progress <= 25 and 'red' or progress > 25 and progress <= 75 and 'yellow' or progress > 75 and 'green',
                readOnly = true,
                metadata = {
                    { label = _L('next_level_in'), value = nextIn > 0 and _L('experience_needed', nextIn) or _L('max_level') },
                    { label = _L('progress'), value = string.format('%d%%', progress) }
                }
            },
            {
                title = _L('back'),
                description = _L('back_to_main_menu'),
                icon = 'fas fa-arrow-left',
                onSelect = function()
                    ShowPizzaJobMenu()
                end
            }
        }
    })
    
    lib.showContext('pizza_stats_menu')
end

CreateThread(function()
    DecorRegister("pizza_job", 1)
end)


CreateThread(function()
    if not Config.Blip then return end 
    local pizzajobBlip = AddBlipForCoord(vector3(Config.JobStartLocation.x, Config.JobStartLocation.y, Config.JobStartLocation.z)) 
    SetBlipSprite(pizzajobBlip, 267)
    SetBlipAsShortRange(pizzajobBlip, true)
    SetBlipScale(pizzajobBlip, 0.8)
    SetBlipColour(pizzajobBlip, 2)
    BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(_L('pizza_job_garage'))
    EndTextCommandSetBlipName(pizzajobBlip)
end)

CreateThread(function()
    if Config.PizzaMakingLocation.Enabled then
        if Config.PizzaMakingLocation.UseBlip then
            local pizzaKitchenBlip = AddBlipForCoord(vector3(Config.PizzaMakingLocation.Location.x, Config.PizzaMakingLocation.Location.y, Config.PizzaMakingLocation.Location.z))
            SetBlipSprite(pizzaKitchenBlip, Config.PizzaMakingLocation.BlipSprite)
            SetBlipAsShortRange(pizzaKitchenBlip, true)
            SetBlipScale(pizzaKitchenBlip, 0.8)
            SetBlipColour(pizzaKitchenBlip, Config.PizzaMakingLocation.BlipColor)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(_L('pizza_oven'))
            EndTextCommandSetBlipName(pizzaKitchenBlip)
        end
        
        Target.addTargetZone(Config.PizzaMakingLocation.Location, {
            {
                icon = "fa-solid fa-pizza-slice",
                label = _L('make_pizzas'),
                action = function() 
                    StartPizzaMaking()
                end,
                canInteract = function()
                    return not makingPizzas
                end
            }
        }, "pizzaMakingZone")
    end
end)

CreateThread(function()
    if Config.PizzaMakingLocation.Enabled and Config.PizzaMakingLocation.Use3DMarker then
        local markerConfig = Config.PizzaMakingLocation
        local bobOffset = 0.0
        local bobDirection = 1
        
        while true do
            local sleep = 500
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - markerConfig.Location)
            
            if distance <= markerConfig.MarkerDrawDistance then
                sleep = 0
                
                local zOffset = 0.0
                if markerConfig.MarkerBobUpAndDown then
                    bobOffset = bobOffset + (0.01 * bobDirection)
                    if bobOffset >= 0.5 then
                        bobDirection = -1
                    elseif bobOffset <= -0.5 then
                        bobDirection = 1
                    end
                    zOffset = bobOffset
                end
                
                local rotation = markerConfig.MarkerRotate and GetGameTimer() * 0.1 or 0.0
                
                DrawMarker(
                    markerConfig.MarkerType, -- Type
                    markerConfig.Location.x, -- X
                    markerConfig.Location.y, -- Y
                    markerConfig.Location.z + zOffset, -- Z (with bobbing offset)
                    0.0, 0.0, 0.0, -- Direction
                    0.0, 0.0, rotation, -- Rotation
                    markerConfig.MarkerSize.x, -- Scale X
                    markerConfig.MarkerSize.y, -- Scale Y
                    markerConfig.MarkerSize.z, -- Scale Z
                    markerConfig.MarkerColor.r, -- Red
                    markerConfig.MarkerColor.g, -- Green
                    markerConfig.MarkerColor.b, -- Blue
                    markerConfig.MarkerColor.a, -- Alpha
                    markerConfig.MarkerBobUpAndDown, -- Bob up and down
                    markerConfig.MarkerFaceCamera, -- Face camera
                    2, -- Rotation order
                    markerConfig.MarkerRotate, -- Rotate
                    nil, nil, false -- Texture params
                )
            end
            
            Wait(sleep)
        end
    end
end)

-- Pizza carrying loop: hold pizza box when you have one and are not in a vehicle
local holdingPizza = false
local holdingPizzaProp = nil
local PIZZA_ANIM_DICT = 'anim@heists@box_carry@'
local PIZZA_ANIM_NAME = 'idle'

local function startHoldingPizza()
    local ped = PlayerPedId()
    RequestAnimDict(PIZZA_ANIM_DICT)
    while not HasAnimDictLoaded(PIZZA_ANIM_DICT) do Wait(0) end
    TaskPlayAnim(ped, PIZZA_ANIM_DICT, PIZZA_ANIM_NAME, 8.0, -8.0, -1, 49, 0, false, false, false)

    local propHash = GetHashKey('prop_pizza_box_01')
    RequestModel(propHash)
    while not HasModelLoaded(propHash) do Wait(0) end
    holdingPizzaProp = CreateObject(propHash, 0.0, 0.0, 0.0, true, true, false)
    AttachEntityToEntity(holdingPizzaProp, ped, GetPedBoneIndex(ped, 28422), 0.0, -0.02, -0.20, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

    holdingPizza = true
end

local function ensurePizzaAnim()
    local ped = PlayerPedId()
    if not IsEntityPlayingAnim(ped, PIZZA_ANIM_DICT, PIZZA_ANIM_NAME, 3) then
        TaskPlayAnim(ped, PIZZA_ANIM_DICT, PIZZA_ANIM_NAME, 8.0, -8.0, -1, 49, 0, false, false, false)
    end
end

local function stopHoldingPizza()
    local ped = PlayerPedId()
    if holdingPizza then
        ClearPedTasks(ped)
        if holdingPizzaProp and DoesEntityExist(holdingPizzaProp) then
            DeleteEntity(holdingPizzaProp)
        end
        holdingPizzaProp = nil
        holdingPizza = false
    end
end

CreateThread(function()
    while true do
        Wait(750)
        local ped = PlayerPedId()
        local inVehicle = IsPedInAnyVehicle(ped, false)
        local hasBoxes = lib.callback.await('peleg-PizzaJob:CallBacks:getPizzaBoxCount', false) or 0
        if hasBoxes > 0 and not inVehicle then
            if not holdingPizza then
                startHoldingPizza()
            else
                ensurePizzaAnim()
            end
        else
            if holdingPizza then
                stopHoldingPizza()
            end
        end
    end
end)

RegisterNetEvent('peleg-pizzajob:client:StartJob', function()
    VehicleModule.showGarageMenu()
end)

RegisterNetEvent('peleg-pizzajob:client:OpenGarage', function()
    VehicleModule.showGarageMenu()
end)

RegisterNetEvent('peleg-pizzajob:client:notify', function (text, type)
    Utils.notify(text, type)
end)

CreateThread(function ()
    Wait(2500)
    SendNUIMessage({ type = 'closePizza' })
end)

RegisterNUICallback("CloseUi", function(data)
    SetNuiFocus(false,false)
end)

RegisterNUICallback("Start", function(data)
    SetNuiFocus(false,false)
    VehicleModule.showGarageMenu()
end)

RegisterNUICallback("timerAction", function(data, cb)
    cb('ok')
end)
