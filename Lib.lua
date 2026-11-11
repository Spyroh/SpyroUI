--╔════════════════════════╗
--║ ┌─┐┌─┐┬ ┬┬─┐┌─┐  ┬ ┬┬  ║
--║ └─┐├─┘└┬┘├┬┘│ │  │ ││  ║
--║ └─┘┴   ┴ ┴└─└─┘  └─┘┴  ║
--╠════════════════════════╣
--║          Lib           ║
--╠════════════════════════╣
--║ By Spyro [Sanguino EU] ║
--╚════════════════════════╝

--╔═══════════════════════════════════════════════════════╗
--║ Library of data and functions used by several modules ║
--╚═══════════════════════════════════════════════════════╝

--[[ Upvalues ]]--------------------------------------------------------------------------------------------------------------------------------------
local _G, gsub, format, pairs, ipairs, unpack, strmatch, tinsert, tremove, Mixin, IsInRaid, IsInGroup, IsInInstance, IsActiveBattlefieldArena, CreateFrame, C_Timer, C_Spell, C_UnitAuras, C_ClassColor, GetClassColor, GetPlayerInfoByGUID, hooksecurefunc, UnitCanAttack, UnitIsFriend, InCombatLockdown, RegisterAttributeDriver, SecureHandlerWrapScript, SecureHandlerSetFrameRef, SecureHandlerExecute, C_SpecializationInfo, EventRegistry
    = _G, gsub, format, pairs, ipairs, unpack, strmatch, tinsert, tremove, Mixin, IsInRaid, IsInGroup, IsInInstance, IsActiveBattlefieldArena, CreateFrame, C_Timer, C_Spell, C_UnitAuras, C_ClassColor, GetClassColor, GetPlayerInfoByGUID, hooksecurefunc, UnitCanAttack, UnitIsFriend, InCombatLockdown, RegisterAttributeDriver, SecureHandlerWrapScript, SecureHandlerSetFrameRef, SecureHandlerExecute, C_SpecializationInfo, EventRegistry

--[[ Namespace vars ]]--------------------------------------------------------------------------------------------------------------------------------
local AddonName, Addon = ... -- Shared table between all files
SpyroUI_DB             = SpyroUI_DB or {} -- SavedVariable
Addon.DB               = SpyroUI_DB
Addon.Name             = AddonName
Addon.Folder           = "Interface/AddOns/"..AddonName
Addon.Media            = Addon.Folder.."/Media"
Addon.Config           = {} -- Configuration table, filled in Config.lua
Addon.Lib              = {} -- Table to store data and functions used by several modules
Addon.Style            = {} -- Table to store oUF styling functions that will be used in different modules
local Lib, Config, oUF = Addon.Lib, Addon.Config, Addon.oUF
Lib.PLAYER_CLASS       = UnitClassBase("player")
Lib.EmptyFunction      = function() end
Lib.IsSecretValue      = issecretvalue or function() return false end
Lib.SetPoint           = PlayerFrame.SetPoint -- To avoid triggering hooks

-- Constants to know which iteration of the game the client is running
Lib.TocVersion        = select(4, GetBuildInfo())
Lib.IsClassic         = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE
Lib.IsVanilla         = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
Lib.IsForever         = WOW_PROJECT_ID == WOW_PROJECT_CAMELOT
Lib.IsTBC             = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
Lib.IsVanillaOrTBC    = Lib.IsVanilla or Lib.IsTBC
Lib.IsWotLK           = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
Lib.IsCata            = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC
Lib.IsPreMoP          = Lib.TocVersion < 50000
Lib.IsRetail          = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
Lib.IsRetailOrForever = Lib.IsRetail or Lib.IsForever

-- List of all spec roles. Needed because GetTalentTreeRoles() returns nil in
-- Vanilla/TBC so we will query the role data from here instead of API functions
local SpecRoles = {
  DEATHKNIGHT = { "TANK"   , "DAMAGER", "DAMAGER" },
  DEMONHUNTER = { "DAMAGER", "TANK"   , "DAMAGER" },
  DRUID       = { "DAMAGER", "DAMAGER", "TANK"     , "HEALER" },
  EVOKER      = { "DAMAGER", "HEALER" , "DAMAGER" },
  HUNTER      = { "DAMAGER", "DAMAGER", "DAMAGER" },
  MAGE        = { "DAMAGER", "DAMAGER", "DAMAGER" },
  MONK        = { "TANK"   , "HEALER" , "DAMAGER" },
  PRIEST      = { "HEALER" , "HEALER" , "DAMAGER" },
  PALADIN     = { "HEALER" , "TANK"   , "DAMAGER" },
  ROGUE       = { "DAMAGER", "DAMAGER", "DAMAGER" },
  SHAMAN      = { "DAMAGER", "DAMAGER", "HEALER"  },
  WARLOCK     = { "DAMAGER", "DAMAGER", "DAMAGER" },
  WARRIOR     = { "DAMAGER", "DAMAGER", "TANK"    },
}

-- Classes with stances/forms
Lib.StanceClass = {
  DRUID   = 1,
  WARRIOR = 1,
  PALADIN = 1
}

-- Large number abbreviation options. Used in the [abbrevhp] and [abbrevpower] tags.
local AbbreviateConfig = {
  breakpointData = {
    { -- Billions: X.Xb
      breakpoint           = 1000000000,
      abbreviation         = "b",
      significandDivisor   = 100000000,
      fractionDivisor      = 10,
      abbreviationIsGlobal = false,
    },

    { -- Millions: X.Xm
      breakpoint           = 1000000,
      abbreviation         = "m",
      significandDivisor   = 100000,
      fractionDivisor      = 10,
      abbreviationIsGlobal = false,
    },

    { -- Thousands: X.Xk (for values over 9999)
      breakpoint           = 10000,
      abbreviation         = "k",
      significandDivisor   = 100, -- 1000 para dejarlo en Xk sin decimal
      fractionDivisor      = 10,  -- 1    para dejarlo en Xk sin decimal
      abbreviationIsGlobal = false,
    },
  },
}

