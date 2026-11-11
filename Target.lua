--╔══════════════════════════╗
--║  ┌─┐┌─┐┬ ┬┬─┐┌─┐  ┬ ┬┬   ║
--║  └─┐├─┘└┬┘├┬┘│ │  │ ││   ║
--║  └─┘┴   ┴ ┴└─└─┘  └─┘┴   ║
--╠══════════════════════════╣
--║ Target & Target's Target ║
--╠══════════════════════════╣
--║  By Spyro [Sanguino EU]  ║
--╚══════════════════════════╝

--[[ Local namespace vars ]]---------------------------------------------------------------------------------------------------------------------------
local _, Addon = ... -- Shared table between all files
local oUF, Lib, Config, Style = Addon.oUF, Addon.Lib, Addon.Config, Addon.Style

--[[ Target ]]-----------------------------------------------------------------------------------------------------------------------------------------
-- Styling function
function Style.Target(F, C) -- This will be used on the Focus's module too
  -- Styling all the basic components
  Style.Base(F, C)
  F.Width = F:GetWidth() -- Will be used for aura positioning

  -- Threat status must be requested against the player
  F.ThreatIndicator.feedbackUnit = "player"

  -- Tagged mob indicator
  F.TapIndicator = F.TextParent:CreateLine(nil, "OVERLAY", nil, -1)
  F.TapIndicator:SetColorTexture(0.5, 0.5, 0.5, 1)
  F.TapIndicator:SetThickness(2)
  F.TapIndicator:SetStartPoint("TOP"..F.oSide, F.Portrait)
  F.TapIndicator:SetEndPoint("BOTTOM"..F.iSide, F.Portrait)
  F.TapIndicator:Hide()
  F.TapIndicatorUpdate = function() F.TapIndicator:SetShown(not UnitIsDead(F.__unit) and UnitIsTapDenied(F.__unit)) end
  Lib.RegisterEvent("PLAYER_"..strupper(F.__unit).."_CHANGED", F.TapIndicatorUpdate)
  Lib.RegisterUnitEvent("UNIT_FACTION", F.__unit, F.TapIndicatorUpdate)

  -- Mob type indicator
  for _, Ind in ipairs({ "MobTypeIndicator", "MobTypeIndicatorPvP" }) do
    F[Ind] = F:CreateFontString(nil, "OVERLAY")
    F[Ind]:SetFont(Addon.Folder.."/Media/Prototype.ttf", 12, "OUTLINE")
    F[Ind]:SetTextColor(1, 0.82, 0)
    F:Tag(F[Ind], "[spyro:classification]")
  end
  F.MobTypeIndicatorPvP:SetJustifyH(F.iSide)
  F.MobTypeIndicatorPvP:SetPoint("TOP"..F.iSide, F.Portrait, F.oSideLeft and 3 or -2, 1)
  F.MobTypeIndicator:SetJustifyH(F.oSide)
  F.MobTypeIndicator:SetPoint("TOP"..F.oSide, F.Portrait, F.oSideLeft and -2 or 3, 1)

  -- PvP icon
  F.PvPIndicator = F.TextParent:CreateTexture(nil, "OVERLAY")
  F.PvPIndicator:SetScale(Lib.IsRetail and 0.5 or 1)
  F.PvPIndicator:SetPoint("TOP", F, "TOP"..F.oSide, F.oSideLeft and 1 or -1, 1)
  function F.PvPIndicator:PostUpdate()
    F.MobTypeIndicator:SetAlphaFromBoolean(self:IsShown(), 0, 1)
    F.MobTypeIndicatorPvP:SetAlphaFromBoolean(self:IsShown(), 1, 0) -- Show when the PvP icon is visible coz it covers the normal MobTypeIndicator
  end

  -- Pet battle icon
  F.PetBattleIcon = F.TextParent:CreateTexture(nil, "OVERLAY")
  F.PetBattleIcon:SetSize(32, 32)
  F.PetBattleIcon:SetPoint("CENTER", F.Portrait, "TOP"..F.oSide, 0, -14)
  Lib.RegisterEvent("PLAYER_"..strupper(F.__unit).."_CHANGED", function()
    if UnitIsWildBattlePet(F.__unit) or UnitIsBattlePetCompanion(F.__unit) then
      F.PetBattleIcon:SetTexture("Interface/TargetingFrame/PetBadge-"..PET_TYPE_SUFFIX[UnitBattlePetType(F.__unit)])
      F.PetBattleIcon:Show()
    else
      F.PetBattleIcon:Hide()
    end
  end)

  -- Leader/guide icon
  F.LeaderIndicator = F:CreateTexture(nil, "OVERLAY")
  F.LeaderIndicator:SetSize(16, 16)
  F.LeaderIndicator:SetPoint("CENTER", F.Portrait, "TOP", 0, 2)

  -- Assistant icon
  F.AssistantIndicator = F:CreateTexture(nil, "OVERLAY")
  F.AssistantIndicator:SetSize(16, 16)
  F.AssistantIndicator:SetPoint("CENTER", F.Portrait, "TOP", 0, 2)

  -- Master looter icon
  F.MasterLooterIndicator = F:CreateTexture(nil, "OVERLAY")
  F.MasterLooterIndicator:SetSize(16, 16)
  F.MasterLooterIndicator:SetPoint("TOP", F, "TOP"..F.oSide, 0, 0)

  -- Quest icon
  F.QuestIndicator = F:CreateTexture(nil, "OVERLAY")
  F.QuestIndicator:SetSize(20, 20)
  F.QuestIndicator:SetPoint("TOP", F, "TOP"..F.oSide, 0, 0)

  -- Target marker
  F.RaidTargetIndicator = F:CreateTexture(nil, "OVERLAY")
  F.RaidTargetIndicator:SetSize(26, 26)
  F.RaidTargetIndicator:SetPoint("CENTER", F.Portrait, "TOP", 0, 1)

  -- Aura containers
  local Layout = {
    elementSpacing   = C.Auras.xPadding,
    lineSpacing      = C.Auras.yPadding,
    groupLineSpacing = C.Auras.yPadding
  }

  -- Creating 1 container for buffs and 1 for debuffs
  for Type, Filter in pairs({ Buffs = "HELPFUL", Debuffs = "HARMFUL" }) do
    F[Type] = Lib.CreateAuraContainer(F.__unit, F)
    F[Type]:SetFlowLayoutAnchorPoint("TOPLEFT")
    F[Type]:SetFlowLayoutGrowthDirection(AnchorUtil.FlowDirection.Right, AnchorUtil.FlowDirection.Down)
    local BorderType = Filter == "HARMFUL" and Lib.Enum.Aura.DebuffTypeBorder or Lib.Enum.Aura.StealableBorder
    local Sort = Filter == "HARMFUL" and AuraContainerSortMethod.UnitFrameDebuff or AuraContainerSortMethod.Name,

    -- Player auras first, with bigger icons
    F[Type]:AddAuraGroup("Player"..Type, Filter.."|PLAYER", {
      initializeFrame = function(Button) Lib.ConfigureAuraButton(Button, { Size = C.Auras.PlayerSize, Border = BorderType }) end,
      sortMethod = Sort,
      layout = Layout
    })

    -- Rest of auras
    F[Type]:AddAuraGroup(Type, Filter.."|!PLAYER", {
      initializeFrame = function(Button) Lib.ConfigureAuraButton(Button, { Size = C.Auras.NormalSize, Border = BorderType }) end,
      sortMethod = Sort,
      layout = Layout
    })
  end

  -- Function to update auras and castbar position
  F.UpdateAurasAndCastbar = function()
    local HasToT = UnitExists(F.ToT.__unit)
    local MaxAuraRowWidth = HasToT and F.MaxAuraRowWidthWhenToT or F.Width
    local AuraOffset = HasToT and F.AuraOffsetWhenToT or 0

    F.Buffs:SetFlowLayoutMaximumLineSize(MaxAuraRowWidth)
    F.Debuffs:SetFlowLayoutMaximumLineSize(MaxAuraRowWidth)

    F.Buffs:ClearAllPoints()
    F.Debuffs:ClearAllPoints()
    F.Castbar:ClearAllPoints()

    if UnitCanAttack("player", F.__unit) then -- Debuffs first on enemies
      F.Debuffs:SetPoint("TOPLEFT", F, "BOTTOMLEFT", AuraOffset, -2)
      F.Buffs:SetPoint("TOPLEFT", F.Debuffs, "BOTTOMLEFT", 0, -3) -- -C.Auras.yPadding
      F.Castbar:SetPoint("TOPLEFT", F.Buffs, "BOTTOMLEFT", HasToT and F.CastbarOffsetWhenToT or F.CastbarOffset, -1)
    else -- Buffs first on friendlies
      F.Buffs:SetPoint("TOPLEFT", F, "BOTTOMLEFT", AuraOffset, -1)
      F.Debuffs:SetPoint("TOPLEFT", F.Buffs, "BOTTOMLEFT", 0, -3) -- -C.Auras.yPadding
      F.Castbar:SetPoint("TOPLEFT", F.Debuffs, "BOTTOMLEFT", HasToT and F.CastbarOffsetWhenToT or F.CastbarOffset, -2)
    end

    F.Buffs:UpdateAllAuras()
    F.Debuffs:UpdateAllAuras()
  end

  -- Tracker of CC/defensives on top of the portrait
  local AuraOptions = {
    maxFrameCount = 1,
    sortMethod = AuraContainerSortMethod.ExpirationOnly, -- Longest one first
    initializeFrame = function(Button)
      Lib.ConfigureAuraButton(Button, { Size = F.Portrait:GetHeight(), ShowSwipe = false, ShowCountdown = true })
      Button.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93) -- Making icon square
    end
  }

  F.PortraitAurasClippingParent = CreateFrame("Frame", nil, F, "DisableUntrustedLayoutScriptsTemplate") -- Parent to hide excess auras
  F.PortraitAurasClippingParent:SetClipsChildren(true)
  F.PortraitAurasClippingParent:SetAllPoints(F.Portrait)
  F.PortraitAuras = Lib.CreateAuraContainer(F.__unit, F.PortraitAurasClippingParent)
  F.PortraitAuras:SetAllPoints(F.Portrait)
  F.PortraitAuras:AddAuraGroup("CC", "HARMFUL|CROWD_CONTROL", AuraOptions)
  F.PortraitAuras:AddAuraGroup("BigDef", "HELPFUL|BIG_DEFENSIVE|!EXTERNAL_DEFENSIVE", AuraOptions)
  F.PortraitAuras:AddAuraGroup("ExternalDef", "HELPFUL|EXTERNAL_DEFENSIVE", AuraOptions)

  -- AuraContainer anchored to the frame's portrait side to show DoTs similar to the ones shown on nameplates
  F.PersonalAuras = Lib.CreateAuraContainer(F.__unit, F, "TOP"..F.iSide, F, "TOP"..F.oSide, 0, 0)
  F.PersonalAuras:AddAuraGroup("PersonalAuras", "HARMFUL|PLAYER|!CROWD_CONTROL", {
    initializeFrame = function(Button) Lib.ConfigureAuraButton(Button, { Size = 30, ShowSwipe = false, ShowCountdown = true, ShowPandemic = true }) end,
    sortDirection = F.oSideLeft and AuraContainerSortDirection.Reverse or Normal, -- Same order independent of grow direction
    sortMethod = AuraContainerSortMethod.Name,
    candidateFilters = { nameplateShowPersonal = true },
  })

  --[[
  -- AuraContainer anchored to the frame's portrait side to show the auras from Config.TargetPersonalDebuffs
  F.PersonalAuras = Lib.CreateAuraContainer(F.__unit, F, "TOP"..F.iSide, F, "TOP"..F.oSide, 0, 0)
  F.PersonalAuras:AddAuraGroup("PersonalAuras", "HARMFUL|PLAYER", {
    initializeFrame = function(Button) Lib.ConfigureAuraButton(Button, { Size = 30, ShowSwipe = false, ShowCountdown = true, ShowPandemic = true }) end,
    sortDirection = F.oSideLeft and AuraContainerSortDirection.Reverse or Normal, -- Same order independent of grow direction
    sortMethod = AuraContainerSortMethod.Name,
    candidateFilters = { includeSpellIDs = Config.TargetPersonalDebuffs } -- Show only the debuffs on this table
  })
  ]]

  local UpdateAuraContainers = function()
    F.UpdateAurasAndCastbar()
    F.PortraitAuras:UpdateAllAuras()
    F.PersonalAuras:UpdateAllAuras()
  end

  -- Events to update auras
  Lib.RegisterUnitEvent("UNIT_TARGET", F.__unit, function() RunNextFrame(UpdateAuraContainers) end) -- Remove this
  Lib.RegisterUnitEvent("UNIT_FACTION", F.__unit, function() RunNextFrame(UpdateAuraContainers) end)
  Lib.RegisterEvent("PLAYER_"..strupper(F.__unit).."_CHANGED", function() RunNextFrame(UpdateAuraContainers) end)
