local item = {
	name = "Antlion Exoskeleton",
	rarity = 1,
	desc = "Reduces incoming damage.",
	mdl = "models/gibs/antlion_gib_large_2.mdl",
	getEffect = function(stack)
		return 1
	end,
	mdlScale = 1.2,
	obtainable = true,
}



hook.Add('DealWithOnHitProcs', 'damagereduc', function(atk, targ, dmg)

	if targ.Inventory and targ.Inventory.antliongib then
		local fb = targ.Inventory.antliongib
		local reduction = math.ceil(5 + (fb - 1 == 0 and 0 or math.log(fb / 6 + 1)) * 20)
				
		local newdmg = dmg:GetDamage() / (1 + reduction / 100)
		dmg:SetDamage(newdmg)
	end

end)


/*
if atk.Inventory.antliongib then
				local fb = atk.Inventory.antliongib
				local reduction = math.ceil(5 + (fb - 1 == 0 and 0 or math.log(fb / 6 + 1)) * 20)
				
				local newdmg = dmg:GetDamage() / (1 + reduction / 100)
				dmg:SetDamage(newdmg)
			end

*/

return item