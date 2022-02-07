

DROUGHT.Detrimental = false

local function exit()
	DROUGHT.Detrimental = nil
end

hook.Add('Think', 'detrimental_effect', function()
	
	if DROUGHT.Detrimental and SysTime() > (DROUGHT.Detrimental.time or 0) + 10 then
		local rply = DROUGHT.Detrimental.ply or nil
		if not rply then
			return exit()
		end

		rply:Kill()

		PrintMessageColor(nil, Color(255, 0, 0), 'You didn\'t pick up the detrimental item soon enough, so I slaughtered one of your teammates!')
		PrintMessageColor(nil, Color(255, 0, 0), 'Now someone else has to bear the burden of ', rply:Name(), '\'s actions.')

		local plys = player.GetAll()
		local app = {}
		for k,v in pairs(plys) do
			if IsValid(v) and v:Alive() and v:Team() == 1 and v != rply then
				app[#app + 1] = v
			end
		end

		if next(app) == nil then
			PrintMessageColor(nil, Color(255, 0, 0), 'Oh, that was the last player alive? Sucks to suck.')
			return exit()
		end

		local new = app[math.random(1, #app)]
		if not new then
			return exit()
		end

		GAMEMODE:OnPickupItem(new, DROUGHT.Detrimental.id)
		if DROUGHT.Detrimental.ent and IsValid(DROUGHT.Detrimental.ent) then
			DROUGHT.Detrimental.ent.ForceRemove = true
		end
		exit()
	end

end)

-- hook.Call("OnPickupItem", GAMEMODE, ply, self)
hook.Add('OnPickupItem', 'detrimental_effect', function(ply, item)
	if item:GetSelfRarity() == 5 then
		exit()
		-- PrintMessage(3, 'Someone has to pay the price for your consequences.')
		PrintMessageColor(nil, Color(255, 0, 0), ply:Name(), " had to pay the price for your consequences.")
	end
end)