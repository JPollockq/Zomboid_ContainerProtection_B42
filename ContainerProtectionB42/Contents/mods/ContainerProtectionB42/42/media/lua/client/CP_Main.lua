-----------------------------------------------------------------------------------
------------------------- Container Protection by iLusioN -------------------------
--  Do not copy any of this. But if you do anyway at least give me some credit.  --
--          Build 42 Compatible - Updated for Project Zomboid Build 42+           --
-----------------------------------------------------------------------------------

-- Load required modules explicitly (PZWiki recommended practice)
-- This ensures all dependencies are loaded before our code executes
require "CP_RoomsDefinitions"

-- Load PZ core classes that we will hook into
-- These are Lua classes from the game's BuildingObjects and Moveables systems
-- Source: media/lua/BuildingObjects/ and media/lua/Moveables/
-- Explicit requires ensure proper load order and clear dependency declarations
require "Moveables/ISMoveablesAction"
require "BuildingObjects/ISDestroyCursor"
require "BuildingObjects/ISMoveableCursor"

---------------------------------------------------------------------------------------------
-- Default Configuration Settings
-- These modes define which moveable object actions are blocked by the protection system:
--   pickup  = Picking up containers and moveables
--   rotate  = Rotating furniture and objects
--   scrap   = Disassembling/destroying objects with tools
--   place   = Placing objects (currently allowed for gameplay flexibility)

local blockedMoveableModes = {
	pickup = true,
	rotate = true,
	scrap = true,
	place = false,
}

---------------------------------------------------------------------------------------------
-- CORE VALIDATION FUNCTION: Checks if a square/room allows the specified action
-- This is where the protection magic happens - validates room-based permissions
--
-- Parameters:
--   _square: The IsoGridSquare object being checked
--   _action: The action type (ISMoveablesAction, ISDestroyCursor, or ISMoveableCursor)
--
-- Returns:
--   true  = Action is allowed (not protected or user has permission)
--   false = Action is blocked (protected room and user lacks permission)

local function isSquareValid(_square, _action)
	-- Safety check: Allow action if no square is provided
	if not _square then return true end
	
	-- Get the room from the square - rooms define protected areas
	local room = _square:getRoom()
	if not room then return true end -- No room = outdoor/unprotected area
	
	-- Get room name for lookup in protection table
	local roomName = room:getName() or "Unknown"
	
	-- Build 42 Compatibility: Use getSpecificPlayer(0) instead of deprecated getPlayer()
	-- In Build 42, getPlayer() is deprecated due to split-screen multiplayer support
	local player = getSpecificPlayer(0)
	if not player then return true end -- No player = allow (safety fallback)
	
		-- Check if this room is in our protection list
		if protectedRooms[roomName] then
			-- Check if this specific action is disabled for this room type
			if protectedRooms[roomName].disabledActions[_action] then
			
					-- PERMISSION CHECK 1: Server Staff Override
					-- Allow Administrators and Moderators to bypass protection if enabled
					if SandboxVars.ContainerProtection.AdminPermissions == true then
						-- Get player's access level from server
						local accessLevel = player:getAccessLevel()
						-- Grant full access to Admin and Moderator roles
						if accessLevel == "Admin" or accessLevel == "Moderator" then
							return true
						end
					end
					
					-- PERMISSION CHECK 2: SafeHouse Membership
					-- Allow SafeHouse owners and members to manage containers in their claimed areas
					if SandboxVars.ContainerProtection.SafeHousePermissions == true then
						-- Get the SafeHouse object for this square (if any)
						local safehouse = SafeHouse.getSafeHouse(_square)
						if safehouse then
							-- Check if player is owner or has been granted access
							if safehouse:isOwner(player) or safehouse:playerAllowed(player) then
								return true -- Allow access for SafeHouse members
							end
						end
					end
					
				-- PROTECTION TRIGGERED: Display warning message
				-- Show red text notification above player's head
				-- Parameters: (message, red, green, blue, duration_ticks)
				player:setHaloNote(getText("IGUI_ContainerProtected"), 255, 100, 100, 300)
				return false
			end
		end
			
	return true
end

---------------------------------------------------------------------------------------------
-- OBJECT VALIDATION FUNCTION: Determines if an object is a protected container
--
-- This function checks if an object should be protected from player actions.
-- Protected objects are those that have containers (storage) and are not temporary structures.
--
-- Parameters:
--   _object: The IsoObject to check
--
-- Returns:
--   true  = Object is a container and should be protected
--   false = Object is not a container or is a temporary/destructible structure

