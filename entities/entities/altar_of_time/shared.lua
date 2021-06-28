ENT.Name = "Altar Of Time"

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Purpose = "pepebigwhat"

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "IsUsed")
end