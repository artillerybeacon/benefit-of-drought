
DROUGHT = DROUGHT or {}

DROUGHT.StartTime = SysTime()

DROUGHT.Debug = true

local function shinclude(...)
	AddCSLuaFile(...)
	include(...)
end

if SERVER then
	--
	shinclude("logging.lua")
	include("rng.lua")  -- move this into 'core'

	-- sv
	include("levels/core.lua")
	include("spawns/sv_init.lua")

	include("sv_itemeffects.lua") -- move this into sh_items to effects.lua
	include("sv_interactables.lua") -- move this into spawns 
	include("sv_mvcalc.lua") -- move this into its own folder 'core'
	include("sv_hostname.lua")

	-- sh
	AddCSLuaFile("sh_items/items.lua")
	include("sh_items/items.lua")
	
	AddCSLuaFile("sh_ping.lua") -- move this into 'core'
	include("sh_ping.lua")
	AddCSLuaFile("sh_readyup.lua") -- move this into 'core'
	include("sh_readyup.lua")
	AddCSLuaFile("sh_classes.lua") -- move this into 'core'
	include("sh_classes.lua")
	
	shinclude("affix/sh_init.lua")


	-- cl
	shinclude("hud/sh_init.lua")
else
	--
	include("logging.lua")

	-- sh
	include("sh_items/items.lua")
	include("sh_ping.lua")
	include("sh_readyup.lua")
	include("sh_classes.lua")

	include("affix/sh_init.lua")

	include("hud/sh_init.lua")
end

function DROUGHT.GameStarted()
	return GetGlobalBool("drought_game_is_started", false)
end 

print("Loaded all gamemode functions.")