end

-- Registering style
oUF:RegisterStyle("Target", function(T)
  Style.Target(T, Config.Target)

  -- Different vertical offsets for the anchor, depending on party size
  if Config.Target.PartyOffset then
    local Offset = Config.Target.PartyOffset
    T.PositionDriver = CreateFrame("Frame", nil, nil, "SecureHandlerAttributeTemplate")
    Lib.SetFrameRef(T.PositionDriver, "Target", T)
    Lib.SaveAnchor(T.PositionDriver, "Anchor", Config.Target.Anchor)

    -- Positioning
    T.PositionDriver:SetAttribute("_onattributechanged", [[
      local Point, RelativeTo, RelativePoint, OffsetX = unpack(Anchor)
      Target:SetPoint(Point, RelativeTo, RelativePoint, OffsetX, value) -- value is the vertical offset
    ]])

    -- Trigger when the party size changes to generate the vertical offset
    RegisterAttributeDriver(T.PositionDriver, "OffsetY", 
      "[nogroup][group:raid]"..Offset[1].. -- Solo or Raids
      ";[@party4,exists]"    ..Offset[5].. -- Party of 5 players
      ";[@party3,exists]"    ..Offset[4].. -- Party of 4 players
      ";[@party2,exists]"    ..Offset[3].. -- Party of 3 players
      ";[@party1,exists]"    ..Offset[2]   -- Party of 2 players
    )
  end
end)

