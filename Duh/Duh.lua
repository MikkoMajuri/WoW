-- Let's be local
local usedTooltips = 0
local playername = UnitName("player")
local defaults = { realm = { notes={}, names={}, }, global = { minimap = {}, } }
local towns = {[381]=1,[321]=1,[471]=1,[362]=1,[341]=1,[480]=1,[301]=1,[382]=1,[481]=1,[504]=1,[1011]=1,[1009]=1,[976]=17,[971]=17,[823]=18,}
local tooltipPool = {}
local db,town,instance,pvp,modifyNote,refreshNotes,refreshNames,tempzone
local dropdown = {}
local icon = LibStub("LibDBIcon-1.0", true)
local Duh = CreateFrame("Frame")
local DuhConfig = CreateFrame("Frame","Duh",UIParent)
local DuhAddNote,DuhManageNotes,DuhManageNames
local EDGEGAP, ROWHEIGHT, ROWGAP = 16, 20, 2

local function dprint(text)
	UIErrorsFrame:AddMessage("|cffff5500Duh:|r "..text)
end

local function SortFunction(a,b)
	return a:GetName() < b:GetName()
end

local function savePosition(frame)
	local dbslot = frame.Shown
	local x,y = frame:GetLeft(), frame:GetTop()
	local s = frame:GetEffectiveScale()
	x,y = x*s,y*s
	if db.realm.notes[dbslot] then
		db.realm.notes[dbslot]["PosX"] = x
		db.realm.notes[dbslot]["PosY"] = y
	end
end

local function loadPosition(frame)
	local dbslot = _G[frame:GetName()]["Shown"]
	local x = db.realm.notes[dbslot] and db.realm.notes[dbslot]["PosX"]
	local y = db.realm.notes[dbslot] and db.realm.notes[dbslot]["PosY"]
	local s = frame:GetEffectiveScale()
	if not x or not y then
		frame:ClearAllPoints()
		frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		return
	end
	x,y = x/s,y/s
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
end

local function releaseTooltip(frame,value)
	if db.realm.notes[value] and db.realm.notes[value]["shown"] then db.realm.notes[value]["shown"] = nil end
	frame:Hide()
	table.insert(tooltipPool, frame)
	table.sort(tooltipPool,SortFunction)
end

local function closeTooltips()
	for i = 1, usedTooltips do
		pcall(loadstring("DuhTooltip" .. i .. ":Hide()"))
	end

	for k, v in pairs(db.realm.notes) do
		if v["shown"] then v["shown"] = nil end
	end
end

local function showHelp(self)
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("LEFT", self, "RIGHT")
	GameTooltip:SetFrameLevel(self:GetFrameLevel()+1)
	GameTooltip:ClearLines()
	GameTooltip:AddLine("Click to close.")
	GameTooltip:AddLine("Ctrl+Click to close all open notes.")
	GameTooltip:AddLine("Shift+Click to manage notes.")
	GameTooltip:Show()
end

local function hideHelp()
	GameTooltip:Hide()
end

local function createTooltip(text,scale,value)
	local temp,tooltip
	if( #(tooltipPool) > 0 ) then
		temp = tooltipPool[1]
		table.remove(tooltipPool, 1)
	end
	if not temp then
		usedTooltips = usedTooltips + 1
		local tooltipname = "DuhTooltip"..usedTooltips
		tooltip = CreateFrame("GameTooltip",tooltipname,UIParent,"GameTooltipTemplate")
		local close = CreateFrame("Button", nil, tooltip, "UIPanelCloseButton")
		close:SetPoint("TOPRIGHT")
		close:SetScript("OnEnter", showHelp)
		close:SetScript("OnLeave", hideHelp)
		close:SetScript("OnClick", function()
			if IsControlKeyDown() then
				closeTooltips()
			elseif IsShiftKeyDown() then
				DuhConfig:Show()
				DuhManageNotes:Show()
			else
				releaseTooltip(tooltip,tooltip.Shown)
			end
		end)
	else
		tooltip = temp
	end
	tooltip:SetPadding(16);
	tooltip:SetOwner(UIParent, "ANCHOR_NONE")
	tooltip:RegisterForDrag("LeftButton")
	tooltip:EnableMouse(true)
	tooltip:SetMovable(true)
	tooltip:SetScript("OnDragStart", function(self) self:StartMoving() end)
	tooltip:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		savePosition(self)
	end)
	tooltip:SetBackdropBorderColor(1,0.3,0,1)
	tooltip:ClearLines()
	tooltip:AddLine(text)
	tooltip:SetScale(scale)
	_G[tooltip:GetName().."TextLeft1"]:SetFont(GameFontHighlightSmall:GetFont())
	tooltip:Show()
	tooltip:SetWidth(_G[tooltip:GetName().."TextLeft1"]:GetWidth()+42)
	tooltip.Shown = value
	loadPosition(tooltip)
	return tooltip
