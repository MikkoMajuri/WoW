local combat,unlocked

miniHUDDB = {}

local function colorify(percent)
	local r,g,b = percent > 0.5 and 2 * (1 - percent) or 1, percent > 0.5 and 1 or 2 * percent, 0
	local color = string.format("|cff%02x%02x%02x", r*255, g*255, b*255)
	return color..math.floor(percent*100).."|r"
end

local function spawnBar(bar,name)
	local statusbar = CreateFrame("StatusBar", nil, UIParent)
	statusbar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	statusbar:GetStatusBarTexture():SetHorizTile(false)
	statusbar:SetMinMaxValues(0, 100)
	statusbar:SetValue(100)
	statusbar:SetWidth(100)
	statusbar:SetHeight(10)
	statusbar:SetStatusBarColor(0,1,0)
	statusbar:SetFrameLevel(0)
	miniHUD[bar] = statusbar

	local statusbarbackground = statusbar:CreateTexture(nil,"BACKGROUND")
	statusbarbackground:SetAllPoints()
	statusbarbackground:SetTexture(0,0,0,1)

	local statusbartext = statusbar:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
	statusbartext:SetPoint("LEFT",statusbar,"RIGHT",5,1)
	statusbartext:SetText(100)
	miniHUD[bar]["text"] = statusbartext

	local statusbarname = statusbar:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
	statusbarname:SetPoint("RIGHT",statusbar,"LEFT",-5,1)
	statusbarname:SetText(name)
	statusbarname:Hide()
	
	statusbar:SetScript("OnEnter", function(self)
		statusbarname:Show()
	end)
	statusbar:SetScript("OnLeave", function(self)
		statusbarname:Hide()
	end)
end

local function savePosition(frame)
	local x,y = frame:GetLeft(), frame:GetTop()
	local s = frame:GetEffectiveScale()
	x,y = x*s,y*s
	miniHUDDB.PosX = x
	miniHUDDB.PosY = y
end

local function loadPosition(frame)
	local x = miniHUDDB and miniHUDDB.PosX
	local y = miniHUDDB and miniHUDDB.PosY
	if x and y then
		local s = frame:GetEffectiveScale()
		x,y = x/s,y/s
		frame:ClearAllPoints()
		frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
	end
end

local function smartPosition()
	local visiblestance
	for i=1,10 do
		if _G["StanceButton"..i]:IsVisible() then
			visiblestance = i
		end
	end
	if visiblestance ~= nil then
		return "LEFT","StanceButton"..visiblestance,"RIGHT",8,0
	else
		return "CENTER",UIParent,"CENTER",0,0
	end
end

miniHUD = CreateFrame("Frame")
miniHUD:SetFrameLevel(1)
miniHUD:RegisterEvent("PLAYER_ENTERING_WORLD")
miniHUD:RegisterEvent("ADDON_LOADED")
miniHUD:RegisterEvent("UNIT_HEALTH")
miniHUD:RegisterEvent("UNIT_HEALTH_FREQUENT")
miniHUD:RegisterEvent("UNIT_POWER")
miniHUD:RegisterEvent("UNIT_POWER_FREQUENT")
miniHUD:RegisterEvent("UNIT_PET")
miniHUD:RegisterEvent("PLAYER_TARGET_CHANGED")
miniHUD:RegisterEvent("PLAYER_REGEN_ENABLED")
miniHUD:RegisterEvent("PLAYER_REGEN_DISABLED")
miniHUD:RegisterEvent("UNIT_COMBO_POINTS")
miniHUD:SetWidth(100)
miniHUD:SetHeight(40)
miniHUD.background = miniHUD:CreateTexture(nil,"BACKGROUND")
miniHUD.background:SetTexture(0,0,0,0)
miniHUD.background:SetAllPoints()
miniHUD:RegisterForDrag("LeftButton")
miniHUD:EnableMouse(false)
miniHUD:SetMovable(false)
miniHUD:SetScript("OnDragStart", function(self) self:StartMoving() end)
miniHUD:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
	savePosition(self)
