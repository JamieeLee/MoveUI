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
