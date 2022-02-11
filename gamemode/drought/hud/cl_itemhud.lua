if not ConVarExists("bod_item_icon_width") then
	CreateClientConVar("bod_item_icon_width", "60", true, false, "Icon width for top right menu", 20, 200)
end
if not ConVarExists("bod_item_qty_font") then
	CreateClientConVar("bod_item_qty_font", "BudgetLabel", true, false, "Font used for item quantities")
end

local function drawUVBar(mat, color, xpos, ypos, width, height, pixels)
    if width < 1 then return end
    surface.SetMaterial(mat)
    surface.SetDrawColor(unpack(color)) -- unpack(color)
    surface.DrawTexturedRectUV(xpos, ypos, 4, height, 0, 0, 0.125, 1)
    surface.DrawTexturedRectUV(xpos+4, ypos, width-(pixels)+1, height, 0.125, 0, 0.875, 1)
    surface.DrawTexturedRectUV(xpos+width-4, ypos, 4, height, 0.875, 0, 1, 1)
end

local irow = 10

local hpBarMat = Material("ror2hud/barback.png")

local iwidth = GetConVar("bod_item_icon_width"):GetInt()
local width = iwidth * irow
cvars.AddChangeCallback("bod_item_icon_width", function(cvar, old, new)
	iwidth = tonumber(new)
	width = iwidth * irow
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

local xp = 33
local yp = 16
hook.Add("HUDPaint", "DroughtHudItem", function()
	if not IsValid(me) then
		me = LocalPlayer()
	end

	-- if not me:Alive() then return end
	if not DROUGHT.GameStarted() then return end

	local bgw, bgh = iwidth * (irow), (iwidth) * (lastItemY or 0) 
    surface.SetDrawColor(255, 255, 255, 180)
    surface.SetMaterial(hpBarMat)
    surface.DrawTexturedRect(
		ScrW() / 2 - bgw / 2,
		yp + 17,-- + --bgh,
		bgw,
		bgh
	)

	surface.SetDrawColor(255, 255, 255, 255)

	local itemPointer = 0
	local itemPointerY = 0
	for k,v in pairs(our_itemlist_cache) do
		itemPointer = itemPointer + 1

		if itemPointer > irow then
			itemPointer = 1
			itemPointerY = itemPointerY + 1
		end

		if not our_itemlist_material_cache[k] then
			our_itemlist_material_cache[k] = Material("materials/item_" .. k .. ".png")
		end

		local xpos = ScrW() / 2 - bgw / 2 + (iwidth * (itemPointer - 1)) + iborder -- - xp - (iwidth * itemPointer) + border - iborder
		local ypos = yp + 17 + (iwidth * (itemPointerY)) + iborder--  + border * 2 + iborder
		
		surface.SetMaterial(our_itemlist_material_cache[k])
		surface.DrawTexturedRect(xpos, ypos, iwidth - border, iwidth - border)

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