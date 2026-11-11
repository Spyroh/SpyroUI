--╔════════════════════════╗
--║ ┌─┐┌─┐┬ ┬┬─┐┌─┐  ┬ ┬┬  ║
--║ └─┐├─┘└┬┘├┬┘│ │  │ ││  ║
--║ └─┘┴   ┴ ┴└─└─┘  └─┘┴  ║
--╠════════════════════════╣
--║     Party members      ║
--╠════════════════════════╣
--║ By Spyro [Sanguino EU] ║
--╚════════════════════════╝

-- Local namespace vars
local _, Addon = ... -- Shared table between all files
local oUF, Config, Lib, Style = Addon.oUF, Addon.Config.Party, Addon.Lib, Addon.Style

-- Styling function
oUF:RegisterStyle("Party", function(F, Unit)
  Style.Party(F, Config)

  -- Phased icon
  F.PhaseIndicator = F:CreateTexture(nil, "OVERLAY")
  F.PhaseIndicator:SetPoint("LEFT", F, "RIGHT", 2, 0)

  -- Targetting helper texture
  F.TrustedTextureParent = CreateFrame("Frame", nil, F, "DisableUntrustedLayoutScriptsTemplate")
  F.TargettingHelper = Lib.CreateTexture(F.TrustedTextureParent, Addon.Media.."/PartyMarkers")
  F.TargettingHelper:SetIgnoreParentAlpha(true)
  F.TargettingHelper:SetSize(25, tonumber(Unit:match("%d")) <= 2 and 56 or 70)

  -- Show only when the player is a healer
  function F.TargettingHelper:UpdateVisiblity() F.TargettingHelper:SetShown(Lib.IsPlayerHealer()) end
  F.TargettingHelper:UpdateVisiblity()
  Lib.RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED", F.TargettingHelper.UpdateVisiblity)
  Lib.RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", F.TargettingHelper.UpdateVisiblity)
  Lib.RegisterOnceEvent("PLAYER_ENTERING_WORLD", F.TargettingHelper.UpdateVisiblity)

  -- Test events to try to fix the name problem
  --[[
  Lib.RegisterUnitEvent("UNIT_NAME_UPDATE", F.__unit, function()
    RunNextFrame(function() F.Name:UpdateTag() end)
  end)
  ]]

  Lib.RegisterEvent("GROUP_ROSTER_UPDATE", function()
    F.Name:UpdateTag()

    local inRange
    local isEligible = UnitIsConnected(F.__unit) and UnitInParty(F.__unit)

    if isEligible then
      inRange = UnitInRange(F.__unit)
      F:SetAlphaFromBoolean(inRange, F.Range.insideAlpha, F.Range.outsideAlpha)
    else
      F:SetAlpha(F.Range.insideAlpha)
    end
  end)
end)

-- Creation and positioning
oUF:SetActiveStyle("Party")
for i = 1, 4 do oUF:Spawn("party"..i, "SpyroParty"..i) end
Lib.UnitFrames_SetGrowthDirection(Config.GrowthDirection, Config.Anchor, SpyroParty1, SpyroParty2, SpyroParty3, SpyroParty4)

-- Targetting helpers
SpyroParty1.TargettingHelper:SetTexCoord(0, 1, 0, 56/284)
SpyroParty1.TargettingHelper:SetPoint("BOTTOMLEFT", SpyroParty1.CCandDef, "BOTTOMRIGHT", -1, 8)
SpyroParty2.TargettingHelper:SetTexCoord(0, 1, 56/284, 112/284)
SpyroParty2.TargettingHelper:SetPoint("BOTTOMLEFT", SpyroParty2.CCandDef, "BOTTOMRIGHT", -1, 8)
SpyroParty3.TargettingHelper:SetTexCoord(0, 1, 112/284, 182/284)
SpyroParty3.TargettingHelper:SetPoint("BOTTOMLEFT", SpyroParty3.CCandDef, "BOTTOMRIGHT", -1, 1)
SpyroParty4.TargettingHelper:SetTexCoord(0, 1, 182/284, 252/284)
SpyroParty4.TargettingHelper:SetPoint("BOTTOMLEFT", SpyroParty4.CCandDef, "BOTTOMRIGHT", -1, 1)

-- Temp frame to print data to diagnose party units problems
oUF_PrintPartyData = CreateFrame("Button", "oUF_PrintPartyData")
oUF_PrintPartyData:SetScript("OnClick", function()
  print("\n")

  for i = 1, 4 do
    Lib.Print(
      "party%d :: Name: %s | oUF.Name: %s | UnitExists: %s | IsShown: %s",
      i,
      NameUtil.GetUnmodifiedUnitFullName("party"..i) or "nil",
      _G["SpyroParty"..i].Name:GetText() or "nil",
      tostring(UnitExists("party"..i)),
      tostring(_G["SpyroParty"..i]:IsShown())
    )
  end

  print("\n")
end)