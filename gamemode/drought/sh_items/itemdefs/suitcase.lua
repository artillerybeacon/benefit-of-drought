local item = {
	name = "Suitcase",
	rarity = 2,
	desc = "Rebound 5% of your damage to attackers.",
	mdl = "models/props_c17/BriefCase001a.mdl",
	icon = "materials/item_briefcase.png",
	getEffect = function(stack)
		return 0.05 * stack
	end,
	obtainable = true,
}

// TODO: Do Item Effect

return item