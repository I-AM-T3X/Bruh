local ADDON_NAME = ... -- bruh

-- Default configuration
local defaults = {
    trigger = "bruh",
    response = "bruh",
    enabled = true,
    cooldown = 10,
}

-- Saved variables (will be persisted between sessions)
BruhDB = BruhDB or CopyTable(defaults)

-- Create frame
local f = CreateFrame("Frame")

-- Register events
f:RegisterEvent("CHAT_MSG_RAID")
f:RegisterEvent("CHAT_MSG_GUILD")
f:RegisterEvent("CHAT_MSG_INSTANCE_CHAT")
f:RegisterEvent("ADDON_LOADED")

-- Map incoming events to outgoing chat types
local RESPONSE_BY_EVENT = {
    CHAT_MSG_RAID = "RAID",
    CHAT_MSG_GUILD = "GUILD",
    CHAT_MSG_INSTANCE_CHAT = "INSTANCE_CHAT",
}

-- Cooldown tracking
local lastTrigger = 0

-- Event handler
f:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        -- Initialize saved variables
        if not BruhDB then
            BruhDB = CopyTable(defaults)
        end
        -- Ensure all fields exist (for upgrades)
        for k, v in pairs(defaults) do
            if BruhDB[k] == nil then
                BruhDB[k] = v
            end
        end
        print("|cff00ffffBruh|r addon loaded. Type |cffFFFF00/bruh|r to toggle or open settings.")
        return
    end

    -- Chat message handling
    if not BruhDB.enabled or not arg1 then return end

    -- During boss encounters / Mythic+ runs (Patch 12.0 "Midnight"), Blizzard
    -- marks chat message text as a "secret value" that addons are not allowed
    -- to read (string methods like :lower()/:find() will error). There's no
    -- way around this by design, so just skip processing in that case.
    if issecretvalue and issecretvalue(arg1) then return end

    local message = arg1:lower()
    local trigger = BruhDB.trigger:lower()
    
    if not message:find(trigger, 1, true) then
        return
    end

    local now = GetTime()
    if now - lastTrigger < BruhDB.cooldown then return end
    lastTrigger = now

    local chatType = RESPONSE_BY_EVENT[event]
    if chatType then
        C_ChatInfo.SendChatMessage(BruhDB.response, chatType)
    end
end)

-- Settings Panel
local panel = CreateFrame("Frame", "BruhSettingsPanel")
panel.name = "Bruh"

-- Title
local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Bruh Settings")

-- Description
local desc = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
desc:SetText("Configure automatic chat responses for raid, guild, and instance chat.")

-- Enable/Disable checkbox
local enableCheck = CreateFrame("CheckButton", "BruhEnableCheck", panel, "InterfaceOptionsCheckButtonTemplate")
enableCheck:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -20)
enableCheck.Text:SetText("Enable Bruh")
enableCheck:SetChecked(BruhDB.enabled)
enableCheck:SetScript("OnClick", function(self)
    BruhDB.enabled = self:GetChecked()
    if BruhDB.enabled then
        print("|cff00ff00Bruh enabled|r")
    else
        print("|cffff0000Bruh disabled|r")
    end
end)

-- Separator line
local separator1 = panel:CreateTexture(nil, "ARTWORK")
separator1:SetPoint("TOPLEFT", enableCheck, "BOTTOMLEFT", 0, -16)
separator1:SetSize(400, 1)
separator1:SetColorTexture(0.25, 0.25, 0.25, 1)

-- Trigger phrase label
local triggerLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
triggerLabel:SetPoint("TOPLEFT", separator1, "BOTTOMLEFT", 0, -20)
triggerLabel:SetText("Trigger Phrase:")

-- Trigger phrase input
local triggerInput = CreateFrame("EditBox", "BruhTriggerInput", panel, "InputBoxTemplate")
triggerInput:SetPoint("TOPLEFT", triggerLabel, "BOTTOMLEFT", 4, -8)
triggerInput:SetSize(300, 20)
triggerInput:SetAutoFocus(false)
triggerInput:SetText(BruhDB.trigger)
triggerInput:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
triggerInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

local triggerHint = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
triggerHint:SetPoint("TOPLEFT", triggerInput, "BOTTOMLEFT", -4, -4)
triggerHint:SetText("The word or phrase that will trigger the response")
triggerHint:SetTextColor(0.6, 0.6, 0.6)

-- Response phrase label
local responseLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
responseLabel:SetPoint("TOPLEFT", triggerHint, "BOTTOMLEFT", 0, -20)
responseLabel:SetText("Response Phrase:")

