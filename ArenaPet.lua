--╔════════════════════════╗
--║ ┌─┐┌─┐┬ ┬┬─┐┌─┐  ┬ ┬┬  ║
--║ └─┐├─┘└┬┘├┬┘│ │  │ ││  ║
--║ └─┘┴   ┴ ┴└─└─┘  └─┘┴  ║
--╠════════════════════════╣
--║       ArenaPets        ║
--╠════════════════════════╣
--║ By Spyro [Sanguino EU] ║
--╚════════════════════════╝

-- Local namespace vars
local _, Addon = ... -- Shared table between all files
local oUF, Config, Lib, Style = Addon.oUF, Addon.Config.ArenaPet, Addon.Lib, Addon.Style
if not Config.Enabled then return end

-- Styling function
oUF:RegisterStyle("ArenaPet", function(F)
  Style.Base(F, Config) -- Styling all the basic components

  -- Target marker
  F.RaidTargetIndicator = F:CreateTexture(nil, "OVERLAY")
  F.RaidTargetIndicator:SetSize(24, 24)
  F.RaidTargetIndicator:SetPoint("CENTER", F, "TOP", 0, 1)

  -- Resurrect indicator
  F.ResurrectIndicator = F:CreateTexture(nil, "OVERLAY")
  F.ResurrectIndicator:SetSize(28, 28)
  F.ResurrectIndicator:SetPoint("CENTER", F.HealthBar)

  -- Show CC and important helpful buffs inside the frame
  local Init = function(Button) Lib.ConfigureAuraButton(Button, { Size = Config.Auras.Size, ShowSwipe = false, ShowCountdown = true }) end
  F.CCandBuffs = Lib.CreateAuraContainer(F.__unit, F, "BOTTOMLEFT", F, "BOTTOMLEFT", 3, 1, Config.BarWidth - 6)
  F.CCandBuffs:AddAuraGroup("CC", "HARMFUL|CROWD_CONTROL", { initializeFrame = Init })
  F.CCandBuffs:AddAuraGroup("Buffs1", "HELPFUL|BIG_DEFENSIVE|!EXTERNAL_DEFENSIVE", { initializeFrame = Init })
  F.CCandBuffs:AddAuraGroup("Buffs2", "HELPFUL|EXTERNAL_DEFENSIVE", { initializeFrame = Init })
  F.CCandBuffs:AddAuraGroup("Buffs3", "HELPFUL|IMPORTANT", { initializeFrame = Init })
end)

-- Creation and positioning
oUF:SetActiveStyle("ArenaPet")
for i = 1, 4 do
  local Frame = oUF:Spawn("arenapet"..i, "SpyroArenaPet"..i)
  Frame:SetPoint("TOPLEFT", _G["SpyroArena"..i], "TOPRIGHT", 1, 0)
end