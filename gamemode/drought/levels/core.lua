local function shinclude(...)
	AddCSLuaFile(...)
	include(...)
end

local function clinclude(...)
	AddCSLuaFile(...)
	if CLIENT then
		include(...)
	end
end

local function svinclude(...)
	if SERVER then
		include(...)
	end
end

svinclude'enemylevel.lua'