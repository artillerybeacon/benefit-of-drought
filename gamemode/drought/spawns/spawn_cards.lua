
local Weights = {

	Basic = 10,
	Miniboss = 5,
	Boss = 2

}

local SpawnCards = {

	["npc_headcrab"] = {
		cost = 8,
		reward = 2,
		t = 'Basic',
		stats = {
			base_hp = 25,
			base_dmg = 12,
			hp_lvl = 6,
			hp_dmg = 2
		}
	},

	['npc_cscanner'] = {
		cost = 8,
		reward = 2,
		t = 'Basic',
		spawn = function(ent)
			ent:Activate()
			ent:Fire('AddOutput', 'OnPhotographPlayer drought_lua:RunPassedCode:hook.Run(\'WispAcquireTarget\'):0:-1')
		end,
		stats = {
			base_hp = 25,
			base_dmg = 4,
			hp_lvl = 5,
			hp_dmg = 1
		}
	},

	["npc_zombie"] = {
		cost = 15,
		reward = 4,
		t = 'Basic',
		stats = {
			base_hp = 75,
			base_dmg = 15,
			hp_lvl = 13,
			hp_dmg = 3
		}
	},

	["npc_antlion"] = {
		cost = 65,
		reward = 16,
		t = 'Miniboss',
		
		stats = {
			base_hp = 125,
			base_dmg = 23,
			hp_lvl = 20,
			hp_dmg = 5
		}
	},

	["npc_antlionguard"] = {
		cost = 500,
		reward = 50,
		t = 'Boss',

		stats = {
			base_hp = 700,
			base_dmg = 50,
			hp_lvl = 60,
			hp_dmg = 10
		}
	},

}

return Weights, SpawnCards