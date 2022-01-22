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

local TotalWeights = {}


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

local spawn_chance = 2.5
local spawn_duration_min = 8
local spawn_duration_max = 12
local next_spawn = math.Remap(0.5, 0, 1, spawn_duration_min, spawn_duration_max)

function DROUGHT:GetEnemyAffordableCards(category)

	category = category or 'Basic'

	local affordable = {}
	for k,v in pairs(SpawnCards) do

		if self.DirectorCredits >= v.cost and v.t == category then
			affordable[k] = v
		end

	end

	return affordable

end

local playercache = 0

function DROUGHT:GetDifficultyCoefficient(dur)

	local plyDiffScale = (1 + 0.3 * playercache)
	return (dur / 60) * plyDiffScale

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
	local tier = 0 // unused
	local count = 0
	local horde = math.random(1, 5)
	local last = SysTime()

	timer.Create('DirectorSpawn', 0.25, horde, function()

		local canAfford = self.DirectorCredits >= SpawnCards[card].cost
		if not canAfford then

			timer.Remove('DirectorSpawn')
			L('Unable to spawn more ', card, '. (', count,' / ', horde,') Cancelling spawn.')
			return

		end

		count = count + 1
		L('Spawning ', card, '. (', count,' / ', horde,')')

		local pos = self:GetRandomSpawnPos(player_to_spawn_on)
		local e = ents.Create(card)
		e:SetPos(pos)
		e:Spawn()
		e:SetNWInt('reward', SpawnCards[card].reward)

		net.Start("drought_combat_beam")
			net.WriteVector(pos + Vector(0, 0, 100) + VectorRand() * 20)
			net.WriteVector(e:GetPos() + Vector(0, 0, e:OBBMaxs().z))
			net.WriteUInt(2, 4)
		net.SendPVS(pos)

		self.DirectorCredits = self.DirectorCredits - SpawnCards[card].cost

	end)
end

hook.Add("Think", "drought_director_think", function()
	if not DROUGHT.GameStarted() then return end
	
	local duration = SysTime() - DROUGHT.StartTime
	if SysTime() > DROUGHT.DirectorLastCredit + 1 then

		playercache = #player.GetAll()

		DROUGHT.DirectorLastCredit = SysTime()
		DROUGHT.DirectorCredits = DROUGHT.DirectorCredits + math.max(1, math.Round(math.random() * DROUGHT:GetDifficultyCoefficient(duration * 3)))
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
