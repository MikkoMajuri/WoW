local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:SetScript("OnEvent", function(self,event)
	-- DataBase can only be used AFTER the PLAYER_LOGIN event. Otherwise it WON'T remember the settings
	if event == "PLAYER_LOGIN" then
		-- DB does not exist, create it so we can store the defaults
		if not miniTipDB then
			miniTipDB = {
				["hidetitle"] = true, -- Hide the Title of target
				["hiderealm"] = true, -- Hide the Realm of target
				["classicon"] = true, -- Show the Class icon of target
				["raceicon"] = true, -- Show the Race icon of target
				["classiconsize"] = 40, -- Class Icon is 40 x 40
				["raceiconsize"] = 40, -- Race icon is 40 x 40
				["targetoftarget"] = true, -- Show Target of Target
				["combathide"] = false, -- Don't hide in combat
			} 
		end
		
		local miniTip = "|cFFFF9900miniTip|r"
		local skull = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8.blp:0|t"
		local cross = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7.blp:0|t"
		-- This is how we get the look of GameTooltip to the Target of Target frame later
		local backdrop = GameTooltip:GetBackdrop()
		local unavailable = "Interface\\CHARACTERFRAME\\TempPortrait.blp"
		-- Races listed. 3 is Female, and 2 is Male.
		local races = {
		   [3] = {
			  ["BloodElf"] = "Interface\\CHARACTERFRAME\\TEMPORARYPORTRAIT-FEMALE-BLOODELF.BLP",
			  ["Draenei"] = "Interface\\CHARACTERFRAME\\TEMPORARYPORTRAIT-FEMALE-DRAENEI.BLP",
			  ["Dwarf"] = "Interface\\CHARACTERFRAME\\TEMPORARYPORTRAIT-FEMALE-DWARF.BLP",
			  ["Gnome"] = "Interface\\CHARACTERFRAME\\TEMPORARYPORTRAIT-FEMALE-GNOME.BLP",
			  ["Goblin"] = "Interface\\CHARACTERFRAME\\TEMPORARYPORTRAIT-FEMALE-GOBLIN.BLP",
			  ["Human"] = "Interface\\CHARACTERFRAME\\TEMPORARYPORTRAIT-FEMALE-HUMAN.BLP",
			  ["NightElf"] = "Interface\\CHARACTERFRAME\\TEMPORARYPORTRAIT-FEMALE-NIGHTELF.BLP",
			  ["Orc"] = "Interface\\CHARACTERFRAME\\TEMPORARYPORTRAIT-FEMALE-ORC.BLP",
			  ["Pandaren"] = "Interface\\CHARACTERFRAME\\TEMPORARYPORTRAIT-FEMALE-PANDAREN.BLP",
			  ["Scourge"] = "Interface\\CHARACTERFRAME\\TEMPORARYPORTRAIT-FEMALE-SCOURGE.BLP",
			  ["Tauren"] = "Interface\\CHARACTERFRAME\\TEMPORARYPORTRAIT-FEMALE-TAUREN.BLP",
			  ["Troll"] = "Interface\\CHARACTERFRAME\\TEMPORARYPORTRAIT-FEMALE-TROLL.BLP",
			  ["Worgen"] = "Interface\\CHARACTERFRAME\\TEMPORARYPORTRAIT-FEMALE-WORGEN.BLP",
		   },
		   
		   [2] = {
			  ["BloodElf"] = "Interface\\CHARACTERFRAME\\TEMPORARYPORTRAIT-MALE-BLOODELF.BLP",
			  ["Draenei"] = "Interface\\CHARACTERFRAME\\TEMPORARYPORTRAIT-MALE-DRAENEI.BLP",
			  ["Dwarf"] = "Interface\\CHARACTERFRAME\\TEMPORARYPORTRAIT-MALE-DWARF.BLP",
			  ["Gnome"] = "Interface\\CHARACTERFRAME\\TEMPORARYPORTRAIT-MALE-GNOME.BLP",
			  ["Goblin"] = "Interface\\CHARACTERFRAME\\TemporaryPortrait-Male-Goblin.blp",
			  ["Human"] = "Interface\\CHARACTERFRAME\\TEMPORARYPORTRAIT-MALE-HUMAN.BLP",
			  ["NightElf"] = "Interface\\CHARACTERFRAME\\TEMPORARYPORTRAIT-MALE-NIGHTELF.BLP",
			  ["Orc"] = "Interface\\CHARACTERFRAME\\TEMPORARYPORTRAIT-MALE-ORC.BLP",
			  ["Pandaren"] = "Interface\\CHARACTERFRAME\\TEMPORARYPORTRAIT-MALE-PANDAREN.BLP",
			  ["Scourge"] = "Interface\\CHARACTERFRAME\\TEMPORARYPORTRAIT-MALE-SCOURGE.BLP",
			  ["Tauren"] = "Interface\\CHARACTERFRAME\\TEMPORARYPORTRAIT-MALE-TAUREN.BLP",
			  ["Troll"] = "Interface\\CHARACTERFRAME\\TEMPORARYPORTRAIT-MALE-TROLL.BLP",
			  ["Worgen"] = "Interface\\CHARACTERFRAME\\TEMPORARYPORTRAIT-MALE-WORGEN.BLP",
		   },
		}

		-- Add more space to sides of the textures in Class and Race icons.
		local gap = 3

		-- Create the Class Icon and Set it to the right side of GameTooltip
		local myClassIcon = CreateFrame("Frame", nil, GameTooltip)
		myClassIcon:SetBackdrop(backdrop)
		local myClassIcontex = myClassIcon:CreateTexture(nil, "ARTWORK")
		myClassIcontex:SetPoint("TOPLEFT",myClassIcon,"TOPLEFT",gap,-gap)
		myClassIcontex:SetPoint("BOTTOMRIGHT",myClassIcon,"BOTTOMRIGHT",-gap,gap)
		myClassIcon:SetPoint("TOPLEFT",GameTooltip,"TOPRIGHT",-3,0)
		myClassIcon:SetParent(GameTooltip)

		-- Create the Race Icon and Set it to the right side of GameTooltip
		local myRaceIcon = CreateFrame("Frame", nil, GameTooltip)
		myRaceIcon:SetBackdrop(backdrop)
		myRaceIcon:SetPoint("TOPLEFT",myClassIcon,"BOTTOMLEFT",0,3)
		local myRaceIcontex = myRaceIcon:CreateTexture(nil, "ARTWORK")
		myRaceIcontex:SetPoint("TOPLEFT",myRaceIcon,"TOPLEFT",gap+2,-gap-2)
		myRaceIcontex:SetPoint("BOTTOMRIGHT",myRaceIcon,"BOTTOMRIGHT",-gap-2,gap+2)	
		myRaceIcon:SetParent(GameTooltip)

		-- Create the Target of Target frame and set it to above the GameTooltip
		local myToT = CreateFrame("Frame", nil, UIParent)
		myToT:SetBackdrop(backdrop)
		myToT:SetPoint("BOTTOMLEFT",GameTooltip,"TOPLEFT",0,-3)
		myToT:SetBackdropColor(0,0,0,0.8)
		myToT.row1 = myToT:CreateFontString(nil, "ARTWORK", "GameTooltipHeaderText")
		myToT.row1:SetPoint("TOPLEFT",myToT,"TOPLEFT",9,-9)
		myToT:SetParent(GameTooltip)

		-- This is what we run when GameTooltip is being shown, or has been updated
		local function updateTooltip(self)
			-- If selected with slashcommand, hide tooltip in combat
			if miniTipDB.combathide and inCombat then
				self:Hide()
				return
			-- Otherwise, let's modify the GameTooltip
			else
				-- Does "mouseover" exist and it also a player?
				if UnitExists("mouseover") and UnitIsPlayer("mouseover") then
					-- Let's gather info from the mouseover
					local GUID = UnitGUID("mouseover")
					local unitTitle = UnitPVPName("mouseover")
					local unitClass, unitClassFilename, unitRace, unitRaceFilename, unitSex, unitName, unitRealm = GetPlayerInfoByGUID(GUID)
					local unitGuild = GetGuildInfo("mouseover")
					local unitLevel = UnitLevel("mouseover")
					local unitDiff = GetQuestDifficultyColor(unitLevel)
					local unitFaction = UnitFactionGroup("mouseover")
					local unitPvP = UnitIsPVP("mouseover")
					local unitAFK = UnitIsAFK("mouseover")
					-- If Reaction was received, use it. Otherwise use gray color.
					local unitReaction = FACTION_BAR_COLORS[UnitReaction("mouseover", "player")] and FACTION_BAR_COLORS[UnitReaction("mouseover", "player")] or { r = 0.5, g = 0.5, b = 0.5 }
					-- If ClassColor was received, use it. Otherwise use gray color.
					local unitClassColor = RAID_CLASS_COLORS[unitClassFilename] and RAID_CLASS_COLORS[unitClassFilename] or { r = 0.5, g = 0.5, b = 0.5 }

					-- Unit has PvP on, let's mark it
					if unitPvP then unitPvP = "PvP" end
					-- Unit is AFK, let's mark it
					if unitAFK then unitAFK = "<AFK>" else unitAFK = "" end

					-- In case the info was not received properly, revert to "Unknown"
					if not unitTitle then unitTitle = "Unknown" end
					if not unitName then unitName = "Unknown" end
					if not unitRace then unitRace = "Unknown" end
					if not unitClass then unitClass = "Unknown" end
					-- If the realm is same than yours, we need to set it because it will be nil
					if not unitRealm then unitRealm = "" end
					-- Is level too big to see, then let's change it to skull-texture
					if unitLevel == -1 then unitLevel = skull end

					-- Tooltip line scanning
					local nameline,guildline,levelline,factionline,pvpline = _G["GameTooltipTextLeft1"],_G["GameTooltipTextLeft2"]
					for i=1,8 do
						local left = _G["GameTooltipTextLeft"..i]
						-- Search for text "Level XX Race Class (Player)", get the line number
						if left:GetText() and string.match(left:GetText(),"Level .*(Player)") then
							levelline = left
						end
						-- Search for faction text, get the line number
						if left:GetText() and string.match(left:GetText(),unitFaction) then 
							factionline = left
						end
						-- Search for PvP text, get the line number
						if left:GetText() and string.match(left:GetText(),"PvP") then 
							pvpline = left
						end
					end

					-- Level not found, this is not a character.
					if not levelline then
						return
					end
					
					-- Tooltip border coloring by reaction
					GameTooltip:SetBackdropBorderColor(unitReaction.r,unitReaction.g,unitReaction.b,1)

					-- Show title or not
					local finalName = miniTipDB.hidetitle and unitName or unitTitle
					-- If realm exists and is shown, add '-' in it
					local finalRealm = miniTipDB.hiderealm and "" or (unitRealm ~= "" and "-"..unitRealm or "")
					-- If everything is shown, printedName will be "Title of the Player-Servername"
					local printedName = finalName..finalRealm

					-- Line 1, Name - Class-colored
					nameline:SetFormattedText("|cff%02x%02x%02x%s|r |cff7f7f7f%s|r", unitClassColor.r*255, unitClassColor.g*255, unitClassColor.b*255, printedName, unitAFK)

					-- Line 2, Guild (Optional, not shown if target not in a guild)
					local formattedText
					if unitGuild then
						-- If target is in same guild, color GameTooltip border and guildname violet
						if UnitIsInMyGuild("mouseover") then
							formattedText = "|cffFF00FF<%s>|r"
							GameTooltip:SetBackdropBorderColor(1,0,1,1)
						-- Otherwise, we'll go with the gray
						else
							formattedText = "|cffa9a9a9<%s>|r"
						end
						guildline:SetFormattedText(formattedText, unitGuild)
					end

					-- Line 2/3, Level XX Race Class (Line 3 if guild is present, otherwise 2). Level is Difficulty-colored and Class is Class-colored
					levelline:SetFormattedText("Level |cff%02x%02x%02x%s|r %s |cff%02x%02x%02x%s|r", unitDiff.r*255, unitDiff.g*255, unitDiff.b*255, unitLevel, unitRace, unitClassColor.r*255, unitClassColor.g*255, unitClassColor.b*255, unitClass)
					
					-- Line 3/4, Faction (Line 4 if guild is present, otherwise 3). Faction is Factioncolored
					factionline:SetFormattedText("|cff%02x%02x%02x%s|r",unitReaction.r*255, unitReaction.g*255, unitReaction.b*255, unitFaction)

					-- Line 4/5, PvP (Line 5 if guild is present, otherwise 4. Optional, not shown if unit is not PvP enabled). PvP is colored green
					if unitPvP then
						pvpline:SetFormattedText("|cff%02x%02x%02x%s|r", 0, 255, 0, unitPvP)
					end
					
					-- Apply changes, resize GameTooltip, etc.
					GameTooltip:Show()

					-- Show Target of mouseover
					local targettarget = UnitName("mouseovertarget")
					if miniTipDB.targetoftarget and targettarget then
						local mouseovertarget = UnitName("mouseovertarget")
						-- Targeting XXX YOU XXX!
						if (UnitIsUnit("mouseovertarget","player")) then
							mouseovertarget = cross..cross..cross.." |cffFF0000YOU|r "..cross..cross..cross
						end
						--local reactioncolor = FACTION_BAR_COLORS[UnitReaction("mouseover", "player")]
						local text = string.format("Targeting: |cff%02x%02x%02x"..mouseovertarget.."|r", unitReaction.r*255, unitReaction.g*255, unitReaction.b*255)
						myToT.row1:SetText(text)
						myToT:SetSize(myToT.row1:GetWidth()+20,32)
						myToT:SetBackdropBorderColor(unitReaction.r,unitReaction.g,unitReaction.b,1)
						myToT:Show()
					end
					
					-- Show Class of mouseover
					if miniTipDB.classicon then
						local t = CLASS_ICON_TCOORDS[unitClassFilename]
						-- If class is not yet received, use questionmark
						if not t then
							myClassIcontex:SetTexture(unavailable)
							myClassIcontex:SetTexCoord(0,1,0,1)
						-- Otherwise, use the correct icon
						else
							myClassIcontex:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
							myClassIcontex:SetTexCoord(unpack(t))
						end
						-- Color the Background and Border by Class-color
						myClassIcon:SetBackdropBorderColor(unitClassColor.r,unitClassColor.g,unitClassColor.b,1)
						myClassIcon:SetBackdropColor(unitClassColor.r,unitClassColor.g,unitClassColor.b,1)
						myClassIcon:SetSize(miniTipDB.classiconsize,miniTipDB.classiconsize)
						myClassIcon:Show()
						myRaceIcon:SetPoint("TOPLEFT",myClassIcon,"BOTTOMLEFT",0,3)
					else
						myRaceIcon:SetPoint("TOPLEFT",GameTooltip,"TOPRIGHT",-3,0)
					end
				
					-- Show Race of mouseover
					if miniTipDB.raceicon then
						-- If sex and race are not yet received, use questionmark
						if not unitSex or not unitRaceFilename then
							myRaceIcontex:SetTexture(unavailable)
						-- Otherwise, use the correct icon
						else
							myRaceIcontex:SetTexture(races[unitSex][unitRaceFilename])
						end
						-- Color the Background and Border by Reaction-color
						myRaceIcon:SetBackdropBorderColor(unitReaction.r,unitReaction.g,unitReaction.b,1)
						myRaceIcon:SetBackdropColor(unitReaction.r,unitReaction.g,unitReaction.b,1)
						myRaceIcon:SetSize(miniTipDB.raceiconsize,miniTipDB.raceiconsize)
						myRaceIcon:Show()
					end
				end
			end
		end

		-- Hide all custom frames
		local function hideTooltip()
			myToT:Hide()
			myClassIcon:Hide()
			myRaceIcon:Hide()
		end

		-- Unregister PLAYER_LOGIN
		self:UnregisterEvent(event)
		-- Hook some functions
		GameTooltip:HookScript("OnTooltipSetUnit", updateTooltip)
		GameTooltip:HookScript("OnUpdate", updateTooltip)
		GameTooltip:HookScript("OnHide", hideTooltip)

		-- Anchor magic happens here
		hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
			local frame = GetMouseFocus()
			-- Anchor to mouse if mouseovering anything else than spells/items
			if frame == WorldFrame then
				tooltip:SetOwner(parent, "ANCHOR_CURSOR")
			-- Otherwise anchor above the button
			else
				tooltip:ClearAllPoints()
				tooltip:SetOwner(parent, "ANCHOR_NONE")
				tooltip:SetPoint("BOTTOMLEFT",frame,"TOPLEFT",-4,3)
			end
		end)
		
		-- Slashcommands
		SLASH_miniTip1 = "/mint"
		SLASH_miniTip2 = "/minitip"
		SlashCmdList["miniTip"] = function(msg)
			-- Separate slashcommand sub-command(s) into two, example /minitip class 50 -> "class 50" -> "class", "50"
			local a, b = strsplit(" ", msg, 2)
			if a == "title" then
				if miniTipDB.hidetitle then miniTipDB.hidetitle = false else miniTipDB.hidetitle = true end
				ChatFrame1:AddMessage(miniTip..": Hiding title: "..tostring(miniTipDB.hidetitle))
			elseif a == "realm" then
				if miniTipDB.hiderealm then miniTipDB.hiderealm = false else miniTipDB.hiderealm = true end
				ChatFrame1:AddMessage(miniTip..": Hiding realm: "..tostring(miniTipDB.hiderealm))
			elseif a == "class" then
				-- make sure b is a number, and between 20 to 100
				if b and tonumber(b) and (tonumber(b) >= 20 and tonumber(b) <= 100) then
					miniTipDB.classiconsize = b
					ChatFrame1:AddMessage(miniTip..": Changing Class icon size to: "..tostring(miniTipDB.classiconsize))
				elseif not b then
					if miniTipDB.classicon then miniTipDB.classicon = false else miniTipDB.classicon = true end
					ChatFrame1:AddMessage(miniTip..": Showing Class icon: "..tostring(miniTipDB.classicon))
				else
					ChatFrame1:AddMessage(miniTip..": Error, give proper value. Example: /minitip class "..miniTipDB.classiconsize)
				end
			elseif a == "race" then
				-- make sure b is a number, and between 20 to 100
				if b and tonumber(b) and (tonumber(b) >= 20 and tonumber(b) <= 100) then
					miniTipDB.raceiconsize = b
					ChatFrame1:AddMessage(miniTip..": Changing Race icon size to: "..tostring(miniTipDB.raceiconsize))
				elseif not b then
					if miniTipDB.raceicon then miniTipDB.raceicon = false else miniTipDB.raceicon = true end
					ChatFrame1:AddMessage(miniTip..": Showing Race icon: "..tostring(miniTipDB.raceicon))
				else
					ChatFrame1:AddMessage(miniTip..": Error, give proper value. Example: /minitip race "..miniTipDB.raceiconsize)
				end
			elseif a == "target" then
				if miniTipDB.targetoftarget then miniTipDB.targetoftarget = false else miniTipDB.targetoftarget = true end
				ChatFrame1:AddMessage(miniTip..": Showing Target of Target: "..tostring(miniTipDB.targetoftarget))
			elseif a == "combat" then
				if miniTipDB.combathide then miniTipDB.combathide = false else miniTipDB.combathide = true end
				ChatFrame1:AddMessage(miniTip..": Hiding tooltip in combat: "..tostring(miniTipDB.combathide))
			else
				ShowUIPanel(ItemRefTooltip)
				if not ItemRefTooltip:IsShown() then ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE") end
				ItemRefTooltip:ClearLines()
				ItemRefTooltip:AddLine(miniTip..": Accepting following slashcommands:")
				ItemRefTooltip:AddDoubleLine(" /minitip title","Hide Title, true/false")
				ItemRefTooltip:AddDoubleLine(" /minitip realm","Hide Realm, true/false")
				ItemRefTooltip:AddDoubleLine(" /minitip target","Show Target of Target, true/false")
				ItemRefTooltip:AddDoubleLine(" /minitip combat","Hide in combat, true/false")
				ItemRefTooltip:AddDoubleLine(" /minitip class","Show Class icon, true/false")
				ItemRefTooltip:AddDoubleLine(" /minitip race","Show Race icon, true/false")
				ItemRefTooltip:AddDoubleLine(" /minitip class X","Change Class icon size, 20-100")
				ItemRefTooltip:AddDoubleLine(" /minitip race X","Change Race icon size, 20-100")
				ItemRefTooltip:Show()
			end
		end
	-- Player has entered combat
	elseif event == "PLAYER_REGEN_DISABLED" then
		inCombat = true
	-- Player has left combat
	elseif event == "PLAYER_REGEN_ENABLED" then
		inCombat = nil
	end
end)