-- Response phrase input
local responseInput = CreateFrame("EditBox", "BruhResponseInput", panel, "InputBoxTemplate")
responseInput:SetPoint("TOPLEFT", responseLabel, "BOTTOMLEFT", 4, -8)
responseInput:SetSize(300, 20)
responseInput:SetAutoFocus(false)
responseInput:SetText(BruhDB.response)
responseInput:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
responseInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

local responseHint = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
responseHint:SetPoint("TOPLEFT", responseInput, "BOTTOMLEFT", -4, -4)
responseHint:SetText("The message that will be sent in response")
responseHint:SetTextColor(0.6, 0.6, 0.6)

-- Separator line
local separator2 = panel:CreateTexture(nil, "ARTWORK")
separator2:SetPoint("TOPLEFT", responseHint, "BOTTOMLEFT", 0, -16)
separator2:SetSize(400, 1)
separator2:SetColorTexture(0.25, 0.25, 0.25, 1)

-- Cooldown label
local cooldownLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
cooldownLabel:SetPoint("TOPLEFT", separator2, "BOTTOMLEFT", 0, -20)
cooldownLabel:SetText("Cooldown:")

-- Cooldown dropdown
local cooldownDropdown = CreateFrame("Frame", "BruhCooldownDropdown", panel, "UIDropDownMenuTemplate")
cooldownDropdown:SetPoint("TOPLEFT", cooldownLabel, "BOTTOMLEFT", -16, -4)

-- Cooldown options
local cooldownOptions = {
    {text = "10 seconds", value = 10},
    {text = "30 seconds", value = 30},
    {text = "60 seconds", value = 60},
    {text = "120 seconds", value = 120},
}

-- Initialize dropdown
UIDropDownMenu_SetWidth(cooldownDropdown, 150)
UIDropDownMenu_Initialize(cooldownDropdown, function(self, level)
    for _, option in ipairs(cooldownOptions) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = option.text
        info.value = option.value
        info.func = function(self)
            BruhDB.cooldown = self.value
            UIDropDownMenu_SetText(cooldownDropdown, self:GetText())
        end
        info.checked = (BruhDB.cooldown == option.value)
        UIDropDownMenu_AddButton(info)
    end
end)

-- Set initial text
for _, option in ipairs(cooldownOptions) do
    if option.value == BruhDB.cooldown then
        UIDropDownMenu_SetText(cooldownDropdown, option.text)
        break
    end
end

local cooldownHint = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
cooldownHint:SetPoint("TOPLEFT", cooldownDropdown, "BOTTOMLEFT", 16, 4)
cooldownHint:SetText("Prevents spam by limiting how often responses are sent")
cooldownHint:SetTextColor(0.6, 0.6, 0.6)

-- Save button
local saveButton = CreateFrame("Button", "BruhSaveButton", panel, "UIPanelButtonTemplate")
saveButton:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 16, 16)
saveButton:SetSize(120, 25)
saveButton:SetText("Save Changes")
saveButton:SetScript("OnClick", function()
    BruhDB.trigger = triggerInput:GetText()
    BruhDB.response = responseInput:GetText()
    -- Cooldown is already saved when dropdown selection changes
    print("|cff00ffffBruh:|r Settings saved!")
end)

-- Reset button
local resetButton = CreateFrame("Button", "BruhResetButton", panel, "UIPanelButtonTemplate")
resetButton:SetPoint("LEFT", saveButton, "RIGHT", 8, 0)
resetButton:SetSize(120, 25)
resetButton:SetText("Reset to Defaults")
resetButton:SetScript("OnClick", function()
    BruhDB = CopyTable(defaults)
    enableCheck:SetChecked(BruhDB.enabled)
    triggerInput:SetText(BruhDB.trigger)
    responseInput:SetText(BruhDB.response)
    -- Reset dropdown text
    for _, option in ipairs(cooldownOptions) do
        if option.value == BruhDB.cooldown then
            UIDropDownMenu_SetText(cooldownDropdown, option.text)
            break
        end
    end
    print("|cff00ffffBruh:|r Settings reset to defaults!")
end)

-- Register settings panel
local category = Settings.RegisterCanvasLayoutCategory(panel, "Bruh")
Settings.RegisterAddOnCategory(category)

-- Slash commands
SLASH_BRUH1 = "/bruh"
SlashCmdList.BRUH = function(msg)
    msg = msg:lower():trim()
    
    if msg == "" or msg == "toggle" then
        BruhDB.enabled = not BruhDB.enabled
        if BruhDB.enabled then
            print("|cff00ff00Bruh enabled|r")
        else
            print("|cffff0000Bruh disabled|r")
        end
    elseif msg == "settings" or msg == "config" then
        Settings.OpenToCategory("Bruh")
    else
        print("|cff00ffffBruh Commands:|r")
        print("  |cffFFFF00/bruh|r - Toggle on/off")
        print("  |cffFFFF00/bruh settings|r - Open settings panel")
    end
end
