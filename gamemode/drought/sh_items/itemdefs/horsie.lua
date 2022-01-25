local item = {
	name = "Stallion",
	rarity = 2,
	desc = "Gives you extra jump height.",
	mdl = "models/props_c17/statue_horse.mdl",
	getEffect = function(stack)
		return 15 * stack
	end,
	obtainable = true,
	mdlScale = 0.25
}

hook.Add('CalculateMovementVars', 'horsie', function(ply, newSpeed, newJump)

	if ply.Inventory and ply.Inventory['horsie'] then
		newJump = newJump + item.getEffect(ply.Inventory['horsie'])
	end

	return newSpeed, newJump

end)

return item