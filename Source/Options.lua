local addonName, addonTable = ...
local LSM = LibStub("LibSharedMedia-3.0")

function addonTable:CreateOptionsPanel()
    -- Create the main panel frame
    local panel = CreateFrame("Frame", addonName .. "OptionsPanel")
    panel.name = "Hold Your Horses"

    -- Title
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText(self.metadata.TITLE)

    -- Logo
    local logo = panel:CreateTexture(nil, "ARTWORK")
    logo:SetSize(64, 64)
    logo:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -16)
    logo:SetTexture(self.metadata.LOGO_PATH)

    -- About Description
    local desc = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    desc:SetPoint("TOPLEFT", logo, "TOPRIGHT", 16, 0)
    desc:SetPoint("RIGHT", -16, 0)
    desc:SetText(self.metadata.DESCRIPTION)
    desc:SetJustifyH("LEFT")

    -- Config Header
    local configHeader = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    configHeader:SetPoint("TOPLEFT", logo, "BOTTOMLEFT", 0, -20)
    configHeader:SetText("Config")

    -- Repositioning Text
    local repoText = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    repoText:SetPoint("TOPLEFT", configHeader, "BOTTOMLEFT", 0, -10)
    repoText:SetWidth(600)
    repoText:SetJustifyH("LEFT")
    repoText:SetText(
    "You can move the icon by dragging it with the mouse and resize it with the mouse wheel. The position will be saved automatically!")

    -- Texture Selector Dropdown
    local dropDown = CreateFrame("Frame", addonName .. "TextureDropDown", panel, "UIDropDownMenuTemplate")
    dropDown:SetPoint("TOPLEFT", repoText, "BOTTOMLEFT", -15, -20)

    local dropDownLabel = dropDown:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
    dropDownLabel:SetPoint("BOTTOMLEFT", dropDown, "TOPLEFT", 16, 3)
    dropDownLabel:SetText("Texture")

    local function OnClick(self)
        UIDropDownMenu_SetSelectedValue(dropDown, self.value)
        addonTable.db.texture = self.value
        addonTable:UpdateTexture()
    end

    local function InitializeDropDown(self, level)
        local info = UIDropDownMenu_CreateInfo()

        -- Add special Fyrakk option
        info.text = "Fyrakk"
        info.value = "Fyrakk"
        info.func = OnClick
        info.checked = (addonTable.db.texture == "Fyrakk")
        UIDropDownMenu_AddButton(info, level)

        -- Add custom option
        info.text = "Hold Your Horses"
        info.value = "Hold Your Horses"
        info.func = OnClick
        info.checked = (addonTable.db.texture == "Hold Your Horses")
        UIDropDownMenu_AddButton(info, level)

        -- Add LSM Backgrounds
        local backgrounds = LSM:HashTable("background")
        local sortedKeys = {}
        for k in pairs(backgrounds) do table.insert(sortedKeys, k) end
        table.sort(sortedKeys)

        for _, key in ipairs(sortedKeys) do
            if key ~= "Hold Your Horses" then
                info.text = key
                info.value = key
                info.func = OnClick
                info.checked = (addonTable.db.texture == key)
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end

    UIDropDownMenu_Initialize(dropDown, InitializeDropDown)
    UIDropDownMenu_SetWidth(dropDown, 200)
    UIDropDownMenu_SetSelectedValue(dropDown, addonTable.db.texture or "Fyrakk")
    UIDropDownMenu_SetText(dropDown, addonTable.db.texture or "Fyrakk")

    -- Register with Blizzard Settings (Modern API)
    if Settings and Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, "Hold Your Horses")
        Settings.RegisterAddOnCategory(category)
        addonTable.settingsCategory = category
    else
        -- Fallback for older clients
        InterfaceOptions_AddCategory(panel)
    end
end
