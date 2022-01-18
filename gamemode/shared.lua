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
	}
}

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
]]
GM.ItemDefs = {
	["register"] = {
		name = "Cash Register",
		rarity = 1,
		desc = "Grants you 1 extra cash per kill.",
		mdl = "models/props_c17/cashregister01a.mdl",
		icon = "materials/item_register.png",
		getEffect = function(stack)
			return stack
		end,
		obtainable = true,
	},
	["horsie"] = {
		name = "Stallion",
		rarity = 2,
		desc = "Gives you extra jump height.",
		mdl = "models/props_c17/statue_horse.mdl",
		getEffect = function(stack) return 15 * stack end,
		obtainable = true,
		mdlScale = 0.25
	},
	["shoe"] = {
		name = "Speedy Sneaker",
		rarity = 1,
		desc = "I am SPEED.",
		mdl = "models/props_junk/Shoe001a.mdl",
		getEffect = function(stack)
			return 20 * stack
		end,
		obtainable = true,
		mdlScale = 2,
		spawnOffset = Vector(0, 0, 10)
	},
	["breenglobe"] = {
		name = "Globe of Knowledge",
		rarity = 3,
		desc = "Gives you an extra jump.",
		mdl = "models/props_combine/breenglobe.mdl",
		icon = "materials/item_register.png",
		getEffect = function(stack)
			return stack
		end,
		obtainable = true,
		mdlScale = 1.3,
	},
	["pothead"] = {
		name = "Steaming Kettle",
		rarity = 3,
		desc = "Getting a critical hit increases your speed for 5 seconds afterwards.",
		mdl = "models/props_interiors/pot01a.mdl",
		getEffect = function(stack)
			return 5 * stack
		end,
		obtainable = true,
		mdlScale = 2,
		spawnOffset = Vector(0, 0, 10)
	},
	["suitcase"] = {
		name = "Suitcase",
		rarity = 2,
		desc = "Rebound 5% of your damage to attackers.",
		mdl = "models/props_c17/BriefCase001a.mdl",
		icon = "materials/item_briefcase.png",
		getEffect = function(stack)
			return 0.05 * stack
		end,
		obtainable = true,
	},
	["antliongib"] = {
		name = "Antlion Exoskeleton",
		rarity = 1,
		desc = "I dunno yet?",
		mdl = "models/gibs/antlion_gib_large_2.mdl",
		getEffect = function(stack) return 1 end,
		mdlScale = 1.2,
		obtainable = true,
	},
	["breenbust"] = {
		name = "Breen's Head",
		rarity = 3,
		desc = "I dunno yet?",
		mdl = "models/props_combine/breenbust.mdl",
		getEffect = function(stack) return 1 end,
		mdlScale = 1.2,
		obtainable = true,
	},
	["meathook"] = {
		name = "Not-So-Sentient Meat Hook",
		rarity = 4,
		desc = "It doesn't hurt to try.",
		mdl = "models/props_junk/meathook001a.mdl",
		getEffect = function() return 1 end,
		mdlScale = 1,
		obtainable = true,
	},
	["huladoll"] = {
		name = "Hula Girl",
		rarity = 2,
		desc = "Dance 'til your dead. +5% base damage for every 10% health taken.",
		mdl = "models/props_lab/huladoll.mdl",
		getEffect = function(stack)
			return 0.05 * stack
		end,
		mdlScale = 4,
		obtainable = true,
	},
	["debuffdoll"] = {
		name = "Baby of Built up Rage",
		rarity = 5,
		desc = "Take 50% more damage.",
		mdl = "models/props_c17/doll01.mdl",
		getEffect = function(stack)
			local initial = 50
			return initial * (1.5 ^ stack)
		end,
		mdlScale = 2,
		obtainable = false,
	},
	["firebucket"] = {
		name = "Portable Gas Can",
		rarity = 2,
		desc= "sadada",
		mdl = "models/props_junk/plasticbucket001a.mdl",
		getEffect = function() return 1 end,
		mdlScale = 1,
		obtainable = true,
	},
	["manzyfriend"] = {
		name = "Manzy's Best Friend",
		rarity = 4,
		desc = "Manzy manzy, manzy \"death\". Cheat death once.",
		mdl = "models/maxofs2d/companion_doll.mdl",
		getEffect = function() end,
		mdlScale = 1,
		obtainable = true
	},
	["debuffspine"] = {
		name = "Spine of Damnation",
		rarity = 5,
		desc = "You shall deal with your consequences. Takes health from you and your surrounding fellows.",
		mdl = "models/Gibs/HGIBS_spine.mdl",
		getEffect = function() end,
		mdlScale = 2,
		obtainable = false,
	},
	["debuffskull"] = {
		name = "Cursed Skull",
		rarity = 5,
		desc = "Fall damage is increased threefold and lethal.",
		mdl = "models/Gibs/HGIBS.mdl",
		getEffect = function() end,
		mdlScale = 2.5,
		obtainable = false
	},
	["beamgut"] = {
		name = "Cremator Beam",
		rarity = 4,
		desc = "Hitting targets has a chance to shoot a beam of pure energy.",
		mdl = "models/props_lab/crematorcase.mdl",
		getEffect = function(stack)
			local initial = 25

			return initial * stack
		end,
		mdlScale = 1,
		obtainable = true
	},
	["debuffjug"] = {
		name = "Bleach",
		rarity = 5,
		desc = "Healing is 90% less effective.",
		mdl = "models/props_junk/garbage_plasticbottle001a.mdl",
		getEffect = function() end,
		mdlScale = 1,
		obtainable = false,
	},
	["sawblade"] = {
		name = "Sawblade",
		rarity = 3,
		desc = "You have a chance to make enemies bleed.",
		mdl = "models/props_junk/sawblade001a.mdl",
		getEffect = function() end,
		mdlScale = 1,
		obtainable = true
	},
	["oilbarrel"] = {
		name = "Oil Barrel",
		rarity = 2,
		desc = "Makes your hands feel slippery, but increases your attack speed by 7% per stack.",
		mdl="models/props_c17/oildrum001.mdl",
		getEffect = function(stack)
			return .07 * stack
		end,
		mdlScale = 0.5,
		obtainable = true
	}
}

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


if SERVER then
	for k,v in pairs(GM.ItemDefs) do
		if file.Exists("materials/item_" .. k .. ".png", "GAME") then
			resource.AddSingleFile("materials/item_" .. k .. ".png")
		else
			print("No Icon:", k)
		end
	end
end