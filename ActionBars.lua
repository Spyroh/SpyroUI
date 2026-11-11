--╔════════════════════════╗
--║ ┌─┐┌─┐┬ ┬┬─┐┌─┐  ┬ ┬┬  ║
--║ └─┐├─┘└┬┘├┬┘│ │  │ ││  ║
--║ └─┘┴   ┴ ┴└─└─┘  └─┘┴  ║
--╠════════════════════════╣
--║      Action Bars       ║
--╠════════════════════════╣
--║ By Spyro [Sanguino EU] ║
--╚════════════════════════╝

--[[ Upvalues ]]---------------------------------------------------------------------------------------------------------------------------------------
local _G, ipairs, strmatch, UIParent
    = _G, ipairs, strmatch, UIParent

--[[ Local namespace vars ]]---------------------------------------------------------------------------------------------------------------------------
local _, Addon        = ... -- Shared table between all files
local Lib, Config     = Addon.Lib, Addon.Config
local CurrentActionID = 1 -- Current Action Slot ID available for the creation of an ActionButton
local MaxActionID     = Lib.IsVanillaOrTBC and 108 or 120 -- Max Action Slot ID available for creation of ActionButtons
local ButtonCounter   = 0
local SetVertexColor  = UIParent:CreateTexture().SetVertexColor -- To not trigger SetVertexColor hooks

--[[ General functions ]]------------------------------------------------------------------------------------------------------------------------------
-- ActionBar_HideEmptyButtons()
-- Shows empty buttons only when the mouse is dragging something that can be dropped in them.
-- > Bar: Reference to the bar.
-- > C: Configuration table.
function Lib.ActionBar_HideEmptyButtons(Bar, C)
  local function CURSOR_CHANGED(IsDefault, NewCursorType, OldCursorType, OldCursorVirtualID)
    --print("CURSOR_CHANGED:", IsDefault, NewCursorType, OldCursorType, GetCursorInfo())
    if NewCursorType ~= 0 or OldCursorType ~= 0 then
      local Droppable = Bar.DroppableTypes[GetCursorInfo()]
      for _, Button in ipairs({ Bar:GetChildren() }) do
        Button:SetShown(Bar.HasAction(Button.action) or Droppable)
      end
    end
  end

  Lib.RegisterEvent("CURSOR_CHANGED", function(...) Lib.RunNextFrame(Lib.RunOutOfCombat, CURSOR_CHANGED, ...) end)
  Lib.RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED", function() Lib.RunNextFrame(Lib.RunOutOfCombat, CURSOR_CHANGED, true, 1) end)
  Lib.RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", function() Lib.RunNextFrame(Lib.RunOutOfCombat, CURSOR_CHANGED, true, 1) end)
  Lib.RegisterUnitEvent("UNIT_PET", "player", function() Lib.RunOutOfCombat(CURSOR_CHANGED, true, 1) end)
end

-- ActionBar_AutoCenter()
-- Centers the bar based on its contents (medium point between the 2 most distant used buttons in the bar).
function Lib.ActionBar_AutoCenter(Bar, OffsetY)
  local CenterNextFrame -- Will store a reference to the Ticker
  Bar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, OffsetY)

  local function AutoCenterBar()
    local Nearest  = 10000
    local Farthest = 0

    for _, Button in ipairs({ Bar:GetChildren() }) do
      if Bar.HasAction(Button.action) then
        local Distance = Button:GetCenter()
        if Distance < Nearest  then Nearest  = Distance end
        if Distance > Farthest then Farthest = Distance end
      end
    end

    if Nearest ~= 10000 then -- Bar has buttons being used
      local ActiveButtonsCenter = Nearest + (Farthest - Nearest)/2
      local ScreenCenter = UIParent:GetCenter() * UIParent:GetEffectiveScale() / Bar:GetEffectiveScale()
      local _,_,_,CurrentOffsetX = Bar:GetPoint()
      Bar:SetPoint("BOTTOM", UIParent, "BOTTOM", CurrentOffsetX + ScreenCenter - ActiveButtonsCenter, OffsetY)
    end
  end

  -- The autocenter can only be executed out of combat
  local function DoAutoCenterBar()
    Lib.RunOutOfCombat(AutoCenterBar)
  end

  -- Event to cancel the autocenter before it happens when swapping entities from buttons because
  -- we only want to do it when we have finished moving stuff (when the mouse is freed)
  Lib.RegisterEvent("ACTIONBAR_SLOT_CHANGED", function(SlotID)
    if GetCursorInfo() and CenterNextFrame then
      CenterNextFrame:Cancel()
    end
  end)

  -- Event to autocenter when modifying the contents of the bar
  Lib.RegisterEvent("CURSOR_CHANGED", function(IsDefault, NewCursorType, OldCursorType, OldCursorVirtualID)
    if IsDefault and OldCursorType ~= 0 then
      CenterNextFrame = C_Timer.NewTicker(0, DoAutoCenterBar, 1) -- Executes the autocenter in the next frame
    end
  end)

  Lib.RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED", DoAutoCenterBar) -- Spec change

  -- Initial autocenter
  Lib.RegisterOnceEvent("PLAYER_ENTERING_WORLD", function()
    DoAutoCenterBar()
    C_Timer.After(4, DoAutoCenterBar)
  end)