-- WoW Forever talent data for the player's class
local ForeverTalentTreeInfo -- Will store a table with talent data
if Lib.IsForever then
  EventUtil.RegisterOnceFrameEventAndCallback("PLAYER_ENTERING_WORLD", function()
    local TreeID = C_Traits.GetConfigInfo(C_Traits.GetConfigIDBySystemID(Enum.SpecializationSystem.TalentTab)).treeIDs[1]
    ForeverTalentTreeInfo = C_Traits.GetGroupDisplayInfoByTreeID(TreeID)
  end)
end

-- Parent of hidden elements. Used in Lib.Hide()
local UI_Hider = CreateFrame("Frame", "SpyroUI_Hider", nil, "SecureFrameTemplate")
UI_Hider:Hide()
UI_Hider:SetAlpha(0)

-- CallbackRegistry to create custom events
Lib.CustomEvents = CreateFromMixins(CallbackRegistryMixin)
Lib.CustomEvents:OnLoad()
Lib.CustomEvents:SetUndefinedEventsAllowed(true)

--[[ Enums ]]------------------------------------------------------------------------------------------------------------------------------------------
Lib.Enum = {
  Aura = {
    StealableBorder  = 1,
    DebuffTypeBorder = 2,
  },

  PowerStringToNumber = {
    MANA           = Enum.PowerType.Mana,
    RAGE           = Enum.PowerType.Rage,
    FOCUS          = Enum.PowerType.Focus,
    ENERGY         = Enum.PowerType.Energy,
    RUNES          = Enum.PowerType.Runes,
    RUNIC_POWER    = Enum.PowerType.RunicPower,
    SOUL_SHARDS    = Enum.PowerType.SoulShards,
    LUNAR_POWER    = Enum.PowerType.LunarPower,
    HOLY_POWER     = Enum.PowerType.HolyPower,
    ALTERNATE      = Enum.PowerType.Alternate,
    MAELSTROM      = Enum.PowerType.Maelstrom,
    CHI            = Enum.PowerType.Chi,
    ARCANE_CHARGES = Enum.PowerType.ArcaneCharges,
    FURY           = Enum.PowerType.Fury,
    PAIN           = Enum.PowerType.Pain,
    INSANITY       = Enum.PowerType.Insanity,
    COMBO_POINTS   = Enum.PowerType.ComboPoints,
    HAPPINESS      = Enum.PowerType.Happiness
  }
}

--[[ Centralized event manager ]]----------------------------------------------------------------------------------------------------------------------
local EventManager = CreateFrame("Frame")
EventManager:SetScript("OnEvent", function(self, Event, ...)
  local FuncList = EventManager[Event]
  for i = 1, #FuncList do FuncList[i](...) end -- Calling the functions registered for this event
end)

-- RegisterEvent()
-- Makes a function to be executed on occurences of an event. Different events can be specified separated by space.
function Lib.RegisterEvent(Events, Function)
  if not Function then return end

  for Event in Events:gmatch("%S+") do
    EventManager[Event] = EventManager[Event] or {}
    local FuncList = EventManager[Event]
    local AlreadyRegistered

    for i = 1, #FuncList do
      if FuncList[i] == Function then -- This function was already registered
        AlreadyRegistered = true
        break
      end
    end

    if not AlreadyRegistered then
      tinsert(FuncList, Function)
      if #FuncList == 1 then EventManager:RegisterEvent(Event) end -- First function added, registering event
    end
  end
end

-- UnregisterEvent()
-- Removes a function that was registered to be executed on occurences of an event.
function Lib.UnregisterEvent(Event, Function)
  if not Function then return end
  local FuncList = EventManager[Event]
  if not FuncList or #FuncList == 0 then return end

  -- Removing the function from this event
  for i = 1, #FuncList do
    if FuncList[i] == Function then
      RunNextFrame(function() -- In the next frame so we don't touch the table that is being used by the EventManager this frame
        tremove(FuncList, i)
        if #FuncList == 0 then EventManager:UnregisterEvent(Event) end -- No functions on this event so we can unregister it
      end)
      break
    end
  end
end

--[[ Centralized StateDriver ]]-----------------------------------------------------------------------------------------------------------------------
Lib.StateDriver = CreateFrame("Frame", nil, nil, "SecureHandlerStateTemplate")
Lib.StateDriver.Counter = 0

-- Method to create a new state
function Lib.StateDriver:Register(Condition, Function)
  self.Counter = self.Counter + 1
  self:SetAttribute("_onstate-StateDriver"..self.Counter, Function)
  RegisterStateDriver(self, "StateDriver"..self.Counter, Condition)
end

