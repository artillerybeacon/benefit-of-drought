

elites = elites or {}

local flame_offsets = {
	npc_headcrab = 0,
	npc_zombie = 0.7,
	npc_antlion = 0.5,
	player = 0.75
}

net.Receive("drought_network_affix", function()
	local ent = net.ReadEntity()
	local affix = net.ReadString()
	
	elites[ent] = affix

	chat.AddText('ent: ', ent, ', aff: ', affix)
end)

local ca = Color(218, 123, 0)
local function RenderFireEffect(k)
	k:SetColor(Color(255, 0, 0))

	if not k.lastFireEffect then
		k.lastFireEffect = SysTime()
	end

	if SysTime() > k.lastFireEffect + 0.15 then
		k.lastFireEffect = SysTime()

		local r = flame_offsets[k:GetClass()] or 1

		local vOffset = k:GetPos() + Vector(0, 0, k:OBBMaxs().z * r)
		local emitter = ParticleEmitter( vOffset, false )
		for i = 0, 3 do
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
end

local function RenderIceEffect(k)
	k:SetColor(Color(0, 100, 255))

	if not k.lastSnowEffect then
		k.lastSnowEffect = SysTime()
	end

	if SysTime() > k.lastSnowEffect + 0.15 then
		k.lastSnowEffect = SysTime()

		local r = flame_offsets[k:GetClass()] or 1

		local vOffset = k:GetPos() + Vector(0, 0, k:OBBMaxs().z * r)
		local emitter = ParticleEmitter( vOffset, false )
		for i = 0, 3 do
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

local function RenderLightningEffect(k)
	k:SetColor(Color(255, 255, 0))

	if not k.lastZapEffect then
		k.lastZapEffect = SysTime()
	end

	if SysTime() > k.lastZapEffect + 0.15 then
		k.lastZapEffect = SysTime()

		local r = flame_offsets[k:GetClass()] or 1

		local vOffset = k:GetPos() + Vector(0, 0, k:OBBMaxs().z * r)
		local emitter = ParticleEmitter( vOffset, false )
		local s = 15
		for i = 0, 3 do
			local part = emitter:Add("trails/electric", vOffset + VectorRand() * k:OBBMaxs().x * 1.5) -- Create a new particle at pos
			if (part) then
				part:SetDieTime(.15) -- How long the particle should "live"
				part:SetStartAlpha(255) -- Starting alpha of the particle
				part:SetEndAlpha(255) -- Particle size at the end if its lifetime
				part:SetStartSize(s * math.random()) -- Starting size
				part:SetEndSize(part:GetStartSize()) -- Size when removed
				--part:SetGravity(0) -- Gravity of the particle
				--part:SetVelocity(0) -- Initial velocity of the particle
				--part:SetAngleVelocity(0)
				--part:SetStartLength(s*2)
				--part:SetEndLength(s*2)
				part:SetAngles(AngleRand() * 15)
				part:SetColor(255, 255, 0)
			end

		end

		emitter:Finish()
	end
end

local renderers = {
	['f'] = RenderFireEffect,
	['i'] = RenderIceEffect,
	['l'] = RenderLightningEffect,
}

hook.Add("Think", "drought_draw_affix", function()

	if next(elites) == nil then return end

	for k,v in pairs(elites) do

		if not IsValid(k) or k:Health() < 1 then
			elites[k] = nil
			continue
		end

		if not k.PrevColor then
			k.PrevColor = k:GetColor()
		end

		if renderers[v] then renderers[v](k) end

	end

end)
