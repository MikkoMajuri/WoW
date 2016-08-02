local version = 0.19

if not PartyHardyDB then PartyHardyDB = {} end
if not PartyHardyDB.whitelist then PartyHardyDB.whitelist = { [string.lower(UnitName("player"))] = true, } end -- add yourself in whitelist, just in case

StaticPopupDialogs["PARTYHARDY_NAMEADD"] = {
	text = "Whitelist name in PartyHardy:\n(small case, do not add -server)",
	button1 = TEXT(ACCEPT),
	button2 = TEXT(CANCEL),
	OnAccept = function(self,data)
		local name
		if data and data.Name then
			name = data.Name
		else
			name = self.editBox:GetText()
		end
		PartyHardyDB.whitelist[string.lower(name)] = true
		ChatFrame1:AddMessage("|cFFFF9900PartyHardy: "..string.lower(name).." added to trusted list.")
		StaticPopup_Hide("PARTYHARDY_NAMEADD")
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = STATICPOPUP_NUMDIALOGS,
	OnShow = function(self,data)
		if data and data.Name then
			self.editBox:SetText(data.Name)
		else
			self.editBox:SetText("player")
		end
		self.editBox:SetFocus();
		self.editBox:HighlightText();
	end,
	hasEditBox = 1,
	maxLetters = 12,
	exclusive = 1,
	EditBoxOnEnterPressed = function(self,data)
		local name
		if data and data.Name then
			name = data.Name
		else
			local parent = self:GetParent();
			name = parent.editBox:GetText();
		end
		PartyHardyDB.whitelist[string.lower(name)] = true
		ChatFrame1:AddMessage("|cFFFF9900PartyHardy: "..string.lower(name).." added to trusted list.")
		StaticPopup_Hide("PARTYHARDY_NAMEADD")
	end,

	EditBoxOnEscapePressed = function()
		StaticPopup_Hide("PARTYHARDY_NAMEADD")
	end,
}

local orange,follow,faction,previouscommand = "|cFFFF9900"

local PartyHardy = CreateFrame("Frame")
PartyHardy:RegisterEvent("CHAT_MSG_PARTY")
PartyHardy:RegisterEvent("CHAT_MSG_PARTY_LEADER")
PartyHardy:RegisterEvent("PARTY_INVITE_REQUEST")
PartyHardy:RegisterEvent("PLAYER_ENTERING_WORLD")
PartyHardy:RegisterEvent("CHAT_MSG_ADDON")
PartyHardy:RegisterEvent("PLAYER_XP_UPDATE")
PartyHardy:RegisterEvent("PLAYER_LEVEL_UP")
PartyHardy:RegisterEvent("PLAYER_LOGIN")
PartyHardy:SetScript("OnEvent", function(self, event, ...)
	if self[event] then return self[event](self, event, ...) end
end)

local XPtable = {}

local function GetXP()
	if UnitLevel("player") < MAX_PLAYER_LEVEL_TABLE[GetAccountExpansionLevel()] then
		local level = UnitLevel("player")+1
		local xp = UnitXP("player")
		local xpmax = UnitXPMax("player")
		local perc = string.format("%.2f",(xpmax-xp)/xpmax*100)
		local message = "To level "..level..": "..perc.."% ".."("..xpmax-xp..")"
		return message -- returns the xp required for next level
	else return "" end
end

