include("shared.lua")

local color_green = Color(0, 255, 0)

surface.CreateFont("drought_loot_crate_text", {
	font = "BudgetLabel",
	size = 24,
	weight = 1000,
	outline = true
})

function ENT:Draw()
	self:DrawModel()
	self.LastPos = self:GetPos()
end

hook.Add("HUDPaint", "drought_drawcosttext", function()
	local trc = LocalPlayer():GetEyeTrace()

	if trc.Entity:GetClass() == "loot_crate" and trc.Fraction < 0.0042 and LocalPlayer():Team() == 1 then

		local ent = trc.Entity
		local isbig = ent:GetModel() == "models/props_junk/wood_crate002a.mdl"
		local our_color = isbig and color_green or color_white

		outline.Add(ent, our_color, OUTLINE_MODE_VISIBLE)

		cam.Start2D()
			surface.SetFont("drought_loot_crate_text")
			surface.SetTextColor(our_color:Unpack())

			local pos2d = (ent:GetPos() + Vector(0, 0, ent:OBBCenter().z)):ToScreen()
			do
				local txt = (isbig and "Large " or "") .. "Loot Crate"
				local tw, th = surface.GetTextSize(txt)

				surface.SetTextPos(pos2d.x - tw / 2, pos2d.y)
				surface.DrawText(txt)
			end
			do
				local txt = "Cost: $" .. string.Comma(tostring(ent:GetCost() or 35)) 
				local tw, th = surface.GetTextSize(txt)

				surface.SetTextPos(pos2d.x - tw / 2, pos2d.y + th)
				surface.DrawText(txt)
			end
		cam.End2D()
	end
end)

function ENT:OnRemove()
	local lp = self.LastPos
	timer.Simple( 0, function()
		if not IsValid( self ) then
			local effectdata = EffectData()
			effectdata:SetOrigin( lp or Vector(0, 0, -12301) )
			util.Effect( "HelicopterMegaBomb", effectdata )

		end
	end)
end