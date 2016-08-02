local _, class = UnitClass("player")

local prio = {}
if class == "DEATHKNIGHT" then
	prio["Blood"] = {
		[1] = format(STAT_FORMAT, ARMOR), --= 100,
		[2] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 90,
		[3] = format(STAT_FORMAT, STAT_HASTE), --= 85,
		[4] = format(STAT_FORMAT, SPELL_STAT1_NAME), --= 80,
		[5] = format(STAT_FORMAT, STAT_VERSATILITY), --= 75,
		[6] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 70,
		[7] = format(STAT_FORMAT, STAT_MASTERY), --= 60,
	}
	prio["Frost"] = {
		[1] = format(STAT_FORMAT, SPELL_STAT1_NAME), --= 100,
		[2] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 43,
		[3] = format(STAT_FORMAT, STAT_VERSATILITY), --= 41,
		[4] = format(STAT_FORMAT, STAT_HASTE), --= 37,
		[5] = format(STAT_FORMAT, STAT_MASTERY), --= 36,
		[6] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 35,
	}
	prio["Unholy"] = {
		[1] = format(STAT_FORMAT, SPELL_STAT1_NAME), --= 100,
		[2] = format(STAT_FORMAT, STAT_MASTERY), --= 56,
		[3] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 52,
		[4] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 40,
		[5] = format(STAT_FORMAT, STAT_VERSATILITY), --= 37,
		[6] = format(STAT_FORMAT, STAT_HASTE), --= 29,
	}
end

if class == "DRUID" then
	prio["Balance"] = {
		[1] = format(STAT_FORMAT, SPELL_STAT4_NAME), --= 100,
		[2] = format(STAT_FORMAT, STAT_HASTE), --= 50,
		[3] = format(STAT_FORMAT, STAT_MASTERY), --= 49,
		[4] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 46,
		[5] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 46,
		[6] = format(STAT_FORMAT, STAT_VERSATILITY), --= 39,
	}
	prio["Feral"] = {
		[1] = format(STAT_FORMAT, SPELL_STAT2_NAME), --= 100,
		[2] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 46,
		[3] = format(STAT_FORMAT, STAT_VERSATILITY), --= 38,
		[4] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 38,
		[5] = format(STAT_FORMAT, STAT_MASTERY), --= 36,
		[6] = format(STAT_FORMAT, STAT_HASTE), --= 30,
	}
	prio["Guardian"] = {
		[1] = format(STAT_FORMAT, ARMOR), --= 100,
		[2] = format(STAT_FORMAT, SPELL_STAT2_NAME), --= 96,
		[3] = format(STAT_FORMAT, STAT_MASTERY), --= 80,
		[4] = format(STAT_FORMAT, STAT_VERSATILITY), --= 75,
		[5] = format(STAT_FORMAT, STAT_HASTE), --= 55,
		[6] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 30,
	}
	prio["Restoration"] = {
		[1] = format(STAT_FORMAT, SPELL_STAT4_NAME), --= 100,
		[2] = format(STAT_FORMAT, SPELL_STAT5_NAME), --= 85,
		[3] = format(STAT_FORMAT, STAT_HASTE), --= 75,
		[4] = format(STAT_FORMAT, STAT_MASTERY), --= 65,
		[5] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 60,
		[6] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 55,
		[7] = format(STAT_FORMAT, STAT_VERSATILITY), --= 50,
	}
end

if class == "HUNTER" then
	prio["Beast Mastery"] = {
		[1] = format(STAT_FORMAT, SPELL_STAT2_NAME), --= 100,
		[2] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 40,
		[3] = format(STAT_FORMAT, STAT_HASTE), --= 38,
		[4] = format(STAT_FORMAT, STAT_MASTERY), --= 38,
		[5] = format(STAT_FORMAT, STAT_VERSATILITY), --= 36,
		[6] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 35,
	}
	prio["Marksmanship"] = {
		[1] = format(STAT_FORMAT, SPELL_STAT2_NAME), --= 100,
		[2] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 46,
		[3] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 45,
		[4] = format(STAT_FORMAT, STAT_VERSATILITY), --= 41,
		[5] = format(STAT_FORMAT, STAT_MASTERY), --= 39,
		[6] = format(STAT_FORMAT, STAT_HASTE), --= 33,
	}
	prio["Survival"] = {
		[1] = format(STAT_FORMAT, SPELL_STAT2_NAME), --= 100,
		[2] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 45,
		[3] = format(STAT_FORMAT, STAT_VERSATILITY), --= 35,
		[4] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 34,
		[5] = format(STAT_FORMAT, STAT_MASTERY), --= 28,
		[6] = format(STAT_FORMAT, STAT_HASTE), --= 14,
	}