function PartyCommands(self,msg,name) -- only executed if person is whitelisted
	local msg = string.lower(msg) -- turns msg into lowercase
	local name = string.lower(name) -- turns name into lowercase
	local name = strsplit("-", name) -- splits name from 'name-server' into 'name'
	local a, b = strsplit(" ", msg, 2) -- splits message that has spaces into different commands
	if a == "!partyhardy" or a == "!ph" or a == "!?" and name == string.lower(UnitName("player")) then
		ShowUIPanel(ItemRefTooltip)
		if not ItemRefTooltip:IsShown() then ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE") end
		ItemRefTooltip:ClearLines()
		ItemRefTooltip:AddLine("PartyHardy party commands:")
		ItemRefTooltip:AddLine(" ")
		ItemRefTooltip:AddDoubleLine("EXAMPLE","Information",1,1,1,1,1,1)
		ItemRefTooltip:AddDoubleLine("!follow","Follow")
		ItemRefTooltip:AddDoubleLine("!followreset","Reset follow if it gets stuck")
		ItemRefTooltip:AddDoubleLine("!ffa","Free for All loot on")
		ItemRefTooltip:AddDoubleLine("!gl","GroupLoot on")
		ItemRefTooltip:AddDoubleLine("!ml","Master Looter on")
		ItemRefTooltip:AddDoubleLine("!pl on","Pass on Loot, accepts on/off")
		ItemRefTooltip:AddDoubleLine("!leader","Request the Party leader status")
		ItemRefTooltip:AddDoubleLine("!invite foobar","Request Party leader to party invite 'foobar'")
		ItemRefTooltip:AddDoubleLine("!mount","Summon a random mount from favorites")
		ItemRefTooltip:AddDoubleLine("!dismount","Dismount, not usable while in air")
		ItemRefTooltip:AddDoubleLine("!emote train","Order everyone to do the emote /train")
		ItemRefTooltip:AddDoubleLine("!pet","Summon a random companion from favorites")
		ItemRefTooltip:AddDoubleLine("!accept","Accept all acceptable boxes")
		ItemRefTooltip:AddDoubleLine("!version","Print the version of PartyHardy")
		ItemRefTooltip:AddDoubleLine("tnl?","Requests to next level info")
		ItemRefTooltip:Show()
	elseif a == "!follow" and name ~= string.lower(UnitName("player")) and not UnitCastingInfo("player") then
		if not PartyHardyDB.follow then
			if CheckInteractDistance(name, 4) then
				PartyHardy:RegisterEvent("AUTOFOLLOW_BEGIN")
				FollowUnit(name)
			else
				SendChatMessage("Can't follow "..name..". Out of range.", "PARTY", faction)
			end
		else
			SendChatMessage("Already following "..PartyHardyDB["follow"]..".", "PARTY", faction)
		end
	elseif a == "!followreset" and UnitIsGroupLeader(UnitName("player")) then
		PartyHardyDB.follow = nil
		SendChatMessage("follow has been reset.", "PARTY", faction)
	elseif a == "!ffa" and UnitIsGroupLeader(UnitName("player")) then
		SetLootMethod("freeforall")
	elseif a == "!gl" and UnitIsGroupLeader(UnitName("player")) then
		SetLootMethod("group")
	elseif a == "!ml" and UnitIsGroupLeader(UnitName("player")) then
		SetLootMethod("master", UnitName("player"))
	elseif a == "!pl" then
		if b == "on" then
			SetOptOutOfLoot(1)
			SendChatMessage("Passing loot: Yes.", "PARTY", faction)
		elseif b == "off" then
			SetOptOutOfLoot(nil)
			SendChatMessage("Passing loot: No.", "PARTY", faction)
		else
			ChatFrame1:AddMessage("Passing loot requires either 'on' or 'off' after the !pl")
		end
	elseif a == "!leader" and UnitIsGroupLeader(UnitName("player")) then
		PromoteToLeader(name)
	elseif a == "!invite" and UnitIsGroupLeader(UnitName("player")) then
		InviteUnit(b);
	elseif a == "!mount" and not IsMounted() and not UnitCastingInfo("player") then
		if InCombatLockdown() then
			previouscommand = "Your previous command was: !mount"
			SendChatMessage("Mounting failed, in combat.", "PARTY", faction)
			PartyHardy:RegisterEvent("PLAYER_REGEN_ENABLED")
		else
			C_MountJournal.Summon(0)
		end
	elseif a == "!dismount" and not IsFlying() then
		Dismount()
	elseif a == "!emote" then
		DoEmote(b)
	elseif a == "!pet" and not IsFlying() and not UnitCastingInfo("player") then
		local pet = math.random(1,GetNumCompanions("CRITTER"))
		CallCompanion("CRITTER",pet)
	elseif a == "!accept" then
		for i=1,STATICPOPUP_NUMDIALOGS do 
			local frame = _G["StaticPopup"..i]
			if frame:IsVisible() then
				if frame.which == "QUEST_ACCEPT" or frame.which == "DEATH" or frame.which == "RESURRECT" or frame.which == "RESURRECT_NO_SICKNESS" or frame.which == "RESURRECT_NO_TIMER" or frame.which == "DUEL_REQUESTED" or frame.which == "RECOVER_CORPSE" or frame.which == "CONFIRM_SUMMON" or frame.which == "PARTY_INVITE" or frame.which == "PARTY_INVITE_XREALM" then StaticPopup_OnClick(frame, 1) end
			end
		end
		
		local checkvisible = LFDRoleCheckPopup:IsVisible()
		local tank = LFDQueueFrameRoleButtonTank.checkButton:GetChecked()
		local healer = LFDQueueFrameRoleButtonHealer.checkButton:GetChecked()
		local dps = LFDQueueFrameRoleButtonDPS.checkButton:GetChecked()
		if checkvisible and (tank or healer or dps) then LFDRoleCheckPopupAccept_OnClick() end
		if QuestFrame:IsVisible() then QuestFrameAcceptButton:Click() end
	elseif a == "!version" then
		SendChatMessage("PartyHardy v"..version, "PARTY", faction)
	elseif a == "tnl?" then
		SendChatMessage(GetXP(), "PARTY", faction)
		SendAddonMessage("PARTYHARDY", "LEVELBROADCAST|"..GetXP(), "PARTY")
	end
