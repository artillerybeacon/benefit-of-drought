local L = Log("drought:wisp")
SetLoggingMode("drought:wisp", DROUGHT.Debug)

local function SetupWisp()
	local lua = ents.Create('lua_run')
	lua:SetName('drought_lua')
	lua:Spawn()
	L('Wisp->CScanner override active... ', lua)
end

local WispSpawnCard = select(2, include('spawn_cards.lua'))["npc_cscanner"]
L("Wisp Spawn Card: ", WispSpawnCard)

local function validity(c, a)

	if not IsValid(a) or not a:IsPlayer() or a:Health() < 1 then return false end
	if not IsValid(c) or c:Health() < 1 then return false end

	return true

end

hook.Add("WispAcquireTarget", 'wisp', function()
	L('Wisp attacked someone: ', ACTIVATOR, CALLER)

	local c, a = CALLER, ACTIVATOR

	if not validity(c, a) then return end
	
	local endpos = a:GetPos() + Vector(0, 0, a:OBBMaxs().z / 2)

	timer.Simple(0.15, function()
	
		if validity(c, a) then
			
			local other = a:GetPos() + Vector(0, 0, a:OBBMaxs().z / 2)
			endpos = LerpVector(0.9, endpos, other)

			local bullet = {
				Attacker = c,
				Damage = WispSpawnCard.stats.base_dmg + (WispSpawnCard.stats.hp_dmg * c:GetNWInt('level', 0)),
				Force = 1,
				Num = 3,
				Tracer = 1,
				TracerName = 'AR2Tracer',
				Src = c:GetPos() + (c:GetForward() * 20) - (c:GetUp() * 15),
				IgnoreEntity = c,
				Spread = Vector(8, 8, 0)
			}
			bullet.Dir = (endpos - bullet.Src)--:GetNormalized()
			-- print(WispSpawnCard.stats.base_dmg,WispSpawnCard.stats.hp_dmg,c:GetNWInt('level',0))
			L('Wisp ', c, ' attacking with dmg: ', bullet.Damage)
			c:FireBullets(bullet)

		end

	end)
	
end)

hook.Add('InitPostEntity', 'wisp', SetupWisp)
hook.Add('PostCleanupMap', 'wisp', SetupWisp)