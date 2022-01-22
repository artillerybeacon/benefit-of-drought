
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

	--if not DROUGHT.GameStarted() then return end

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

	-- difficulty meter
	do
		if not DROUGHT.DifficultyMeterPanel or not IsValid(DROUGHT.DifficultyMeterPanel) then
			local bw = 270
			local bh = 35
			local y = 5

			local panel = vgui.Create('DPanel')
			panel:SetPos(ScrW() / 2 - bw / 2, y)
			panel:SetSize(bw, bh)
			panel:SetBackgroundColor(Color(0, 0, 0))


			// todo: get duration based on time set from global var
			local start = SysTime()

			--local dp = derma.GetControlList().DPanel
			--print(dp)

			local diffs = {
				{
					name = "Easy",
					col = Color(0, 200, 50),
					w = 1
				},
				{
					name = "Medium",
					col = Color(150, 200, 50),
					w = 1
				}
			}
			function panel:Paint(w, h)

				surface.SetDrawColor(0, 0, 0)
				surface.DrawRect(0, 0, w, h)

				local at = (60 * 5) * 4
				local dur = SysTime() - start
				local real_box_perc = bw / 2 -- the diffs will use
				local offset = 0
				for i = 1, #diffs do
					local v = diffs [i]
					local real = v.w * real_box_perc

					local sadge = 2 - bw * (dur / at) + bw / 2 + offset
					surface.SetDrawColor(v.col:Unpack())
					surface.DrawRect(sadge, 2, real - 4, bh - 4)

					offset = math.ceil(offset + real) - 5
				end
				
				// pointer
				surface.SetDrawColor(70, 70, 70)
				surface.DrawRect(w / 2 - 1, 0, 2, h)
			end

			DROUGHT.DifficultyMeterPanel = panel
		end
	end
end)

if DROUGHT.DifficultyMeterPanel then
	DROUGHT.DifficultyMeterPanel:Remove()
end