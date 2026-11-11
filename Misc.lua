--╔════════════════════════╗
--║ ┌─┐┌─┐┬ ┬┬─┐┌─┐  ┬ ┬┬  ║
--║ └─┐├─┘└┬┘├┬┘│ │  │ ││  ║
--║ └─┘┴   ┴ ┴└─└─┘  └─┘┴  ║
--╠════════════════════════╣
--║          Misc          ║
--╠════════════════════════╣
--║ By Spyro [Sanguino EU] ║
--╚════════════════════════╝

--╔═════════════════════════════════════════════════════════════════════════════════════════════╗
--║ This module modifies Blizzard's UI frames that are not UnitFrames/Minimap, CVars and sounds ║
--╚═════════════════════════════════════════════════════════════════════════════════════════════╝

--[[ Upvalues ]]---------------------------------------------------------------------------------------------------------------------------------------
local _G, pairs, ipairs, C_CVar
    = _G, pairs, ipairs, C_CVar

--[[ Local namespace vars ]]---------------------------------------------------------------------------------------------------------------------------
local _, Addon = ... -- Shared table between all files
local Lib, Config = Addon.Lib, Addon.Config

--[[ Clickable frames to enable the CVars for forced secret restrictions ]]----------------------------------------------------------------------------
local SecretRestrictionsCVars = {
  "addonChatRestrictionsForced",
  "secretChallengeModeRestrictionsForced",
  "secretCombatRestrictionsForced",
  "secretEncounterRestrictionsForced",
  "secretMapRestrictionsForced",
  "secretPvPMatchRestrictionsForced"
}

EnableSecretRestrictions = CreateFrame("Button", nil, nil, "SecureActionButtonTemplate")
EnableSecretRestrictions:SetScript("OnClick", function()
  for _, CVarName in ipairs(SecretRestrictionsCVars) do C_CVar.SetCVar(CVarName, 1) end
  print("Secret restrictions CVars |cffFF0000enabled|r.")
end)

DisableSecretRestrictions = CreateFrame("Button", nil, nil, "SecureActionButtonTemplate")
DisableSecretRestrictions:SetScript("OnClick", function()
  for _, CVarName in ipairs(SecretRestrictionsCVars) do C_CVar.SetCVar(CVarName, 0) end
  print("Secret restrictions CVars |cff00FF00disabled|r.")
end)

ShowSecretRestrictions = CreateFrame("Button", nil, nil, "SecureActionButtonTemplate")
ShowSecretRestrictions:SetScript("OnClick", function()
  for _, CVarName in ipairs(SecretRestrictionsCVars) do
    print(CVarName..":", C_CVar.GetCVar(CVarName))
  end
end)

