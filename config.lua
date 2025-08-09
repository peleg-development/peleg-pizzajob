Config = {}

-- Locale Configuration
Config.Locale = 'en' -- Available locales: 'en' (English), 'he' (Hebrew)

-- Core
Config.Core = 'qb' -- Supports: 'qb', 'qbx'
Config.Notify = 'ox' -- Supports: ox_lib = 'ox', qb-notify = 'qb', okoknotify = 'okok'
Config.CoreResourceName = 'qb-core' -- if u changed your core name
Config.Target = 'ox_target' -- target name for exports: 'qb-target', 'ox_target', 'draw3d'
-- 'qb-target' - Uses qb-target for interaction zones
-- 'ox_target' - Uses ox_target for interaction zones  
-- 'draw3d' - Uses 3D text and E key for interactions (no targeting script required)
Config.FuelScript = 'ox_fuel' -- suopports cdn-fuel qb-fuel
Config.ProgressBar = 'ox' -- supports qbcore defult = 'qb', ox_lib = 'ox'

-- Inventory
-- Supported: 'qb' (qb-inventory/qbcore), 'qs' (qs-inventory), 'ox' (ox_inventory)
Config.Inventory = 'qb'

-- Vehicle Garage System
Config.VehicleGarage = {
    Enabled = true,
    GarageLocation = vec3(294.5, -964.09, 29.42), -- Same as job start for now
    SpawnLocation = vec4(294.39, -954.54, 29.42, 255.86),
    Vehicles = {
        {
            name = "Food Bike",
            model = "foodbike",
            level = 1,
            description = "Basic delivery bike for beginners",
            image = "https://via.placeholder.com/150x100/ff6b6b/ffffff?text=Food+Bike"
        },
        {
            name = "Food Car",
            model = "foodcar",
            level = 2,
            description = "Reliable delivery car for apprentices",
            image = "https://via.placeholder.com/150x100/ffa726/ffffff?text=Food+Car"
        },
        {
            name = "Food Car 2",
            model = "foodcar2",
            level = 3,
            description = "Improved delivery vehicle for veterans",
            image = "https://via.placeholder.com/150x100/ffeb3b/ffffff?text=Food+Car+2"
        },
        {
            name = "Food Car 3",
            model = "foodcar3",
            level = 4,
            description = "Advanced delivery car for experts",
            image = "https://via.placeholder.com/150x100/66bb6a/ffffff?text=Food+Car+3"
        },
        {
            name = "Food Car 4",
            model = "foodcar4",
            level = 5,
            description = "Premium delivery vehicle for masters",
            image = "https://via.placeholder.com/150x100/42a5f5/ffffff?text=Food+Car+4"
        },
        {
            name = "Food Car 5",
            model = "foodcar5",
            level = 7,
            description = "Elite delivery car for legends",
            image = "https://via.placeholder.com/150x100/ab47bc/ffffff?text=Food+Car+5"
        },
        {
            name = "Food Car 7",
            model = "foodcar7",
            level = 10,
            description = "Ultimate delivery vehicle for pizza gods",
            image = "https://via.placeholder.com/150x100/ffd700/ffffff?text=Food+Car+7"
        }
    }
}

-- Level Colors Configuration
Config.LevelColors = {
    [1] = { color = '#ff6b6b', name = 'Rookie' },      -- Red
    [2] = { color = '#ffa726', name = 'Apprentice' },   -- Orange
    [3] = { color = '#ffeb3b', name = 'Veteran' },      -- Yellow
    [4] = { color = '#66bb6a', name = 'Expert' },       -- Green
    [5] = { color = '#42a5f5', name = 'Master' },       -- Blue
    [6] = { color = '#ab47bc', name = 'Legend' },       -- Purple
    [7] = { color = '#ff7043', name = 'Elite' },        -- Deep Orange
    [8] = { color = '#26a69a', name = 'Champion' },     -- Teal
    [9] = { color = '#ec407a', name = 'Hero' },         -- Pink
    [10] = { color = '#ffd700', name = 'Pizza God' }    -- Gold
}

-- General Settings
Config.JobStartLocation = vec3(294.5, -964.09, 29.42)  -- Example coordinates for job starting location
Config.NpcStart = 'a_m_m_prolhost_01' -- Replace with the desired NPC model
Config.JobEndLocation = vec3(294.5, -964.09, 29.42)    -- Example coordinates for job ending location

-- Pizza Making Location
-- When Enabled = true: Players must go to the physical location to make pizzas
-- When Enabled = false: Players can make pizzas through the menu anywhere
Config.PizzaMakingLocation = {
    Enabled = true, -- Set to false to disable physical location and use menu instead
    Location = vec3(289.9289, -964.0513, 28.4186), -- Physical location for making pizzas
    UseBlip = false, -- Add blip on map for pizza making location
    BlipSprite = 267, -- Blip sprite ID
    BlipColor = 47, -- Blip color
    BlipName = "Pizza Oven", -- Blip name (will be localized in code)
    
    -- 3D Marker Settings
    Use3DMarker = true, -- Enable/disable 3D marker at pizza making location
    MarkerType = 25, -- Marker type (Popular: 1=cylinder, 2=sphere, 6=ring, 20=arrow, 25=checkpoint, 28=circle)
    MarkerSize = {x = 2.0, y = 2.0, z = 1.0}, -- Marker size (width, depth, height)
    MarkerColor = {r = 255, g = 165, b = 0, a = 100}, -- Marker color (Red, Green, Blue, Alpha/Transparency)
    MarkerBobUpAndDown = false, -- Make marker bob up and down smoothly
    MarkerRotate = false, -- Make marker rotate continuously
    MarkerFaceCamera = false, -- Make marker always face the camera
    MarkerDrawDistance = 50.0 -- Distance at which marker becomes visible (meters)
}

