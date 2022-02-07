
local hide = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
    ["CHudAmmo"] = true,
    ["CHudSecondaryAmmo"] = true
}

local enabled_cvar = CreateClientConVar("ror2hud_enabled", "1", true, false, "The RoR2 HUD is enabled.", 0, 1)

hook.Add("HUDShouldDraw", "HideHUD", function(name) if hide[name] then return false end end)

local cPushModelMatrix = cam.PushModelMatrix
local cPopModelMatrix = cam.PopModelMatrix

surface.CreateFont("RoR2HUD_Bombardier", {
    font = "Bombardier",
    extended = false,
    size = 25,
    antialias = true
})


local tMat = Matrix()

local xpadding_cvar = CreateClientConVar("ror2hud_xpadding", "122", true, false, "Changes how far away the HUD touches the sides of the screen.", 0, ScrW())
local ypadding_cvar = CreateClientConVar("ror2hud_ypadding", "100", true, false, "Changes how far away the HUD touches the bottom of the screen.", 0, ScrH())
local armorThickness_cvar = CreateClientConVar("ror2hud_armorthickness", "6", true, false, "How thick the armor bar is compared to the health bar (in pixels).", 0, 32)
local hudAngle_cvar = CreateClientConVar("ror2hud_angle", "3", true, false, "The angle at which the HUD is set at.", -90, 90)
local filter_cvar = CreateClientConVar("ror2hud_filter", "3", true, false, "The texture filter used on the HUD. 0 = None, 1 = Point, 2 = Linear, 3 = Anistropic.", 0, 3)

local function drawElements(offsetx, offsety, angle, drawfunc)
    tMat:SetAngles(Angle(angle, angle, 45))

    tMat:SetTranslation(Vector(offsetx, offsety, 0))

    tMat:SetScale(Vector(1, 1, 0))

    cPushModelMatrix(tMat)
        drawfunc()
    cPopModelMatrix()
end

local function drawUVBar(mat, color, xpos, ypos, width, height, pixels)
    if width < 1 then return end
    surface.SetMaterial(mat)
    surface.SetDrawColor(unpack(color)) -- unpack(color)
    surface.DrawTexturedRectUV(xpos, ypos, 4, height, 0, 0, 0.125, 1)
    surface.DrawTexturedRectUV(xpos+4, ypos, width-(pixels)+1, height, 0.125, 0, 0.875, 1)
    surface.DrawTexturedRectUV(xpos+width-4, ypos, 4, height, 0.875, 0, 1, 1)
end

local hpBarMat = Material("ror2hud/hpbar.png")
local armorBarMat = Material("ror2hud/armorbar.png")
local barBackMat = Material("ror2hud/barback.png")
local lowHp = Material("ror2hud/lowhp_indicator.png")

local curFPS = 0

local hidden_elements = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
    ["CHudAmmo"] = true,
    ["CHudSecondaryAmmo"] = true
}

hook.Add("HUDShouldDraw", "RoR2HUDDisableDefault", function(name)
    if hidden_elements[name] then return !enabled_cvar:GetBool() end
end)

local me = LocalPlayer()

