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

hook.Add('DealWithOnHitProcs', 'bleed', function(atk, targ, dmg)

	if targ.Inventory and targ.Inventory.suitcase then
		local percentage = item.getEffect(targ.Inventory.suitcase)
		local rebound = dmg:GetDamage() * percentage

		atk.LastHit = targ
		atk:TakeDamage(rebound)
		atk:EmitSound("weapons/pistol/pistol_fire3.wav")
		net.Start("DrawHitMarker")
		net.Send(targ)
	end

end)

return item