end

-- CreateActionButton()
-- Creates an actionbutton and returns it.
-- A concrete Action Slot ID for the button can be specified, otherwise the one used will be CurrentActionID.
local function CreateActionButton(ActionSlotID)
  ButtonCounter = ButtonCounter + 1

  local B = CreateFrame("CheckButton", "SpyroActionButton"..ButtonCounter, UIParent, "ActionBarButtonTemplate")
  B:SetAttribute("type", "action")
  B:SetAttribute("action", ActionSlotID or CurrentActionID)
  if not ActionSlotID then CurrentActionID = CurrentActionID + 1 end -- Incrementing coz it has been used for this button

  -- Cooldowns
  B.chargeCooldown:SetHideCountdownNumbers(true)
  B.cooldown:SetHideCountdownNumbers(false)
  B.cooldown:SetDrawSwipe(false)
  B.cooldown:SetDrawBling(false)
  B.cooldown:SetCountdownAbbrevThreshold(99)
  B.lossOfControlCooldown:SetAlpha(0)
  B.enableLOCCooldown = nil

  -- Aesthetic changes
  B.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93) -- Icon
  B.Border:SetTexture("") -- No inner green glow for buttons with equipped items
  hooksecurefunc(B.NormalTexture, "SetVertexColor", function(self) SetVertexColor(self, 1, 1, 1, 1) end) -- Opaque border

  -- Hiding HotKey/range circle
  if B.TextOverlayContainer then B.TextOverlayContainer.HotKey:SetAlpha(0)
  else _G[B:GetName().."HotKey"]:SetAlpha(0) end

  -- Making macro names only visible on mouse over
  B:HookScript("OnEnter", function(self) self.Name:Show() end)
  B:HookScript("OnLeave", function(self) self.Name:Hide() end)
  B.Name:Hide()

  return B
end

-- CreateActionBar()
-- Creates an ActionBar and returns it.
local function CreateActionBar(C)
  local ActionID = C.StartActionID
  local CountPerRow = 0
  local ButtonSize = ActionButton1:GetWidth()
  local Bar = CreateFrame("Frame", C.Name, UIParent, "SecureHandlerStateTemplate")
  Bar:SetScale(C.Scale)
  Bar.DroppableTypes = { spell = 1, item = 1, macro = 1, mount = 1, petaction = 1, battlepet = 1, flyout = 1, companion = 1, outfit = 1 }
  Bar.HasAction = C_ActionBar.HasAction -- Used in Lib.ActionBar_HideEmptyButtons() / Lib.ActionBar_AutoCenter()
  Bar.Button = {} -- To store the buttons

  -- In Forever we will use a -1 horizontal offset on each column except the first one, so we have to account for that in the bar's width
  Bar:SetWidth(Lib.IsForever and ButtonSize * C.Columns - C.Columns + 1 or ButtonSize * C.Columns)

  -- In Forever we will use a +1 vertical offset on each column except the first one, so we have to account for that in the bar's height
  Bar:SetHeight(Lib.IsForever and ButtonSize * C.Rows - C.Rows + 1 or ButtonSize * C.Rows)

  -- Populating with buttons
  for i = 1, C.Rows * C.Columns do
    Bar.Button[i] = CreateActionButton(ActionID)
    Bar.Button[i]:SetParent(Bar)
    if ActionID then ActionID = ActionID + 1 end

    -- Custom button settings
    if C.ChargesSize then Bar.Button[i].Count:SetFont("Fonts/ARIALN.TTF", C.ChargesSize, "OUTLINE") end
    if C.ShowSwipe ~= nil then Bar.Button[i].cooldown:SetDrawSwipe(C.ShowSwipe) end
    if C.ShowCountdown ~= nil then Bar.Button[i].cooldown:SetHideCountdownNumbers(not C.ShowCountdown) end
    if C.ShowCountdownOnCharges ~= nil then Bar.Button[i].chargeCooldown:SetHideCountdownNumbers(not C.ShowCountdownOnCharges) end

    if i == 1 then -- First button of the bar
      Bar.Button[i]:SetPoint("TOPLEFT")
    elseif CountPerRow == C.Columns then -- Row finished, this button it's the first in the next row
      Bar.Button[i]:SetPoint("TOP", Bar.Button[i-C.Columns], "BOTTOM", 0, Lib.IsForever and 1 or 0)
      CountPerRow = 0 -- Resetting counter of the buttons added in the row
    else -- Next button in a row
      Bar.Button[i]:SetPoint("LEFT", Bar.Button[i-1], "RIGHT", Lib.IsForever and -1 or 0, 0)
    end

    if C.HideEmpty then Bar.Button[i]:SetShown(Bar.HasAction(Bar.Button[i].action)) end -- Initial visibility 
    CountPerRow = CountPerRow + 1
  end

  if C.ShowOnMouseOver then Lib.ShowOnMouseOver(Bar) end
  if C.HideEmpty then Lib.ActionBar_HideEmptyButtons(Bar, C) end
  if C.Visibility then RegisterStateDriver(Bar, "visibility", C.Visibility) end -- Visibility condition

  if C.HideOOC then -- Option to hide out of combat
    RegisterStateDriver(Bar, "visibility", "[combat] show; hide")
    Lib.RegisterEvent("PLAYER_REGEN_ENABLED", function() RegisterStateDriver(Bar, "visibility", "[combat] show; hide") end)

    -- Show it when something can be dropped on it when out of combat
    Lib.RegisterEvent("CURSOR_CHANGED", function(IsDefault, NewCursorType, OldCursorType, OldCursorVirtualID)
      if InCombatLockdown() then return end

      if (NewCursorType ~= 0 or OldCursorType ~= 0) and Bar.DroppableTypes[GetCursorInfo()] then
        UnregisterStateDriver(Bar, "visibility")
        Bar:Show()
      else
        RegisterStateDriver(Bar, "visibility", "[combat] show; hide")
      end
    end)
  end

  -- Position
  if C.AutoCenter then Lib.ActionBar_AutoCenter(Bar, C.Anchor[5])
  else Bar:SetPoint(unpack(C.Anchor)) end

  return Bar