end

local eventtable = {
	[1] = {"In Town.","Town"},
	[2] = {"In Instance.","Instance"},
	[3] = {"In PvP.","PvP"},
	[4] = {"At Login.","Login","PLAYER_LOGIN"},
	[5] = {"At Merchant.","Merchant","MERCHANT_SHOW"},
	[6] = {"At Ready Check.","Ready Check","READY_CHECK"},
	[7] = {"At Mailbox.","Mailbox","MAIL_SHOW"},
	[8] = {"When Trading with someone.","Trade","TRADE_SHOW"},
	[9] = {"When choosing a Flight Path.","Flight Master","TAXIMAP_OPENED"},
	[10] = {"At the Guild Bank.","Guild Bank","GUILDBANKFRAME_OPENED"},
	[11] = {"At the Bank.","Bank","BANKFRAME_OPENED"},
	[12] = {"After changing Talent Specs.","Talent Swap","ACTIVE_TALENT_GROUP_CHANGED"},
	[13] = {"When Auction House is open.","Auction House","AUCTION_HOUSE_SHOW"},
	[14] = {"When Profession Window is open.","Profession Window","TRADE_SKILL_SHOW"},
	[15] = {"When you gain a Level.","Next Level","PLAYER_LEVEL_UP"},
	[16] = {"At Garrison Mission table","Mission Table","GARRISON_MISSION_NPC_OPENED"},
	[17] = {"In Garrison (Only Heartstone/Flight)","Garrison"},
	[18] = {"In Darkmoon Faire","Darkmoon Faire"},
}

local function checkNote(event)
	for k,v in pairs(db.realm.notes) do
		if not v["showwith"] or v["showwith"] == playername then
			if v[event] and not v["shown"] then
				createTooltip(v["note"],v["scale"] and v["scale"] or 1,k)
				v["shown"] = true
				if v["showonce"] then
					table.remove(db.realm.notes,k)
				end
			end
		end
	end
end

local function zoneCheck()
	local zone = GetCurrentMapAreaID()
	local instance = select(2,GetInstanceInfo())
	if not town and towns[zone] then
		tempzone = zone
		town = true
		instance = nil
		pvp = nil
		checkNote(towns[zone])
	end
	if (town or instance or pvp) and towns[zone] then
		tempzone = zone
		town = nil
		instance = nil
		pvp = nil
	end
	if (instance == "party" or instance == "raid") then
		print(instance)
		tempzone = nil
		instance = true
		town = nil
		pvp = nil
		checkNote(2)
	end
	if (instance == "pvp" or instance == "arena") then
		tempzone = nil
		instance = nil
		town = nil
		pvp = true
		checkNote(3)
	end
end

local function colorify()
	local playerclass,PLAYERCLASS = UnitClass("player")
	local r,g,b = RAID_CLASS_COLORS[PLAYERCLASS].r,RAID_CLASS_COLORS[PLAYERCLASS].g,RAID_CLASS_COLORS[PLAYERCLASS].b
	return string.format("|cff%02x%02x%02x", r*255, g*255, b*255)
end

local function addName(name)
	local playername = UnitName("player")
	local classcolorhex = colorify()
	local found = false
	if name then
		playername = name
		classcolorhex = "|cff909090"
	else
		for k,v in pairs(db.realm.names) do
			if v[1] == playername then
				v[2] = classcolorhex..playername.."|r"
				found = true
			end
		end
	end
	if not found then
		table.insert(db.realm.names,{playername,classcolorhex..playername.."|r"})
		dprint("Added name "..classcolorhex..playername.."|r in character list")
	end
	if refreshNames then refreshNames() end
end

local function changeName()
	local playername = UnitName("player")
	for k,v in pairs(db.realm.names) do
		if v[1] == playername then
			local classcolorhex = colorify()
			v[2] = classcolorhex..playername.."|r"
		end
	end
	if refreshNames then refreshNames() end
end

local function MakeButton(width,height,parent)
	if not parent then parent = DuhConfig end
	local butt = CreateFrame("Button", nil, parent)
	butt:SetWidth(width)
	butt:SetHeight(height)
	butt:SetHighlightFontObject(GameFontHighlightSmall)
	butt:SetNormalFontObject(GameFontNormalSmall)
	butt:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
	butt:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
	butt:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
	butt:SetDisabledTexture("Interface\\Buttons\\UI-Panel-Button-Disabled")
	butt:GetNormalTexture():SetTexCoord(0, 0.625, 0, 0.6875)
	butt:GetPushedTexture():SetTexCoord(0, 0.625, 0, 0.6875)
	butt:GetHighlightTexture():SetTexCoord(0, 0.625, 0, 0.6875)
	butt:GetDisabledTexture():SetTexCoord(0, 0.625, 0, 0.6875)
	butt:GetHighlightTexture():SetBlendMode("ADD")
	
	return butt
