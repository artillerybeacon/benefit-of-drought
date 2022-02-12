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

local color_white = Color(255, 255, 255)
function ENT:Initialize()

	// lol
	self:SetModel("models/weapons/w_missile_launch.mdl")
	self:SetAngles(Angle(-90, 0, 0))

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	util.SpriteTrail( self, 0, color_white, false, 10, 0, 2, 1, "trails/smoke.vmt" )

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
	end


	self.Rising = true
	self.Start = SysTime() 


	-- self.OurMissile:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

end

function ENT:PhysicsUpdate(phys)
	if not self.Rising then
	-- else
		local tpos = IsValid(self:GetTarget()) and self:GetTarget():GetPos() or Vector(0, 0, 0)
		local lerp = math.Remap((SysTime() - self.Start) / 10, 0, 1, 0.15, 0.5)
		self:SetAngles(LerpAngle(lerp, self:GetAngles(), (tpos - self:GetPos()):Angle()))
	end

	phys:SetVelocity(self:GetForward() * 800)

	if self.Rising and SysTime() > self.Start + 0.5 then
		self.Rising = false
	end

	if SysTime() > self.Start + 10 then
		self:Explode()
		return false
	end
end

function ENT:Explode()
	self:Remove()

	local effectdata = EffectData()
	effectdata:SetOrigin( self:GetPos() or Vector(0, 0, -12301) )
	util.Effect( "HelicopterMegaBomb", effectdata )

	util.BlastDamage(self, self:GetProcOwner(), self:GetPos(), 100, self:GetDamage())
end

function ENT:PhysicsCollide(data, coll)
	self:Explode()
end