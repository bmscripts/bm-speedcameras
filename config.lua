Config = {}

-- ============================================================
--  General Settings
-- ============================================================

Config.Locale = 'en'                        -- Language for notifications (currently only English)
Config.DebugMode = false                    -- Enables visual debug spheres for camera zones
Config.UseMPH = true                        -- true = MPH, false = KMH

-- ============================================================
--  Notification Settings
-- ============================================================

Config.NotifyPosition = 'center-right'      -- Notification position on screen
Config.NotifyDuration = 10000               -- Duration in ms (10000 = 10 seconds)

-- ============================================================
--  Blip Settings
-- ============================================================

Config.EnableBlips = true                   -- Enable/disable all speed camera blips

Config.DefaultBlipSprite = 744              -- Default blip icon (camera)
Config.DefaultBlipColour = 0                -- Default blip colour
Config.DefaultBlipScale = 0.6               -- Default blip size
Config.DefaultBlipLabel = "Speed Camera"    -- Default blip name
Config.DefaultShortRange = true             -- Only show blip when nearby
Config.DefaultShortRangeDistance = 500.0    -- Distance threshold for short-range blips

-- ============================================================
--  Default Camera Fine Settings
-- ============================================================

Config.DefaultBaseFine = 100                -- Base fine amount
Config.DefaultFinePerPercent = 5            -- Fine per 1% over the limit
Config.DefaultMaxFine = 1000                -- Maximum fine (or false to disable)
Config.DefaultPaymentType = 'bank'          -- 'cash' or 'bank'

-- ============================================================
--  Default Camera Prop Settings
-- ============================================================

Config.DefaultCameraModel = nil             -- Default prop model (nil = no prop)
                                            -- Examples: prop_cctv_pole_01a, prop_cctv_pole_02, etc.

-- ============================================================
--  Flash & Sound Effects
-- ============================================================

Config.FlashEnabled = true                  -- Enable screen flash when triggered
Config.FlashIntensity = 1.0                 -- Flash brightness
Config.FlashDuration = 300                  -- Flash duration in ms

Config.SoundEnabled = true                  -- Enable shutter sound when triggered

-- ============================================================
--  Fine Scaling System
-- ============================================================

Config.FineMultiplier = 1.0                 -- Global multiplier (1.0 = normal, 2.0 = double fines)

-- Vehicle class multipliers (GTA vehicle classes)
Config.VehicleClassMultiplier = {
    [0]  = 1.0,                             -- Compacts
    [1]  = 1.0,                             -- Sedans
    [2]  = 1.2,                             -- SUVs
    [3]  = 1.0,                             -- Coupes
    [4]  = 1.0,                             -- Muscle
    [5]  = 1.0,                             -- Sports Classics
    [6]  = 1.0,                             -- Sports
    [7]  = 1.0,                             -- Super
    [8]  = 0.7,                             -- Motorcycles
    [9]  = 1.0,                             -- Off-road
    [10] = 1.0,                             -- Industrial
    [11] = 1.0,                             -- Utility
    [12] = 1.0,                             -- Vans
    [13] = 1.0,                             -- Cycles (bicycles)
    [14] = 1.0,                             -- Boats
    [15] = 1.0,                             -- Helicopters
    [16] = 1.0,                             -- Planes
    [17] = 1.0,                             -- Service
    [18] = 1.5,                             -- Emergency
    [19] = 1.0,                             -- Military
    [20] = 1.3,                             -- Commercial
}

-- Time-of-day multipliers
Config.TimeOfDayMultiplier = {
    day = 1.0,                              -- 06:00–20:00
    night = 0.8                             -- 20:00–06:00 (cheaper fines)
}

-- Jobs that should NEVER receive speed camera fines
Config.ExcludedJobs = {
    police = true,
    ambulance = true,
    bcso = true,
    sahp = true,
    -- Add more as needed
}

-- ============================================================
--  Speed Camera Definitions
-- ============================================================

Config.SpeedCameras = {

    -- ========================================================
    --  LARGE EXAMPLE CAMERA (DUAL-DIRECTION)
    -- ========================================================
    {
        coords = vec3(88.85, -1038.7, 29.46),       -- Camera location
        radius = 20.0,                              -- Detection radius
        speedLimit = 40,                            -- Speed limit (MPH or KMH)

        -- Prop placement
        model = 'prop_cctv_pole_03',                -- Prop model (optional)
        heading = 245.0,                            -- Prop rotation
        zOffset = -0.05,                            -- Ground alignment offset

        -- Directional detection
        -- direction = 180.0,                        - Primary detection direction (optional)
        -- fov = 45.0,                              -- Primary detection cone width

        -- ====================================================
        --  Dual-Direction Support
        -- ====================================================
        dualDirection = true,                                -- Enables detection from BOTH directions
                                                    -- If true, the camera also detects vehicles coming from the opposite heading

        dualFov = 45.0,                             -- Optional FOV for the reverse direction (defaults to Config.DefaultFOV)

        -- Fine settings
        baseFine = 200,                             -- Base fine
        finePerPercent = 5,                         -- Fine per % over limit
        maxFine = 1000,                             -- Maximum fine
        paymentType = 'cash',                       -- Payment method

        -- Blip settings
        blip = {
            enabled = true,                         -- Enable blip
            sprite = 744,                           -- Icon
            colour = 0,                             -- Colour
            scale = 0.6,                            -- Size
            label = "Speed Camera (Example)",       -- Name
            shortRange = true,                      -- Only show when nearby
            shortRangeDistance = 500.0              -- Distance threshold
        }
    },

    -- ========================================================
    --  SMALL EXAMPLE CAMERA (SINGLE-DIRECTION)
    -- ========================================================
    {
        coords = vec3(319.77, -1034.71, 29.22),     -- Camera location
        radius = 15.0,                              -- Detection radius
        speedLimit = 40,                            -- Speed limit

        model = 'prop_cctv_pole_04',                -- Optional prop
        heading = 0.0,                              -- Optional rotation
        zOffset = -0.05,                            -- Optional ground offset

        direction = 115.0,                          -- Single-direction detection
        fov = 60.0,                                 -- Detection cone width

        blip = {
            enabled = true                          -- Minimal blip config
        }
    }
}

-- ============================================================
--  Internal Defaults (Do Not Modify)
-- ============================================================

Config.FlashEffect = "MP_job_load"         -- Timecycle modifier used for flash
Config.SoundName = 'Camera_Shoot'          -- Sound played when triggered
Config.SoundSet = 'Phone_SoundSet_Default' -- Sound set used
Config.PropZOffset = 0.0                   -- Global fallback Z offset
Config.DefaultFOV = 90.0                   -- Default detection cone width
