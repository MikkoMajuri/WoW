NeonChatDB = {}

local chatborder = CreateFrame("Button", nil, ChatFrame1EditBox)
chatborder:SetBackdrop(GameTooltip:GetBackdrop())
chatborder:SetBackdropColor(0,0,0,0)
chatborder:SetBackdropBorderColor(0,0,0,0)
chatborder:EnableMouse(false)

local chateditbox = CreateFrame("Button", nil, ChatFrame1EditBox)
chateditbox:SetBackdrop(GameTooltip:GetBackdrop())
chateditbox:SetBackdropColor(0,0,0,0)
chateditbox:SetBackdropBorderColor(0,0,0,0)

hooksecurefunc("ChatEdit_UpdateHeader", function(editbox)
	if ACTIVE_CHAT_EDIT_BOX then
		local type = editbox:GetAttribute("chatType")
		local frame = string.match(ACTIVE_CHAT_EDIT_BOX:GetName(),"ChatFrame%d",1) or string.match(ACTIVE_CHAT_EDIT_BOX:GetName(),"GMChatFrame",1)
		
		if NeonChatDB[1] then chatborder:Hide() else chatborder:Show() end

		if ( type == "CHANNEL" ) then
			local id = GetChannelName(editbox:GetAttribute("channelTarget"))
			if id == 0 then	
				chatborder:SetBackdropBorderColor(0.5,0.5,0.5)
				chatborder:SetBackdropColor(0.5,0.5,0.5)
				chateditbox:SetBackdropColor(0.5/3,0.5/3,0.5/3)
			else 
				chatborder:SetBackdropBorderColor(ChatTypeInfo[type..id].r,ChatTypeInfo[type..id].g,ChatTypeInfo[type..id].b)
				chatborder:SetBackdropColor(ChatTypeInfo[type..id].r/3,ChatTypeInfo[type..id].g/3,ChatTypeInfo[type..id].b/3)
				chateditbox:SetBackdropColor(ChatTypeInfo[type..id].r/3,ChatTypeInfo[type..id].g/3,ChatTypeInfo[type..id].b/3)
			end
		else
			if ChatTypeInfo[type].r == nil or ChatTypeInfo[type].g == nil or ChatTypeInfo[type].b == nil then return else
				chatborder:SetBackdropBorderColor(ChatTypeInfo[type].r,ChatTypeInfo[type].g,ChatTypeInfo[type].b)
				chatborder:SetBackdropColor(ChatTypeInfo[type].r/3,ChatTypeInfo[type].g/3,ChatTypeInfo[type].b/3)
				chateditbox:SetBackdropColor(ChatTypeInfo[type].r/3,ChatTypeInfo[type].g/3,ChatTypeInfo[type].b/3)
			end
		end
		
		chatborder:SetParent(ACTIVE_CHAT_EDIT_BOX)
		chatborder:ClearAllPoints()
		chatborder:SetPoint("TOPLEFT", frame.."TopLeftTexture",0,0)
		chatborder:SetPoint("BOTTOMRIGHT", frame.."BottomRightTexture",0,1)
		chateditbox:SetParent(ACTIVE_CHAT_EDIT_BOX)
		chateditbox:ClearAllPoints()
		chateditbox:SetPoint("TOPLEFT",ACTIVE_CHAT_EDIT_BOX:GetName().."FocusLeft","TOPLEFT",4,-3)
		chateditbox:SetPoint("BOTTOMRIGHT",ACTIVE_CHAT_EDIT_BOX:GetName().."FocusRight","BOTTOMRIGHT",-4,3)
		chateditbox:SetFrameLevel(_G[frame.."EditBox"]:GetFrameLevel()-1)
		chatborder:SetFrameStrata(_G[frame]:GetFrameStrata())
		chatborder:SetFrameLevel(_G[frame]:GetFrameLevel()-1)

	else
		chatborder:SetBackdropBorderColor(0,0,0,0)
		chatborder:SetBackdropColor(0,0,0,0)
		chateditbox:SetBackdropColor(0,0,0,0)
	end
	
	for chatframe=1,CURRENT_CHAT_FRAME_ID do
		for i=6,8 do select(i, _G["ChatFrame"..chatframe.."EditBox"]:GetRegions()):Hide() end
	end
end)

SLASH_NEONCHAT1 = "/neonchat"
SLASH_NEONCHAT2 = "/nc"
SlashCmdList["NEONCHAT"] = function()
	if NeonChatDB[1] then 
		NeonChatDB[1] = nil
		print("|cFFFF9900NeonChat:|r Chat coloring |cFF00FF00ON|r")
	else
		NeonChatDB[1] = true
		print("|cFFFF9900NeonChat:|r Chat coloring |cFFFF0000OFF|r")
	end
end