hook.Add("HUDPaint", "RoR2HUD", function()
	if not IsValid(me) then
		me = LocalPlayer()
	end

    if !enabled_cvar:GetBool() then return end -- if the cvar is set to disable the HUD

	if not DROUGHT.GameStarted() then return end
	
    render.PushFilterMag(filter_cvar:GetInt()) --smooth filter
    render.PushFilterMin(filter_cvar:GetInt())

    local xpadding = xpadding_cvar:GetInt()
    local ypadding = ypadding_cvar:GetInt()
    local armorThickness = armorThickness_cvar:GetInt()
    local hudAngle = -hudAngle_cvar:GetInt()

    --[[------------------------
               Health
    --]]------------------------

    local hp = LocalPlayer():Health()
    local maxhp = LocalPlayer():GetMaxHealth()
    local hpratio = math.Clamp(hp, 0, maxhp) / maxhp

    drawElements(xpadding, ScrH()-ypadding, hudAngle, function()
        surface.SetDrawColor(210, 210, 210, 180)
        surface.SetMaterial(barBackMat)
        surface.DrawTexturedRect(0, 0, 430, 30)
        drawUVBar(hpBarMat, {94, 173, 48, 255}, 0, 0, 430*hpratio, 30, 8)
    end) --health bar

    local armor = LocalPlayer():Armor()
    local maxarmor = LocalPlayer():GetMaxArmor()
    local armorratio = math.Clamp(armor, 0, maxarmor) / maxarmor

    drawElements(xpadding-armorThickness, ScrH()-ypadding-armorThickness, hudAngle, function()
        drawUVBar(armorBarMat, {255, 255, 255, 255}, 0, 0, 438*armorratio, 30+armorThickness*2, 8)
    end) --armor bar

    drawElements(xpadding, ScrH()-ypadding, hudAngle, function()
        surface.SetMaterial(lowHp)
        surface.DrawTexturedRect(3, 3, 50, 24)

        draw.TextShadow({
            text = math.max(hp, 0) .. " / " .. maxhp,
            font = "RoR2HUD_Bombardier",
            pos = {215, 15},
            color = color_white,
            xalign = TEXT_ALIGN_CENTER,
            yalign = TEXT_ALIGN_CENTER
        }, 1, 150)
    end) -- health text

    curFPS = Lerp(4 * RealFrameTime(), curFPS, 1/RealFrameTime())

    drawElements(xpadding+6, ScrH()-ypadding-34, hudAngle, function()
        draw.TextShadow({
            text = LocalPlayer():Nick(),
            font = "RoR2HUD_Bombardier",
            pos = {0, 12},
            color = color_white,
            xalign = TEXT_ALIGN_LEFT,
            yalign = TEXT_ALIGN_CENTER
        }, 1, 150)
        draw.TextShadow({
            text = "$"..string.Comma(tostring(me:GetNWInt("drought_money", 0))),
            font = "RoR2HUD_Bombardier",
            pos = {415, 12},
            color = color_white,
            xalign = TEXT_ALIGN_RIGHT,
            yalign = TEXT_ALIGN_CENTER
        }, 1, 150)
    end) -- name, fps/ping text

    render.PopFilterMag()
    render.PopFilterMin()
end)


do return end


		if not DROUGHT.DifficultyMeterPanel or not IsValid(DROUGHT.DifficultyMeterPanel) then
			local bw = 270
			local bh = 35
			local y = 5

			local panel = vgui.Create('DPanel')
			panel:SetPos(ScrW() / 2 - bw / 2, y)
			panel:SetSize(bw, bh)
			panel:SetBackgroundColor(Color(0, 0, 0))


			// todo: get duration based on time set from global var
			local start = SysTime()

			--local dp = derma.GetControlList().DPanel
			--print(dp)

			local diffs = {
				{
					name = "Easy",
					col = Color(0, 200, 50),
					w = 1
				},
				{
					name = "Medium",
					col = Color(150, 200, 50),
					w = 1
				},
				{
					name = "Impossible",
					col = Color(70, 70, 70),
					w = 50
				}
			}
			function panel:Paint(w, h)

				surface.SetDrawColor(0, 0, 0)
				surface.DrawRect(0, 0, w, h)

				local at = (60 * 5) * 4
				local dur = SysTime() - start
				local real_box_perc = bw / 2 -- the diffs will use
				local offset = 0
				for i = 1, #diffs do
					local v = diffs [i]
					local real = v.w * real_box_perc

					local sadge = 2 - bw * (dur / at) + bw / 2 + offset
					surface.SetDrawColor(v.col:Unpack())
					surface.DrawRect(sadge, 2, real - 4, bh - 4)

					offset = math.ceil(offset + real) - 5
				end
				
				// pointer
				surface.SetDrawColor(70, 70, 70)
				surface.DrawRect(w / 2 - 1, 0, 2, h)
			end

			DROUGHT.DifficultyMeterPanel = panel
		end