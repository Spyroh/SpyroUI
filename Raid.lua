--╔════════════════════════╗
--║ ┌─┐┌─┐┬ ┬┬─┐┌─┐  ┬ ┬┬  ║
--║ └─┐├─┘└┬┘├┬┘│ │  │ ││  ║
--║ └─┘┴   ┴ ┴└─└─┘  └─┘┴  ║
--╠════════════════════════╣
--║      Raid Frames       ║
--╠════════════════════════╣
--║ By Spyro [Sanguino EU] ║
--╚════════════════════════╝

--╔══════════════════════════════════════════════════════════════════╗
--║ This module modifies Blizzard's CompactUnitFrames for raid units ║
--╚══════════════════════════════════════════════════════════════════╝

--[[ Local namespace vars ]]---------------------------------------------------------------------------------------------------------------------------
local _, Addon = ... -- Shared table between all files
local Lib, Config = Addon.Lib, Addon.Config
local SetStatusBarTexture = CreateFrame("StatusBar").SetStatusBarTexture

--[[ Hooks ]]------------------------------------------------------------------------------------------------------------------------------------------
local function SkinCompactUnitFrame(U)
  if U.SpyroUI or not U.unit or U.unit:find("nameplate") or U.unit:find("arena") then return end -- or U.unit:find("party")
  U.SpyroUI = true -- Mark as processed

  -- Disabling parent alpha on the background and borders to create a dim effect when out of range like the pre-Midnight frames
  U.background:SetIgnoreParentAlpha(true)
  U.powerBar.background:SetIgnoreParentAlpha(true)

  -- Health bar
  U.healthBar:SetStatusBarTexture(Addon.Media.."/MinimalistBar")
  hooksecurefunc(U.healthBar, "SetStatusBarTexture", function(S) SetStatusBarTexture(S, Addon.Media.."/MinimalistBar") end)

  -- Mana bar
  U.powerBar:SetFrameStrata(U.healthBar:GetFrameStrata())
  U.powerBar:SetFrameLevel(U.healthBar:GetFrameLevel())
  U.powerBar:SetStatusBarTexture(Addon.Media.."/MinimalistBar")
  U.powerBar.TopBorder = Lib.CreateLine(U.powerBar)--, nil, nil, 1.5)
  U.powerBar.TopBorder:SetStartPoint("TOPLEFT")
  U.powerBar.TopBorder:SetEndPoint("TOPRIGHT")
  hooksecurefunc(U.powerBar, "SetStatusBarTexture", function(S) SetStatusBarTexture(S, Addon.Media.."/MinimalistBar") end)
end

-- Players
CompactRaidFrameContainer:ApplyToFrames("normal", SkinCompactUnitFrame)
hooksecurefunc("DefaultCompactUnitFrameSetup", SkinCompactUnitFrame)

-- Pets
CompactRaidFrameContainer:ApplyToFrames("mini", SkinCompactUnitFrame)
hooksecurefunc("DefaultCompactMiniFrameSetup", SkinCompactUnitFrame)