end

if class == "MAGE" then
	prio["Arcane"] = {
		[1] = format(STAT_FORMAT, SPELL_STAT4_NAME), --= 100,
		[2] = format(STAT_FORMAT, STAT_MASTERY), --= 55,
		[3] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 48,
		[4] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 44,
		[5] = format(STAT_FORMAT, STAT_HASTE), --= 41,
		[6] = format(STAT_FORMAT, STAT_VERSATILITY), --= 39,
	}
	prio["Fire"] = {
		[1] = format(STAT_FORMAT, SPELL_STAT4_NAME), --= 100,
		[2] = format(STAT_FORMAT, STAT_HASTE), --= 56,
		[3] = format(STAT_FORMAT, STAT_MASTERY), --= 55,
		[4] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 55,
		[5] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 50,
		[6] = format(STAT_FORMAT, STAT_VERSATILITY), --= 38,
	}
	prio["Frost"] = {
		[1] = format(STAT_FORMAT, SPELL_STAT4_NAME), --= 100,
		[2] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 60,
		[3] = format(STAT_FORMAT, STAT_VERSATILITY), --= 45,
		[4] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 44,
		[5] = format(STAT_FORMAT, STAT_MASTERY), --= 38,
		[6] = format(STAT_FORMAT, STAT_HASTE), --= 29,
	}
end

if class == "MONK" then
	prio["Brewmaster"] = {
		[1] = format(STAT_FORMAT, ARMOR), --= 100,
		[2] = format(STAT_FORMAT, STAT_MASTERY), --= 90,
		[3] = format(STAT_FORMAT, STAT_VERSATILITY), --= 85,
		[4] = format(STAT_FORMAT, SPELL_STAT2_NAME), --= 80,
		[5] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 75,
		[6] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 70,
		[7] = format(STAT_FORMAT, STAT_HASTE), --= 63,
	}
	prio["Mistweaver"] = {
		[1] = format(STAT_FORMAT, SPELL_STAT4_NAME), --= 100,
		[2] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 90,
		[3] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 80,
		[4] = format(STAT_FORMAT, SPELL_STAT5_NAME), --= 75,
		[5] = format(STAT_FORMAT, STAT_VERSATILITY), --= 65,
		[6] = format(STAT_FORMAT, STAT_HASTE), --= 60,
		[7] = format(STAT_FORMAT, STAT_MASTERY), --= 40,
	}
	prio["Windwalker"] = {
		[1] = format(STAT_FORMAT, SPELL_STAT2_NAME), --= 100,
		[2] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 47,
		[3] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 39,
		[4] = format(STAT_FORMAT, STAT_VERSATILITY), --= 39,
		[5] = format(STAT_FORMAT, STAT_HASTE), --= 37,
		[6] = format(STAT_FORMAT, STAT_MASTERY), --= 23,
	}
end

if class == "PALADIN" then
	prio["Holy"] = {
		[1] = format(STAT_FORMAT, SPELL_STAT4_NAME), --= 100,
		[2] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 90,
		[3] = format(STAT_FORMAT, SPELL_STAT5_NAME), --= 85,
		[4] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 80,
		[5] = format(STAT_FORMAT, STAT_MASTERY), --= 75,
		[6] = format(STAT_FORMAT, STAT_VERSATILITY), --= 65,
		[7] = format(STAT_FORMAT, STAT_HASTE), --= 55,
	}
	prio["Protection"] = {
		[1] = format(STAT_FORMAT, ARMOR), --= 100,
		[2] = format(STAT_FORMAT, SPELL_STAT1_NAME), --= 89,
		[3] = format(STAT_FORMAT, SPELL_STAT3_NAME), --= 84,
		[4] = format(STAT_FORMAT, STAT_MASTERY), --= 80,
		[5] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 70,
		[6] = format(STAT_FORMAT, STAT_VERSATILITY), --= 69,
		[7] = format(STAT_FORMAT, STAT_ATTACK_POWER), --= 68,
		[8] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 64,
		[9] = format(STAT_FORMAT, STAT_HASTE), --= 60,
	}
	prio["Retribution"] = {
		[1] = format(STAT_FORMAT, SPELL_STAT1_NAME), --= 100,
		[2] = format(STAT_FORMAT, STAT_MASTERY), --= 56,
		[3] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 45,
		[4] = format(STAT_FORMAT, STAT_HASTE), --= 44,
		[5] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 44,
		[6] = format(STAT_FORMAT, STAT_VERSATILITY), --= 41,
	}
