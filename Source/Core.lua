local addonName, addonTable = ...
local LSM = LibStub("LibSharedMedia-3.0")

-- Constants
local CHECK_SPELL_ID = 150544 -- Summon Random Favorite Mount
local ATLAS_NAME = "Fyrakk-Flying-Icon"
local UPDATE_INTERVAL = 0.5   -- seconds
local MIN_SIZE = 20
local DEFAULT_SIZE = 64
local MAX_SIZE = 250

-- Default Settings
local defaults = {
    texture = "Fyrakk",
    size = DEFAULT_SIZE,
    point = "CENTER",
    relativePoint = nil,
    x = 0,
    y = 0,
}

addonTable.metadata = {
    TITLE = "Title",
    LOGO_PATH = "IconTexture",
    DESCRIPTION = "Notes"
}

-- Event Handling Frame
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- Initialize Database
        HoldYourHorsesDB = HoldYourHorsesDB or {}
        for k, v in pairs(defaults) do
            if HoldYourHorsesDB[k] == nil then
                HoldYourHorsesDB[k] = v
            end
        end
        addonTable.db = HoldYourHorsesDB
    elseif event == "PLAYER_LOGIN" then
        addonTable:OnInitialize()
    end
end)

function addonTable:OnInitialize()
    -- Fetch metadata
    for keyName, keyValue in pairs(self.metadata) do
        self.metadata[keyName] = C_AddOns.GetAddOnMetadata(addonName, keyValue) or keyValue
    end

    -- Register the logo texture as an option in LSM
    LSM:Register("background", "Hold Your Horses", self.metadata.LOGO_PATH)

    -- Initialize Components
    self:CreateFrame()

    -- Initialize Options Panel (if loaded)
    if self.CreateOptionsPanel then
        self:CreateOptionsPanel()
    end
end

function addonTable:UpdateTexture()
    if not self.texture or not self.db then return end

    local textureName = self.db.texture
    if textureName == "Fyrakk" then
        self.texture:SetAtlas(ATLAS_NAME, true)
    else
        local lsmTexture = LSM:Fetch("background", textureName)
        self.texture:SetTexture(lsmTexture)
        self.texture:SetTexCoord(0, 1, 0, 1)
    end
end

function addonTable:CreateFrame()
    self.frame = CreateFrame("Frame", "HoldYourHorsesFrame", UIParent)

    self.frame:SetSize(self.db.size, self.db.size)
    if self.db.point then
        self.frame:SetPoint(self.db.point, UIParent, self.db.relativePoint, self.db.x, self.db.y)
    else
        self.frame:SetPoint("CENTER")
    end
    self.frame:SetClampedToScreen(true)

    local texture = self.frame:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints(self.frame)
    self.texture = texture

    self:UpdateTexture()

    -- Repositioning
    self.frame:SetMovable(true)
    self.frame:EnableMouse(true)
    self.frame:RegisterForDrag("LeftButton")
    self.frame:SetScript("OnDragStart", function(f)
        if not InCombatLockdown() then
            f:StartMoving()
        end
    end)
    self.frame:SetScript("OnDragStop", function(f)
        f:StopMovingOrSizing()
        local point, _, relativePoint, x, y = f:GetPoint()
        self.db.point = point
        self.db.relativePoint = relativePoint
        self.db.x = x
        self.db.y = y
    end)

    -- Resizing
    self.frame:EnableMouseWheel(true)
    self.frame:SetScript("OnMouseWheel", function(f, delta)
        local currentSize = self.db.size
        if delta > 0 then currentSize = currentSize + 5 else currentSize = currentSize - 5 end
        currentSize = math.max(MIN_SIZE, math.min(MAX_SIZE, currentSize))

        f:SetSize(currentSize, currentSize)
        self.db.size = currentSize
    end)

    -- OnUpdate
    local timeSinceLastUpdate = 0
    self.frame:SetScript("OnUpdate", function(f, elapsed)
        timeSinceLastUpdate = timeSinceLastUpdate + elapsed
        if timeSinceLastUpdate > UPDATE_INTERVAL then
            if C_PetBattles and C_PetBattles.IsInBattle and C_PetBattles.IsInBattle() then
                f:SetAlpha(0)
            elseif C_Spell.IsSpellUsable(CHECK_SPELL_ID) and not InCombatLockdown() then
                f:SetAlpha(1)
                texture:SetDesaturated(false)
                texture:SetVertexColor(1, 1, 1, 1)
            else
                f:SetAlpha(1)
                texture:SetDesaturated(true)
                texture:SetVertexColor(0.6, 0.6, 0.6, 1)
            end
            timeSinceLastUpdate = 0
        end
    end)
end
