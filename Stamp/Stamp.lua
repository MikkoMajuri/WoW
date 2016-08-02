local addonName, addon = ...
local dbversion = 2
local noteicon = "|TInterface\\ICONS\\INV_Scroll_10:20:20|t"
local tempBag,tempSlot,tempButton,tempID
local origs = {}

Stamp = CreateFrame("Frame")
Stamp:RegisterEvent("PLAYER_LOGIN")
Stamp.BagSlots = {}
Stamp.items = {
	"None", 			-- 1
	"|cffFF0000SELL|r", -- 2
	"|cff00FF00BANK|r", -- 3
	"|cffFFFF00MAIL|r", -- 4
	"|cff00FFFFKEEP|r", -- 5
	"|cff98FB98OPEN|r", -- 6
	"|cffFF1493USE|r", 	-- 7
	"|cffFFA500D/E|r", 	-- 8
	"|cff00BFFFAH|r", 	-- 9
	"|cffff00ffNOTE|r",	-- 10
}

-- Keep NOTE always in the last spot because of possible DB upgrade
local notenumber = #Stamp.items

StaticPopupDialogs["STAMP_ADDNOTE"] = {
	text = "Add a note to item:",
	button1 = TEXT(ACCEPT),
	button2 = TEXT(CANCEL),
	OnAccept = function(self,data)
		local note = _G[self:GetName().."EditBox"]:GetText()
		if not note or note == nil or note == "" then
			return
		end
		if StampDB and not StampDB.Notes then StampDB.Notes = {} end
		StampDB[data.itemID] = data.note
		StampDB.Notes[data.itemID] = note
		Stamp.ClearItems()
		Stamp.MarkBags()
		StaticPopup_Hide("STAMP_ADDNOTE")
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	OnShow = function(self,data)
		self.text:SetText("Add a note to item\n"..select(2,GetItemInfo(data.itemID)))
		if StampDB.Notes[data.itemID] then
			self.editBox:SetText(StampDB.Notes[data.itemID])
		else
			self.editBox:SetText("Note of "..GetItemInfo(data.itemID).." goes here.")
		end
		self.editBox:SetFocus();
		self.editBox:HighlightText();
	end,
	hasEditBox = 1,
	editBoxWidth = 350,
	exclusive = 1,
	EditBoxOnEnterPressed = function(self,data)
		if StampDB and not StampDB.Notes then StampDB.Notes = {} end
		local parent = self:GetParent();
		local note = parent.editBox:GetText();
		StampDB[data.itemID] = data.note
		StampDB.Notes[data.itemID] = note
		Stamp.ClearItems()
		Stamp.MarkBags()
		StaticPopup_Hide("STAMP_ADDNOTE")
	end,

	EditBoxOnEscapePressed = function()
		StaticPopup_Hide("STAMP_ADDNOTE")
	end,
}

function Stamp.MarkBags()
	for idx,entry in pairs(Stamp.BagSlots) do
		local itemButton = entry:GetName()
		local bag = entry:GetParent():GetID()
		local slot = entry:GetID()
		for k,v in pairs(StampDB) do
			if GetContainerItemID(bag,slot) == k then
				if _G[itemButton] and _G[itemButton].text then _G[itemButton].text:SetText(Stamp.items[v]) end
			end
		end
	end
end

function Stamp.ClearItems()
	for idx,entry in ipairs(Stamp.BagSlots) do
		if entry and entry.text then entry.text:SetText("") end
	end
end

local total = 0
local function onUpdate(self,elapsed)
	total = total + elapsed
	if total >= 0.1 then
		Stamp:SetScript("OnUpdate",nil)
		Stamp.ClearItems()
		Stamp.MarkBags()
		total = 0
	end
end

local function onUpdate()
	Stamp.ClearItems()
	Stamp.MarkBags()
end

function Stamp.BlizzardBags()
	for i=1,12 do
		for j=1,36 do
			table.insert(Stamp.BagSlots,_G["ContainerFrame"..i.."Item"..j])
		end
	end
	Stamp.Bags = true
end

function Stamp.BlizzardBankBags()
	for i=1,28 do
		table.insert(Stamp.BagSlots,_G["BankFrameItem"..i])
	end
	Stamp.Bank = true
end

function Stamp.BlizzardBankReagentBags()
	for i=1,98 do
		table.insert(Stamp.BagSlots,_G["ReagentBankFrameItem"..i])
	end
	Stamp.Reagent = true
end

function Stamp.CreateText()
	for idx,entry in pairs(Stamp.BagSlots) do
		if entry and not entry.text then
			local text = Stamp:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
			text:SetParent(entry)
			text:SetPoint("TOP",entry,"TOP",2,-3)
			entry.text = text
		end
	end
end

Stamp:SetScript("OnEvent", function(self,event)
	if event == "PLAYER_LOGIN" then
		self:RegisterEvent("BAG_UPDATE_DELAYED")
		self:RegisterEvent("BANKFRAME_OPENED")
		self:RegisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED")
		self:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
		self:UnregisterEvent(event)
		
		if not StampDB then StampDB = { DBVersion = dbversion, Notes = {},} end
		if StampDB and not StampDB.Notes then StampDB.Notes = {} end
		-- Convert first version of Database to new version, swap old note number into new number
		if not StampDB.DBVersion or StampDB.DBVersion ~= dbversion then
			for k,v in pairs(StampDB.Notes) do
			   if StampDB[k] then 
					StampDB[k] = notenumber
			   end
			end
			ChatFrame1:AddMessage("|cFFFF9900Stamp:|r Database has been updated to version "..dbversion)
			StampDB.DBVersion = dbversion
		end

		if Stamp.Custom then return else
			if not Stamp.Bags then
				Stamp.BlizzardBags()
			end
			if not Stamp.Bank then
				Stamp.BlizzardBankBags()
			end
			Stamp.CreateText()
		end
	elseif event == "BAG_UPDATE_DELAYED" or event == "BANKFRAME_OPENED" or event == "PLAYERREAGENTBANKSLOTS_CHANGED" or event == "PLAYERBANKSLOTS_CHANGED" then
		Stamp.ClearItems()
		Stamp.MarkBags()
	end
end)