--[[ Default UI frames to make movable ]]--------------------------------------------------------------------------------------------------------------
local MovableFrames = {
  ["AchievementFrame"] = 1, ["AchievementFrameHeader"] = 1, ["AlliedRacesFrame"] = 1, ["ArchaeologyFrame"] = 1, ["ArtifactFrame"] = 1, ["ArtifactRelicForgeFrame"] = 1, ["AuctionHouseFrame"] = 1, ["AuctionFrame"] = 1, ["AzeriteEssenceUI"] = 1, ["AzeriteRespecFrame"] = 1, ["AzeriteEmpoweredItemUI"] = 1, ["AddonList"] = 1, ["AudioOptionsFrame"] = 1,
  ["BarberShopFrame"] = 1, ["BlackMarketFrame"] = 1, ["BFAMissionFrame"] = 1, ["BankFrame"] = 1, ["BattlefieldFrame"] = 1,
  ["CalendarFrame"] = 1, ["ChannelFrame"] = 1, ["CollectionsJournal"] = 1, ["CommunitiesFrame"] = 1, ["ChallengesKeystoneFrame"] = 1, ["CommunitiesGuildLogFrame"] = 1, ["CommunitiesGuildNewsFiltersFrame"] = 1, ["CommunitiesGuildTextEditFrame"] = 1, ["ContributionCollectionFrame"] = 1, ["CraftFrame"] = 1, ["ClassTrainerFrame"] = 1, ["CinematicFrame"] = 1, ["ChatConfigFrame"] = 1, ["CharacterFrame"] = 1,
  ["DeathRecapFrame"] = 1, ["DressUpFrame"] = 1, ["DestinyFrame"] = 1,
  ["EncounterJournal"] = 1,
  ["FlightMapFrame"] = 1, ["FriendsFrame"] = 1,
  ["GarrisonBuildingFrame"] = 1, ["GarrisonCapacitiveDisplayFrame"] = 1, ["GarrisonLandingPage"] = 1, ["GarrisonMissionFrame"] = 1, ["GarrisonMonumentFrame"] = 1, ["GarrisonRecruiterFrame"] = 1, ["GarrisonRecruitSelectFrame"] = 1, ["GarrisonShipyardFrame"] = 1, ["GuildFrame"] = 1, ["GMSurveyFrame"] = 1, ["GuildBankFrame"] = 1, ["GuildControlUI"] = 1, ["GuildInviteFrame"] = 1, ["GuildRegistrarFrame"] = 1, ["GossipFrame"] = 1, ["GameMenuFrame"] = 1,
  ["HelpFrame"] = 1,
  ["InspectFrame"] = 1, ["IslandsPartyPoseFrame"] = 1, ["IslandsQueueFrame"] = 1, ["ItemInteractionFrame"] = 1, ["ItemSocketingFrame"] = 1, ["ItemUpgradeFrame"] = 1, ["InterfaceOptionsFrame"] = 1, ["ItemTextFrame"] = 1,
  ["KeyBindingFrame"] = 1,
  ["LookingForGuildFrame"] = 1, ["LootFrame"] = 1,
  ["MacroFrame"] = 1, ["MailFrame"] = 1, ["MissingLootFrame"] = 1, ["MerchantFrame"] = 1,
  ["ObliterumForgeFrame"] = 1, ["OrderHallTalentFrame"] = 1, ["OrderHallMissionFrame"] = 1, ["OpenMailFrame"] = 1,
  ["PVPMatchResults"] = 1, ["PVPMatchScoreboard"] = 1, ["PlayerTalentFrame"] = 1, ["PVEFrame"] = 1, ["PetStableFrame"] = 1, ["PetitionFrame"] = 1, ["PlayerSpellsFrame"] = 1,
  ["QuestFrame"] = 1, ["QuestLogFrame"] = 1, ["QuestLogPopupDetailFrame"] = 1,
  ["ReforgingFrame"] = 1, ["RaidBrowserFrame"] = 1, ["RaidParentFrame"] = 1,
  ["ScrappingMachineFrame"] = 1, ["SettingsPanel"] = 1, ["SpellBookFrame" ] = 1, ["StaticPopup1"] = 1, ["StaticPopup2" ] = 1, ["StackSplitFrame"] = 1, ["ScrollOfResurrectionSelectionFrame"] = 1, ["SplashFrame"] = 1,
  ["TalentFrame"] = 1, ["TalkingHeadFrame"] = 1, ["TradeSkillFrame"] = 1, ["TransmogrifyFrame"] = 1, ["TabardFrame"] = 1, ["TutorialFrame"] = 1, ["TaxiFrame"] = 1, ["TradeFrame"] = 1,
  ["VoidStorageFrame"] = 1, ["VideoOptionsFrame"] = 1,
  ["WardrobeFrame"] = 1, ["WarboardQuestChoiceFrame"] = 1, ["WarfrontsPartyPoseFrame"] = 1, ["WorldStateScoreFrame"] = 1
}

