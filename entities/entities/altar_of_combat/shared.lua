ENT.Name = "Altar Of Combat"

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Purpose = "pepebigwhat"

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Cost")

	self:NetworkVar("Bool", 0, "IsInProgress")

	self:NetworkVar("Bool", 1, "IsDone")
	self:NetworkVar("Bool", 2, "IsDoneSpawning")
end