--[[ System to run functions delayed (in the next frame or when out of combat ]]----------------------------------------------------------------------
local DelayedRun = CreateFrame("Frame")
DelayedRun:Hide()
DelayedRun.QueueNextFrame = {}
DelayedRun.QueueOutOfCombat = {}

-- Queue manager
function DelayedRun.QueueManager(Type, Queue, Function, ...)
  if Type == "ADD" then
    local i             = #Queue + 1
    Queue[i]            = {}
    Queue[i].Function   = Function
    Queue[i].Parameters = {...}

  elseif Type == "RUN" then
    for i = 1, #Queue do
      --if not Queue[i] then print("Queue", i, "is nil") end
      Queue[i].Function(unpack(Queue[i].Parameters))
      Queue[i].Parameters = nil
      Queue[i] = nil
    end
  end
end

-- Next frame queue execution
DelayedRun:SetScript("OnUpdate", function(self)
  self.QueueManager("RUN", self.QueueNextFrame)
  self:Hide() -- Disabling OnUpdate
end)

-- Out of combat queue execution
DelayedRun:SetScript("OnEvent", function(self)
  self:UnregisterEvent("PLAYER_REGEN_ENABLED")
  self.QueueManager("RUN", self.QueueOutOfCombat)
end)

-- Function to queue functions to be executed in the next frame
function Lib.RunNextFrame(Function, ...)
  DelayedRun.QueueManager("ADD", DelayedRun.QueueNextFrame, Function, ...)
  DelayedRun:Show() -- Enabling OnUpdate to run one time in the next frame
end

-- Function to queue functions to be executed when the player gets out of combat
function Lib.RunOutOfCombat(Function, ...)
  DelayedRun.QueueManager("ADD", DelayedRun.QueueOutOfCombat, Function, ...)
  if InCombatLockdown() then DelayedRun:RegisterEvent("PLAYER_REGEN_ENABLED") -- Out of combat event
  else DelayedRun:GetScript("OnEvent")(DelayedRun) end -- If we are already out of combat, run the queue
end

--[[ LibEditModeOverride ]]---------------------------------------------------------------------------------------------------------------------------
Lib.EditModeOverride = LibStub("LibEditModeOverride-1.0")
Lib.RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED", function() Lib.EditModeOverride:LoadLayouts() end)

--[[ General functions ]]-----------------------------------------------------------------------------------------------------------------------------
-- RegisterEvents()
-- Registers multiple events in an oUF frame. Different events can be specified separated by space. They don't trigger if the frame is not visible.
function Lib.RegisterEvents(oUF_Frame, Events, Function, IsUnitless)
  for Event in Events:gmatch("%S+") do
    oUF_Frame:RegisterEvent(Event, Function, IsUnitless)
  end
end

-- MatchAND()
-- Does a String:match() AND operation with a variable number of patterns.
function Lib.MatchAND(String, ...)
  for _, Pattern in ipairs({...}) do
    if not String:match(Pattern) then
      return false
    end
  end

  return true
end

-- MatchOR()
-- Does a String:match() OR operation with a variable number of patterns.
function Lib.MatchOR(String, ...)
  for _, Pattern in ipairs({...}) do
    if String:match(Pattern) then
      return true
    end
  end

  return false
end

-- M()
-- Takes strings like "ArenaEnemyFrame[1-3]" and returns references to the frames ArenaEnemyFrame1, ArenaEnemyFrame2, ArenaEnemyFrame3.
-- Very useful when you need to do a bunch a references to default UI frames.
function Lib.M(...)
  local Return  = {}
  local Pattern = "%[%d+%-%d+%]"

  for _, Frames in ipairs({...}) do
    local Range = strmatch(Frames, Pattern)
    if Range then
      local LowerLimit, UpperLimit = strmatch(Range, "(%d+)%-(%d+)")
      for i = LowerLimit, UpperLimit do
        local FrameName = gsub(Frames, Pattern, i)
        if not _G[FrameName] then print("The frame", FrameName, "doesn't exist.") end
        Return[#Return+1] = _G[FrameName]
      end
    end
  end

  return unpack(Return)
end

-- Msg()
-- Shows messages in the chat window.
function Lib.Msg(Text, ...)
  print("|cFFFFFF00[SpyroUI]|r", format(Text, ...))
end

-- Print()
-- print() with format options.
function Lib.Print(Text, ...)
  print(format(Text, ...))
end

-- Hide()
-- Hides elements.
function Lib.Hide(...)
  for _, Element in pairs({...}) do
    Element.isShownExternal = nil
    Element:SetAlpha(0)
    Element:SetParent(UI_Hider)

    if Element.HideBase then Element:HideBase()
    else Element:Hide() end

    if Element:IsObjectType("Texture") then Element:SetTexture(nil)
    elseif Element:IsObjectType("MaskTexture") then Element:SetTexture(nil)
    elseif Element:IsObjectType("StatusBar") then Element:SetStatusBarTexture("")
    elseif Element:IsObjectType("FontString") then Element:SetText("")
    elseif Element:IsObjectType("Frame") then Element:SetAttribute("statehidden", true) end
  end
end

-- HideAndUnregister()
-- Hides frames and unregisters all their events.
function Lib.HideAndUnregister(...)
  for _, Frame in pairs({...}) do
    Frame.isShownExternal = nil
    Frame:SetAlpha(0)
    Frame:SetParent(UI_Hider)
    Frame:UnregisterAllEvents()
    Frame:SetAttribute("statehidden", true)

    if Frame.HideBase then Frame:HideBase()
    else Frame:Hide() end
  end
end

-- BoolToNumber()
-- Returns secret 1/0 from secret true/false
function Lib.BoolToNumber(SecretBool)
  _Texture:SetAlphaFromBoolean(SecretBool, 1, 0)
  return _Texture:GetAlpha()
end

-- EventRegistry_RegisterEvent()
-- Makes a function to be executed on occurences of an event using Blizzard's EventRegistry.
function Lib.EventRegistry_RegisterEvent(Event, Function)
  EventRegistry:RegisterFrameEventAndCallback(Event, function(Owner, ...)
    Function(...) -- Don't pass the owner to the callback
  end, Function) -- Using the function itself as owner
end

-- EventRegistry_UnregisterEvent()
-- Removes a function that was registered to be executed on occurences of an event using Blizzard's EventRegistry.
function Lib.EventRegistry_UnregisterEvent(Event, Owner)
  EventRegistry:UnregisterFrameEventAndCallback(Event, Owner)
end

-- RegisterOnceEvent()
-- Makes a function to be executed on the first occurence of an event.
function Lib.RegisterOnceEvent(Event, Function)
  EventUtil.RegisterOnceFrameEventAndCallback(Event, Function)
end

-- RegisterUnitEvent()
-- Makes a function to be executed on occurences of events for certain units. Different events can be specified separated by space.
function Lib.RegisterUnitEvent(Events, Units, Function)
  local EventList = {} -- Table with the events
  for Event in Events:gmatch("%S+") do
    EventList[Event] = true -- Indexed by event name
  end

  local U = strsplittable(" ", Units) -- Table with the units
  local i = 1

  while U[i] do
    local Frame = CreateFrame("Frame") -- One frame for each 4 units since that's the cap

    Frame:SetScript("OnEvent", function(self, EventName, ...)
      if EventList[EventName] then Function(...) end
    end)

    for Event, _ in pairs(EventList) do -- Registering the events for these units
      Frame:RegisterUnitEvent(Event, U[i], U[i+1], U[i+2], U[i+3])
    end

    i = i + 4
  end
end

-- FrameRegisterEvent()
-- Makes a function to be executed on occurences of an event.
function Lib.FrameRegisterEvent(Frame, Event, Function)
  Frame:HookScript("OnEvent", function(self, EventName, ...)
    if EventName == Event then Function(...) end
  end)

  Frame:RegisterEvent(Event)
end

-- FrameRegisterUnitEvent()
-- Makes a function to be executed on occurences of an event for certain units (up to 4).
function Lib.FrameRegisterUnitEvent(Frame, Event, Units, Function)
  Frame:HookScript("OnEvent", function(self, EventName, ...)
    if EventName == Event then Function(...) end
  end)

  Frame:RegisterUnitEvent(Event, strsplit(" ", Units))
end

-- Execute()
-- Executes CodeSnippet in the restricted environment owned by the widget.
function Lib.Execute(Widget, CodeSnippet, ...)
  SecureHandlerExecute(Widget, format(CodeSnippet, ...))
end

-- SetAttribute()
-- Sets an attribute on the frame.
function Lib.SetAttribute(Widget, Attribute, CodeSnippet, ...)
  Widget:SetAttribute(Attribute, format(CodeSnippet, ...))
end

-- WrapScript()
-- Wraps a widget script with code snippets that execute in the RestrictedEnvironment.
function Lib.WrapScript(Frame, Script, Header, CodeSnippet, ...)
  SecureHandlerWrapScript(Frame, Script, Header, [[ return true, true ]], format(CodeSnippet, ...))
end

-- WrapAllScripts()
-- Wraps all the widget scripts that don't require interaction by the user with code snippets that execute in the RestrictedEnvironment.
function Lib.WrapAllScripts(Frame, Header, CodeSnippet, ...)
  for _, Script in ipairs({ "OnShow", "OnHide", "OnAttributeChanged" }) do
    Lib.WrapScript(Frame, Script, Header, CodeSnippet, ...)
  end
end

-- MakeMovable()
-- Makes a frame movable.
function Lib.MakeMovable(...)
  for _, F in ipairs({...}) do
    if F then
      F:EnableMouse(true)
      F:SetMovable(true)
      F:SetClampedToScreen(true)
      F:RegisterForDrag("LeftButton")
      F:SetScript("OnDragStart", F.StartMoving)
      F:SetScript("OnDragStop", F.StopMovingOrSizing)
      F:SetUserPlaced(true)
    else
      print("MakeMovable(): Inexistent frame.")
    end
  end
end

-- GetUnitClass()
-- Returns the non-localized class of an unitID or unitframe.
function Lib.GetUnitClass(Element)
  return UnitClassBase(Element.IsObjectType and Element:IsObjectType("Frame") and (Element.displayedUnit or Element.unit or Element:GetAttribute("unit")) or Element)
end

-- SetShadow()
-- Enables or disables the shadow of a FontString.
function Lib.SetShadow(String, Enable)
  if Enable then
    String:SetShadowColor(0, 0, 0, 1)
    String:SetShadowOffset(1, -1)
  else
    String:SetShadowColor(0, 0, 0, 0)
    String:SetShadowOffset(0, 0)
  end
end

-- SetPortrait()
-- Setups portraits for players (class icon) or NPC's.
function Lib.SetPortrait(Portrait, UnitID)
  if UnitIsPlayer(UnitID) then -- If it's a player, put his class icon
    local UNIT_CLASS = Lib.GetUnitClass(UnitID)
    if UNIT_CLASS then Lib.SetClassIcon(Portrait, UNIT_CLASS) end -- Sometimes GetUnitClass() returns nil for party units
  else -- Not a player, using default TexCoord for NPC portraits
    Portrait:SetTexCoord(0, 1, 0, 1)
  end 
end

-- SetFrameRef()
-- Creates a variable with a reference to a frame in the restricted environment owned by the widget.
function Lib.SetFrameRef(Widget, Name, Frame)
  SecureHandlerSetFrameRef(Widget, Name, Frame)
  Lib.Execute(Widget, [[ %s = self:GetFrameRef("%s") ]], Name, Name)
end

-- AbbreviateNumbers()
-- Abbreviates big numbers.
function Lib.AbbreviateNumbers(Number)
  return AbbreviateNumbers(Number, AbbreviateConfig)
end

-- RunAfterEditMode()
-- Runs a function when OOC after the EditMode loads a layout or is closed.
function Lib.RunAfterEditMode(Function, RunNow)
  local Func = function() Lib.RunNextFrame(Lib.RunOutOfCombat, Function) end
  EventRegistry:RegisterCallback("EditMode.Enter", Func)
  EventRegistry:RegisterCallback("EditMode.Exit", Func)
  --hooksecurefunc(C_EditMode, "OnEditModeExit", Func)
  hooksecurefunc(C_EditMode, "SetActiveLayout", Func)
  Lib.RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED", Func)
  Lib.RegisterEvent("PLAYER_PVP_TALENT_UPDATE", function() C_Timer.After(0.5, Func) end)
  Lib.RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED", function() C_Timer.After(0.5, Func) end)
  if RunNow then Func() end
end

-- EditModeAnchor()
-- Anchors an element and restores the anchor after EditMode interactions or profile changes.
function Lib.EditModeAnchor(Element, Point, RelativeTo, RelativePoint, OffsetX, OffsetY)
  Lib.RunAfterEditMode(function()
    Element:ClearAllPoints()
    Element:SetPoint(Point, RelativeTo, RelativePoint, OffsetX, OffsetY)
  end, true)

  if Lib.EditModeOverride:AreLayoutsLoaded() then
    if Lib.EditModeOverride:HasEditModeSettings(Element) and Lib.EditModeOverride:CanEditActiveLayout() then
      Lib.EditModeOverride:ReanchorFrame(Element, Point, RelativeTo, RelativePoint, OffsetX, OffsetY)
      Lib.EditModeOverride:ApplyChanges()

      Lib.RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED", function()
        Lib.EditModeOverride:ReanchorFrame(Element, Point, RelativeTo, RelativePoint, OffsetX, OffsetY)
        Lib.EditModeOverride:ApplyChanges()
      end)
    end
  else
    Lib.RegisterOnceEvent("EDIT_MODE_LAYOUTS_UPDATED", function()
      Lib.EditModeOverride:LoadLayouts()

      if Lib.EditModeOverride:HasEditModeSettings(Element) and Lib.EditModeOverride:CanEditActiveLayout() then
        Lib.EditModeOverride:ReanchorFrame(Element, Point, RelativeTo, RelativePoint, OffsetX, OffsetY)
        Lib.EditModeOverride:ApplyChanges()

        Lib.RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED", function()
          Lib.EditModeOverride:ReanchorFrame(Element, Point, RelativeTo, RelativePoint, OffsetX, OffsetY)
          Lib.EditModeOverride:ApplyChanges()
        end)
      end
    end)
  end