end

if class == "PRIEST" then
	prio["Discipline"] = {
		[1] = format(STAT_FORMAT, SPELL_STAT4_NAME), --= 100,
		[2] = format(STAT_FORMAT, SPELL_STAT5_NAME), --= 80,
		[3] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 65,
		[4] = format(STAT_FORMAT, STAT_MASTERY), --= 60,
		[5] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 55,
		[6] = format(STAT_FORMAT, STAT_VERSATILITY), --= 45,
		[7] = format(STAT_FORMAT, STAT_HASTE), --= 30,
	}
	prio["Holy"] = {
		[1] = format(STAT_FORMAT, SPELL_STAT4_NAME), --= 100,
		[2] = format(STAT_FORMAT, SPELL_STAT5_NAME), --= 81,
		[3] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 75,
		[4] = format(STAT_FORMAT, STAT_MASTERY), --= 70,
		[5] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 65,
		[6] = format(STAT_FORMAT, STAT_VERSATILITY), --= 60,
		[7] = format(STAT_FORMAT, STAT_HASTE), --= 55,
	}
	prio["Shadow"] = {
		[1] = format(STAT_FORMAT, SPELL_STAT4_NAME), --= 100,
		[2] = format(STAT_FORMAT, STAT_MASTERY), --= 51,
		[3] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 48,
		[4] = format(STAT_FORMAT, STAT_HASTE), --= 47,
		[5] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 44,
		[6] = format(STAT_FORMAT, STAT_VERSATILITY), --= 39,
	}
end

if class == "ROGUE" then
	prio["Assassination"] = {
		[1] = format(STAT_FORMAT, SPELL_STAT2_NAME), --= 100,
		[2] = format(STAT_FORMAT, STAT_HASTE), --= 41,
		[3] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 40,
		[4] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 37,
		[5] = format(STAT_FORMAT, STAT_VERSATILITY), --= 36,
		[6] = format(STAT_FORMAT, STAT_MASTERY), --= 35,
	}
	prio["Combat"] = {
		[1] = format(STAT_FORMAT, SPELL_STAT2_NAME), --= 100,
		[2] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 48,
		[3] = format(STAT_FORMAT, STAT_MASTERY), --= 39,
		[4] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 35,
		[5] = format(STAT_FORMAT, STAT_VERSATILITY), --= 34,
		[6] = format(STAT_FORMAT, STAT_HASTE), --= 30,
	}
	prio["Subtlety"] = {
		[1] = format(STAT_FORMAT, SPELL_STAT2_NAME), --= 100,
		[2] = format(STAT_FORMAT, STAT_MASTERY), --= 44,
		[3] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 42,
		[4] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 36,
		[5] = format(STAT_FORMAT, STAT_VERSATILITY), --= 35,
		[6] = format(STAT_FORMAT, STAT_HASTE), --= 23,
	}
end

if class == "SHAMAN" then
	prio["Elemental"] = {
		[1] = format(STAT_FORMAT, SPELL_STAT4_NAME), --= 100,
		[2] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 80,
		[3] = format(STAT_FORMAT, STAT_HASTE), --= 70,
		[4] = format(STAT_FORMAT, STAT_MASTERY), --= 55,
		[5] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 50,
		[6] = format(STAT_FORMAT, STAT_VERSATILITY), --= 50,
	}
	prio["Enhancement"] = {
		[1] = format(STAT_FORMAT, SPELL_STAT2_NAME), --= 100,
		[2] = format(STAT_FORMAT, STAT_HASTE), --= 42,
		[3] = format(STAT_FORMAT, STAT_MASTERY), --= 38,
		[4] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 38,
		[5] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 35,
		[6] = format(STAT_FORMAT, STAT_VERSATILITY), --= 35,
	}
	prio["Restoration"] = {
		[1] = format(STAT_FORMAT, SPELL_STAT4_NAME), --= 100,
		[2] = format(STAT_FORMAT, SPELL_STAT5_NAME), --= 65,
		[3] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 60,
		[4] = format(STAT_FORMAT, STAT_MASTERY), --= 58,
		[5] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 50,
		[6] = format(STAT_FORMAT, STAT_VERSATILITY), --= 45,
		[7] = format(STAT_FORMAT, STAT_HASTE), --= 40,
	}
