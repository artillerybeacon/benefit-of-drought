include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

-- models/props_junk/wood_crate001a.mdl
-- models/props_junk/wood_crate002a.mdl


function ENT:Initialize()

	local isbig = false
	self:SetModel("models/props_junk/wood_crate001a.mdl")

	if math.random(1, 15) == 1 then
		isbig = true
		self:SetModel("models/props_junk/wood_crate002a.mdl")
	end

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)

	self:SetPos(self:GetPos() + Vector(0, 0, math.random(8,14)))
	self:SetAngles(Angle(math.random(-25, 25), math.random(-25, 25), 0))

	self:SetUseType(SIMPLE_USE)

	self:SetCost(isbig and 25 * 2.5 or 25)

	-- go through all the items in the game
	local applicable = {}
	local topickrarity = 1
	local weight = math.random(1, 100)


	if isbig then
		topickrarity = math.random(2, 4)
	else
		if weight < 75 then
			topickrarity = 1
		elseif weight >= 75 or weight < 88 then
			topickrarity = 2
		elseif weight >= 88 and weight < 98 then
			topickrarity = 3
		elseif weight >= 98 then
			topickrarity = 4
		end
	end

	for k,v in pairs(GAMEMODE.ItemDefs) do
		if v.rarity == topickrarity then
			table.insert(applicable, k)
		end
	end

	if next(applicable) == nil then
		self:Remove()
	else
		self:SetItemToGive(applicable[math.random(1, #applicable)])
	end

	--PrintMessage(3, tostring(self) .. " has weight " .. tostring(weight) .. " with rarity " .. tostring(topickrarity) .. " and item " .. self:GetItemToGive())

end
-- 
function ENT:Use(act, call)
	if not self.Used and act:Team() == 1 then
		self.Used = true

		local money = act:GetNWInt("drought_money", 0)
		if money < self:GetCost() then
			act:ChatPrint("You cannot buy this.")
			act:EmitSound("buttons/button2.wav")
			timer.Simple(0.2, function()
				if IsValid(self) then
					self.Used = false
				end
			end)
			return
		end

		-- self:CallOnR
		act:SetNWInt("drought_money", money - self:GetCost())
		self:Remove()
		self:EmitSound(")physics/wood/wood_crate_break" .. tostring(math.random(1,5)) .. ".wav")

		local item = ents.Create("item_pickup")
		item:SetItemID(self:GetItemToGive())
		item:SetPos(self:GetPos())
		item:UpdateOurItem()
		item:Spawn()
	end
end

concommand.Add("spawnlootcrate", function(ply)
	local e = ents.Create("altar_of_combat")
	e:SetPos(ply:GetEyeTrace().HitPos)
	e:Spawn()
end)