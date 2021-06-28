ENT.Name = "Altar Of Gold"

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Purpose = "pepebigwhat"

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Cost")
end