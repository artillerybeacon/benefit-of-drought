local item = {
	name = "Speedy Sneaker",
	rarity = 1,
	desc = "I am SPEED.",
	mdl = "models/props_junk/Shoe001a.mdl",
	getEffect = function(stack)
		return 20 * stack
	end,
	obtainable = true,
	mdlScale = 2,
	spawnOffset = Vector(0, 0, 10)
}

hook.Add('CalculateMovementVars', 'shoe', function(ply, newSpeed, newJump)

	if ply.Inventory and ply.Inventory['shoe'] then
		newSpeed = newSpeed + item.getEffect(ply.Inventory['shoe'])
	end

	return newSpeed, newJump

end)

return item