end

-- EditModeSetting()
-- Alters an EditMode setting and maintains it between profile changes.
function Lib.EditModeFrameSetting(Frame, Setting, Value)
  Lib.RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED", function()
    if Lib.EditModeOverride:CanEditActiveLayout() then
      Lib.EditModeOverride:SetFrameSetting(Frame, Setting, Value)
      Lib.EditModeOverride:ApplyChanges()
    end
  end)

  if Lib.EditModeOverride:AreLayoutsLoaded() and Lib.EditModeOverride:CanEditActiveLayout() then
    Lib.EditModeOverride:SetFrameSetting(Frame, Setting, Value)
    Lib.EditModeOverride:ApplyChanges()
  end
end

-- SaveAnchor()
-- Saves an anchor point data in a table in the Restricted Environment owned by the widget.
-- ▪ Widget:    Widget
-- ▪ TableName: Table's name inside the restricted environment
-- ▪ Anchor:    Table with the anchor data
local AnchorFrameCounter = 0
function Lib.SaveAnchor(Widget, TableName, Anchor)
  local A = Anchor
  local RelativeFrame = type(A[2]) == "string" and _G[A[2]] or A[2] -- Can be a string (frame's name) or direct reference
  local NameRef = RelativeFrame:GetName()

  if not NameRef then 
    AnchorFrameCounter = AnchorFrameCounter + 1
    NameRef = "AnchorFrame"..AnchorFrameCounter
  end

  SecureHandlerSetFrameRef(Widget, NameRef, RelativeFrame) -- Setting a reference to the frame inside the Restricted Environment
  Lib.Execute(Widget, [[ %s = newtable("%s", self:GetFrameRef("%s"), "%s", %d, %d) ]], TableName, A[1], NameRef, A[3], A[4], A[5])
end

-- CropIconBorders()
-- Crop the borders of an icon to make it look square.
function Lib.CropIconBorders(Icon)
  Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
end

-- CreateEventFrame()
-- Returns a frame ready to respond to events with its methods that are named as the events.
function Lib.CreateEventFrame()
  local EventFrame = CreateFrame("Frame")
  EventFrame:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)
  return EventFrame
