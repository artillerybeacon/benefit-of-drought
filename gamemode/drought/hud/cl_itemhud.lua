if not ConVarExists("bod_item_icon_width") then
	CreateClientConVar("bod_item_icon_width", "60", true, false, "Icon width for top right menu", 20, 200)
end
if not ConVarExists("bod_item_qty_font") then
	CreateClientConVar("bod_item_qty_font", "BudgetLabel", true, false, "Font used for item quantities")
end

local iwidth = GetConVar("bod_item_icon_width"):GetInt()
local width = iwidth * 6
cvars.AddChangeCallback("bod_item_icon_width", function(cvar, old, new)
	iwidth = tonumber(new)
	width = iwidth * 6
end)

local ifont = GetConVar("bod_item_qty_font"):GetString()
cvars.AddChangeCallback("bod_item_qty_font", function(cvar, old, new)
	ifont = new
end)

local iborder = 5
local border = 10

local lastItemY 

our_itemlist_cache = our_itemlist_cache or {}
our_itemlist_material_cache = our_itemlist_material_cache or {}

local me = LocalPlayer()
hook.Add("HUDPaint", "DroughtHudItem", function()
	if not IsValid(me) then
		me = LocalPlayer()
	end

	if not me:Alive() then return end
	if not DROUGHT.GameStarted() then return end

	surface.SetDrawColor(90, 90, 90, 150)

	if not lastItemY then
		surface.DrawRect(ScrW() - width - border, border, width, 60)
	else
		surface.DrawRect(ScrW() - width - border, border, width, iwidth * lastItemY)
	end

	surface.SetDrawColor(255, 255, 255, 255)

	local itemPointer = 0
	local itemPointerY = 0
	for k,v in pairs(our_itemlist_cache) do
		itemPointer = itemPointer + 1

		if itemPointer > 6 then
			itemPointer = 1
			itemPointerY = itemPointerY + 1
		end

		if not our_itemlist_material_cache[k] then
			our_itemlist_material_cache[k] = Material("materials/item_" .. k .. ".png")
		end

		local xpos = ScrW() - border - (iwidth * itemPointer)  + iborder
		local ypos = border + iborder + (iwidth * itemPointerY)
		
		surface.SetMaterial(our_itemlist_material_cache[k])
		surface.DrawTexturedRect(xpos, ypos, iwidth - iborder * 2, iwidth - iborder * 2)

		if v > 1 then
			surface.SetTextColor(255, 255, 255, 255)
			surface.SetFont(ifont)

			local txt = "x" .. tostring(v)
			local tw, th = surface.GetTextSize(txt)
			surface.SetTextPos(xpos + iwidth - (iborder * 2) - tw, ypos)
			surface.DrawText(txt)
		end
	end

	lastItemY = itemPointerY + 1

end)