--╔════════════════════════╗
--║ ┌─┐┌─┐┬ ┬┬─┐┌─┐  ┬ ┬┬  ║
--║ └─┐├─┘└┬┘├┬┘│ │  │ ││  ║
--║ └─┘┴   ┴ ┴└─└─┘  └─┘┴  ║
--╠════════════════════════╣
--║       PartyPets        ║
--╠════════════════════════╣
--║ By Spyro [Sanguino EU] ║
--╚════════════════════════╝

-- Local namespace vars
local _, Addon = ... -- Shared table between all files
local oUF, Config, Lib, Style = Addon.oUF, Addon.Config.PartyPet, Addon.Lib, Addon.Style

-- Styling function
oUF:RegisterStyle("PartyPet", function(F)
  Style.PartyPet(F, Config)
end)

-- Creation and positioning
oUF:SetActiveStyle("PartyPet")
for i = 1, 4 do
  local Frame = oUF:Spawn("partypet"..i, "SpyroPartyPet"..i)
  Frame:SetPoint("TOPRIGHT", _G["SpyroParty"..i], "TOPLEFT", -1, 0)
end

-- Targetting helper for partypet1
SpyroPartyPet1.TrustedTextureParent = CreateFrame("Frame", nil, SpyroPartyPet1, "DisableUntrustedLayoutScriptsTemplate")
SpyroPartyPet1.TargettingHelper = Lib.CreateTexture(SpyroPartyPet1.TrustedTextureParent, Addon.Media.."/PartyMarkers")
SpyroPartyPet1.TargettingHelper:SetSize(17, 32)
SpyroPartyPet1.TargettingHelper:SetTexCoord(0, 17/25, 252/284, 1)
SpyroPartyPet1.TargettingHelper:SetIgnoreParentAlpha(true)
SpyroPartyPet1.TargettingHelper:SetPoint("BOTTOMRIGHT", SpyroPartyPet1.Important, "BOTTOMLEFT", 1, -15)

-- Show only when the player is a healer in a party of 2
function SpyroPartyPet1.TargettingHelper.UpdateVisiblity()
  SpyroPartyPet1.TargettingHelper:SetShown(Lib.CanPlayerHeal() and not UnitIsVisible("party2")) --not SpyroParty2:IsShown()
end

Lib.RegisterOnceEvent("PLAYER_ENTERING_WORLD", SpyroPartyPet1.TargettingHelper.UpdateVisiblity)
Lib.RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED ACTIVE_TALENT_GROUP_CHANGED GROUP_ROSTER_UPDATE", SpyroPartyPet1.TargettingHelper.UpdateVisiblity)

-- Invisible buttons that target the 1st/2nd/3rd existent pets when clicked. To be called from macros via /click
for TargetPet, FrameName in ipairs({ "TargetFirstPet", "TargetSecondPet", "TargetThirdPet" }) do
  local B = CreateFrame("Button", FrameName, nil, "SecureActionButtonTemplate")
  B:SetAttribute("type", "target")
  B:SetAttribute("useOnKeyDown", false)
  B:RegisterForClicks("AnyUp", "AnyDown")

  Lib.Execute(B, [[ Pet = newtable("partypet1", "partypet2", "partypet3", "partypet4", "pet") ]])
  Lib.WrapScript(B, "PreClick", B, [[
    local PetsSeen = 0
    self:SetAttribute("unit", nil)

    for i = 1, 5 do
      if UnitExists(Pet[i]) then
        PetsSeen = PetsSeen + 1
        if PetsSeen == %d then
          self:SetAttribute("unit", Pet[i])
          break
        end
      end
    end
  ]], TargetPet)
end