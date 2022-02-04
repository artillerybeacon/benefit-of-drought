--[[
-- Creator: Exho
-- Purpose: Provide a free hitmarker script that has a nice level of customization
https://steamcommunity.com/sharedfiles/filedetails/?id=296385367
]]--

if SERVER then
	resource.AddFile("sound/mlghit.wav")
	util.AddNetworkString( "DrawHitMarker" )
	
	hook.Add("EntityTakeDamage","HitmarkerDetector",function( ply, dmginfo )
		local att = dmginfo:GetAttacker()
		local dmg = dmginfo:GetDamage()
		

		--print('balls')
		if (IsValid(att) and att:IsPlayer() and att ~= ply) then
		--print('balls2')
			net.Start("DrawHitMarker")
			net.Send(att)
		end
	end)
end

if CLIENT then
	-- Declare our convars and variables
	local hm_toggle = CreateClientConVar("hm_enabled", "1", true, true)	
	local hm_type = CreateClientConVar("hm_hitmarkertype", "lines", true, true)
	local hm_sound = CreateClientConVar("hm_hitsound", "1", true, true)	
	local DrawHitM = false
	local CanPlayS = true
	local alpha = 0
	
	local function GrabColor() -- Used for retrieving the console color
		return Color(255, 255, 255)
	end
	
	net.Receive( "DrawHitMarker", function( len, ply )
		DrawHitM = true
		CanPlayS = true
		alpha = 255 
	end)
	
	hook.Add("HUDPaint", "HitmarkerDrawer", function() 
		-- if hm_toggle:GetBool() == false then return end -- Enables/Disables the hitmarkers
		if alpha == 0 then DrawHitM = false CanPlayS = true end -- Removes them after they decay 
		
		if DrawHitM == true then
			if CanPlayS and hm_sound:GetBool() == true then
				surface.PlaySound("mlghit.wav")
				CanPlayS = false
			end
			
			local x = ScrW() / 2
			local y = ScrH() / 2
			
			alpha = math.Approach(alpha, 0, 5 )
			local col = GrabColor() -- Grabs HM color and draws your design
			col.a = alpha 
			surface.SetDrawColor( col )
			
			local sel = string.lower(hm_type:GetString())
			-- The drawing part of the hitmarkers and the various types you can choose
			if sel == "lines" then 
				surface.DrawLine( x - 6, y - 5, x - 11, y - 10 )
				surface.DrawLine( x + 5, y - 5, x + 10, y - 10 )
				surface.DrawLine( x - 6, y + 5, x - 11, y + 10 )
				surface.DrawLine( x + 5, y + 5, x + 10, y + 10 )
			elseif sel == "sidesqr_lines" then
				surface.DrawLine( x - 15, y, x, y + 15 )
				surface.DrawLine( x + 15, y, x, y - 15 )
				surface.DrawLine( x, y + 15, x + 15, y)
				surface.DrawLine( x, y - 15, x - 15, y)
				surface.DrawLine( x - 5, y - 5, x - 10, y - 10 )
				surface.DrawLine( x + 5, y - 5, x + 10, y - 10 )
				surface.DrawLine( x - 5, y + 5, x - 10, y + 10 )
				surface.DrawLine( x + 5, y + 5, x + 10, y + 10 )
			elseif sel == "sqr_rot" then
				surface.DrawLine( x - 15, y, x, y + 15 )
				surface.DrawLine( x + 15, y, x, y - 15 )
				surface.DrawLine( x, y + 15, x + 15, y)
				surface.DrawLine( x, y - 15, x - 15, y)
			else -- Defaults to 'lines' in case of an incorrect type
				surface.DrawLine( x - 6, y - 5, x - 11, y - 10 )
				surface.DrawLine( x + 5, y - 5, x + 10, y - 10 )
				surface.DrawLine( x - 6, y + 5, x - 11, y + 10 )
				surface.DrawLine( x + 5, y + 5, x + 10, y + 10 )
			end
		end
	end)
end

