local item = {
	name = "Cremator Beam",
	rarity = 4,
	desc = "Hitting targets has a chance to shoot a beam of pure energy.",
	mdl = "models/props_lab/crematorcase.mdl",
	getEffect = function(stack)
		local initial = 25
		return initial * stack
	end,
	mdlScale = 1,
	obtainable = true
}

return item