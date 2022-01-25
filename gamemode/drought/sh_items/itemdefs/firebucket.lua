local item = {
	name = "Portable Gas Can",
	rarity = 2,
	desc = "Chance to ignite players on attack.",
	mdl = "models/props_junk/plasticbucket001a.mdl",
	getEffect = function(stack)
		return math.ceil(15 + (stack - 1 == 0 and 0 or math.log(stack / 6 + 1)) * 15)
	end,
	mdlScale = 1,
	obtainable = true,
}

hook.Add('DealWithOnHitProcs', 'firebucket', function(atk, target, dmg)
	if atk.Inventory and atk.Inventory.firebucket then
		local chance = item.getEffect(atk.Inventory.firebucket) / 100
		if math.random() < chance then
			target:Ignite(5)
			target.LastHit = atk
		end
	end
end)

return item