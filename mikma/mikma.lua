local mikma = CreateFrame("Frame")

--mikma:RegisterEvent("MERCHANT_SHOW")
mikma:RegisterEvent("PLAYER_ENTERING_WORLD")
mikma:RegisterEvent("PLAYER_REGEN_ENABLED")
mikma:RegisterEvent("PLAYER_REGEN_DISABLED")
mikma:RegisterEvent("PLAYER_LOGIN")
mikma:SetScript("OnEvent", function(self, event, ...)
	if self[event] then return self[event](self, event, ...) end
end)

function mikma:PLAYER_REGEN_ENABLED()
	mikma:RegisterEvent("SKILL_LINES_CHANGED")
end

function mikma:PLAYER_REGEN_DISABLED()
	mikma:UnregisterEvent("SKILL_LINES_CHANGED")
end

function mikma:PLAYER_ENTERING_WORLD()
	mikma:RegisterEvent("SKILL_LINES_CHANGED")
	mikma:SKILL_LINES_CHANGED()
end

function mikma:PLAYER_LOGIN()
	if not mikmaDB then mikmaDB = {} end
	mikma:ChatFrameMods()
	mikma:TransparentBags()
	mikma:UnregisterEvent("PLAYER_LOGIN")
end

function mikma:MERCHANT_SHOW()
	-- autorepair levels over 40
	if UnitLevel("player") > 39 then
		RepairAllItems() 
	end
	-- sell grey crap
	for bag=0,4 do
		for slot=0,GetContainerNumSlots(bag) do
			local link = GetContainerItemLink(bag, slot)
			if link and select(3, GetItemInfo(link)) == 0 then
				ShowMerchantSellCursor(1)
				UseContainerItem(bag, slot)
			end
		end
	end
end

mikma:RegisterEvent("CHAT_MSG_SYSTEM")
function mikma:CHAT_MSG_SYSTEM(event, ...)
	local arg1 = ...
	if ( arg1 and arg1 == IDLE_MESSAGE ) then
		ForceQuit()
	end
end

local skillBox = CreateFrame("MessageFrame", nil, UIParent)
skillBox:SetSize(250, 35)
skillBox:SetPoint("TOPLEFT",ChatFrame1,"TOPRIGHT", 10, 0)
skillBox:SetInsertMode("TOP")
skillBox:SetJustifyH("LEFT")
skillBox:SetFrameStrata("HIGH")
skillBox:SetTimeVisible(60)
skillBox:SetFadeDuration(10)
skillBox:SetFont(STANDARD_TEXT_FONT, 15, "OUTLINE")

function mikma:SKILL_LINES_CHANGED()
	skillBox:Clear()
	local prof1, prof2, archaeology, fishing, cooking, firstAid = GetProfessions()
	
	local race = UnitRace("player")
	local fromMax = 25
	local extra = 0
	local upgrade
	
	if prof1 ~= nil then
		local name, texture, rank, maxRank, numSpells, spelloffset, skillLine, rankModifier, specializationIndex, specializationOffset = GetProfessionInfo(prof1)
		--[[
		if race == "Gnome" and name == "Engineering" then
			fromMax = 40
			extra = 15
		end
		]]
		if rank == 700+extra then
			return
		end
		if rank > maxRank-fromMax then
			--if maxRank <= 700+extra then
			--	upgrade = ""
			--else
				upgrade = " |cFFFF0000(Upgrade available!)|r"
			--end
		else
			upgrade = ""
		end
		skillBox:AddMessage("|T"..texture..":0|t "..rank.."/"..maxRank..upgrade)
	end

	if prof2 ~= nil then
		local name, texture, rank, maxRank, numSpells, spelloffset, skillLine, rankModifier, specializationIndex, specializationOffset = GetProfessionInfo(prof2)
		--[[
		if race == "Gnome" and name == "Engineering" then
			fromMax = 40
			extra = 15
		end
		]]
		if rank == 700+extra then
			return
		end
		if rank > maxRank-fromMax then 
			--if maxRank <= 700+extra then
			--	upgrade = ""
			--else
				upgrade = " |cFFFF0000(Upgrade available!)|r"
			--end
		else 
			upgrade = "" 
		end
		skillBox:AddMessage("|T"..texture..":0|t "..rank.."/"..maxRank..upgrade)
	end
