--╔════════════════════════╗
--║ ┌─┐┌─┐┬ ┬┬─┐┌─┐  ┬ ┬┬  ║
--║ └─┐├─┘└┬┘├┬┘│ │  │ ││  ║
--║ └─┘┴   ┴ ┴└─└─┘  └─┘┴  ║
--╠════════════════════════╣
--║      Boss Frames       ║
--╠════════════════════════╣
--║ By Spyro [Sanguino EU] ║
--╚════════════════════════╝

-- Local namespace vars
local _, Addon = ... -- Shared table between all files
local oUF, C, Lib, Style = Addon.oUF, Addon.Config.Boss, Addon.Lib, Addon.Style

-- Styling function
oUF:RegisterStyle("Boss", function(F)
  Style.Base(F, C) -- Styling all the basic components
  Lib.CreateRaidStyleAuras(F, C)

  -- Target marker
  F.RaidTargetIndicator = F:CreateTexture(nil, "OVERLAY")
  F.RaidTargetIndicator:SetSize(24, 24)
  F.RaidTargetIndicator:SetPoint("CENTER", F, "TOP", 0, 1)

  -- Debuffs
  F.Debuffs:AddAuraGroup("PersonalAuras", "HARMFUL|PLAYER|!CROWD_CONTROL", {
    initializeFrame = function(Button) Lib.ConfigureAuraButton(Button, { Size = 30, ShowSwipe = false, ShowCountdown = true, ShowPandemic = true }) end,
    sortMethod = AuraContainerSortMethod.Name,
    candidateFilters = { nameplateShowPersonal = true }, -- To show our DoTs similar to the ones shown on nameplates
  })

  -- Buffs
  local BuffOptions = {
    initializeFrame = function(Button) Lib.ConfigureAuraButton(Button, { Size = C.Buffs.Size }) end,
    sortMethod = AuraContainerSortMethod.Name
  }
  F.Buffs:AddAuraGroup("1", "HELPFUL|PLAYER|RAID_IN_COMBAT", BuffOptions) -- For Valithria type encounters where you heal the boss
  F.Buffs:AddAuraGroup("2", "HELPFUL|!PLAYER|IMPORTANT", BuffOptions)
  F.Buffs:AddAuraGroup("3", "HELPFUL|!PLAYER|DISPELLABLE|!IMPORTANT", BuffOptions)
  F.Buffs:AddAuraGroup("4", "HELPFUL|!PLAYER|!DISPELLABLE|!IMPORTANT", BuffOptions)
  F.Buffs:SetAuraGroupCandidateFilters("4", { isBossOrRoleAura = true })
end)

-- Creation and positioning
oUF:SetActiveStyle("Boss")
for i = 1, 5 do oUF:Spawn("boss"..i, "SpyroBoss"..i) end
Lib.UnitFrames_SetGrowthDirection(C.GrowthDirection, C.Anchor, SpyroBoss1, SpyroBoss2, SpyroBoss3, SpyroBoss4, SpyroBoss5)