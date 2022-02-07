if SERVER then

	function GM:SpawnItem(pos, id)
		local item = self.ItemDefs[id]
		if not item then return end

		local ent = ents.Create("item_pickup")
		ent:SetItemID(id)
		ent:SetPos(pos)
		ent:UpdateOurItem()
		ent:Spawn()

		if item.rarity == 5 then
			PrintMessageColor(nil, Color(255, 0, 0), 'A debuff item has spawned on the map. Someone has to pick it up in 60 seconds or something very bad will happen to your team, I promise.')
			DROUGHT.Detrimental = { 
				time = SysTime(),
				ply = NULL,
				id = id
			}
		end

		return ent
	end

	util.AddNetworkString("drought_modify_itemlist")
	function GM:SendItemChange(ply, id, qty)
		net.Start("drought_modify_itemlist")
			net.WriteString(id)
			net.WriteUInt(qty or 0, 32)
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

local function loadItems()

	local path = GAMEMODE.FolderName .. '/gamemode/drought/sh_items/itemdefs/'
	local files, dirs = file.Find(path .. '/*.lua', 'LUA')

	for _, v in pairs(files) do
		AddCSLuaFile(path .. v)
		local data = include(path .. v)
		if data then
			local internal = v:sub(1, v:len() - 4)
			GAMEMODE.ItemDefs[internal] = data
			if file.Exists("materials/item_" .. internal .. ".png", "GAME") then
				resource.AddSingleFile("materials/item_" .. internal .. ".png")
			else
				print("No Icon:", internal)
			end
		end
		print(' > Included ' .. v)
	end

end 

if CLIENT then
	concommand.Add('bod_force_reload_items_cl', loadItems)
else
	concommand.Add('bod_force_reload_items', function(ply)
		if ply != NULL or (IsValid(ply) and ply:IsSuperAdmin()) then return end

		loadItems()
		for k,v in pairs(player.GetAll()) do
			v:ConCommand('bod_force_reload_items_cl')
		end
	end)
end
hook.Add("Initialize", 'loadItems', loadItems)