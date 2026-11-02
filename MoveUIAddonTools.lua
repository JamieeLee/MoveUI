-- Move UI add-on shortcuts for Azeroth Survivors.
-- BigCursor is a cursor utility, not a movable UI frame. Keep it out of the
-- mover list and expose its own controls here without duplicating its settings.
-- LocalClock remains independently managed by its existing frame registration.

local addonToolsFrame
local addonToolsStatus
local bigCursorStatus
local bigCursorToggle
local bigCursorSettings
local localClockStatus
local localClockOptions
local localClockTools

local function HasAddonCommand(name)
    return type(SlashCmdList) == "table"
        and type(SlashCmdList[name]) == "function"
end

local function RunAddonCommand(name, message)
    if not HasAddonCommand(name) then return false end
    local ok = pcall(SlashCmdList[name], message or "")
    return ok
end

local function SetButtonAvailable(button, available)
    if not button then return end
    if available then
        if button.Enable then button:Enable() end
    else
        if button.Disable then button:Disable() end
    end
end

local function UpdateAddonTools()
    local bigCursorAvailable = HasAddonCommand("BIGCURSOR")
    if bigCursorAvailable then
        local enabled = true
        local size = 46
        if type(BigCursorDB) == "table" then
            if BigCursorDB.enabled == false then enabled = false end
            size = tonumber(BigCursorDB.size) or size
        end
        if bigCursorStatus then
            local state = "Enabled"
            if not enabled then state = "Disabled" end
            bigCursorStatus:SetText("Status: " .. state .. "  |  " .. tostring(size) .. " px")
        end
        if bigCursorToggle then
            if enabled then
                bigCursorToggle:SetText("Disable")
            else
                bigCursorToggle:SetText("Enable")
            end
        end
    elseif bigCursorStatus then
        bigCursorStatus:SetText("Status: Not loaded")
    end
    SetButtonAvailable(bigCursorToggle, bigCursorAvailable)
    SetButtonAvailable(bigCursorSettings, bigCursorAvailable)

    local localClockAvailable = HasAddonCommand("LOCALCLOCK")
    if localClockStatus then
        if localClockAvailable then
            localClockStatus:SetText("Clock display is managed in the frame list.")
        else
            localClockStatus:SetText("Status: LocalClock not loaded")
        end
    end
    SetButtonAvailable(localClockOptions, localClockAvailable)
    SetButtonAvailable(localClockTools, localClockAvailable)

    if addonToolsStatus then
        if bigCursorAvailable and localClockAvailable then
            addonToolsStatus:SetText("BigCursor and LocalClock are available.")
        elseif bigCursorAvailable then
            addonToolsStatus:SetText("BigCursor is available. LocalClock is not loaded.")
        elseif localClockAvailable then
            addonToolsStatus:SetText("LocalClock is available. BigCursor is not loaded.")
        else
            addonToolsStatus:SetText("Enable BigCursor or LocalClock to use these shortcuts.")
        end
    end
end

local function CreateToolsButton(parent, name, label, width, point, relative, relativePoint, x, y, onClick)
    local button = CreateFrame("Button", name, parent, "GameMenuButtonTemplate")
    button:SetWidth(width)
    button:SetHeight(22)
    button:SetPoint(point, relative, relativePoint, x, y)
    button:SetText(label)
    local text = button:GetFontString()
    if text and text.SetJustifyH then text:SetJustifyH("CENTER") end
    button:SetScript("OnClick", onClick)
    button:Show()
    return button
end

