local item = {
	name = "Antlion Exoskeleton",
	rarity = 1,
	desc = "Reduces incoming damage.",
	mdl = "models/gibs/antlion_gib_large_2.mdl",
	getEffect = function(stack)
		return 1
	end,
	mdlScale = 1.2,
	obtainable = true,
}

return item