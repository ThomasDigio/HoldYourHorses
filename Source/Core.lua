local CHECK_SPELL_ID = 150544 -- Summon Random Favorite Mount
local ATLAS_NAME = "Fyrakk-Flying-Icon"

local UPDATE_INTERVAL = 0.5 -- seconds

local MIN_SIZE = 20
local DEFAULT_SIZE = 64
local MAX_SIZE = 250

-- Create the icon
local frame = CreateFrame("Frame", "HoldYourHorsesFrame", UIParent)
frame:SetSize(DEFAULT_SIZE, DEFAULT_SIZE)
frame:SetPoint("CENTER")
frame:SetClampedToScreen(true)
local texture = frame:CreateTexture(nil, "BACKGROUND")
texture:SetAllPoints(frame)
texture:SetAtlas(ATLAS_NAME, true)

-- Repositioning
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function(self)
    if not InCombatLockdown() then
        self:StartMoving()
    end
end)
frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relativePoint, x, y = self:GetPoint()
    HoldYourHorsesDB.point = point
    HoldYourHorsesDB.relativePoint = relativePoint
    HoldYourHorsesDB.x = x
    HoldYourHorsesDB.y = y
end)

-- Resizing
frame:EnableMouseWheel(true)
frame:SetScript("OnMouseWheel", function(self, delta)
    local currentSize = HoldYourHorsesDB.size or DEFAULT_SIZE

    if delta > 0 then
        currentSize = currentSize + 5
    else
        currentSize = currentSize - 5
    end

    if currentSize < MIN_SIZE then
        currentSize = MIN_SIZE
    end
    if currentSize > MAX_SIZE then
        currentSize = MAX_SIZE
    end

    self:SetSize(currentSize, currentSize)
    HoldYourHorsesDB.size = currentSize
end)

-- Restore on Login
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self)
    -- Initialize DB if it's the very first time loading
    if not HoldYourHorsesDB then
        HoldYourHorsesDB = {}
    end

    -- Restore Size
    if HoldYourHorsesDB.size then
        frame:SetSize(HoldYourHorsesDB.size, HoldYourHorsesDB.size)
    end

    -- Restore Position
    if HoldYourHorsesDB.point then
        frame:ClearAllPoints()
        frame:SetPoint(HoldYourHorsesDB.point, UIParent, HoldYourHorsesDB.relativePoint, HoldYourHorsesDB.x,
        HoldYourHorsesDB.y)
    end
end)

-- Can we mount?
local timeSinceLastUpdate = 0
frame:SetScript("OnUpdate", function(self, elapsed)
    timeSinceLastUpdate = timeSinceLastUpdate + elapsed

    if timeSinceLastUpdate > UPDATE_INTERVAL then
        if C_PetBattles and C_PetBattles.IsInBattle and C_PetBattles.IsInBattle() then
            self:SetAlpha(0)
        elseif C_Spell.IsSpellUsable(CHECK_SPELL_ID) and not InCombatLockdown() then
            self:SetAlpha(1)
            texture:SetDesaturated(false)
            texture:SetVertexColor(1, 1, 1, 1)
        else
            self:SetAlpha(1)
            texture:SetDesaturated(true)
            texture:SetVertexColor(0.6, 0.6, 0.6, 1)
        end

        timeSinceLastUpdate = 0
    end
end)
