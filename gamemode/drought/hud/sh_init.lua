local function shinclude(...)
	AddCSLuaFile(...)
	include(...)
end

local function clinclude(...)
	AddCSLuaFile(...)
	if not SERVER then
		include(...)
	end
end

shinclude('sh_hitmarker.lua')
clinclude('cl_itemhud.lua')
clinclude('cl_realhud.lua')
clinclude('cl_thirdperson.lua')