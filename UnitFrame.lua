--╔════════════════════════╗
--║ ┌─┐┌─┐┬ ┬┬─┐┌─┐  ┬ ┬┬  ║
--║ └─┐├─┘└┬┘├┬┘│ │  │ ││  ║
--║ └─┘┴   ┴ ┴└─└─┘  └─┘┴  ║
--╠════════════════════════╣
--║       UnitFrame        ║
--╠════════════════════════╣
--║ By Spyro [Sanguino EU] ║
--╚════════════════════════╝

--╔═══════════════════════════════════════════════╗
--║ General functions and data used by unitframes ║
--╚═══════════════════════════════════════════════╝

--[[ Local namespace vars ]]---------------------------------------------------------------------------------------------------------------------------
local _, Addon = ... -- Shared table between all files
local oUF, Lib, Style, _Enum = Addon.oUF, Addon.Lib, Addon.Style, Addon.Lib.Enum.Aura
local BlizzlikeDebuffs = true
local BlizzlikeBuffs = false

--[[ Colors ]]-----------------------------------------------------------------------------------------------------------------------------------------
-- Making reaction colors look like selection ones
oUF.colors.reaction[1] = oUF.colors.selection[oUF.Enum.SelectionType.Hostile]
oUF.colors.reaction[2] = oUF.colors.selection[oUF.Enum.SelectionType.Hostile]
oUF.colors.reaction[3] = oUF.colors.selection[oUF.Enum.SelectionType.Unfriendly]
oUF.colors.reaction[4] = oUF.colors.selection[oUF.Enum.SelectionType.Neutral]
oUF.colors.reaction[5] = oUF.colors.selection[oUF.Enum.SelectionType.Friendly]
oUF.colors.reaction[6] = oUF.colors.selection[oUF.Enum.SelectionType.Friendly]
oUF.colors.reaction[7] = oUF.colors.selection[oUF.Enum.SelectionType.Friendly]
oUF.colors.reaction[8] = oUF.colors.selection[oUF.Enum.SelectionType.Friendly]

--[[ General functions ]]------------------------------------------------------------------------------------------------------------------------------
-- AnchorElement()
-- Positions an element with an anchor from the Config.
function Lib.AnchorElement(Element, Anchor, oUF_Frame)
  local Point, RelativeTo, RelativePoint, OffsetX, OffsetY = unpack(Anchor)

  -- Can be relative to the frame or any of its elements, indicated by a string in the Config anchor
  if type(RelativeTo) == "string" then RelativeTo = RelativeTo == "Frame" and oUF_Frame or oUF_Frame[RelativeTo] end
  Element:SetPoint(Point, RelativeTo, RelativePoint, OffsetX, OffsetY)
end