local function hookOnModifiedClick(self,button)
	if IsControlKeyDown() and button == 'RightButton' then
		tempBag = self:GetParent():GetID()
		tempSlot = self:GetID()
		tempButton = self:GetName()
		tempID = GetContainerItemID(tempBag,tempSlot)
		if tempID then
			ToggleDropDownMenu(1, nil, StampDropDown, self:GetName(), 0, 0)
		end
	end
end

hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", function(self,button) hookOnModifiedClick(self,button) end)
hooksecurefunc("BankFrameItemButtonGeneric_OnModifiedClick", function(self,button) hookOnModifiedClick(self,button) end)

hooksecurefunc("ToggleBackpack", function()
	C_Timer.NewTimer(0.1, function() onUpdate() end)
end)

hooksecurefunc("ToggleBag", function()
	Stamp.ClearItems()
	Stamp.MarkBags()
end)

hooksecurefunc("CloseBag", function()
	C_Timer.NewTimer(0.1, function() onUpdate() end)
end)

ReagentBankFrame:HookScript("OnShow", function()
	if Stamp.Custom then return else
		if not Stamp.Reagent then
			Stamp.BlizzardBankReagentBags()
		end
	end
	Stamp.CreateText()
	Stamp.MarkBags()
end)

if not StampDropDown then
   CreateFrame("Button", "StampDropDown", UIParent, "UIDropDownMenuTemplate")
end

local function OnClick(self)
	UIDropDownMenu_SetSelectedID(StampDropDown, 1)
	if self:GetID() == 1 then
		StampDB[tempID] = nil
		StampDB.Notes[tempID] = nil
		Stamp.ClearItems()
		Stamp.MarkBags()
	elseif self:GetID() == notenumber then
		if StampDB and not StampDB.Notes then StampDB.Notes = {} end
		StaticPopup_Show("STAMP_ADDNOTE",nil,nil,{itemID = tempID, note = self:GetID()})
	else
		StampDB[tempID] = self:GetID()
		Stamp.ClearItems()
		Stamp.MarkBags()
	end
end

local function initialize(self, level)
	for idx,entry in pairs(Stamp.items) do
		info = UIDropDownMenu_CreateInfo()
		info.text = entry
		info.value = entry
		info.notCheckable = 1
		info.func = OnClick
		UIDropDownMenu_AddButton(info, level)
	end
end

UIDropDownMenu_Initialize(StampDropDown, initialize)
UIDropDownMenu_SetWidth(StampDropDown, 100);
UIDropDownMenu_SetButtonWidth(StampDropDown, 124)
UIDropDownMenu_SetSelectedID(StampDropDown, 1)
UIDropDownMenu_JustifyText(StampDropDown, "LEFT")

-- Code from this point on is 1:1 copypaste from my other addon, Post-it :)
local showntip

local function AddLines(frame, line, ...)
	if not line then return end
	addon:AddSpacerLine(frame, 1, 1, 0, 1)
	frame:AddLine(noteicon.." "..line, 1, 0, 1)
end

local function OnTooltipSetItem(frame, ...)
	local name, link = frame:GetItem()
	if link then
		local id = tonumber(link:match("item:(%d+):"))
		if StampDB.Notes and StampDB.Notes[id] then AddLines(frame, string.split("`", StampDB.Notes[id])) end
	end
	if origs[frame] then return origs[frame](frame, ...) end
end

for _,frame in pairs{GameTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2} do
	origs[frame] = frame:GetScript("OnTooltipSetItem")
	frame:SetScript("OnTooltipSetItem", OnTooltipSetItem)
end

local tooltipHooked = {}
local tooltipLines = {}
function addon:AddSpacerLine(tooltip, height, r, g, b, a)
    if not tooltipLines[tooltip] then
        tooltipLines[tooltip] = {}
    end

    if not tooltipHooked[tooltip] then
        tooltip:HookScript("OnTooltipCleared", function(self)
            for k, line in pairs(tooltipLines[self]) do 
                line:Hide()
            end
        end)
        tooltipHooked[tooltip] = true
    end

    tooltip:AddDoubleLine(" "," ")
    local num = tooltip:NumLines()
    local line = tooltipLines[tooltip][num]
    if not line then
        line = tooltip:CreateTexture(nil,"ARTWORK")
        line:SetPoint("LEFT", tooltip:GetName().."TextLeft"..num, "LEFT")
        line:SetPoint("RIGHT", tooltip:GetName().."TextRight"..num, "RIGHT")
        tooltipLines[tooltip][num] = line
    end
    line:SetHeight(height or 1)
    line:SetTexture(r or NORMAL_FONT_COLOR.r, g or NORMAL_FONT_COLOR.g, b or NORMAL_FONT_COLOR.b, a or 1)
    line:Show()
end
