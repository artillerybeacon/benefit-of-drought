local item = {
	name = "Baby of Built up Rage",
	rarity = 5,
	desc = "Take 50% more damage.",
	mdl = "models/props_c17/doll01.mdl",
	getEffect = function(stack)
		local initial = 50
		return initial * (1.5 ^ stack)
	end,
	mdlScale = 2,
	obtainable = false,
}

return item