end

-- CreateLine()
-- Creates a line of a given thickness and color and returns it.
function Lib.CreateLine(Parent, Layer, SubLevel, Thickness, Red, Green, Blue, Alpha)
  local Line = Parent:CreateLine(nil, Layer, nil, SubLevel)
  Line:SetThickness(Thickness or 1)
  Line:SetColorTexture(Red or 0, Green or 0, Blue or 0, Alpha or 1)
  return Line
end

-- CreateTexture()
-- Creates a texture and returns it.
function Lib.CreateTexture(Parent, Path, Layer, SubLevel)
  local Texture = Parent:CreateTexture(nil, Layer, nil, SubLevel)
  Texture:SetTexture(Path)
  return Texture
end

-- CreateFlatTexture()
-- Creates a flat texture of a given color an returns it.
function Lib.CreateFlatTexture(Parent, Layer, SubLevel, Red, Green, Blue, Alpha)
  local Texture = Parent:CreateTexture(nil, Layer, nil, SubLevel)
  Texture:SetColorTexture(Red or 0, Green or 0, Blue or 0, Alpha or 1)
  return Texture
end

-- CreateFlatBackdrop()
-- Creates a border around a frame using its backdrop.
function Lib.CreateFlatBackdrop(Frame, Thickness, R, G, B)
  if not Frame.SetBackdrop then Mixin(Frame, BackdropTemplateMixin) end
  Frame:SetBackdrop({ edgeFile = "Interface/Buttons/WHITE8x8", edgeSize = Thickness or 1 })
  Frame:SetBackdropColor(R or 0, G or 0, B or 0, 1)
  Frame:SetBackdropBorderColor(R or 0, G or 0, B or 0, 1)
  Frame.TopLeftCorner:SetDrawLayer("OVERLAY", 6)
  Frame.TopEdge:SetDrawLayer("OVERLAY", 6)
  Frame.TopRightCorner:SetDrawLayer("OVERLAY", 6)
  Frame.RightEdge:SetDrawLayer("OVERLAY", 6)
  Frame.BottomRightCorner:SetDrawLayer("OVERLAY", 6)
  Frame.BottomEdge:SetDrawLayer("OVERLAY", 6)
  Frame.BottomLeftCorner:SetDrawLayer("OVERLAY", 6)
  Frame.LeftEdge:SetDrawLayer("OVERLAY", 6)
