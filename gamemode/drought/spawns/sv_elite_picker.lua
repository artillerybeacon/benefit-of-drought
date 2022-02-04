local EliteCards = include('elite_cards.lua')
PrintTable(EliteCards)

return function(card, Credits, SpawnCards)

	local eliteAffix, eliteTier
	
	local force = false

	local spawnCost = SpawnCards[card].cost

	if not force then
		for i = 1, #EliteCards do
			local elite_type = EliteCards[i]
			local elite_cost = elite_type.CostMult * SpawnCards[card].cost
			if elite_cost > Credits then
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