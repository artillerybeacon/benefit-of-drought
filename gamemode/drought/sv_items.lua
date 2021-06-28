function GM:SpawnItem(pos, id)
	local item = self.ItemDefs[id]
	if not item then return end

	local ent = ents.Create("item_pickup")
	ent:SetPos(pos)
	ent:SetItemID(id)
	ent:Spawn()

	if item.rarity == 5 then
		PrintMessage(3, "A debuff item has spawned on the map. Someone has to pick it up in 60 seconds or something very bad will happen to your team, I promise.")
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

util.AddNetworkString("drought_send_pickup")
function GM:BroadcastPickupItem(ply, id)
	net.Start("drought_send_pickup")
		net.WriteEntity(ply)
		net.WriteString(id)
	net.Send(player.GetHumans())
end

function GM:PostPlayerDeath(vic, inf, atk)
	PrintMessage(3, "!!! " .. vic:Name() .. " died a horrible death. !!!")
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

	--print("GM:PickupItem", ply, id)

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
end

concommand.Add("bod_admin_spawn_item", function(ply, argst, args)
	if !ply:IsSuperAdmin() then return end 

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