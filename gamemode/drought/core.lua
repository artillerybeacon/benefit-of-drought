
DROUGHT = DROUGHT or {}

DROUGHT.StartTime = SysTime()

DROUGHT.Debug = true

if SERVER then
	--
	AddCSLuaFile("logging.lua")
	include("logging.lua")

	-- sv
	include("sv_spawns.lua")	
	--include('sv_items/items.lua')
	include("sv_itemeffects.lua")
	include("sv_interactables.lua")
	include("sv_mvcalc.lua")

	-- sh
	AddCSLuaFile("sh_items/items.lua")
	include("sh_items/items.lua")
	AddCSLuaFile("sh_ping.lua")
	include("sh_ping.lua")
	AddCSLuaFile("sh_readyup.lua")
	include("sh_readyup.lua")
	AddCSLuaFile("sh_classes.lua")
	include("sh_classes.lua")
	AddCSLuaFile("sh_hitmarker.lua")
	include("sh_hitmarker.lua")
	AddCSLuaFile("sh_elite.lua")
	include("sh_elite.lua")


	-- cl
	AddCSLuaFile("cl_itemhud.lua")
	AddCSLuaFile("cl_realhud.lua")
	AddCSLuaFile("cl_thirdperson.lua")
else
	--
	include("logging.lua")

	-- sh
	include("sh_items/items.lua")
	include("sh_ping.lua")
	include("sh_readyup.lua")
	include("sh_classes.lua")
	include("sh_hitmarker.lua")
	include("sh_elite.lua")

	-- cl
	include("cl_itemhud.lua") 
	include("cl_realhud.lua")
	include("cl_thirdperson.lua")
end

function DROUGHT.GameStarted()
	return GetGlobalBool("drought_game_is_started", false)
end 

print("Loaded all gamemode functions.")