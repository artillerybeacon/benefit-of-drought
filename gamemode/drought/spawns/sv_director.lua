-- shame(less)fully ripped off of risk of rain
local L = Log("drought:director")
SetLoggingMode("drought:director", DROUGHT.Debug)

local Weights, SpawnCards = include('spawn_cards.lua')
local Diffs = include('difficulties.lua')

-- moved total into a function to keep less space in the director file.
local TotalFunc = include('sv_director_totals.lua')
local TotalWeights, TotalCost, TotalWeightsFull, MostExpensiveForEachTier = TotalFunc(Weights, SpawnCards)

PrintTable(SpawnCards)
PrintTable(TotalWeights)
PrintTable(TotalCost)

local MaxHorde = 5
local HordeCount = { -- Using .Shares here, could optimize but need testing.
	{ Shares = 100 },
	{ Shares = 50 },
	{ Shares = 30 },
	{ Shares = 15 },
	{ Shares = 5  }
}

DROUGHT.Director = DROUGHT.Director or {}

DROUGHT.Director.Credits = 0
DROUGHT.Director.LastCredit = SysTime()
DROUGHT.Director.LastSpawn = SysTime()

DROUGHT.Director.MinSpawnChance = 1.1
DROUGHT.Director.MaxSpawnChance = 2.5
DROUGHT.Director.MinNextSpawnTime = 5
DROUGHT.Director.MaxNextSpawnTime = 25

function DROUGHT.Director:SetNextSpawn(time_frac, scale)
	scale = scale or 0

	self.NextSpawn = math.Remap(
		time_frac,
		0,
		1,
		self.MinNextSpawnTime,
		math.max(self.MaxNextSpawnTime - scale, self.MinNextSpawnTime)
	)
end

-- there is no next spawn timer, but we can init the var with this
DROUGHT.Director:SetNextSpawn(0.5)

game.CleanUpMap()

local PlayerNumCache = 0

function DROUGHT.Director:GetDifficultyCoefficient(dur)
	local base = dur / 60 -- minutes

	local pdiff = 0.3 * math.min(0, PlayerNumCache - 1) + 1

	local stagediff = 1.15 ^ (0) -- TODO: Stages

	local time = 0.0506 * (1) * (PlayerNumCache ^ 0.2) -- TODO: Get difficulty percentage increase. (parenthesis)
	
	return (pdiff + base * time) * stagediff
end

local r = math.random

function DROUGHT.Director:GetRandomPosNearPly(ply)
	local dist = r(300, 400) -- distance from ply in hammer units
	local rads = 2 * math.pi * r() -- random radian angle
	local rpos = ply:GetPos() + Vector(math.sin(rads) * dist, math.cos(rads) * dist, 0) -- new position
	-- Get a random position near the player's navmesh if it isn't in the world.
	if not util.IsInWorld(rpos) then
		local NavArea = navmesh.GetNearestNavArea(rpos, false, 6000, false)
		if not IsValid(NavArea) then
			return Vector(0, 0, 0)
		end
		rpos = NavArea:GetRandomPoint()
	end
	-- Make sure the position that we chose is always on the ground.
	return util.TraceLine({
		start = rpos,
		endpos = rpos - Vector(0, 0, 10000),
		filter = function(ent)
			return ent == game.GetWorld()
		end
	}).HitPos
end

function DROUGHT.Director:GetValidPlayerChoices()
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

function DROUGHT.Director:GetEnemyAffordableCards(category)

	category = category or 'Basic'

	local affordable = {}
	for k,v in pairs(SpawnCards) do

		if self.Credits >= v.cost and v.t == category then
			affordable[k] = v
		end

	end

	return affordable

end

