function DROUGHT:GetEnemyLevel(coeff, plyc)
	return math.floor(1 + (coeff / plyc) * 3.0303)
end