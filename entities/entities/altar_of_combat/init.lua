include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

util.AddNetworkString("drought_caltar_notif")
util.AddNetworkString("drought_combat_beam")

function ENT:Initialize()

	self.SpawnPos = self:GetPos()
	self.Enemies = {}

	self:SetModel("models/props_c17/gravestone_statue001a.mdl")
	self:SetColor(Color(120, 120, 120))

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)

	self:SetPos(self:GetPos() + Vector(0, 0, 50))
	self:SetAngles(Angle(math.random(-10, 10), math.random(-180, 180), 0))

	self:SetUseType(SIMPLE_USE)
	self:DrawShadow(false)

	self:SetCost(25 * 15.5)
	self:SetIsDone(false)
	self:SetIsDoneSpawning(false)

end

function ENT:Use(activator)
	if self:GetIsInProgress() then return end

	self:SetIsInProgress(true)

	util.ScreenShake(self:GetPos(), 5, 5, 1, 2000)

	net.Start("drought_caltar_notif")
		net.WriteEntity(activator)
	net.Send(player.GetHumans())

	local hordecount = math.random(1, 3)
	local circle_amnts = math.random(3, 6)
	local dist = 300

	for i = 1, circle_amnts do
		timer.Simple(0.25 * i, function()

			if not IsValid(self) then return end

			local frac = (360 / circle_amnts) * i
			local s = math.sin(math.rad(frac))
			local c = math.cos(math.rad(frac))

			local pos = self.SpawnPos + Vector(s * dist, c * dist, 10)

			if not util.IsInWorld(pos) then
				local area = navmesh.GetNearestNavArea(pos, false, dist, false)
				pos = area:GetCenter()
			end

			net.Start("drought_combat_beam")
			net.WriteVector(pos)
				net.WriteVector(self:GetPos() + Vector(0, 0, 25) + Vector(0, 0, self:OBBMaxs().z))
				
			net.SendPVS(activator:GetPos())

		end)
		timer.Simple(0.25 + 0.25 * i, function()
			if not IsValid(self) then return end

			local frac = (360 / circle_amnts) * i
			local s = math.sin(math.rad(frac))
			local c = math.cos(math.rad(frac))

			local pos = self.SpawnPos + Vector(s * dist, c * dist, 10)

			if not util.IsInWorld(pos) then
				local area = navmesh.GetNearestNavArea(pos, false, dist, false)
				pos = area:GetCenter()
			end

			local ent = ents.Create("npc_zombie")
			ent:SetPos(pos)
			ent:Spawn()

			timer.Simple(0.5, function()
				if not ent:IsInWorld() then
					local area = navmesh.GetNearestNavArea(pos, false, dist, false)
					ent:SetPos(area:GetCenter())
				end
			end)

			table.insert(self.Enemies, ent)

			if i == circle_amnts then
				self:SetIsDoneSpawning(true)
			end
		end)
	end
end

function ENT:Think()
	if not self.LastCheck then
		self.LastCheck = SysTime()
	end

	if self:GetIsInProgress() and self:GetIsDoneSpawning() and SysTime() > self.LastCheck + 0.5 then
		self.LastCheck = SysTime()

		for k,e in pairs(self.Enemies) do
			if not IsValid(e) or e:Health() < 1 then
				table.remove(self.Enemies, k)
			end
		end
		
		if #self.Enemies == 0 then
			self.LastCheck = 99999999
			self:SetIsDone(true)
			SafeRemoveEntityDelayed(self, 0.75)

			self:EmitSound(")npc/assassin/ball_zap1.wav")

			timer.Simple(0.75, function()
				local applicable = {}
				local topickrarity = 1
				local weight = math.random(1, 100)

				if weight < 75 then
					topickrarity = 1
				elseif weight >= 75 or weight < 88 then
					topickrarity = 2
				elseif weight >= 88 and weight < 98 then
					topickrarity = 3
				elseif weight >= 98 then
					topickrarity = 4
				end

				for k,v in pairs(GAMEMODE.ItemDefs) do
					if v.rarity == topickrarity then
						table.insert(applicable, k)
					end
				end

				if next(applicable) != nil then
					local ent = ents.Create("item_pickup")
					ent:SetPos(self.SpawnPos)
					ent:SetItemID(applicable[math.random(1,#applicable)])
					ent:UpdateOurItem()
					ent:Spawn()	
				end
			end)
		end
	end
end

