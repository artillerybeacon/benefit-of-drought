

DROUGHT.Detrimental = false



hook.Add('Think', 'detrimental_effect', function()
	
	if DROUGHT.Detrimental and SysTime() > DROUGHT.Detrimental + 60 then
		local plys = player.GetAll()
		local rply = plys[math.random(1, #plys)]

		rply:Kill()
		DROUGHT.Detrimental = nil
		PrintMessage(3, 'You didn\'t pick up the detrimental item soon enough, so I slaughtered one of your teammates!')
	end

end)