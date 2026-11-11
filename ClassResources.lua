--╔════════════════════════╗
--║ ┌─┐┌─┐┬ ┬┬─┐┌─┐  ┬ ┬┬  ║
--║ └─┐├─┘└┬┘├┬┘│ │  │ ││  ║
--║ └─┘┴   ┴ ┴└─└─┘  └─┘┴  ║
--╠════════════════════════╣
--║    Class Resources     ║
--╠════════════════════════╣
--║ By Spyro [Sanguino EU] ║
--╚════════════════════════╝

-- Local namespace vars
local _, Addon = ... -- Shared table between all files
local oUF, Config, Lib, UnitPower = Addon.oUF, Addon.Config, Addon.Lib, UnitPower
local ChargesFrame

-- CreatePowerCharges()
-- Creates a frame with combopoint-like textures to visualize charges of a power.
-- PowerID can be a spellID for buff resources or a PowerType string.
-- If SpecIndex is specified, the ChargesFrame will be enabled only for that spec.
local function CreatePowerCharges(Anchor, ChargeSize, PowerID, SpecIndex)
  ChargesFrame = CreateFrame("Frame", nil, UIParent) -- Parent for the charges textures
  ChargesFrame:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end) -- Run events on methods of their name
  ChargesFrame:SetPoint(unpack(Anchor))

  ChargesFrame.Charges = {}
  ChargesFrame.ChargeSize = ChargeSize
  ChargesFrame.PowerID = PowerID
  ChargesFrame.SpecIndex = SpecIndex

  function ChargesFrame:PLAYER_ENTERING_WORLD()
    ChargesFrame:Update()
    if self.UNIT_AURA then self:UNIT_AURA()
    elseif self.UNIT_POWER_UPDATE then self:UNIT_POWER_UPDATE(_, self.PowerID) end
  end

  function ChargesFrame:TRAIT_CONFIG_UPDATED() self:Update() end
  function ChargesFrame:PLAYER_TALENT_UPDATE() self:Update() end
  function ChargesFrame:ACTIVE_PLAYER_SPECIALIZATION_CHANGED() self:Update() end
  function ChargesFrame:ACTIVE_TALENT_GROUP_CHANGED() self:Update() end
  ChargesFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")
  ChargesFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
  ChargesFrame:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED")
  ChargesFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
  ChargesFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

  function ChargesFrame:Update()
    -- Checking if it must be enabled for this spec
    if self.SpecIndex and self.SpecIndex ~= Lib.GetSpecIndex() then
      self:Hide()
      self:UnregisterEvent("PLAYER_ENTERING_WORLD")
      self:UnregisterEvent("UNIT_AURA")
      self:UnregisterEvent("UNIT_POWER_UPDATE")
      self:UnregisterEvent("PLAYER_TARGET_CHANGED")
      return
    end

    -- Buff (SpellID)
    if type(self.PowerID) == "number" then
      self.MaxCharges = C_Spell.GetSpellMaxCumulativeAuraApplications(self.PowerID)

      function self:UNIT_AURA()
        local Buff = C_UnitAuras.GetPlayerAuraBySpellID(self.PowerID)
        self:UpdateCharges(Buff and Buff.applications or 0)
      end

      self:RegisterUnitEvent("UNIT_AURA", "player")

    -- PowerType (COMBO_POINTS, HOLY_POWER, CHI, ARCANE_CHARGES, etc)
    else
      self.PowerTypeNumber = Lib.Enum.PowerStringToNumber[self.PowerID]

      -- HOLY_POWER returns the wrong value (3 instead of 5) in the first PLAYER_ENTERING_WORLD so we have to hardcode it :-/
      self.MaxCharges = self.PowerID == "HOLY_POWER" and 5 or UnitPowerMax("player", self.PowerTypeNumber)

      if self.PowerID == "COMBO_POINTS" and Lib.TocVersion < 60000 then -- Combo Points stored on target
        function self:UNIT_POWER_UPDATE(_, PowerType)
          if PowerType == self.PowerID then self:UpdateCharges(GetComboPoints("player", "target")) end
        end

        function self:PLAYER_TARGET_CHANGED() self:UpdateCharges(GetComboPoints("player", "target")) end
        self:RegisterEvent("PLAYER_TARGET_CHANGED")
        --Lib.RegisterEvent("PLAYER_ENTERING_WORLD", function() self:SetShown(UnitExists("target")) end)

      else -- Power stored on the player
        function self:UNIT_POWER_UPDATE(_, PowerType)
          if PowerType == self.PowerID then self:UpdateCharges(UnitPower("player", self.PowerTypeNumber)) end
        end
      end

      self:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
    end

    self:SetSize(self.MaxCharges > 3 and self.ChargeSize*2-3 or self.ChargeSize, self.ChargeSize * 3)

    -- Hiding charges that already exist (possible if this function has been called before), which can
    -- happen in cases like Retail Rogue where the number of total Combo Points changes with talents
    for i = 1, #self.Charges do
      self.Charges[i]:ClearAllPoints()
      self.Charges[i]:Hide() -- Hidden charges will be considered disabled in the positioning function
    end

    -- Creating charges
    for i = 1, self.MaxCharges do
      if self.Charges[i] then
        self.Charges[i]:Show()
      else
        self.Charges[i] = CreateFrame("Frame", nil, self)
        self.Charges[i]:SetSize(self.ChargeSize, self.ChargeSize)

        self.Charges[i].On = self.Charges[i]:CreateTexture()
        self.Charges[i].On:SetAtlas("ClassOverlay-ComboPoint")
        self.Charges[i].On:SetAllPoints()

        self.Charges[i].Off = self.Charges[i]:CreateTexture()
        self.Charges[i].Off:SetAtlas("ClassOverlay-ComboPoint-Off")
        self.Charges[i].Off:SetAllPoints()
      end
    end

    -- Positioning charges. Hidden charges will be considered disabled
    local C = self.Charges

    C[1]:SetPoint("BOTTOM", C[2], "TOP")
    C[2]:SetPoint("BOTTOM", C[3], "TOP")
    C[3]:SetPoint("BOTTOMLEFT")

    if C[5] and C[5]:IsShown() then
      C[4]:SetPoint("BOTTOM", C[5], "TOP", 0, 0)
      if C[6] and C[6]:IsShown() then C[5]:SetPoint("BOTTOM", C[6], "TOP", 0, 0)
      else C[5]:SetPoint("TOPLEFT", C[2], "RIGHT", -3, 0) end
    elseif C[4] and C[4]:IsShown() then
      C[4]:SetPoint("LEFT", C[2], "RIGHT", 0, 0)
    end

    if C[6] and C[6]:IsShown() then C[6]:SetPoint("BOTTOMLEFT", C[3], "BOTTOMRIGHT", 0, 0) end
    if C[7] and C[7]:IsShown() then C[7]:SetPoint("LEFT", C[5], "RIGHT", 0, 0) end
  end

  function ChargesFrame:UpdateCharges(CurrentCharges)
    for i = 1, self.MaxCharges do
      self.Charges[i].On:SetShown(i <= CurrentCharges)
      self.Charges[i].Off:SetShown(i > CurrentCharges)
    end
  end

  ChargesFrame:PLAYER_ENTERING_WORLD()
  return ChargesFrame