end

-- CreateExternalBackdrop()
-- Creates a extra backdrop on a frame using a children frame.
function Lib.CreateExternalBackdrop(Parent, EdgeTexture, Thickness)
  local B, Thickness = CreateFrame("Frame", nil, Parent, BackdropTemplateMixin and "BackdropTemplate"), Thickness or 1
  B:SetFrameLevel(Parent:GetFrameLevel())
  B:SetPoint("TOPLEFT", Parent, "TOPLEFT", -Thickness, Thickness)
  B:SetPoint("BOTTOMRIGHT", Parent, "BOTTOMRIGHT", Thickness, -Thickness)
  B:SetBackdrop({ edgeFile = EdgeTexture, edgeSize = Thickness })
  return B
end

-- GetInstanceType()
-- Returns the type of instance the player is in (false if he isn't in any).
function Lib.GetInstanceType()
  local InInstance, InstanceType = IsInInstance()
  return InInstance and InstanceType
end

-- GetGroupType()
-- Returns the type of group where the player is.
function Lib.GetGroupType()
  return IsInRaid() and "raid" or IsInGroup() and "party"
end

-- GetClassColor()
-- Returns the color of a class in the 3 components (Red, Green, Blue).
function Lib.GetClassColor(Class)
  if Lib.IsVanilla and Class == "SHAMAN" then
    return 0, 0.44, 0.87 -- Blue class color for Shamans in Vanilla
  end

  if C_ClassColor then
    local Color = C_ClassColor.GetClassColor(Class)
    return Color.r, Color.g, Color.b
  end

  local R, G, B = GetClassColor(Class)
  return R, G, B
end

-- GetClassColorFromGUID()
-- Returns the color of a class in the 3 components (Red, Green, Blue).
function Lib.GetClassColorFromGUID(GUID)
  local _,Class = GetPlayerInfoByGUID(GUID)
  local R, G, B, Hex = GetClassColor(Class)
  return R, G, B
end

-- GetUnitColor()
-- Returns de color of an unit: Class color for players, reaction color for NPCs.
function Lib.GetUnitColor(UnitID)
  if UnitIsPlayer(UnitID) then
    return oUF.colors.class[UnitClassBase(UnitID)]:GetRGB()
  else
    return oUF.colors.reaction[UnitReaction(UnitID, "player")]:GetRGB()
  end
end

-- GetPrimaryTalentTree()
-- Returns the talent tree with the most points spent in Vanilla/TBC.
-- This API function exists in those iterations of the game but it doesn't work (always returns 1).
function Lib.GetPrimaryTalentTree()
  local MainTree = 5 -- Default value for low level chars with no points spent (similar to Retail's low level spec)
  local MostPointsSeen = 0

  for Tree = 1, Lib.GetNumSpecs() do
    local _,_,_,_,_,_,PointsSpent = C_SpecializationInfo.GetSpecializationInfo(Tree, nil, nil, nil, nil, C_SpecializationInfo.GetActiveSpecGroup())

    if PointsSpent > MostPointsSeen then
      MainTree = Tree
      MostPointsSeen = PointsSpent
    end
  end

  return MainTree
end

-- GetPrimaryTalentTree_Forever()
-- Returns the talent tree with the most points spent in WoW Forever.
function Lib.GetPrimaryTalentTree_Forever()
  local MainTree = 5 -- Default value for low level chars with no points spent (similar to Retail's low level spec)
  local MostPointsSeen = 0
  local groupIDs = {}
  local groupIndices = {}

  for _, displayInfo in ipairs(ForeverTalentTreeInfo) do
    table.insert(groupIDs, displayInfo.groupID);
    groupIndices[displayInfo.groupID] = displayInfo.orderIndex + 1
  end

  for _, groupCurrencyInfo in ipairs(C_Traits.GetGroupCurrencyInfo(C_Traits.GetConfigIDBySystemID(Enum.SpecializationSystem.TalentTab), groupIDs)) do
    local PointsSpent = groupCurrencyInfo.currencyInfos[1].spent

    if PointsSpent > MostPointsSeen then
      MainTree = groupIndices[groupCurrencyInfo.traitNodeGroupID]
      MostPointsSeen = PointsSpent
    end
  end

  return MainTree
end

-- GetNumSpecs()
-- Returns the total numbers of specializations.
function Lib.GetNumSpecs()
  if IsForever then return #ForeverTalentTreeInfo
  elseif IsPreMoP then return GetNumTalentTabs()
  else return GetNumSpecializations() end
end

-- GetSpecIndex()
-- Returns the current class specialization index.
function Lib.GetSpecIndex()
  local SpecIndex

  if IsForever then SpecIndex = Lib.GetPrimaryTalentTree_Forever()
  elseif IsPreMoP then SpecIndex = Lib.GetPrimaryTalentTree()
  else SpecIndex = C_SpecializationInfo.GetSpecialization() end

  return SpecIndex ~= 5 and SpecIndex or nil
end

-- GetSpecName()
-- Returns the name of a specialization.
local function GetSpecName(SpecIndex)
  if IsForever then
    return ForeverTalentTreeInfo[SpecIndex].displayName
  else
    local _,Name = C_SpecializationInfo.GetSpecializationInfo(SpecIndex)
    return Name
  end
end

-- GetSpecRole()
-- Returns the role a specialization is intended to perform.
function Lib.GetSpecRole(SpecIndex) -- local GetSpecRole = IsPreMoP and GetTalentTreeRoles or GetSpecializationRole
  return SpecRoles[Lib.PLAYER_CLASS][SpecIndex]
end

-- IsPlayerHealer()
-- Returns if the player has a healing spec active.
function Lib.IsPlayerHealer()
  local SpecIndex = Lib.GetSpecIndex()
  return SpecIndex and Lib.GetSpecRole(SpecIndex) == "HEALER"
end

-- CanPlayerHeal()
-- Returns if the player can heal even without a healer spec active.
function Lib.CanPlayerHeal()
  return Lib.PLAYER_CLASS == "DRUID"   or Lib.PLAYER_CLASS == "EVOKER" or Lib.PLAYER_CLASS == "MONK"
      or Lib.PLAYER_CLASS == "PALADIN" or Lib.PLAYER_CLASS == "PRIEST" or Lib.PLAYER_CLASS == "SHAMAN"
end

-- InArena()
-- Returns if the player is in an arena match.
function Lib.InArena()
  return Lib.GetInstanceType() == "arena" or IsActiveBattlefieldArena()
end

-- SetClassIcon()
-- Puts a class icon in a texture using the HQ class icons.
function Lib.SetClassIcon(Texture, Class)
  Texture:SetAtlas("ClassIcon-"..Class)
end

-- ClearAndSetPoint()
-- Removes all anchor points and sets a new one. Optionally accepts a table with the anchor data.
function Lib.ClearAndSetPoint(Element, Point, RelativeTo, RelativePoint, OffsetX, OffsetY)
  Element:ClearAllPoints()

  if type(Point) == "table" then Element:SetPoint(unpack(Point))
  else Element:SetPoint(Point, RelativeTo, RelativePoint, OffsetX, OffsetY) end
end

-- SetPosition()
-- Moves an UI element, optionally trying to disable its repositioning from Blizzard code.
-- ▪ Element: Element to move
-- ▪ Anchor:  Table with the anchor data
-- ▪ Force:   Bool to specify if we should try to force the position (in case that it's moved again by Blizzard's code)
function Lib.SetPosition(Element, Anchor, Force)
  -- If no anchor specified, force the actual position. This need to be done in the next frame so the GetPoint() data is updated
  if not Anchor then
    Lib.RunNextFrame(function() Lib.SetPosition(Element, { Element:GetPoint() }, Force) end)
    return
  end

  -- Trying to make Blizzard code ignore this frame
  if Element:IsObjectType("Frame") then
    Element:SetMovable(true)
    Element:SetUserPlaced(true)
    Element:SetDontSavePosition(true)
  end

  -- Frames that can be moved directly
  if not InCombatLockdown() or InCombatLockdown() and not Element:IsProtected() then
    Element:ClearAllPoints()
    Lib.SetPoint(Element, unpack(Anchor))
  end

  -- Protected frames
  local IsProtected, IsExplicitlyProtected = Element:IsProtected()
  if IsProtected then
    if InCombatLockdown() then
      Lib.RunOutOfCombat(function()
        Element:ClearAllPoints()
        Lib.SetPoint(Element, unpack(Anchor))
      end)
    end

    -- Trying to force the position in case that is moved by Blizzard's code
    if Force then
      -- Out of combat trigger
      hooksecurefunc(Element, "SetPoint", function()
        Lib.RunOutOfCombat(function()
          Element:ClearAllPoints()
          Lib.SetPoint(Element, unpack(Anchor))
        end)
      end)

      Lib.RunAfterEditMode(function()
        Element:ClearAllPoints()
        Lib.SetPoint(Element, unpack(Anchor))
      end)

      -- It's possible to move explicitly protected frames in combat from the Restricted Environment by using the widget script handlers supported
      -- by SecureHandlerWrapScript() as triggers, but the RelativeFrame that the frame anchors to also needs to be explicitly protected
      local RelativeFrameIsProtected, RelativeFrameIsExplicitlyProtected = Anchor[2]:IsProtected()
      if Element:IsObjectType("Frame") and IsExplicitlyProtected and RelativeFrameIsExplicitlyProtected then
        Lib.SaveAnchor(Element, "FixedAnchor", Anchor)
        Element:SetAttribute("PositionFrame", [[ self:ClearAllPoints(); self:SetPoint(unpack(FixedAnchor)) ]])
        Lib.WrapAllScripts(Element, Element, [[ self:RunAttribute("PositionFrame") ]])

        -- If it's an UnitFrame, create triggers in an AttributeDriver
        local Unit = Element:GetAttribute("unit")
        if Unit then
          local Repositioner = CreateFrame("Frame", nil, nil, "SecureHandlerAttributeTemplate")
          Lib.SetFrameRef(Repositioner, "Element", Element)
          Repositioner:SetAttribute("_onattributechanged", [[ Element:RunAttribute("PositionFrame") ]])
          RegisterAttributeDriver(Repositioner, "ManualTrigger", "[mod:shift,mod:alt]1; 0")

          if Unit ~= "player" then
            RegisterAttributeDriver(Repositioner, "ExistTrigger", format("[@%s,exists]%sExists; %sNoExists", Unit, Unit, Unit))
            RegisterAttributeDriver(Repositioner, "DeadTrigger", format("[@%s,dead]%sDead; %sNoDead", Unit, Unit, Unit))
          end
        end
      end
    end

  -- Unprotected frames
  elseif Force then
    hooksecurefunc(Element, "SetPoint", function()
      Element:ClearAllPoints()
      Lib.SetPoint(Element, unpack(Anchor))
    end)
  end

  if Element:IsObjectType("Frame") then Element:SetMovable(false) end
end

-- CopyTexture()
-- Copies a texture and returns the copy.
-- ▪ Texture to copy.
-- ▪ Parent of the copy.
function Lib.CopyTexture(Texture, Parent)
  local T = Parent:CreateTexture()
  T:SetAlpha(Texture:GetAlpha())
  T:SetTexture(Texture:GetTexture())
  T:SetDrawLayer(Texture:GetDrawLayer())
  T:SetVertexColor(Texture:GetVertexColor())
  T:SetColorTexture(Texture:GetColorTexture())
  return T
end

-- ShowOnMouseOver()
-- Makes a frame be visible only on mouseover.
function Lib.ShowOnMouseOver(Frame)
  Frame:SetAlpha(0)
  local Ticker

  local function CheckMouseOver()
    if Frame:IsMouseOver() then return end
    Frame:SetAlpha(0)
    Ticker:Cancel()
  end

  local function OnEnter()
    if Frame:GetAlpha() == 1 then return end
    Frame:SetAlpha(1)
    Ticker = C_Timer.NewTicker(0.2, CheckMouseOver)
  end

  for _, F in ipairs({ Frame, Frame:GetChildren() }) do
    F:HookScript("OnEnter", OnEnter)
  end
end

-- Lib.ConfigureAuraButton()
-- Configures a Blizzard's AuraButton.
function Lib.ConfigureAuraButton(B, Options) --function Lib.ConfigureAuraButton(B, Size, Border, ShowSwipe, ShowCountdown, ShowPandemic)
  if Options.Size then B:SetSize(Options.Size, Options.Size) end

  -- Icon
  B.Icon = B:CreateTexture(nil, "ARTWORK")
  B.Icon:SetAllPoints(B)
  B:SetIcon(B.Icon)

  -- Cooldown
  B.Cooldown = B.Cooldown or CreateFrame("Cooldown", nil, B, "CooldownFrameTemplate")
  B.Cooldown:SetPoint("CENTER", 0, -1)
  B.Cooldown:SetReverse(true)
  B.Cooldown:SetDrawEdge(false)
  B.Cooldown:SetDrawBling(false)
  B.Cooldown:SetDrawSwipe(true)
  B.Cooldown:SetHideCountdownNumbers(true)
  if Options.ShowSwipe ~= nil then
    B.Cooldown:SetDrawSwipe(Options.ShowSwipe)
    if not Options.ShowSwipe then B.Cooldown:SetHideCountdownNumbers(false) end -- If not swipe, show countdown
  end
  if Options.ShowCountdown ~= nil then B.Cooldown:SetHideCountdownNumbers(not Options.ShowCountdown) end
  B:SetDurationCooldown(B.Cooldown)

  -- Stacks
  B.Count = B:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
  B.Count:SetJustifyH("RIGHT")
  B.Count:SetPoint("BOTTOMRIGHT", B, "BOTTOMRIGHT", 0, 0)
  if Options.CountSize then B.Count:SetFont("Fonts/ARIALN.TTF", Options.CountSize, "OUTLINE") end
  B:SetApplicationCount(B.Count)

  -- Stealable border
  if Options.Border == Lib.Enum.Aura.StealableBorder then
    B.Stealable = B:CreateTexture(nil, "OVERLAY")
    B.Stealable:SetPoint("TOPLEFT", -3, 4)
    B.Stealable:SetPoint("BOTTOMRIGHT", 3, -3)
    B.Stealable:SetTexture("Interface/TargetingFrame/UI-TargetingFrame-Stealable")
    B.Stealable:SetBlendMode("ADD")
    B:AddDispelTypeTexture(B.Stealable, {
      style = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset,
      showWhenHelpful = true,
      --stealableFilter = Enum.CustomAuraButtonDispelTypeStealableFilter.Stealable,
      customDispelColorMap = { ["Magic"] = CreateColor(1, 1, 1) }
    })

  -- DispelType border
  elseif Options.Border == Lib.Enum.Aura.DebuffTypeBorder then
    B.Border = B:CreateTexture(nil, "OVERLAY")
    B.Border:SetTexture("Interface/Buttons/UI-Debuff-Overlays")
    B.Border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
    B.Border:SetPoint("TOPLEFT", -1, 0)
    B.Border:SetPoint("BOTTOMRIGHT", 0, 0)
    B:AddDispelTypeTexture(B.Border, {
      style = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset,
      showWhenHarmful = true,
      showWithoutDispelType = true
    })

    -- Making the icon 1px smaller to account for the border
    B.Icon:ClearAllPoints()
    B.Icon:SetPoint("TOPLEFT", B, "TOPLEFT", 1, -1)
    B.Icon:SetPoint("BOTTOMRIGHT", B, "BOTTOMRIGHT", -1, 1)
  end

  -- Pandemic border
  if Options.ShowPandemic then
    B.Pandemic = B:CreateTexture(nil, "OVERLAY")
    B.Pandemic:SetPoint("TOPLEFT", -3, 3)
    B.Pandemic:SetPoint("BOTTOMRIGHT", 3, -3)
    B.Pandemic:SetTexture("Interface/TargetingFrame/UI-TargetingFrame-Stealable")
    B.Pandemic:SetBlendMode("ADD")
    B.Pandemic:SetVertexColor(1, 0, 0)
    B:AddPandemicRegion(B.Pandemic)
  end
end