end

function mikma:ChatFrameMods()
	if not mikmaDB.ChatMods then
		FCF_ResetChatWindows()
		FCFDock_AddChatFrame(GENERAL_CHAT_DOCK,ChatFrame3,3)
		FCFDock_AddChatFrame(GENERAL_CHAT_DOCK,ChatFrame4,4)
		FCF_SetLocked(ChatFrame3, false)
		FCF_SetLocked(ChatFrame4, false)
		FCF_UnDockFrame(ChatFrame3)
		FCF_UnDockFrame(ChatFrame4)
		FCF_SetTabPosition(ChatFrame3,0)
		FCF_SetTabPosition(ChatFrame4,0)
		FCF_SetChatWindowFontSize(nil, ChatFrame1, 12)
		FCF_SetChatWindowFontSize(nil, ChatFrame2, 12)
		FCF_SetChatWindowFontSize(nil, ChatFrame3, 12)
		FCF_SetChatWindowFontSize(nil, ChatFrame4, 12)
		ChatFrame_RemoveAllChannels(ChatFrame3)
		ChatFrame_RemoveAllChannels(ChatFrame4)
		ChatFrame_RemoveAllMessageGroups(ChatFrame3)
		ChatFrame_RemoveAllMessageGroups(ChatFrame4);
		FCF_SetWindowAlpha(ChatFrame1, DEFAULT_CHATFRAME_ALPHA)
		FCF_SetWindowAlpha(ChatFrame3, DEFAULT_CHATFRAME_ALPHA)
		FCF_SetWindowAlpha(ChatFrame4, DEFAULT_CHATFRAME_ALPHA)
		FCF_SetLocked(ChatFrame3, true)
		FCF_SetLocked(ChatFrame3, true)
		ChatFrame1:AddMessage("Creating ChatFrame3 and ChatFrame4.")
		mikmaDB.ChatMods = { alpha = 0.3, height = 10, ChatFrame3 = false, ChatFrame4 = false, }
	end
	ChatFrame3:ClearAllPoints()
	ChatFrame4:ClearAllPoints()
	local width = ChatFrame1:GetWidth()
	ChatFrame3:SetWidth(width)
	ChatFrame4:SetWidth(width)
	local x,y = 0,10
	ChatFrame3:SetPoint("BOTTOMLEFT",ChatFrame1,"TOPLEFT",x,y)
	ChatFrame4:SetPoint("BOTTOMLEFT",ChatFrame3,"TOPLEFT",x,y)
	if mikmaDB.ChatMods.ChatFrame3 then
		ChatFrame3:SetHeight(mikmaDB.ChatMods.height)
	else
		local height = ChatFrame1:GetHeight()
		ChatFrame3:SetHeight(height)
	end

	if mikmaDB.ChatMods.ChatFrame4 then
		ChatFrame4:SetHeight(mikmaDB.ChatMods.height)
	else
		local height = ChatFrame1:GetHeight()
		ChatFrame4:SetHeight(height)
	end
	FCF_SavePositionAndDimensions(ChatFrame3)
	FCF_SavePositionAndDimensions(ChatFrame4)


	local showbg1 = CreateFrame("CheckButton", nil, parent)
	showbg1:SetPoint("BOTTOMRIGHT", ChatFrame3, "BOTTOMLEFT", -2, -3)
	showbg1:SetWidth(12)
	showbg1:SetHeight(12)
	showbg1:SetAlpha(mikmaDB.ChatMods.alpha)
	showbg1:SetScript("OnClick", function(self)
		if mikmaDB.ChatMods.ChatFrame3 then
			local height = ChatFrame1:GetHeight()
			ChatFrame3:SetHeight(height)
			showbg1:SetNormalTexture("INTERFACE\\Icons\\Spell_ChargeNegative")
			mikmaDB.ChatMods.ChatFrame3 = false
		else
			ChatFrame3:SetHeight(mikmaDB.ChatMods.height)
			showbg1:SetNormalTexture("INTERFACE\\Icons\\Spell_ChargePositive")
			mikmaDB.ChatMods.ChatFrame3 = true
		end
		FCF_SavePositionAndDimensions(ChatFrame3)
	end)
	showbg1:SetScript("OnEnter", function(self)
		showbg1:SetAlpha(1)
	end)
	showbg1:SetScript("OnLeave", function(self)
		showbg1:SetAlpha(mikmaDB.ChatMods.alpha)
	end)
	if mikmaDB.ChatMods.ChatFrame3 then
		showbg1:SetNormalTexture("INTERFACE\\Icons\\Spell_ChargePositive")
	else
		showbg1:SetNormalTexture("INTERFACE\\Icons\\Spell_ChargeNegative")
	end
	
	local showbg2 = CreateFrame("Button", nil, parent)
	showbg2:SetPoint("BOTTOMRIGHT", ChatFrame4, "BOTTOMLEFT", -2, -3)
	showbg2:SetWidth(12)
	showbg2:SetHeight(12)
	showbg2:SetAlpha(mikmaDB.ChatMods.alpha)
	showbg2:SetScript("OnClick", function(self)
	if mikmaDB.ChatMods.ChatFrame4 then
		local height = ChatFrame1:GetHeight()
		ChatFrame4:SetHeight(height)
		showbg2:SetNormalTexture("INTERFACE\\Icons\\Spell_ChargeNegative")
		mikmaDB.ChatMods.ChatFrame4 = false
	else
		ChatFrame4:SetHeight(mikmaDB.ChatMods.height)
		showbg2:SetNormalTexture("INTERFACE\\Icons\\Spell_ChargePositive")
		mikmaDB.ChatMods.ChatFrame4 = true
	end
	FCF_SavePositionAndDimensions(ChatFrame4)  
	end)
	showbg2:SetScript("OnEnter", function(self)
		showbg2:SetAlpha(1)
	end)
	showbg2:SetScript("OnLeave", function(self)
		showbg2:SetAlpha(mikmaDB.ChatMods.alpha)
	end)
	if mikmaDB.ChatMods.ChatFrame4 then
		showbg2:SetNormalTexture("INTERFACE\\Icons\\Spell_ChargePositive")
	else
		showbg2:SetNormalTexture("INTERFACE\\Icons\\Spell_ChargeNegative")
	end
