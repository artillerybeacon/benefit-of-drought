
hook.Add( "CalcView", "drought_thirdperson", function( ply, pos, angles, fov )
	if not ply:Alive() then return end
	if not DROUGHT.GameStarted() then return end

	local e = pos - (angles:Forward() * 100)
	local hull = util.TraceHull({
		start = pos,
		endpos = e,
		filter = game.GetWorld(),
		mins = Vector(-10, -10, -10),
		maxs = Vector(10, 10, 10)
	}).HitPos

	return {
		origin = hull,
		angles = angles,
		fov = fov,
		drawviewer = true
	}
end )