-- Creation
oUF:SetActiveStyle("Target")
local Target = oUF:Spawn("target", "SpyroTarget")
if not Config.Target.PartyOffset then Target:SetPoint(unpack(Config.Target.Anchor)) end

-- Target change sound
local HadTarget
Lib.RegisterEvent("PLAYER_TARGET_CHANGED", function()
  if not UnitExists("target") then
    if HadTarget then PlaySound(SOUNDKIT.INTERFACE_SOUND_LOST_TARGET_UNIT) end
    HadTarget = false
    return
  end

  HadTarget = true
  if C_PlayerInteractionManager.IsReplacingUnit() then return end

  if UnitIsEnemy("target", "player") then PlaySound(SOUNDKIT.IG_CREATURE_AGGRO_SELECT)
  elseif UnitIsFriend("player", "target") then PlaySound(SOUNDKIT.IG_CHARACTER_NPC_SELECT)
  else PlaySound(SOUNDKIT.IG_CREATURE_NEUTRAL_SELECT) end
end)

--[[ Target's target ]]--------------------------------------------------------------------------------------------------------------------------------
-- Styling function
function Style.TargetTarget(F, C) -- This will be used on the Focus's module too
  Style.Base(F, C) -- Styling all the basic components

  -- Show the name only if the unit is alive because otherwise the statustext will be shown
  F:Tag(F.Name, F.Name.Color.."[nameifalive]")

  -- Storing data in the Target for modifications that the ToT causes on it when it's visible
  local P = F.PseudoParent
  local TotUnderTarget = F.Portrait:GetWidth() + 3 -- Part of the ToT that is under the Target
  P.AuraOffsetWhenToT = P.oSideLeft and TotUnderTarget or 0
  P.MaxAuraRowWidthWhenToT = P:GetWidth() - TotUnderTarget

  -- The castbar will be aligned with the "inner side" (the opposite of the portrait) of the Target
  if P.oSideLeft then
    P.CastbarOffset = -(P.Castbar:GetWidth() - P:GetWidth())
    P.CastbarOffsetWhenToT = -(P.Castbar:GetWidth() - P:GetWidth()) - TotUnderTarget
  else
    P.CastbarOffset = P.Castbar.Icon:GetWidth() + 1
    P.CastbarOffsetWhenToT = CastbarOffset
  end
end

-- Registering style
oUF:RegisterStyle("TargetTarget", function(F)
  F.PseudoParent = Target
  F.PseudoParent.ToT = F
  Style.TargetTarget(F, Config.TargetTarget)
end)

-- Creation
oUF:SetActiveStyle("TargetTarget")
local ToT = oUF:Spawn("targettarget", "SpyroTargetTarget")
local xOffset = ToT.Portrait:GetWidth() + 2 -- Needed to align the ToT's portrait inner side with the Target's portrait outer side
ToT:SetPoint("TOP"..ToT.oSide, Target, "BOTTOM"..ToT.iSide, ToT.oSideLeft and -xOffset or xOffset, 0)