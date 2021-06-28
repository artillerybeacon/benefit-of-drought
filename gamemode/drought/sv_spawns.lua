
local SpawnCards = {

	["npc_zombie"] = {
		cost = 8,
		hordemin = 1,
		hordemax = 8,
		reward = 4
	}
}

DROUGHT.Director = DROUGHT.Director or {}
DROUGHT.Director.SpawnCredits = 0
DROUGHT.Director.CreditMult = 0.75
DROUGHT.Director.DiffMult = 1
DROUGHT.Director.LastCredit = 0
DROUGHT.Director.LastSpawn = NULL
DROUGHT.Director.PlayerTarget = nil
 
function ge()
	return math.Remap(math.random(), 0, 1, 7123123123, 14123123123)--11, 18)
end
hook.Add("Think", "drought_director_think", function()
	if SysTime() >= DROUGHT.Director.LastCredit + 1 then
		DROUGHT.Director.LastCredit = SysTime()


		local diffCoefficient = (SysTime() - DROUGHT.StartTime) / 250 + 1

		-- print(diffCoefficient)
		local newCredits = DROUGHT.Director.SpawnCredits

		newCredits = newCredits + (DROUGHT.Director.CreditMult * (1 + 0.4 * diffCoefficient) * (#player.GetHumans() + 1) / 2)

		DROUGHT.Director.SpawnCredits = newCredits
		--print(DROUGHT.Director.SpawnCredits)
	end

	if not DROUGHT.Director.PlayerTarget then
		local ply

		local applicable = {}

		for k,v in pairs(player.GetAll()) do
			if v:Team() == 1 then
				table.insert(applicable, v)
			end
		end

		ply = applicable[math.random(1, #applicable)]

		DROUGHT.Director.PlayerTarget = ply
	end

	if DROUGHT.Director.LastSpawn == NULL then
		DROUGHT.Director.LastSpawn = SysTime()
		DROUGHT.Director.NextSpawn = ge()
	end

	if SysTime() > DROUGHT.Director.LastSpawn + DROUGHT.Director.NextSpawn then
		DROUGHT.Director.LastSpawn = SysTime()
		DROUGHT.Director.NextSpawn = ge()--11, 18)
		
		if DROUGHT.Director.PlayerTarget then
			local ent = "npc_zombie"
			local e = ents.Create(ent)
			e:SetPos(DROUGHT.Director.PlayerTarget:GetPos() + Vector(0, 0, 3000))
			e:Spawn()

			local diffCoefficient = (SysTime() - DROUGHT.StartTime) / 250 + 1
			local rew = math.Round(SpawnCards[ent].reward * diffCoefficient, 2)
			e:SetNWFloat("reward", rew)
			print(rew)
		end

		DROUGHT.Director.PlayerTarget = nil

		PrintMessage(3, "Attempting to spawn enemies, Credits: " .. tostring(DROUGHT.Director.SpawnCredits))

	end
	--if SysTime() >

end)

-- PrintMessage(3, DROUGHT.Director:GetDifficulty()) 