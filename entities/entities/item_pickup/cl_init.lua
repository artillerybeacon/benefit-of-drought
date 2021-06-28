include("shared.lua")

local singlecolor = Material("engine/singlecolor")


function ENT:Draw()
	
	local rarity = GAMEMODE.ItemRarities[self:GetSelfRarity()]
	local color = Color(0, 0, 0)
	if rarity and rarity.color then
		color = rarity.color
	end

	self:DrawModel()

	outline.Add(self, color, OUTLINE_MODE_VISIBLE)


end



function ENT:Think()

	
    if not self.Matrixa then
        self.Matrixa = Matrix()
        self.Matrixa:SetAngles(self:GetAngles())
    end

	local height = 32 + math.sin(CurTime()) * 3
	
    self:DisableMatrix("RenderMultiply")

		self.Matrixa:Rotate(Angle(0, FrameTime() * 45, 0))
		self.Matrixa:Translate(Vector(0, 0, height))

    self:EnableMatrix("RenderMultiply", self.Matrixa)

	self.Matrixa:Translate(Vector(0, 0, -height))

end