end

local function CheckFriend(name)
	for i = 1, GetNumFriends() do
		if (name == GetFriendInfo(i)) then return true end -- friend is in the friendlist
	end
end

function PartyHardy:CHAT_MSG_PARTY(self,msg,name)
	local name = strsplit("-", name) -- splits name from 'name-server' into 'name'
	if PartyHardyDB.whitelist[string.lower(name)] then PartyCommands(self,msg,name) end -- checks if the name is whitelisted
end

function PartyHardy:CHAT_MSG_PARTY_LEADER(self,msg,name)
	local name = strsplit("-", name) -- splits name from 'name-server' into 'name'
	if PartyHardyDB.whitelist[string.lower(name)] then PartyCommands(self,msg,name) end-- checks if the name is whitelisted
end

function PartyHardy:PARTY_INVITE_REQUEST(self,name)
	local name = strsplit("-", name) -- splits name from 'name-server' into 'name'
	if CheckFriend(name) then -- check if the player is in your friendlist
		for i=1,STATICPOPUP_NUMDIALOGS do 
			local frame = _G["StaticPopup"..i]
			if frame:IsVisible() and frame.which == "PARTY_INVITE" or frame.which == "PARTY_INVITE_XREALM" then StaticPopup_OnClick(frame, 1) end -- auto accept party invites
		end
		if not PartyHardyDB.whitelist[string.lower(name)] then StaticPopup_Show("PARTYHARDY_NAMEADD",nil,nil,{Name = name}) end -- friend is not in the whitelist, add him?
	end
end

function PartyHardy:AUTOFOLLOW_BEGIN(self, name)
	PartyHardyDB.follow = name -- remember the name we are following
	SendAddonMessage("PARTYHARDY","FOLLOWSTART", "WHISPER", name)
	PartyHardy:RegisterEvent("AUTOFOLLOW_END")
end

function PartyHardy:AUTOFOLLOW_END(self)
	if PartyHardyDB.follow then
		SendAddonMessage("PARTYHARDY","FOLLOWSTOP", "WHISPER", PartyHardyDB.follow)
		PartyHardy:UnregisterEvent(self)
		PartyHardyDB.follow = nil
	end
end

AutoFollowStatus:SetScript("OnHide", function() -- follow stopped in unexpected way, event did not fire
	if PartyHardyDB.follow then
		SendAddonMessage("PARTYHARDY","FOLLOWSTOPSTUCK", "WHISPER", PartyHardyDB.follow)
		PartyHardy:UnregisterEvent("AUTOFOLLOW_END")
		PartyHardyDB.follow = nil
	end
end)

function PartyHardy:PLAYER_REGEN_ENABLED()
	PartyHardy:UnregisterEvent("PLAYER_REGEN_ENABLED")
	SendChatMessage("Combat ended."..previouscommand and previouscommand or "", "PARTY", faction) -- friendly reminder what we were doing while we were in the combat
	previouscommand = nil
end

function PartyHardy:PLAYER_ENTERING_WORLD()
	faction = UnitFactionGroup("player") == "Horde" and "Orcish" or "Common"
	if UnitInParty("player") then SendAddonMessage("PARTYHARDY","LEVELREQUEST","PARTY") end
end

function PartyHardy:PLAYER_LOGIN()
	RegisterAddonMessagePrefix("PARTYHARDY")
end

