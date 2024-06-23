local PETC = PetCollector
local DISPLAY = PETC.DISPLAY
local PETS = PETC.PETS
local UTILITIES = PETC.UTILITIES
local DATA = PETC.DATA
local ZONES = PETC.ZONES
local regionS = PETC.regionS

local function ResetTabContent()
    if (PAMainFrameTab2.content.scrollFrame) then
        for _,continentFrame in pairs(PAMainFrameTab2.content.scrollFrame.expansionFramesPool) do
            continentFrame:Hide()
            continentFrame:ClearAllPoints()
            continentFrame.movingAnchor:ClearAllPoints()
            continentFrame.childrenHostFrame.standardTextPool:ReleaseAll()
            continentFrame.childrenHostFrame.smallerTextPool:ReleaseAll()
        end
    else
        PAMainFrameTab2.content.scrollFrame = CreateFrame("ScrollFrame", nil, PAMainFrameTab2.content, "UIPanelScrollFrameTemplate")
        PAMainFrameTab2.content.scrollFrame.expansionFramesPool = {}
        PAMainFrameTab2.content.scrollFrame:SetClipsChildren(true)
        PAMainFrameTab2.content.scrollFrame:SetPoint("TOPLEFT", PAMainFrameTab2.content, "TOPLEFT", 10, -55);
        PAMainFrameTab2.content.scrollFrame:SetPoint("BOTTOMRIGHT", PAMainFrameTab2.content, "BOTTOMRIGHT",0,4);
        PAMainFrameTab2.content.scrollFrame.ScrollBar:ClearAllPoints();
        PAMainFrameTab2.content.scrollFrame.ScrollBar:SetPoint("TOPLEFT", PAMainFrameTab2.content.scrollFrame, "TOPRIGHT", -12, -18);
        PAMainFrameTab2.content.scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", PAMainFrameTab2.content.scrollFrame, "BOTTOMRIGHT", -7, 24);
        local scrollFrameChild = CreateFrame("Frame", nil, PAMainFrameTab2.content.scrollFrame)
        PAMainFrameTab2.content.scrollFrame:SetScrollChild(scrollFrameChild)
        PAMainFrameTab2.content.scrollFrame.child = scrollFrameChild
    end
end

function DISPLAY.Capturable:ShowLoading()
    PAMainFrameTab2.content.refreshButton:Hide()
    PAMainFrameTab2.content.spinner:Show()
end

function DISPLAY.Capturable:HideLoading()
    PAMainFrameTab2.content.refreshButton:Show()
    PAMainFrameTab2.content.spinner:Hide()
    DISPLAY.Capturable:Update()
end

local function AcquireStandardText(continentFrame)
    local text = continentFrame.childrenHostFrame.standardTextPool:Acquire()
    text:SetScript("OnEnter", nil)
    text:SetScript("OnLeave", nil)
    text:Show()
    return text
end
local function AcquirePetText(continentFrame)
    local text = continentFrame.childrenHostFrame.standardTextPool:Acquire()
    text:SetTextColor(.4, .74, 1)
    text:SetScript("OnEnter", nil)
    text:SetScript("OnLeave", nil)
    text:SetScript("OnMouseDown", nil)
    text:Show()
    return text
end


local function AcquireSmallerText(continentFrame)
    local text = continentFrame.childrenHostFrame.smallerTextPool:Acquire()
    if (not text:GetText()) then
        local fontFile, fontHeight, fontFlags = text:GetFont()
        text:SetFont(fontFile, fontHeight-2, fontFlags)
    end
    text:SetScript("OnEnter", nil)
    text:SetScript("OnLeave", nil)
    text:Show()
    return text
end


