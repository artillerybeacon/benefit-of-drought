local function clinclude(...)
	AddCSLuaFile(...)
	if CLIENT then
		include(...)
	end
end

if SERVER then
	util.AddNetworkString('drought_network_affix')
end

clinclude('cl_affix_render.lua')
