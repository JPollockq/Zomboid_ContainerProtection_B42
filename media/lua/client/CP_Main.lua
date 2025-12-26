-----------------------------------------------------------------------------------
------------------------- Container Protection by iLusioN -------------------------
--  Do not copy any of this. But if you do anyway at least give me some credit.  --
-----------------------------------------------------------------------------------

require "CP_RoomsDefinitions.lua" -- Arquivo de definição de "Rooms"

---------------------------------------------------------------------------------------------
-- Configurações padrões // pickup = pegar/ rotate = rotacionar / scrap = disassemble,destroy / place = colocar.

local blockedMoveableModes = {
	pickup = true,
	rotate = true,
	scrap = true,
	place = false,
};

---------------------------------------------------------------------------------------------
-- Checa as Salas (Aonde a mágica acontece hehexd)

local function isSquareValid(_square, _action)
	if not _square then return true; end;
	local room = _square:getRoom();
	if not room then return true; end;
	local roomName = room:getName() or "Unknown";
	local player = getPlayer()
	
		if protectedRooms[roomName] then
			if protectedRooms[roomName].disabledActions[_action] then
			
					-- Permite que Administradores e Moderadores controlem os containers.
					if SandboxVars.ContainerProtection.AdminPermissions == true then
						if (player:getAccessLevel() == "Admin") or (player:getAccessLevel() == "Moderator") then
							return true;
						end
					end
					
					-- Permite que os Donos e Membros da Safehouse controlem os containers.
					if SandboxVars.ContainerProtection.SafeHousePermissions == true then
					local safehouse = SafeHouse.getSafeHouse(_square)
						if safehouse then
							if safehouse:isOwner(player) or safehouse:playerAllowed(player) then
								return true;
							end
						end
					end
					
				local player = getPlayer();
				--player:Say("This container is protected!");
				player:setHaloNote(getText("IGUI_ContainerProtected"));
				return false;
			end
		end
			
	return true;

end

---------------------------------------------------------------------------------------------
-- Checa os Objetos

local function isObjectProtected(_object)
	if _object then
		if _object:getContainer() then
			if _object:getObjectName() ~= "Thumpable" then
				return true;
			end;
		end;
	end;
	return false;
end

---------------------------------------------------------------------------------------------
-- Altera as ações

local callback_ISMoveablesAction_isValid;
local callback_ISDestroyCursor_isValid;
local callback_ISMoveableCursor_isValid;

local function initContainerProtection()
	-- Remove a inicialização para carregar o servidor por completo.
	Events.EveryOneMinute.Remove(initContainerProtection);
	
	if ISMoveablesAction then
		callback_ISMoveablesAction_isValid = ISMoveablesAction.isValid;
		ISMoveablesAction.isValid = function(self)
			local retVal = callback_ISMoveablesAction_isValid(self);
			if retVal == true then
				if blockedMoveableModes[self.mode] then
					if self.moveProps and isObjectProtected(self.moveProps.object) then
						retVal = isSquareValid(self.square, "ISMoveablesAction");
					end;
				end;
			end;
			return retVal;
		end;
	end;

	if ISDestroyCursor then
		callback_ISDestroyCursor_isValid = ISDestroyCursor.isValid;
		ISDestroyCursor.isValid = function(self, _square)
			local retVal = callback_ISDestroyCursor_isValid(self, _square);
			if retVal == true then
				if isObjectProtected(self.currentObject) then
					retVal = isSquareValid(_square, "ISDestroyCursor");
				end;
			end;
			return retVal;
		end;
	end;

	if ISMoveableCursor then
		callback_ISMoveableCursor_isValid = ISMoveableCursor.isValid;
		ISMoveableCursor.isValid = function(self, _square)
			local retVal = callback_ISMoveableCursor_isValid(self, _square);
			if retVal == true then
				if blockedMoveableModes[ISMoveableCursor.mode[self.player]] then
					if isObjectProtected(self.cacheObject) then
						retVal = isSquareValid(_square, "ISMoveableCursor");
					end;
				end;
			end;
			if not retVal then self.colorMod = {r=1,g=0,b=0}; end;
			return retVal or false;
		end;
	end;
end

-- Garante que o servidor está totalmente carregado antes de iniciar o script.
Events.EveryOneMinute.Add(initContainerProtection);
