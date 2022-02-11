local L = Log("drought:itemsys")

SetLoggingMode("drought:itemsys", DROUGHT.Debug)

function GM:EntityTakeDamage(target, dmg)
	-- Negate player vs player damage
	if target:GetClass() == "player" then
		local atk = dmg:GetAttacker()
		if atk:GetClass() == "player" then
			dmg:SetDamage(0)
			return
		end
	end

	-- Custom hook to run proc logic
	hook.Run('DealWithOnHitProcs', dmg:GetAttacker(), target, dmg)

	do return end

	if target:GetClass():find("npc_") then
		local atk = dmg:GetAttacker()

		if IsValid(atk) and atk:IsPlayer() and next(atk.Inventory) != nil then

			if atk.Inventory.huladoll then
				local percentage = 1 + (self.ItemDefs.huladoll.getEffect(atk.Inventory.huladoll))
				dmg:SetDamage(dmg:GetDamage() * percentage)
			end

			if atk.Inventory.beamgut then
				local fb = atk.Inventory.beamgut
				local chance = math.ceil(5 + (fb - 1 == 0 and 0 or math.log(fb / 6 + 1)) * 20) / 100

				print(chance)

				if math.random() < chance then
					atk:EmitSound'DeathBeam'
					local percentage = (1 + self.ItemDefs.beamgut.getEffect(fb) / 100) * dmg:GetDamage()
					dmg:SetDamage(percentage)
				end
			end

		end
	elseif target:IsPlayer() then
		local atk = target
		if IsValid(atk) and atk:IsPlayer() and next(atk.Inventory) != nil then
			if atk.Inventory.debuffdoll then
				local percentage = 1 + (self.ItemDefs.debuffdoll.getEffect(atk.Inventory.debuffdoll) / 100)
				dmg:SetDamage(dmg:GetDamage() * percentage)
			end

			print(dmg:GetAttacker())


		end
	end
end

function GM:OnNPCKilled(npc, atk, inf)

	-- give amount to players and give 1/4 of the amount to everyone else
	if npc.LastHit and IsValid(npc.LastHit) then
		atk = npc.LastHit
		if not atk:IsPlayer() then return end
	end

	local toGive = npc:GetNWInt("reward", 3)
	local toGiveEveryoneElse = math.ceil(toGive / 4)

	toGive, toGiveEveryoneElse = hook.Run('CalculateExtraMoney', atk, toGive, toGiveEveryoneElse)

	atk:SetNWInt("drought_money", atk:GetNWInt("drought_money", 0) + toGive)

	for k,v in pairs(player.GetHumans()) do
		if v == atk then continue end

		v:SetNWInt("drought_money", v:GetNWInt("drought_money", 0) + toGiveEveryoneElse)
	end

	atk:SetFrags(atk:Frags() + 1)
	
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

hook.Add("PlayerSay", 'asd', function(ply, txt)
	if txt:sub(1, 5) == "!give" then
		txt = txt:sub(7)
		ply.Inventory[txt] = (ply.Inventory[txt] or 0) + 30
		GAMEMODE:SendItemChange(ply, txt, ply.Inventory[txt])
		ply:RecalculateVars()
	end
end)

L("Item system loaded")