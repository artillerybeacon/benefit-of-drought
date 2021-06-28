ENT.Name = "Loot Crate"

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Purpose = "pick this shit up"

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "ItemToGive")
	self:NetworkVar("Int", 0, "Cost")
end