

    if tonumber(GetCVar'modUnitFrame') == 0 then return end

    local BG = [[Interface\AddOns\modui\statusbar\texture\sb.tga]]
    local BACKDROP = {bgFile = [[Interface\Tooltips\UI-Tooltip-Background]]}
    local _, class = UnitClass'player'
    local colour = RAID_CLASS_COLORS[class]
    local orig = {}

    local anchor = function(num)
    	if num > 5 then return 6 end
    	return 1
    end

    orig.TargetDebuffButton_Update         = TargetDebuffButton_Update
    orig.PartyMemberFrame_UpdateMember     = PartyMemberFrame_UpdateMember
    orig.TargetofTarget_Update             = TargetofTarget_Update
    orig.TextStatusBar_UpdateTextString    = TextStatusBar_UpdateTextString
    orig.UIOptionsFrame_UpdateDependencies = UIOptionsFrame_UpdateDependencies

    PlayerFrameBackground.bg = PlayerFrame:CreateTexture(nil, 'ARTWORK')
    PlayerFrameBackground.bg:SetPoint('TOPLEFT', PlayerFrameBackground)
    PlayerFrameBackground.bg:SetPoint('BOTTOMRIGHT', PlayerFrameBackground, 0, 22)
    PlayerFrameBackground.bg:SetVertexColor(colour.r, colour.g, colour.b, 1)
    PlayerFrameBackground.bg:SetTexture(BG)
    PlayerFrameBackground.bg:SetTexCoord(1, 0, 0, 1)

    PlayerFrame.status = PlayerFrameTexture:GetParent():CreateFontString(nil, 'OVERLAY')
    PlayerFrame.status:SetFont(STANDARD_TEXT_FONT, 12, 'OUTLINE')
    PlayerFrame.status:SetShadowOffset(0, 0)
    PlayerFrame.status:SetTextColor(1, 0, 0)
    PlayerFrame.status:SetPoint('CENTER', PlayerFrameHealthBar, 0, -5)

    PlayerFrameHealthBar:SetBackdrop(BACKDROP)
    PlayerFrameHealthBar:SetBackdropColor(0, 0, 0, .6)

    PlayerFrameManaBar:SetBackdrop(BACKDROP)
    PlayerFrameManaBar:SetBackdropColor(0, 0, 0, .6)

    TargetFrameNameBackground:SetTexture(BG)
    TargetFrameNameBackground:SetDrawLayer'BORDER'

    TargetFrameHealthBar:SetBackdrop(BACKDROP)
    TargetFrameHealthBar:SetBackdropColor(0, 0, 0, .6)

    TargetFrameManaBar:SetBackdrop(BACKDROP)
    TargetFrameManaBar:SetBackdropColor(0, 0, 0, .6)

    PlayerFrameGroupIndicator:SetAlpha(0)

    PlayerHitIndicator:SetText(nil)
    PlayerHitIndicator.SetText = function() end

    PetHitIndicator:SetText(nil)
    PetHitIndicator.SetText = function() end

    TargetLevelText:SetJustifyH'LEFT'
    TargetLevelText:SetPoint('LEFT', TargetFrameTextureFrame, 'CENTER', 56, -16)

    for i = 6, 12 do
        local f = CreateFrame('Button', 'TargetFrameBuff'..i, TargetFrame, 'TargetBuffButtonTemplate')
        f:SetID(i)
        f:Hide()
        modSkin(f, 16)      -- first 6 are skinned in skin/button/target.lua
        modSkinPadding(f, 2)
        modSkinColor(f, .2, .2, .2)
        if i == 6 then
            f:SetPoint('TOPLEFT', TargetFrameBuff1, 'BOTTOMLEFT', 0, -2)
        else
            f:SetPoint('LEFT', _G['TargetFrameBuff'..(i - 1)], 'RIGHT', 3, 0)
        end
    end

    for i, v in pairs({PlayerPVPIcon, TargetFrameTextureFramePVPIcon,}) do v:SetAlpha(0) end

    for i = 1, 4 do _G['PartyMemberFrame'..i..'PVPIcon']:SetAlpha(0) end

    for i = 1, 4 do
        for _, v in pairs({_G['PartyMemberFrame'..i..'HealthBar'], _G['PartyMemberFrame'..i..'ManaBar']}) do
            v:SetBackdrop(BACKDROP) v:SetBackdropColor(0, 0, 0, .6)
        end
    end


    local colourParty = function()              -- PARTY CLASS COLOUR
        for i = 1, MAX_PARTY_MEMBERS do
            local name = _G['PartyMemberFrame'..i..'Name']
            if UnitIsPlayer('party'..i) then
                local _, class = UnitClass('party'..i)
                local colour = RAID_CLASS_COLORS[class]
                if colour then name:SetTextColor(colour.r, colour.g, colour.b) end
            else
                name:SetTextColor(1, .8, 0)
            end
        end
    end


    function TargetFrame_OnShow() end           -- REMOVE TARGETING SOUND
    function TargetFrame_OnHide() CloseDropDownMenus() end



    local mod_TargetBuffs = function()          -- TARGET AURAS (up to 16)
        local b, d = 0, 0

        for i = 1, 16 do
            local bu = _G['TargetFrameBuff'..i]
            local ic = UnitBuff('target', i)
            if bu and ic then
                _G['TargetFrameBuff'..i..'Icon']:SetTexture(ic)
                bu:Show()
                bu.id = i
                b = i
            else
                if bu then bu:Hide() end
            end
        end

        for i = 1, 16 do
            local ic, stack = UnitDebuff('target', i)
            local bu = _G['TargetFrameDebuff'..i]
            if bu and ic then
                local count = _G['TargetFrameDebuff'..i..'Count']
                if stack > 1 then
                    count:SetText(stack)
                    count:Show()
                else
                    count:Hide()
                end
                _G['TargetFrameDebuff'..i..'Icon']:SetTexture(ic)
                bu:Show()
                bu.id = i
                d = i
            else
                if bu then bu:Hide() end
            end
        end

        for i = 6, 12 do
            local bu = _G['TargetFrameBuff'..i]
            local x, y = _G['TargetFrameBuff1']:GetWidth(), _G['TargetFrameBuff1']:GetHeight()
            bu:SetWidth(x) bu:SetHeight(y)
        end

        if UnitIsFriend('player', 'target') then
            TargetFrameBuff1:ClearAllPoints()
            TargetFrameBuff1:SetPoint('TOPLEFT', 'TargetFrame', 'BOTTOMLEFT', 5, 32)
            TargetFrameDebuff1:ClearAllPoints()
            TargetFrameDebuff1:SetPoint('TOPLEFT', _G['TargetFrameBuff'..anchor(b)], 'BOTTOMLEFT', 0, -2)
        else
            TargetFrameBuff1:ClearAllPoints()
            TargetFrameBuff1:SetPoint('TOPLEFT', _G['TargetFrameDebuff'..anchor(d)], 'BOTTOMLEFT', 0, -2)
            TargetFrameDebuff1:ClearAllPoints()
            TargetFrameDebuff1:SetPoint('TOPLEFT', TargetFrame, 'BOTTOMLEFT', 5, 32)
        end
    end


    t = CreateFrame'Frame'
    t:RegisterEvent'PLAYER_TARGET_CHANGED' t:RegisterEvent'PARTY_MEMBERS_CHANGED'
    t:RegisterEvent'UNIT_FACTION'
    t:SetScript('OnEvent', function()           -- COLOUR UNIT
        local _, class = UnitClass'target'
        local colour = RAID_CLASS_COLORS[class]
        if UnitIsPlayer'target' then TargetFrameNameBackground:SetVertexColor(colour.r, colour.g, colour.b, 1) end
        if arg1 == 'PARTY_MEMBERS_CHANGED' then colourParty() end
    end)

    function PartyMemberFrame_UpdateMember()
        orig.PartyMemberFrame_UpdateMember()
        colourParty()
    end

    function TargetofTarget_Update()
        orig.TargetofTarget_Update()
        local _, class = UnitClass'targettarget'
        local colour = RAID_CLASS_COLORS[class]
        if UnitIsPlayer'targettarget' then
            TargetofTargetName:SetTextColor(colour.r, colour.g, colour.b)
        else
            TargetofTargetName:SetTextColor(1, .8, 0)
        end
    end

    function TextStatusBar_UpdateTextString(sb)  -- STATUS TEXT
        if not sb then sb = this end
        orig.TextStatusBar_UpdateTextString(sb)
    	local string = sb.TextString
    	if string then
            local pp = UnitPowerType'player'
    		local v  = math.floor(sb:GetValue())
    		local min, max = sb:GetMinMaxValues()
            local percent = math.floor(v/max*100)

    		if max > 0 then
    			sb:Show()
                if UnitIsDead'player' then
                    PlayerFrame.status:SetText'Dead'
                    string:SetText''
                    return
                elseif UnitIsGhost'player' then
                    PlayerFrame.status:SetText'Ghost'
                    string:SetText''
                    return
    			elseif v == 0 and sb.zeroText then
                    PlayerFrame.status:SetText''
                    string:SetText''
                    return
                elseif sb:GetName() == 'PetFrameManaBar' then
                    string:SetText''
                    return
    			else
                    PlayerFrame.status:SetText''
                    if sb:GetName() == 'MainMenuExpBar' then
                        string:SetPoint('CENTER', sb) string:SetJustifyH'CENTER'
                        if GetCVar'modValue' == '1' then
                            if ReputationWatchBar:IsShown() then
                                local rname, _, rmin, rmax, rv = GetWatchedFactionInfo()
                                MainMenuExpBar.rep:SetText(rname..': '..true_format((rv - rmin))..' / '..true_format((rmax - rmin))..'    ')
                                string:SetText('—     XP: '..true_format(v)..' / '..true_format(max))
                                string:SetPoint('CENTER', (string:GetWidth()/2) - 8, 25)
                            else
                                MainMenuExpBar.rep:SetText''
                                string:SetText(true_format(v)..' / '..true_format(max))
                            end
                        else
                            if ReputationWatchBar:IsShown() then
                                local rname, standing, rmin, rmax, rv = GetWatchedFactionInfo()
                                local rperc = math.floor((rv - rmin)/(rmax - rmin)*100)
                                MainMenuExpBar.rep:SetText(rname..': '..percent..'% into '.._G['FACTION_STANDING_LABEL'..standing]..'    ')
                                string:SetText('—     XP: '..percent..'%')
                                string:SetPoint('CENTER', (string:GetWidth()/2) - 8, 25)
                            else
                                MainMenuExpBar.rep:SetText''
                                string:SetText(percent..'%')
                            end
                        end
                    elseif sb:GetName() == 'PlayerFrameManaBar'
                    and (pp == 1 or pp == 2 or pp == 3) then
                        string:SetText(v)
                    else
                        if GetCVar'modBoth' == '1' then
                            string:SetText(true_format(v)..'/'..true_format(max)..' — '..percent..'%')
                        elseif GetCVar'modValue'  == '1' and GetCVar'modBoth' == '0' then
                            string:SetText(true_format(v))
                        else
                            string:SetText(percent..'%')
                        end
                    end
                    string:SetFont(STANDARD_TEXT_FONT, 12, 'OUTLINE')
                    if GetCVar'modStatus'  == '0' and GetCVar'modBoth' == '0' and sb:GetName() ~= 'MainMenuExpBar' then
                        string:ClearAllPoints()
                        string:SetJustifyV'MIDDLE'
                        string:SetPoint('CENTER',
                                    (sb:GetName() == ('PetFrameHealthBar' or 'PetFrameManaBar')) and PetFrame or PlayerFrame,
                                    (sb:GetName() == ('PetFrameHealthBar' or 'PetFrameManaBar')) and 18 or
                                    (sb:GetName() == 'PlayerFrameManaBar') and 30 or 80,
                                    -2)
                    end
    			end
            end
    	end
    end

    local cv = GetCVar'modStatus' local cv2 = GetCVar'modValue' local cv3 = GetCVar'ModBoth'
    local f = CreateFrame'Frame'
    f:RegisterEvent'CVAR_UPDATE'
    f:SetScript('OnEvent', function()
        if (arg1 == 'MODSTATUS_BAR_TEXT' and arg2 ~= cv)
        or (arg1 == 'MODSTATUS_BAR_VALUE' and arg2 ~= cv2)
        or (arg1 == 'MODSTATUS_BAR_CONSOLIDATE' and arg2 ~= cv3) then
            TextStatusBar_UpdateTextString() ReloadUI()
        end
    end)

    TargetFrame:SetScript('OnEnter', function()
        UnitFrame_OnEnter()
        function TargetDebuffButton_Update() mod_TargetBuffs() end
        TargetDebuffButton_Update()
    end)
    TargetFrame:SetScript('OnLeave', function()
        UnitFrame_OnLeave()
        function TargetDebuffButton_Update() orig.TargetDebuffButton_Update() end
        TargetDebuffButton_Update()
        for i = 6, 12 do _G['TargetFrameBuff'..i]:Hide() end
    end)



    --