-- shamelessly ripped off of risk of rain
local L = Log("drought:director")

SetLoggingMode("drought:director", DROUGHT.Debug)

DROUGHT.DirectorCredits = 0
DROUGHT.DirectorLastCredit = SysTime()
DROUGHT.DirectorLastSpawn = SysTime()

local Weights = {

	Basic = 10,
	Miniboss = 5,
	Boss = 2

}

local SpawnCards = {

	["npc_headcrab"] = {
		cost = 5,
		reward = 2,
		t = 'Basic'
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
	}

}

local TotalWeights = {}

local MaxHorde = 5

local TotalCost = {}

// Initialize total cost, total total weights
local TotalWeightsFull

for k,v in pairs(SpawnCards) do
	if not TotalWeights[v.t] then
		TotalWeights[v.t] = Weights[v.t]
	else
		TotalWeights[v.t] = TotalWeights[v.t] + Weights[v.t]
	end

	TotalWeightsFull = (TotalWeightsFull or 0) + Weights[v.t]
end

//
for k,v in pairs(SpawnCards) do
	if not TotalCost[v.t] then
		TotalCost[v.t] = v.cost
	else
		TotalCost[v.t] = TotalCost[v.t] + v.cost
	end
end

//
for k,v in pairs(SpawnCards) do
	SpawnCards[k].Shares = 1 / ((v.cost / TotalCost[v.t]) * (Weights[v.t] / TotalWeightsFull))
end

PrintTable(SpawnCards)

PrintTable(TotalWeights)

PrintTable(TotalCost)

//
game.CleanUpMap()

// copied from pluto inventory
local function roll(crate)
	local m = math.random()

	local total = 0
	for _, v in pairs(crate) do
		total = total + (istable(v) and v.Shares or v)
	end

	m = m * total

	for itemname, val in pairs(crate) do
		if (istable(val)) then
			m = m - val.Shares
		else
			m = m - val
		end

		if (m <= 0) then
			return itemname, val
		end
	end
end

DROUGHT.RollChance = roll

local spawn_chance = 2.5
local spawn_duration_min = 8
local spawn_duration_max = 25
local next_spawn = math.Remap(0.5, 0, 1, spawn_duration_min, spawn_duration_max)

function DROUGHT:GetEnemyAffordableCards(category)

	category = category or 'Basic'

	local affordable = {}
	for k,v in pairs(SpawnCards) do

		local too_cheap = false

		// TODO: too cheap
		if false then
			too_cheap = true
		end

		if self.DirectorCredits >= v.cost and v.t == category and not too_cheap then
			affordable[k] = v
		end

	end

	return affordable

end

local playercache = 0
local minute = 60

local diffs = {

	Easy = {
		end_at = 0,
		mult = 0
	},
	Medium = {
		end_at = minute * 5,
		mult = 0.2
	},
	Impossible = {
		end_at = 1e9,
		mult = 3
	}

}

local hordeCount = {
	{ Shares = 100 },
	{ Shares = 50 },
	{ Shares = 30 },
	{ Shares = 15 },
	{ Shares = 5  }
}

DROUGHT.CurrentDifficulty = nil

function DROUGHT:GetDifficultyCoefficient(dur)

	local baseScale = (dur / (minute * 2.5))

	local plyDiffScale = (1 + 0.3 * (playercache - 1)) // 30% per player
	
	local timeDiffScale = 1
	local lastDiff 
	for k,v in pairs(diffs) do
		if dur >= v.end_at then
			timeDiffScale = 1 + v.mult
			lastDiff = k
			continue
		else
			if not DROUGHT.CurrentDifficulty then
				DROUGHT.CurrentDifficulty = lastDiff
			else
				if DROUGHT.CurrentDifficulty != lastDiff then
					PrintMessage(3, 'New Difficulty: ' .. lastDiff)
					DROUGHT.CurrentDifficulty = lastDiff
				end
			end
			break
		end 
	end

	return baseScale
		   * plyDiffScale
		   * timeDiffScale

end

