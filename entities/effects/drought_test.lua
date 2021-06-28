
local color_angry = Color(120, 60, 60)

local color_angrier = Color(120, 0, 0)
function EFFECT:Init( data )
	self.data = data
	self.particles = 3

	self.start = SysTime()
end

function EFFECT:Think()
	if SysTime() > self.start + 0.25 then
		return false
	end

	return true
end

local m = Material("cable/xbeam")
function EFFECT:Render()
	if SysTime() > self.start + 0.25 then
		return false
	end

	local vOffset = self.data:GetOrigin() + Vector( 0, 0, 0.2 )
	local vAngle = self.data:GetAngles()
	
	local emitter = ParticleEmitter( vOffset, false )
		for i=0, self.particles do
			local particle = emitter:Add( "effects/softglow", vOffset )
			if particle then
				particle:SetAngles( vAngle )
				particle:SetVelocity( Vector( 0, 0, 15 ) )
				particle:SetColor( color_angry:Unpack() )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( 0.2)
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 40 )
				particle:SetStartLength( 1 )
				particle:SetEndSize( 120 )
				particle:SetEndLength( 100 )
			end

			
			local sparticle = emitter:Add( "effects/softglow", self.data:GetStart() - Vector(0, 0, 50) )
			if sparticle then
				sparticle:SetAngles( vAngle )
				sparticle:SetVelocity( Vector( 0, 0, 15 ) )
				sparticle:SetColor( color_angrier:Unpack() )
				sparticle:SetLifeTime( 0 )
				sparticle:SetDieTime( 0.01)
				sparticle:SetStartAlpha( 255 )
				sparticle:SetEndAlpha( 255 )
				sparticle:SetStartSize( 120 )
				sparticle:SetStartLength( 100 )
				sparticle:SetEndSize( 120 )
				sparticle:SetEndLength( 100 )
			end
		end

	emitter:Finish()

	local beamStart = CurTime() * 15
	local beamEnd = beamStart - 4
	cam.Start3D()
		render.SetMaterial(m)
		for i = 1, 1 do
			render.DrawBeam(
				self.data:GetStart(),
				self.data:GetOrigin(),
				10,
				beamStart,
				beamEnd,
				color_angry
			)
		end
	cam.End3D()

end
