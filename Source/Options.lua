local addonName, addonTable = ...
local LSM = LibStub("LibSharedMedia-3.0")

function addonTable:CreateOptionsPanel()
    local panel = CreateFrame("Frame", addonName .. "OptionsPanel")

    local function CreateSectionHeader(parent, text, relativeTo, yOffset)
        local headerFrame = CreateFrame("Frame", nil, parent)
        headerFrame:SetHeight(20)
        headerFrame:SetPoint("TOP", relativeTo, "BOTTOM", 0, yOffset)
        headerFrame:SetPoint("LEFT", parent, "LEFT", 10, 0)
        headerFrame:SetPoint("RIGHT", parent, "RIGHT", -10, 0)

        local headerText = headerFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        headerText:SetText(text)
        headerText:SetTextColor(1, 0.82, 0) -- Gold color
        headerText:SetPoint("CENTER")

        local leftLine = headerFrame:CreateTexture(nil, "ARTWORK")
        leftLine:SetHeight(1)
        leftLine:SetColorTexture(0.25, 0.25, 0.25, 1) -- Dark grey
        -- Draw from frame left to text left
        leftLine:SetPoint("LEFT", headerFrame, "LEFT")
        leftLine:SetPoint("RIGHT", headerText, "LEFT", -5, 0)

        local rightLine = headerFrame:CreateTexture(nil, "ARTWORK")
        rightLine:SetHeight(1)
        rightLine:SetColorTexture(0.25, 0.25, 0.25, 1)
        -- Draw from text right to frame right
        rightLine:SetPoint("LEFT", headerText, "RIGHT", 5, 0)
        rightLine:SetPoint("RIGHT", headerFrame, "RIGHT")

        return headerFrame
    end

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 15, -15)
    title:SetText(self.metadata.TITLE)

    local aboutHeader = CreateSectionHeader(panel, "About", title, -20)
    local aboutLogo = panel:CreateTexture(nil, "ARTWORK")
    aboutLogo:SetSize(64, 64)
    aboutLogo:SetPoint("TOPLEFT", aboutHeader, "BOTTOMLEFT", 10, -15)
    aboutLogo:SetTexture(self.metadata.LOGO_PATH)
    local aboutDescription = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    aboutDescription:SetPoint("LEFT", aboutLogo, "RIGHT", 20, 0)
    aboutDescription:SetPoint("RIGHT", panel, "RIGHT", -20, 0)
    aboutDescription:SetPoint("TOP", aboutLogo, "TOP")
    aboutDescription:SetPoint("BOTTOM", aboutLogo, "BOTTOM")
    aboutDescription:SetJustifyH("LEFT")
    aboutDescription:SetJustifyV("MIDDLE")
    aboutDescription:SetText(self.metadata.DESCRIPTION)

    local configHeader = CreateSectionHeader(panel, "Config", aboutLogo, -30)
    local configText = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    configText:SetPoint("TOPLEFT", configHeader, "BOTTOMLEFT", 16, -15)
    configText:SetPoint("RIGHT", panel, "RIGHT", -16, 0)
    configText:SetJustifyH("LEFT")
    configText:SetText(
        "You can move the icon by dragging it with the mouse and resize it with the mouse wheel. The position will be saved automatically!")

    local dropDown = CreateFrame("Frame", addonName .. "TextureDropDown", panel, "UIDropDownMenuTemplate")
    dropDown:SetPoint("TOPLEFT", configText, "BOTTOMLEFT", -15, -20)
    local dropDownLabel = dropDown:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
    dropDownLabel:SetPoint("BOTTOMLEFT", dropDown, "TOPLEFT", 16, 3)
    dropDownLabel:SetText("Texture")
    dropDownLabel:SetTextColor(1, 0.82, 0)

    local function OnClick(self)
        UIDropDownMenu_SetSelectedValue(dropDown, self.value)
        addonTable.db.texture = self.value
        addonTable:UpdateTexture()
    end

    local function InitializeDropDown(self, level)
        local info = UIDropDownMenu_CreateInfo()

        -- Addon-specific
        info.text = "Fyrakk"
        info.value = "Fyrakk"
        info.func = OnClick
        info.checked = (addonTable.db.texture == "Fyrakk")
        UIDropDownMenu_AddButton(info, level)
        info.text = "Hold Your Horses"
        info.value = "Hold Your Horses"
        info.func = OnClick
        info.checked = (addonTable.db.texture == "Hold Your Horses")
        UIDropDownMenu_AddButton(info, level)

        -- SharedMedia
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

    -- Register with Blizzard settings
    local category = Settings.RegisterCanvasLayoutCategory(panel, "Hold Your Horses")
    Settings.RegisterAddOnCategory(category)
    addonTable.settingsCategory = category
end