-- Base()
-- Called from oUF styling functions to create all the basic components of an unitframe based on a configuration table.
function Style.Base(F, C)
  local BorderWidth = 1
  F.oSide     = C.Portrait -- Side of the frame where the portrait is, the "outer" side
  F.iSide     = C.Portrait == "LEFT" and "RIGHT" or "LEFT" -- Side of the frame that is the opposite of the portrait, the "inner" side
  F.oSideLeft = F.oSide == "LEFT" -- True if left is the outer side

  -- Background to cover the spaces between elements of the frame, making them look like borders
  F.BackgroundFrame = CreateFrame("Frame", nil, F)
  F.BackgroundFrame:SetFrameStrata("BACKGROUND")
  F.BackgroundFrame:SetFrameLevel(1)
  F.BackgroundFrame:SetAllPoints()
  F.Background = F.BackgroundFrame:CreateTexture(nil, "BACKGROUND", nil, -8)
  F.Background:SetColorTexture(0.01, 0.01, 0.01)
  F.Background:SetAllPoints()
  F.Background:SetIgnoreParentAlpha(true) -- This will create a dim effect if the frame's alpha changes with range

  -- Parent to show text on top of certain elements
  F.TextParent = CreateFrame("Frame", nil, F)
  F.TextParent:SetFrameLevel(10)

  -- Portrait
  if C.Portrait then
    local Size = (C.NameBar and C.NameBar.Height + BorderWidth or 0) + C.HealthBar.Height + (C.PowerBar and C.PowerBar.Height + BorderWidth or 0)
    F.Portrait = F:CreateTexture(nil, "BORDER")
    F.Portrait:SetSize(Size, Size)
    F.Portrait:SetPoint("TOPLEFT", F, "TOPLEFT", C.Portrait == "LEFT" and BorderWidth or BorderWidth + C.BarWidth + BorderWidth, -BorderWidth)
    function F.Portrait:PreUpdate() F.Portrait.showClass = UnitIsPlayer(F.__unit) end -- Class icon on portraits for players
    F.Portrait.Background = F:CreateTexture(nil, "BACKGROUND") -- To fill the space around rounded portraits
    F.Portrait.Background:SetColorTexture(Lib.IsRetail and 0.01 or 0, Lib.IsRetail and 0.05 or 0, Lib.IsRetail and 0.12 or 0)
    F.Portrait.Background:SetAllPoints(F.Portrait)
  end

  -- HealthBar
  F.Health = CreateFrame("StatusBar", nil, F)
  F.Health.colorHealth = true
  F.Health.colorDisconnected = true
  F.Health:SetStatusBarTexture(C.HealthBar.Texture)
  F.Health:SetSize(C.BarWidth, C.HealthBar.Height)
  F.Health:SetPoint("TOPLEFT", F, "TOPLEFT",
    C.Portrait == "LEFT" and BorderWidth + F.Portrait:GetWidth() + BorderWidth or BorderWidth,
    C.NameBar and -BorderWidth - C.NameBar.Height - BorderWidth or -BorderWidth
  )
  F.Health.Background = F.Health:CreateTexture(nil, "BACKGROUND", nil, -7)
  F.Health.Background:SetColorTexture(unpack(C.HealthBar.BackgroundColor))
  F.Health.Background:SetAllPoints()
  if C.HealthBar.Color then
    if C.HealthBar.Color == "AUTO" then
      F.Health.colorClass = true
      F.Health.colorReaction = true
    else
      F.colors.health = oUF:CreateColor(unpack(C.HealthBar.Color))
    end
  end

  -- Health value
  if C.HealthValue then
    F.Health.Value = F.TextParent:CreateFontString(nil, "OVERLAY", nil, 7)
    F.Health.Value:SetFont(unpack(C.HealthValue.Font))
    F.Health.Value:SetJustifyH(C.HealthValue.Justify or "CENTER")
    F:Tag(F.Health.Value, "[spyro:hp]")
    Lib.AnchorElement(F.Health.Value, C.HealthValue.Anchor, F)
  end

  -- Healing prediction
  if C.HealthBar.PredictionTexture then
    F.Health.incomingHealOverflow = 1
    F.Health.HealingAll = CreateFrame("StatusBar", nil, F.Health)
    F.Health.HealingAll:SetStatusBarTexture(C.HealthBar.PredictionTexture)
    F.Health.HealingAll:SetStatusBarColor(0, 1, 0, 1)
    F.Health.HealingAll:SetPoint("TOP")
    F.Health.HealingAll:SetPoint("BOTTOM")
    F.Health.HealingAll:SetPoint("LEFT", F.Health:GetStatusBarTexture(), "RIGHT")

    -- Damage absorb
    F.Health.DamageAbsorb = CreateFrame("StatusBar", nil, F.Health)
    F.Health.DamageAbsorb:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
    F.Health.DamageAbsorb:GetStatusBarTexture():SetTexture(Addon.Media.."/Absorb", "REPEAT", "REPEAT")
    F.Health.DamageAbsorb:GetStatusBarTexture():SetHorizTile(true)
    F.Health.DamageAbsorb:GetStatusBarTexture():SetVertTile(true)
    F.Health.DamageAbsorb:SetStatusBarColor(0.80, 0.93, 1.00) -- 0.90, 0.97, 1.00
    F.Health.DamageAbsorb:SetPoint("TOP")
    F.Health.DamageAbsorb:SetPoint("BOTTOM")
    F.Health.DamageAbsorb:SetPoint("LEFT", F.Health.HealingAll:GetStatusBarTexture(), "RIGHT")

    -- Overshield glow when absorbs overflow past max health
    F.Health.OverDamageAbsorbIndicator = F.Health:CreateTexture()
    F.Health.OverDamageAbsorbIndicator:SetPoint("TOP")
    F.Health.OverDamageAbsorbIndicator:SetPoint("BOTTOM")
    F.Health.OverDamageAbsorbIndicator:SetPoint("RIGHT", F.Health, "RIGHT", 3, 0)
    F.Health.OverDamageAbsorbIndicator:SetWidth(8)

    -- Healing absorb
    F.Health.HealAbsorb = CreateFrame("StatusBar", nil, F.Health)
    F.Health.HealAbsorb:SetPoint("TOP")
    F.Health.HealAbsorb:SetPoint("BOTTOM")
    F.Health.HealAbsorb:SetPoint("RIGHT", F.Health:GetStatusBarTexture())
    F.Health.HealAbsorb:SetStatusBarTexture("Interface/BUTTONS/WHITE8X8")
    F.Health.HealAbsorb:GetStatusBarTexture():SetAtlas("RaidFrame-Absorb-Overlay", TextureKitConstants.IgnoreAtlasSize, nil, nil, "REPEAT", "REPEAT")
    F.Health.HealAbsorb:GetStatusBarTexture():SetHorizTile(true)
    F.Health.HealAbsorb:GetStatusBarTexture():SetVertTile(true)
    F.Health.HealAbsorb:GetStatusBarTexture():SetVertexColor(0, 0, 0)
    F.Health.HealAbsorb:SetReverseFill(true)
    F.Health.OverHealAbsorbIndicator = F.Health:CreateTexture()
    F.Health.OverHealAbsorbIndicator:SetPoint("TOP", Health, 0, 2)
    F.Health.OverHealAbsorbIndicator:SetPoint("BOTTOM", Health, 0, -2)
    F.Health.OverHealAbsorbIndicator:SetPoint("RIGHT", Health, "LEFT", 3, 0)
    F.Health.OverHealAbsorbIndicator:SetWidth(10)
  end

  -- PowerBar
  if C.PowerBar then
    F.Power = CreateFrame("StatusBar", nil, F)
    F.Power:SetStatusBarTexture(C.PowerBar.Texture)
    F.Power:SetSize(C.BarWidth, C.PowerBar.Height)
    F.Power:SetPoint("TOPLEFT", F.Health, "BOTTOMLEFT", 0, -BorderWidth)
    F.Power.colorPower = true
    F.Power.displayAltPower = true
    F.Power.Background = F.Power:CreateTexture(nil, "BACKGROUND", nil, -7)
    F.Power.Background:SetColorTexture(unpack(C.PowerBar.BackgroundColor))
    F.Power.Background:SetAllPoints()
  end

  -- Power value
  if C.PowerValue then
    F.Power.Value = F.Power:CreateFontString(nil, "OVERLAY")
    F.Power.Value:SetFont(unpack(C.PowerValue.Font))
    F.Power.Value:SetJustifyH(C.PowerValue.Justify or "CENTER")
    F:Tag(F.Power.Value, "[spyro:power]")
    Lib.AnchorElement(F.Power.Value, C.PowerValue.Anchor, F)
  end

  -- NameBar
  if C.NameBar then
    F.NameBar = F:CreateTexture(nil, "BACKGROUND")
    F.NameBar:SetTexture(C.NameBar.Texture)
    F.NameBar:SetDrawLayer("BACKGROUND", 0)
    F.NameBar:SetSize(C.BarWidth, C.NameBar.Height)
    F.NameBar:SetPoint("BOTTOMLEFT", F.Health, "TOPLEFT", 0, BorderWidth)
    if C.NameBar.Color == "AUTO" then
      Lib.RegisterEvent("PLAYER_TARGET_CHANGED", function() F.NameBar:SetVertexColor(Lib.GetUnitColor(F.__unit)) end, true)
      Lib.RegisterUnitEvent("UNIT_FACTION", F.__unit, function() F.NameBar:SetVertexColor(Lib.GetUnitColor(F.__unit)) end)
    else
      F.NameBar:SetVertexColor(unpack(C.NameBar.Color))
    end
  end

  -- Name
  F.Name = F.TextParent:CreateFontString(nil, "ARTWORK")
  F.Name:SetFont(unpack(C.Name.Font))
  F.Name:SetJustifyH(C.Name.Justify or "CENTER")
  F.Name:SetWordWrap(false)
  Lib.AnchorElement(F.Name, C.Name.Anchor, F)
  if C.Name.MaxWidth then F.Name:SetWidth(C.Name.MaxWidth) end
  if C.Name.Shadow then F.Name:SetShadowOffset(1, -1) end    
  F.Name.Color = C.Name.Color and (C.Name.Color == "AUTO" and "[unitcolor]" or oUF:CreateColor(unpack(C.Name.Color)):GenerateHexColorMarkup()) or ""
  F:Tag(F.Name, F.Name.Color.."[name]")

  -- Status
  F.Status = F.TextParent:CreateFontString(nil, "OVERLAY")
  F.Status:SetFont(unpack(C.Status.Font))
  F.Status:SetJustifyH(C.Status.Justify or "CENTER")
  F:Tag(F.Status, "[spyro:status]")
  Lib.AnchorElement(F.Status, C.Status.Anchor, F)

  -- Level
  if C.Level then
    F.Level = F.TextParent:CreateFontString(nil, "OVERLAY")
    F.Level:SetJustifyH(C.Level.Justify or "CENTER")
    F.Level:SetFont(unpack(C.Level.Font))
    F:Tag(F.Level, "[spyro:level]")
    Lib.AnchorElement(F.Level, C.Level.Anchor, F)

    -- Skull texture to show when the level of the unit is too high to know
    F.SkullLevel = F:CreateTexture(nil, "OVERLAY")
    F.SkullLevel:Hide()
    F.SkullLevel:SetAtlas("UI-HUD-UnitFrame-Target-HighLevelTarget_Icon")
    F.SkullLevel:SetSize(unpack(C.Level.SkullSize))
    Lib.AnchorElement(F.SkullLevel, C.Level.SkullAnchor, F)
  end

  -- Role icon
  if C.RoleIcon then
    F.GroupRoleIndicator = F.TextParent:CreateTexture(nil, "OVERLAY")
    F.GroupRoleIndicator.useAtlasSize = false
    F.GroupRoleIndicator:SetSize(C.RoleIcon.Size, C.RoleIcon.Size)
    Lib.AnchorElement(F.GroupRoleIndicator, C.RoleIcon.Anchor, F)
  end

  -- Combat indicator
  if C.CombatIndicator then
    F.CombatIndicator = F.TextParent:CreateFontString(nil, "OVERLAY")
    F.CombatIndicator:SetFont(unpack(C.CombatIndicator.Font))
    F.CombatIndicator:SetJustifyH(C.CombatIndicator.Justify or "CENTER")
    F.CombatIndicator:SetTextColor(unpack(C.CombatIndicator.Color))
    F.CombatIndicator:SetText("C")
    Lib.AnchorElement(F.CombatIndicator, C.CombatIndicator.Anchor, F)
  end

  -- Range opacity
  if C.RangeOpacity then
    F.Range = {}
  end

  -- Threat glow
  if C.Threat then
    if C.Threat.Style == "OUTSIDE" then -- Glow around the border of the frame
      F.ThreatIndicator = Lib.CreateExternalBackdrop(F, Addon.Media.."/AggroGlow", 9)
      F.ThreatIndicator:SetFrameStrata("BACKGROUND")
      F.ThreatIndicator:SetFrameLevel(0)

      -- Function to update the threat color since oUF doesn't work with backdrops (only textures)
      function F.ThreatIndicator:PostUpdate(Unit, Status, Color)
        if Color then self:SetBackdropBorderColor(Color:GetRGB()) end
      end
    else -- Raid-style glow inside the frame
      F.ThreatIndicator = F.TextParent:CreateTexture(nil, "BORDER", nil, 1)
      F.ThreatIndicator:SetTexture("Interface/RaidFrame/Raid-FrameHighlights")
      F.ThreatIndicator:SetTexCoord(0.00781250, 0.55468750, 0.00781250, 0.27343750)
      F.ThreatIndicator:SetAllPoints(F)
      F.ThreatIndicator:Hide()
    end

    -- Option of ignore a threat level and the levels under it
    if C.Threat.IgnoreLevel then
      if F.ThreatIndicator.PostUpdate then -- If it already exists hook it
        hooksecurefunc(F.ThreatIndicator, "PostUpdate", function(_,Status)
          if Status and Status <= C.Threat.IgnoreLevel then self:Hide() end
        end)
      else
        function F.ThreatIndicator:PostUpdate(_,Status)
          if Status and Status <= C.Threat.IgnoreLevel then self:Hide() end
        end
      end
    end

    -- Disable in Arenas
    Lib.RegisterEvent("PLAYER_ENTERING_WORLD", function()
      if Lib.InArena() then F:DisableElement("ThreatIndicator")
      else F:EnableElement("ThreatIndicator") end
    end)
  end

  -- Target highlight
  if C.TargetHighlight then
    -- Creating an internal border to highlight when the unit is targeted
    F.TargetedBorder = F.TextParent:CreateTexture(nil, "OVERLAY")
    F.TargetedBorder:SetTexture("Interface/RaidFrame/Raid-FrameHighlights")
    F.TargetedBorder:SetTexCoord(0.00781250, 0.55468750, 0.28906250, 0.55468750)
    F.TargetedBorder:SetIgnoreParentAlpha(true)
    F.TargetedBorder:SetAllPoints(F)
    F.TargetedBorder:Hide()

    -- Events to check if this unit is the target
    Lib.RegisterEvent(
      "PLAYER_ENTERING_WORLD "..
      "PLAYER_TARGET_CHANGED "..
      "PLAYER_SOFT_ENEMY_CHANGED "..
      "PLAYER_SOFT_FRIEND_CHANGED"..
      (Lib.MatchOR(F.__unit, "^party%d$", "^partypet%d$", "^raid%d$", "^raidpet%d$") and " GROUP_ROSTER_UPDATE" or ""),
      function() F.TargetedBorder:SetShown(UnitIsUnit("target", F.__unit)) end, true
    )
  end

  -- Cast bar
  if C.Castbar then
    F.Castbar = CreateFrame("StatusBar", "SpyroPlayerCastbar", F, "DisableUntrustedLayoutScriptsTemplate")
    F.Castbar:SetFrameLevel(20) -- Higher than UnitFrames
    F.Castbar:SetStatusBarTexture(C.Castbar.Texture)
    F.Castbar:SetStatusBarColor(unpack(C.Castbar.Color))
    F.Castbar:SetSize(C.Castbar.Width, C.Castbar.Height)
    if C.Castbar.Anchor then Lib.AnchorElement(F.Castbar, C.Castbar.Anchor, F) end

    -- Background
    F.Castbar.Background = F.Castbar:CreateTexture(nil, "BACKGROUND")
    F.Castbar.Background:SetColorTexture(unpack(C.Castbar.BackgroundColor))
    F.Castbar.Background:SetAllPoints()

    -- Spark
    F.Castbar.Spark = F.Castbar:CreateTexture(nil, "OVERLAY")
    F.Castbar.Spark:SetBlendMode("ADD")
    F.Castbar.Spark:SetSize(14, C.Castbar.Height * 1.8)
    F.Castbar.Spark:SetPoint("CENTER", F.Castbar:GetStatusBarTexture(), "RIGHT", 0, 0)

    -- Text
    F.Castbar.Text = F.Castbar:CreateFontString(nil, "OVERLAY")
    F.Castbar.Text:SetFont(unpack(C.Castbar.Font))
    F.Castbar.Text:SetWordWrap(false)
    F.Castbar.Text:SetJustifyH("CENTER")
    F.Castbar.Text:SetPoint("CENTER")
    if C.Castbar.SpellMaxWidth then F.Castbar.Text:SetWidth(C.Castbar.SpellMaxWidth) end

    -- Icon
    F.Castbar.Icon = F.Castbar:CreateTexture(nil, "OVERLAY")
    F.Castbar.Icon:SetSize(C.Castbar.Height, C.Castbar.Height)
    F.Castbar.Icon:SetPoint("TOPRIGHT", F.Castbar, "TOPLEFT", -1, 0)

    -- Uninterruptible shield
    F.Castbar.Shield = F.Castbar:CreateTexture(nil, "OVERLAY", nil, 7)
    F.Castbar.Shield:SetTexture(Addon.Media.."/Shield")
    F.Castbar.Shield:SetSize(C.Castbar.Height * 64 / 20, C.Castbar.Height * 64 / 20)
    F.Castbar.Shield:SetPoint("CENTER", F.Castbar.Icon, "CENTER")
    F.Castbar.Shield:SetAlpha(0)

    -- Uninterruptible border
    F.Castbar.UninterruptibleBorder = Lib.CreateExternalBackdrop(F.Castbar, "Interface/Buttons/WHITE8x8", 3)
    F.Castbar.UninterruptibleBorder:SetFrameLevel(19)
    F.Castbar.UninterruptibleBorder:SetBackdropColor(0.6, 0.6, 0.6, 1)
    F.Castbar.UninterruptibleBorder:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
    F.Castbar.UninterruptibleBorder:SetAlpha(0)
    function F.Castbar:PostCastStart(_,_,notInterruptible) self.UninterruptibleBorder:SetAlphaFromBoolean(notInterruptible) end
    function F.Castbar:PostCastInterruptible(_,_,notInterruptible) self.UninterruptibleBorder:SetAlphaFromBoolean(notInterruptible) end

    -- Border
    Lib.CreateFlatBackdrop(F.Castbar, 1, 0.01, 0.01, 0.01)
  end

  -- Tooltip
  F:HookScript("OnEnter", function()
    if GameTooltip:IsForbidden() then return end
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    GameTooltip:SetUnit(F.__unit)
    GameTooltip:Show()
  end)

  F:HookScript("OnLeave", function()
    GameTooltip:Hide()
  end)

  -- Frame's size based on its contents
  F:SetSize(
    BorderWidth*2 + (F.Portrait and F.Portrait:GetWidth() + BorderWidth or 0) + C.BarWidth,
    BorderWidth*2 + (C.NameBar and C.NameBar.Height + BorderWidth or 0) + C.HealthBar.Height + (C.PowerBar and C.PowerBar.Height + BorderWidth or 0)
  )

  -- Enable right-click menu
  F:RegisterForClicks("AnyUp")
