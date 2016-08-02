local font = "NumberFont_Shadow_Med"
local width = 500
local mf = LibStub("LibMessageFrame")

PartyHardyMF = mf.New("PartyHardyMF", width, 100, "BOTTOMLEFT", ChatFrame4, "TOPLEFT", 0, 40)
local row = mf.Row(PartyHardyMF,font,UnitName("player"),UnitName("player"))
local prevrow = row

local function partycheck()
	local num = GetNumGroupMembers()
	if num > 1 then
		for i=1,num do
			local name = UnitName("party"..num-1)
			if name and PartyHardyDB.whitelist[string.lower(name)] and UnitLevel(name) < MAX_PLAYER_LEVEL_TABLE[GetAccountExpansionLevel()]then
				mf.ShowAll(PartyHardyMF)
				local row = mf.Row(PartyHardyMF,font,UnitName("party"..num-1),UnitName("party"..num-1),"TOPLEFT",prevrow,"BOTTOMLEFT")
			end
		end
	elseif num <= 1 then
		mf.HideAll(PartyHardyMF)
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_ADDON")
frame:RegisterEvent("UNIT_OTHER_PARTY_CHANGED")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("UNIT_CONNECTION")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

RegisterAddonMessagePrefix("PARTYHARDY")

frame:SetScript("OnEvent", function(self,event,...)
	if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_LOGIN" or event == "GROUP_ROSTER_UPDATE" or event == "UNIT_CONNECTION" or event == "UNIT_OTHER_PARTY_CHANGED" then
		partycheck()
	elseif event == "CHAT_MSG_ADDON" then
		local addon,broadcast,channel,namefull,name = ...
		local mesg1,mesg2 = string.split("|",broadcast)
		if mesg1 == "LEVELBROADCAST" then
			--ChatFrame3:AddMessage(name.." - "..mesg2)
			for k,v in pairs(PartyHardyMF.rows) do
				if v.ident == name then
					v.text:SetText(name.." - "..mesg2)
				end
			end
		end
	end
end)

local tmptable = {}
for k,v in pairs(PartyHardyMF.rows) do
	if v.visible then
		table.insert(tmptable,v)
	end
end

PartyHardyMF:SetSize(width,row.text:GetHeight() * #tmptable)
