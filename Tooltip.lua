--╔════════════════════════╗
--║ ┌─┐┌─┐┬ ┬┬─┐┌─┐  ┬ ┬┬  ║
--║ └─┐├─┘└┬┘├┬┘│ │  │ ││  ║
--║ └─┘┴   ┴ ┴└─└─┘  └─┘┴  ║
--╠════════════════════════╣
--║        Tooltip         ║
--╠════════════════════════╣
--║ By Spyro [Sanguino EU] ║
--╚════════════════════════╝

-- Showing icons of items in tooltips
local TipIcon = CreateFrame("Frame", nil, ItemRefTooltip)
TipIcon:SetSize(36, 36)
TipIcon:SetPoint("TOPRIGHT", ItemRefTooltip, "TOPLEFT", 0, -1)
TipIcon.Texture = TipIcon:CreateTexture(nil, "BACKGROUND")
TipIcon.Texture:SetAllPoints(TipIcon)
TipIcon.Texture:SetTexture(134400) -- "Interface/Icons/INV_Misc_QuestionMark"

-- Frame whose OnUpdate attempts to show uncached icons
TipIcon.Updater = CreateFrame("Frame", nil, TipIcon)
TipIcon.Updater:Hide()
TipIcon.Updater:SetScript("OnUpdate", function(self, Elapsed)
  self.Timer = self.Timer + Elapsed
  if self.Timer < 0.2 then return end
  self:Hide()
  TipIcon.SetIcon(self.IconType, self.IconID)
end)

TipIcon.SetIcon = function(IconType, IconID)
  local Texture

  if IconType == "item" then Texture = select(10, C_Item.GetItemInfo(IconID)) or ""
  elseif IconType == "spell" then Texture = C_Spell.GetSpellTexture(IconID) or ""
  elseif IconType == "achievement" then Texture = select(10, GetAchievementInfo(IconID)) or "" end

  if Texture then -- If this is an item, spell or achievement
    if strlenutf8(Texture) > 0 then -- And texture is an actual path
      TipIcon.Texture:SetTexture(Texture)
    else
      TipIcon.Updater.IconType = IconType -- Otherwise note Type and ID
      TipIcon.Updater.IconID = IconID
      TipIcon.Texture:SetTexture(nil) -- Clear its texture for now
      TipIcon.Updater.Timer = 0
      TipIcon.Updater:Show() -- And check again in 0.2 seconds
    end
    TipIcon:Show()
  else
    TipIcon:Hide()
  end
end

hooksecurefunc("SetItemRef", function(Link)
  local IconType, IconID = Link:match("\124?H?(%w+):(%d+)")
  TipIcon.Updater:Hide() -- Just in case ItemRefTooltip was closed while waiting for an icon to cache
  TipIcon.SetIcon(IconType, IconID)
end)

-- Class color in tooltips
if TooltipDataProcessor then -- Retail
  --[[
  TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(Tooltip)
    if Tooltip ~= GameTooltip then return end
    local _,UnitID = Tooltip:GetUnit()
    if not UnitID or not UnitIsPlayer("mouseover") then return end

    Tooltip.TextLeft1:SetText(Color:WrapTextInColorCode(TooltipData.lines[1].leftText))
  end)
  ]]

  TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(Tooltip)
    if Tooltip ~= GameTooltip then return end
    local TooltipData = Tooltip:GetTooltipData()
    local Class

    if not issecretvalue(TooltipData.guid) and strsplit("-", TooltipData.guid) == "Player" then
      _,Class = UnitClassFromGUID(TooltipData.guid)
    elseif UnitIsPlayer("mouseover") then
      Class = UnitClassBase("mouseover")
    end

    if Class then
      local Color = C_ClassColor.GetClassColor(Class)
      Tooltip.TextLeft1:SetText(Color:WrapTextInColorCode(TooltipData.lines[1].leftText))
    end
  end)
else -- Classic
  GameTooltip:HookScript("OnTooltipSetUnit", function(self)
    if self ~= GameTooltip then return end
    local _,UnitID = self:GetUnit()
    if not UnitIsPlayer(UnitID) then return end
    local R, G, B = Lib.GetClassColor(UnitClassBase(UnitID))
    local Text = GameTooltipTextLeft1:GetText()
    GameTooltipTextLeft1:SetFormattedText("|cff%02x%02x%02x%s|r", R*255, G*255, B*255, Text:match("|cff\x\x\x\x\x\x(.+)|r") or Text)
  end)
end