end

-- UnitFrames_SetGrowthDirection()
-- Sets the direction where a group of UnitFrames will grow (UP or DOWN).
-- The upwards growth is made by just changing the vertical offset of the first frame.
-- This can be applied to make the PartyFrames/BossFrames/ArenaFrames grow upwards.
function Lib.UnitFrames_SetGrowthDirection(Direction, Anchor, ...)
  local Frames = {...}

  -- Downwards growth
  for i = 1, #Frames do
    Frames[i]:ClearAllPoints()
    if i == 1 then Frames[i]:SetPoint(unpack(Anchor))
    else Frames[i]:SetPoint("TOPLEFT", Frames[i-1], "BOTTOMLEFT", 0, 0) end
  end

  if Direction ~= "UP" then return end

  -- Upwards growth. Implemented by changing the vertical offset of the first frame
  local Condition = ""
  local FirstFrame = Frames[1]
  local FrameHeight = FirstFrame:GetHeight()

  FirstFrame.PositionDriver = CreateFrame("Frame", nil, nil, "SecureHandlerAttributeTemplate")
  Lib.SetFrameRef(FirstFrame.PositionDriver, "FirstFrame", FirstFrame)
  Lib.SaveAnchor(FirstFrame.PositionDriver, "Anchor", Anchor) -- The anchor must be a table with the params

  FirstFrame.PositionDriver:SetAttribute("_onattributechanged", [[
    local Point, RelativeTo, RelativePoint, OffsetX = unpack(Anchor)
    FirstFrame:SetPoint(Point, RelativeTo, RelativePoint, OffsetX, value) -- value is the vertical offset
  ]])

  -- Condition to generate the proper vertical offset depending on the existence of each unit
  for i = #Frames, 2, -1 do Condition = Condition.."[@"..Frames[i].__unit..",exists]"..(FrameHeight * (i-1))..";" end
  RegisterAttributeDriver(FirstFrame.PositionDriver, "OffsetY", Condition.."0") -- Default offset is 0
