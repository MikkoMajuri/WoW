local lib, oldminor = LibStub:NewLibrary("LibMessageFrame",1)
if not lib then return end

local debugLibMessageFrame = false
-- <nevcairiel> you should give the message frame a metatable so you can call messageframe:row instead of MF.row(messageframe

local function smartpos(parent)
	local tmptable = {}

	for k,v in pairs(parent.rows) do
		if v.visible then
			table.insert(tmptable,v)
		end
	end

	for k,v in pairs(tmptable) do
		local row = tmptable[k]
		if k == 1 then
			row:ClearAllPoints()
			row:SetPoint("TOPLEFT",parent,"TOPLEFT")
		else
			row:ClearAllPoints()
			row:SetPoint("TOPLEFT",parent.rows[k-1],"BOTTOMLEFT")
		end
	end
end

function lib.New(name,x,y,...)
	local frame = CreateFrame("Frame", name, UIParent)
	frame:SetSize(x,y)
	if select(1, ...) then frame:SetPoint(...) end
	if debugLibMessageFrame then
		frame.bg = frame:CreateTexture(nil, "BACKGROUND")
		frame.bg:SetTexture(0,0,0,0.5)
		frame.bg:SetAllPoints(frame)
	end
	frame.rows = {}
	frame.visible = {}
	return frame
end
	
function lib.Row(parent,font,text,identify,...)
	for k,v in pairs(parent.rows) do 
		if v.ident == identify then return end -- Frame already exists
	end
	local row = CreateFrame("Frame",nil,parent)
	row.text = row:CreateFontString(nil, "ARTWORK", font)
	row.text:SetAllPoints(row)
	row.text:SetJustifyH("LEFT")
	row.text:SetText(text)
	if select(1, ...) then
		row:SetPoint(...)
	else
		row:SetPoint("TOPLEFT",parent,"TOPLEFT")
	end
	if debugLibMessageFrame then
		row.BG = row:CreateTexture(nil,"BACKGROUND")
		row.BG:SetTexture(0,1,0,0.5)
		row.BG:SetAllPoints(row)
	end
	row:Show()
	rowheight = row.text:GetHeight()
	row:SetSize(parent:GetWidth(),rowheight)
	row.ident = identify
	row.visible = true
	table.insert(parent.rows,row)
	return row
end

function lib.Update(parent,identify,text)
	for k,v in pairs(parent.rows) do
		if v.ident == identify then
			v.text:SetText(text)
		end
	end
end

function lib.Change(parent,identify,new)
	for k,v in pairs(parent.rows) do
		if v.ident == identify then
			v.ident = new
		end
	end
end

function lib.Hide(parent,identify)
	for k,v in pairs(parent.rows) do
		if v.ident == identify then
			v.visible = false
			v:Hide()
		end
	end
	
	smartpos(parent)
end

function lib.Show(parent,identify)
	for k,v in pairs(parent.rows) do
		if v.ident == identify then
			v.visible = true
			v:Show()
		end
	end

	smartpos(parent)
end

function lib.HideAll(parent)
	parent:Hide()
end


function lib.ShowAll(parent)
	parent:Show()
end