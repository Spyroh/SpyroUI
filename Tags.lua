--╔════════════════════════╗
--║ ┌─┐┌─┐┬ ┬┬─┐┌─┐  ┬ ┬┬  ║
--║ └─┐├─┘└┬┘├┬┘│ │  │ ││  ║
--║ └─┘┴   ┴ ┴└─└─┘  └─┘┴  ║
--╠════════════════════════╣
--║    Custom oUF tags     ║
--╠════════════════════════╣
--║ By Spyro [Sanguino EU] ║
--╚════════════════════════╝

local _, Addon = ...
local Lib, oUF = Addon.Lib, Addon.oUF

-- [firstname]: Shows only the first name without last name in WoW Forever
oUF.Tags.Events["firstname"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["firstname"] = function(Unit)
  return UnitName(Unit)
end

-- [nameifalive]: Returns the name if the unit is alive
oUF.Tags.Events["nameifalive"] = "UNIT_NAME_UPDATE UNIT_DIED"
oUF.Tags.Methods["nameifalive"] = function(Unit)
  if not UnitIsDeadOrGhost(Unit) then
    return UnitName(Unit)
  end
end

-- [spyro:hp]: Abbreviated current HP value
oUF.Tags.Events["spyro:hp"] = "UNIT_HEALTH UNIT_MAXHEALTH"
oUF.Tags.Methods["spyro:hp"] = function(Unit)
  if not UnitIsDeadOrGhost(Unit) then
    return Lib.AbbreviateNumbers(UnitHealth(Unit))
  end
end

-- [spyro:power]: Abbreviated current Power value
oUF.Tags.Events["spyro:power"] = "UNIT_POWER_UPDATE UNIT_MAXPOWER"
oUF.Tags.Methods["spyro:power"] = function(Unit)
  if not UnitIsDeadOrGhost(Unit) and UnitIsConnected(Unit) then
    return Lib.AbbreviateNumbers(UnitPower(Unit))
  end
end

-- [spyro:level]: Returns the level of the unit colored like the DefaultUI. If it's too high to know, it shows the skull icon
oUF.Tags.Events["spyro:level"] = "UNIT_LEVEL PLAYER_LEVEL_UP"
oUF.Tags.Methods["spyro:level"] = function(Unit)
  local Level = UnitEffectiveLevel(Unit)
  if UnitIsWildBattlePet(Unit) or UnitIsBattlePetCompanion(Unit) then Level = UnitBattlePetLevel(Unit) end

  if Level > 0 then
    _FRAME.SkullLevel:Hide()

    if UnitCanAttack("player", Unit) then
      local Color = GetDifficultyColor(C_PlayerInfo.GetContentDifficultyCreatureForPlayer(Unit))
      return Hex(Color.r, Color.g, Color.b)..Level
    end

    return Hex(1.0, 0.82, 0.0)..Level
  else
    _FRAME.SkullLevel:Show()
  end
end

-- [spyro:classification]: Returns one character symbolizing the classification of the unit
oUF.Tags.Events["spyro:classification"] = "UNIT_CLASSIFICATION_CHANGED"
oUF.Tags.Methods["spyro:classification"] = function(Unit)
  local MobType = UnitClassification(Unit)
  if MobType == "worldboss" or UnitIsBossMob(Unit) then return "B" end
  if MobType == "rareelite" then return "X" end
  if MobType == "elite" then return "E" end
  if MobType == "rare" then return "R" end
end

-- [spyro:status]: Similar to the default tag but adding Unconscious state and removing resting
oUF.Tags.Events["spyro:status"] = "UNIT_HEALTH PLAYER_UPDATE_RESTING UNIT_CONNECTION PARTY_MEMBER_ENABLE PARTY_MEMBER_DISABLE"
oUF.Tags.Methods["spyro:status"] = function(Unit)
  if UnitIsUnconscious(Unit) then return "Unconscious"
  elseif UnitIsDead(Unit) then return "Dead"
  elseif UnitIsGhost(Unit) then return "Ghost"
  elseif not UnitIsConnected(Unit) then return "Offline" end
end

-- [unitcolor]: Class color for players, reaction color for NPCs (red for hostile, yellow for neutral, green for friendly)
oUF.Tags.Events["unitcolor"] = "PLAYER_TARGET_CHANGED UNIT_FACTION"
oUF.Tags.Methods["unitcolor"] = function(Unit)
  if not UnitExists(Unit) then return end
  if UnitIsPlayer(Unit) then return Hex(_COLORS.class[UnitClassBase(Unit)]) end
  return Hex(_COLORS.reaction[UnitReaction(Unit, "player")])
end