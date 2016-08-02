if IsAddOnLoaded("ArkInventory") then

	Stamp.Custom = true

	local frame = CreateFrame("Frame")
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:SetScript("OnEvent", function(self,event)
		self:UnregisterEvent(event)
		Stamp.BagSlots = {}
		for i = 0, 11 do
			local maxSlots = 36
			for slotNumber = 1, maxSlots do
				local itemButton = _G["ARKINV_Frame1ScrollContainerBag" .. i + 1 .. "Item" .. slotNumber]
				table.insert(Stamp.BagSlots,itemButton)
			end
		end
		Stamp.CreateText()
		
		local createBank
		
		function Stamp.MarkBags()
			for idx,entry in pairs(Stamp.BagSlots) do
				local bag = entry:GetParent():GetID()
				local slot = entry:GetID()
				for k,v in pairs(StampDB) do
					if GetContainerItemID(bag,slot) == k then
						_G[entry:GetName()].text:SetText(Stamp.items[v])
					end
				end
			end
		end

		ARKINV_Frame1:HookScript("OnShow", Stamp.MarkBags)
		ARKINV_Frame3:SetScript("OnShow", function(self)
			-- ArkInventory is superslow, need to add a timer to slow Stamp down...
			C_Timer.NewTimer(0.1, function(self)
				if not createBank then
					for i = 0, 6 do
						local maxSlots = 36
						for slotNumber = 1, maxSlots do
							local itemButton = _G["ARKINV_Frame3ScrollContainerBag" .. i + 1 .. "Item" .. slotNumber]
							table.insert(Stamp.BagSlots,itemButton)
						end
					end
					Stamp.CreateText()
					createBank = true
				end
				Stamp.MarkBags()
			end)
		end)
	end)
end