local ADDON_NAME = ... -- bruh

-- Configuration
local TRIGGER_WORD = "bruh"
local RESPONSE_MESSAGE = "bruh"

-- Map incoming events to outgoing chat types
local RESPONSE_BY_EVENT = {
    CHAT_MSG_RAID  = "RAID",
    CHAT_MSG_GUILD = "GUILD",
    CHAT_MSG_INSTANCE_CHAT = "INSTANCE_CHAT",
}

-- Create frame
local f = CreateFrame("Frame")

-- Register events
f:RegisterEvent("CHAT_MSG_RAID")
f:RegisterEvent("CHAT_MSG_GUILD")
f:RegisterEvent("CHAT_MSG_INSTANCE_CHAT")

-- Cooldown to prevent spam (10s)
local lastTrigger = 0
local COOLDOWN = 10

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
        -- Modern API call
        C_ChatInfo.SendChatMessage(RESPONSE_MESSAGE, chatType)
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
