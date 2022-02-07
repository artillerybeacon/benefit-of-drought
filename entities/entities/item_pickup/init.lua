include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

function ENT:Initialize()

	--self:DefaultVars()
	
	self:SetAngles(Angle())
	self:DrawShadow(false)

	self:SetModelScale(0)
	
	self:UpdateOurItem()
	self.SpawnPos = self:GetPos()

end

function ENT:UpdateOurItem()
	local id = self:GetItemID()
	local item = GAMEMODE.ItemDefs[id]

	if not item then
		error(tostring(self) .. " has invalid id " .. id)
	end

	self:SetModel(item.mdl)
	self:SetSelfRarity(item.rarity)
	self:SetSelfName(item.name)
	self:SetModelScale(item.mdlScale or 1, 0.25)
	self:PhysicsInit(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:SetPos(self:GetPos() - (item.spawnOffset or Vector(0, 0, 0)))

end

function ENT:Touch(ent)
	--[[if not self.Removed then
		self.Removed = true

		SafeRemoveEntityDelayed(self, 0.1)
		self:SetModelScale(0, 0.1)
		self:SetSolid(SOLID_NONE)

		hook.Call("OnPickupItem", GAMEMODE, ent, self)
	end]]
end

function ENT:Think()
	if not self.LastCheck then self.LastCheck = SysTime() end

	if SysTime() > self.LastCheck + 0.25 and not self.Removed then
		self.LastCheck = SysTime()

		local ent = ents.FindInSphere(self.SpawnPos, 50)
		
		local applicable = {}

		for k,v in pairs(ent) do
			if IsValid(v) and v:IsPlayer() then
				table.insert(applicable, v)
			end
		end

		if next(applicable) != nil or self.ForceRemove then
			local ply = applicable[math.random(1, #applicable)]

			self.Removed = true
			self.ForceRemove = nil

			SafeRemoveEntityDelayed(self, 0.1)
			self:SetModelScale(0, 0.1)
			self:SetSolid(SOLID_NONE)

			hook.Call("OnPickupItem", GAMEMODE, ply, self)
		end
	end
end