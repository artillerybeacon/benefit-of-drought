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

function GM:ClearInventory(ply)
	if not ply.Inventory then return end

	for k,v in pairs(ply.Inventory) do
		self:SendItemChange(ply, k, 0)
	end

	ply.Inventory = {}
	self:RecalculateMovementVars(ply)
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
	self:RecalculateMovementVars(ply)
end

local default_walk = 200
local default_jump = 200
function GM:RecalculateMovementVars(ply)

	// Movement Speed
	local extraSpeed = 0
	if ply.Inventory and ply.Inventory.shoe then
		extraSpeed = self.ItemDefs.shoe.getEffect(ply.Inventory.shoe)
	end
	ply:SetRunSpeed((default_walk * 2) + (extraSpeed * 2))
	ply:SetWalkSpeed(default_walk + extraSpeed)

	// Jump Power
	local extraJump = 0
	if ply.Inventory and ply.Inventory.horsie then
		extraJump = self.ItemDefs.horsie.getEffect(ply.Inventory.horsie)
	end
	ply:SetJumpPower(default_jump + extraJump)

	// Attack Speed
	local wep = ply:GetActiveWeapon()
	if IsValid(wep) and wep.Primary and wep.Primary.Delay then

		local delay
		if not wep.Primary.StoredDelay then
			wep.Primary.StoredDelay = wep.Primary.Delay
		end

		delay = wep.Primary.StoredDelay
		
		local extraASpeed = 1
		if ply.Inventory and ply.Inventory.oilbarrel then
			extraASpeed = math.max(extraASpeed - self.ItemDefs.oilbarrel.getEffect(ply.Inventory.oilbarrel), 0)
		end

		delay = delay * extraASpeed

		wep.Primary.Delay = math.Round(delay, 6)

		wep:CallOnClient('HackySetDelay', tostring(wep.Primary.Delay))

	end

end

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