end

-- CreateAuraContainer()
-- Creates an AuraContainer with the most common settings and returns it.
function Lib.CreateAuraContainer(Unit, Parent, Point, RelativeTo, RelativePoint, OffsetX, OffsetY, MaxWidth)
  local A = CreateFrame("AuraContainer", nil, Parent, "CustomAuraContainerTemplate")
  A:SetEditModePreviewEnabled(true)
  A:SetUnit(Unit)
  if MaxWidth then A:SetFlowLayoutMaximumLineSize(MaxWidth) end

  if Point then
    A:SetPoint(Point, RelativeTo, RelativePoint, OffsetX, OffsetY)
    A:SetFlowLayoutAnchorPoint(Point)
    local Horizontal = Point:find("LEFT") and "Right" or "Left"
    local Vertical = Point:find("BOTTOM") and "Up" or "Down"
    A:SetFlowLayoutGrowthDirection(AnchorUtil.FlowDirection[Horizontal], AnchorUtil.FlowDirection[Vertical])
  end

  return A
end

-- CreateRaidStyleDispelSymbols()
-- Creates raid-style dispel alert symbols on the topright of the healthbar of an UnitFrame.
--
-- Params:
-- ▪ F: Frame.
-- ▪ C: Configuration table for the frame.
function Lib.CreateRaidStyleDispelSymbols(F, C)
  F.DispelSymbols = Lib.CreateAuraContainer(F.__unit, F.TextParent, "TOPRIGHT", F.Health, "TOPRIGHT", -1, -2)

  -- Creating an icon for each dispel type, to be displayed always in the same order
  for _, DebuffType in ipairs({ "Magic", "Curse", "Disease", "Poison", "Bleed" }) do
    F.DispelSymbols:AddAuraGroup(DebuffType, "HARMFUL|RAID", {
      maxFrameCount = 1,
      candidateFilters = { includeDispelTypes = { [DebuffType] = true } },

      initializeFrame = function(AuraButton)
        AuraButton:SetSize(C.DispelSymbols.Size, C.DispelSymbols.Size)
        AuraButton.Symbol = AuraButton:CreateTexture(nil, "OVERLAY")
        AuraButton.Symbol:SetAllPoints(AuraButton)
        if C.DispelSymbols.UseOldIcons then
          AuraButton.Symbol:SetTexture("Interface/RaidFrame/Raid-Icon-Debuff"..DebuffType)
          AuraButton:AddDispelTypeTexture(AuraButton.Symbol, { style = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset })
        else
          AuraButton:AddDispelTypeTexture(AuraButton.Symbol, { style = Enum.CustomAuraButtonDispelTypeTextureStyle.Icon })
        end
      end
    })
  end

  F.DispelSymbols:UpdateAllAuras()
