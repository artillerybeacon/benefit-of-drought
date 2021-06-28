include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("outline.lua")
AddCSLuaFile("cl_init.lua")

SetGlobalBool("drought_game_is_started", false)

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

function GM:PlayerLoadout(ply)
	
end

function GM:PlayerSpawn(pl)
	pl:StripWeapons()
	pl:SetTeam(400)
	
end

function GM:CanPlayerSuicide(ply)
	if ply:Team() == 400 then return false end

	return true
end

function GM:PlayerDeathThink(ply)
	if not ply.DeadTime then
		ply.DeadTime = SysTime()
		ply.OldAngles = ply:EyeAngles()
		ply.OldPos = ply:GetPos()
	end

	if ply.Inventory and ply.Inventory.manzyfriend and SysTime() > ply.DeadTime + 1.5 then
		PrintMessage(3, ply:Name() .. " was saved by their Manzy's Best Friend.")
		ply:Spawn()
		
		ply.DeadTime = nil

		ply.Inventory.manzyfriend = (ply.Inventory.manzyfriend - 1 == 0) and nil or (ply.Inventory.manzyfriend - 1)

		timer.Simple(0.5, function()
			ply:SetPos(ply.OldPos)
			ply:SetEyeAngles(ply.OldAngles)
			self:SendItemChange(ply, "manzyfriend", ply.Inventory.manzyfriend)
		end)
	end

	return false
end