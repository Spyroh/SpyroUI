--╔════════════════════════╗
--║ ┌─┐┌─┐┬ ┬┬─┐┌─┐  ┬ ┬┬  ║
--║ └─┐├─┘└┬┘├┬┘│ │  │ ││  ║
--║ └─┘┴   ┴ ┴└─└─┘  └─┘┴  ║
--╠════════════════════════╣
--║        Minimap         ║
--╠════════════════════════╣
--║ By Spyro [Sanguino EU] ║
--╚════════════════════════╝

local _, Addon = ... -- Shared table between all files
local Lib, Config = Addon.Lib, Addon.Config.Minimap
function GetMinimapShape() return "SQUARE" end -- Letting LibDBIcon know the shape of the Minimap

-- Event PLAYER_ENTERING_WORLD
-- Fires after a loading screen. Run only one time.
Lib.RegisterOnceEvent("PLAYER_ENTERING_WORLD", function()
  --[[ Minimap ]]--------------------------------------------------------------------------------------------------------------------------------------
  -- Hiding unused stuff
  Lib.Hide(
    AddonCompartmentFrame,
    MinimapCompassTexture,
    MinimapBackdrop,
    Minimap.ZoomIn,
    Minimap.ZoomOut,
    MinimapCluster.BorderTop,
    MinimapCluster.DielFrame,
    MinimapCluster.MinimapContainer.PlayerCoords
  )

  -- Header
  Minimap.Header = CreateFrame("Frame", "Minimap.Header", Minimap)
  Minimap.Header:SetFrameStrata("LOW")
  Minimap.Header:SetFrameLevel(2)
  Minimap.Header:SetSize(Minimap:GetWidth(), Config.Font[2] + 6)
  Minimap.Header.Background = Lib.CreateFlatTexture(Minimap.Header, "BACKGROUND", 0)
  Minimap.Header.Background:SetAllPoints()
  Minimap.Header.Background:SetColorTexture(0.2, 0.2, 0.2)
  Minimap.Header:SetPoint("TOPRIGHT", MinimapCluster, "TOPRIGHT", 0, 0)
  Lib.CreateFlatBackdrop(Minimap.Header, 1)

  -- Body
  if BackdropTemplateMixin then Mixin(Minimap, BackdropTemplateMixin) end
  Minimap:SetFrameStrata("LOW")
  Minimap:SetFrameLevel(3)
  Minimap:SetSize(Config.Size, Config.Size)
  Minimap:ClearAllPoints()
  Minimap:SetPoint("TOPRIGHT", Minimap.Header, "BOTTOMRIGHT", 0, 1)
  Minimap:SetHitRectInsets(0, 0, 0, 0)
  Minimap:SetMaskTexture("Interface/Buttons/WHITE8x8") -- Square shape
  Minimap:SetBackdrop({ edgeFile = "Interface/Buttons/WHITE8x8", edgeSize = 1 }) -- 1px border
  Minimap:SetBackdropBorderColor(0, 0, 0, 1)

  -- Footer
  Minimap.Footer = CreateFrame("Frame", "Minimap.Footer", Minimap)
  Minimap.Footer:SetFrameStrata("LOW")
  Minimap.Footer:SetFrameLevel(2)
  Minimap.Footer:SetSize(Minimap.Header:GetSize())
  Minimap.Footer.Background = Lib.CreateFlatTexture(Minimap.Footer, "BACKGROUND", 0)
  Minimap.Footer.Background:SetAllPoints()
  Minimap.Footer.Background:SetColorTexture(0.2, 0.2, 0.2)
  Minimap.Footer:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, 1)
  Lib.CreateFlatBackdrop(Minimap.Footer, 1)

  -- Cluster
  local SetSize = PlayerFrame.SetSize
  local ClusterWidth, ClusterHeight = Minimap:GetWidth(), Minimap.Header:GetHeight() + Minimap:GetHeight() + Minimap.Footer:GetHeight() - 2
  MinimapCluster:SetFrameStrata("LOW")
  MinimapCluster:SetFrameLevel(2)
  MinimapCluster:ClearAllPoints()
  MinimapCluster:SetHitRectInsets(0, 0, 0, 0)
  MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0)
  MinimapCluster:SetSize(ClusterWidth, ClusterHeight)
  MinimapCluster.MinimapContainer:ClearAllPoints()
  MinimapCluster.MinimapContainer:SetAllPoints(MinimapCluster)
  hooksecurefunc(MinimapCluster, "SetSize", function() SetSize(MinimapCluster, ClusterWidth, ClusterHeight) end)

  -- Zone button
  if MinimapCluster.ZoneTextButton.StateTexture then MinimapCluster.ZoneTextButton.StateTexture:Hide() end
  MinimapCluster.ZoneTextButton:ClearAllPoints()
  MinimapCluster.ZoneTextButton:SetAllPoints(Minimap.Header)

  -- Zone text
  MinimapZoneText:SetParent(Minimap.Header)
  MinimapZoneText:SetDrawLayer("BORDER", 0)
  MinimapZoneText:SetWidth(Config.Size - 2)
  MinimapZoneText:SetJustifyH("CENTER")
  MinimapZoneText:ClearAllPoints()
  MinimapZoneText:SetPoint("CENTER", Minimap.Header)
  MinimapZoneText:SetFont(unpack(Config.Font))

  -- Clock
  TimeManagerFrame:ClearAllPoints()
  TimeManagerFrame:SetPoint("TOPRIGHT", MinimapCluster, "BOTTOMRIGHT", 0, 0)
  TimeManagerClockButton:ClearAllPoints()
  TimeManagerClockButton:SetPoint("CENTER", Minimap.Footer, "CENTER", 0, 0)
  TimeManagerClockTicker:ClearAllPoints()
  TimeManagerClockTicker:SetPoint("CENTER")
  TimeManagerClockTicker:SetFont(unpack(Config.Font))
  TimeManagerAlarmFiredTexture:ClearAllPoints()
  TimeManagerAlarmFiredTexture:SetPoint("TOPLEFT", TimeManagerClockTicker, "TOPLEFT", -14, 6)
  TimeManagerAlarmFiredTexture:SetPoint("BOTTOMRIGHT", TimeManagerClockTicker, "BOTTOMRIGHT", 9, -8)

  -- Mouse clicks
  Minimap:SetScript("OnMouseUp", function(self, Button)
    if Button == "LeftButton" then Minimap.OnClick(self) -- Ping
    elseif Button == "RightButton" then ToggleCalendar() -- Calendar
    elseif Button == "MiddleButton" then ToggleWorldMap() end -- Map
  end)

  --[[ Hub Button. Unfolds the addon's minimap buttons when clicked ]]---------------------------------------------------------------------------------
  local AddonButtonTray = CreateFrame("Frame", nil, Minimap) -- Parent
  local MinimapHubButton = LibStub("LibDataBroker-1.1"):NewDataObject("MinimapHubButton", {
    type = "launcher",
    text = "MinimapHubButton",
    icon = "Interface/Icons/Trade_Engineering",
    OnClick = function() AddonButtonTray:SetShown(not AddonButtonTray:IsShown()) end
  })
  AddonButtonTray:Hide()
  Addon.DB.MinimapHubButton = Addon.DB.MinimapHubButton or {}
  LibStub("LibDBIcon-1.0"):Register("MinimapHubButton", MinimapHubButton, Addon.DB.MinimapHubButton)

  -- Capturing addon buttons
  Config.ButtonHubIgnore["LibDBIcon10_MinimapHubButton"] = true -- The hub button must not collect itself
  local NextButtonAnchor = LibDBIcon10_MinimapHubButton
  for _, Button in ipairs({ Minimap:GetChildren() }) do
    if Button.icon and not Config.ButtonHubIgnore[Button:GetName()] then
      Button:ClearAllPoints()
      Button:SetParent(AddonButtonTray)
      Button:SetIgnoreParentScale(false)
      Button:SetScale(1)
      Button:SetPoint("RIGHT", NextButtonAnchor, "LEFT", 0, 0)
      NextButtonAnchor = Button

      -- Preventing button from moving
      Button:SetScript("OnDragStart", nil)
      Button:SetScript("OnDragStop", nil)
      Button.ClearAllPoints = Lib.EmptyFunction
      Button.SetScale = Lib.EmptyFunction
      Button.SetPoint = Lib.EmptyFunction
      Button.SetParent = Lib.EmptyFunction
    end
  end

  --[[ System for mouseover buttons, only visible when the Minimap or its buttons get mouseovered ]]---------------------------------------------------
  local MouseOver = CreateFrame("Frame", nil, Minimap) -- Parent for the buttons
  MouseOver:SetAlpha(0)

  -- Default buttons affected by the mouseover
  for _, F in ipairs({ GameTimeFrame, MinimapCluster.Tracking, MinimapCluster.Tracking.Button }) do
    F:SetParent(MouseOver)
  end

  -- Function to check if the mouseover must remain shown or be hidden
  function MouseOver.Check()
    for i = 1, #MouseOver.TriggerFrames do
      if MouseOver.TriggerFrames[i]:IsMouseOver() and MouseOver.TriggerFrames[i]:IsVisible() or AddonButtonTray:IsVisible() then return end
    end
    MouseOver:SetAlpha(0) -- We left all the mouseover enabling regions, hiding the parent
    MouseOver.Ticker:Cancel() -- No need to check anymore
  end

  -- Function that will be executed on the OnEnter script of frames that trigger the mouseover
  function MouseOver.OnEnter()
    if MouseOver:GetAlpha() == 1 then return end
    MouseOver:SetAlpha(1)
    MouseOver.Ticker = C_Timer.NewTicker(0.2, MouseOver.Check) -- Setting a timer to check when to hide
  end

  -- Adding to a table all the frames that should trigger the mouseover
  MouseOver.TriggerFrames = { MinimapCluster, Minimap, GameTimeFrame, MinimapCluster.Tracking, MinimapCluster.Tracking.Button }
  for _, Button in ipairs({ Minimap:GetChildren() }) do
    if Button.icon then
      tinsert(MouseOver.TriggerFrames, Button)

      -- Adding to mouseover the buttons that won't be collected for the button hub and not in the mouseover ignore list
      if Config.ButtonHubIgnore[Button:GetName()] and not Config.MouseOverIgnore[Button:GetName()] then
        Button:SetParent(MouseOver)
      end
    end
  end

  -- Setting the OnEnter script on the frames
  for i = 1, #MouseOver.TriggerFrames do
    MouseOver.TriggerFrames[i]:HookScript("OnEnter", MouseOver.OnEnter)
  end

  -----------------------------------------------------------------------------------------------------------------------------------------------------

  -- Mail icon
  MiniMapMailIcon:ClearAllPoints()
  MiniMapMailIcon:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 1, 0)

  -- Tracking button
  MinimapCluster.Tracking:ClearAllPoints()
  MinimapCluster.Tracking:SetPoint("BOTTOMLEFT", Minimap.Footer)
  MinimapCluster.Tracking:SetSize(Minimap.Footer:GetHeight(), Minimap.Footer:GetHeight())
  MinimapCluster.Tracking.Button:SetSize(Minimap.Footer:GetHeight(), Minimap.Footer:GetHeight())

  -- Calendar button
  GameTimeFrame:SetSize(Minimap.Footer:GetHeight(), Minimap.Footer:GetHeight())
  GameTimeFrame:ClearAllPoints()
  GameTimeFrame:SetPoint("BOTTOMRIGHT", Minimap.Footer, "BOTTOMRIGHT", 2, -1)
  hooksecurefunc(GameTimeCalendarInvitesTexture, "Show", function() GameTimeFrame:SetAlpha(1) end) -- Show if we get an invite

  -- Garrisson button
  if GarrisonLandingPageMinimapButton then
    Lib.SetPosition(GarrisonLandingPageMinimapButton, { "TOP", GameTimeFrame, "BOTTOM", 0, 6 }, true)
    GarrisonLandingPageMinimapButton:SetParent(MouseOver)
    GarrisonLandingPageMinimapButton:HookScript("OnEnter", MouseOver.OnEnter)
    tinsert(MouseOver.TriggerFrames, GarrisonLandingPageMinimapButton)
  end
end)