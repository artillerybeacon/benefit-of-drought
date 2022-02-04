
local Weights = {

	Basic = 10,
	Miniboss = 5,
	Boss = 2

}

local SpawnCards = {

	["npc_headcrab"] = {
		cost = 8,
		reward = 2,
		t = 'Basic'
	},

	['npc_cscanner'] = {
		cost = 8,
		reward = 2,
		t = 'Basic',
		spawn = function(ent)
			ent:Activate()
			ent:Fire('AddOutput', 'OnPhotographPlayer drought_lua:RunPassedCode:hook.Run(\'WispAcquireTarget\'):0:-1')
		end
	},

	["npc_zombie"] = {
		cost = 15,
		reward = 4,
		t = 'Basic'
	},

	["npc_antlion"] = {
		cost = 65,
		reward = 16,
		t = 'Miniboss'
	},

	["npc_antlionguard"] = {
		cost = 500,
		reward = 50,
		t = 'Boss'
	},

}

return Weights, SpawnCards