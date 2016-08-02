if select(2,UnitClass("player")) == "ROGUE" then

	local frame = CreateFrame("frame")
	RogueTimers = { 
		Width = 200,
		Height = 13,
		PictureGap = 0,
		Position = {"BOTTOM",CastingBarFrame,"TOP",10,100},
		HideText = false,
		ActiveSpecGroup = 1,
	}
	
	local function pimpmytext(whichone)
		local left = RogueTimers[whichone]:GetRegions():GetLeft()
		local right = RogueTimers[whichone]:GetRegions():GetRight()
		local width = right - left
		RogueTimers[whichone]["Text"]:SetWidth(width - 5)
		RogueTimers[whichone]["Text"]:SetHeight(RogueTimers.Height)
		if RogueTimers[whichone]["Text"]:GetStringWidth() < 15 or RogueTimers[whichone]:GetValue() <= 0 then
			RogueTimers[whichone]["Text"]:Hide()
		else
			RogueTimers[whichone]["Text"]:Show()
		end
	end

	local foo = 50
	
	-- Target Health
	local icon = "Interface\\LFGFrame\\LFGRole"
	RogueTimers.TargetHealth = CreateFrame("StatusBar", nil, UIParent)
	RogueTimers.TargetHealth:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	RogueTimers.TargetHealth:GetStatusBarTexture():SetHorizTile(false)
	RogueTimers.TargetHealth:SetMinMaxValues(0, 1)
	RogueTimers.TargetHealth:SetValue(0)
	RogueTimers.TargetHealth:SetWidth(RogueTimers.Width)
	RogueTimers.TargetHealth:SetHeight(RogueTimers.Height)
	RogueTimers.TargetHealth:SetPoint(unpack(RogueTimers.Position))
	RogueTimers.TargetHealth:SetStatusBarColor(1,1,1)
	RogueTimers.TargetHealth:Hide()
	RogueTimers.TargetHealth.Text = RogueTimers.TargetHealth:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	RogueTimers.TargetHealth.Text:SetPoint("LEFT",RogueTimers.TargetHealth,"LEFT",RogueTimers.PictureGap,0)
	RogueTimers.TargetHealth.Text:SetText("Target Health")
	RogueTimers.TargetHealth.Text:SetJustifyH("LEFT")
	if RogueTimers.HideText then
		RogueTimers.TargetHealth.Text:Hide()
	else
		RogueTimers.TargetHealth.Text:SetParent(RogueTimers.TargetHealth)
	end
	RogueTimers.TargetHealth.Texture = RogueTimers.TargetHealth:CreateTexture(nil, "ARTWORK")
	RogueTimers.TargetHealth.Texture:SetWidth(RogueTimers.Height)
	RogueTimers.TargetHealth.Texture:SetHeight(RogueTimers.Height)
	RogueTimers.TargetHealth.Texture:SetTexture(icon)
	RogueTimers.TargetHealth.Texture:SetTexCoord(3/4, 0, 3/4, 1, 1, 0, 1, 1)
	RogueTimers.TargetHealth.Texture:SetPoint("RIGHT",RogueTimers.TargetHealth,"LEFT",-3,0)
	RogueTimers.TargetHealth.Texture:SetParent(RogueTimers.TargetHealth)
	pimpmytext("TargetHealth")
	
	-- Combo Points
	RogueTimers.ComboPoints = CreateFrame("StatusBar", nil, UIParent)
	RogueTimers.ComboPoints:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	RogueTimers.ComboPoints:GetStatusBarTexture():SetHorizTile(false)
	RogueTimers.ComboPoints:SetMinMaxValues(0, 5)
	RogueTimers.ComboPoints:SetValue(0)
	RogueTimers.ComboPoints:SetWidth(RogueTimers.Width)
	RogueTimers.ComboPoints:SetHeight(RogueTimers.Height)
	RogueTimers.ComboPoints:SetPoint("TOP",RogueTimers.TargetHealth,"BOTTOM",0,-1)
	RogueTimers.ComboPoints:SetStatusBarColor(1,1,1)
	RogueTimers.ComboPoints:Hide()
	RogueTimers.ComboPoints.Text = RogueTimers.ComboPoints:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	RogueTimers.ComboPoints.Text:SetPoint("LEFT",RogueTimers.ComboPoints,"LEFT",RogueTimers.PictureGap,0)
	RogueTimers.ComboPoints.Text:SetText("Combo Points")
	RogueTimers.ComboPoints.Text:SetJustifyH("LEFT")
	if RogueTimers.HideText then
		RogueTimers.ComboPoints.Text:Hide()
	else
		RogueTimers.ComboPoints.Text:SetParent(RogueTimers.ComboPoints)
	end
	RogueTimers.ComboPoints.Texture = RogueTimers.ComboPoints:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	RogueTimers.ComboPoints.Texture:SetPoint("RIGHT",RogueTimers.ComboPoints,"LEFT",-3,0)
	RogueTimers.ComboPoints.Texture:SetParent(RogueTimers.ComboPoints)
	RogueTimers.ComboPoints.Texture:SetText("0")
	pimpmytext("ComboPoints")	

	-- Deadly Poison
	RogueTimers.DeadlyPoison = CreateFrame("StatusBar", nil, UIParent)
	RogueTimers.DeadlyPoison:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	RogueTimers.DeadlyPoison:GetStatusBarTexture():SetHorizTile(false)
	RogueTimers.DeadlyPoison:SetMinMaxValues(0, 1)
	RogueTimers.DeadlyPoison:SetValue(0)
	RogueTimers.DeadlyPoison:SetWidth(RogueTimers.Width)
	RogueTimers.DeadlyPoison:SetHeight(RogueTimers.Height)
	RogueTimers.DeadlyPoison:SetPoint("TOP",RogueTimers.ComboPoints,"BOTTOM",0,-1)
	RogueTimers.DeadlyPoison:SetStatusBarColor(1,1,1)
	RogueTimers.DeadlyPoison:Hide()
	RogueTimers.DeadlyPoison.Text = RogueTimers.DeadlyPoison:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	RogueTimers.DeadlyPoison.Text:SetPoint("LEFT",RogueTimers.DeadlyPoison,"LEFT",RogueTimers.PictureGap,0)
	RogueTimers.DeadlyPoison.Text:SetText("Deadly Poison")
	RogueTimers.DeadlyPoison.Text:SetJustifyH("LEFT")
	if RogueTimers.HideText then
		RogueTimers.DeadlyPoison.Text:Hide()
	else
		RogueTimers.DeadlyPoison.Text:SetParent(RogueTimers.DeadlyPoison)
	end
	RogueTimers.DeadlyPoison.Texture = RogueTimers.DeadlyPoison:CreateTexture(nil,"OVERLAY")
	RogueTimers.DeadlyPoison.Texture:SetTexture("Interface\\Icons\\Ability_Rogue_DualWeild")
	RogueTimers.DeadlyPoison.Texture:SetWidth(RogueTimers.Height)
	RogueTimers.DeadlyPoison.Texture:SetHeight(RogueTimers.Height)
	RogueTimers.DeadlyPoison.Texture:SetPoint("RIGHT",RogueTimers.DeadlyPoison,"LEFT",-3,0)
	pimpmytext("DeadlyPoison")
	
	-- Slice and Dice
	RogueTimers.SliceandDice = CreateFrame("StatusBar", nil, UIParent)
	RogueTimers.SliceandDice:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	RogueTimers.SliceandDice:GetStatusBarTexture():SetHorizTile(false)
	RogueTimers.SliceandDice:SetMinMaxValues(0, 1)
	RogueTimers.SliceandDice:SetValue(0)
	RogueTimers.SliceandDice:SetWidth(RogueTimers.Width)
	RogueTimers.SliceandDice:SetHeight(RogueTimers.Height)
	RogueTimers.SliceandDice:SetPoint("TOP",RogueTimers.DeadlyPoison,"BOTTOM",0,-1)
	RogueTimers.SliceandDice:SetStatusBarColor(1,1,1)
	RogueTimers.SliceandDice:Hide()
	RogueTimers.SliceandDice.Text = RogueTimers.SliceandDice:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	RogueTimers.SliceandDice.Text:SetPoint("LEFT",RogueTimers.SliceandDice,"LEFT",RogueTimers.PictureGap,0)
	RogueTimers.SliceandDice.Text:SetText("Slice and Dice")
	RogueTimers.SliceandDice.Text:SetJustifyH("LEFT")
	if RogueTimers.HideText then
		RogueTimers.SliceandDice.Text:Hide()
	else
		RogueTimers.SliceandDice.Text:SetParent(RogueTimers.SliceandDice)
	end
	RogueTimers.SliceandDice.Texture = RogueTimers.SliceandDice:CreateTexture(nil,"OVERLAY")
	RogueTimers.SliceandDice.Texture:SetTexture("Interface\\Icons\\Ability_Rogue_SliceDice")
	RogueTimers.SliceandDice.Texture:SetWidth(RogueTimers.Height)
	RogueTimers.SliceandDice.Texture:SetHeight(RogueTimers.Height)
	RogueTimers.SliceandDice.Texture:SetPoint("RIGHT",RogueTimers.SliceandDice,"LEFT",-3,0)
	pimpmytext("SliceandDice")
	
	-- Hemorrhage
	RogueTimers.Hemorrhage = CreateFrame("StatusBar", nil, UIParent)
	RogueTimers.Hemorrhage:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	RogueTimers.Hemorrhage:GetStatusBarTexture():SetHorizTile(false)
	RogueTimers.Hemorrhage:SetMinMaxValues(0, 1)
	RogueTimers.Hemorrhage:SetValue(0)
	RogueTimers.Hemorrhage:SetWidth(RogueTimers.Width)
	RogueTimers.Hemorrhage:SetHeight(RogueTimers.Height)
	RogueTimers.Hemorrhage:SetPoint("TOP",RogueTimers.SliceandDice,"BOTTOM",0,-1)
	RogueTimers.Hemorrhage:SetStatusBarColor(1,1,1)
	RogueTimers.Hemorrhage:Hide()
	RogueTimers.Hemorrhage.Text = RogueTimers.Hemorrhage:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	RogueTimers.Hemorrhage.Text:SetPoint("LEFT",RogueTimers.Hemorrhage,"LEFT",RogueTimers.PictureGap,0)
	RogueTimers.Hemorrhage.Text:SetText("Hemorrhage")
	RogueTimers.Hemorrhage.Text:SetJustifyH("LEFT")
	if RogueTimers.HideText then
		RogueTimers.Hemorrhage.Text:Hide()
	else
		RogueTimers.Hemorrhage.Text:SetParent(RogueTimers.Hemorrhage)
	end
	RogueTimers.Hemorrhage.Texture = RogueTimers.Hemorrhage:CreateTexture(nil,"OVERLAY")
	RogueTimers.Hemorrhage.Texture:SetTexture("Interface\\Icons\\Spell_Shadow_LifeDrain")
	RogueTimers.Hemorrhage.Texture:SetWidth(RogueTimers.Height)
	RogueTimers.Hemorrhage.Texture:SetHeight(RogueTimers.Height)
	RogueTimers.Hemorrhage.Texture:SetPoint("RIGHT",RogueTimers.Hemorrhage,"LEFT",-3,0)
	pimpmytext("Hemorrhage")

	-- Rupture
	RogueTimers.Rupture = CreateFrame("StatusBar", nil, UIParent)
	RogueTimers.Rupture:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	RogueTimers.Rupture:GetStatusBarTexture():SetHorizTile(false)
	RogueTimers.Rupture:SetMinMaxValues(0, 1)
	RogueTimers.Rupture:SetValue(0)
	RogueTimers.Rupture:SetWidth(RogueTimers.Width)
	RogueTimers.Rupture:SetHeight(RogueTimers.Height)
	RogueTimers.Rupture:SetPoint("TOP",RogueTimers.Hemorrhage,"BOTTOM",0,-1)
	RogueTimers.Rupture:SetStatusBarColor(0.84, 0, 0, 1)
	RogueTimers.Rupture:Hide()
	RogueTimers.Rupture.Text = RogueTimers.Rupture:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	RogueTimers.Rupture.Text:SetPoint("LEFT",RogueTimers.Rupture,"LEFT",RogueTimers.PictureGap,0)
	RogueTimers.Rupture.Text:SetText("Rupture")
	RogueTimers.Rupture.Text:SetJustifyH("LEFT")
	if RogueTimers.HideText then
		RogueTimers.Rupture.Text:Hide()
	else
		RogueTimers.Rupture.Text:SetParent(RogueTimers.Rupture)
	end
	RogueTimers.Rupture.Texture = RogueTimers.Rupture:CreateTexture(nil,"OVERLAY")
	RogueTimers.Rupture.Texture:SetTexture("Interface\\Icons\\Ability_Rogue_Rupture")
	RogueTimers.Rupture.Texture:SetWidth(RogueTimers.Height)
	RogueTimers.Rupture.Texture:SetHeight(RogueTimers.Height)
	RogueTimers.Rupture.Texture:SetPoint("RIGHT",RogueTimers.Rupture,"LEFT",-3,0)
	pimpmytext("Rupture")	
	
	local firstframe = RogueTimers.TargetHealth
	local lastframe = RogueTimers.Rupture

	-- Background frame
	RogueTimers.Background = CreateFrame("Button",nil,UIParent)
	RogueTimers.Background:SetBackdrop(GameTooltip:GetBackdrop())
	RogueTimers.Background:SetParent(firstframe)
	RogueTimers.Background:SetPoint("TOPLEFT",firstframe,"TOPLEFT",-25,10)
	RogueTimers.Background:SetPoint("BOTTOMRIGHT",lastframe,"BOTTOMRIGHT",10,-10)
	RogueTimers.Background:SetBackdropColor(0,0,0,0.2)
	RogueTimers.Background:SetBackdropBorderColor(1,1,1,0.2)
	RogueTimers.Background:EnableMouse(false)

	RogueTimers.PoisonOne = frame:CreateTexture(nil,"HIGH")
	RogueTimers.PoisonOne:SetWidth(foo)
	RogueTimers.PoisonOne:SetHeight(foo)
	RogueTimers.PoisonOne:SetTexture(select(3,GetSpellInfo("Deadly Poison")))
	RogueTimers.PoisonOne:SetPoint("BOTTOMRIGHT", RogueTimers.Background, "TOP", -5, 0)
	RogueTimers.PoisonOne:SetAlpha(0)

	RogueTimers.PoisonTwo = frame:CreateTexture(nil,"HIGH")
	RogueTimers.PoisonTwo:SetWidth(foo)
	RogueTimers.PoisonTwo:SetHeight(foo)
	RogueTimers.PoisonTwo:SetTexture(select(3,GetSpellInfo("Crippling Poison")))
	RogueTimers.PoisonTwo:SetPoint("BOTTOMLEFT", RogueTimers.Background, "TOP", 5, 0)
	RogueTimers.PoisonTwo:SetAlpha(0)
	
	local function magic()
		if not RogueTimers.Disable and GetActiveSpecGroup() == RogueTimers.ActiveSpecGroup and UnitExists("target") and UnitCanAttack("player","target") then
		
			-- Main Hand
			if UnitBuff("player","Deadly Poison") then
				RogueTimers.PoisonOne:SetAlpha(0)
			else
				RogueTimers.PoisonOne:SetAlpha(1)
			end
			
			-- Off Hand
			if UnitBuff("player","Crippling Poison") or UnitBuff("player","Leeching Poison") then
				RogueTimers.PoisonTwo:SetAlpha(0)
			else
				RogueTimers.PoisonTwo:SetAlpha(1)
			end
				
			-- Target Health
			local value = UnitHealth("target")/UnitHealthMax("target")
			RogueTimers.TargetHealth:SetStatusBarColor(RogueTimers.ColorStuff(value))
			RogueTimers.TargetHealth:SetMinMaxValues(0,UnitHealthMax("target"))
			RogueTimers.TargetHealth:SetValue(UnitHealth("target"))
			-- Shrinking text
			pimpmytext("TargetHealth")

			-- Combo Points
			local points = GetComboPoints("player","target")
			RogueTimers.ComboPoints:SetValue(points)
			RogueTimers.ComboPoints:SetStatusBarColor(RogueTimers.ColorStuff(points/5))
			RogueTimers.ComboPoints.Texture:SetText(points)
			-- Shrinking text
			pimpmytext("ComboPoints")	
			
			-- Deadly Poison
			if UnitDebuff("target","Deadly Poison") and select(8,UnitDebuff("target","Deadly Poison")) == "player" then 
				local stack = select(4,UnitDebuff("target","Deadly Poison"))
				local maxdur = select(6,UnitDebuff("target","Deadly Poison"))
				local curdur = select(7,UnitDebuff("target","Deadly Poison"))-GetTime()
				RogueTimers.DeadlyPoison:SetMinMaxValues(0,maxdur)
				RogueTimers.DeadlyPoison:SetValue(curdur)
				if floor(curdur) == -1 then curdur = 0 end
				RogueTimers.DeadlyPoison:SetStatusBarColor(RogueTimers.ColorStuff(stack/5))
				-- Shrinking text
				pimpmytext("DeadlyPoison")
			else
				RogueTimers.DeadlyPoison:SetValue(0)
				pimpmytext("DeadlyPoison")
			end
			
			-- Slice and Dice
			if UnitAura("player","Slice and Dice") then 
				local maxdur = select(6,UnitAura("player","Slice and Dice"))
				local curdur = select(7,UnitAura("player","Slice and Dice"))-GetTime()
				RogueTimers.SliceandDice:SetMinMaxValues(0,maxdur)
				RogueTimers.SliceandDice:SetValue(curdur)
				if floor(curdur) == -1 then curdur = 0 end
				RogueTimers.SliceandDice:SetStatusBarColor(RogueTimers.ColorStuff(curdur/maxdur))
				-- Shrinking text
				pimpmytext("SliceandDice")
			else
				RogueTimers.SliceandDice:SetValue(0)
				pimpmytext("SliceandDice")
			end

			-- Hemorrhage
			if UnitDebuff("target","Hemorrhage") and UnitDebuff("target","Hemorrhage") then 
				local maxdur = select(6,UnitDebuff("target","Hemorrhage"))
				local curdur = select(7,UnitDebuff("target","Hemorrhage"))-GetTime()
				RogueTimers.Hemorrhage:SetMinMaxValues(0,maxdur)
				RogueTimers.Hemorrhage:SetValue(curdur)
				RogueTimers.Hemorrhage:SetStatusBarColor(RogueTimers.ColorStuff(curdur/maxdur))
				-- Shrinking text
				pimpmytext("Hemorrhage")
			else
				RogueTimers.Hemorrhage:SetValue(0)
				pimpmytext("Hemorrhage")
			end
			
			-- Rupture
			if UnitDebuff("target","Rupture") and UnitDebuff("target","Rupture") then 
				local maxdur = select(6,UnitDebuff("target","Rupture"))
				local curdur = select(7,UnitDebuff("target","Rupture"))-GetTime()
				RogueTimers.Rupture:SetMinMaxValues(0,maxdur)
				RogueTimers.Rupture:SetValue(curdur)
				-- Shrinking text
				pimpmytext("Rupture")
			else
				RogueTimers.Rupture:SetValue(0)
				pimpmytext("Rupture")
			end
		else
			RogueTimers.TargetHealth:Hide()
			RogueTimers.DeadlyPoison:Hide()
			RogueTimers.ComboPoints:Hide()
			RogueTimers.SliceandDice:Hide()
			RogueTimers.Hemorrhage:Hide()
			RogueTimers.Rupture:Hide()
			RogueTimers.PoisonOne:Hide()
			RogueTimers.PoisonTwo:Hide()
		end
	end

	--frame:RegisterEvent("UNIT_COMBO_POINTS")
	frame:RegisterEvent("PLAYER_TARGET_CHANGED")
	frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	frame:RegisterEvent("UNIT_AURA")
	frame:RegisterEvent("UNIT_COMBAT")
	frame:SetScript("OnEvent", function(self,event,id)
	
		if event == "PLAYER_TARGET_CHANGED" then
			local loaded = frame:GetScript("OnUpdate")
			if not RogueTimers.Disable and GetActiveSpecGroup() == RogueTimers.ActiveSpecGroup and UnitExists("target") and UnitCanAttack("player","target") then
				if not loaded then
					frame:SetScript("OnUpdate",magic)
				end
				RogueTimers.TargetHealth:Show()
				RogueTimers.ComboPoints:Show()
				RogueTimers.DeadlyPoison:Show()
				RogueTimers.ComboPoints:Show()
				RogueTimers.SliceandDice:Show()
				RogueTimers.Hemorrhage:Show()
				RogueTimers.Rupture:Show()
				RogueTimers.PoisonOne:Show()
				RogueTimers.PoisonTwo:Show()
			else
				frame:SetScript("OnUpdate",nil)
				RogueTimers.TargetHealth:Hide()
				RogueTimers.ComboPoints:Hide()
				RogueTimers.DeadlyPoison:Hide()
				RogueTimers.ComboPoints:Hide()
				RogueTimers.SliceandDice:Hide()
				RogueTimers.Hemorrhage:Hide()
				RogueTimers.Rupture:Hide()
				RogueTimers.PoisonOne:Hide()
				RogueTimers.PoisonTwo:Hide()
			end
		elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
			if id == RogueTimers.ActiveTalentGroup then
				local loaded = frame:GetScript("OnUpdate")
				if not RogueTimers.Disable and GetActiveTalentGroup() == RogueTimers.ActiveTalentGroup and UnitExists("target") and UnitCanAttack("player","target") then
					if not loaded then
						frame:SetScript("OnUpdate",magic)
					end
					RogueTimers.TargetHealth:Show()
					RogueTimers.ComboPoints:Show()
					RogueTimers.DeadlyPoison:Show()
					RogueTimers.SliceandDice:Show()
					RogueTimers.Hemorrhage:Show()
					RogueTimers.Rupture:Show()
					RogueTimers.PoisonOne:Show()
					RogueTimers.PoisonTwo:Show()

					else
					frame:SetScript("OnUpdate",nil)
					RogueTimers.TargetHealth:Hide()
					RogueTimers.DeadlyPoison:Hide()
					RogueTimers.ComboPoints:Hide()
					RogueTimers.SliceandDice:Hide()
					RogueTimers.Hemorrhage:Hide()
					RogueTimers.Rupture:Hide()
					RogueTimers.PoisonOne:Hide()
					RogueTimers.PoisonTwo:Hide()
				end
			end
		elseif event == "UNIT_COMBAT" then
			if id == "target" then
				local loaded = frame:GetScript("OnUpdate")
				if not RogueTimers.Disable and GetActiveSpecGroup() == RogueTimers.ActiveSpecGroup and UnitExists("target") and UnitCanAttack("player","target") then
					if not loaded then
						frame:SetScript("OnUpdate",magic)
					end
					RogueTimers.TargetHealth:Show()
					RogueTimers.ComboPoints:Show()
					RogueTimers.DeadlyPoison:Show()
					RogueTimers.ComboPoints:Show()
					RogueTimers.SliceandDice:Show()
					RogueTimers.Hemorrhage:Show()
					RogueTimers.Rupture:Show()
					RogueTimers.PoisonOne:Show()
					RogueTimers.PoisonTwo:Show()
				else
					frame:SetScript("OnUpdate",nil)
					RogueTimers.TargetHealth:Hide()
					RogueTimers.ComboPoints:Hide()
					RogueTimers.DeadlyPoison:Hide()
					RogueTimers.ComboPoints:Hide()
					RogueTimers.SliceandDice:Hide()
					RogueTimers.Hemorrhage:Hide()
					RogueTimers.Rupture:Hide()
					RogueTimers.PoisonOne:Hide()
					RogueTimers.PoisonTwo:Hide()
				end
			end
		else
			if id == UnitName("player") then
				if UnitBuff("player","Deadly Poison") then
					RogueTimers.PoisonOne:SetAlpha(0)
				else
					RogueTimers.PoisonOne:SetAlpha(1)
				end
				
				-- Off Hand
				if UnitBuff("player","Crippling Poison") then
					RogueTimers.PoisonTwo:SetAlpha(0)
				else
					RogueTimers.PoisonTwo:SetAlpha(1)
				end
			end
		end
	end)
		
	function RogueTimers.ColorStuff(value)
		local r,g,b
		if(value > 0.5) then
			r = (1.0 - value) * 2
			g = 1.0
		else
			r = 1.0
			g = value * 2
		end
		b = 0.0;
		return r,g,b
	end
end