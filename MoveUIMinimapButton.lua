-- Move UI minimap launcher
-- Saved-angle minimap button with round/square layout positioning and click/drag behavior.
-- Extracted from the tested 1.2.9 runtime; behavior intentionally preserved.

-- Shares the unified Add-on Tools panel exposed by MoveUIAddonTools.lua.
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

-- Build optional controls after the UI and minimap are available.
local MoveUIAddonToolsBootstrap = CreateFrame("Frame")
MoveUIAddonToolsBootstrap:RegisterEvent("PLAYER_LOGIN")
MoveUIAddonToolsBootstrap:SetScript("OnEvent", function()
    if MAOptions then MoveUI_CreateAddonTools() end
    MoveUI_CreateMinimapButton()
    MoveUIAddonToolsBootstrap:UnregisterEvent("PLAYER_LOGIN")
end)
