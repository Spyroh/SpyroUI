--╔════════════════════════╗
--║ ┌─┐┌─┐┬ ┬┬─┐┌─┐  ┬ ┬┬  ║
--║ └─┐├─┘└┬┘├┬┘│ │  │ ││  ║
--║ └─┘┴   ┴ ┴└─└─┘  └─┘┴  ║
--╠════════════════════════╣
--║     Pet Action Bar     ║
--╠════════════════════════╣
--║ By Spyro [Sanguino EU] ║
--╚════════════════════════╝

local _, Addon = ... -- Shared table between all files
local Config, Lib = Addon.Config.PetBar, Addon.Lib
Lib.HideAndUnregister(PetActionBar)

--[[ Creating bar ]]------------------------------------------------------------------------------------------------------------------------------------
local PetBar = CreateFrame("Frame", "SpyroPetBar", UIParent, "SecureHandlerStateTemplate")
PetBar:SetSize(Config.ButtonSize * 10, Config.ButtonSize)
PetBar.DroppableTypes = { petaction = 1 } -- Used in Lib.ActionBar_HideEmptyButtons()
RegisterStateDriver(PetBar, "visibility", "[pet,@vehicle,noexists] show; hide") -- Only visible when we have a pet

local BG = PetBar:CreateTexture()
--BG:SetAllPoints()
BG:SetColorTexture(1, 0, 0)

function PetBar.HasAction(ButtonIndex) -- Used in Lib.ActionBar_HideEmptyButtons() / Lib.ActionBar_AutoCenter()
  return PetBar[ButtonIndex]:HasAction()
end

function PetBar:UpdateButtons()
  for i = 1, 10 do
    self[i]:Update()
  end
end

function PetBar:UpdateButtonsCooldowns()
  for i = 1, 10 do
    self[i]:UpdateCooldown()
  end
end

PetBar:RegisterEvent("PLAYER_ENTERING_WORLD")
PetBar:RegisterEvent("PLAYER_CONTROL_LOST")
PetBar:RegisterEvent("PLAYER_CONTROL_GAINED")
PetBar:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED")
PetBar:RegisterEvent("PLAYER_TARGET_CHANGED")
PetBar:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
PetBar:RegisterEvent("PET_BAR_UPDATE")
PetBar:RegisterEvent("PET_UI_UPDATE")
PetBar:RegisterEvent("PET_BAR_UPDATE_USABLE")
PetBar:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
PetBar:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")
PetBar:RegisterUnitEvent("UNIT_PET", "player")
PetBar:RegisterUnitEvent("UNIT_FLAGS", "pet")
PetBar:RegisterUnitEvent("UNIT_AURA", "pet")

PetBar:SetScript("OnEvent", function(self, Event)
  if Event == "PET_BAR_UPDATE_COOLDOWN" then self:UpdateButtonsCooldowns()
  else self:UpdateButtons() end
end)

--[[ Creating buttons ]]--------------------------------------------------------------------------------------------------------------------------------
for i = 1, 10 do
  PetBar[i] = CreateFrame("CheckButton", "SpyroPetActionButton"..i, PetBar, "PetActionButtonTemplate", i)
  PetBar[i]:SetSize(Config.ButtonSize, Config.ButtonSize)

  if i == 1 then PetBar[i]:SetPoint("TOPLEFT")
  else PetBar[i]:SetPoint("LEFT", PetBar[i-1], "RIGHT") end
  local Button = PetBar[i]

  Button.action = i
  Button.index = i

  function Button:Update()
    local name, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i)
 
    self.tooltipName = isToken and _G[name] or name -- Tooltip
    self:SetChecked(isActive) -- Active ability

    -- Icon
    self.icon:SetShown(texture ~= nil)
    self.icon:SetTexture(isToken and _G[texture] or texture)

    -- Autocast visuals
    self.AutoCastOverlay:SetShown(autoCastAllowed)
    self.AutoCastOverlay:ShowAutoCastEnabled(autoCastEnabled)

    -- Ability usability
    if texture then
      if GetPetActionSlotUsable(i) then self.icon:SetVertexColor(1, 1, 1)
      else self.icon:SetVertexColor(0.4, 0.4, 0.4) end
    end
  end

  function Button:UpdateCooldown()
    local start, duration, enabled = GetPetActionCooldown(i)
    CooldownFrame_Set(self.cooldown, start, duration, enabled)
  end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------

PetBar:UpdateButtons()
PetBar:UpdateButtonsCooldowns()
if Config.HideEmpty then Lib.ActionBar_HideEmptyButtons(PetBar, Config) end
if Config.AutoCenter then Lib.ActionBar_AutoCenter(PetBar, Config.Anchor[5])
else PetBar:SetPoint(unpack(Config.Anchor)) end