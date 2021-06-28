include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")


function ENT:Initialize()

	self:SetModel("models/props_c17/fountain_01.mdl")
	self:SetColor(Color(0, 186, 255))
	self:SetModelScale(0.7)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)

	self:SetPos(self:GetPos() - Vector(0, 0, 10))
	self:SetAngles(Angle(math.random(-10, 10), math.random(-180, 180), 0))

	self:SetUseType(SIMPLE_USE)
	
	self:DrawShadow(false)

	self:SetIsUsed(false)

end


function ENT:Use(activator)
	if (self:GetIsUsed()) then return end 

	self:SetIsUsed(true)

	util.ScreenShake(self:GetPos(), 5, 5, 1, 2000)

	self:SetColor(Color(120, 120, 120))

	
end