end

-- Event PLAYER_ENTERING_WORLD
-- Fires whenever the loading screen appears. After the first one the Enum.PowerType data is already available.
Lib.RegisterOnceEvent("PLAYER_ENTERING_WORLD", function()
  local Anchor = Config.Player.ResourceCharges.Anchor
  local ChargeSize = Config.Player.ResourceCharges.ChargeSize

  --[[ Totems ]]---------------------------------------------------------------------------------------------------------------------------------------
  local TOTEM_PRIORITIES = Lib.PLAYER_CLASS == "SHAMAN" and SHAMAN_TOTEM_PRIORITIES or STANDARD_TOTEM_PRIORITIES
  local TotemBar = CreateFrame("Frame", "SpyroTotemBar", UIParent, "SecureHandlerBaseTemplate")
  local F = SpyroPlayer
  TotemBar:SetPoint(unpack(Addon.Config.TotemBar.Anchor))
  TotemBar:SetSize(Addon.Config.TotemBar.TotemSize * MAX_TOTEMS, Addon.Config.TotemBar.TotemSize)
  F.Totems = {}

  for i = 1, MAX_TOTEMS do
    F.Totems[i] = CreateFrame("Button", nil, TotemBar, "SecureActionButtonTemplate")
    F.Totems[i]:SetSize(Addon.Config.TotemBar.TotemSize, Addon.Config.TotemBar.TotemSize)
    F.Totems[i]:RegisterForClicks("AnyUp")
    F.Totems[i]:SetAttribute("useOnKeyDown", false)
    F.Totems[i]:SetAttribute("type2", "destroytotem")
    F.Totems[i]:SetAttribute("totem-slot", TOTEM_PRIORITIES[i])

    F.Totems[i].Icon = F.Totems[i]:CreateTexture(nil, "OVERLAY")
    F.Totems[i].Icon:SetAllPoints()

    F.Totems[i].Cooldown = CreateFrame("Cooldown", nil, F.Totems[i], "CooldownFrameTemplate")
    F.Totems[i].Cooldown:SetAllPoints()
    F.Totems[i].Cooldown:SetDrawSwipe(false)
    F.Totems[i].Cooldown:SetDrawEdge(false)

    if i == 1 then F.Totems[i]:SetPoint("TOPLEFT", TotemBar)
    else F.Totems[i]:SetPoint("TOPLEFT", F.Totems[i-1], "TOPRIGHT", 1) end
    TotemBar[i] = F.Totems[i]
  end

  F:EnableElement("Totems")
  F.Totems:ForceUpdate()

  --[[ Rogue/Druid ]]----------------------------------------------------------------------------------------------------------------------------------
  if Lib.PLAYER_CLASS == "ROGUE" or Lib.PLAYER_CLASS == "DRUID" then -- Combo Points
    CreatePowerCharges(Anchor, ChargeSize, "COMBO_POINTS")

  --[[ Monk ]]-----------------------------------------------------------------------------------------------------------------------------------------
  elseif Lib.PLAYER_CLASS == "MONK" then
    CreatePowerCharges(Anchor, ChargeSize, "CHI", 3)

  --[[ Warlock ]]--------------------------------------------------------------------------------------------------------------------------------------
  elseif Lib.PLAYER_CLASS == "WARLOCK" and Lib.IsRetail then
    CreatePowerCharges(Anchor, ChargeSize, "SOUL_SHARDS")

  --[[ Mage ]]-----------------------------------------------------------------------------------------------------------------------------------------
  elseif Lib.PLAYER_CLASS == "MAGE" and Lib.IsRetail then
    CreatePowerCharges(Anchor, ChargeSize, "ARCANE_CHARGES", 1)
    CreatePowerCharges(Anchor, ChargeSize, 205473, 3) -- Icicles

  --[[ Paladin ]]--------------------------------------------------------------------------------------------------------------------------------------
  elseif Lib.PLAYER_CLASS == "PALADIN" and Lib.IsRetail then -- Holy Power
    local HolyPowerFrame = CreatePowerCharges(Anchor, ChargeSize, "HOLY_POWER")

    -- AuraSlot to show a custom texture (3 fake charges) on Divine Purpose procs
    local Container = CreateFrame("AuraContainer", nil, HolyPowerFrame, "CustomAuraContainerTemplate")
    Container:SetUnit("player")
    local AuraSlot = Container:AddAuraSlot("DivinePurpose", "HELPFUL|PLAYER", {
      candidateFilters = { includeSpellIDs = { [408458] = true } },

      initializeFrame = function(DivinePurpose)
        DivinePurpose:SetSize(ChargeSize, ChargeSize * 3)
        DivinePurpose:SetPoint("BOTTOMLEFT", HolyPowerFrame, "BOTTOMRIGHT", UnitPowerMax("player", Enum.PowerType.HolyPower) > 3 and -3 or 0, 0)

        for i = 1, 3 do
          DivinePurpose[i] = DivinePurpose:CreateTexture()
          DivinePurpose[i]:SetAtlas("ClassOverlay-ComboPoint")
          DivinePurpose[i]:SetSize(ChargeSize, ChargeSize)
        end

        DivinePurpose[1]:SetPoint("BOTTOM", DivinePurpose[2], "TOP")
        DivinePurpose[2]:SetPoint("BOTTOM", DivinePurpose[3], "TOP")
        DivinePurpose[3]:SetPoint("BOTTOMLEFT")
      end
    })

  --[[ Evoker ]]---------------------------------------------------------------------------------------------------------------------------------------
  elseif Lib.PLAYER_CLASS == "EVOKER" then


  --[[ DK ]]-------------------------------------------------------------------------------------------------------------------------------------------
  elseif Lib.PLAYER_CLASS == "DEATHKNIGHT" then

  end

  -- If we created a ChargesFrame, move the's PlayerFrame CC and Defensive AuraContainer to its right
  if ChargesFrame then
    SpyroPlayer.CCandDef:ClearAllPoints()
    SpyroPlayer.CCandDef:SetPoint("BOTTOMLEFT", ChargesFrame,"BOTTOMRIGHT", 0, 0)
  end
end)