end

function mikma:TransparentBags()
	local a = 0.5 
	for i=1, NUM_CONTAINER_FRAMES, 1 do 
		local bt = _G["ContainerFrame"..i.."BackgroundTop"]
		if bt then bt:SetAlpha(a) end
		local bm = _G["ContainerFrame"..i.."BackgroundMiddle1"]
		if bm then bm:SetAlpha(a) end 
		local bb = _G["ContainerFrame"..i.."BackgroundBottom"]
		if bb then bb:SetAlpha(a) end
	end
	local btf = _G["BackpackTokenFrame"]
	if btf then btf:SetAlpha(a) end
end

function mikma:MoveAlertFrame()
	CastingBarFrame:SetFrameStrata("DIALOG")
	AlertFrame:ClearAllPoints()
	AlertFrame:SetPoint("TOP",CastingBarFrame,"BOTTOM",0,90)
end

-- INTERFACE\\Icons\\Spell_ChargeNegative
-- INTERFACE\\Icons\\Spell_ChargePositive

Minimap:SetScript("OnMouseWheel", function(self,arg1)
      local zoom = Minimap:GetZoom()
      if zoom == 0 and arg1 == -1 then
         return 
      else
         Minimap:SetZoom(arg1+zoom)
      end
end)
SLASH_Reload1 = "/rl"
SlashCmdList["Reload"] = function() ReloadUI() end