function DISPLAY.Capturable:Update()
    ResetTabContent()
    local tabContent = PAMainFrameTab2.content
    local scrollFrame = tabContent.scrollFrame
    if UTILITIES:IsEmpty(PETS.capturable) then
        local noResults = scrollFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
        noResults:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 50,0);
        noResults:SetText("You've captured all of the wild pets!!")
        return
    end

    local sumHeight = 0
    local widest = 0
    local priorContinentFrame = nil
    local totalHeight = 0
    for continentName, continentContents in pairs(PETS.capturable) do
        --continent HEADER
        local continentFrame = DISPLAY:AcquireExpansionFrame(scrollFrame, continentName)
        if (priorContinentFrame) then
            continentFrame:SetPoint("TOPLEFT", priorContinentFrame.movingAnchor, "BOTTOMLEFT", 0, -continentFrame.header:GetHeight() -DISPLAY.Constants.lineSeparation)
        else
            continentFrame:SetPoint("TOPLEFT", scrollFrame.child, "TOPLEFT", 0, 0)
        end
        priorContinentFrame = continentFrame
        local continentHeight = 0

        local priorZoneAnchor = nil
        local priorZoneHeight = 0
        for zoneName, zoneContents in pairs(continentContents) do
            --ZONE HEADER
            local zoneHeader = AcquireStandardText(continentFrame);
            zoneHeader:SetText(zoneName)
            zoneHeader:SetPoint("LEFT", continentFrame.childrenHostFrame, "LEFT", 0, 0);      
            if (priorZoneAnchor) then
                zoneHeader:SetPoint("TOP", priorZoneAnchor, "BOTTOM", 0, -priorZoneHeight);
            else
                zoneHeader:SetPoint("TOP", continentFrame.childrenHostFrame, "TOP", 0, -DISPLAY.Constants.lineSeparation);                
            end
            priorZoneAnchor = zoneHeader
            priorZoneHeight = zoneHeader:GetHeight()
            
            local lastAnchor = nil
            if (zoneContents.pets) then
                local lineWidth = 0
                for _, pet in pairs(zoneContents.pets) do
                    --ZONE PETS
                    local zonePet = AcquirePetText(continentFrame);
                    zonePet:SetFormattedText("[%s]", pet.name)
                    zonePet.pet = pet
                    lineWidth = lineWidth + 20 + zonePet:GetWidth()
                    if (lastAnchor) then
                        if (lineWidth <= 540) then
                            zonePet:SetPoint("TOPLEFT", lastAnchor, "TOPRIGHT", 20, 0);
                        else
                            lineWidth = zonePet:GetWidth()                            
                            zonePet:SetPoint("TOP", lastAnchor, "BOTTOM", 0, -DISPLAY.Constants.lineSeparation);
                            zonePet:SetPoint("LEFT", continentFrame.childrenHostFrame, "LEFT", 200, 0);
                            priorZoneHeight = priorZoneHeight + zonePet:GetHeight() + DISPLAY.Constants.lineSeparation
                        end
                    else
                        zonePet:SetPoint("LEFT", continentFrame.childrenHostFrame, "LEFT", 200, 0);
                        zonePet:SetPoint("TOP", zoneHeader, "TOP", 0, 0);
                    end
                    
                    zonePet:SetScript("OnEnter",
                        function(self)
                            self:SetTextColor(.5, .85, 1)
                            self:SetShadowColor(1,1,1, .4)
                        end
                    )
                    zonePet:SetScript("OnLeave",
                        function(self)
                            self:SetTextColor(.4, .74, 1)
                            self:SetShadowColor(0,0,0,0)
                        end
                    )
                    zonePet:SetScript("OnMouseDown",
                        function(self)
                            DISPLAY.PetCard:Show(self.pet)
                        end
                    )
                    lastAnchor = zonePet
                end
                continentHeight = continentHeight + priorZoneHeight + zoneHeader:GetHeight()
            end

            for areaName, areaContents in pairs(zoneContents) do        
                if (areaContents.pets) then
                    --AREA HEADER
                    local areaHeader = AcquireStandardText(continentFrame);
                    areaHeader:SetText(areaName)
                    areaHeader:SetPoint("TOP", lastAnchor or priorZoneAnchor, "BOTTOM", 0, -DISPLAY.Constants.lineSeparation);
                    areaHeader:SetPoint("LEFT", continentFrame.childrenHostFrame, "LEFT", DISPLAY.Constants.zoneIndent, 0);   
                    priorZoneAnchor = areaHeader
                    priorZoneHeight = areaHeader:GetHeight()
                    
                    lineWidth = 0
                    lastAnchor = nil
                    for _, pet in pairs(areaContents.pets) do
                        --AREA PETS
                        local areaPet = AcquirePetText(continentFrame);
                        areaPet:SetFormattedText("[%s]", pet.name)
                        areaPet.pet = pet
                        lineWidth = lineWidth + 20 + areaPet:GetWidth()
                        if (lastAnchor) then
                            if (lineWidth <= 550) then
                                areaPet:SetPoint("TOPLEFT", lastAnchor, "TOPRIGHT", 20, 0);
                            else
                                lineWidth = areaPet:GetWidth()                            
                                areaPet:SetPoint("TOP", lastAnchor, "BOTTOM", 0, -DISPLAY.Constants.lineSeparation);
                                areaPet:SetPoint("LEFT", continentFrame.childrenHostFrame, "LEFT", 200, 0);
                                priorZoneHeight = priorZoneHeight + areaPet:GetHeight() + DISPLAY.Constants.lineSeparation
                            end
                        else
                            areaPet:SetPoint("LEFT", continentFrame.childrenHostFrame, "LEFT", 200, 0);
                            areaPet:SetPoint("TOP", areaHeader, "TOP", 0, 0);
                        end
                        areaPet:SetScript("OnEnter",
                            function(self)
                                self:SetTextColor(.5, .85, 1)
                                self:SetShadowColor(1,1,1, .4)
                            end
                        )
                        areaPet:SetScript("OnLeave",
                            function(self)
                                self:SetTextColor(.4, .74, 1)
                                self:SetShadowColor(0,0,0,0)
                            end
                        )
                        areaPet:SetScript("OnMouseDown",
                            function(self)
                                DISPLAY.PetCard:Show(self.pet)
                            end
                        )
                        lastAnchor = areaPet
                    end
                    continentHeight = continentHeight + priorZoneHeight + zoneHeader:GetHeight()
                end
            end
        end

        continentFrame:SetSize(DISPLAY.Constants.minWidth, continentHeight)
        continentFrame.continentHeight = continentFrame:GetHeight()
        continentFrame.movingAnchor:GetHeight()
        totalHeight = totalHeight + continentHeight +DISPLAY.Constants.lineHeight +DISPLAY.Constants.lineSeparation
    end

    scrollFrame.child:SetSize(DISPLAY.Constants.minWidth, totalHeight)
    
    --Hack to make it so the window doesn't load empty
    local currentHeight = PAMainFrameTab2.content.scrollFrame.child:GetHeight()
end