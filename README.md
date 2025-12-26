# Container Protection - Build 42 Compatible Version

## Changes from Original Version:

### Critical Updates for Build 42:
1. **mod.info**: Added `require=BuildVersion:42.0` flag
2. **CP_Main.lua**:
   - Changed `getPlayer()` to `getSpecificPlayer(0)` for Build 42 compatibility
   - Added nil-check for player object
   - Changed `require "CP_RoomsDefinitions.lua"` to `require "CP_RoomsDefinitions"` (removed .lua extension)
   - Changed event from `Events.EveryOneMinute` to `Events.OnGameStart` for better performance
   - Added parameters to `setHaloNote()` for proper display
   - Removed duplicate player variable declaration
   - Improved accessLevel handling
   - All comments translated to English and significantly expanded

3. **sandbox-options.txt**: Moved from `media/` to `media/lua/server/` (correct Build 42 location)

### Project Structure (Steam Workshop Format):
```
ContainerProtectionB42/
├── workshop.txt                                    (Steam Workshop metadata)
└── Contents/
    └── mods/
        └── ContainerProtectionB42/
            ├── mod.info                            (Main mod info - Build 42 compatible)
            ├── 42/                                 (Build 42 specific files)
            │   ├── mod.info                        (Build 42 version info)
            │   └── media/
            │       └── lua/
            │           ├── client/                 (Client-side scripts)
            │           │   ├── CP_Main.lua         (Main protection logic - UPDATED)
            │           │   └── CP_RoomsDefinitions.lua (200+ protected rooms)
            │           ├── server/                 (Server-side scripts)
            │           │   └── sandbox-options.txt (Sandbox configuration)
            │           └── shared/                 (Shared resources)
            │               └── Translate/
            │                   ├── EN/             (English translations)
            │                   │   ├── IG_UI_EN.txt
            │                   │   └── Sandbox_EN.txt
            │                   └── PTBR/           (Portuguese-BR translations)
            │                       ├── IG_UI_PTBR.txt
            │                       └── Sandbox_PTBR.txt
            └── common/                             (Common resources shared across builds)
```

### Installation:

#### For Steam Workshop:
1. Subscribe to the mod on Steam Workshop
2. The mod will auto-install to your mods directory

#### For Manual Installation:
1. Copy the `ContainerProtectionB42` folder to:
   - **Windows**: `C:\Users\<YourName>\Zomboid\mods\`
   - **Linux**: `~/.zomboid/mods/`
   - **Mac**: `~/Library/Application Support/Zomboid/mods/`

2. Ensure the structure matches the format above

#### For Development/Testing:
1. Use the `ContainerProtectionB42` folder directly
2. Symlink to your PZ mods directory if needed

### Testing:
After loading the mod, test in Lua console (F11 -> Lua Console):
```lua
print("Player: " .. tostring(getSpecificPlayer(0)))
print("SandboxVars: " .. tostring(SandboxVars.ContainerProtection))
print("Admin Perms: " .. tostring(SandboxVars.ContainerProtection.AdminPermissions))
```

### Features:
- ✅ **200+ Protected Room Types**: Comprehensive coverage of all major building types
- ✅ **Admin/Moderator Override**: Server staff can bypass protection when needed
- ✅ **SafeHouse Integration**: Players can manage containers in their claimed areas
- ✅ **Multilingual Support**: English and Portuguese-BR translations included
- ✅ **Configurable Sandbox Options**: Customize protection behavior per server
- ✅ **Performance Optimized**: Uses OnGameStart event for efficient initialization
- ✅ **Extensive Documentation**: All code fully commented in English

### Build Compatibility:
- ✅ **Build 42.0+** (Current version)
- ❌ **Build 41.x** (Use B41 folder for legacy support)

### Technical Details:

#### Room Categories Protected:
- Residential rooms (living rooms, kitchens, bathrooms, bedrooms)
- Commercial kitchens (restaurants, bakeries, fast food)
- Storage areas (warehouses, back rooms, industrial storage)
- Retail stores (clothing, electronics, hardware, groceries)
- Factories and industrial facilities
- Emergency services (police, fire, military)
- Miscellaneous locations (gyms, offices, medical facilities)

#### Protection Mechanism:
The mod hooks into three core game systems:
1. **ISMoveablesAction**: Prevents pickup, rotation, and scrapping
2. **ISDestroyCursor**: Blocks sledgehammer destruction
3. **ISMoveableCursor**: Provides visual feedback with red cursor

#### Compatibility Notes:
- Requires Project Zomboid Build 42.0 or higher
- Uses new `getSpecificPlayer()` API for split-screen support
- Follows Build 42 server/client/shared folder structure
- Fully compatible with multiplayer and dedicated servers

### Repository Structure:
This repository contains:
- **ContainerProtectionB42/**: Main mod folder (Steam Workshop format)
- **B41/**: Legacy Build 41 version for reference
- **v2/**: Development version with latest updates
- **README.md**: This documentation file

### Credits:
- Original Mod: iLusioN
- Build 42 Port: Updated with API compatibility changes
- Documentation: Comprehensive English comments added
