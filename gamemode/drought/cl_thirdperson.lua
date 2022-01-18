
hook.Add( "CalcView", "drought_thirdperson", function( ply, pos, angles, fov )
	if not ply:Alive() then return end
	
	/*
local tr = util.TraceHull( {
	start = self.Owner:GetShootPos(),
	endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 100 ),
	filter = self.Owner,
	mins = Vector( -10, -10, -10 ),
	maxs = Vector( 10, 10, 10 ),
	mask = MASK_SHOT_HULL
} )
*/
	local e = pos - (angles:Forward() * 100)

	local hull = util.TraceHull({
		start = pos,
		endpos = e,
		filter = ply,
		mins = Vector(-10, -10, -10),
		maxs = Vector(10, 10, 10)
	})

	e = hull.HitPos



	local f = fov
	local d = true

	local view = {
		origin = e,
		angles = angles,
		fov = f,
		drawviewer = d
	}

	return view
end )