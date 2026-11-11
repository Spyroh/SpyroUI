--╔════════════════════════╗
--║ ┌─┐┌─┐┬ ┬┬─┐┌─┐  ┬ ┬┬  ║
--║ └─┐├─┘└┬┘├┬┘│ │  │ ││  ║
--║ └─┘┴   ┴ ┴└─└─┘  └─┘┴  ║
--╠════════════════════════╣
--║          Pet           ║
--╠════════════════════════╣
--║ By Spyro [Sanguino EU] ║
--╚════════════════════════╝

-- Local namespace vars
local _, Addon = ... -- Shared table between all files
local oUF, Config, Lib, Style = Addon.oUF, Addon.Config.Pet, Addon.Lib, Addon.Style

-- Styling function
function Style.PartyPet(F, C) -- Pet uses the same general style as PartyPets. This function will be also used on the PartyPets module
  Style.Base(F, C) -- Styling all the basic components
  Lib.CreatePartyAuras(F, C)
  F.Health.colorClass = true -- For vehicles

  -- Resurrect indicator
  F.ResurrectIndicator = F:CreateTexture(nil, "OVERLAY")
  F.ResurrectIndicator:SetSize(28, 28)
  F.ResurrectIndicator:SetPoint("CENTER", F.HealthBar)
end

-- Styling function
oUF:RegisterStyle("Pet", function(F, Unit)
  Style.PartyPet(F, Config)

  -- Happiness indicator
  F.Happiness = F:CreateTexture(nil, "OVERLAY")
  F.Happiness:SetSize(22, 22)
  F.Happiness:SetPoint("RIGHT", F, "LEFT", 0, 0)
end)

-- Creation
oUF:SetActiveStyle("Pet")
local Pet = oUF:Spawn("pet", "SpyroPet")
Pet:SetPoint(unpack(Config.Anchor))

--[[
-- Test
Pet.TrustedTextureParent = CreateFrame("Frame", nil, Pet, "DisableUntrustedLayoutScriptsTemplate")
Pet.TargettingHelper = Lib.CreateTexture(Pet.TrustedTextureParent, Addon.Media.."/PartyMarkers")
Pet.TargettingHelper:SetSize(17, 32)
Pet.TargettingHelper:SetTexCoord(0, 17/25, 252/284, 1)
Pet.TargettingHelper:SetIgnoreParentAlpha(true)
Pet.TargettingHelper:SetPoint("BOTTOMRIGHT", Pet.Important, "BOTTOMLEFT", 1, -15)
]]