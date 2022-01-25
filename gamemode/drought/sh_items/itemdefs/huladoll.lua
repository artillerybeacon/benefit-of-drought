local item = {
	name = "Hula Girl",
	rarity = 2,
	desc = "Dance 'til your dead. +5% base damage for every 10% health taken.",
	mdl = "models/props_lab/huladoll.mdl",
	getEffect = function(stack)
		return 0.05 * stack
	end,
	mdlScale = 4,
	obtainable = true,
}

return item