end

local tooltipHooked = {}
local tooltipLines = {}
local function AddSpacerLine(tooltip, height, r, g, b, a)
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

Duh.LDB = LibStub("LibDataBroker-1.1"):NewDataObject("Duh", {
	type = "data feed",
	text = "Duh notes, click to add new",
	icon = "INTERFACE\\ICONS\\INV_Scroll_01",
	OnClick = function() 
		if DuhConfig:IsVisible() then DuhConfig:Hide() else DuhConfig:Show() end
	end,
})

local dataobj = Duh.LDB
dataobj.OnTooltipShow = function(tooltip)
	tooltip:AddLine("|cffff5500Duh|r")
	tooltip:AddLine(" ")
	tooltip:AddDoubleLine("Note","Show with event")
	AddSpacerLine(tooltip, 2, 1, 0, 0)
	for k,v in pairs(db.realm.notes) do
		if k <= 20 then
			local temptable = {}
			for i=1,#eventtable do
				if v[i] then
					table.insert(temptable,eventtable[i][2])
				end
			end
			local note = v["note"]
			if #v["note"] > 30 then note = string.sub(note, 1, 30).."..." end
			local notetext = table.concat(temptable,", ")
			if v["showonce"] then notetext = notetext..", |cFFFF0000Show once|r" end
			if v["showwith"] then

				local textname
				for i=1,#db.realm.names do
					if db.realm.names[i][1] == v["showwith"] then
						textname = db.realm.names[i][2]
					end
				end

				notetext = notetext.." ("..textname..")"
			end
			tooltip:AddDoubleLine(note,notetext,1,1,1,0,1,0)
		elseif k > 20 then
			tooltip:AddLine(#db.realm.notes - 5 .." Notes more...")
			break
		end
	end
end

Duh:RegisterEvent("PLAYER_LOGIN")
Duh:RegisterEvent("MERCHANT_SHOW")
Duh:RegisterEvent("ZONE_CHANGED")
Duh:RegisterEvent("ZONE_CHANGED_NEW_AREA")
Duh:RegisterEvent("READY_CHECK")
Duh:RegisterEvent("MAIL_SHOW")
Duh:RegisterEvent("TRADE_SHOW")
Duh:RegisterEvent("TAXIMAP_OPENED")
Duh:RegisterEvent("GUILDBANKFRAME_OPENED")
Duh:RegisterEvent("BANKFRAME_OPENED")
Duh:RegisterEvent("AUCTION_HOUSE_SHOW")
Duh:RegisterEvent("TRADE_SKILL_SHOW")
Duh:RegisterEvent("PLAYER_LEVEL_UP")
Duh:RegisterEvent("GARRISON_MISSION_NPC_OPENED")

--[[ GUI STARTS HERE ]]
local function createGUI()
	-- <DuhConfig>
 	do
		DuhConfig:SetSize(700,500)
		local backdrop = GameTooltip:GetBackdrop()
		DuhConfig:SetBackdrop(backdrop)
		DuhConfig:SetPoint("CENTER",UIParent)
		DuhConfig:SetBackdropBorderColor(1,0.3,0,1)
		DuhConfig:SetBackdropColor(0,0,0,0.5)
		tinsert(UISpecialFrames, DuhConfig:GetName())
		local title, subtitle = LibStub("tekKonfig-Heading").new(DuhConfig, "Duh - Note AddOn", "")
		DuhConfig:RegisterForDrag("LeftButton")
		DuhConfig:SetMovable(true)
		DuhConfig:EnableMouse(true)
		DuhConfig:SetClampedToScreen(true)
		DuhConfig:Hide()
		DuhConfig:SetScript("OnDragStart", function(self)
			self:StartMoving()
		end)
		DuhConfig:SetScript("OnDragStop", function(self)
			self:StopMovingOrSizing()
		end)

		local close = CreateFrame("Button", nil, DuhConfig, "UIPanelCloseButton")
		close:SetPoint("TOPRIGHT")
		close:SetScript("OnClick", function(self)
			  DuhConfig:Hide()
		end)
	end
	-- </DuhConfig>

	-- <DuhAddNote>
	do
		DuhAddNote = CreateFrame("Frame",nil,DuhConfig)
		DuhAddNote:SetSize(690,430)
		local backdrop = GameTooltip:GetBackdrop()
		DuhAddNote:SetBackdrop(backdrop)
		DuhAddNote:SetPoint("BOTTOM",DuhConfig,"BOTTOM",0,5)
		DuhAddNote:SetBackdropBorderColor(1,0.3,0,1)
		DuhAddNote:SetBackdropColor(0,0,0,0.5)
		DuhAddNote:Hide()
		DuhAddNote:SetParent(DuhConfig)

		local title = DuhAddNote:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		title:SetPoint("TOPLEFT", 16, -16)
		title:SetText("Add Note")

		local subtitle = DuhAddNote:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		subtitle:SetHeight(25)
		subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
		subtitle:SetPoint("RIGHT", DuhAddNote, -32, 0)
		subtitle:SetNonSpaceWrap(true)
		subtitle:SetJustifyH("LEFT")
		subtitle:SetJustifyV("TOP")
		subtitle:SetText("This panel can be used to add/edit notes. Notes are server-wide.")

		local LINEHEIGHT, maxoffset, offset = 12, 0, 0

		local f = CreateFrame("Frame",nil,DuhAddNote)
		f:SetHeight(150)
		f:SetWidth(400)
		f:SetPoint("TOPLEFT",subtitle,"BOTTOMLEFT", 0, 0)
		f:SetPoint("RIGHT",subtitle,"BOTTOMRIGHT", 0,0)
		f:SetBackdrop(GameTooltip:GetBackdrop())
		f:SetBackdropColor(0,0,0,1)
		f:SetBackdropBorderColor(1,1,1,1)
		f:EnableMouse()

		local scroll = CreateFrame("ScrollFrame", nil, f)
		scroll:SetPoint("TOPLEFT", 5, -5)
		scroll:SetPoint("BOTTOMRIGHT", -5, 5)
		local HEIGHT = scroll:GetHeight()

		local editbox = CreateFrame("EditBox", nil, scroll)
		scroll:SetScrollChild(editbox)
		editbox:SetPoint("TOP")
		editbox:SetPoint("LEFT")
		editbox:SetPoint("RIGHT")
		editbox:SetHeight(1000)
		editbox:SetFontObject(GameFontHighlightSmall)
		editbox:SetTextInsets(2,2,2,2)
		editbox:SetMultiLine(true)
		editbox:SetAutoFocus(false)
		editbox:SetScript("OnEscapePressed", function()
			editbox:ClearFocus()
			DuhAddNote:Hide()
		end)
		editbox:SetScript("OnEditFocusLost", function(self) editbox:ClearFocus() end)
		editbox:SetScript("OnShow", function(self)
			self:SetText("")
			self:SetFocus()
		end)

		local function doscroll(v)
			offset = math.max(math.min(v, 0), maxoffset)
			scroll:SetVerticalScroll(-offset)
			editbox:SetPoint("TOP", 0, offset)
		end

		editbox:SetScript("OnCursorChanged", function(self, x, y, width, height)
			LINEHEIGHT = height
			if offset < y then
				doscroll(y)
			elseif math.floor(offset - HEIGHT + height*2) > y then
				local v = y + HEIGHT - height*2
				maxoffset = math.min(maxoffset, v)
				doscroll(v)
			end
		end)

		scroll:UpdateScrollChildRect()
		scroll:EnableMouseWheel(true)
		scroll:SetScript("OnMouseWheel", function(self, val) doscroll(offset + val*LINEHEIGHT*3) end)

		local dropdown1 = CreateFrame("Frame", "DuhDropDown1", DuhAddNote, "UIDropDownMenuTemplate")
		dropdown1:SetPoint("TOPLEFT", f, "BOTTOMLEFT", -15, -5)

		local function OnClick1(self)
			UIDropDownMenu_SetSelectedValue(dropdown1, self.value)
			if self.value == "All" then
				dropdown["showwith"] = nil
			else
				dropdown["showwith"] = self.value
			end
		end

		local function initialize(self, level)
			local info = {}
			info.text = "All characters"
			info.value = "All"
			info.func = OnClick1
			UIDropDownMenu_AddButton(info)

			for k,v in pairs(db.realm.names) do
				local info = UIDropDownMenu_CreateInfo()
				info.text = v[2]
				info.value = v[1]
				info.func = OnClick1
				UIDropDownMenu_AddButton(info, level)
			end
		end

		UIDropDownMenu_Initialize(dropdown1, initialize)
		UIDropDownMenu_SetWidth(dropdown1, 150);
		UIDropDownMenu_SetButtonWidth(dropdown1, 124)
		UIDropDownMenu_SetSelectedID(dropdown1, 1)
		UIDropDownMenu_JustifyText(dropdown1, "LEFT")
		UIDropDownMenu_SetText(dropdown1,"All characters")

		local slider2 = CreateFrame("Slider", "DuhSlider1", DuhAddNote, "OptionsSliderTemplate")
		slider2:SetWidth(144)
		slider2:SetHeight(17)
		slider2:SetOrientation("HORIZONTAL")
		slider2:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
		slider2:SetMinMaxValues(1,3)
		slider2:SetValueStep(1)
		slider2:SetValue(1)

		slider2.tooltipText = 'Set the size of the note'
		_G[slider2:GetName() .. 'Low']:SetText('Normal')
		_G[slider2:GetName() .. 'High']:SetText('Huge')
		_G[slider2:GetName() .. 'Text']:SetText('Size')
		slider2:SetScript("OnValueChanged", function(self, newvalue)
			dropdown["scale"] = newvalue
		end)

		slider2:SetPoint("BOTTOM", f, "BOTTOM", 0, -30)
		slider2:Show()

		local function Update(self) slider2:SetValue(dropdown["scale"] and dropdown["scale"] or 1) end
		slider2:SetScript("OnShow", Update)
		Update(DuhConfig)

		local dropdown3 = CreateFrame("Frame", "DuhDropDown3", DuhAddNote, "UIDropDownMenuTemplate")
		dropdown3:SetPoint("TOPRIGHT", f, "BOTTOMRIGHT", 15, -5)

		local function OnClick3(self)
			if self.checked then
				if self.value ~= "showonce" then
					dropdown[self.value] = true
				else
					dropdown["showonce"] = true
				end
			else
				if self.value ~= "showonce" then
					dropdown[self.value] = nil
				else
					dropdown["showonce"] = nil
				end
			end
		end

		local function initialize3(self, level)
			local info = {}
			info.text = "|cffff0000Only once.|r"
			info.value = "showonce"
			info.isNotRadio = true
			info.keepShownOnClick = 1
			info.checked = dropdown["showonce"] and true or false
			info.func = OnClick3
			UIDropDownMenu_AddButton(info, level)

			for i=1,#eventtable do
				local info = UIDropDownMenu_CreateInfo()
				info.text = eventtable[i][1]
				info.value = i
				info.isNotRadio = true
				info.keepShownOnClick = 1
				info.checked = dropdown[i] and true or false
				info.func = OnClick3
				UIDropDownMenu_AddButton(info, level)
			end
		end

		UIDropDownMenu_Initialize(dropdown3, initialize3)
		UIDropDownMenu_SetWidth(dropdown3, 150);
		UIDropDownMenu_SetButtonWidth(dropdown3, 124)
		UIDropDownMenu_JustifyText(dropdown3, "LEFT")
		UIDropDownMenu_SetText(dropdown3,"Show note:")

		local butt = MakeButton(80,22,f)
		butt:SetPoint("BOTTOMLEFT", DuhAddNote, "BOTTOMLEFT", 5, 5)
		butt:SetScale(1.5)
		butt:SetText("Add Note")
		butt:SetScript("OnClick", function()
			local temp = false
			for i=1,#eventtable do
				if dropdown[i] then
					temp = true
				end
			end
			if not temp then
				dprint("Forgot to select event?")
			elseif editbox:GetText() == "" or editbox:GetText() == nil then
				dprint("Not going to add empty note, are we?")
			else
				dropdown["note"] = editbox:GetText()
				UIDropDownMenu_SetSelectedID(dropdown1, 1)
				UIDropDownMenu_SetText(dropdown1, "All Characters")
				editbox:SetText("")
				CloseDropDownMenus()
				if not modifyNote then
					table.insert(db.realm.notes,dropdown)
					dprint("Note added!")
				else
					db.realm.notes[modifyNote] = dropdown
					butt:SetText("Add Note")
					dprint("Modified previous entry")
				end
				dropdown = {}
			end
			modifyNote = nil
		end)

		local function hideReset()
			dropdown = {}
			UIDropDownMenu_SetSelectedID(dropdown1, 1)
			UIDropDownMenu_SetText(dropdown1,"All characters")
			butt:SetText("Add Note")
			modifyNote = nil
		end
		DuhAddNote:SetScript("OnHide", hideReset)

		local function resetChecked()
			if not modifyNote then
				hideReset()
			else
				butt:SetText("Edit Note")
				editbox:SetText(dropdown["note"])
				for k,v in pairs(db.realm.names) do
					if dropdown["showwith"] == v[1] then
						UIDropDownMenu_SetSelectedValue(dropdown1, v[1])
						UIDropDownMenu_SetText(dropdown1, v[2])
					end
				end
			end
		end
		DuhAddNote:SetScript("OnShow", function()
			DuhManageNotes:Hide()
			DuhManageNames:Hide()
			resetChecked()
		end)
	end
	-- </DuhAddNote>

	-- <DuhManageNotes>
	do
		DuhManageNotes = CreateFrame("Frame",nil,DuhConfig)
		DuhManageNotes:SetSize(690,430)
		local backdrop = GameTooltip:GetBackdrop()
		DuhManageNotes:SetBackdrop(backdrop)
		DuhManageNotes:SetPoint("BOTTOM",DuhConfig,"BOTTOM",0,5)
		DuhManageNotes:SetBackdropBorderColor(1,0.3,0,1)
		DuhManageNotes:SetBackdropColor(0,0,0,0.5)
		DuhManageNotes:Hide()
		DuhManageNotes:SetParent(DuhConfig)
		local title = DuhManageNotes:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		title:SetPoint("TOPLEFT", 16, -16)
		title:SetText("Manage Notes")

		local subtitle = DuhManageNotes:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		subtitle:SetHeight(25)
		subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
		subtitle:SetPoint("RIGHT", DuhManageNotes, -32, 0)
		subtitle:SetNonSpaceWrap(true)
		subtitle:SetJustifyH("LEFT")
		subtitle:SetJustifyV("TOP")
		subtitle:SetText("This panel can be used to edit/delete notes.")

		local rows, anchor = {}
		local green = "|cFF00FF00"
		local red = "|cFFFF0000"

		local function OnEnter(self)
			GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
			local value = self.number
			GameTooltip:AddLine(db.realm.notes[value]["note"], nil, nil, nil, true)

			if db.realm.notes[value]["showwith"] then
				for k,v in pairs(db.realm.names) do
					if db.realm.notes[value]["showwith"] == v[1] then
						GameTooltip:AddLine("Show only with character: "..v[2])
					end
				end
			end

			if db.realm.notes[value]["showonce"] then
				GameTooltip:AddLine(red.."Show note once.|r")
			end

			local temptable = {}
			for k,v in pairs(eventtable) do
				if db.realm.notes[value][k] then table.insert(temptable,green..v[2].."|r") end
			end

			GameTooltip:AddLine("Show with: "..table.concat(temptable,", "),nil,nil,nil,1)
			GameTooltip:Show()
		end

		local function OnLeave() GameTooltip:Hide() end

		local function ShowOnClick(self)
			local value = self.number
			ShowUIPanel(ItemRefTooltip)
			if not ItemRefTooltip:IsShown() then ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE") end
			ItemRefTooltip:ClearLines()
			ItemRefTooltip:AddLine("Duh note:")
			ItemRefTooltip:AddLine(db.realm.notes[value].note)
			ItemRefTooltip:Show()
		end

		local function DeleteOnClick(self)
			local value = self:GetParent().number
			table.remove(db.realm.notes,value)
			refreshNotes()
		end

		local function EditOnClick(self)
			local value = self:GetParent().number
			modifyNote = value
			for k,v in pairs(db.realm.notes[value]) do
				dropdown[k] = v
			end
			DuhAddNote:Show()
		end

		for i=1,16 do
			local row = CreateFrame("Button", nil, DuhManageNotes)
			if not anchor then row:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, 0)
			else row:SetPoint("TOP", anchor, "BOTTOM", 0, -ROWGAP) end
			row:SetPoint("LEFT", EDGEGAP, 0)
			row:SetPoint("RIGHT", -EDGEGAP*2-8, 0)
			row:SetHeight(ROWHEIGHT)
			anchor = row
			rows[i] = row

			local deletebutton = MakeButton(45,22,row)
			deletebutton:SetPoint("RIGHT")
			deletebutton:SetText("Delete")
			deletebutton:SetScript("OnClick", DeleteOnClick)
			row.deletebutton = deletebutton

			local editbutton = MakeButton(30,22,row)
			editbutton:SetPoint("RIGHT",deletebutton,"LEFT")
			editbutton:SetText("Edit")
			editbutton:SetScript("OnClick", EditOnClick)
			row.editbutton = editbutton

			local title = row:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
			title:SetPoint("LEFT")
			title:SetPoint("RIGHT",editbutton,"LEFT",0,0)
			title:SetHeight(ROWHEIGHT)
			title:SetJustifyH("LEFT")
			row.title = title

			row:SetScript("OnEnter", OnEnter)
			row:SetScript("OnLeave", OnLeave)
			row:SetScript("OnClick", ShowOnClick)
		end

		local scrollbar = LibStub("tekKonfig-Scroll").new(DuhManageNotes, nil, #rows/2)
		scrollbar:ClearAllPoints()
		scrollbar:SetPoint("TOP", rows[1], 0, -16)
		scrollbar:SetPoint("BOTTOM", rows[#rows], 0, 16)
		scrollbar:SetPoint("RIGHT", -16, 0)
		scrollbar:SetMinMaxValues(0, math.max(0, #db.realm.notes-#rows))
		scrollbar:SetValue(0)

		local offset = 0
		function refreshNotes()
			if not DuhManageNotes:IsVisible() then return end
			scrollbar:SetMinMaxValues(0, math.max(0, #db.realm.notes-#rows))
			for i,row in ipairs(rows) do
				if (i + offset) <= #db.realm.notes then
					local title = db.realm.notes[i + offset] and db.realm.notes[i + offset]["note"]
					row.deletebutton:Show()
					row.title:SetText(title)
					row.number = i + offset
					row:Show()
				else
					row:Hide()
				end
			end
		end

		DuhManageNotes:SetScript("OnShow", function()
			refreshNotes()
			DuhAddNote:Hide()
			DuhManageNames:Hide()
		end)

		local f = scrollbar:GetScript("OnValueChanged")
		scrollbar:SetScript("OnValueChanged", function(self, value, ...)
			offset = math.floor(value)
			refreshNotes()
			return f(self, value, ...)
		end)

		DuhManageNotes:EnableMouseWheel()
		DuhManageNotes:SetScript("OnMouseWheel", function(self, val) scrollbar:SetValue(scrollbar:GetValue() - val*#rows/2) end)
	end
	-- </DuhManageNotes>

	-- <DuhManageNames>
	do
		DuhManageNames = CreateFrame("Frame",nil,DuhConfig)
		DuhManageNames:SetSize(690,430)
		local backdrop = GameTooltip:GetBackdrop()
		DuhManageNames:SetBackdrop(backdrop)
		DuhManageNames:SetPoint("BOTTOMLEFT",DuhConfig,"BOTTOMLEFT",5,5)
		DuhManageNames:SetBackdropBorderColor(1,0.3,0,1)
		DuhManageNames:SetBackdropColor(0,0,0,0.5)
		DuhManageNames:Hide()
		DuhManageNames:SetParent(DuhConfig)
		local title = DuhManageNames:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		title:SetPoint("TOPLEFT", 16, -16)
		title:SetText("Manage Characters")

		local subtitle = DuhManageNames:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		subtitle:SetHeight(45)
		subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
		subtitle:SetPoint("RIGHT", DuhManageNames, -32, 0)
		subtitle:SetNonSpaceWrap(true)
		subtitle:SetJustifyH("LEFT")
		subtitle:SetJustifyV("TOP")
		subtitle:SetText("This panel can be used to add/delete characters in the list at note page. Over level 40 characters are being added automatically, under that you need to add manually. Characters are server-wide.")
		local rows, anchor = {}

		local function LoadOnClick(self)
			local value = self:GetParent().number
			table.remove(db.realm.names,value)
			refreshNames()
		end

		local label = DuhManageNames:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		label:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, 0)
		label:SetJustifyH("LEFT")
		label:SetHeight(18)
		label:SetText("Add character:")

		local editbox = CreateFrame("EditBox", nil, DuhManageNames, "InputBoxTemplate")
		editbox:SetPoint("LEFT",label,"RIGHT",10,0)
		editbox:SetMaxLetters(12)
		editbox:SetWidth(150)
		editbox:SetHeight(19)
		editbox:SetAutoFocus(false)
		editbox:SetFontObject(ChatFontNormal)

		local function onClickAddName()
			if #db.realm.names >= 11 then
				dprint("Your list is full. Please remove some names first.")
			else
				addName(editbox:GetText());
				refreshNames()
			end
		end

		local button = CreateFrame("Button", nil, editbox, "UIPanelButtonTemplate")
		button:SetWidth(40)
		button:SetHeight(20)
		button:SetPoint("LEFT", editbox, "RIGHT", 0, -1)
		button:SetText("Ok")
		button:SetScript("OnClick", onClickAddName)
		local function OnEnter(self)
			GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
			GameTooltip:AddLine("Make sure the name is correct!")
			GameTooltip:Show()
		end
		local function OnLeave() GameTooltip:Hide() end
		button:SetScript("OnEnter", OnEnter)
		button:SetScript("OnLeave", OnLeave)

		local servername = DuhManageNames:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		local text = GetCVar("realmName")
		servername:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -15)
		servername:SetJustifyH("LEFT")
		servername:SetHeight(18)
		servername:SetText(text.." characters:")

		for i=1,11 do
			local row = CreateFrame("Button", nil, DuhManageNames)
			if not anchor then row:SetPoint("TOPLEFT", servername, "BOTTOMLEFT", 0, 0)
			else row:SetPoint("TOP", anchor, "BOTTOM", 0, -ROWGAP) end
			row:SetPoint("LEFT", EDGEGAP, 0)
			row:SetPoint("RIGHT", -EDGEGAP*2-8, 0)
			row:SetHeight(ROWHEIGHT)
			anchor = row
			rows[i] = row

			local deletebutton = MakeButton(80,22,row)
			deletebutton:SetPoint("RIGHT")
			deletebutton:SetText("Delete")
			deletebutton:SetScript("OnClick", LoadOnClick)
			row.deletebutton = deletebutton

			local title = row:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
			title:SetPoint("LEFT")
			title:SetPoint("RIGHT",deletebutton,"LEFT",0,0)
			title:SetJustifyH("LEFT")
			row.title = title
		end

		local offset = 0
		function refreshNames()
			if not DuhManageNames:IsVisible() then return end
			for i,row in ipairs(rows) do
				if (i + offset) <= #db.realm.names then
					local title = db.realm.names[i + offset][2] and db.realm.names[i + offset][2]
					row.deletebutton:Show()
					row.deletebutton:SetWidth(45)
					row.title:SetText(title)
					row.number = i + offset
					row:Show()
				else
					row:Hide()
				end
			end
		end

		DuhManageNames:SetScript("OnShow", function()
			refreshNames()
			DuhAddNote:Hide()
			DuhManageNotes:Hide()
		end)
	end
	-- </DuhManageNames>

	-- <DuhConfig buttons>
	do
		local butt1 = MakeButton(150,22)
		butt1:SetPoint("TOPLEFT", DuhConfig, "TOPLEFT", 16, -37)
		butt1:SetText("Add Note")
		butt1:SetScript("OnClick", function()
			DuhAddNote:Show()
		end)

		local butt2 = MakeButton(150,22)
		butt2:SetPoint("LEFT",butt1,"RIGHT",0,0)
		butt2:SetText("Manage Notes")
		butt2:SetScript("OnClick", function()
			DuhManageNotes:Show()
		end)

		local butt3 = MakeButton(150,22)
		butt3:SetText("Manage Characters")
		butt3:SetPoint("LEFT",butt2,"RIGHT",0,0)
		butt3:SetScript("OnClick", function()
			DuhManageNames:Show()
		end)

		local butt4 = MakeButton(150,22)
		butt4:SetText(db.global.minimap.hide and "Show Minimap button" or "Hide Minimap button")
		butt4:SetPoint("LEFT",butt3,"RIGHT",40,0)
		butt4:SetScript("OnClick", function(self)
			if db.global.minimap.hide then
				icon:Show("Duh")
				db.global.minimap.hide = nil
				self:SetText("Hide Minimap button")
				dprint("Minimap button visible")
			else
				icon:Hide("Duh")
				db.global.minimap.hide = true
				dprint("Minimap button hidden")
				self:SetText("Show Minimap button")
			end
		end)
	end
	-- </DuhConfig buttons>
end
--[[ GUI ENDS HERE ]]

local function eventCheck(self,event,arg1)
	if event == "PLAYER_LOGIN" then
		self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

		db = LibStub("AceDB-3.0"):New("DuhDB", defaults)
		local upgradeDB = false
		if DuhDB.version == "b" and DuhDB.names then
			db.realm.names = DuhDB.names
			DuhDB.names = nil
			upgradeDB = true
		end
		if DuhDB.version == "b" and DuhDB.notes then
			db.realm.notes = DuhDB.notes
			DuhDB.notes = nil
			upgradeDB = true
		end
		if upgradeDB then
			dprint("Database has been upgraded.")
			DuhDB.version = nil
		end

		icon:Register("Duh", Duh.LDB, db.global)

		if db.global.minimap.hide then
			icon:Hide("Duh")
		else
			icon:Show("Duh")
		end
		
		createGUI()

		local level = UnitLevel("player")
		if level > 40 then
			addName()
		end
		changeName()
		for k,v in pairs(db.realm.notes) do
			if v["shown"] then
				v["shown"] = nil
			end
		end
		zoneCheck()
	elseif event == "ZONE_CHANGED" or event == "ZONE_CHANGED_NEW_AREA" then
		local zone = GetCurrentMapAreaID()
		if zone == tempzone then return else
			tempzone = nil
			zoneCheck()
		end
	end
	for k,v in pairs(eventtable) do
		if v[3] and event == v[3] then
			checkNote(k)
		end
	end
end

Duh:SetScript("OnEvent", eventCheck)

SLASH_Duh1 = "/duh";
SLASH_Duh2 = "/d";
SlashCmdList["Duh"] = function()
	if DuhConfig:IsVisible() then DuhConfig:Hide() else DuhConfig:Show() end
end