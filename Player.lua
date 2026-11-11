--╔════════════════════════╗
--║ ┌─┐┌─┐┬ ┬┬─┐┌─┐  ┬ ┬┬  ║
--║ └─┐├─┘└┬┘├┬┘│ │  │ ││  ║
--║ └─┘┴   ┴ ┴└─└─┘  └─┘┴  ║
--╠════════════════════════╣
--║         Player         ║
--╠════════════════════════╣
--║ By Spyro [Sanguino EU] ║
--╚════════════════════════╝

-- Local namespace vars
local _, Addon = ... -- Shared table between all files
local oUF, Config, Lib, Style = Addon.oUF, Addon.Config.Player, Addon.Lib, Addon.Style

-- Styling function
function Style.Party(F, C) -- Player uses the same general style as Party members. This function will be also used on the Party module
  Style.Base(F, C) -- Styling all the basic components
  Lib.CreatePartyAuras(F, C)

  -- Summon indicator
  F.SummonIndicator = F:CreateTexture(nil, "OVERLAY")
  F.SummonIndicator:SetPoint("CENTER", F.HealthBar)

  -- Resurrect indicator
  F.ResurrectIndicator = F:CreateTexture(nil, "OVERLAY")
  F.ResurrectIndicator:SetSize(32, 32)
  F.ResurrectIndicator:SetPoint("CENTER", F.HealthBar)

  -- Ready check icon
  F.ReadyCheckIndicator = F:CreateTexture(nil, "OVERLAY")
  F.ReadyCheckIndicator:SetPoint("CENTER", F.HealthBar)
end

-- Registering style
oUF:RegisterStyle("Player", function(F)
  Style.Party(F, Config)
  --F.Castbar.SafeZone = F.Castbar:CreateTexture(nil, "OVERLAY") -- Castbar latency texture

  -- Rest indicator
  F.RestingIndicator = F.TextParent:CreateFontString(nil, "OVERLAY")
  F.RestingIndicator:SetFont(Addon.Media.."/Prototype.ttf", 12, "OUTLINE")
  F.RestingIndicator:SetTextColor(1, 0.82, 0)
  F.RestingIndicator:SetJustifyH("RIGHT")
  F.RestingIndicator:SetText("ZzZ")
  F.RestingIndicator:SetPoint("TOPRIGHT", F.Health, "TOPRIGHT", -1, -4)

  -- Additional power bar (like mana for Balance druids) (like mana for druids in cat form)
  F.AdditionalPower = CreateFrame("StatusBar", nil, F, "DisableUntrustedLayoutScriptsTemplate")
  F.AdditionalPower.colorPower = true
  F.AdditionalPower:SetOrientation("VERTICAL")
  F.AdditionalPower:SetStatusBarTexture(Addon.Media.."/FlatBar")
  F.AdditionalPower:SetSize(Config.PowerBar.Height + 2, F:GetHeight())
  F.AdditionalPower:SetPoint("BOTTOMRIGHT", F, "BOTTOMLEFT", 1, 0)
  F.AdditionalPower.Background = F.AdditionalPower:CreateTexture(nil, "BACKGROUND", nil, -7)
  F.AdditionalPower.Background:SetColorTexture(unpack(Config.PowerBar.BackgroundColor))
  F.AdditionalPower.Background:SetAllPoints()
  Lib.CreateFlatBackdrop(F.AdditionalPower, 1, 0.01, 0.01, 0.01) -- Border

  -- Encounter/quest power bar
  F.AlternativePower = CreateFrame("StatusBar", nil, F, "DisableUntrustedLayoutScriptsTemplate")
  F.AlternativePower.colorPower = true
  F.AlternativePower:SetSize(Config.AlternativePower.Width, Config.AlternativePower.Height)
  Lib.CreateFlatBackdrop(F.AlternativePower, 1, 0.01, 0.01, 0.01) -- Border
  Lib.AnchorElement(F.AlternativePower, Config.AlternativePower.Anchor, F)

  -- Enable aggro highlight only when in party and not in Arena
  local ThreatHightlightUpdate = function()
    if not IsInGroup() or Lib.InArena() then F:DisableElement("ThreatIndicator")
    else F:EnableElement("ThreatIndicator") end
  end

  Lib.RegisterEvent("GROUP_ROSTER_UPDATE", ThreatHightlightUpdate)
  Lib.RegisterEvent("PLAYER_ENTERING_WORLD", ThreatHightlightUpdate)

  -- Player's buffs that must always be visible
  if Config.PersonalBuffs[Lib.PLAYER_CLASS] then
    F.Buffs:AddAuraGroup("PersonalBuffs", "HELPFUL|PLAYER", {
      initializeFrame = function(Button) Lib.ConfigureAuraButton(Button, { Size = Config.Buffs.Size }) end,
      sortMethod = AuraContainerSortMethod.Name,
      sortDirection = AuraContainerSortDirection.Reverse,
      candidateFilters = { includeSpellIDs = Config.PersonalBuffs[Lib.PLAYER_CLASS] }
    })
  end

  -- AuraContainer to show personal buffs on the outer topleft of the frame
  if Config.PersonalBuffs2[Lib.PLAYER_CLASS] then
    local Swipe = Config.PersonalBuffs2[Lib.PLAYER_CLASS].ShowSwipe
    F.TrackedBuffs = Lib.CreateAuraContainer(F.__unit, F, "TOPRIGHT", F, "TOPLEFT", 0, 0)
    F.TrackedBuffs:AddAuraGroup("TrackedBuffs", "HELPFUL|PLAYER", {
      initializeFrame = function(Button) Lib.ConfigureAuraButton(Button, { Size = 38, CountSize = 16, ShowSwipe = Swipe, ShowCountdown = not Swipe }) end, -- C.ImportantAuras.Size
      sortMethod = AuraContainerSortMethod.Name,
      sortDirection = AuraContainerSortDirection.Reverse,
      candidateFilters = { includeSpellIDs = Config.PersonalBuffs2[Lib.PLAYER_CLASS] }
    })
  end
end)

