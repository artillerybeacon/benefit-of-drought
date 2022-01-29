

DROUGHT.Detrimental = false



hook.Add('Think', 'detrimental_effect', function()
	
	if DROUGHT.Detrimental and SysTime() > DROUGHT.Detrimental + 60 then
		local plys = player.GetAll()
		local app  = {}
		for k,v in pairs(plys) do
			if IsValid(v) and v:Alive() and v:Team() == 1 then
				app[#app + 1] = v
			end
		end

		local rply = app[math.random(1, #app)]

		if not rply then return end

		rply:Kill()
		DROUGHT.Detrimental = nil

		PrintMessageColor(nil, Color(255, 0, 0), 'You didn\'t pick up the detrimental item soon enough, so I slaughtered one of your teammates!')
	end

end)