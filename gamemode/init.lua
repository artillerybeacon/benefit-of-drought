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


GM.DeathMessages = {
	"lol %s got rekt",
	"%s died a horrible death.",
	"%s got mauled",
	"%s ceased to exist",
	"We won't forget you, %s",
	"%s walked off a cliff",
	"%s got pelted by their favorite enemy",
	"%s learned the hard way",
	"%s had a skill issue",
	"You weren't needed anyway, %s",
	"%s went back home",
}

function GM:PostPlayerDeath(vic, inf, atk)

	local msg = self.DeathMessages[math.random(1, #self.DeathMessages)]
	PrintMessageColor(nil, Color(255, 52, 52), "!!! ", string.format(msg, vic:Name()), " !!!")

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

			-- PrintMessage(3, ply:Name() .. " was saved by their Manzy's Best Friend.")
			PrintMessageColor(nil, Color(52, 255, 154), ply:Name(), " was saved by their ", self.ItemRarities[4].color, "Manzy's Best Friend", Color(52, 255, 154), "!")
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

-- this doesnt work at all and im too lazy to remove it
function GM:CreateEntityRagdoll( owner, ragdoll )
	SafeRemoveEntityDelayed( ragdoll, 8 )
end

concommand.Add('m', function(p)

	local e = ents.Create'proc_missile'
	e:SetPos(p:GetPos() + Vector(0, 0, 100))
	e:Spawn()
	e:SetProcOwner(p)
	e:SetDamage(10)

end)