local function CreateAddonToolsPanel()
    if addonToolsFrame then return end

    local panel = CreateFrame("Frame", "MoveUIAddonToolsFrame", UIParent)
    addonToolsFrame = panel
    panel:SetWidth(270)
    panel:SetHeight(214)
    panel:SetFrameStrata("DIALOG")
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    if panel.SetClampedToScreen then panel:SetClampedToScreen(true) end
    if panel.SetBackdrop then
        panel:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        panel:SetBackdropColor(0.05, 0.05, 0.05, 0.96)
        panel:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    end
    if UISpecialFrames then table.insert(UISpecialFrames, "MoveUIAddonToolsFrame") end
    panel:SetScript("OnDragStart", function() panel:StartMoving() end)
    panel:SetScript("OnDragStop", function() panel:StopMovingOrSizing() end)

    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -10)
    title:SetText("Move UI - Add-on Tools")

    CreateToolsButton(panel, "MoveUIAddonToolsClose", "X", 22,
        "TOPRIGHT", panel, "TOPRIGHT", -8, -7, function()
            panel:Hide()
        end)

    local bigCursorTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    bigCursorTitle:SetPoint("TOPLEFT", panel, "TOPLEFT", 14, -38)
    bigCursorTitle:SetText("BigCursor")

    bigCursorStatus = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bigCursorStatus:SetPoint("TOPLEFT", panel, "TOPLEFT", 14, -56)
    bigCursorStatus:SetWidth(240)
    bigCursorStatus:SetJustifyH("LEFT")

    bigCursorToggle = CreateToolsButton(panel, "MoveUIBigCursorToggle", "Enable", 88,
        "TOPLEFT", panel, "TOPLEFT", 12, -70, function()
            if not HasAddonCommand("BIGCURSOR") then
                UpdateAddonTools()
                return
            end
            local enabled = type(BigCursorDB) ~= "table" or BigCursorDB.enabled ~= false
            if enabled then
                RunAddonCommand("BIGCURSOR", "off")
            else
                RunAddonCommand("BIGCURSOR", "on")
            end
            UpdateAddonTools()
        end)

    bigCursorSettings = CreateToolsButton(panel, "MoveUIBigCursorSettings", "Settings", 88,
        "LEFT", bigCursorToggle, "RIGHT", 8, 0, function()
            if RunAddonCommand("BIGCURSOR", "menu") then panel:Hide() end
        end)

    local divider = panel:CreateTexture(nil, "ARTWORK")
    divider:SetTexture("Interface\\Buttons\\WHITE8X8")
    divider:SetVertexColor(0.45, 0.45, 0.45, 0.8)
    divider:SetHeight(1)
    divider:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -105)
    divider:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -12, -105)

    local localClockTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    localClockTitle:SetPoint("TOPLEFT", panel, "TOPLEFT", 14, -119)
    localClockTitle:SetText("LocalClock")

    localClockStatus = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    localClockStatus:SetPoint("TOPLEFT", panel, "TOPLEFT", 14, -137)
    localClockStatus:SetWidth(240)
    localClockStatus:SetJustifyH("LEFT")

    localClockOptions = CreateToolsButton(panel, "MoveUILocalClockOptions", "Options", 88,
        "TOPLEFT", panel, "TOPLEFT", 12, -151, function()
            if RunAddonCommand("LOCALCLOCK", "options") then panel:Hide() end
        end)

    localClockTools = CreateToolsButton(panel, "MoveUILocalClockTools", "Clock Tools", 88,
        "LEFT", localClockOptions, "RIGHT", 8, 0, function()
            if RunAddonCommand("LOCALCLOCK", "tools") then panel:Hide() end
        end)

    addonToolsStatus = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    addonToolsStatus:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 14, 12)
    addonToolsStatus:SetWidth(240)
    addonToolsStatus:SetJustifyH("LEFT")
    addonToolsStatus:SetText("")

    panel:SetScript("OnShow", UpdateAddonTools)
    panel:Hide()
end

function MoveUI_CreateAddonTools()
    if not MAOptions or not CreateFrame then return end
    if not MoveUIAddonToolsButton then
        local button = CreateFrame("Button", "MoveUIAddonToolsButton", MAOptions, "GameMenuButtonTemplate")
        MoveUIAddonToolsButton = button
        button:SetWidth(92)
        button:SetHeight(22)
        button:SetPoint("TOPRIGHT", MAOptions, "TOPRIGHT", -22, -18)
        button:SetText("Add-on Tools")
        local text = button:GetFontString()
        if text and text.SetJustifyH then text:SetJustifyH("CENTER") end
        button:SetScript("OnClick", function()
            CreateAddonToolsPanel()
            if addonToolsFrame:IsShown() then
                addonToolsFrame:Hide()
            else
                addonToolsFrame:ClearAllPoints()
                addonToolsFrame:SetPoint("TOPLEFT", MAOptions, "TOPRIGHT", 6, -42)
                UpdateAddonTools()
                addonToolsFrame:Show()
            end
        end)
        button:Show()
    end
