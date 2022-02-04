

if SERVER then
	AddCSLuaFile('cl_affix_render.lua')
	util.AddNetworkString('drought_network_affix')
end

if CLIENT then
	include('cl_affix_render.lua')
end