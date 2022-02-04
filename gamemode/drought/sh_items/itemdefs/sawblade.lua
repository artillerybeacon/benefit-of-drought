local item = {
	name = "Sawblade",
	rarity = 3,
	desc = "You have a chance to make enemies bleed.",
	mdl = "models/props_junk/sawblade001a.mdl",
	getEffect = function(stack)
		return math.min(1, 0.1 * stack)
	end,
	mdlScale = 1,
	obtainable = true
}

local bleeds = {}

local bleed_tick = 1/2

hook.Add('DealWithOnHitProcs', 'bleed', function(atk, targ, dmg)

	if atk.Inventory and atk.Inventory.sawblade then
		local chance = item.getEffect(atk.Inventory.sawblade or 0)

		if math.random() <= chance then
			if not bleeds[targ] then
				bleeds[targ] = {
					stack = 1,
					last_tick = 0,
					bleeder = atk,
					time = SysTime() + 5
				}
			else
				local new = bleeds[targ]
				bleeds[targ] = {
					stack = new.stack + 1,
					bleeder = atk,
					time = SysTime() + 5,
					last_tick = new.last_tick
				}
			end
			targ:SetNWBool('bleeding', true)
		end
	end

end)

hook.Add('Think', 'bleed_think', function()

	for k,v in pairs(bleeds) do
		if not IsValid(k) or k:Health() < 1 then
			continue
		end

		if SysTime() > v.last_tick + bleed_tick then
			bleeds[k].last_tick = SysTime()
			k:TakeDamage(3 * (bleeds[k].stack or 1))
			continue
		end

		if SysTime() > v.time then
			bleeds[k] = nil
			k:SetNWBool('bleeding', false)
			continue
		end
	end

end)



return item