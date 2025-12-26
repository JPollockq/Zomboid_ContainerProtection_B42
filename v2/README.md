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

3. **sandbox-options.txt**: Moved from `media/` to `media/lua/server/` (correct location)

### Files Structure:
```
v2/
├── mod.info (updated)
└── media/
    └── lua/
        ├── client/
        │   ├── CP_Main.lua (updated)
        │   └── CP_RoomsDefinitions.lua (unchanged)
        ├── server/
        │   └── sandbox-options.txt (moved here)
        └── shared/
            └── Translate/
                ├── EN/
                │   ├── IG_UI_EN.txt
                │   └── Sandbox_EN.txt
                └── PTBR/
                    ├── IG_UI_PTBR.txt
                    └── Sandbox_PTBR.txt
```

### Installation:
1. Copy the entire v2 folder contents to your Project Zomboid mods directory
2. Or rename v2 folder to "ContainerProtection" and use as replacement

### Testing:
After loading the mod, test in Lua console (F11 -> Lua Console):
```lua
print("Player: " .. tostring(getSpecificPlayer(0)))
print("SandboxVars: " .. tostring(SandboxVars.ContainerProtection))
print("Admin Perms: " .. tostring(SandboxVars.ContainerProtection.AdminPermissions))
```

### Features Preserved:
- ✅ All room protection (200+ rooms)
- ✅ Admin/Moderator permissions
- ✅ SafeHouse permissions
- ✅ Multilingual support (EN/PTBR)
- ✅ Sandbox settings
- ✅ All original functionality

### Build Compatibility:
- ✅ Build 42.0+
- ❌ Build 41.x (use original version)
