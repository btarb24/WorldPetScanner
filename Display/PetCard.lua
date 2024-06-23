---@class PetCollector
local PETC = PetCollector
local DISPLAY = PETC.DISPLAY
local UTILITIES = PETC.UTILITIES
local PETS = PETC.PETS

local function AcquireMapTileTexture(parent)
    if (not parent.mapTilePool) then
        parent.mapTilePool = CreateTexturePool(parent, "BACKGROUND")
        table.insert(PAPetCard.pools, parent.mapTilePool)
    end

    local t = parent.mapTilePool:Acquire()
    t:Show()
    return t
end
local function AcquireMapPinTexture(parent)
    if (not parent.mapPinPool) then
        parent.mapPinPool = CreateTexturePool(parent, "OVERLAY")
        table.insert(PAPetCard.pools, parent.mapPinPool)
    end

    local t = parent.mapPinPool:Acquire()
    t:Show()
    return t
end
local function AcquireLabelFont(parent)    
    if (not parent.labelFontPool) then
        parent.labelFontPool = CreateFontStringPool(parent, "OVERLAY", nil, "GameFontNormal")
        table.insert(PAPetCard.pools, parent.labelFontPool)
    end

    local t = parent.labelFontPool:Acquire()
    t:Show()
    return t
end
local function AcquireMultiValueFont(parent)    
    if (not parent.multiValueFontPool) then
        parent.multiValueFontPool = CreateFontStringPool(parent, "OVERLAY", nil, "GameFontHighlight")
        table.insert(PAPetCard.pools, parent.multiValueFontPool)
    end

    local t = parent.multiValueFontPool:Acquire()
    t:SetTextColor(.7, .7, .7)
    t:SetScript("OnEnter", nil)
    t:SetScript("OnLeave", nil)
    t:SetScript("OnMouseDown", nil)
    t:Show()    
    return t
end
local function AcquireValueFont(parent)    
    if (not parent.valueFontPool) then
        parent.valueFontPool = CreateFontStringPool(parent, "OVERLAY", nil, "GameFontHighlight")
        table.insert(PAPetCard.pools, parent.valueFontPool)
    end

    local t = parent.valueFontPool:Acquire()
    t:Show()    
    return t
end


local function CreateWindow()
    DISPLAY.PetCard.winWidth = 400;

    local f = CreateFrame("Frame", "PAPetCard", UIParent, "UIPanelDialogTemplate", "TitleDragAreaTemplate")
    f.pools = {}
    f:SetResizable(true)
    f:SetSize(DISPLAY.PetCard.winWidth, 600)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)


    f.TitleArea = CreateFrame("Frame", nil, f)
    f.TitleArea:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -40)
    f.TitleArea:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", -50, 0)
    f.TitleArea:EnableMouse(true)
    f.TitleArea:RegisterForDrag("LeftButton")
    f.TitleArea:SetScript("OnDragStart",
        function(self)
            PAPetCard.moving = true
            PAPetCard:StartMoving()
        end
    )
    f.TitleArea:SetScript("OnDragStop",
        function(self)
            PAPetCard.moving = nil
            PAPetCard:StopMovingOrSizing()
        end
    )

    f.Close = CreateFrame("Button", "$parentClose", f)
    f.Close:SetSize(24, 24)
    f.Close:SetPoint("TOPRIGHT")
    f.Close:SetNormalTexture("Interface/Buttons/UI-Panel-MinimizeButton-Up")
    f.Close:SetPushedTexture("Interface/Buttons/UI-Panel-MinimizeButton-Down")
    f.Close:SetHighlightTexture("Interface/Buttons/UI-Panel-MinimizeButton-Highlight", "ADD")
    f.Close:SetScript("OnClick", function(self)
        self:GetParent():Hide()
    end)

    local mapFrame = CreateFrame("Frame", nil, f)
    mapFrame:SetSize(350, 256)
    mapFrame:SetPoint("TOPLEFT",20,-50)
    PAPetCard.mapFrame = mapFrame
    
    f.mapLbl = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.mapLbl:SetPoint("BOTTOM", mapFrame, "TOP", 0, -10)
    f.mapLbl:SetPoint("CENTER", mapFrame)
    
    f.scrollFrame = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
    f.scrollFrame.expansionFramesPool = {}
    f.scrollFrame:SetClipsChildren(true)
    f.scrollFrame:SetPoint("TOPLEFT", mapFrame, "BOTTOMLEFT", 0, 0);
    f.scrollFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT",0,4);
    f.scrollFrame.ScrollBar:ClearAllPoints();
    f.scrollFrame.ScrollBar:SetPoint("TOPLEFT", f.scrollFrame, "TOPRIGHT", -30, -18);
    f.scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", f.scrollFrame, "BOTTOMRIGHT", 0, 24);
    f.scrollFrame.child = CreateFrame("Frame", nil, f.scrollFrame)
    f.scrollFrame:SetScrollChild(f.scrollFrame.child)
end

local function GetFirstMapWithCoords(pet)
    for idx, loc in ipairs(pet.locations) do
        if (loc.mapID and loc.coords) then
            return idx
        end
    end
end

