local item = {
	name = "Oil Barrel",
	rarity = 2,
	desc = "Makes your hands feel slippery, but increases your attack speed by 7% per stack.",
	mdl="models/props_c17/oildrum001.mdl",
	getEffect = function(stack)
		return .05 * stack
	end,
	mdlScale = 0.5,
	obtainable = true
}


hook.Add('CalcASpeed', 'oilbarrel', function(ply)

	if ply.Inventory and ply.Inventory.oilbarrel then
		return math.min(0.95, item.getEffect(ply.Inventory.oilbarrel))
	end
	
end)

return item