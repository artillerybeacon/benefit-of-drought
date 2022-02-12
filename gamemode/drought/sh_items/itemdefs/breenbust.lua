local item = {
	name = "Breen's Head",
	rarity = 3,
	desc = "Breen provided you with missiles for your cause.",
	mdl = "models/props_combine/breenbust.mdl",
	getEffect = function(stack)
		return .75 * stack
	end,
	mdlScale = 1.2,
	obtainable = true,
}


hook.Add('DealWithOnHitProcs', 'rocket', function(atk, target, dmg)
	if atk.Inventory and atk.Inventory.breenbust and dmg:GetInflictor():GetClass() != "proc_missile" then
		
		local fb = atk.Inventory.breenbust
		local chance = math.ceil(5 + (fb - 1 == 0 and 0 or math.log(fb / 6 + 1)) * 20) / 100
		print(chance)
		if math.random() < chance then
					
			local e = ents.Create'proc_missile'
			e:SetPos(atk:GetPos() + Vector(0, 0, 100))
			e:Spawn()
			e:SetProcOwner(atk)
			e:SetDamage(dmg:GetDamage() * (item.getEffect(atk.Inventory.breenbust)))
			e:SetTarget(target)

		end
	end
end)

return item