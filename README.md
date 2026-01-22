<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://i.ibb.co/qLqknnYd/BMScripts-Header.png">
  <source media="(prefers-color-scheme: light)" srcset="https://i.ibb.co/qLqknnYd/BMScripts-Header.png">
  <img alt="Shows the BM Scripts banner" src="https://i.ibb.co/qLqknnYd/BMScripts-Header.png">
</picture>

# BM Speed Cameras - QB/QBox Configurable Speed Cameras with Fines and Plate Notifications
*A lightweight, configurable, and performance‑friendly speed camera system for FiveM (QBCore/QBox).*

This script adds fully functional speed cameras to your server, complete with configurable speed limits, fines, directional detection, dual‑direction support, blips, props, and clean player notifications.

---

## 📌 Features Overview

- 🚨 **Speed Detection** (MPH or KMH)  
- 🎯 **Directional & Dual‑Direction Cameras**  
- 💸 **Dynamic Fine System** (base fine, % over limit, multipliers)  
- 🚫 **Job Exemptions** (police, EMS, etc.)  
- 📍 **Optional Blips** for each camera  
- 📸 **Camera Props** with ground alignment  
- ⚡ **Flash & Sound Effects** when triggered  
- 🔧 **Debug Mode** for camera placement  
- 🧾 **Clean Notifications** including the vehicle’s plate  
- 🧩 **Fully Configurable** through `config.lua`  

---

## 📥 Installation

1. Place the resource folder into your server’s `resources` directory.
2. Add this to your `server.cfg`:
```
ensure bm-speedcameras
```
3. Configure everything in `config.lua`.

## ⚙️ Configuration Overview

All settings for the script are controlled through `config.lua`.  
Every camera, fine, blip, and effect can be customized without touching the core code.

---

### 🔧 General Settings

| Setting | Description |
|--------|-------------|
| `Locale` | Language for notifications (currently only `en`) |
| `DebugMode` | Shows debug spheres for camera zones |
| `UseMPH` | Toggle between MPH (true) or KMH (false) |

---

### 🔔 Notification Settings

| Setting | Description |
|--------|-------------|
| `NotifyPosition` | Screen position of notifications |
| `NotifyDuration` | How long notifications stay visible (ms) |

---

### 🗺️ Blip Settings

| Setting | Description |
|--------|-------------|
| `EnableBlips` | Enable/disable all camera blips |
| `DefaultBlipSprite` | Default blip icon |
| `DefaultBlipColour` | Default blip colour |
| `DefaultBlipScale` | Default blip size |
| `DefaultBlipLabel` | Default blip name |
| `DefaultShortRange` | Only show blip when nearby |
| `DefaultShortRangeDistance` | Distance threshold for short‑range blips |

---

### 💸 Fine System

| Setting | Description |
|--------|-------------|
| `DefaultBaseFine` | Base fine amount |
| `DefaultFinePerPercent` | Fine per 1% over the limit |
| `DefaultMaxFine` | Maximum fine allowed |
| `DefaultPaymentType` | `cash` or `bank` |
| `FineMultiplier` | Global multiplier for all fines |

---

### 🚗 Vehicle Class Multipliers

Each GTA vehicle class can have its own multiplier.  
Example: Motorcycles cheaper, emergency vehicles more expensive.

```lua
Config.VehicleClassMultiplier = {
    [0] = 1.0,   -- Compacts
    [1] = 1.0,   -- Sedans
    [2] = 1.2,   -- SUVs
    [8] = 0.7,   -- Motorcycles
    [18] = 1.5,  -- Emergency
}
```

### 🌙 Time‑of‑Day Multipliers
```lua
Config.TimeOfDayMultiplier = {
    day = 1.0,    -- 06:00–20:00
    night = 0.8   -- 20:00–06:00
}
```

### 🚫 Job Exemptions
Jobs listed here will never receive fines:
```lua
Config.ExcludedJobs = {
    police = true,
    ambulance = true,
    bcso = true,
    sahp = true
}
```

### ⚡ Flash & Sound Effects

These effects play when a player triggers a speed camera.

| Setting | Description |
|--------|-------------|
| `FlashEnabled` | Enables a bright screen flash when the camera triggers |
| `FlashIntensity` | Brightness of the flash effect |
| `FlashDuration` | Duration of the flash (in ms) |
| `SoundEnabled` | Plays a camera shutter sound when triggered |

Example:

```lua
Config.FlashEnabled = true
Config.FlashIntensity = 1.0
Config.FlashDuration = 300
Config.SoundEnabled = true
```

### 🏗️ Camera Props
Each camera can optionally spawn a physical prop (e.g., CCTV pole).
- Props auto‑align to the ground
- Custom heading supported
- Optional Z offset for fine‑tuning

Example:
```lua
model = 'prop_cctv_pole_03',
heading = 245.0,
zOffset = -0.05,
```
If `model = nil`, no prop will spawn.

### 🧪 Debug Mode
Debug mode draws a visible sphere around each camera zone using ox_lib.
```lua
Config.DebugMode = true
```
Useful for:
- Testing camera placement
- Checking radius coverage
- Ensuring directional detection is correct

### 📸 Camera Definitions
Each camera is defined inside `Config.SpeedCameras`.
```lua
{
    coords = vec3(88.85, -1038.7, 29.46),
    radius = 20.0,
    speedLimit = 40,

    -- Optional prop
    model = 'prop_cctv_pole_03',
    heading = 245.0,
    zOffset = -0.05,

    -- Optional directional detection
    direction = 180.0,
    fov = 45.0,

    -- Optional dual-direction detection
    dual = true,
    dualFov = 45.0,

    -- Fine settings
    baseFine = 200,
    finePerPercent = 5,
    maxFine = 1000,
    paymentType = 'cash',

    -- Blip settings
    blip = {
        enabled = true,
        sprite = 744,
        colour = 0,
        scale = 0.6,
        label = "Speed Camera",
        shortRange = true,
        shortRangeDistance = 500.0
    }
}
```

### 🚦 How Speed Cameras Work
1. Player enters a camera radius
2. Script checks:
   - Speed
   - Speed limit
   - Direction (if enabled)
   - Dual‑direction (if enabled)

3. If speeding:
   - Fine is calculated
   - Multipliers applied
   - Money removed
   - Notification shown
   - Plate included in the message

4. A cooldown prevents repeated fines

### 🔔 Notification Example
```
You were caught speeding doing 60 in a 40 zone.
Fine: $300
Plate: EXAMPLE1
```

### 🛠 Dependencies
- ox_lib (notifications, debug zones)
- QBCore / QBox (player money, job data)

### ❓ Troubleshooting
- Enable DebugMode = true to visualize camera zones
- Check server console for config validation errors
- Ensure ox_lib is started before this resource
- Verify camera coordinates and radius values
- Ensure your blip settings are valid

# License

You may use and edit this script for personal or server use.

If you reupload, redistribute, or share this script in any form, **attribution is required**.  
You must credit the original author: **BM Scripts**.

You may not claim this script as your own.