local function UpdateWindow(pet, locationIdx)
    for _, pool in pairs(PAPetCard.pools) do
        pool:ReleaseAll()
    end

    if not locationIdx then 
        locationIdx = GetFirstMapWithCoords(pet)
    end

    local f = PAPetCard
    local mapFrame = f.mapFrame
    f.Title:SetText(pet.name)

    if (pet.locations and pet.locations[locationIdx] and pet.locations[locationIdx].mapID and pet.locations[locationIdx].coords) then
        local mapID = pet.locations[locationIdx].mapID
        local layers = C_Map.GetMapArtLayers(mapID)

        if layers and layers[1] then
            local layerInfo = layers[1]

            local textures = C_Map.GetMapArtLayerTextures(mapID,1)

            local widthCount = ceil(layerInfo.layerWidth/layerInfo.tileWidth)
            local heightCount = ceil(layerInfo.layerHeight/layerInfo.tileHeight)

            local xScale = mapFrame:GetWidth() / layerInfo.layerWidth
            local yScale = mapFrame:GetHeight() / layerInfo.layerHeight
            scale = math.min(xScale, yScale)

            local adjustX = mapFrame:GetWidth() / 2 - layerInfo.layerWidth * (centerX or 0.5) * scale
            local adjustY = mapFrame:GetHeight() / 2 - layerInfo.layerHeight * (centerY or 0.5) * scale

            if (not adjustX == 0) then
                mapFrame:SetWidth(layerInfo.layerWidth * scale);
            elseif (not adjustY == 0) then
                mapFrame:SetHeight(layerInfo.layerHeight * scale);
            end
            for y=1,heightCount do
                for x=1,widthCount do
                    local textureIdx = (y-1)*widthCount + x
                    local t = AcquireMapTileTexture(mapFrame)

                    t:SetSize(layerInfo.tileWidth*scale,layerInfo.tileHeight*scale)
                    t:SetPoint("TOPLEFT",adjustX + layerInfo.tileWidth * (x-1) * scale,-(y-1)*layerInfo.tileHeight * scale-adjustY)

                    t:SetTexture(textures[textureIdx])
                end
            end

            for _, coord in pairs(pet.locations[locationIdx].coords) do
                local dot = AcquireMapPinTexture(mapFrame)
                dot:SetSize(6,6)
                dot:SetPoint("TOPLEFT", mapFrame:GetWidth() * (coord[1]/100), (mapFrame:GetHeight() * (coord[2]/100))*-1)
                dot:SetTexture("Interface\\Icons\\Tracking_WildPet")
            end
        end
        
        f.mapLbl:SetText(C_Map.GetMapInfo(pet.locations[locationIdx].mapID).name)
            
        if (pet.locations) then
            local locationLbl = AcquireLabelFont(f.scrollFrame)
            locationLbl:SetText("Locations:  ")
            locationLbl:SetPoint("TOPLEFT", f.scrollFrame, "TOPLEFT")
            local locationLineWidth = locationLbl:GetWidth()
            local priorLoc
            local line = 0
            for locIdx, location in ipairs(pet.locations) do        
                if (location.mapID and location.coords) then
                    local loc
                    if (locIdx == locationIdx) then
                        loc = AcquireValueFont(f.scrollFrame)
                    else
                        loc = AcquireMultiValueFont(f.scrollFrame)
                    end
                    loc.locationIndex = locIdx
                    loc.pet = pet
                    loc:SetText(C_Map.GetMapInfo(location.mapID).name)
                    locationLineWidth = locationLineWidth + loc:GetWidth()
                    if (not priorLoc or locationLineWidth > DISPLAY.PetCard.winWidth -55) then
                        if (priorLoc) then
                            line = line + 1
                        end
                        locationLineWidth = locationLbl:GetWidth() + loc:GetWidth()
                        loc:SetPoint("LEFT", locationLbl, "RIGHT")
                        loc:SetPoint("TOP", locationLbl, "TOP", 0, line * locationLbl:GetHeight()*-1)
                    else
                        local comma = AcquireValueFont(f.scrollFrame)
                        comma:SetText(", ")
                        comma:SetPoint("TOPLEFT", priorLoc, "TOPRIGHT")
                        loc:SetPoint("TOPLEFT", comma, "TOPRIGHT")
                        locationLineWidth = locationLineWidth + comma:GetWidth()
                    end
                    priorLoc = loc
                    if (locIdx ~= locationIdx) then
                        loc:SetScript("OnEnter",
                            function(self)
                                self:SetTextColor(1,1,1)
                                self:SetShadowColor(1,1,1, .4)
                            end
                        )
                        loc:SetScript("OnLeave",
                            function(self)
                                self:SetTextColor(.7, .7, .7)
                                self:SetShadowColor(0,0,0,0)
                            end
                        )
                        loc:SetScript("OnMouseDown",
                            function(self)
                                DISPLAY.PetCard:Show(self.pet, self.locationIndex)
                            end
                        )
                    end
                end
            end
        end
    end
    
    f.scrollFrame:GetHeight()
end

function DISPLAY.PetCard:Show(pet, locationIdx)
    if (not PAPetCard) then
        CreateWindow()
    end

    UpdateWindow(pet, locationIdx)

    PAPetCard:Show()
end