end

-- CreateRaidStyleAuras()
-- Creates AuraContainers for raid-style auras (debuffs on bottomleft, buffs on bottomright) in the healthbar of an UnitFrame.
-- Doesn't add any AuraGroup since that will be implemented by each UnitFrame.
--
-- Params:
-- ▪ F: Frame.
-- ▪ C: Configuration table for the frame.
function Lib.CreateRaidStyleAuras(F, C)
  local IsPet = F.__unit:find("pet")

  --[[ Debuffs ]]------------------------------------------------------------------------------------
  local DebuffsMaxWidth = (C.Debuffs.Size + 2) * 3
  F.DebuffsClipParent = CreateFrame("Frame", nil, F.Health) -- Parent to hide excess auras
  F.DebuffsClipParent:SetClipsChildren(true)
  F.DebuffsClipParent:SetPoint("BOTTOMLEFT", F.Health, "BOTTOMLEFT", 3, -1)
  F.DebuffsClipParent:SetSize(DebuffsMaxWidth, (C.Debuffs.Size + 2) * (IsPet and 1 or 2))
  F.DebuffsClipParent:SetFrameLevel(F.Health:GetFrameLevel() + 1)
  F.DebuffsClipParent:SetFrameLevel(10)
  F.Debuffs = Lib.CreateAuraContainer(F.__unit, F.DebuffsClipParent, "BOTTOMLEFT", F.Health, "BOTTOMLEFT", 3, 1, DebuffsMaxWidth)

  --[[ Buffs ]]--------------------------------------------------------------------------------------
  local BuffsMaxWidth = (C.Buffs.Size + 2) * 3
  F.BuffsClipParent = CreateFrame("Frame", nil, F.Health) -- Parent to hide excess auras
  F.BuffsClipParent:SetClipsChildren(true)
  F.BuffsClipParent:SetPoint("BOTTOMRIGHT", F.Health, "BOTTOMRIGHT", -3, 1)
  F.BuffsClipParent:SetSize(BuffsMaxWidth, C.Buffs.Size * (IsPet and 1 or 2))
  F.BuffsClipParent:SetFrameLevel(10)
  F.Buffs = Lib.CreateAuraContainer(F.__unit, F.BuffsClipParent, "BOTTOMRIGHT", F.Health, "BOTTOMRIGHT", -3, 1, BuffsMaxWidth)
