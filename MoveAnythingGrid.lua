-- MoveAnything grid extension for Azeroth Survivors (WoW-client-derived UI)
-- Uses Lua 5.0-compatible syntax.
local MAAS_GRID_SPACING = 24
local MAAS_GRID_ALPHA = 0.30
local MAAS_GRID_THICKNESS = 1.0
local MAAS_GridFrame
local MAAS_GridLines = {}

local function MAAS_ClearGridLines()
    local i
    for i = 1, table.getn(MAAS_GridLines), 1 do
        if MAAS_GridLines[i] then MAAS_GridLines[i]:Hide() end
    end
    MAAS_GridLines = {}
end

local function MAAS_AddGridLine(vertical, offset, width, height)
    local line = MAAS_GridFrame:CreateTexture(nil, "OVERLAY")
    line:SetTexture("Interface\\Buttons\\WHITE8X8")
    line:SetVertexColor(0.48, 0.72, 1.0, 1.0)
    line:SetAlpha(MAAS_GRID_ALPHA)
    if vertical then
        line:SetWidth(MAAS_GRID_THICKNESS)
        line:SetHeight(height)
        line:SetPoint("BOTTOMLEFT", MAAS_GridFrame, "BOTTOMLEFT", offset, 0)
    else
        line:SetWidth(width)
        line:SetHeight(MAAS_GRID_THICKNESS)
        line:SetPoint("BOTTOMLEFT", MAAS_GridFrame, "BOTTOMLEFT", 0, offset)
    end
    table.insert(MAAS_GridLines, line)
end

function MoveAnythingAS_RefreshGrid()
    if not MAAS_GridFrame or not UIParent then return end
    MAAS_ClearGridLines()
    -- Anchor the grid to UIParent, then place every line relative to the grid itself.
    -- This avoids the old partial-screen result caused by mixing coordinate parents.
    MAAS_GridFrame:ClearAllPoints()
    MAAS_GridFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
    -- Some WoW-derived clients expose UIParent smaller than the rendered viewport.
    local width = (GetScreenWidth and GetScreenWidth()) or UIParent:GetWidth() or 0
    local height = (GetScreenHeight and GetScreenHeight()) or UIParent:GetHeight() or 0
    if MAAS_GridFrame.SetWidth then MAAS_GridFrame:SetWidth(width) end
    if MAAS_GridFrame.SetHeight then MAAS_GridFrame:SetHeight(height) end
    local x = 0
    while x <= width do
        MAAS_AddGridLine(true, x, width, height)
        x = x + MAAS_GRID_SPACING
    end
    local y = 0
    while y <= height do
        MAAS_AddGridLine(false, y, width, height)
        y = y + MAAS_GRID_SPACING
    end
end

function MoveAnythingAS_ShowGrid()
    if not CreateFrame or not UIParent then return end
    if not MAAS_GridFrame then
        MAAS_GridFrame = CreateFrame("Frame", "MoveAnythingASGrid", UIParent)
        MAAS_GridFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
        if MAAS_GridFrame.SetWidth and GetScreenWidth then MAAS_GridFrame:SetWidth(GetScreenWidth()) end
        if MAAS_GridFrame.SetHeight and GetScreenHeight then MAAS_GridFrame:SetHeight(GetScreenHeight()) end
        if MAAS_GridFrame.SetFrameStrata then MAAS_GridFrame:SetFrameStrata("LOW") end
        if MAAS_GridFrame.SetFrameLevel then MAAS_GridFrame:SetFrameLevel(1) end
        if MAAS_GridFrame.EnableMouse then MAAS_GridFrame:EnableMouse(false) end
        if MAAS_GridFrame.SetScript then
            MAAS_GridFrame:SetScript("OnSizeChanged", function() MoveAnythingAS_RefreshGrid() end)
        end
    end
    MoveAnythingAS_RefreshGrid()
    MAAS_GridFrame:Show()
end

function MoveAnythingAS_HideGrid()
    if MAAS_GridFrame then MAAS_GridFrame:Hide() end
end

function MoveAnythingAS_ToggleGrid()
    if MAAS_GridFrame and MAAS_GridFrame:IsShown() then
        MAAS_GridFrame:Hide()
        if Print then Print("Move UI: grid hidden.") end
    else
        MoveAnythingAS_ShowGrid()
        if Print then Print("Move UI: grid shown (24-unit spacing).") end
    end
end

SLASH_MOVEANYTHINGGRID1 = "/movegrid"
SlashCmdList["MOVEANYTHINGGRID"] = function() MoveAnythingAS_ToggleGrid() end

-- /move FrameName already starts/stops the original addon's real mover.
-- Show the grid whenever the original mover is being activated.
local MAAS_OriginalToggleMove = MoveAnything_ToggleMove
if MAAS_OriginalToggleMove then
    MoveAnything_ToggleMove = function(moveFrameName)
        MAAS_OriginalToggleMove(moveFrameName)
        local isMoving = MoveAnything_FindMAFrame and MoveAnything_FindMAFrame(moveFrameName)
        if isMoving then
            MoveAnythingAS_ShowGrid()
        else
            local i, anyMoving = 1, false
            while i <= 20 do
                local mover = getglobal and getglobal("MoveAnything" .. i)
                if mover and mover.IsVisible and mover:IsVisible() then anyMoving = true end
                i = i + 1
            end
            if not anyMoving then MoveAnythingAS_HideGrid() end
        end
    end
end

-- Opening the original options window also exposes the grid for visual alignment.
local MAAS_OriginalToggleOptions = MoveAnything_ToggleOptionsMenu
if MAAS_OriginalToggleOptions then
    MoveAnything_ToggleOptionsMenu = function()
        MAAS_OriginalToggleOptions()
        if MAOptions and MAOptions.IsVisible and MAOptions:IsVisible() then
            MoveAnythingAS_ShowGrid()
        else
            MoveAnythingAS_HideGrid()
        end
    end
end
