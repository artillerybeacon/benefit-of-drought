
local cached_trace_struct = {
	filter = game.GetWorld(),
	mins = Vector(-10, -10, -10),
	maxs = Vector(10, 10, 10)
}

hook.Add( "CalcView", "drought_thirdperson", function( ply, pos, angles, fov )
	if not ply:Alive() then return end
	if not DROUGHT.GameStarted() then return end

	cached_trace_struct.start = pos
	cached_trace_struct.endpos = pos - (angles:Forward() * 100)

	return {
		origin = util.TraceHull(cached_trace_struct).HitPos,
		angles = angles,
		fov = fov,
		drawviewer = true
	}
end )

hook.Remove("PostDrawOpaqueRenderables", "asdasd", function()
	for k,v in pairs(ents.FindByClass("npc_cscanner")) do
		render.DrawLine(v:GetPos(), v:GetPos() + v:GetForward() * 5000 - v:GetUp() * 15, Color(255, 255, 255))
	end
end)