GM.Name    = "Benefit of Drought"
GM.Author  = "N/A"
GM.Email   = "N/A"
GM.Website = "N/A"

team.SetUp(1, "Survivors", Color(0, 120, 255), false)
team.SetUp(400, "Spectators", Color(120, 120, 120), false)

if SERVER then
	AddCSLuaFile("drought/core.lua")
end
include("drought/core.lua")

GM.ItemRarities = {
	{
		name = "Common",
		color = Color(255, 255, 255)
	},
	{
		name = "Uncommon",
		color = Color(0, 255, 0)
	},
	{
		name = "Rare",
		color = Color(0, 190, 255)
	},
	{
		name = "Epic",
		color = Color(250, 150, 0)
	},
	{
		name = "Detrimental",
		color = Color(255, 50, 0)
	},
	[1000] = {
		name = 'Unique',
		color = Color(110, 0, 200)
	}
}

if SERVER then
	util.AddNetworkString('PrintMessageColor')

	local PlayerMeta = FindMetaTable('Player')

	function PrintMessageColor(to, ...)
		if to == nil then
			to = player.GetHumans()
		end
		local args = { ... }
		net.Start('PrintMessageColor')
			net.WriteTable(args)
		net.Send(to)
	end

	function PlayerMeta:PrintMessageColor(...)
		PrintMessageColor({self}, ...)
	end
else
	net.Receive('PrintMessageColor', function(len)
		chat.AddText(unpack(net.ReadTable()))
	end)
end

--[[
Entity [176][prop_physics]      176     models/maxofs2d/companion_doll.mdl      1       -0.251 127.751 -0.410
Entity [177][prop_physics]      177     models/props_c17/furnituretable003a.mdl 1       0.309 -83.763 -0.056
Entity [178][prop_physics]      178     models/props_c17/furniturecouch002a.mdl 1       0.111 -173.488 -0.000
Entity [186][prop_physics]      186     models/props_c17/furniturecouch001a.mdl 1       -0.003 -90.076 -0.016

the ones i placed
-- Entity [138][prop_physics]      138     models/gibs/antlion_gib_large_2.mdl     1.2		 -8.684 63.509 1.307
-- Entity [189][prop_physics]      189     models/props_c17/statue_horse.mdl       0.1        -0.347 -171.515 -0.407
-- Entity [200][prop_physics]      200     models/props_combine/breenbust.mdl      1       -0.041 50.521 -0.079
-- Entity [201][prop_physics]      201     models/props_interiors/pot01a.mdl       1       0.299 12.381 0.144
-- Entity [202][prop_physics]      202     models/props_combine/breenglobe.mdl     1.3 	-0.054 13.344 0.632
-- Entity [203][prop_physics]      203     models/props_lab/huladoll.mdl   		4       1.111 19.878 -0.019
-- Entity [204][prop_physics]      204     models/props_junk/watermelon01.mdl      1.3 	-6.094 80.588 -14.893
Entity [205][prop_physics]      205     models/props_junk/plasticbucket001a.mdl 1       0.341 117.024 0.796
-- Entity [206][prop_physics]      206     models/props_c17/doll01.mdl     		2       0.000 -106.669 0.000
Entity [207][prop_physics]      207     models/props_lab/cactus.mdl     		2       -0.000 176.490 0.000
-- Entity [208][prop_physics]      208     models/props_junk/meathook001a.mdl      1       -1.208 16.973 -6.681	



? models/props_wasteland/cranemagnet01a.mdl

Shadow Ornament -- models/props_trainstation/trainstation_ornament002.mdl
Mysterious Washer -- models/props_wasteland/laundry_dryer002.mdl
Time ??? -- models/props_combine/breenclock.mdl

-- models/props_junk/garbage_coffeemug001a.mdl

Plug (L)-- models/props_lab/tpplug.mdl
]]
GM.ItemDefs = {}

/*

"Airboat.FireGunRevDown"
{
	"channel"		"CHAN_STATIC"
	"volume"		"VOL_NORM"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_GUNFIRE"

	"rndwave"
	{
		"wave"			"weapons/airboat/airboat_gun_lastshot1.wav"
		"wave"			"weapons/airboat/airboat_gun_lastshot2.wav"
	}
}

*/

sound.Add({
	name    = 'DeathBeam',
	channel = CHAN_STATIC,
	volume  = 1,
	level   = 160,
	pitch   = {160, 180},
	sound   = {
		"weapons/airboat/airboat_gun_lastshot1.wav"
	}
})

