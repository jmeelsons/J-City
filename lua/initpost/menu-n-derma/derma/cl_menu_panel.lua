local PANEL = {}
local curent_panel 
local red_select = Color(250,0,0)
local isFirstOpen = true

DISCORD_URL = "" -- your discord url

local Selects = {
    {Title = "Disconnect", Func = function(luaMenu) RunConsoleCommand("disconnect") end},
    {Title = "Main Menu", Func = function(luaMenu) gui.ActivateGameUI() luaMenu:Close() end},
    {Title = "Discord", Func = function(luaMenu) luaMenu:Close() gui.OpenURL(DISCORD_URL)  end},
--  {Title = "Donate", Func = function(luaMenu) luaMenu:Close() IGS.UI(pl) end}, 
    {Title = "Traitor Role",
    GamemodeOnly = true,
    CreatedFunc = function(self, parent, luaMenu)
        local btn = vgui.Create( "DLabel", self )
        btn:SetText( "SOE" )
        btn:SetMouseInputEnabled( true )
        btn:SizeToContents()
        btn:SetFont( "ZC_MM_Buttons" )
        btn:SetTall( ScreenScale( 12 ) )
        btn:Dock(BOTTOM)
        btn:DockMargin(ScreenScale(5),ScreenScale(10),0,0)
        btn:SetTextColor(Color(255,255,255))
        btn:InvalidateParent()
        btn.RColor = Color(225, 225, 225, 0)
        btn.WColor = Color(225, 225, 225, 255)
        btn.x = btn:GetX()

        function btn:DoClick()
            luaMenu:Close()
            hg.SelectPlayerRole(nil, "soe")
        end
    
        local selfa = self
        function btn:Think()
            self.HoverLerp = selfa.HoverLerp
            self.HoverLerp2 = LerpFT(0.2, self.HoverLerp2 or 0, self:IsHovered() and 1 or 0)
                
            self:SetTextColor(self.RColor:Lerp(self.WColor:Lerp(red_select, self.HoverLerp2), self.HoverLerp))
            self:SetX(self.x + ScreenScaleH(40) + self.HoverLerp * ScreenScaleH(50))
        end

        local btn = vgui.Create( "DLabel", btn )
        btn:SetText( "STD" )
        btn:SetMouseInputEnabled( true )
        btn:SizeToContents()
        btn:SetFont( "ZC_MM_Buttons" )
        btn:SetTall( ScreenScale( 12 ) )
        btn:Dock(BOTTOM)
        btn:DockMargin(0,ScreenScale(2),0,0)
        btn:SetTextColor(Color(255,255,255))
        btn:InvalidateParent()
        btn.RColor = Color(225, 225, 225, 0)
        btn.WColor = Color(225, 225, 225, 255)
        btn.x = btn:GetX()

        function btn:DoClick()
            luaMenu:Close()
            hg.SelectPlayerRole(nil, "standard")
        end
    
        function btn:Think()
            self.HoverLerp = selfa.HoverLerp
            self.HoverLerp2 = LerpFT(0.2, self.HoverLerp2 or 0, self:IsHovered() and 1 or 0)
    
            self:SetTextColor(self.RColor:Lerp(self.WColor:Lerp(red_select, self.HoverLerp2), self.HoverLerp))
            self:SetX(self.x + ScreenScaleH(35))
        end
    end,
    Func = function(luaMenu)
        
    end,
    },
    {Title = "Achievements", Func = function(luaMenu,pp) 
        hg.DrawAchievmentsMenu(pp)
    end},
    {Title = "Settings", Func = function(luaMenu,pp) 
        hg.DrawSettings(pp) 
    end},
    {Title = "Appearance", Func = function(luaMenu,pp) hg.CreateApperanceMenu(pp) end},
    {Title = "Return", Func = function(luaMenu) luaMenu:Close() end},
}

