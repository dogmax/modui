

                                        -- UIPARENT_MANAGED_FRAME_POSITIONS ALTERNATIVE
                                        -- FOR HORIZONTAL BARS
    if not MODUI_HORIZONTAL then return end
    CONTAINER_OFFSET_Y = 90
    local orig = {}

    local movebars = function()          -- ACTIONBARS
        for _, v in pairs({ _G['ShapeshiftButton1'],
                            _G['PetActionButton1'],
                            _G['StanceButton1'] }) do
            if SHOW_MULTI_ACTIONBAR_3 then
                v:SetPoint('BOTTOMLEFT', MultiBarRightButton1, 'TOPLEFT', 24, 8)
            elseif SHOW_MULTI_ACTIONBAR_1 and not SHOW_MULTI_ACTIONBAR_3 then
                v:SetPoint('BOTTOMLEFT', MultiBarBottomLeftButton1, 'TOPLEFT', 24, 8)
            else
                v:SetPoint('BOTTOMLEFT', ActionButton1, 'TOPLEFT', 24, 18)
            end
        end
    end

    local movetip = function()             -- TOOLTIP
        local type = GameTooltip:GetAnchorType()
        local i    = 1
        GameTooltip:SetBackdropColor(0, 0, 0, .7)
        GameTooltip:SetBackdropBorderColor(.1, .1, .1, 1)
        if type == 'ANCHOR_NONE' then
            GameTooltip:ClearAllPoints()
            if SHOW_MULTI_ACTIONBAR_4 then
                GameTooltip:SetPoint('BOTTOMRIGHT', MultiBarLeftButton12, 'TOPRIGHT', 3, 14)
            elseif SHOW_MULTI_ACTIONBAR_2 and not SHOW_MULTI_ACTIONBAR_4 then
                GameTooltip:SetPoint('BOTTOMRIGHT', MultiBarBottomRightButton12, 'TOPRIGHT', 3, 14)
            else
                GameTooltip:SetPoint('BOTTOMRIGHT', MainMenuBarBackpackButton, 'TOPRIGHT', 3, 18)
            end
            while ContainerFrame1.bags[i] do
                local f  = _G[ContainerFrame1.bags[i]]
                GameTooltip:SetPoint('BOTTOMRIGHT', f, 'TOPRIGHT', -3, CONTAINER_OFFSET_Y/5)
                local b = GameTooltip:GetBottom()
                if math.floor(b + .5) > 600 then
                    GameTooltip:SetPoint('BOTTOMRIGHT', f, 'BOTTOMLEFT', -15, f:GetHeight()/3)
                end
                i = i + 1
            end
        end
    end

    local moveCB = function()          -- CASTBAR
        local y
        if SHOW_MULTI_ACTIONBAR_3 or SHOW_MULTI_ACTIONBAR_4 then
            y = 160
        elseif  (SHOW_MULTI_ACTIONBAR_1 or SHOW_MULTI_ACTIONBAR_2)
        and not (SHOW_MULTI_ACTIONBAR_3 or SHOW_MULTI_ACTIONBAR_4)  then
            y = 120
        else
            y = 80
        end
        CastingBarFrame:SetPoint('BOTTOM', UIParent, 0, y)
    end

    orig.updateContainerFrameAnchors = updateContainerFrameAnchors
    orig.UIParent_ManageFramePositions = UIParent_ManageFramePositions

    function updateContainerFrameAnchors()
        orig.updateContainerFrameAnchors()
        local i = 1
        CONTAINER_WIDTH = 210
        CONTAINER_OFFSET_Y = 95
        while ContainerFrame1.bags[i] do
            local f  = _G[ContainerFrame1.bags[i]]
            f:SetWidth(192)
            if i == 1 then f:SetPoint('BOTTOMRIGHT', f:GetParent(), -15, CONTAINER_OFFSET_Y) end
            i = i + 1
        end
    end

                                            -- HOOK
    local t = CreateFrame('Frame', nil, GameTooltip) t:SetAllPoints()
    t:SetScript('OnShow', movetip)

    function UIParent_ManageFramePositions()
        orig.UIParent_ManageFramePositions()
        movebars()
        moveCB()
        for _, v in pairs({ SlidingActionBarTexture0, SlidingActionBarTexture1,
                            ShapeshiftBarLeft, ShapeshiftBarMiddle, ShapeshiftBarRight, }) do
            if v then v:Hide() end
        end
    end

    for _, v in pairs({                     -- UNHOOK
        'MultiBarLeft',
        'MultiBarRight',
        'StanceBarFrame',
        'PossessBarFrame',
        'CastingBarFrame',
        'PETACTIONBAR_YPOS',
        'CONTAINER_OFFSET_X',
        'CONTAINER_OFFSET_Y'
    }) do
        UIPARENT_MANAGED_FRAME_POSITIONS[v] = nil
    end

    --
