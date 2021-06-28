
local hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true
}

hook.Add("HUDShouldDraw", "HideHUD", function(name)
	if (hide[ name ]) then
		return false
	end

	-- Don't return anything here, it may break other addons that rely on this hook.
end)


local hwidth = 400
local hh = 200
local me = LocalPlayer()

local hpBarWidthLerp
local shieldBarWidthLerp--  = 0

hook.Add("HUDPaint", "DroughtHUDReal", function()
	if not IsValid(me) then
		me = LocalPlayer()
	end

	if not GetGlobalBool("drought_game_is_started", false) then return end

	do -- draw cash bar
		surface.SetDrawColor(70, 70, 70)
		surface.DrawRect(5, ScrH() - 40, 350, 35)
		
		surface.SetFont("Trebuchet24")
		local t = "Cash: $" .. string.Comma(tostring(me:GetNWInt("drought_money", 0)))
		local tw, th = surface.GetTextSize(t)
		surface.SetTextColor(255, 255, 255)
		surface.SetTextPos(350 / 2 - tw / 2 + 5, (ScrH() - 40) + (38 / 2) - (th / 2))
		surface.DrawText(t)

		surface.SetDrawColor(0, 0, 0)
		surface.DrawOutlinedRect(5, ScrH() - 40, 350, 35)
	end

	do -- draw health
		surface.SetDrawColor(0, 0, 0)
		surface.DrawOutlinedRect(5, ScrH() - 75, 350, 35)
		local health = LocalPlayer():Health()
		local maxHealth = LocalPlayer():GetMaxHealth()
		local hpfrac = health / maxHealth

		if not hpBarWidthLerp then
			hpBarWidthLerp = 0--348 * (health / maxHealth)
		else
			hpBarWidthLerp = Lerp(FrameTime() * 10, hpBarWidthLerp, 348 * hpfrac)
		end

		surface.DrawRect(5, ScrH() - 75, 350, 35)


		surface.SetDrawColor(255 * (1 - hpfrac), 255 * hpfrac, 0, 255)
		surface.DrawRect(6, ScrH() - 74, hpBarWidthLerp, 34)

		surface.SetFont("Trebuchet24")
		local t = string.Comma(tostring(health)) .. " / " .. string.Comma(tostring(maxHealth))
		local tw, th = surface.GetTextSize(t)
		surface.SetTextColor(255, 255, 255)
		surface.SetTextPos(350 / 2 - tw / 2 + 5, (ScrH() - 75) + (38 / 2) - (th / 2))
		surface.DrawText(t)
	end
end)