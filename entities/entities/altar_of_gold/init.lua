include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")


function ENT:Initialize()

	self:SetModel("models/props_c17/gravestone_statue001a.mdl")
	self:SetColor(Color(255, 186, 0))

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)

	self:SetPos(self:GetPos() + Vector(0, 0, 50))
	self:SetAngles(Angle(math.random(-10, 10), math.random(-180, 180), 0))

	self:SetUseType(SIMPLE_USE)

	self:SetCost(25 * 15.5)
	
	self:DrawShadow(false)

end