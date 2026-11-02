-- Move UI optional addon integration
-- Suppresses duplicate standalone BigCursor and LocalClock minimap bubbles while Move UI is active.
-- Extracted from the tested 1.2.9 runtime; behavior intentionally preserved.

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
