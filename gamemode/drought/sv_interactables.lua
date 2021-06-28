local L = Log("drought:interactables")

SetLoggingMode("drought:interactables", DROUGHT.Debug)

DROUGHT.Interactable = {}

DROUGHT.Interactable.MaxRangeXY = 11000
DROUGHT.Interactable.MinRangeXY = -DROUGHT.Interactable.MaxRangeXY

DROUGHT.Interactable.MaxRangeZ = DROUGHT.Interactable.MaxRangeXY / 2
DROUGHT.Interactable.MinRangeZ = -DROUGHT.Interactable.MaxRangeZ

DROUGHT.Interactable.LootAmount = 250

DROUGHT.Interactable.LootGenerateMaxAttempts = 2500

function DROUGHT.Interactable:ChooseRandomLocation()
	return Vector(
		math.random(self.MinRangeXY, self.MaxRangeXY),
		math.random(self.MinRangeXY, self.MaxRangeXY),
		math.random(self.MinRangeZ, self.MaxRangeZ)
	)
end

function DROUGHT.Interactable:GetSpawnArray()
	-- I don't know where I want to go with this.
	
	local result = {}

	result["loot_crate"] = math.random(22, 30)

	result["altar_of_combat"] = math.random(2,6)

	if math.random(1, 50) == 1 then
		result["altar_of_gold"] = 1
	end

	return result
end

function DROUGHT.Interactable:SpawnInteractables()
	L"SpawnInteractables called"

	local minrange, maxrange = -6000, 6000

	local loots = 0
	local attempts = 0
	local used = {}

	local placed_gold_altar = false

	while loots < self.LootAmount and attempts < self.LootGenerateMaxAttempts do
		attempts = attempts + 1

		local vec = Vector(
			math.random(minrange, maxrange),
			math.random(minrange, maxrange),
			math.random(minrange / 3, maxrange / 3)
		)
		repeat
			vec = Vector(
				math.random(minrange, maxrange),
				math.random(minrange, maxrange),
				math.random(minrange, maxrange)
			)
			attempts = attempts + 1
		until util.IsInWorld(vec) or (attempts > self.LootGenerateMaxAttempts - 1)

		--print(vec)
		local area = navmesh.GetNearestNavArea(vec, false, maxrange, false)

		if not IsValid(area) then continue end
		if used[area:GetID()] then continue end

		local ent = "loot_crate"
		if math.random(1, 10) == 5 then
			ent = math.random(1, 2) == 1 and "altar_of_combat" or "altar_of_time"
		elseif math.random(1, 50) == 1 and not placed_gold_altar then
			ent = "altar_of_gold"
			placed_gold_altar = true
		end

		local crate = ents.Create(ent)
		crate:SetPos(area:GetCenter())
		crate:Spawn()

		used[area:GetID()] = true
		loots = loots + 1
		L(tostring(loots) .. " / " .. tostring(DROUGHT.Interactable.LootAmount) .. " at CNavArea[" .. area:GetID() .. "]")
	end

	L("Done creating interactables!")
	L(tostring(attempts) .. " / 2500 iterations to spawn interactables")
end

--function GM:PostCleanupMap()
--	L("game.CleanUpMap was called, respawning interactables.")
--	DROUGHT.Interactable:SpawnInteractables()
--end

-- models/props_c17/fountain_01.mdl
-- models/props_c17/gravestone_statue001a.mdl

concommand.Add("bod_admin_resetmap", function(ply)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end

	L((ply == NULL and "Console man" or tostring(ply)) ..  "forced a map cleanup")

	game.CleanUpMap()
	DROUGHT.Interactable:SpawnInteractables()
end)

L("Loaded interactable system")