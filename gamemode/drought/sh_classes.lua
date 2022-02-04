local L = Log("drought:classes")

SetLoggingMode("drought:classes", DROUGHT.Debug)

if CLIENT then return end


local DefaultModel = 'models/player/kleiner.mdl'

local Classes = {

	['class_rambo'] = {
		loadout = { 'rambofists' },
		health = 125,
		default_speed = 1.1,
		model = DefaultModel
	},

	['class_gunner'] = {
		loadout = { 'dualberettas' },
		health = 95,
		default_speed = 1,
		model = DefaultModel
	}

}

DROUGHT.Classes = Classes



function GM:PlayerLoadout(ply)

	local class_str = ply:GetNWString('drought_class_str', 'class_rambo')
	local class_tbl = Classes[class_str]

	if not class_tbl then
		L("Invalid class string for ", ply, " (", class_str, ")")
		return
	end

	for k,v in pairs(class_tbl.loadout) do
		ply:Give(v)
	end

	ply:SetModel(class_tbl.model or DefaultModel)
	ply:SetHealth(class_tbl.health)
	ply:SetMaxHealth(ply:Health())

end

hook.Add('CalculateMovementVars', 'class', function(ply, newSpeed, newJump)

	local class_str = ply:GetNWString('drought_class_str', 'class_rambo')
	local class_tbl = Classes[class_str]

	if not class_tbl then
		return
	end

	if class_tbl.default_speed then
		newSpeed = newSpeed * class_tbl.default_speed
	end

	return newSpeed, newJump

end)