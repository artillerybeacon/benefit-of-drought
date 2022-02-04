local L = Log("drought:wisp")
SetLoggingMode("drought:wisp", DROUGHT.Debug)

local function SetupWisp()
	local lua = ents.Create('lua_run')
	lua:SetName('drought_lua')
	lua:Spawn()
	L('Wisp->CScanner override active... ', lua)
end

hook.Add("WispAcquireTarget", 'wisp', function()
	L('Wisp attacked someone: ', ACTIVATOR, CALLER)

	// Eventually I'll add a bullet shot thing in here, make them actual shotguns.
	// I also need to move this into it's own LUA file.
	ACTIVATOR:TakeDamage(10, CALLER)
end)

hook.Add('InitPostEntity', 'wisp', SetupWisp)
hook.Add('PostCleanupMap', 'wisp', SetupWisp)