local L = Log("drought:pings")

SetLoggingMode("drought:pings", DROUGHT.Debug)

if SERVER then

	util.AddNetworkString("drought_ping")

	net.Receive("drought_ping", function(len, ply)
		local hitpos = net.ReadVector()
		local traceent = net.ReadEntity()

		if not GetGlobalBool("drought_game_is_started", false) then return end

		net.Start("drought_ping")
			net.WriteVector(hitpos)
			net.WriteEntity(ply)
			net.WriteEntity(traceent)
		net.Send(player.GetHumans())
	end)

else

	surface.CreateFont("drought_ping_text", {
		font = "Arial",
		size = 24,
		weight = 300,
		outline = false,
		antialias=true
	})


	local color_cache = {}

	local function colorcache(r,g,b,a)
		r = r or 0
		g = g or 0
		b = b or 0
		a = a or 255

		if not color_cache[r] then color_cache[r] = {} end
		if not color_cache[r][g] then color_cache[r][g] = {} end
		if not color_cache[r][g][b] then color_cache[r][g][b] = {} end

		if not color_cache[r][g][b][a] then
			color_cache[r][g][b][a] = Color(r,g,b,a)
		end

		return color_cache[r][g][b][a]
	end

	local cc = colorcache(0, 200, 255)

	DROUGHT.LastPing = SysTime()

	DROUGHT.PingDuration = 2

	DROUGHT.PingScreenDuration = 15

	DROUGHT.Pings = {}

	local names = {
		npc_zombie = 'Zombie',
		npc_antlion = 'Antlion',
		npc_headcrab = 'Headcrab'
	}

	net.Receive("drought_ping", function()
		local pos = net.ReadVector()
		local ply = net.ReadEntity()
		local hit = net.ReadEntity()

		table.insert(DROUGHT.Pings, {pos = pos, ply = ply, hit = hit, start = SysTime()})

		-- if game.GetWorld() == hit then return end

		if hit:GetClass() == "loot_crate" then
			chat.AddText(cc, " < ", ply:Name(), " has found: Loot Crate ($" .. hit:GetCost() .. ") > ")
		elseif hit:GetClass() == "altar_of_gold" then
			chat.AddText(cc, " < ", ply:Name(), " has found: Altar of Gold ($" .. hit:GetCost() .. ") > ")
		else
			local n
			if game.GetWorld() == hit then
				n = ' has indicated something.'
			else
				n = ' has found: ' .. names[hit:GetClass()]
			end
			chat.AddText(cc, " < ", ply:Name(), n, " > ")
		end
	end)
	
	local circles = {}


	hook.Add("HUDPaint", "drought_ping", function()
		for i = 1, #DROUGHT.Pings do
			local ping = DROUGHT.Pings[i]

			if not ping then continue end

			if SysTime() > ping.start + DROUGHT.PingScreenDuration then
				table.remove(DROUGHT.Pings, i)
				continue
			end
			
			local pos

			if game.GetWorld() != ping.hit and not IsValid(ping.hit) then
				continue
			else
				if game.GetWorld() == ping.hit then
					pos = ping.pos:ToScreen()
				else
					pos = (ping.hit:GetPos() + Vector(0, 0, ping.hit:OBBCenter().z)):ToScreen()
				end
			end


			local ent = ping.ply

			surface.SetTextColor(cc:Unpack())
			surface.SetFont("drought_ping_text")

			local txt = ent:Name()
			local tw, th = surface.GetTextSize(txt)
			surface.SetTextPos(pos.x - tw / 2, pos.y - th / 2)
			surface.DrawText(txt)

			if not circles[i] then
				circles[i] = {
					lastAdd = SysTime() - 1,
					circles = {}
				}
			end

			if #circles[i].circles < 1 and SysTime() > circles[i].lastAdd + 1 then
				circles[i].lastAdd = SysTime()
				table.insert(circles[i].circles, 1)
			end

			for _ = 1, #circles[i].circles do
				local c = circles[i].circles[_]

				if not c then continue end

				local frac = circles[i].circles[_] / 100

				local ca = colorcache(cc.r, cc.g, cc.b, 255 - (frac * 255))
				surface.DrawCircle(pos.x, pos.y,  c, ca)
				surface.DrawCircle(pos.x, pos.y,  c + FrameTime(), ca)

				c = c + FrameTime() * 50

				circles[i].circles[_] = c

				if c >= 100 then
					table.remove(circles[i].circles, 1)
				end
			end
			--surface.DrawCircle( pos.x, pos.y, 100, cc )
		end

	end)
 
	hook.Add("Move", "drought_ping", function(ply, mv)
		if input.WasMousePressed(MOUSE_MIDDLE) and GetGlobalBool("drought_game_is_started", false) then
			if SysTime() > DROUGHT.LastPing + DROUGHT.PingDuration then
				DROUGHT.LastPing = SysTime()

				local tr = ply:GetEyeTrace()
				net.Start("drought_ping")
					net.WriteVector(tr.HitPos)
					net.WriteEntity(tr.Entity)
				net.SendToServer()
			end
		end
	end)
end

L("Ping system loaded")