--[[ Experience % viewer ]]----------------------------------------------------------------------------------------------------------------------------
if UnitLevel("player") < GetMaxPlayerLevel() then -- If the player is not max level
  -- Creating a string to show the % of experience in the current level
  local XP = UIParent:CreateFontString("SpyroUI_XPviewer", nil, "GameFontNormal")
  XP:SetFont(unpack(Config.XPviewer.Font))
  XP:SetPoint(unpack(Config.XPviewer.Anchor))
  XP:SetIgnoreParentScale(true)
  XP:SetDrawLayer("BACKGROUND")

  -- Method to update experience
  XP.Update = function()
    if UnitLevel("player") == GetMaxPlayerLevel() then -- Disabling if we have reached max level
      XP:Hide()
      Lib.UnregisterEvent("UPDATE_EXHAUSTION", XP.Update)
      Lib.UnregisterEvent("PLAYER_XP_UPDATE", XP.Update)
      Lib.UnregisterEvent("PLAYER_UPDATE_RESTING", XP.Update)
      Lib.UnregisterEvent("PLAYER_LEVEL_UP", XP.Update)
      return
    end

    XP:SetText(floor((UnitXP("player") / UnitXPMax("player")) * 100).."%") -- % of experience in the current level
    if IsResting() or GetXPExhaustion() then XP:SetTextColor(0, 1, 0) -- Green color if we have rested exp
    else XP:SetTextColor(1, 1, 1) end -- White color for no rested exp
  end

  -- Events
  Lib.RegisterOnceEvent("PLAYER_ENTERING_WORLD", XP.Update) -- Fires after a loading screen
  Lib.RegisterEvent("UPDATE_EXHAUSTION", XP.Update) -- Fires when the player's rest state or amount of rested XP changes
  Lib.RegisterEvent("PLAYER_XP_UPDATE", XP.Update) -- Fires when the player's amount of accrued experience points changes.
  Lib.RegisterEvent("PLAYER_UPDATE_RESTING", XP.Update) -- Fires when the player enters or leaves a major city, inn or other "resting" area
  Lib.RegisterEvent("PLAYER_LEVEL_UP", XP.Update) -- Fires when the player levels up
end

--[[ Latency viewer ]]---------------------------------------------------------------------------------------------------------------------------------
local Latency = UIParent:CreateFontString(nil, nil, "GameFontNormal")
Latency:SetJustifyH("LEFT")
Latency:SetJustifyV("TOP")
Latency:SetFont(unpack(Config.LatencyViewer.Font))
Latency:SetPoint(unpack(Config.LatencyViewer.Anchor))
Latency:SetTextColor(1, 1, 1)
Latency:SetParent(MicroMenu)
C_Timer.After(5, function() Latency:SetText(select(4, GetNetStats()).."ms") end)
C_Timer.NewTicker(30, function() Latency:SetText(select(4, GetNetStats()).."ms") end) -- Updating every 30 seconds

--[[ Frame rate viewer ]]------------------------------------------------------------------------------------------------------------------------------
if UIPARENT_MANAGED_FRAME_POSITIONS then UIPARENT_MANAGED_FRAME_POSITIONS["FramerateLabel"] = nil end
local FPS_Label = FramerateLabel or FramerateFrame.Label
local FPS_Number = FramerateText or FramerateFrame.FramerateText
local SetFormattedText = PlayerFrame.name.SetFormattedText -- To avoid triggering the hook

FPS_Label:ClearAllPoints()
FPS_Label:SetFont(unpack(Config.FrameRateViewer.Font))
FPS_Label:SetPoint("CENTER", UIParent, "CENTER", 16, -100)
FPS_Label:SetText(" FPS")

FPS_Number:ClearAllPoints()
FPS_Number:SetFont(unpack(Config.FrameRateViewer.Font))
FPS_Number:SetPoint("RIGHT", FPS_Label, "LEFT", 0, 0)

hooksecurefunc(FPS_Number, "SetFormattedText", function(self, _, Var)
  SetFormattedText(self, "%d", Var) -- Removing decimals
end)

