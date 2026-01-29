local ADDON_NAME = ... -- bruh

-- Configuration
local TRIGGER_WORD = "bruh"
local RESPONSE_MESSAGE = "bruh"

-- Map incoming events to outgoing chat types
local RESPONSE_BY_EVENT = {
    CHAT_MSG_SAY   = "SAY",
    CHAT_MSG_RAID  = "RAID",
    CHAT_MSG_GUILD = "GUILD",
}

-- Create frame
local f = CreateFrame("Frame")

-- Register events
f:RegisterEvent("CHAT_MSG_SAY")
f:RegisterEvent("CHAT_MSG_RAID")
f:RegisterEvent("CHAT_MSG_GUILD")

-- Cooldown to prevent spam (2s, matches WeakAura)
local lastTrigger = 0
local COOLDOWN = 30

local enabled = true

f:SetScript("OnEvent", function(_, event, message)
    if not enabled or not message then return end

    if not message:lower():find(TRIGGER_WORD, 1, true) then
        return
    end

    local now = GetTime()
    if now - lastTrigger < COOLDOWN then return end
    lastTrigger = now

    local chatType = RESPONSE_BY_EVENT[event]
    if chatType then
        SendChatMessage(RESPONSE_MESSAGE, chatType)
    end
end)

-- Slash command: /bruh
SLASH_BRUH1 = "/bruh"
SlashCmdList.BRUH = function()
    enabled = not enabled
    if enabled then
        print("|cff00ff00bruh enabled|r")
    else
        print("|cffff0000bruh disabled|r")
    end
end