end


local function MoveUI_ToggleAddonTools(anchorToMinimap)
    CreateAddonToolsPanel()
    if not addonToolsFrame then return end

    if addonToolsFrame:IsShown() then
        addonToolsFrame:Hide()
        return
    end

    addonToolsFrame:ClearAllPoints()
    if anchorToMinimap and Minimap then
        addonToolsFrame:SetPoint("TOPRIGHT", Minimap, "BOTTOMLEFT", -8, -8)
    elseif MAOptions and MAOptions:IsShown() then
        addonToolsFrame:SetPoint("TOPLEFT", MAOptions, "TOPRIGHT", 6, -42)
    else
        addonToolsFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
    UpdateAddonTools()
    addonToolsFrame:Show()
end

-- Move UI uses the same classic minimap-ring and angle-based drag model as
-- BigCursor and LocalClock. Its position is saved independently.
local function MoveUI_IsSquareMinimap()
    if not IsAddOnLoaded then return false end
    local ok, loaded = pcall(IsAddOnLoaded, "SurvivorsDragonUi")
    return ok and loaded and true or false
end

local function MoveUI_UpdateMinimapButtonPosition()
    if not MoveUIMinimapButton or not Minimap then return end
    if type(MoveUIDB) ~= "table" then MoveUIDB = {} end
    local angle = tonumber(MoveUIDB.minimapButtonAngle) or 315
    local radians = math.rad(angle)
    local c, s = math.cos(radians), math.sin(radians)
    local half = (Minimap:GetWidth() or 140) / 2
    local x, y

    if MoveUI_IsSquareMinimap() then
        local radius = half + 6
        local divisor = math.max(math.abs(c), math.abs(s))
        if divisor <= 0 then return end
        x, y = c * radius / divisor, s * radius / divisor
    else
        local radius = half + 10
        x, y = c * radius, s * radius
    end

    MoveUIMinimapButton:ClearAllPoints()
    MoveUIMinimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function MoveUI_SaveMinimapButtonAngle()
    if not MoveUIMinimapButton or not Minimap then return end
    local centerX, centerY = Minimap:GetCenter()
    local buttonX, buttonY = MoveUIMinimapButton:GetCenter()
    if not centerX or not centerY or not buttonX or not buttonY then return end

    local atan2 = math.atan2 or math.atan
    local angle = math.deg(atan2(buttonY - centerY, buttonX - centerX))
    if angle < 0 then angle = angle + 360 end
    if type(MoveUIDB) ~= "table" then MoveUIDB = {} end
    MoveUIDB.minimapButtonAngle = angle
    MoveUI_UpdateMinimapButtonPosition()
end