local PickElite = include('sv_elite_picker.lua')
function DROUGHT.Director:AttemptSpawn()
	local rng = 1 / 2

	if r() < rng then
		L ("Spawn failed due to RNG.", ' 1 / ', rng)
		return false
	end

	local function stop(msg)
		L("Aborting spawn (", msg, ")")
		return hook.Remove('Think', 'DirectorSpawn')
	end

	local valid = self:GetValidPlayerChoices()
	local target = valid[math.random(1, #valid)]

	local category = (DROUGHT.RollChance(Weights))
	local amount = (DROUGHT.RollChance(HordeCount))
	local card = (DROUGHT.RollChance(self:GetEnemyAffordableCards(category)))

	if not card then
		return stop("Unable to afford any card.")
	end

	print("C",category,card)
	local affix, tier, cost = PickElite(card, self.Credits, SpawnCards)

	local last = SysTime()
	local count = 0

	hook.Add('Think', 'DirectorSpawn', function()
		if not (SysTime() > last + 0.25) then
			return
		end
		last = SysTime()
		
		-- Can afford the spawn.
		if not (self.Credits >= cost) then
			return stop("cant afford enemy spawn")
		end
		-- There aren't 40 or so enemies on the map.
		if (#ents.FindByClass('npc_*') >= 40) then
			return stop("too many enemies")
		end
		-- The enemy isn't too cheap TODO
		if false then
			return stop("enemy spawn is too cheap")
		end

		count = count + 1
		if count > amount then
			return stop('Successfully spawned ', count, ' enemies.')
		end

		L('Spawning ', card, '(', count, '/', amount, ')(', affix, tier, ')')
		local pos = self:GetRandomPosNearPly(target)
		local c = self:GetDifficultyCoefficient(SysTime() - DROUGHT.StartTime)
		local e = self:SpawnEnemy(card, pos, affix, tier, c, DROUGHT:GetEnemyLevel(c, PlayerNumCache))

		net.Start("drought_combat_beam")
			net.WriteVector(pos + Vector(0, 0, 100) + VectorRand() * 20)
			net.WriteVector(e:GetPos() + Vector(0, 0, e:OBBMaxs().z))
			net.WriteUInt(2, 4)
		net.SendPVS(pos)

		self.Credits = self.Credits - cost
	end)
end

local EliteCards = include('elite_cards.lua')
function DROUGHT.Director:SpawnEnemy(card, pos, affix, tier, coef, lvl)
	local SpawnStats = SpawnCards[card].stats

	local e = ents.Create(card)
	e:SetPos(pos)
	e:Spawn()
	e:SetNWInt('reward', math.ceil(SpawnCards[card].reward * 2 * coef))
	e:SetNWInt('level', lvl)
	e:SetNWString('affix', affix)

	if SpawnCards[card].spawn then
		SpawnCards[card].spawn(e)
	end

	if affix == nil or tier == nil then return e end

	print(card, pos, affix, tier, lvl, e)

	e:SetHealth(SpawnStats.base_hp + (SpawnStats.hp_lvl * lvl))
	e:SetMaxHealth(e:Health())

	timer.Simple(0, function()
		net.Start('drought_network_affix')
			net.WriteEntity(e)
			net.WriteString(affix)
		net.SendPVS(e:GetPos())

		local oldHealth, oldMhealth = e:Health(), e:GetMaxHealth()
		local mult = EliteCards[tier].HPMult
		e:SetHealth(oldHealth * mult)
		e:SetMaxHealth(oldMhealth * mult)
	end)

	return e
end


local function UnstuckEnemies()

	for k,v in pairs(ents.FindByClass('npc_*')) do
		
		if not util.IsInWorld(v:GetPos()) then
			L("Found enemy stuck: ", v, "(", v:GetPos(), ")")
			v:SetPos(DROUGHT.Director:GetNear('random'))
		end

	end

end

function DROUGHT.Director:Think()
	if not DROUGHT.GameStarted() then return end

	local Duration = SysTime() - DROUGHT.StartTime
	if SysTime() > self.LastCredit + 1 then -- the director gets 1 credit a sec.
		self.LastCredit = SysTime()

		self.Credits = self.Credits + math.max(
			1,
			math.Round(r() * self:GetDifficultyCoefficient(Duration))
		)


		--self.MaxSpawnChance = math.max(
		--	self.MinSpawnChance,
		--	2.5 - (self:GetDifficultyCoefficient(Duration) / 3.3333) -- 3 1/3 minutes, better spawn chance
		--)
		print(self.Credits)

		PlayerNumCache = #player.GetAll()
	end

	if SysTime() > self.LastSpawn + self.NextSpawn then
		self.LastSpawn = SysTime()
		self:SetNextSpawn(
			r(),
			(self:GetDifficultyCoefficient(Duration) / 20)
		)
		
		L "Enemy attempting to spawn.."
		self:AttemptSpawn()
		UnstuckEnemies()
	end
end

concommand.Add('bod_force_next_spawn', function()
	DROUGHT.Director.LastSpawn = -1e9
	DROUGHT.Director.Credits = 50000
	
end)