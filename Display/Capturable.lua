local PETC = PetCollector
local DISPLAY = PETC.DISPLAY
local DISPLAY_UTIL = PETC.DISPLAY.Util
local PETS = PETC.PETS
local UTILITIES = PETC.UTILITIES

local function ResetTabContent()
    if (PAMainFrameTab2.content.scrollFrame) then
        DISPLAY_UTIL:Reset(PAMainFrameTab2)
    else
        PAMainFrameTab2.content.scrollFrame = CreateFrame("ScrollFrame", nil, PAMainFrameTab2.content, "UIPanelScrollFrameTemplate")
        PAMainFrameTab2.content.scrollFrame:SetClipsChildren(true)
        PAMainFrameTab2.content.scrollFrame:SetPoint("TOPLEFT", PAMainFrameTab2.content, "TOPLEFT", 10, -55);
        PAMainFrameTab2.content.scrollFrame:SetPoint("BOTTOMRIGHT", PAMainFrameTab2.content, "BOTTOMRIGHT",0,4);
        PAMainFrameTab2.content.scrollFrame.ScrollBar:ClearAllPoints();
        PAMainFrameTab2.content.scrollFrame.ScrollBar:SetPoint("TOPLEFT", PAMainFrameTab2.content.scrollFrame, "TOPRIGHT", -20, -18);
        PAMainFrameTab2.content.scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", PAMainFrameTab2.content.scrollFrame, "BOTTOMRIGHT", 0, 24);
        local scrollFrameChild = CreateFrame("Frame", nil, PAMainFrameTab2.content.scrollFrame)
        PAMainFrameTab2.content.scrollFrame:SetScrollChild(scrollFrameChild)
        PAMainFrameTab2.content.scrollFrame.child = scrollFrameChild
    end
end

function DISPLAY.Capturable:Update()
    ResetTabContent()
    local tabContent = PAMainFrameTab2.content
    local scrollFrame = tabContent.scrollFrame
    if UTILITIES:IsEmpty(PETS.capturable) then
        local noResults = DISPLAY_UTIL:AcquireHighlightFont(PAMainFrameTab2, scrollFrame)
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
        local continentFrame = DISPLAY_UTIL:AcquireExpansionFrame(PAMainFrameTab2, scrollFrame, continentName)
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
            local zoneHeader = DISPLAY_UTIL:AcquireHighlightFont(PAMainFrameTab2, continentFrame);
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
                    local zonePet = DISPLAY_UTIL:AcquirePetLinkFont(PAMainFrameTab2, continentFrame, pet);
                    zonePet:SetFormattedText("[%s]", pet.name)
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
                    lastAnchor = zonePet
                end
                continentHeight = continentHeight + priorZoneHeight + zoneHeader:GetHeight()
            end

            for areaName, areaContents in pairs(zoneContents) do        
                if (areaContents.pets) then
                    --AREA HEADER
                    local areaHeader = DISPLAY_UTIL:AcquireHighlightFont(PAMainFrameTab2, continentFrame);
                    areaHeader:SetText(areaName)
                    areaHeader:SetPoint("TOP", lastAnchor or priorZoneAnchor, "BOTTOM", 0, -DISPLAY.Constants.lineSeparation);
                    areaHeader:SetPoint("LEFT", continentFrame.childrenHostFrame, "LEFT", DISPLAY.Constants.zoneIndent, 0);   
                    priorZoneAnchor = areaHeader
                    priorZoneHeight = areaHeader:GetHeight()
                    
                    lineWidth = 0
                    lastAnchor = nil
                    for _, pet in pairs(areaContents.pets) do
                        --AREA PETS
                        local areaPet = DISPLAY_UTIL:AcquirePetLinkFont(PAMainFrameTab2, continentFrame, pet);
                        areaPet:SetFormattedText("[%s]", pet.name)
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