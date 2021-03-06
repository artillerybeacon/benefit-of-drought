include("shared.lua")
include("outline.lua")

net.Receive("drought_send_pickup", function()
	local ent = net.ReadEntity()
	local item = net.ReadString()

	item = GAMEMODE.ItemDefs[item]
	if not item then return end

	chat.AddText(
		color_white,
		">> ",
		team.GetColor(0),
		ent == LocalPlayer() and "You" or ent:GetName(),
		color_white,
		ent == LocalPlayer() and " have" or " has",
		" picked up ",
		GAMEMODE.ItemRarities[item.rarity].color,
		item.name
	)

	if ent == LocalPlayer() then
		chat.AddText(Color(148, 148, 148), "      ", item.desc)
	end
end)

net.Receive("drought_modify_itemlist", function()
	local item = net.ReadString()
	local qty = net.ReadUInt(32)

	if qty == 0 then
		qty = nil
	end

	our_itemlist_cache[item] = qty
end)


print("GM:", GM)