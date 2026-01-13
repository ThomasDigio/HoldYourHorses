local addonName = ...
local AceAddon = LibStub("AceAddon-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

---@class HoldYourHorses: AceAddon
local HoldYourHorses = AceAddon:GetAddon(addonName)

HoldYourHorses.optionOrder = 0
HoldYourHorses.colour = "d79743"

function HoldYourHorses:IncrementAndFetchOptionOrder()
    self.optionOrder = self.optionOrder + 1
    return self.optionOrder
end

function HoldYourHorses:CreateSpacing()
    return {
        order = self:IncrementAndFetchOptionOrder(),
        type = "description",
        name = " ",
        width = "full",
    }
end

function HoldYourHorses:ColourText(text)
    return "|cff" .. self.colour .. text .. "|r"
end

function HoldYourHorses:CreateOptionsPanel()
    local options = {
        name = self.metadata.TITLE,
        handler = HoldYourHorses,
        type = "group",
        args = {
            aboutHeader = {
                order = self:IncrementAndFetchOptionOrder(),
                type = "header",
                name = "About",
            },
            aboutHeaderSpacing = self:CreateSpacing(),
            logoImage = {
                order = self:IncrementAndFetchOptionOrder(),
                type = "description",
                name = " ",
                width = 0.6,
                image = self.metadata.LOGO_PATH,
                imageWidth = 64,
                imageHeight = 64,
            },
            description = {
                order = self:IncrementAndFetchOptionOrder(),
                type = "description",
                name = self.metadata.DESCRIPTION,
                fontSize = "medium",
                width = 3,
            },
            configHeader = {
                order = self:IncrementAndFetchOptionOrder(),
                type = "header",
                name = "Config",
            },
            configHeaderSpacing = self:CreateSpacing(),
            repositioningText = {
                order = self:IncrementAndFetchOptionOrder(),
                type = "description",
                name =
                "You can move the icon by dragging it with the mouse and resize it with the mouse wheel. The position will be saved automatically!",
                fontSize = "medium",
                width = "full",
            },
            repositioningTextSpacing = self:CreateSpacing(),
            textureSelector = {
                order = self:IncrementAndFetchOptionOrder(),
                type = "select",
                name = "Texture",
                desc = "Choose the texture for the indicator",
                dialogControl = "LSM30_Background",
                values = function()
                    local t = CopyTable(LSM:HashTable("background"))
                    t["Fyrakk"] = "Fyrakk"
                    t["Hold Your Horses"] = "Hold Your Horses"
                    return t
                end,
                get = function(_) return self.db.global.texture end,
                set = function(_, value)
                    self.db.global.texture = value
                    self:UpdateTexture()
                end,
            },
        },
    }

    AceConfigRegistry:RegisterOptionsTable(addonName, options)
    AceConfigDialog:AddToBlizOptions(addonName, "Hold Your Horses")
end