function DROUGHT:GetValidPlayerChoices()

	local plys = player.GetAll()
	local ret = {}
	for i = 1, #plys do
		local v = plys[i]
		if IsValid(v) and v:Alive() then
			ret[#ret + 1] = v
		end
	end

	return ret

end

function DROUGHT:GetRandomSpawnPos(ply)

	local vrand = ply:GetPos() + Vector(
		math.random(-400, 400),
		math.random(-400, 400),
		0
	)

	// Find random navmesh if the position is outside the world.
	if not util.IsInWorld(vrand) then
		local area = navmesh.GetNearestNavArea(vrand, false, 6000, false)
		if not IsValid(area) then
			return Vector(0, 0, 0)
		end

		// TODO: Get random area within the nav area.
		// print(area:GetRandomPoint())
		vrand = area:GetCenter()
	end

	// Ensure the position is always on the ground.
	local tr = util.TraceLine( {
		start = vrand,
		endpos = vrand - Vector(0, 0, 10000),
		filter = function( ent ) return ent == game.GetWorld() end
	} )

	// Return result of the trace, a position on the ground
	return tr.HitPos

end

function DROUGHT:SpawnEnemy(duration)

	/*

	Whenever a Director picks a spawn card, it does not do so completely randomly
	it takes into account the computed weight of the element. The computed weight of the element depends on two things :

	The relative weight of the category
	(equal to the weight of the category, divided by the sum of the weights of all categories)
	The relative weight of the card
	(equal to the weight of the element,
	divided by the sum of the weights of all elements that can spawn on this map and within that category)

	The final chance to be picked is equal to the product of these ratios.
	*/
	local category = (roll(TotalWeights))
	local cards = self:GetEnemyAffordableCards(category)
	
	if next(cards) == nil then

		L'cant afford shit'
		return false

	end

	local card = (roll(cards))
	local plys = self:GetValidPlayerChoices()
	local player_to_spawn_on = plys[math.random(1,#plys)]
	// local tier = 0 // unused
	local count = 0
	local horde = math.random(1, 5)
	local last = SysTime()


	// Elite Picker:
	// The Director then determines which Elite tier will be active.
	// The chosen Elite tier is the highest available tier the Director can afford
	// (as in, the value of the corresponding Elite monster is less than or equal to the Director's current credits).
	// Once the tier has been chosen, a random affix is then picked from its tier (unless the chosen tier is 0).
	// All Elites from the wave will use this tier and affix.
	local eliteAffix, eliteTier, spawnCost = DROUGHT:ChoseEliteAffix(card, SpawnCards)

	local function cancelSpawn(reason)
		timer.Remove('DirectorSpawn')
		L('Unable to spawn more ', card, ' because of ', reason , '. (', count,' / ', horde,') Cancelling spawn.')
	end

	timer.Create('DirectorSpawn', 0.25, horde, function()

		local canAfford = self.DirectorCredits >= spawnCost
		print(self.DirectorCredits, spawnCost)
		if not canAfford then
			return cancelSpawn('budget cuts')
		end

		local aliveEnemies = ents.FindByClass('npc_*')
		if #aliveEnemies >= 40 then
			--PrintTable(aliveEnemies)
			--for k,v in pairs(aliveEnemies) do
			--	print(v:GetPos(), util.IsInWorld(v))
			--end
			return cancelSpawn('too many enemies')
		end

		count = count + 1
		L('Spawning ', card, '. (', count,' / ', horde,')')
		L("Elites: ", eliteAffix, ", ", eliteTier)

		local pos = self:GetRandomSpawnPos(player_to_spawn_on)
		local e = ents.Create(card)
		e:SetPos(pos)
		e:Spawn()
		e:SetNWInt('reward', SpawnCards[card].reward)
		e:SetNWString('affix', eliteAffix)
		e:SetKeyValue('spawnflags', SF_NPC_FADE_CORPSE)

		self:HandleEliteAffix(e, eliteAffix, eliteTier)

		net.Start("drought_combat_beam")
			net.WriteVector(pos + Vector(0, 0, 100) + VectorRand() * 20)
			net.WriteVector(e:GetPos() + Vector(0, 0, e:OBBMaxs().z))
			net.WriteUInt(2, 4)
		net.SendPVS(pos)

		self.DirectorCredits = self.DirectorCredits - spawnCost

	end)
end

hook.Add("Think", "drought_director_think", function()
	if not DROUGHT.GameStarted() then return end
	
	local duration = SysTime() - DROUGHT.StartTime
	if SysTime() > DROUGHT.DirectorLastCredit + 1 then

		playercache = #player.GetAll()

		DROUGHT.DirectorLastCredit = SysTime()
		DROUGHT.DirectorCredits = DROUGHT.DirectorCredits + math.max(1, math.Round(math.random() * DROUGHT:GetDifficultyCoefficient(duration)))
		spawn_chance = math.max(1.1, 2.5 - DROUGHT:GetDifficultyCoefficient(duration) / (10/3)) // every 3 1/3 minutes increased chance for enemies to spawn
		
	end

	if SysTime() > DROUGHT.DirectorLastSpawn + next_spawn then

		if math.random() > 1 / spawn_chance then return end
		DROUGHT:SpawnEnemy(duration)
		DROUGHT.DirectorLastSpawn = SysTime()
		next_spawn = math.Remap(
			math.random(),
			0,
			1,
			spawn_duration_min,
			math.max(spawn_duration_min, spawn_duration_max - (duration * (DROUGHT:GetDifficultyCoefficient(duration) / 20))) // every 10 minutes spawn speed increases to max of 6 seconds per interval 
		)

	end

end)
