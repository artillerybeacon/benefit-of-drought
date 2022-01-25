if CLIENT then

	local ca = Color(218, 123, 0)

	local eliteAffixEffectList = {
		["f"] = 'drought_elite_fire'
	}

	local elites = {}

	local flame_offsets = {
		npc_headcrab = 0,
		npc_zombie = 0.7,
		npc_antlion = 0.5,
		
		player = 0.75
	}

	net.Receive('drought_network_affix', function()
		local ent = net.ReadEntity()
		local affix = net.ReadString()

		--local effStr = eliteAffixEffectList[affix]
		--if not effStr then return end

		elites[ent] = affix
		print(ent, affix)
	end)

	hook.Add('Think', 'drought_draw_affix', function()

		if next(elites) == nil then return end

		for k,v in pairs(elites) do

			if not IsValid(k) or k:Health() < 1 then
				elites[k] = nil
				continue
			end

			if not k.PrevColor then
				k.PrevColor = k:GetColor()
			end

			if v == 'f' then

				k:SetColor(Color(255, 0, 0))

				if not k.lastFireEffect then
					k.lastFireEffect = SysTime()
				end

				if SysTime() > k.lastFireEffect + 0.15 then
					k.lastFireEffect = SysTime()

					local r = 1
					if flame_offsets[k:GetClass()] then
						r = flame_offsets[k:GetClass()]
					end

					local vOffset = k:GetPos() + Vector(0, 0, k:OBBMaxs().z * r)
					local emitter = ParticleEmitter( vOffset, false )
					for i=0, 3 do
						local particle = emitter:Add( "effects/softglow", vOffset )
						
						local s = math.random(25, 45)
						if particle then
							particle:SetAngles( EyeAngles() )
							particle:SetVelocity( VectorRand() )
							particle:SetGravity( Vector(0, 0, 100) )
							particle:SetColor( ca:Unpack() )
							particle:SetLifeTime( 0 )
							particle:SetDieTime( 0.67 )
							particle:SetStartAlpha( 255 )
							particle:SetEndAlpha( 100 )
							particle:SetStartSize( s )
							particle:SetStartLength( s )
							particle:SetEndSize( 10 )
							particle:SetEndLength( 25 )
						end
					end

					emitter:Finish()
				end

			elseif v == 'i' then

				k:SetColor(Color(0, 100, 255))

				if not k.lastSnowEffect then
					k.lastSnowEffect = SysTime()
				end

				if SysTime() > k.lastSnowEffect + 0.15 then
					k.lastSnowEffect = SysTime()


					-- chat.AddText'blals'
					local r = 1
					if flame_offsets[k:GetClass()] then
						r = flame_offsets[k:GetClass()]
					end

					local vOffset = k:GetPos() + Vector(0, 0, k:OBBMaxs().z * r)
					local emitter = ParticleEmitter( vOffset, false )
					for i=0, 3 do
						local particle = emitter:Add( "effects/softglow", vOffset )
						
						local s = math.random(25, 45)
						local part = emitter:Add("particle/smokesprites_0001", vOffset + VectorRand() * k:OBBMaxs().x) -- Create a new particle at pos
						if (part) then
							part:SetDieTime(math.random() * 2) -- How long the particle should "live"
							part:SetStartAlpha(255) -- Starting alpha of the particle
							part:SetEndAlpha(0) -- Particle size at the end if its lifetime
							part:SetStartSize(math.random(4, 10)) -- Starting size
							part:SetEndSize(0) -- Size when removed
							part:SetGravity(Vector(0, 0, -25)) -- Gravity of the particle
							part:SetVelocity(VectorRand() * 50) -- Initial velocity of the particle
							part:SetAngleVelocity(AngleRand() / 15)
							part:SetColor(255, 255, 255)
						end

					end

					emitter:Finish()
				end

			end


		end

	end)

	return

end

local EliteCards = {

	{
		CostMult = 1,
		Tier = 0,
		HPMult = 1,
		Choices = {}
	},
	{
		CostMult = 6,
		Tier = 1,
		HPMult = 4,
		Choices = {
			'f', 'i', 'l'
		}
	},
	{
		CostMult = 36,
		Tier = 2,
		HPMult = 18,
		Choices = {
			'u'
		}
	}

}

		/*if eliteAffix == 'f' then
			local ef = EffectData()
			ef:SetEntity(e)
			local rf = RecipientFilter()
			rf:AddPVS(e:GetPos())
			timer.Simple(0, function()
				util.Effect('drought_elite_fire', ef, false, rf)
			end)
		end
*/
function DROUGHT:ChoseEliteAffix(card, SpawnCards)

	local eliteAffix, eliteTier--  = DROUGHT:ChoseEliteAffix()
	
	local force = false

	local spawnCost = SpawnCards[card].cost
	
	-- force = true

	if not force then
		for i = 1, #EliteCards do
			local elite_type = EliteCards[i]
			local elite_cost = elite_type.CostMult * SpawnCards[card].cost
			if elite_cost > self.DirectorCredits then
				break
			end

			if next(elite_type.Choices) != nil then
				eliteAffix = elite_type.Choices[math.random(1, #elite_type.Choices)]
				eliteTier = i
			end
		end

		if eliteAffix then
			spawnCost = spawnCost * EliteCards[eliteTier].CostMult
		end
	else
		eliteAffix = 'i'
		eliteTier = 1
	end

	return eliteAffix, eliteTier, spawnCost

end

util.AddNetworkString('drought_network_affix')
function DROUGHT:HandleEliteAffix(ent, eliteAffix, eliteTier)
	if eliteAffix == nil or eliteTier == nil then return end

	timer.Simple(0, function()
		
		net.Start('drought_network_affix')
			net.WriteEntity(ent)
			net.WriteString(eliteAffix)
		net.SendPVS(ent:GetPos())
	end)

	// TODO: Set entity health
	// lua_run DROUGHT:HandleEliteAffix(Player(5), 'f', 1)
end


// Ice Affix
hook.Add('EntityTakeDamage', 'IceAffix', function(target, dmg)

	if IsValid(target) and target:IsPlayer() then
		local atk = dmg:GetAttacker()
		local affix = atk:GetNWString('affix', '')

		if affix != '' and affix == 'i' then

			target.Iced = true
			GAMEMODE:RecalculateMovementVars(target)

			local start = SysTime()
			local t = 'checker' .. target:Nick()
			timer.Create(t, 0.25, 20, function()
				if not IsValid(target) or target:Health() < 1 then
					timer.Remove(t)
					return
				end
				
				if SysTime() > start + 4.9 then
					target.Iced = false
					GAMEMODE:RecalculateMovementVars(target)
				end
			end)

		end
	end

end)

hook.Add('PostSpeedModHook', 'IceAffix', function(ply, initw, initr, neww, newr)

	if ply.Iced then
		neww = neww * 0.65
		newr = newr * 0.65

		return neww, newr
	end

end)

/*

	self:PostSpeedModHook(
		ply,
		default_walk,
		default_walk*2,
		ply:GetWalkSpeed(),
		ply:GetRunSpeed()
	)
*/