end)

local function showFrames()
	miniHUD.player:Show()
	miniHUD.power:Show()
	if UnitExists("playerpet") then miniHUD.pet:Show() end
	if UnitExists("target") then miniHUD.target:Show() end
	miniHUD.combo:Show()
end

local function hideFrames()
	miniHUD.player:Hide()
	miniHUD.power:Hide()
	miniHUD.pet:Hide()
	miniHUD.target:Hide()
	miniHUD.combo:Hide()
end

local function combopoints(amount)
	local combo = ""
	for i=1,amount do
		combo = combo.."*"
	end
   
	local percent = ((amount-1)*20)/100
	local r,g,b = percent > 0.5 and 2 * (1 - percent) or 1, percent > 0.5 and 1 or 2 * percent, 0
	local color = string.format("|cff%02x%02x%02x", r*255, g*255, b*255)
	return color..combo.."|r"
end

local function showCombo()
	local points = GetComboPoints("player","target")
	if points >= 1 then
		miniHUD.combo:SetText(combopoints(points))
	else
		miniHUD.combo:SetText("")
	end
end

miniHUD:SetScript("OnEvent", function(self,event,arg)
	if event == "ADDON_LOADED" then
		spawnBar("player","You")
		spawnBar("power","Power")
		spawnBar("target","Target")
		spawnBar("pet","Pet")

		local combo = miniHUD.power:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
		combo:SetPoint("LEFT",miniHUD.power,"RIGHT",35,-1)
		miniHUD.combo = combo
		showCombo()
		
		self.player:SetPoint("LEFT",self,"LEFT",2,6)
		self.power:SetPoint("TOP",self.player,"BOTTOM",0,-3)
		self.pet:SetPoint("TOP",self.power,"BOTTOM",0,-3)
		self.target:SetPoint("BOTTOM",self.player,"TOP",0,3)
		self:UnregisterEvent("ADDON_LOADED")
	elseif event == "PLAYER_ENTERING_WORLD" then
		if miniHUDDB and not (miniHUDDB.PosX and miniHUDDB.PosY) then
			self:SetPoint(smartPosition())
		else
			loadPosition(self)
		end
		if UnitExists("target") then
			if miniHUDDB.combat and not combat then return else self.target:Show() end
			showCombo()
		else
			self.target:Hide()
		end
		if UnitExists("playerpet") then
			local petclass,PETCLASS = UnitClass("playerpet")
			local r,g,b = RAID_CLASS_COLORS[PETCLASS].r,RAID_CLASS_COLORS[PETCLASS].g,RAID_CLASS_COLORS[PETCLASS].b
			self.pet:SetStatusBarColor(r,g,b)
			local percent = UnitHealth("playerpet")/UnitHealthMax("playerpet")
			self.pet.text:SetText(colorify(percent))
			if miniHUDDB.combat and not combat then return else self.pet:Show() end
		else
			self.pet:Hide()
		end
		
		if miniHUDDB.combat then
			hideFrames()
		end
		
	    local playerclass,PLAYERCLASS = UnitClass("player")
        local r,g,b = RAID_CLASS_COLORS[PLAYERCLASS].r,RAID_CLASS_COLORS[PLAYERCLASS].g,RAID_CLASS_COLORS[PLAYERCLASS].b
		self.player:SetStatusBarColor(r,g,b)
		local percent = UnitHealth("player")/UnitHealthMax("player")
		self.player.text:SetText(colorify(percent))
		local r,g,b = PowerBarColor[UnitPowerType("player")]
		self.power:SetStatusBarColor(PowerBarColor[UnitPowerType("player")].r,PowerBarColor[UnitPowerType("player")].g,PowerBarColor[UnitPowerType("player")].b)
		local percent = UnitPower("player")/UnitPowerMax("player")
		self.power.text:SetText(colorify(percent))
		
	elseif event == "UNIT_HEALTH" or event == "UNIT_HEALTH_FREQUENT" then
		if arg == "player" or arg == "target" or arg == "pet" then
			if arg == "target" then
				local r,g,b = UnitSelectionColor(arg)
				self[arg]:SetStatusBarColor(r,g,b)
			end
			self[arg]:SetMinMaxValues(0,UnitHealthMax(arg))
			self[arg]:SetValue(UnitHealth(arg))
			local percent = UnitHealth(arg)/UnitHealthMax(arg)
			self[arg]["text"]:SetText(colorify(percent))
		end
		
	elseif event == "UNIT_POWER" or event == "UNIT_POWER_FREQUENT" then
		if arg == "player" then
			self.power:SetStatusBarColor(PowerBarColor[UnitPowerType("player")].r,PowerBarColor[UnitPowerType("player")].g,PowerBarColor[UnitPowerType("player")].b)
			self.power:SetMinMaxValues(0,UnitPowerMax("player"))
			self.power:SetValue(UnitPower("player"))
			local percent = UnitPower("player")/UnitPowerMax("player")
			self.power.text:SetText(colorify(percent))
		end
	elseif event == "UNIT_PET" then
		if arg == "player" then
			if UnitExists("playerpet") then
				local petclass,PETCLASS = UnitClass("playerpet")
				local r,g,b = RAID_CLASS_COLORS[PETCLASS].r,RAID_CLASS_COLORS[PETCLASS].g,RAID_CLASS_COLORS[PETCLASS].b
				self.pet:SetStatusBarColor(r,g,b)
				local percent = UnitHealth("playerpet")/UnitHealthMax("playerpet")
				self.pet.text:SetText(colorify(percent))
				if miniHUDDB.combat and not combat then return else self.pet:Show() end
			else
				self.pet:Hide()
			end
		end
	elseif event == "PLAYER_TARGET_CHANGED" then
		if UnitExists("target") then
			self.target:SetMinMaxValues(0, UnitHealthMax("target"))
			local percent = UnitHealth("target")/UnitHealthMax("target")
			self.target:SetValue(UnitHealth("Target"))
			self.target.text:SetText(colorify(percent))
			local r,g,b = UnitSelectionColor("target")
			self.target:SetStatusBarColor(r,g,b)
			if miniHUDDB.combat and not combat then return else self.target:Show() end
			showCombo()
		else
			self.target:Hide()
			miniHUD.combo:SetText("")
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		if miniHUDDB.combat then
			combat = nil
			hideFrames()
		end
	elseif event == "PLAYER_REGEN_DISABLED" then
		if miniHUDDB.combat then
			combat = true		
			showFrames()
		end
	elseif event == "UNIT_COMBO_POINTS" then
		if arg == "player" then
			showCombo()
		end
	end
end)

SLASH_miniHUD1 = "/minihud";
SLASH_miniHUD2 = "/mh";
SlashCmdList["miniHUD"] = function(cmd)
	if cmd == "lock" then
		if not unlocked then
			miniHUD.background:SetTexture(0,0,0,0.5)
			miniHUD:SetMovable(true)
			miniHUD:EnableMouse(true)
			unlocked = true
			showFrames()
		else
			miniHUD.background:SetTexture(0,0,0,0)
			miniHUD:EnableMouse(false)
			miniHUD:SetMovable(false)
			unlocked = nil
			if miniHUDDB.combat then
				hideFrames()
			end
		end
	elseif cmd == "combat" then
		if miniHUDDB.combat then
			miniHUDDB.combat = nil
			ChatFrame1:AddMessage("miniHUD: Always shown.")
			showFrames()
		else
			miniHUDDB.combat = true
			ChatFrame1:AddMessage("miniHUD: Now shown when entering combat.")
			hideFrames()
		end
	else
		ChatFrame1:AddMessage("miniHUD: Accepting following commands: lock, combat.")
	end
end