end

if class == "WARLOCK" then
	prio["Affliction"] = {
		[1] = format(STAT_FORMAT, SPELL_STAT4_NAME), --= 100,
		[2] = format(STAT_FORMAT, STAT_MASTERY), --= 56,
		[3] = format(STAT_FORMAT, STAT_HASTE), --= 53,
		[4] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 47,
		[5] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 43,
		[6] = format(STAT_FORMAT, STAT_VERSATILITY), --= 39,
	}
	prio["Demonology"] = {
		[1] = format(STAT_FORMAT, SPELL_STAT4_NAME), --= 100,
		[2] = format(STAT_FORMAT, STAT_HASTE), --= 50,
		[3] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 46,
		[4] = format(STAT_FORMAT, STAT_MASTERY), --= 45,
		[5] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 45,
		[6] = format(STAT_FORMAT, STAT_VERSATILITY), --= 39,
	}
	prio["Destruction"] = {
		[1] = format(STAT_FORMAT, SPELL_STAT4_NAME), --= 100,
		[2] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 49,
		[3] = format(STAT_FORMAT, STAT_HASTE), --= 44,
		[4] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 43,
		[5] = format(STAT_FORMAT, STAT_MASTERY), --= 41,
		[6] = format(STAT_FORMAT, STAT_VERSATILITY), --= 40,
	}
end

if class == "WARRIOR" then
	prio["Arms"] = {
		[1] = format(STAT_FORMAT, SPELL_STAT1_NAME), --= 100,
		[2] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 54,
		[3] = format(STAT_FORMAT, STAT_MASTERY), --= 52,
		[4] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 46,
		[5] = format(STAT_FORMAT, STAT_VERSATILITY), --= 42,
		[6] = format(STAT_FORMAT, STAT_HASTE), --= 33,
	}
	prio["Fury"] = {
		[1] = format(STAT_FORMAT, SPELL_STAT1_NAME), --= 100,
		[2] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 65,
		[3] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 57,
		[4] = format(STAT_FORMAT, STAT_MASTERY), --= 57,
		[5] = format(STAT_FORMAT, STAT_HASTE), --= 51,
		[6] = format(STAT_FORMAT, STAT_VERSATILITY), --= 46,
	}
	prio["Protection"] = {
		[1] = format(STAT_FORMAT, STAT_VERSATILITY), --= 100,
		[2] = format(STAT_FORMAT, ARMOR), --= 95,
		[3] = format(STAT_FORMAT, STAT_MASTERY), --= 84,
		[4] = format(STAT_FORMAT, STAT_HASTE), --= 74,
		[5] = format(STAT_FORMAT, STAT_CRITICAL_STRIKE), --= 68,
		[6] = format(STAT_FORMAT, STAT_MULTISTRIKE), --= 63,
		[7] = format(STAT_FORMAT, SPELL_STAT1_NAME), --= 58,
	}
end

local stattable = {}
for k,v in pairs(PAPERDOLL_STATCATEGORY_DEFAULTORDER) do
   local max = #PAPERDOLL_STATCATEGORIES[v].stats
   for i=1,max do
      table.insert(stattable,"CharacterStatsPaneCategory"..k.."Stat"..i)
   end
end

local function updateStats()
	if not GetSpecialization() then return else
		local spec = select(2,GetSpecializationInfo(GetSpecialization()))
		for k,v in pairs(stattable) do
			if _G[v] then
				local text = _G[v].Label:GetText()
				for j,c in pairs(prio[spec]) do
					if text == c then
						_G[v].Label:SetText(text.." |cFFF720C2"..j.."|r")
					end
				end
			end
		end
	end
end

CharacterFrame:HookScript("OnShow", updateStats)
CharacterFrame:HookScript("OnUpdate", updateStats)