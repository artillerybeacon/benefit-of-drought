local L = Log("drought:itemsys")

SetLoggingMode("drought:itemsys", DROUGHT.Debug)

function GM:EntityTakeDamage(target, dmg)
	-- NPC items
	if target:GetClass():find("npc_") then
		local atk = dmg:GetAttacker()

		if IsValid(atk) and atk:IsPlayer() and next(atk.Inventory) != nil then

			if atk.Inventory.firebucket then
				local fb = atk.Inventory.firebucket
				local chance = math.ceil(15 + (fb - 1 == 0 and 0 or math.log(fb / 6 + 1)) * 15)
				print(chance)

				if math.random(1, 100) <= chance then
					target:Ignite(5)
					target.LastHit = atk
				end
			end
		end
	elseif target:IsPlayer() then
		local atk = target
		if IsValid(atk) and atk:IsPlayer() and next(atk.Inventory) != nil then
			
			if atk.Inventory.antliongib then
				local fb = atk.Inventory.antliongib
				local reduction = math.ceil(5 + (fb - 1 == 0 and 0 or math.log(fb / 6 + 1)) * 20)
				
				local newdmg = dmg:GetDamage() / (1 + reduction / 100)

				dmg:SetDamage(newdmg)
			end
		end
	end
end

function GM:OnNPCKilled(npc, atk, inf)
	-- give amount to players and give 1/4 of the amount to everyone else

	if npc.LastHit and IsValid(npc.LastHit) then
		atk = npc.LastHit
	end

	local toGive = npc:GetNWInt("reward", 3)
	local toGiveEveryoneElse = math.ceil(toGive / 4)

	atk:SetNWInt("drought_money", atk:GetNWInt("drought_money", 0) + toGive)

	for k,v in pairs(player.GetHumans()) do
		if v == atk then continue end

		v:SetNWInt("drought_money", v:GetNWInt("drought_money", 0) + toGiveEveryoneElse)
	end

	atk:SetFrags(atk:Frags() + 1)

	if IsValid(atk) and atk:IsPlayer() and next(atk.Inventory) != nil then
		if atk.Inventory.register then
			local extraCash = self.ItemDefs.register.getEffect(atk.Inventory.register)
			atk:SetNWInt("drought_money", atk:GetNWInt("drought_money", 0) + extraCash)
		end
	end
end

concommand.Add("zambie", function(ply)
	local e = ents.Create("npc_zombie")

	e:SetPos(ply:GetEyeTrace().HitPos)

	e:Spawn()
end)

concommand.Add("giveall", function(ply)
	for k,v in pairs(GAMEMODE.ItemDefs) do
		
		ply.Inventory[k] = 30
		GAMEMODE:SendItemChange(ply, k, 30)
		
	end
end)

L("Item system loaded")