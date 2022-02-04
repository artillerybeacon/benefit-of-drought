/*

				if IsValid(self.TargetedEntity) then
					if not self.Velocity then
						self.Velocity = self:GetVelocity()
					else
						self.Velocity = LerpVector(0.4, self.Velocity, (self.TargetedEntity:GetPos() - pos):GetNormal() * self.RocketSpeed)
					end
					
					self:SetLocalVelocity(self.Velocity)
				end
				
*/

include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")


function ENT:Initialize()

	// lol
	self:SetModel("models/props_junk/wood_crate001a.mdl")

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)

end