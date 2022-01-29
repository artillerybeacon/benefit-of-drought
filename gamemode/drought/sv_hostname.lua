
local function seth(str)
	local new = DROUGHT.OldHostName .. ' | ' .. str

	new = string.sub(new, 1, 200)

	game.ConsoleCommand('hostname ' .. new .. "\n")

	--print(new)
end

 
if not DROUGHT.OldHostName then
	hook.Add('Initialize', 'hostname', function()
		timer.Simple(1, function()
			DROUGHT.OldHostName = GetConVar('hostname'):GetString()
			--print('Set host name... ' .. DROUGHT.OldHostName)
			hook.Remove('Initialize', 'hostname')
		end)
	end)
else
	game.ConsoleCommand('hostname ' .. DROUGHT.OldHostName .. "\n")
end




DROUGHT.LastHostnameUpdate = SysTime()

hook.Add('Think', 'hostname', function()
	if not (SysTime() > DROUGHT.LastHostnameUpdate + 10) then return end

	DROUGHT.LastHostnameUpdate = SysTime()

	if not DROUGHT.GameStarted() then
		seth('Waiting for players...')
	else
		local plyc = #player.GetAll()


		seth(tostring(plyc) .. " " .. (plyc == 1 and "player" or "players") .. ", " .. os.date("!%X", SysTime() - DROUGHT.StartTime))
	end
end)