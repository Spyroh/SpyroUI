--╔════════════════════════╗
--║ ┌─┐┌─┐┬ ┬┬─┐┌─┐  ┬ ┬┬  ║
--║ └─┐├─┘└┬┘├┬┘│ │  │ ││  ║
--║ └─┘┴   ┴ ┴└─└─┘  └─┘┴  ║
--╠════════════════════════╣
--║ Focus & Focus's Target ║
--╠════════════════════════╣
--║ By Spyro [Sanguino EU] ║
--╚════════════════════════╝

--[[ Local namespace vars ]]---------------------------------------------------------------------------------------------------------------------------
local _, Addon = ... -- Shared table between all files
local oUF, Lib, Config, Style = Addon.oUF, Addon.Lib, Addon.Config, Addon.Style

--[[ Focus ]]------------------------------------------------------------------------------------------------------------------------------------------
-- Registering style
oUF:RegisterStyle("Focus", function(F)
  Style.Target(F, Config.Focus)

  -- Custom anchor for the Focus in raids, so it doesn't cover the RaidFrames
  if Config.Focus.RaidAnchor then
    local PositionDriver = CreateFrame("Frame", nil, nil, "SecureHandlerAttributeTemplate")
    Lib.SetFrameRef(PositionDriver, "Focus", F)
    Lib.SaveAnchor(PositionDriver, "NormalAnchor", Config.Focus.Anchor)
    Lib.SaveAnchor(PositionDriver, "RaidAnchor", Config.Focus.RaidAnchor)

    PositionDriver:SetAttribute("_onattributechanged", [[
      Focus:ClearAllPoints()
      if value == "RaidAnchor" or IsBattleground then Focus:SetPoint(unpack(RaidAnchor))
      else Focus:SetPoint(unpack(NormalAnchor)) end
    ]])

    local TriggerCondition = -- Arena is a raid but we don't want the raid anchor
      "[@arena5,exists][@arena4,exists][@arena3,exists][@arena2,exists][@arena1,exists]NormalAnchor;"..
      "[group:raid]RaidAnchor;"..
      "NormalAnchor"

    RegisterAttributeDriver(PositionDriver, "AnchorTrigger", TriggerCondition)

    -- We have to detect battlegrounds because flag carriers use ArenaIDs so it could be confused for a real arena enemy
    Lib.RegisterEvent("PLAYER_ENTERING_WORLD", function()
      Lib.Execute(PositionDriver, [[
        IsBattleground = %s
        self:RunAttribute("_onattributechanged", "%s")
      ]], tostring(C_PvP.IsBattleground()), SecureCmdOptionParse(TriggerCondition))
    end)
  end
end)

-- Creation
oUF:SetActiveStyle("Focus")
local Focus = oUF:Spawn("focus", "SpyroFocus")
Focus:SetPoint(unpack(Config.Focus.Anchor))

--[[ Focus's target ]]---------------------------------------------------------------------------------------------------------------------------------
-- Registering style
oUF:RegisterStyle("FocusTarget", function(F)
  F.PseudoParent = Focus
  F.PseudoParent.ToT = F
  Style.TargetTarget(F, Config.FocusTarget)
end)

-- Creation
oUF:SetActiveStyle("FocusTarget")
local ToF = oUF:Spawn("focustarget", "SpyroFocusTarget")
local Offset = ToF.Portrait:GetWidth() + 2 -- Offset needed to align the ToF's portrait inner side with the Focus's portrait outer side
ToF:SetPoint("TOP"..ToF.oSide, Focus, "BOTTOM"..ToF.iSide, ToF.oSideLeft and -Offset or Offset, 0)