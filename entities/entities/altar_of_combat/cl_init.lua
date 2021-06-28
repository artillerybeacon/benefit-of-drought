include("shared.lua")

local color_gray = Color(120, 120, 120)
local color_angry = Color(120, 60, 60)

function ENT:Draw()
	render.SetLightingMode(2)
		self:DrawModel()
	render.SetLightingMode(0)
end

function ENT:Think()

	if not self:GetIsDone() then return end
	
    if not self.Matrixa then
        self.Matrixa = Matrix()
        -- self.Matrixa:SetAngles(self:GetAngles())
    end

	local height = FrameTime() * (self:OBBMaxs().z / 0.45)--32 + math.sin(CurTime()) * 3
	
    self:DisableMatrix("RenderMultiply")

		--self.Matrixa:Rotate(self:GetAngles())
		self.Matrixa:Translate(Vector(0, 0, -height))

    self:EnableMatrix("RenderMultiply", self.Matrixa)

	
		--self.Matrixa:Rotate(-self:GetAngles())

	-- self.Matrixa:Translate(Vector(0, 0, -height))

end

hook.Add("HUDPaint", "drought_draw_caltar", function()
	local trc = LocalPlayer():GetEyeTrace()

	if trc.Entity:GetClass() == "altar_of_combat" and trc.Fraction < 0.0042 then

		local ent = trc.Entity

		if ent:GetIsInProgress() then
			ent:SetColor(color_angry)
			surface.SetTextColor(color_angry:Unpack())
			outline.Add(ent, color_angry, OUTLINE_MODE_VISIBLE)
		else
			ent:SetColor(color_gray)
			surface.SetTextColor(color_gray:Unpack())
			outline.Add(ent, color_gray, OUTLINE_MODE_VISIBLE)
		end


		cam.Start2D()
			surface.SetFont("drought_loot_crate_text")

			local pos2d = (ent:GetPos() + Vector(0, 0, ent:OBBCenter().z)):ToScreen()
			do
				local txt = "Altar of Combat"
				local tw, th = surface.GetTextSize(txt)

				surface.SetTextPos(pos2d.x - tw / 2, pos2d.y)
				surface.DrawText(txt)
			end
			do
				local txt = "Give yourself a challenge..."

				if trc.Entity:GetIsInProgress() then
					txt = "Kill all the enemies!"
				end
				local tw, th = surface.GetTextSize(txt)

				surface.SetTextPos(pos2d.x - tw / 2, pos2d.y + th)
				surface.DrawText(txt)
			end
		cam.End2D()
	end
end)

net.Receive("drought_caltar_notif", function()
	local activator = net.ReadEntity()

	chat.AddText(
		team.GetColor(1),
		activator:Name(),
		" ",
		color_white,
		"has activated an ",
		color_gray,
		"Altar of Combat",
		color_white
	)
end)

net.Receive("drought_combat_beam", function()
	local vPoint = net.ReadVector()
	local vOrigin = net.ReadVector()
		local effectdata = EffectData()
		effectdata:SetStart(vOrigin)
		effectdata:SetOrigin( vPoint )
		util.Effect( "drought_test", effectdata )
end)