end

-- CreatePartyAuras()
-- Adds raid-style auras to an UnitFrame:
-- ▪ Dispel alert symbols on TOPRIGHT.
-- ▪ Debuffs on BOTTOMLEFT.
-- ▪ Buffs on BOTTOMRIGHT.
-- ▪ Boss/Important debuffs on BOTTOMLEFT outside of the frame.
-- ▪ CC/Important buffs on BOTTOMRIGHT outside of the frame (for pets they will be shown on the same place as Boss debuffs).
--
-- Params:
-- ▪ F: Frame.
-- ▪ C: Configuration table for the frame.
function Lib.CreatePartyAuras(F, C)
  local IsPet = F.__unit:find("pet")
  Lib.CreateRaidStyleDispelSymbols(F, C)
  Lib.CreateRaidStyleAuras(F, C)

  --[[ Debuffs ]]----------------------------------------------------------------------------------------------------------------
  -- Blizz-like filter but without CROWD_CONTROL and IMPORTANT coz we show that in another place
  if BlizzlikeDebuffs then
    F.Debuffs:SetAuraProcessingPolicy(CustomAuraContainerAuraProcessingPolicy.ProcessAura)
    F.Debuffs:AddAuraGroup("BlizzDebuffs", "HARMFUL", { -- "HARMFUL|!CROWD_CONTROL|!IMPORTANT"
      maxFrameCount = C.Debuffs.MaxNum,
      initializeFrame = function(Button) Lib.ConfigureAuraButton(Button, { Size = C.Debuffs.Size, Border = _Enum.DebuffTypeBorder }) end,
      sortMethod = AuraContainerSortMethod.UnitFrameDebuff,
      candidateFilters = { excludeSpellIDs = Addon.Config.PartyDebuffsHide }
    })

  -- Custom filter
  else
    -- Priority debuffs (Weakened Soul/Forbearance?) | Doesn't work
    F.Debuffs:AddAuraGroup("PrioDebuffs", "HARMFUL", {
      initializeFrame = function(Button) Lib.ConfigureAuraButton(Button, { Size = C.Debuffs.Size * 2, Border = _Enum.DebuffTypeBorder }) end,
      sortMethod = AuraContainerSortMethod.UnitFrameDebuff,
      candidateFilters = { isPriorityAura = true }
    })

    -- Debuffs that the player can dispel, except important/CC ones that will be shown in a different place
    F.Debuffs:AddAuraGroup("Debuffs1", "HARMFUL|RAID|!IMPORTANT|!CROWD_CONTROL", {
      initializeFrame = function(Button) Lib.ConfigureAuraButton(Button, { Size = C.Debuffs.Size, Border = _Enum.DebuffTypeBorder }) end,
      sortMethod = AuraContainerSortMethod.UnitFrameDebuff,
      --candidateFilters = { isPriorityAura = false } -- Already shown before
    })

    -- Debuffs that the player can't dispel, except important/CC ones that will be shown in a different place
    F.Debuffs:AddAuraGroup("Debuffs2", "HARMFUL|!RAID|!IMPORTANT|!CROWD_CONTROL", {
      initializeFrame = function(Button) Lib.ConfigureAuraButton(Button, { Size = C.Buffs.Size, Border = _Enum.DebuffTypeBorder }) end,
      sortMethod = AuraContainerSortMethod.UnitFrameDebuff,
      candidateFilters = {
        --isPriorityAura = false,
        excludeSpellIDs = Addon.Config.PartyDebuffsHide
      },
    })
  end

  -- Boss/important debuffs on the outside left of the frame
  if IsPet then F.Important = Lib.CreateAuraContainer(F.__unit, F, "RIGHT", F, "LEFT", 0, 0)
  else F.Important = Lib.CreateAuraContainer(F.__unit, F, "BOTTOMRIGHT", F, "BOTTOMLEFT", 0, 0) end

  -- Boss or role debuffs
  F.Important:AddAuraGroup("Important1", "HARMFUL|!CROWD_CONTROL", {
    initializeFrame = function(Button) Lib.ConfigureAuraButton(Button, { Size = C.ImportantAuras.Size, Border = _Enum.DebuffTypeBorder }) end,
    sortMethod = AuraContainerSortMethod.UnitFrameDebuff,
    candidateFilters = { isBossOrRoleAura = true }, -- isBossAura
  })

  -- Important debuffs that the player can dispel
  F.Important:AddAuraGroup("Important2", "HARMFUL|RAID|IMPORTANT|!CROWD_CONTROL", {
    initializeFrame = function(Button) Lib.ConfigureAuraButton(Button, { Size = C.ImportantAuras.Size, _Enum.DebuffTypeBorder }) end,
    sortMethod = AuraContainerSortMethod.UnitFrameDebuff,
    candidateFilters = { isBossOrRoleAura = false },
  })

  -- Important debuffs that the player can't dispel
  F.Important:AddAuraGroup("Important3", "HARMFUL|!RAID|IMPORTANT|!CROWD_CONTROL", {
    initializeFrame = function(Button) Lib.ConfigureAuraButton(Button, { Size = C.ImportantAuras.Size, _Enum.DebuffTypeBorder }) end,
    sortMethod = AuraContainerSortMethod.UnitFrameDebuff,
    candidateFilters = { isBossOrRoleAura = false },
  })

  --[[ Buffs ]]-----------------------------------------------------------------------------------------------------------------------
  -- Blizz-like buff filter, experimental
  if BlizzlikeBuffs then
    F.Buffs:SetAuraProcessingPolicy(CustomAuraContainerAuraProcessingPolicy.ProcessAura)
    F.Buffs:AddAuraGroup("BlizzBuffs", "HELPFUL", {
      maxFrameCount = C.Buffs.MaxNum,
      initializeFrame = function(Button) Lib.ConfigureAuraButton(Button, { Size = C.Buffs.Size }) end,
      sortMethod = AuraContainerSortMethod.Name,
    })

  -- Custom filter
  else
    -- Buffs that will always be visible (from any caster)
    if Addon.Config.PartyBuffsShowAlways[Lib.PLAYER_CLASS] then
      F.Buffs:AddAuraGroup("ShowAlways", "HELPFUL", {
        initializeFrame = function(Button) Lib.ConfigureAuraButton(Button, { Size = C.Buffs.Size }) end,
        sortMethod = AuraContainerSortMethod.Name,
        candidateFilters = { includeSpellIDs = Addon.Config.PartyBuffsShowAlways[Lib.PLAYER_CLASS] },
      })
    end

    -- Buffs that will be visible only out of combat (from any caster)
    if Addon.Config.PartyBuffsShowOOC[Lib.PLAYER_CLASS] then
      F.Buffs:AddAuraGroup("ShowOOC", "HELPFUL", {
        initializeFrame = function(Button) Lib.ConfigureAuraButton(Button, { Size = C.Buffs.Size }) end,
        sortMethod = AuraContainerSortMethod.Name,
        candidateFilters = { includeSpellIDs = Addon.Config.PartyBuffsShowOOC[Lib.PLAYER_CLASS] },
      })

      F.Buffs:SetAuraGroupEnabled("ShowOOC", not UnitAffectingCombat("player"))
      Lib.RegisterEvent("PLAYER_REGEN_ENABLED", function() F.Buffs:SetAuraGroupEnabled("ShowOOC", true) end)
      Lib.RegisterEvent("PLAYER_REGEN_DISABLED", function() F.Buffs:SetAuraGroupEnabled("ShowOOC", false) end)
    end

    -- Buffs from the player that will always be visible
    F.Buffs:AddAuraGroup("HoTs", "HELPFUL|PLAYER", { -- |RAID_IN_COMBAT
      initializeFrame = function(Button) Lib.ConfigureAuraButton(Button, { Size = C.Buffs.Size }) end,
      sortMethod = AuraContainerSortMethod.Name,
      candidateFilters = { includeSpellIDs = Addon.Config.RAID_IN_COMBAT },
    })
  end

  --[[ CC and defensives ]]-----------------------------------------------------------------------------------------------------------
  -- Players: Shown on the outside right of the frame
  -- Pets: Shown outside left of the frame (on the same container as the important debuffs)
  local AuraSize, Container

  if IsPet then
    Container = F.Important
    AuraSize =  C.ImportantAuras.Size
  else
    F.CCandDef = Lib.CreateAuraContainer(F.__unit, F, "BOTTOMLEFT", F, "BOTTOMRIGHT", 0, 0)
    Container = F.CCandDef
    AuraSize = C.CCandDefAuras.Size
  end

  Container:AddAuraGroup("CC", "HARMFUL|CROWD_CONTROL", {
    initializeFrame = function(Button) Lib.ConfigureAuraButton(Button, { Size = AuraSize, Border = _Enum.DebuffTypeBorder }) end,
  })
  Container:AddAuraGroup("BigDef", "HELPFUL|BIG_DEFENSIVE|!EXTERNAL_DEFENSIVE", {
    initializeFrame = function(Button) Lib.ConfigureAuraButton(Button, { Size = AuraSize }) end,
  })
  Container:AddAuraGroup("ExternalDef", "HELPFUL|EXTERNAL_DEFENSIVE", {
    initializeFrame = function(Button) Lib.ConfigureAuraButton(Button, { Size = AuraSize }) end,
  })
end