ENT.Name = "Missile"

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Purpose = "kaboom"

function ENT:SetupDataTables()

	self:NetworkVar('Entity', 0, 'ProcOwner')
	self:NetworkVar('Int', 0, 'Damage')

end