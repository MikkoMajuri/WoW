if IsAddOnLoaded("Bagnon") then
	
	Stamp.Custom = true
	
	Stamp.BagSlots = {}
	for bagNumber = 1,12 do
		for slotNumber = 1, 36 do
			local itemButton = _G["ContainerFrame" .. bagNumber .. "Item" .. slotNumber]
			table.insert(Stamp.BagSlots,itemButton)
		end
	end
	
	Stamp.CreateText()
	
	function Stamp.MarkBags()
		for idx,entry in ipairs(Stamp.BagSlots) do
			if _G[entry:GetName()].hasItem then
				local hasItem = string.match(_G[entry:GetName()].hasItem,"item:(%d+)")
				local hasItem = tonumber(hasItem)
				for k,v in pairs(StampDB) do
					if hasItem == k then
						_G[entry:GetName()].text:SetText(Stamp.items[v])
					end
				end
			end
		end
	end
	
	-- Bagnon frames are available after you have logged in.
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:SetScript("OnEvent", function(self,event)
		BagnonFrameinventory:HookScript("OnShow", Stamp.MarkBags)
	end)
end