-- Creation
oUF:SetActiveStyle("Player")
local Player = oUF:Spawn("player", "SpyroPlayer")
if Lib.IsForever then Player:Tag(Player.Name, Player.Name.Color.."[firstname]") end -- Show only first name in Forever
Player:SetPoint(unpack(Config.Anchor))

Lib.RegisterOnceEvent("PLAYER_ENTERING_WORLD", function()
  -- Buffs on the left of the minimap
  BuffFrame:SetScale(Config.BuffFrame.Scale)
  BuffFrame.AuraContainer.GetAuraWarningAlphaForDuration = nil
  Lib.EditModeAnchor(BuffFrame, unpack(Config.BuffFrame.Anchor))
  Lib.Hide(BuffFrame.CollapseAndExpandButton)

  -- Debuffs on the left of the minimap
  DebuffFrame:SetScale(Config.DebuffFrame.Scale)
  DebuffFrame.AuraContainer.GetAuraWarningAlphaForDuration = nil
  Lib.EditModeAnchor(DebuffFrame, unpack(Config.DebuffFrame.Anchor))
end)

--[[
-- Test
Player.TrustedTextureParent = CreateFrame("Frame", nil, Player, "DisableUntrustedLayoutScriptsTemplate")
Player.TargettingHelper = Lib.CreateTexture(Player.TrustedTextureParent, Addon.Media.."/PartyMarkers")
Player.TargettingHelper:SetIgnoreParentAlpha(true)
Player.TargettingHelper:SetSize(25, 70)
Player.TargettingHelper:SetTexCoord(0, 1, 182/284, 252/284)
Player.TargettingHelper:SetPoint("BOTTOMLEFT", Player.CCandDef, "BOTTOMRIGHT", -1, 1)
]]

--[[
EventRegistry:RegisterFrameEventAndCallback("UNIT_HEAL_PREDICTION", function(_, Unit)
  print(UnitGetIncomingHeals(Unit))
end)
]]