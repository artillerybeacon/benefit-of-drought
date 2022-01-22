local L = Log("drought:readyup")

SetLoggingMode("drought:readyup", DROUGHT.Debug)

if SERVER then

	DROUGHT.ReadyPlayers = {}

	hook.Add("PlayerInitialSpawn", "drought_setready", function(ply)
		if DROUGHT.GameStarted() then return end

		DROUGHT.ReadyPlayers[ply] = false

		L(ply:Name() .. " has joined the server.")
	end)

	hook.Add("PlayerDisconnected", "drought_readyup_removeply", function(ply)
		DROUGHT.ReadyPlayers[ply] = nil

		PrintTable(DROUGHT.ReadyPlayers)
		L(ply:Name() .. " has left the server.")
	end)

	util.AddNetworkString("drought_readyup") 

	timer.Create("drought_readyup_timer", 1, 0, function()
		if next(DROUGHT.ReadyPlayers) == nil then return end

		for k,v in pairs(DROUGHT.ReadyPlayers) do
			if not v then return end
		end

		L"Everyone is ready! Starting game"

		PrintMessage(3, "Everyone is ready...")

		timer.Remove("drought_readyup_timer")

		timer.Simple(3, function()
			SetGlobalBool("drought_game_is_started", true)

			game.CleanUpMap()
			DROUGHT.Interactable:SpawnInteractables()

			DROUGHT.Alive = {}

			for k,v in pairs(player.GetAll()) do
				L("Spawned ", v)
				v:Spawn()
				v:UnSpectate()
				v:SetTeam(1)
				GAMEMODE:PlayerLoadout(v)
				GAMEMODE:InitGameVars(v)
				GAMEMODE:ClearInventory(v)
				GAMEMODE:RecalculateMovementVars(v)
				DROUGHT.Alive[v] = true
			end

			DROUGHT.StartTime = SysTime()
				
			net.Start("drought_readyup")
				net.WriteBool(true)
			net.Send(player.GetHumans())
		end)
	end)

	net.Receive("drought_readyup", function(len, ply)
		--ply:ChatPrint("Received ready up request...")
		--ply:ChatPrint(tostring(SysTime() - ply.readyupcooldown))

		if ply.readyupcooldown and SysTime() < ply.readyupcooldown + 3 then return end

		ply.readyupcooldown = SysTime()

		local state = not DROUGHT.ReadyPlayers[ply]
		DROUGHT.ReadyPlayers[ply] = state

		--ply:ChatPrint(tostring(DROUGHT.ReadyPlayers[ply]))

		net.Start("drought_readyup")
			net.WriteBool(false)
			net.WriteEntity(ply)
			net.WriteBit(state)
		net.Send(player.GetHumans())

		--ply:ChatPrint("Processed ready up request!")
	end)
else

	DROUGHT.ReadyUpPanel = DROUGHT.ReadyUpPanel or nil

	surface.CreateFont("drought_ready_text", {
		font = "Arial",
		size = 60,
		weight = 1000,
		outline = true,
		antialias = true
	})
	
	DROUGHT.OurReadyUpState = false
	
	DROUGHT.ReadyPlayers = {}

	function DROUGHT:CreateReadyUpPanel()
		if DROUGHT.ReadyUpPanel and IsValid(DROUGHT.ReadyUpPanel) then
			DROUGHT.ReadyUpPanel:Remove()
		end

		for k,v in pairs(player.GetAll()) do
			DROUGHT.ReadyPlayers[v] = false
		end 

		DROUGHT.ReadyUpPanel = vgui.Create("DFrame")
		DROUGHT.ReadyUpPanel:SetTitle("")
		DROUGHT.ReadyUpPanel:ShowCloseButton(false)
		DROUGHT.ReadyUpPanel:SetSize(ScrW() / 2, ScrH())
		DROUGHT.ReadyUpPanel:Center()
		DROUGHT.ReadyUpPanel:MakePopup()
		DROUGHT.ReadyUpPanel:SetDraggable(false)
		local panel = DROUGHT.ReadyUpPanel

		surface.SetFont("drought_ready_text")
		local tw, th = surface.GetTextSize("Ready?")

		panel.ReadyLabel = vgui.Create("DLabel", panel)
		panel.ReadyLabel:SetFont("drought_ready_text")
		panel.ReadyLabel:SetText("Ready?")
		panel.ReadyLabel:SetSize(tw, th)
		panel.ReadyLabel:SetPos(panel:GetWide() / 2 - tw / 2, panel:GetTall() / 8 - th / 2)

		panel.ReadyUpButton = vgui.Create("DButton", panel)
		local ox, oy = panel.ReadyLabel:GetPos()
		panel.ReadyUpButton:SetPos(ox, oy + panel.ReadyLabel:GetTall() * 2)
		panel.ReadyUpButton:SetWide(panel.ReadyLabel:GetWide())
		panel.ReadyUpButton:SetTall(30)
		panel.ReadyUpButton:SetText("Ready Up")
		function panel.ReadyUpButton.DoClick(button)
			net.Start("drought_readyup")
			net.SendToServer()

			chat.AddText("Sent ready up request...")
		end

		panel.ReadyUpPropertySheet = vgui.Create("DPropertySheet", panel)
		panel.ReadyUpPropertySheet:SetTall(panel:GetTall() / 1.5)
		panel.ReadyUpPropertySheet:Dock(BOTTOM)
		local property = panel.ReadyUpPropertySheet

		property.panel1 = vgui.Create("DPanel", panel.ReadyUpPropertySheet)
		property.panel1.Paint = function(self, w, h)
			draw.RoundedBox(4, 0, 0, w, h, Color(60, 60, 80, self:GetAlpha()))
		end 
				
		property.panel1.scroll = vgui.Create( "DScrollPanel", property.panel1 )
		property.panel1.scroll:Dock( FILL )

		panel.ReadyUpPropertySheet:AddSheet("Player List", property.panel1, "icon16/cross.png")

		property.panel2 = vgui.Create("DPanel", panel.ReadyUpPropertySheet)
		property.panel2.Paint = function(self, w, h)
			draw.RoundedBox(4, 0, 0, w, h, Color(255, 128, 0, self:GetAlpha()))
		end 

		panel.ReadyUpPropertySheet:AddSheet("Classes", property.panel2, "icon16/tick.png")

		timer.Create("drought_readyup_show", 1, 0, DROUGHT.PlayerlistTimerFunc)
	end

	function DROUGHT.PlayerlistTimerFunc()
		if IsValid(DROUGHT.ReadyUpPanel)
		and IsValid(DROUGHT.ReadyUpPanel.ReadyUpPropertySheet)
		and IsValid(DROUGHT.ReadyUpPanel.ReadyUpPropertySheet.panel1) then
			
			local panel = DROUGHT.ReadyUpPanel.ReadyUpPropertySheet.panel1
			local scroll = panel.scroll

			local children = scroll:GetChildren()[1]:GetChildren()

			for k,v in pairs(children) do v:Remove() end

			for k,v in pairs(player.GetAll()) do
				local playerpanel = scroll:Add("DPanel")
				playerpanel:Dock(TOP)
				playerpanel:DockMargin(panel:GetWide() / 4, 5, panel:GetWide() / 4, 5)
				playerpanel:SetTall(66)
				playerpanel.Player = v
				
				local col = v.drought_isReady and Color(0, 255, 0) or Color(255, 0, 0)
				if v.drought_isReady != nil then
					playerpanel:SetBackgroundColor(col)
				else
					playerpanel:SetBackgroundColor(Color(60, 60, 60))
				end

				local avatar = vgui.Create("AvatarImage", playerpanel)
				avatar:SetPos(2, 2)
				avatar:SetSize(62, 62)
				avatar:SetPlayer(v, 64)

				local label = vgui.Create("DLabel", playerpanel)
				label:SetPos(70, 0)
				label:SetWide(panel:GetWide() / 2)
				label:SetText(v:Name())
				label:SetFont("BudgetLabel")
				
				local clabel = vgui.Create("DLabel", playerpanel)
				clabel:SetPos(70, 12)
				clabel:SetText("N/A")
				clabel:SetFont("BudgetLabel")
