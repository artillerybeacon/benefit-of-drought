


local default_walk = 200
local default_jump = 200

function GM:RecalculateAttackSpeed(ply)

	local wep = ply:GetActiveWeapon()
	if IsValid(wep) and wep.Primary and wep.Primary.Delay then

		local delay
		if not wep.Primary.StoredDelay then
			wep.Primary.StoredDelay = wep.Primary.Delay
		end

		delay = wep.Primary.StoredDelay
		
		local extraASpeed = math.max(1 - (hook.Run('CalcASpeed', ply) or 0), 0)
		--if ply.Inventory and ply.Inventory.oilbarrel then
		--	extraASpeed = math.max(extraASpeed - self.ItemDefs.oilbarrel.getEffect(ply.Inventory.oilbarrel), 0)
		--end

		delay = delay * extraASpeed

		wep.Primary.Delay = math.Round(delay, 6)

		wep:CallOnClient('HackySetDelay', tostring(wep.Primary.Delay))

	end

end

// Movement Speed
function GM:RecalculateMovementVars(ply)
	local extraSpeed, extraJump = hook.Run( 'CalculateMovementVars', ply, 0, 0 )

	ply:SetRunSpeed((default_walk * 2) + (extraSpeed * 2))
	ply:SetWalkSpeed(default_walk + extraSpeed)
	ply:SetJumpPower(default_jump + extraJump)
end

local Player = FindMetaTable('Player')
function Player:RecalculateVars()
	
	PrintMessage(3, 'Recalculating... ' .. tostring(self))
	GAMEMODE:RecalculateAttackSpeed(self)
	GAMEMODE:RecalculateMovementVars(self)

end


function GM:PlayerSwitchWeapon(ply, old, new)
	ply:RecalculateVars()
	return false
end