function MoveUI_CreateMinimapButton()
    if not CreateFrame or not Minimap or MoveUIMinimapButton then return end
    if type(MoveUIDB) ~= "table" then MoveUIDB = {} end
    if type(MoveUIDB.minimapButtonAngle) ~= "number" then
        MoveUIDB.minimapButtonAngle = 315
    end

    local button = CreateFrame("Button", "MoveUIMinimapButton", Minimap)
    MoveUIMinimapButton = button
    button:SetWidth(31)
    button:SetHeight(31)
    button:SetFrameStrata("MEDIUM")
    if Minimap.GetFrameLevel then button:SetFrameLevel(Minimap:GetFrameLevel() + 8) end
    button:EnableMouse(true)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")

    local label = button:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    label:SetWidth(25)
    label:SetHeight(16)
    label:SetPoint("CENTER", button, "CENTER", 0, 1)
    label:SetText("MU")
    label:SetTextColor(1, 0.82, 0.05, 1)

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetWidth(53)
    border:SetHeight(53)
    border:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)

    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    button:SetScript("OnEnter", function()
        if not GameTooltip then return end
        GameTooltip:SetOwner(button, "ANCHOR_LEFT")
        GameTooltip:SetText("Move UI")
        GameTooltip:AddLine("Left-click: Open Move UI", 1, 1, 1)
        GameTooltip:AddLine("Right-click: Add-on Tools", 1, 1, 1)
        GameTooltip:AddLine("Drag: Move around the minimap", 0.75, 0.75, 0.75)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        if GameTooltip then GameTooltip:Hide() end
    end)
    button:SetScript("OnMouseDown", function()
        if not button.isDragging then button.draggedForClick = nil end
    end)
    button:SetScript("OnClick", function()
        if button.draggedForClick then
            button.draggedForClick = nil
            return
        end
        if arg1 == "RightButton" then
            MoveUI_ToggleAddonTools(true)
        elseif arg1 == "LeftButton" then
            if MoveAnything_ToggleOptionsMenu then
                MoveAnything_ToggleOptionsMenu()
            elseif MAOptions then
                MAOptions:Show()
            end
        end
    end)
    button:SetScript("OnDragStart", function()
        if not button.isDragging then
            if GameTooltip then GameTooltip:Hide() end
            button.isDragging = true
            button.draggedForClick = true
        end
    end)
    button:SetScript("OnUpdate", function()
        if not button.isDragging then return end
        local cursorX, cursorY = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        local centerX, centerY = Minimap:GetCenter()
        if not cursorX or not cursorY or not scale or scale <= 0 or not centerX or not centerY then
            return
        end
        local dx = cursorX / scale - centerX
        local dy = cursorY / scale - centerY
        if dx == 0 and dy == 0 then return end
        local atan2 = math.atan2 or math.atan
        local angle = math.deg(atan2(dy, dx))
        if angle < 0 then angle = angle + 360 end
        MoveUIDB.minimapButtonAngle = angle
        MoveUI_UpdateMinimapButtonPosition()
    end)
    button:SetScript("OnDragStop", function()
        if button.isDragging then
            button.isDragging = nil
            MoveUI_SaveMinimapButtonAngle()
        end
    end)
    button:SetScript("OnHide", function()
        button.isDragging = nil
    end)

    MoveUI_UpdateMinimapButtonPosition()
    button:Show()
end

-- When Move UI is present, its combined Add-on Tools panel replaces the
-- standalone BigCursor and LocalClock minimap bubbles. Their own addon files
-- are unchanged, so they retain their normal bubbles when used without Move UI.
local function MoveUI_HideStandaloneMinimapButtons()
    local names = { "BigCursorMinimapButton", "LocalClockMinimapButton" }
    for i = 1, table.getn(names) do
        local button = getglobal and getglobal(names[i])
        if button then
            if button.SetAlpha then button:SetAlpha(0) end
            if button.EnableMouse then button:EnableMouse(false) end
            if button.IsShown and button:IsShown() then button:Hide() end
        end
    end
end

local MoveUIBubbleIntegrationWatcher = CreateFrame("Frame")
local MoveUIBubbleIntegrationElapsed = 0
MoveUIBubbleIntegrationWatcher:SetScript("OnUpdate", function()
    MoveUIBubbleIntegrationElapsed = MoveUIBubbleIntegrationElapsed + (arg1 or 0)
    if MoveUIBubbleIntegrationElapsed < 0.15 then return end
    MoveUIBubbleIntegrationElapsed = 0
    MoveUI_HideStandaloneMinimapButtons()
end)

SLASH_MOVEUITOOLS1 = "/movetools"
SlashCmdList["MOVEUITOOLS"] = function()
    MoveUI_ToggleAddonTools(false)
end

-- The XML creates MAOptions after its embedded scripts are read. Wait until
-- PLAYER_LOGIN, when the complete UI tree and minimap are available, before
-- attaching our optional controls. This keeps the core Move UI load path intact.
local MoveUIAddonToolsBootstrap = CreateFrame("Frame")
MoveUIAddonToolsBootstrap:RegisterEvent("PLAYER_LOGIN")
MoveUIAddonToolsBootstrap:SetScript("OnEvent", function()
    if MAOptions then MoveUI_CreateAddonTools() end
    MoveUI_CreateMinimapButton()
    MoveUIAddonToolsBootstrap:UnregisterEvent("PLAYER_LOGIN")
end)

