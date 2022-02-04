include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("outline.lua")
AddCSLuaFile("cl_init.lua")

SetGlobalBool("drought_game_is_started", false)

resource.AddFile('resource/fonts/bombard_.ttf')
resource.AddFile('materials/ror2hud/armorbar.png')
resource.AddFile('materials/ror2hud/barback.png')
resource.AddFile('materials/ror2hud/hpbar.png')
resource.AddFile('materials/ror2hud/lowhp_indicator.png')

function GM:InitGameVars(ply)

	ply:SetNWInt("drought_money", 0)
	ply:SetNWInt("drought_shield", 0)
	ply:SetNWInt("drought_mshield", 0)
	ply:SetNWInt("drought_additional_health", 0)

end

function GM:PlayerInitialSpawn(ply)

	ply:SetModel("models/player/kleiner.mdl")
	ply:SetNoCollideWithTeammates(true)

	ply:AllowFlashlight()
	ply:SetTeam(400)

	ply:Spectate(OBS_MODE_FIXED)

	ply.Inventory = {}

	self:InitGameVars(ply)

end

function GM:PlayerSpawn(pl)

	pl:SetTeam(400)
	pl:SetupHands() -- Create the hands and call GM:PlayerSetHandsModel
	
	--if (DROUGHT.GameStarted() and not pl.Revived) then
	--	GAMEMODE:PlayerSpawnAsSpectator(pl)
	--end

end


function GM:PostPlayerDeath(vic, inf, atk)
	PrintMessage(3, "!!! " .. vic:Name() .. " died a horrible death. !!!")
end


-- Choose the model for hands according to their player model.
function GM:PlayerSetHandsModel( ply, ent )

	local simplemodel = player_manager.TranslateToPlayerModelName( ply:GetModel() )
	local info = player_manager.TranslatePlayerHands( simplemodel )
	if ( info ) then
		ent:SetModel( info.model )
		ent:SetSkin( info.skin )
		ent:SetBodyGroups( info.body )
	end

end

function GM:CanPlayerSuicide(ply)

	if ply:Team() == 400 then return false end

	return true

end

local function HasManzyFriend(ply)

	if not ply.Inventory then return false end
	if not ply.Inventory.manzyfriend then return false end

	return ply.Inventory.manzyfriend

end

function GM:PlayerDeathThink(ply)

	if not ply.DeadTime then

		ply.DeadTime = SysTime()
		ply.OldAngles = ply:EyeAngles()
		ply.OldPos = ply:GetPos()

	end

	if SysTime() > ply.DeadTime + 1.5 then

		local h = HasManzyFriend(ply)
		if h and h > 0 then

			PrintMessage(3, ply:Name() .. " was saved by their Manzy's Best Friend.")
			ply.Revived = true
			ply:Spawn()
			ply:SetTeam(1)
			ply.DeadTime = nil
			ply.Inventory.manzyfriend = h - 1
			GAMEMODE:PlayerLoadout(ply)
			GAMEMODE:RecalculateMovementVars(ply)

			if ply.Inventory.manzyfriend <= 0 then
				ply.Inventory.manzyfriend = nil
				self:SendItemChange(ply, "manzyfriend", nil)
			else
				self:SendItemChange(ply, "manzyfriend", ply.Inventory.manzyfriend)
			end

			timer.Simple(0, function()
				ply:SetPos(ply.OldPos)
				ply:SetEyeAngles(ply.OldAngles)
				ply.Revived = nil
			end)
	
		else

			GAMEMODE:PlayerSpawnAsSpectator( ply )
			ply.DeadTime = 1e9

		end

	end

	return false

end


local LastDeathCheck = 0
function GM:Think()

	if not DROUGHT.Alive then return end

	if DROUGHT.Director then DROUGHT.Director:Think() end

	if not (SysTime() > LastDeathCheck + 1) then return end
	LastDeathCheck = SysTime()

	for k,v in pairs(DROUGHT.Alive) do
		if IsValid(k) and (k:Alive() or HasManzyFriend(k)) then
			return
		end	
	end

	PrintMessage(3, 'Everyone\'s dead. Resetting map in 5 seconds.')
	LastDeathCheck = 1e9

	timer.Simple(5, function()
		game.ConsoleCommand('changelevel gm_construct\n')
	end)

	return

end