local function isObjectProtected(_object)
	if _object then
		-- Check if object has a container (storage capacity)
		if _object:getContainer() then
			-- Exclude "Thumpable" objects (player-built walls/structures)
			-- These are meant to be destroyed and shouldn't be protected
			if _object:getObjectName() ~= "Thumpable" then
				return true -- This is a protected world container
			end
		end
	end
	return false -- Not a container or is a destructible structure
end

---------------------------------------------------------------------------------------------
-- ACTION OVERRIDE SYSTEM
--
-- This section hooks into Project Zomboid's native action validation functions.
-- We store references to the original functions and replace them with our custom
-- validation logic that adds room-based protection checks.
--
-- Pattern for each hook:
--   1. Save original function reference (before overriding)
--   2. Create new function that wraps the original
--   3. Call original validation first
--   4. Add our protection layer
--   5. Return combined result
--
-- Note: By requiring the classes at the top of the file, we guarantee they exist here.
-- This approach is recommended by PZWiki for reliable mod initialization.

-- Store original validation function references
-- These will be called first, then we add our protection layer
local original_ISMoveablesAction_isValid = ISMoveablesAction.isValid
local original_ISDestroyCursor_isValid = ISDestroyCursor.isValid
local original_ISMoveableCursor_isValid = ISMoveableCursor.isValid

---------------------------------------------------------------------------------------------
-- HOOK 1: ISMoveablesAction.isValid
-- Handles furniture movement actions (pickup, rotate, scrap, place)
--
-- This function is called by the game whenever a player attempts to interact
-- with a moveable object (furniture, containers, etc.)

function ISMoveablesAction:isValid()
	-- First, run the game's original validation
	local retVal = original_ISMoveablesAction_isValid(self)
	
	-- Only add protection check if base validation passed
	if retVal == true then
		-- Check if this action mode is in our blocked list
		if blockedMoveableModes[self.mode] then
			-- Verify the object is a protected container
			if self.moveProps and isObjectProtected(self.moveProps.object) then
				-- Apply room-based validation
				retVal = isSquareValid(self.square, "ISMoveablesAction")
			end
		end
	end
	
	return retVal
end

---------------------------------------------------------------------------------------------
-- HOOK 2: ISDestroyCursor.isValid
-- Handles sledgehammer destruction validation
--
-- Called when player hovers with sledgehammer to show if object can be destroyed

function ISDestroyCursor:isValid(square)
	-- Run original game validation
	local retVal = original_ISDestroyCursor_isValid(self, square)
	
	-- Add protection check if base validation passed
	if retVal == true then
		-- Check if targeting a protected container
		if isObjectProtected(self.currentObject) then
			-- Apply room-based validation
			retVal = isSquareValid(square, "ISDestroyCursor")
		end
	end
	
	return retVal
end

---------------------------------------------------------------------------------------------
-- HOOK 3: ISMoveableCursor.isValid
-- Handles cursor preview when selecting moveables
--
-- Provides visual feedback (green/red cursor) before player commits to action

function ISMoveableCursor:isValid(square)
	-- Run original game validation
	local retVal = original_ISMoveableCursor_isValid(self, square)
	
	-- Add protection check if base validation passed
	if retVal == true then
		-- Check if this cursor mode is blocked
		if blockedMoveableModes[ISMoveableCursor.mode[self.player]] then
			-- Check if targeting a protected container
			if isObjectProtected(self.cacheObject) then
				-- Apply room-based validation
				retVal = isSquareValid(square, "ISMoveableCursor")
			end
		end
	end
	
	-- Visual feedback: Turn cursor red if action is blocked
	if not retVal then 
		self.colorMod = {r=1, g=0, b=0} -- RGB red color
	end
	
	return retVal or false
end

---------------------------------------------------------------------------------------------
-- INITIALIZATION COMPLETE
-- Debug logging for troubleshooting (appears in console.txt)
-- Confirms that the mod loaded successfully and hooks are in place

print("[Container Protection] Build 42 - Hooks installed successfully")
print("[Container Protection] Protected room types: " .. (protectedRooms and "Loaded" or "ERROR: Not loaded!"))
if protectedRooms then
	local count = 0
	for _ in pairs(protectedRooms) do count = count + 1 end
	print("[Container Protection] Total protected room types: " .. count)
end