end

--[[ Hiding unused stuff ]]----------------------------------------------------------------------------------------------------------------------------
MainActionBar:SetScale(0.0001)
MainActionBar:SetSize(1, 1)
MainActionBar:SetClampedToScreen(false)
MainActionBar:ClearAllPoints()
MainActionBar.enableDividers = nil
MainActionBar.VerticalDividersPool:ReleaseAll()
MainActionBar.HorizontalDividersPool:ReleaseAll()

Lib.Hide(
  MainActionBar.EndCaps,
  MainActionBar.BorderArt,
  MainActionBar.ActionBarPageNumber,
  MultiCastActionBarFrame,
  StatusTrackingBarManager,
  Lib.M("MainActionBarButtonContainer[1-12]")
)

Lib.HideAndUnregister(
  MultiBar5,
  MultiBar6,
  MultiBar7,
  MultiBarLeft,
  MultiBarRight,
  MultiBarBottomLeft,
  MultiBarBottomRight,
  StanceBar,
  PossessActionBar,
  Lib.M("ActionButton[1-12]"),
  Lib.M("MultiBar5Button[1-12]"),
  Lib.M("MultiBar6Button[1-12]"),
  Lib.M("MultiBar7Button[1-12]"),
  Lib.M("MultiBarLeftButton[1-12]"),
  Lib.M("MultiBarRightButton[1-12]"),
  Lib.M("MultiBarBottomLeftButton[1-12]"),
  Lib.M("MultiBarBottomRightButton[1-12]")
)

--[[ Custom bars ]]------------------------------------------------------------------------------------------------------------------------------------
for _, BarConfig in ipairs(Config.ActionBars) do
  CreateActionBar(BarConfig)
end

--[[ Events ]]-----------------------------------------------------------------------------------------------------------------------------------------
-- Event PLAYER_ENTERING_WORLD
-- Fires after a loading screen.
Lib.RegisterOnceEvent("PLAYER_ENTERING_WORLD", function()
  Lib.EditModeAnchor(MainActionBar, "TOP", UIParent, "BOTTOM", 0, -1000)

  -- Extra buttons
  Lib.EditModeAnchor(ExtraActionBarFrame, "BOTTOM", UIParent, "BOTTOM", 0, 150)
  Lib.EditModeAnchor(MainMenuBarVehicleLeaveButton, "BOTTOM", UIParent, "BOTTOM", 0, 154)

  -- ItemRack's buttons modification
  if C_AddOns.IsAddOnLoaded("ItemRack") then
    local i = 1
    while _G["ItemRackButton"..i] do
      _G["ItemRackButton"..i].icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
      i = i + 1
    end

    hooksecurefunc("CreateFrame", function(_, Name)
      if Name and strmatch(Name, "^ItemRackButton%d$") then
        _G[Name].icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
      end
    end)
  end
end)