Config.UseDefultVehicles = true -- if u use our vehicles that are in stream to set the livery
Config.TimeLimitPerDelivery = 300  -- Time limit for each delivery in seconds (300 seconds = 5 minutes)
Config.Blip = false -- enable or disable the job blip on the map

-- Payout Settings
Config.BasePayout = 300  -- Base payout for deliveries
Config.DistanceMultiplier = 5  -- Multiplier for payout based on distance
Config.DistanceBonusMultiplier = 3 -- Multiplier for payout based on distance
Config.AdditionalPayoutPerDelivery = 6 -- Multiplier for payout based on distance
Config.PayCheckType = "cash" -- types: 'cash', 'bank'

-- UI Settings
Config.ShowJobUI = false  -- Set to false to disable job UI (using ox_lib menu instead)

-- Timer
Config.DeliveryTimer = 3600 -- set the max time per delveiry if delviery not in time will give u a new one
Config.ReetDeliveryCount = true -- if fail will reset delvery count so player will get less money
Config.TakeMoney = true -- if true will take money from player on fail
Config.TakeMoneyAmount = 500 -- ammoiunt of money on lost
Config.TakeEXP = true -- will take exp from the player only enable if xp system is enabled
Config.ExpTakeAmount = 10 -- amount to take

-- Random Tips
Config.RandomItem = true -- gives a random item as a tip
Config.RandomItemChance = 50 -- % to get any item at all
Config.RandomItems = {
    ['goldcoin'] = math.random(0,3) -- if u get 0 system will return and give nothing..
    -- ['itemname'] = amount only ints not floats!
}
Config.RandomMoney = true -- if true tips can be given as random money ofc u can add them both..
Config.RandomMoneyAmount = { min = 200, max = 400 } -- amount for the tip!
Config.RandomMoneyType = 'cash' -- supported 'cash', 'bank'

-- EXP System
Config.XP = {
    Use = true, -- Toggles xp system on or off; true = on, false = off
    Command = true, -- Toggles xp command on or off; true = on, false = off
    MetaDataName = 'pizzaexp', -- The name of your xp if you edit this make sure to also edit the line included in readme this is also your /miningxp command
    Levels = { -- Change your xp requirements here to suit your server set these as high as you want preset xp increase = (xp / 0.8)
        1000, -- level 2 
        1250, -- level 3 
        1562, -- level 4
        1953, -- level 5
        2441, -- level 6 
        3051, -- level 7
        3814, -- level 8
        4768, -- level 9
        5960, -- level 10
        -- this will not work for now inorder to change levels go to server/functions.lua
    }
}

Config.JobLocs = { -- Random delivery houses.
    vector3(288.3212, -920.0848, 29.4655),
    -- vector3(224.11, 513.52, 140.92),
    -- vector3(57.51, 449.71, 147.03),
    -- vector3(-297.81, 379.83, 112.1),
    -- vector3(-595.78, 393.0, 101.88),
    -- vector3(-842.68, 466.85, 87.6),
    -- vector3(-1367.36, 610.73, 133.88),
    -- vector3(944.44, -463.19, 61.55),
    -- vector3(970.42, -502.5, 62.14),
    -- vector3(1099.5, -438.65, 67.79),
    -- vector3(1229.6, -725.41, 60.96),
    -- vector3(288.05, -1094.98, 29.42),
    -- vector3(-32.35, -1446.46, 31.89),
    -- vector3(-34.29, -1847.21, 26.19),
    -- vector3(130.59, -1853.27, 25.23),
    -- vector3(192.2, -1883.3, 25.06),
    -- vector3(348.64, -1820.87, 28.89),
    -- vector3(427.28, -1842.14, 28.46),
    -- vector3(291.48, -1980.15, 21.6),
    -- vector3(279.87, -2043.67, 19.77),
    -- vector3(1297.25, -1618.04, 54.58),
    -- vector3(1381.98, -1544.75, 57.11),
    -- vector3(1245.4, -1626.85, 53.28),
    -- vector3(315.09, -128.31, 69.98),
    -- vector3(-20.93653, -1406.271, 29.532669),
    -- vector3(-32.32445, -1446.168, 31.89141),
    -- vector3(-602.1438, -1121.965, 22.324249),
    -- vector3(-736.7023, -1118.965, 11.015544),
    -- vector3(335.23135, -71.63269, 73.042213),
    -- vector3(1207.4804, -620.3994, 66.438636),
    -- vector3(1130.4631, -963.6549, 47.258625),
    -- vector3(232.49606, -1094.821, 29.294008),
    -- vector3(478.98596, -106.7353, 63.15781),
}