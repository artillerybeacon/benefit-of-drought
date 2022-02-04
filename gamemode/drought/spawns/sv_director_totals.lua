return function(Weights, SpawnCards)

	local TotalWeights, TotalCost, TotalWeightsFull, MostExpensiveForEachTier = {}, {}, 0, {}

	// Initialize total cost, total of the weights
	for k,v in pairs(SpawnCards) do
		if not TotalWeights[v.t] then
			TotalWeights[v.t] = Weights[v.t]
		else
			TotalWeights[v.t] = TotalWeights[v.t] + Weights[v.t]
		end

		TotalWeightsFull = (TotalWeightsFull or 0) + Weights[v.t]

		if not TotalCost[v.t] then
			TotalCost[v.t] = v.cost
		else
			TotalCost[v.t] = TotalCost[v.t] + v.cost
		end
	end

	for k,v in pairs(SpawnCards) do
		if not MostExpensiveForEachTier[v.t] then
			MostExpensiveForEachTier[v.t] = v.cost 
		end

		if v.cost > MostExpensiveForEachTier[v.t] then
			MostExpensiveForEachTier[v.t] = v.cost
		end

		SpawnCards[k].Shares = 1 / ((v.cost / TotalCost[v.t]) * (Weights[v.t] / TotalWeightsFull))
	end

	return TotalWeights, TotalCost, TotalWeightsFull, MostExpensiveForEachTier

end