function PartyHardy:CHAT_MSG_ADDON(self,prefix,message,channel,name)
	if prefix == "PARTYHARDY" then
		local name = strsplit("-", name) -- splits name from 'name-server' into 'name'
		local info1,info2 = string.split("|", message) -- splits the message from 'LEVELBROADCAST|To level xx: zz.yy% (12345)' into 'LEVELBROADCAST' and 'To level xx: zz.yy% (12345)'
		if info1 == "LEVELREQUEST" and UnitLevel("player") < MAX_PLAYER_LEVEL_TABLE[GetAccountExpansionLevel()] then SendAddonMessage("PARTYHARDY", "LEVELBROADCAST|"..GetXP(), "PARTY") -- checks if the unit is at max level of current expansion
		elseif info1 == "LEVELBROADCAST" and name ~= UnitName("player") then XPtable[name] = info2
		elseif info1 == "LEVELWHISPERREQUEST" then SendAddonMessage("PARTYHARDY", "LEVELWHISPERBROADCAST|"..GetXP(), "WHISPER", name)
		elseif info1 == "LEVELWHISPERBROADCAST" then ChatFrame1:AddMessage(name..": "..info2)
		elseif info1 == "FOLLOWSTART" then ChatFrame1:AddMessage(orange.."PartyHardy: "..name.." is following you.")
		elseif info1 == "FOLLOWSTOP" then ChatFrame1:AddMessage(orange.."PartyHardy: "..name.." is no longer following you.")
		elseif info1 == "FOLLOWSTOPSTUCK" then ChatFrame1:AddMessage(orange.."PartyHardy: "..name.." is no longer following you. Maybe the character is stuck?")
		elseif info1 == "EXECUTE" then
			if PartyHardyDB.whitelist[string.lower(name)] then
				local func,err = loadstring(info2)
				if not err then
					ChatFrame1:AddMessage(name.." executed a code: "..info2)
					if name ~= UnitName("player") then func() end
				end
			end
		elseif info1 == "DING" then
			if name ~= UnitName("player") then SendChatMessage("{star} GZ "..name.." {star}","PARTY", faction) end
		end
	end
end

function PartyHardy:PLAYER_XP_UPDATE()
	if UnitInParty("player") then SendAddonMessage("PARTYHARDY", "LEVELBROADCAST|"..GetXP(), "PARTY") end
end

function PartyHardy:PLAYER_LEVEL_UP()
	if UnitInParty("player") then
		SendAddonMessage("PARTYHARDY", "LEVELBROADCAST|"..GetXP(), "PARTY") 
		SendAddonMessage("PARTYHARDY", "DING", "PARTY")
	end
end

SLASH_PartyHardy1 = "/partyhardy";
SLASH_PartyHardy2 = "/ph";
SlashCmdList["PartyHardy"] = function(msg)
	local a, b = strsplit(" ", msg, 2);
	if a == "add" then
		if b then
			PartyHardyDB.whitelist[string.lower(b)] = true
			ChatFrame1:AddMessage(orange.."PartyHardy: "..b.." added to whitelist.")
		else
			StaticPopup_Show("PARTYHARDY_NAMEADD")
		end
	elseif a == "del" or a == "remove" then
		if not b then return elseif #b < 13 then
			PartyHardyDB.whitelist[string.lower(b)] = nil
			ChatFrame1:AddMessage(orange.."PartyHardy: "..b.." removed from whitelist.")
		end
	elseif a == "list" then
		ShowUIPanel(ItemRefTooltip)
		if not ItemRefTooltip:IsShown() then ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE") end
		ItemRefTooltip:ClearLines()
		ItemRefTooltip:AddLine("PartyHardy whitelist:")
		for k,v in pairs(PartyHardyDB.whitelist) do
			if k ~= string.lower(UnitName("player")) then -- skip yourself on the list
				ItemRefTooltip:AddLine(k)
			end
		end
		ItemRefTooltip:Show()
	else ChatFrame1:AddMessage(orange.."PartyHardy accepts these commands: 'add <name>', 'del/remove <name>', 'list'.") end
end

SLASH_TNL1 = "/tnl"
SlashCmdList["TNL"] = function(name) 
	if UnitExists(name) then 
		local name = string.lower(name)
		SendAddonMessage("PARTYHARDY","LEVELWHISPERREQUEST","WHISPER",name) 
	else
		SendAddonMessage("PARTYHARDY","LEVELREQUEST","PARTY")
	end
end