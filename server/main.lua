-- ============================================================
--  Fine Multiplier Logic
-- ============================================================

local function getFineMultiplier(vehClass, hour)
    local multiplier = Config.FineMultiplier or 1.0

    -- Vehicle class multiplier
    if Config.VehicleClassMultiplier and Config.VehicleClassMultiplier[vehClass] then
        multiplier = multiplier * Config.VehicleClassMultiplier[vehClass]
    end

    -- Time of day multiplier
    local isNight = (hour >= 20 or hour < 6)

    if isNight then
        multiplier = multiplier * ((Config.TimeOfDayMultiplier and Config.TimeOfDayMultiplier.night) or 1.0)
    else
        multiplier = multiplier * ((Config.TimeOfDayMultiplier and Config.TimeOfDayMultiplier.day) or 1.0)
    end

    return multiplier
end

-- ============================================================
--  Speed Camera Fine Handler
-- ============================================================

RegisterNetEvent('bm-speedcameras:finePlayer', function(camIndex, speed, vehClass, hour, plate)
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)
    if not Player then return end

    local cam = Config.SpeedCameras[camIndex]
    if not cam then return end

    -- Job Exclusion Check
    local job = Player.PlayerData.job and Player.PlayerData.job.name
    if job and Config.ExcludedJobs and Config.ExcludedJobs[job] then
        return
    end

    -- Mandatory radius check
    local radius = tonumber(cam.radius)
    if not radius then return end

    -- Apply defaults for optional fields
    local limit = tonumber(cam.speedLimit) or 0
    local baseFine = tonumber(cam.baseFine) or Config.DefaultBaseFine
    local finePerPercent = tonumber(cam.finePerPercent) or Config.DefaultFinePerPercent
    local maxFine = tonumber(cam.maxFine) or Config.DefaultMaxFine
    local paymentType = cam.paymentType or Config.DefaultPaymentType

    if limit <= 0 then limit = 1 end

    -- Calculate overspeed %
    local overSpeed = speed - limit
    local percentOver = (overSpeed / limit) * 100
    if not percentOver or percentOver ~= percentOver then percentOver = 0 end

    -- Base fine calculation
    local fine = baseFine + (percentOver * finePerPercent)

    -- Apply scaling
    local scale = getFineMultiplier(vehClass, hour)
    fine = math.floor(fine * scale)

    -- Respect maxFine
    if cam.maxFine and fine > cam.maxFine then
        fine = cam.maxFine
    end

    if maxFine and fine > maxFine then
        fine = maxFine
    end

    fine = math.floor(fine)

    -- Remove money
    Player.Functions.RemoveMoney(paymentType, fine, 'speed-camera-fine')

    -- Notify client (vehicle info now comes from client)
    TriggerClientEvent('bm-speedcameras:notifyFine', src, {
        speed = speed,
        limit = limit,
        fine = fine,
        plate = plate or "Unknown"
    })
end)

-- ============================================================
--  Config Validation
-- ============================================================

local function validateConfig()
    print("^3[bm-speedcameras] Validating configuration...^7")

    if not Config.SpeedCameras or #Config.SpeedCameras == 0 then
        print("^1[bm-speedcameras] ERROR: No speed cameras defined in Config.SpeedCameras!^7")
        return
    end

    for i, cam in ipairs(Config.SpeedCameras) do
        local prefix = ("^3[bm-speedcameras] Camera %s:^7 "):format(i)

        if not cam.coords then
            print(prefix .. "^1Missing coords!^7")
        elseif not cam.coords.x or not cam.coords.y or not cam.coords.z then
            print(prefix .. "^1Invalid coords format (must be vec3).^7")
        end

        if not cam.radius then
            print(prefix .. "^1Missing radius!^7")
        elseif type(cam.radius) ~= "number" or cam.radius <= 0 then
            print(prefix .. "^1Invalid radius (must be > 0).^7")
        end

        if not cam.speedLimit then
            print(prefix .. "^1Missing speedLimit!^7")
        elseif type(cam.speedLimit) ~= "number" or cam.speedLimit <= 0 then
            print(prefix .. "^1Invalid speedLimit (must be > 0).^7")
        end

        if cam.baseFine and cam.baseFine < 0 then
            print(prefix .. "^1baseFine cannot be negative.^7")
        end

        if cam.finePerPercent and cam.finePerPercent < 0 then
            print(prefix .. "^1finePerPercent cannot be negative.^7")
        end

        if cam.maxFine and cam.maxFine < 0 then
            print(prefix .. "^1maxFine cannot be negative.^7")
        end

        if cam.paymentType and cam.paymentType ~= "cash" and cam.paymentType ~= "bank" then
            print(prefix .. "^1Invalid paymentType (must be 'cash' or 'bank').^7")
        end

        if cam.zOffset and type(cam.zOffset) ~= "number" then
            print(prefix .. "^1Invalid zOffset (must be a number).")
        end

        if cam.direction and (type(cam.direction) ~= "number" or cam.direction < 0 or cam.direction >= 360) then
            print(prefix .. "^1Invalid direction (must be 0–359).")
        end

        if cam.fov and (type(cam.fov) ~= "number" or cam.fov <= 0 or cam.fov > 180) then
            print(prefix .. "^1Invalid fov (must be 1–180).")
        end

        if cam.dual ~= nil and type(cam.dual) ~= "boolean" then
            print(prefix .. "^1Invalid dual value (must be true/false).")
        end

        if cam.dualFov and (type(cam.dualFov) ~= "number" or cam.dualFov <= 0 or cam.dualFov > 180) then
            print(prefix .. "^1Invalid dualFov (must be 1–180).")
        end
    end

    print("^2[bm-speedcameras] Config validation complete.^7")
end

-- ============================================================
--  Resource Start
-- ============================================================

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        validateConfig()
    end
end)
