local item = {
	name = "Globe of Knowledge",
	rarity = 3,
	desc = "Gives you an extra jump.",
	mdl = "models/props_combine/breenglobe.mdl",
	icon = "materials/item_register.png",
	getEffect = function(stack)
		return stack
	end,
	obtainable = true,
	mdlScale = 1.3,
}

// TODO: Item Effect

return item