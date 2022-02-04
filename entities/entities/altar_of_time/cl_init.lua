include("shared.lua")

local color_teal = Color(0, 186, 255)
local color_gray = Color(120, 120, 120)

function ENT:Draw()
	render.SetLightingMode(2)

	self:DrawModel()
	
	render.SetLightingMode(0)
end

hook.Add("HUDPaint", "drought_draw_waltar", function()
	local trc = LocalPlayer():GetEyeTrace()

	if trc.Entity:GetClass() == "altar_of_time" and trc.Fraction < 0.0042 then

		local ent = trc.Entity

		if ent:GetIsUsed() then
			outline.Add(ent, color_gray, OUTLINE_MODE_VISIBLE)
		else
			outline.Add(ent, color_teal, OUTLINE_MODE_VISIBLE)
		end

		cam.Start2D()
			surface.SetFont("drought_loot_crate_text")

			local t2 = "Advance time slightly..."
			if ent:GetIsUsed() then
				surface.SetTextColor(color_gray:Unpack())
				t2 = ''
			else
				surface.SetTextColor(color_teal:Unpack())
			end

			local pos2d = (ent:GetPos() + Vector(0, 0, ent:OBBCenter().z)):ToScreen()
			do
				local txt = "Altar of Time"
				local tw, th = surface.GetTextSize(txt)

				surface.SetTextPos(pos2d.x - tw / 2, pos2d.y)
				surface.DrawText(txt)
			end
			do
				local txt = t2
				local tw, th = surface.GetTextSize(txt)

				surface.SetTextPos(pos2d.x - tw / 2, pos2d.y + th)
				surface.DrawText(txt)
			end
		cam.End2D()
	end
end)