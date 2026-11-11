--╔════════════════════════╗
--║ ┌─┐┌─┐┬ ┬┬─┐┌─┐  ┬ ┬┬  ║
--║ └─┐├─┘└┬┘├┬┘│ │  │ ││  ║
--║ └─┘┴   ┴ ┴└─└─┘  └─┘┴  ║
--╠════════════════════════╣
--║      Arena Frames      ║
--╠════════════════════════╣
--║ By Spyro [Sanguino EU] ║
--╚════════════════════════╝

-- Local namespace vars
local _, Addon = ... -- Shared table between all files
local oUF, Config, Lib, Style = Addon.oUF, Addon.Config.Arena, Addon.Lib, Addon.Style

-- Styling function
oUF:RegisterStyle("Arena", function(F)
  Style.Base(F, Config) -- Styling all the basic components

  -- Target marker
  F.RaidTargetIndicator = F:CreateTexture(nil, "OVERLAY")
  F.RaidTargetIndicator:SetSize(24, 24)
  F.RaidTargetIndicator:SetPoint("CENTER", F, "TOP", 0, 1)

  -- Spec icon
  F.SpecIcon = F:CreateTexture(nil, "OVERLAY")
  F.SpecIcon:SetSize(Config.SpecIcon.Size, Config.SpecIcon.Size)
  Lib.AnchorElement(F.SpecIcon, Config.SpecIcon.Anchor, F)

  -- Resurrect indicator
  F.ResurrectIndicator = F:CreateTexture(nil, "OVERLAY")
  F.ResurrectIndicator:SetSize(32, 32)
  F.ResurrectIndicator:SetPoint("CENTER", F.HealthBar)

  -- Show CC and important helpful buffs inside the frame
  local Init = function(Button) Lib.ConfigureAuraButton(Button, { Size = Config.Auras.Size, ShowSwipe = false, ShowCountdown = true }) end
  F.CCandBuffs = Lib.CreateAuraContainer(F.__unit, F, "BOTTOMLEFT", F, "BOTTOMLEFT", 3, 1, Config.BarWidth - 6)
  F.CCandBuffs:AddAuraGroup("CC", "HARMFUL|CROWD_CONTROL", { initializeFrame = Init })
  F.CCandBuffs:AddAuraGroup("Buffs1", "HELPFUL|BIG_DEFENSIVE|!EXTERNAL_DEFENSIVE", { initializeFrame = Init })
  F.CCandBuffs:AddAuraGroup("Buffs2", "HELPFUL|EXTERNAL_DEFENSIVE", { initializeFrame = Init })
  F.CCandBuffs:AddAuraGroup("Buffs3", "HELPFUL|IMPORTANT", { initializeFrame = Init })

  -- PvP trinket
  F.Trinket = CreateFrame("Cooldown", nil, F, "CooldownFrameTemplate")
  F.Trinket:SetPoint("BOTTOMLEFT", F, "BOTTOMRIGHT", 0, 0)
  F.Trinket:SetSize(F:GetHeight(), F:GetHeight())
  F.Trinket:SetDrawSwipe(false)
  F.Trinket:SetHideCountdownNumbers(false)
  F.Trinket.Icon = F.Trinket:CreateTexture()
  F.Trinket.Icon:SetTexture("interface/icons/ability_pvp_gladiatormedallion")
  F.Trinket.Icon:SetAllPoints()
  local function TrinketUpdate() F.Trinket:SetCooldownFromDurationObject(C_PvP.GetArenaCrowdControlDuration(F.__unit)) end

  -- Request of CC data
  Lib.RegisterEvent("ARENA_OPPONENT_UPDATE", function(Unit, UpdateReason) -- There isn't an unit version of this event :-/
    if Unit == F.__unit and UpdateReason == "seen" then C_PvP.RequestCrowdControlSpell(Unit) end
  end)

  -- Trinket updates
  Lib.RegisterUnitEvent("ARENA_CROWD_CONTROL_SPELL_UPDATE", F.__unit, TrinketUpdate)
  Lib.RegisterEvent("ARENA_COOLDOWNS_UPDATE", function(Unit) -- There isn't an unit version of this event :-/
    if Unit == F.__unit then TrinketUpdate() end
  end)

  -- Making the trinket smaller if a pet appears
  Lib.RegisterUnitEvent("UNIT_PET", F.__unit, function(Unit)
    local TrinketSize = UnitExists(Unit.."pet") and F:GetHeight() or F:GetHeight() / 2 - 2
    F.TrinketSize:SetSize(TrinketSize, TrinketSize)
  end)
end)

-- Creation and positioning
oUF:SetActiveStyle("Arena")
for i = 1, 5 do oUF:Spawn("arena"..i, "SpyroArena"..i) end
Lib.UnitFrames_SetGrowthDirection(Config.GrowthDirection, Config.Anchor, SpyroArena1, SpyroArena2, SpyroArena3, SpyroArena4, SpyroArena5)