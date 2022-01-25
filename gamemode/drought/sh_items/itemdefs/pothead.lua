local item = {
	name = "Steaming Kettle",
	rarity = 3,
	desc = "Getting a critical hit increases your speed for 5 seconds afterwards.",
	mdl = "models/props_interiors/pot01a.mdl",
	getEffect = function(stack)
		return 5 * stack
	end,
	obtainable = true,
	mdlScale = 2,
	spawnOffset = Vector(0, 0, 10)
}

// TODO: Item Effect

return item