local splasheh = {
    'прощай СНБ ;(',
    'СНБ СЕКС',
    'ritkay толстый',
    'пинг под 500 это фича',
    'колымка CODE...',
    'Z-SANDBOX V2 FOREVER <3',
    'зтовн хуйня',
    'CHUCK NORRIS, Rest In Peace...',
    'С Днем победы вас товарищи!',
    'Тут была бы ваша реклама',
    'Я тебе под дверь насру',
    'Ганслингер купит арт своей фурсоны запомните слова!!!',
    'БОЕВОЙ ИНВАЛИД НА КОЛЯСКЕ ПРОТИВ МЛАДЕНЦА!!1',
    'Мод на госуслуги отсутствие судимости'
}

local Pluv = Material("pluv/pluvkid.jpg")

local IconPaths = {
    "snb/wypher/wypher1.png",
    "snb/wypher/wypher2.png",
    "snb/wypher/wypher3.png",
    "snb/wypher/wypher4.png",
    "snb/wypher/wypher5.png"
}

local IconMaterials = {}

function PANEL:GetRandomIcon()
    local path = IconPaths[math.random(#IconPaths)]
    if not IconMaterials[path] then
        IconMaterials[path] = Material(path)
    end
    return IconMaterials[path]
end

function PANEL:InitializeMarkup()
	local mapname = game.GetMap()
	local prefix = string.find(mapname, "_")
	if prefix then
		mapname = string.sub(mapname, prefix + 1)
	end
	local gm = splasheh[math.random(#splasheh)] .. " | " .. string.NiceName(mapname) 

    if hg.PluvTown.Active then
        local text = "<font=ZC_MM_Title><colour=199,2,2>    </colour>SED</font>\n<font=ZCity_Tiny><colour=105,105,105>" .. gm .. "</colour></font>"

        self.SelectedPluv = table.Random(hg.PluvTown.PluvMats)

        return markup.Parse(text)
    end

    local playersCount = #player.GetAll()
local text = "<font=ZC_MM_Title><colour=255,180,255,255>J<colour=255,255,255,255>-City :3</colour></font>\n<font=ZCity_Tiny><colour=105,105,105>" .. gm .. "</colour></font>\n<font=ZCity_Tiny><colour=105,105,105>Players online: " .. playersCount .. "</colour></font>"
    return markup.Parse(text)
end

local color_red = Color(255,25,25,45)
local clr_gray = Color(255,255,255,25)
local clr_verygray = Color(10,10,19,235)

function PANEL:Init()
    self:SetAlpha(0)
    self:SetSize(ScrW(), ScrH())
    self:Center()
    self:SetTitle("")
    self:SetDraggable(false)
    self:SetBorder(false)
    self:SetColorBG(clr_verygray)
    self:SetDraggable(false)
    self:ShowCloseButton(false)
    curent_panel = nil
    self.Title, self.TitleShadow = self:InitializeMarkup()

    self.currentIcon = self:GetRandomIcon()

    self:CreateImage()

    self:BuildMenuStructure()

    if isFirstOpen then
        self:FirstOpenAnimation()
    else
        self:ShowAll()
    end
end

function PANEL:CreateImage()
    self.imagePanel = vgui.Create("DPanel", self)
    local imageWidth = ScrW() * 0.5
    self.imagePanel:SetSize(imageWidth, ScrH())
    self.imagePanel:SetPos(ScrW() - imageWidth, 0)
    self.imagePanel:SetAlpha(0)
    self.imagePanel:SetMouseInputEnabled(false)
    self.imagePanel:SetZPos(0)
    self.imagePanel:SetKeyboardInputEnabled(false)
    
    self.imagePanel.idleTime = 0
    self.imagePanel.idleOffset = 0
    self.imagePanel.iconMaterial = self.currentIcon

    self.imagePanel.targetX = 0
    self.imagePanel.targetY = 0
    self.imagePanel.currentX = 0
    self.imagePanel.currentY = 0
    self.imagePanel.maxOffset = 20
    
    self.imagePanel.Paint = function(this, w, h)
        local iconMaterial = this.iconMaterial
        if iconMaterial then
            local texW, texH = iconMaterial:Width(), iconMaterial:Height()
            
            local scaleH = h / texH
            local scaleW = w / texW
            local scale = math.max(scaleH, scaleW)
            
            local drawW = texW * scale
            local drawH = texH * scale

            local baseX = (w - drawW) / 2
            local baseY = (h - drawH) / 2

            local x = baseX + this.currentX
            local y = baseY + this.currentY + this.idleOffset * 0.50
            
            surface.SetDrawColor(Color(255,255,255,255))
            surface.SetMaterial(iconMaterial)
            surface.DrawTexturedRect(x, y, drawW, drawH)
        end
    end
    
    function self.imagePanel:Think()
        if not IsValid(self) then return end
        self.idleTime = self.idleTime + FrameTime() * 5
        self.idleOffset = math.sin(self.idleTime) * 8

        local mouseX, mouseY = gui.MousePos()
        local scrW, scrH = ScrW(), ScrH()

        local normX = (mouseX / scrW - 0.5) * 2
        local normY = (mouseY / scrH - 0.5) * 2

        self.targetX = -normX * self.maxOffset
        self.targetY = -normY * self.maxOffset

        local speed = 0.08
        self.currentX = Lerp(speed, self.currentX or 0, self.targetX)
        self.currentY = Lerp(speed, self.currentY or 0, self.targetY)
    end
end

function PANEL:BuildMenuStructure()
    self.lDock = vgui.Create("DPanel", self)
    local lDock = self.lDock
    lDock:Dock(LEFT)
    lDock:SetSize(ScrW() / 4, ScrH())
    lDock:DockMargin(ScreenScale(0), ScreenScaleH(90), ScreenScale(10), ScreenScaleH(90))
    lDock.Paint = function(this, w, h)
        if hg.PluvTown.Active then
            surface.SetDrawColor(color_white)
            surface.SetMaterial(self.SelectedPluv or Pluv)
            surface.DrawTexturedRect(0, ScreenScale(27), ScreenScale(25), ScreenScale(27))
        end

        self.Title:Draw(ScreenScale(15), ScreenScale(50), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 255, TEXT_ALIGN_LEFT)
    end

    self.Buttons = {}
    for k, v in ipairs(Selects) do
        if v.GamemodeOnly and engine.ActiveGamemode() != "zcity" then continue end
        self:AddSelect(lDock, v.Title, v)
    end

    local bottomDock = vgui.Create("DPanel", self)
    bottomDock:SetPos(ScreenScale(1), ScrH() - ScrH()/10)
    bottomDock:SetSize(ScreenScale(190), ScreenScaleH(40))
    bottomDock.Paint = function(this, w, h) end
    self.panelparrent = vgui.Create("DPanel", self)
    self.panelparrent:SetPos(bottomDock:GetWide()+bottomDock:GetX(), 0)
    self.panelparrent:SetSize(ScrW() - bottomDock:GetWide()*1, ScrH())
    self.panelparrent.Paint = function(this, w, h) end
    
    local git = vgui.Create("DLabel", bottomDock)
    git:Dock(BOTTOM)
    git:DockMargin(ScreenScale(10), 0, 0, 0)
    git:SetFont("ZCity_Tiny")
    git:SetTextColor(clr_gray)
    git:SetText("GitHub: github.com/" .. hg.GitHub_ReposOwner .. "/" .. hg.GitHub_ReposName)
    git:SetContentAlignment(4)
    git:SetMouseInputEnabled(true)
    git:SizeToContents()

    function git:DoClick()
        gui.OpenURL("https://github.com/" .. hg.GitHub_ReposOwner .. "/" .. hg.GitHub_ReposName)
    end

    local zteam_left = vgui.Create("DLabel", bottomDock)
    zteam_left:Dock(BOTTOM)
    zteam_left:DockMargin(ScreenScale(10), 0, 0, 0)
    zteam_left:SetFont("ZCity_Tiny")
    zteam_left:SetTextColor(clr_gray)
    zteam_left:SetText("Authors: uzelezz, Sadsalat, \nMr.Point, Zac90, Deka, Mannytko")
    zteam_left:SetContentAlignment(4)
    zteam_left:SizeToContents()

    local zteam_right = vgui.Create("DLabel", self)
    zteam_right:SetPos(ScrW() - ScreenScale(196), ScrH() - ScrH()/15 + ScreenScaleH(5))
    zteam_right:SetFont("ZCity_Tiny")
    zteam_right:SetTextColor(clr_gray)
    zteam_right:SetText("J-City By Jmeelson's \nVersion: 2.3b")
    zteam_right:SetContentAlignment(5)
    zteam_right:SizeToContents()
    zteam_right:SetMouseInputEnabled(false)
end

function PANEL:FirstOpenAnimation()
    isFirstOpen = false

    self:SetAlpha(0)
    if self.lDock then self.lDock:SetAlpha(0) end
    if self.imagePanel then self.imagePanel:SetAlpha(0) end

    for _, btn in ipairs(self.Buttons or {}) do
        btn:SetAlpha(0)
    end

    timer.Simple(0.05, function()
        if not IsValid(self) then return end
        self:AlphaTo(255, 0.3, 0, nil)
    end)

    timer.Simple(0.1, function()
        if not IsValid(self) or not IsValid(self.lDock) then return end
        self.lDock:AlphaTo(255, 0.25, 0, nil)
    end)

    timer.Simple(0.3, function()
        if not IsValid(self) or not IsValid(self.imagePanel) then return end
        self.imagePanel:AlphaTo(200, 0.3, 0, nil)
        
        local startX = ScrW() + ScreenScale(50)
        self.imagePanel:SetPos(startX, 0)
        self.imagePanel:MoveTo(ScrW() - ScrW() * 0.3, 0, 0.4, 0, nil)
    end)

    timer.Simple(0.15, function()
        if not IsValid(self) then return end
        local buttons = self.Buttons or {}
        for i, btn in ipairs(buttons) do
            timer.Simple(i * 0.06, function()
                if IsValid(btn) then
                    btn:AlphaTo(255, 0.15, 0, nil)

                    local origY = btn:GetY()
                    btn:SetY(origY + 15)
                    btn:MoveTo(origY, 0.15, 0, nil)
                end
            end)
        end
    end)
end

function PANEL:ShowAll()
    self:SetAlpha(255)
    if self.lDock then self.lDock:SetAlpha(255) end
    if self.imagePanel then 
        self.imagePanel:SetAlpha(200)
        self.imagePanel:SetPos(ScrW() - ScrW() * 0.3, 0)
    end
    
    for _, btn in ipairs(self.Buttons or {}) do
        btn:SetAlpha(255)
    end
end

function PANEL:First( ply )
end

local gradient_d = surface.GetTextureID("vgui/gradient-d")
local gradient_r = surface.GetTextureID("vgui/gradient-u")
local gradient_l = surface.GetTextureID("vgui/gradient-l")

local clr_1 = Color(151,0,0,35)
function PANEL:Paint(w,h)
    draw.RoundedBox( 0, 0, 0, w, h, self.ColorBG )
    hg.DrawBlur(self, 5)
    surface.SetDrawColor( self.ColorBG )
    surface.SetTexture( gradient_l )
    surface.DrawTexturedRect(0,0,w,h)
    surface.SetDrawColor( clr_1 )
    surface.SetTexture( gradient_d )
    surface.DrawTexturedRect(0,0,w,h)
end

function PANEL:AddSelect( pParent, strTitle, tbl )
    local id = #self.Buttons + 1
    self.Buttons[id] = vgui.Create( "DLabel", pParent )
    local btn = self.Buttons[id]
    btn:SetText( strTitle )
    btn:SetMouseInputEnabled( true )
    btn:SizeToContents()
    btn:SetFont( "ZC_MM_Buttons" )
    btn:SetTall( ScreenScale( 15 ) )
    btn:Dock(BOTTOM)
    btn:DockMargin(ScreenScale(15),ScreenScale(0.5),0,-2)
    btn.Func = tbl.Func
    btn.HoveredFunc = tbl.HoveredFunc
    local luaMenu = self 
    if tbl.CreatedFunc then tbl.CreatedFunc(btn, self, luaMenu) end
    btn.RColor = Color(225,225,225)
    function btn:DoClick()
        -- ,kz оптимизировать надо, но идёт ошибка(кэшировать бы luaMenu.panelparrent вместо вызова его каждый раз)
        if curent_panel == string.lower(strTitle) then
			for i = 1, 3 do
				surface.PlaySound("shitty/tap_release.wav")
			end
            luaMenu.panelparrent:AlphaTo(0,0.2,0,function()
                luaMenu.panelparrent:Remove()
                luaMenu.panelparrent = nil
                luaMenu.panelparrent = vgui.Create("DPanel", luaMenu)
                
                luaMenu.panelparrent:SetPos(some_coordinates_x, 0)
                luaMenu.panelparrent:SetSize(some_size_x, some_size_y)
                luaMenu.panelparrent.Paint = function(this, w, h) end
                --btn.Func(luaMenu,luaMenu.panelparrent)
                curent_panel = nil
            end)
            return 
        end
        some_size_x = luaMenu.panelparrent:GetWide()
        some_size_y = luaMenu.panelparrent:GetTall()
        some_coordinates_x = luaMenu.panelparrent:GetX()
        luaMenu.panelparrent:AlphaTo(0,0.2,0,function()
            luaMenu.panelparrent:Remove()
            luaMenu.panelparrent = nil
            luaMenu.panelparrent = vgui.Create("DPanel", luaMenu)
            
            luaMenu.panelparrent:SetPos(some_coordinates_x, 0)
            luaMenu.panelparrent:SetSize(some_size_x, some_size_y)
            luaMenu.panelparrent.Paint = function(this, w, h) end
            btn.Func(luaMenu,luaMenu.panelparrent)
            curent_panel = string.lower(strTitle)
        end)
		for i = 1, 3 do
			surface.PlaySound("shitty/tap_depress.wav")
		end
    end

    function btn:Think()
        self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, (self:IsHovered() or (IsValid(self:GetChild(0)) and self:GetChild(0):IsHovered()) or (IsValid(self:GetChild(0)) and IsValid(self:GetChild(0):GetChild(0)) and self:GetChild(0):GetChild(0):IsHovered())) and 1 or 0)

        local v = self.HoverLerp
        self:SetTextColor(self.RColor:Lerp(red_select, v))

        local targetText = (self:IsHovered()) and string.upper(strTitle) or strTitle
        local crw = self:GetText()

        if (crw ~= targetText) or (curent_panel == string.lower(strTitle)) then
            local ntxt = ""
            local will_text = (curent_panel == string.lower(strTitle) and not strTitle == 'Traitor Role') and '[ '..string.upper(strTitle)..' ]' or strTitle
            for i = 1, #will_text do
                local char = will_text:sub(i, i)
                if i <= math.ceil(#will_text * v) then
                    ntxt = ntxt .. string.upper(char)
                else
                    ntxt = ntxt .. char
                end
            end
			if self:GetText() ~= ntxt then
				surface.PlaySound("shitty/tap-resonant.wav")
			end
            self:SetText(ntxt)
        end
        self:SizeToContents()
    end
end

function PANEL:Close()
    if IsValid(self.imagePanel) then
        self.imagePanel:Remove()
    end
    self:AlphaTo( 0, 0.1, 0, function() 
        if IsValid(self) then 
            self:Remove() 
        end
    end)
    self:SetKeyboardInputEnabled(false)
    self:SetMouseInputEnabled(false)
end

vgui.Register( "ZMainMenu", PANEL, "ZFrame")

hook.Add("OnPauseMenuShow","OpenMainMenu",function()
    local run = hook.Run("OnShowZCityPause")
    if run != nil then
        return run
    end

    if MainMenu and IsValid(MainMenu) then
        MainMenu:Close()
        MainMenu = nil
        return false
    end

    MainMenu = vgui.Create("ZMainMenu")
    MainMenu:MakePopup()
    return false
end)