--[[
				local rlabel = vgui.Create("DLabel", playerpanel)
				rlabel:SetText("Ready")
				rlabel:SetFont("BudgetLabel")

				function rlabel:Paint(w, h)
					surface.SetFont("BudgetLabel")

					local txt = "Ready"
					local tw, th = surface.GetTextSize(txt)
					
					self:SetPos(panel:GetWide() / 2 - tw - 2)


				end]]
			end
		else
			timer.Remove("drought_readyup_show")
		end
	end

	hook.Add("InitPostEntity", "drought_readyup_show", function()
		if DROUGHT.GameStarted() then return end

		DROUGHT:CreateReadyUpPanel()
		hook.Remove("InitPostEntity", "drought_readyup_show")

		local str = "$pp_colour_"
		local tab = {
			[str.."addr"] = 0,
			[str.."addg"] = 0,
			[str.."addb"] = 0,
			[str.."brightness"] = 0.0,
			[str.."contrast"] = 0.5,
			[str.."colour"] = 0,
			[str.."mulr"] = 0,
			[str.."mulg"] = 0,
			[str.."mulb"] = 0
		}
		hook.Add("RenderScreenspaceEffects", "drought_start_effect", function()
			DrawColorModify(tab)
		end) 
	end)

	DROUGHT:CreateReadyUpPanel()
	--chat.AddText(GetGlobalBool("drought_game_is_started", false))
	--if GetGlobalBool("drought_game_is_started", false) then
		-- DROUGHT:CreateReadyUpPanel()
	--end
	--if IsValid(DROUGHT.ReadyUpPanel) and not GetGlobalBool("drought_game_is_started", false) then
	--	DROUGHT:CreateReadyUpPanel()
	--end

	net.Receive("drought_readyup", function()
		local isDone = net.ReadBool()

		if not isDone then 
			local ply = net.ReadEntity()
			local isReady = net.ReadBit() == 1

			ply.drought_isReady = isReady

			local col = isReady and Color(0, 255, 0) or Color(255, 0, 0)

			if ply == LocalPlayer() then
				local txt = isReady and "Ready!" or "Not Ready"

				local panel = DROUGHT.ReadyUpPanel

				surface.SetFont("drought_ready_text")
				local tw, th = surface.GetTextSize(txt)
				
				panel.ReadyLabel:SetColor(col)
				panel.ReadyLabel:SetText(txt)
				panel.ReadyLabel:SetPos(panel:GetWide() / 2 - tw / 2, panel:GetTall() / 8 - th / 2)
				panel.ReadyLabel:SetSize(tw, th)
			end
			
			local plypanels = DROUGHT.ReadyUpPanel.ReadyUpPropertySheet.panel1.scroll:GetChildren()[1]:GetChildren()

			for k,v in pairs(plypanels) do
				if v.Player == ply then
					v:SetBackgroundColor(col)
				end
			end
		else
			if IsValid(DROUGHT.ReadyUpPanel) then DROUGHT.ReadyUpPanel:Remove() end
			timer.Remove("drought_readyup_show")
			hook.Remove("RenderScreenspaceEffects", "drought_start_effect")
		end
	end)


end