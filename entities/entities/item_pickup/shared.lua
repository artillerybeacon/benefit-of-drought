ENT.Name = "Item Pickup"

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Purpose = "pick this shit up"

function ENT:SetupDataTables()
	-- use ItemID for determining our model
	self:NetworkVar("String", 0, "ItemID")
	self:NetworkVar("String", 1, "SelfName")
	self:NetworkVar("Int", 0, "SelfRarity")
end
