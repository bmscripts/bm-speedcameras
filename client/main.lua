-- ============================================================
--  Client State
-- ============================================================

local playerPed = cache.ped
local activeBlips = {}      -- Stores active blip handles
local spawnedProps = {}     -- Stores spawned camera prop entities

-- ============================================================
--  Ground Z Detection Helper
-- ============================================================

local function getGroundZ(x, y, z)
    local _, groundZ = GetGroundZFor_3dCoord(x, y, z, false)
    return groundZ
end

-- ============================================================
--  Speed Camera Detection Loop
-- ============================================================

CreateThread(function()
    while true do
        Wait(500)

        local ped = PlayerPedId()
        if not IsPedInAnyVehicle(ped, false) then goto continue end

        local veh = GetVehiclePedIsIn(ped, false)
        local speed = GetEntitySpeed(veh)

        -- Convert speed to MPH or KMH
        if Config.UseMPH then
            speed = speed * 2.236936
        else
            speed = speed * 3.6
        end

        local coords = GetEntityCoords(ped)

        -- Loop through all configured cameras
        for i, cam in ipairs(Config.SpeedCameras) do
            local dist = #(coords - vector3(cam.coords.x, cam.coords.y, cam.coords.z))

            if dist <= cam.radius then
                local shouldTrigger = true

                -- Optional directional detection
                if cam.direction then
                    local vehHeading = GetEntityHeading(veh)

                    -- Primary direction
                    local camDir = cam.direction
                    local fov = cam.fov or Config.DefaultFOV

                    local diffPrimary = math.abs((vehHeading - camDir + 180) % 360 - 180)
                    local inPrimary = diffPrimary <= fov

                    local inDual = false

                    -- Dual-direction support (corrected)
                    if cam.dual then
                        local dualDir = (camDir + 180) % 360
                        local dualFov = cam.dualFov or fov

                        local diffDual = math.abs((vehHeading - dualDir + 180) % 360 - 180)
                        inDual = diffDual <= dualFov
                    end

                    if not inPrimary and not inDual then
                        shouldTrigger = false
                    end
                end

                -- Trigger fine if speeding and direction is valid
                if shouldTrigger and speed > cam.speedLimit then

                    -- ====================================================
                    --  Send all required data to the server
                    -- ====================================================
                    local vehClass = GetVehicleClass(veh)
                    local hour = GetClockHours()

                    -- Vehicle info (client-side, reliable)
                    local modelHash = GetEntityModel(veh)
                    local plate = GetVehicleNumberPlateText(veh) or "Unknown"

                    TriggerServerEvent(
                        'bm-speedcameras:finePlayer',
                        i,
                        speed,
                        vehClass,
                        hour,
                        plate
                    )

                    Wait(3000) -- Prevent rapid re-triggering
                end
            end
        end

        ::continue::
    end
end)

-- ============================================================
--  Blip Rendering Loop
-- ============================================================

CreateThread(function()
    if not Config.EnableBlips then return end

    while true do
        Wait(500)

        local ped = PlayerPedId()
        local pCoords = GetEntityCoords(ped)

        for i, cam in ipairs(Config.SpeedCameras) do
            if cam.blip and cam.blip.enabled then
                local camPos = vector3(cam.coords.x, cam.coords.y, cam.coords.z)
                local dist = #(pCoords - camPos)

                local shortRange = cam.blip.shortRange
                if shortRange == nil then
                    shortRange = Config.DefaultShortRange
                end

                local range = cam.blip.shortRangeDistance or Config.DefaultShortRangeDistance
                local shouldShow = not shortRange or dist <= range

                if shouldShow and not activeBlips[i] then
                    local blip = AddBlipForCoord(camPos.x, camPos.y, camPos.z)

                    SetBlipSprite(blip, cam.blip.sprite or Config.DefaultBlipSprite)
                    SetBlipColour(blip, cam.blip.colour or Config.DefaultBlipColour)
                    SetBlipScale(blip, cam.blip.scale or Config.DefaultBlipScale)
                    SetBlipAsShortRange(blip, true)

                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString(cam.blip.label or Config.DefaultBlipLabel)
                    EndTextCommandSetBlipName(blip)

                    activeBlips[i] = blip
                end

                if not shouldShow and activeBlips[i] then
                    RemoveBlip(activeBlips[i])
                    activeBlips[i] = nil
                end
            end
        end
    end
end)

-- ============================================================
--  Fine Notification Event
-- ============================================================

RegisterNetEvent('bm-speedcameras:notifyFine', function(data)
    local speed = tonumber(data.speed) or 0
    local limit = tonumber(data.limit) or 0
    local fine = tonumber(data.fine) or 0

    local plate = data.plate or "Unknown"

    speed = math.floor(speed + 0.5)
    limit = math.floor(limit + 0.5)

    if Config.FlashEnabled then
        SetTimecycleModifier(Config.FlashEffect)
        SetTimecycleModifierStrength(Config.FlashIntensity)
        Wait(Config.FlashDuration)
        ClearTimecycleModifier()
    end

    if Config.SoundEnabled then
        PlaySoundFrontend(-1, Config.SoundName, Config.SoundSet, true)
    end

    local L = Locales[Config.Locale]

    local message = L.notify_message:format(
        speed,
        limit,
        fine,
        plate
    )

    lib.notify({
        title = L.notify_title,
        description = message,
        type = 'error',
        position = Config.NotifyPosition,
        duration = Config.NotifyDuration
    })
end)

-- ============================================================
--  Debug Spheres (ox_lib)
-- ============================================================

CreateThread(function()
    if not Config.DebugMode then return end

    for i, cam in ipairs(Config.SpeedCameras) do
        cam.debugZone = lib.zones.sphere({
            coords = vec3(cam.coords.x, cam.coords.y, cam.coords.z),
            radius = cam.radius,
            debug = true,
            inside = function() end,
            onEnter = function() end,
            onExit = function() end
        })
    end
end)

-- ============================================================
--  Prop Spawning (Camera Models)
-- ============================================================

CreateThread(function()
    for i, cam in ipairs(Config.SpeedCameras) do
        local model = cam.model or Config.DefaultCameraModel
        if model then
            local hash = joaat(model)

            RequestModel(hash)
            while not HasModelLoaded(hash) do
                Wait(10)
            end

            local x, y, z = cam.coords.x, cam.coords.y, cam.coords.z
            local groundZ = getGroundZ(x, y, z)

            local offset = cam.zOffset or Config.PropZOffset or 0.0
            local finalZ = (groundZ or z) + offset

            local obj = CreateObject(hash, x, y, finalZ, false, false, false)

            SetEntityHeading(obj, cam.heading or 0.0)
            FreezeEntityPosition(obj, true)

            spawnedProps[i] = obj
        end
    end
end)

-- ============================================================
--  Cleanup Props on Resource Stop
-- ============================================================

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    for _, obj in pairs(spawnedProps) do
        if DoesEntityExist(obj) then
            DeleteObject(obj)
        end
    end
end)