-------------------------------------------------------------------------------------------------------------------------------------------------------
Lib.RegisterOnceEvent("PLAYER_ENTERING_WORLD", function()
  MacroFrame:SetScale(1.5) -- Increasing macro window scale
  UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE") -- Disabling red error messages

  -- Muting certain sounds
  for _, SoundID in ipairs(Config.MuteSounds) do
    MuteSoundFile(SoundID)
  end

  -- CVars
  for CVar, Value in pairs(Config.CVars) do
    C_CVar.SetCVar(CVar, Value)
  end

  -- Vehicle seats
  Lib.EditModeAnchor(VehicleSeatIndicator, "BOTTOMLEFT", SpyroCooldownBar, "BOTTOMRIGHT", 0, 0)

  -- Queue status
  Lib.EditModeAnchor(QueueStatusButton, "BOTTOMRIGHT", SpyroCooldownBar, "TOPRIGHT", -16, -2)

  -- Durability alert
  Lib.EditModeAnchor(DurabilityFrame, "BOTTOMLEFT", SpyroCooldownBar, "TOPLEFT", 0, 0)

  -- Quest tracker
  --[[
  Lib.EditModeAnchor(ObjectiveTrackerFrame, "TOPRIGHT", MinimapCluster, "BOTTOMRIGHT", -1, -10)
  Lib.EditModeFrameSetting(ObjectiveTrackerFrame, Enum.EditModeObjectiveTrackerSetting.Height, Config.QuestTracker.Height)
  Lib.RunAfterEditMode(function() ObjectiveTrackerFrame:SetSize(Config.QuestTracker.Height, Config.QuestTracker.Width) end, true)
  ]]

  -- MicroMenu
  if MicroMenu.BorderArt then MicroMenu.BorderArt:Hide() end
  if MicroMenu.BackgroundArt then MicroMenu.BackgroundArt:Hide() end
  MicroMenuContainer:SetScale(Config.MicroMenu.Scale)
  MicroMenuContainer:SetClampedToScreen(false)
  MicroMenuContainer:SetSize(MicroMenu:GetSize())
  Lib.ShowOnMouseOver(MicroMenu)
  Lib.EditModeAnchor(MicroMenuContainer, unpack(Config.MicroMenu.Anchor))

  -- Bags
  Lib.EditModeFrameSetting(BagsBar, Enum.EditModeBagsSetting.Direction, Enum.BagsDirection.Right)
  if BagsBar.BorderArt then BagsBar.BorderArt:Hide() end
  if BagBarExpandToggle then BagBarExpandToggle:Hide() end --Lib.Hide(BagBarExpandToggle)
  BagsBar:SetScale(Config.Bags.Scale)
  BagsBar:SetClampedToScreen(false)
  Lib.ShowOnMouseOver(BagsBar)
  Lib.EditModeAnchor(BagsBar, unpack(Config.Bags.Anchor))

  if Lib.IsRetail then
    Lib.RunAfterEditMode(function()
      local TotalBags, PrevBag = 0

      for z, Bag in ipairs({ BagsBar:GetChildren() }) do
        if z ~= 1 and z ~= 3 then
          Bag:SetScale(1)
          Bag:SetSize(CharacterMicroButton:GetHeight(), CharacterMicroButton:GetHeight())
          Bag:ClearAllPoints()

          if PrevBag then Bag:SetPoint("TOPLEFT", PrevBag, "TOPRIGHT", 0, 0)
          else Bag:SetPoint("TOPLEFT", BagsBar, "TOPLEFT", 0, 0) end

          PrevBag = Bag
          TotalBags = TotalBags + 1
        end
      end

      BagsBar:SetSize(CharacterMicroButton:GetHeight() * TotalBags, CharacterMicroButton:GetHeight())
    end, true)
  end

  -- Disabling mouse on the ToastFrame
  hooksecurefunc(EventToastManagerFrame, "DisplayToast", function()
    EventToastManagerFrame:SetMouseClickEnabled(false)

    local Toast = EventToastManagerFrame:IsCurrentlyToasting()
    if not Toast then return end

    if Toast.TitleTextMouseOverFrame then Toast.TitleTextMouseOverFrame:SetMouseClickEnabled(false) end
    if Toast.SubTitleMouseOverFrame then Toast.SubTitleMouseOverFrame:SetMouseClickEnabled(false) end

    local EnableClick = Toast.toastInfo and Toast.toastInfo.displayType == Enum.EventToastDisplayType.ScenarioClickExpand or false
    Toast:SetMouseClickEnabled(EnableClick)
  end)

  -- LossOfControlFrame modifications
  hooksecurefunc(LossOfControlFrame, "SetUpDisplay", function(self)
    self:ClearAllPoints()
    self:SetPoint("CENTER", 0, -150)
    self.blackBg:Hide()
    self.RedLineTop:Hide()
    self.RedLineBottom:Hide()
    self.Icon:ClearAllPoints()
    self.Icon:SetPoint("CENTER", self, "CENTER", 0, 0)
    self.AbilityName:ClearAllPoints()
    self.AbilityName:SetPoint("TOP", self.Icon, "BOTTOM", 0, 0)
    self.AbilityName.scrollTime = nil
    self.TimeLeft.NumberText:ClearAllPoints()
    self.TimeLeft.NumberText:SetPoint("CENTER", self.Icon, "CENTER", 0, 0)
    self.TimeLeft.NumberText.scrollTime = nil
    self.TimeLeft.NumberText:SetShown(not C_AddOns.IsAddOnLoaded("OmniCC"))
    self.TimeLeft.SecondsText:ClearAllPoints()
    self.TimeLeft.SecondsText:SetPoint("BOTTOM", self, 0, -80)
    self.TimeLeft.SecondsText:Hide()
    self.TimeLeft.SecondsText.scrollTime = nil
    if self.Anim:IsPlaying() then self.Anim:Stop() end
  end)

  -- Making default UI frames movable
  for FrameName in pairs(MovableFrames) do -- The ones that already exist
    if _G[FrameName] then Lib.MakeMovable(_G[FrameName]) end
  end

  hooksecurefunc("CreateFrame", function(_, Name) -- The ones that will be created later
    if Name and MovableFrames[Name] and _G[Name] then Lib.MakeMovable(_G[Name]) end
  end)
end)

