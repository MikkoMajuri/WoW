if IsAddOnLoaded("cargBags_Nivaya") then
	
	Stamp.Custom = true
	
	Stamp.BagSlots = {}
	local function tablecopy(t)
		for k, v in pairs(t) do table.insert(Stamp.BagSlots,v) end
		return setmetatable(Stamp.BagSlots, getmetatable(t))
	end

	local frame = CreateFrame("Frame")
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:RegisterEvent("BANKFRAME_OPENED")
	frame:SetScript("OnEvent", function(self,event)
		if event == "PLAYER_LOGIN" then
			self:UnregisterEvent(event)

			-- Delay the process after login
			local function timerFunction(self)
				if next(Stamp.BagSlots) then
					self:Cancel()
					return
				end

				tablecopy(Nivaya.buttons)
				Stamp.CreateText()

				function Stamp.MarkBags()
					for idx,entry in pairs(Stamp.BagSlots) do
						local itemButton = entry
						local bag = entry.bagID
						local slot = entry.slotID
						for k,v in pairs(StampDB) do
							if GetContainerItemID(bag,slot) and GetContainerItemID(bag,slot) == k then
								_G[itemButton:GetName()].text:SetText(Stamp.items[v])
							end
						end
					end
				end
				Nivaya:HookScript("OnShow", Stamp.MarkBags)
			end

			local ticker = C_Timer.NewTicker(1, function(self) timerFunction(self) end, nil)

		else
			self:UnregisterEvent(event)
			tablecopy(Nivaya.buttons)
			Stamp.CreateText()
		end
	end)
end