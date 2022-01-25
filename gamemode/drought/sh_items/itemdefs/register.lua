local item = {
	name = "Cash Register",
	rarity = 1,
	desc = "Grants you 1 extra cash per kill.",
	mdl = "models/props_c17/cashregister01a.mdl",
	icon = "materials/item_register.png",
	getEffect = function(stack)
		return stack
	end,
	obtainable = true,
}

hook.Add('CalculateExtraMoney', 'register', function(atk, toGive, toGiveEveryoneElse)

	if IsValid(atk) and atk.Inventory and atk.Inventory['register'] then
		toGive = toGive + item.getEffect(atk.Inventory['register'])
	end

	return toGive, toGiveEveryoneElse

end)

return item