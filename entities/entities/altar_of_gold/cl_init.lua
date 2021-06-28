include("shared.lua")

local color_gold = Color(255, 186, 0)

function ENT:Draw()
	render.SetLightingMode(2)
	
	self:DrawModel()
	
	render.SetLightingMode(0)
end

hook.Add("HUDPaint", "drought_draw_galtar", function()
	local trc = LocalPlayer():GetEyeTrace()

	if trc.Entity:GetClass() == "altar_of_gold" and trc.Fraction < 0.0042 then

		local ent = trc.Entity

		outline.Add(ent, color_gold, OUTLINE_MODE_VISIBLE)

		cam.Start2D()
			surface.SetFont("drought_loot_crate_text")
			surface.SetTextColor(color_gold:Unpack())

			local pos2d = (ent:GetPos() + Vector(0, 0, ent:OBBCenter().z)):ToScreen()
			do
				local txt = "Altar of Gold"
				local tw, th = surface.GetTextSize(txt)

				surface.SetTextPos(pos2d.x - tw / 2, pos2d.y)
				surface.DrawText(txt)
			end
			do
				local txt = "I wonder where this goes to..."
				local tw, th = surface.GetTextSize(txt)

				surface.SetTextPos(pos2d.x - tw / 2, pos2d.y + th)
				surface.DrawText(txt)
			end
			do
				local txt = "Cost: $" .. string.Comma(tostring(ent:GetCost() or 35)) 
				local tw, th = surface.GetTextSize(txt)

				surface.SetTextPos(pos2d.x - tw / 2, pos2d.y + th * 2)
				surface.DrawText(txt)
			end
		cam.End2D()
	end
end)