--[[ Entering/leaving combat alert ]]------------------------------------------------------------------------------------------------------------------
local CombatStatusAlert = UIParent:CreateFontString()
CombatStatusAlert:SetFont("Fonts/FRIZQT__.TTF", 28, "OUTLINE")
CombatStatusAlert:SetPoint("CENTER", UIParent, "CENTER", 0, 169)
CombatStatusAlert:Hide()
CombatStatusAlert.Anim = CombatStatusAlert:CreateAnimationGroup()
CombatStatusAlert.Move = CombatStatusAlert.Anim:CreateAnimation("Translation")
CombatStatusAlert.Move:SetOffset(0, 50)
CombatStatusAlert.Move:SetDuration(1.3)
CombatStatusAlert.Move:SetSmoothing("NONE")
CombatStatusAlert.Anim:SetScript("OnFinished", function() CombatStatusAlert:Hide() end)
Lib.SetShadow(CombatStatusAlert, true)

Lib.RegisterEvent("PLAYER_REGEN_DISABLED", function()
  CombatStatusAlert:SetText("+Combat")
  CombatStatusAlert:SetTextColor(1, 0, 0)
  CombatStatusAlert.Anim:Stop()
  CombatStatusAlert:Show()
  CombatStatusAlert.Anim:Play()
end)

Lib.RegisterEvent("PLAYER_REGEN_ENABLED", function()
  CombatStatusAlert:SetText("-Combat")
  CombatStatusAlert:SetTextColor(0, 1, 0)
  CombatStatusAlert.Anim:Stop()
  CombatStatusAlert:Show()
  CombatStatusAlert.Anim:Play()
end)

--[[ Alerts for taints and blocked/forbidden actions ]]------------------------------------------------------------------------------------------------
-- Event ADDON_ACTION_BLOCKED
-- Fires when a protected function is being called from tainted code.
Lib.RegisterEvent("ADDON_ACTION_BLOCKED", function(AddonName, Function)
  print("ADDON_ACTION_BLOCKED:", AddonName, "::", Function)
end)

-- Event ADDON_ACTION_FORBIDDEN
-- Fires when an AddOn tries use actions that are always forbidden (movement, targeting, etc).
Lib.RegisterEvent("ADDON_ACTION_FORBIDDEN", function(AddonName, Function)
  print("ADDON_ACTION_FORBIDDEN:", AddonName, "::", Function)
end)

-- Event MACRO_ACTION_BLOCKED
-- Same for macros.
Lib.RegisterEvent("MACRO_ACTION_BLOCKED", function(Function)
  print("MACRO_ACTION_BLOCKED:", Function)
end)

-- Event MACRO_ACTION_FORBIDDEN
-- Same for macros.
Lib.RegisterEvent("MACRO_ACTION_FORBIDDEN", function(Function)
  print("MACRO_ACTION_FORBIDDEN:", Function)
end)