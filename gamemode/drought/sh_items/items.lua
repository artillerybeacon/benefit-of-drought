if SERVER then

	function GM:SpawnItem(pos, id)
		local item = self.ItemDefs[id]
		if not item then return end

		local ent = ents.Create("item_pickup")
		ent:SetPos(pos)
		ent:SetItemID(id)
		ent:Spawn()

		if item.rarity == 5 then
			PrintMessage(3, "A debuff item has spawned on the map. Someone has to pick it up in 60 seconds or something very bad will happen to your team, I promise.")
			DROUGHT.Detrimental = SysTime()
		end

		return ent
	end

	util.AddNetworkString("drought_modify_itemlist")
	function GM:SendItemChange(ply, id, qty)
		net.Start("drought_modify_itemlist")
			net.WriteString(id)
			net.WriteUInt(qty, 32)
		net.Send(ply)
	end

	function GM:ClearInventory(ply)
		if not ply.Inventory then return end

		for k,v in pairs(ply.Inventory) do
			self:SendItemChange(ply, k, 0)
		end

		ply.Inventory = {}
		ply:RecalculateVars()
	end

	util.AddNetworkString("drought_send_pickup")
	function GM:BroadcastPickupItem(ply, id)
		net.Start("drought_send_pickup")
			net.WriteEntity(ply)
			net.WriteString(id)
		net.Send(player.GetHumans())
	end


	function GM:OnPickupItem(ply, ent)
		local id
		if IsEntity(ent) then
			id = ent:GetItemID()
		elseif isstring(ent) then
			id = ent
		else
			error("wtf was passed through OnPickupItem? " .. tostring(ent))
		end
		
		if not self.ItemDefs[id] then
			error("OnPickupItem called with invalid parameters id=" .. id)
		else
			if self.ItemDefs[id].rarity == 5 and DROUGHT.Detrimental then
				DROUGHT.Detrimental = nil
				PrintMessage(3, 'Someone has to pay the price for your consequences.')
			end
		end

		self:BroadcastPickupItem(ply, id)

		local qty = 1

		if not ply.Inventory then
			ply.Inventory = {}
		end

		if not ply.Inventory[id] then
			ply.Inventory[id] = qty
		else
			ply.Inventory[id] = ply.Inventory[id] + 1

			qty = ply.Inventory[id]
		end

		self:SendItemChange(ply, id, qty)
		ply:RecalculateVars()
	end

	include('sv_detrim_gimmick.lua')



	concommand.Add("bod_admin_spawn_item", function(ply, argst, args)
		-- if !ply:IsSuperAdmin() then return end 

		local item
		if next(args) == nil then
			item = "register"
		else
			item = string.Trim(args[1]:lower())
		end

		GAMEMODE:SpawnItem(ply:GetEyeTrace().HitPos, item)
	end)

	concommand.Add("bod_admin_clearitems", function(ply)
		if !ply:IsSuperAdmin() then return end 

		local items = ents.FindByClass("item_pickup")

		ply:ChatPrint("Cleared " .. tostring(#items) .. " items.")

		for i = 1, #items do
			local ent = items[i]

			SafeRemoveEntity(ent)
		end
	end)

end
/////

local function loadItems()

	local fpath = GAMEMODE.FolderName .. '/gamemode/drought/sh_items/itemdefs/'
	local f,d = file.Find(fpath .. '/*.lua', 'LUA')

	--print('balls')
	--print(f,d)
	--PrintTable(f)
	for _,v in pairs(f) do
		AddCSLuaFile(fpath .. v)
		local e = include(fpath .. v)
		if e then
			local cn = v:sub(1, v:len() - 4)
			GAMEMODE.ItemDefs[cn] = e
			if file.Exists("materials/item_" .. cn .. ".png", "GAME") then
				resource.AddSingleFile("materials/item_" .. cn .. ".png")
			else
				print("No Icon:", k)
			end
		end
		print(' > Included ' .. v)
	end

end 

concommand.Add('bod_force_reload_items', loadItems)
hook.Add("Initialize", 'loadItems', loadItems)