--╔════════════════════════╗
--║ ┌─┐┌─┐┬ ┬┬─┐┌─┐  ┬ ┬┬  ║
--║ └─┐├─┘└┬┘├┬┘│ │  │ ││  ║
--║ └─┘┴   ┴ ┴└─└─┘  └─┘┴  ║
--╠════════════════════════╣
--║   Configuration file   ║
--╠════════════════════════╣
--║ By Spyro [Sanguino EU] ║
--╚════════════════════════╝
local _, Addon = ...
local Lib, Config = Addon.Lib, Addon.Config

--[[ Target ]]-----------------------------------------------------------------------------------------------------------------------------------------
Config.Target = {
  Anchor = { "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 511, 532 },
  PartyOffset = { -- Different vertical offsets for the anchor, depending on party size
    [1] = 532, -- Solo or Raids
    [2] = 532, -- Party of 2 players
    [3] = 532, -- Party of 3 players
    [4] = 362, -- Party of 4 players
    [5] = 362, -- Party of 5 players
  },

  Portrait = "RIGHT",
  BarWidth = 147,

  Name = {
    MaxWidth = 147 - 5, -- When it will truncate
    Font = { Addon.Media.."/Prototype.ttf", 13, "OUTLINE" },
    Anchor = { "CENTER", "NameBar" },
    Justify = "CENTER",
    Color = "AUTO", -- AUTO (class color for players, reaction colors for NPCs) or a specific color in a table
  },

  NameBar = {
    Height = 22,
    Color = { 0.33, 0.36, 0.37 }, -- Can be AUTO
    Texture = Addon.Media.."/MinimalistBar",
  },

  HealthBar = {
    Height  = 12,
    Texture = Addon.Media.."/MinimalistBar",
    Color = { 0, 1, 0 }, -- Can be AUTO
    BackgroundColor = { 0.12, 0.12, 0.12 },
    PredictionTexture = "Interface/RaidFrame/Raid-bar-HP-fill", -- Interface/TargetingFrame/UI-StatusBar
  },

  HealthValue = {
    Anchor = { "CENTER", "Health" },
    Font = { Addon.Media.."/Prototype.ttf", 13, "OUTLINE" },
    Justify = "CENTER",
  },

  PowerBar = {
    Height = 12,
    Texture = Addon.Media.."/MinimalistBar",
    BackgroundColor = { 0.12, 0.12, 0.12 },
  },

  PowerValue = {
    Anchor = { "CENTER", "Power" },
    Font = { Addon.Media.."/Prototype.ttf", 13, "OUTLINE" },
    Justify = "CENTER",
  },

  Status = {
    Anchor = { "CENTER", "Power" },
    Font = { Addon.Media.."/Prototype.ttf", 13, "OUTLINE" },
    Justify = "CENTER",
  },

  Level = {
    Anchor = { "BOTTOMRIGHT", "Portrait", 3, -2 },
    Font = { Addon.Media.."/Prototype.ttf", 12, "OUTLINE" },
    Justify = "RIGHT",
    SkullSize = { 11, 14 }, -- Widht/Height for the texture that will be shown if the level is too high to know it
    SkullAnchor = { "BOTTOMRIGHT", "Portrait" },
  },

  RoleIcon = {
    Anchor = { "CENTER", "Portrait", "TOPLEFT" },
    Size = 13,
  },

  CombatIndicator = {
    Anchor = { "RIGHT", "Power", 2, 0 },
    Font = { Addon.Media.."/Prototype.ttf", 13, "OUTLINE" },
    Justify = "RIGHT",
    Color = { 1, 0, 0 },
  },

  Threat = {
    Style = "OUTSIDE",
  },

  Auras = {
    xPadding   =  3, -- Space between auras
    yPadding   =  3, -- Space between aura rows
    PlayerSize = 28, -- Size of the auras casted by the player
    NormalSize = 22, -- Size of the rest of the auras
  },

  Castbar = {
    Height = 20,
    Width = 238,
    SpellMaxWidth = 238 - 5,
    Font = { Addon.Media.."/Prototype.ttf", 13, "OUTLINE" },
    Texture = Addon.Media.."/MinimalistBar",
    Color = { 1, 0.7, 0 },
    BackgroundColor = { 0.12, 0.12, 0.12 },
  }
}

--[[ Target's target ]]--------------------------------------------------------------------------------------------------------------------------------
Config.TargetTarget = {
  Portrait = "LEFT",
  BarWidth = 60,

  Name = {
    MaxWidth = 60 - 3,
    Font = { Addon.Media.."/Prototype.ttf", 11, "OUTLINE" },
    Anchor = { "CENTER", "Health" },
    Justify = "CENTER",
    Color = { 1, 1, 1 },
  },

  HealthBar = {
    Height  = 20,
    Texture = Addon.Media.."/MinimalistBar",
    Color = "AUTO",
    BackgroundColor = { 0.12, 0.12, 0.12 },
    PredictionTexture = "Interface/RaidFrame/Raid-bar-HP-fill",
  },

  PowerBar = {
    Height = 8,
    Texture = Addon.Media.."/MinimalistBar",
    BackgroundColor = { 0.12, 0.12, 0.12 },
  },

  Status = {
    Anchor = { "CENTER", "Health" },
    Font = { Addon.Media.."/Prototype.ttf", 11, "OUTLINE" },
    Justify = "CENTER",
  },
}

--[[ Focus ]]------------------------------------------------------------------------------------------------------------------------------------------
Config.Focus = {
  Anchor = { "TOPLEFT", "SpyroTarget", "TOPRIGHT", 502, 0 }, -- Anchor when solo or party
  RaidAnchor = { "TOPRIGHT", "SpyroTarget", "TOPLEFT", -40, 0 }, -- Anchor when in raids
  ThreatGlow = "OUTSIDE",
  Portrait = "LEFT",
  BarWidth = 147,

  Name = {
    MaxWidth = 147 - 5, -- When it will truncate
    Font = { Addon.Media.."/Prototype.ttf", 13, "OUTLINE" },
    Anchor = { "CENTER", "NameBar" },
    Justify = "CENTER",
    Color = "AUTO", -- AUTO (class color for players, reaction colors for NPCs) or a specific color in a table
  },

  NameBar = {
    Height = 22,
    Color = { 0.33, 0.36, 0.37 }, -- Can be AUTO
    Texture = Addon.Media.."/MinimalistBar",
  },

  HealthBar = {
    Height  = 12,
    Texture = Addon.Media.."/MinimalistBar",
    Color = { 0, 1, 0 }, -- Can be AUTO
    BackgroundColor = { 0.12, 0.12, 0.12 },
    PredictionTexture = "Interface/RaidFrame/Raid-bar-HP-fill", -- Interface/TargetingFrame/UI-StatusBar
  },

  HealthValue = {
    Anchor = { "CENTER", "Health" },
    Font = { Addon.Media.."/Prototype.ttf", 13, "OUTLINE" },
    Justify = "CENTER",
  },

  PowerBar = {
    Height = 12,
    Texture = Addon.Media.."/MinimalistBar",
    BackgroundColor = { 0.12, 0.12, 0.12 },
  },

  PowerValue = {
    Anchor = { "CENTER", "Power" },
    Font = { Addon.Media.."/Prototype.ttf", 13, "OUTLINE" },
    Justify = "CENTER",
  },

  Status = {
    Anchor = { "CENTER", "Power" },
    Font = { Addon.Media.."/Prototype.ttf", 13, "OUTLINE" },
    Justify = "CENTER",
  },

  Level = {
    Anchor = { "BOTTOMLEFT", "Portrait", -2, -2 },
    Font = { Addon.Media.."/Prototype.ttf", 12, "OUTLINE" },
    Justify = "LEFT",
    SkullSize = { 11, 14 }, -- Widht/Height for the texture that will be shown if the level is too high to know it
    SkullAnchor = { "BOTTOMLEFT", "Portrait" },
  },

  RoleIcon = {
    Anchor = { "CENTER", "Portrait", "TOPRIGHT" },
    Size = 13,
  },

  CombatIndicator = {
    Anchor = { "LEFT", "Power", -1, 0 },
    Font = { Addon.Media.."/Prototype.ttf", 13, "OUTLINE" },
    Justify = "LEFT",
    Color = { 1, 0, 0 },
  },

  Threat = {
    Style = "OUTSIDE",
  },

  Auras = {
    xPadding   =  3, -- Space between auras
    yPadding   =  6, -- Space between aura rows
    PlayerSize = 28, -- Size of the auras casted by the player
    NormalSize = 22, -- Size of the rest of the auras
  },

  Castbar = {
    Height = 20,
    Width = 238,
    SpellMaxWidth = 238 - 5,
    Font = { Addon.Media.."/Prototype.ttf", 13, "OUTLINE" },
    Texture = Addon.Media.."/MinimalistBar",
    Color = { 1, 0.7, 0 },
    BackgroundColor = { 0.12, 0.12, 0.12 },
  }
}

--[[ Focus's target ]]---------------------------------------------------------------------------------------------------------------------------------
Config.FocusTarget = {
  Portrait = "RIGHT",
  BarWidth = 60,

  Name = {
    MaxWidth = 60 - 3,
    Font = { Addon.Media.."/Prototype.ttf", 11, "OUTLINE" },
    Anchor = { "CENTER", "Health" },
    Justify = "CENTER",
    Color = { 1, 1, 1 },
  },

  HealthBar = {
    Height  = 20,
    Texture = Addon.Media.."/MinimalistBar",
    Color = "AUTO",
    BackgroundColor = { 0.12, 0.12, 0.12 },
    PredictionTexture = "Interface/RaidFrame/Raid-bar-HP-fill",
  },

  PowerBar = {
    Height = 8,
    Texture = Addon.Media.."/MinimalistBar",
    BackgroundColor = { 0.12, 0.12, 0.12 },
  },

  Status = {
    Anchor = { "CENTER", "Health" },
    Font = { Addon.Media.."/Prototype.ttf", 11, "OUTLINE" },
    Justify = "CENTER",
  },
}

--[[ Player ]]-----------------------------------------------------------------------------------------------------------------------------------------
Config.Player = {
  Anchor = { "BOTTOMLEFT", "SpyroTarget", "TOPLEFT" },
  TargetHighlight = true,
  BarWidth = 147,

  ResourceCharges = { -- For Combo Points, Holy Power, Chi, etc
    Anchor = { "BOTTOMLEFT", "SpyroPlayer", "BOTTOMRIGHT" },
    ChargeSize = 24,
  },

  RoleIcon = {
    Anchor = { "TOPLEFT", "Health", "TOPLEFT", 2, -3 },
    Size = 13,
  },

  Name = {
    Anchor = { "TOPLEFT", "Health", "TOPLEFT", 14, -3 }, -- "LEFT", "GroupRoleIndicator", "RIGHT"
    Font = { "Fonts/FRIZQT__.TTF", 11 },
    Shadow = true,
    MaxWidth = 147 - 16,
    Justify = "LEFT",
    Color = { 1, 1, 1 },
  },

  HealthBar = {
    Height = 62,
    Texture = Addon.Media.."/MinimalistBar",
    Color = "AUTO",
    BackgroundColor = { 0.12, 0.12, 0.12 },
    PredictionTexture = Addon.Media.."/MinimalistBar",
  },

  PowerBar = {
    Height = 7,
    Texture = Addon.Media.."/MinimalistBar",
    BackgroundColor = { 0.12, 0.12, 0.12 },
  },

  Status = {
    Anchor = { "CENTER", "Health" },
    Font = { Addon.Media.."/Prototype.ttf", 20, "OUTLINE" },
    Justify = "CENTER",
  },

  CombatIndicator = {
    Anchor = { "CENTER", "Health", "CENTER", 1, -1 },
    Font = { Addon.Media.."/Prototype.ttf", 16, "OUTLINE" },
    Justify = "CENTER",
    Color = { 1, 0, 0 },
  },

  DispelSymbols = { -- Raid-style dispel alert symbols
    Size = 14,
    UseOldIcons = false -- Pre-Midnight dispel symbols
  },

  Debuffs = { -- Raid-style debuffs
    Size = 22,
    MaxNum = 6,
  },

  Buffs = { -- Raid-style buffs
    Size = 22,
    MaxNum = 6,
  },

  ImportantAuras = { -- Shown on the outside bottom left of the frame
    Size = 34,
  },

  CCandDefAuras = { -- Shown on the outside bottom right of the frame
    Size = 34,
  },

  Threat = {
    Style = "INSIDE",
    IgnoreLevel = 1, -- Don't show yellow threat
  },

  AdditionalPower = { -- Additional power bar (like mana for Balance druids)
    Anchor = { "BOTTOMRIGHT", "Frame", "BOTTOMLEFT", 1, 0 },
    Orientation = "VERTICAL",
    Height = 72,
    Width = 7,
    Texture = Addon.Media.."/FlatBar",
    BackgroundColor = { 0.12, 0.12, 0.12 },
  },

  AlternativePower = { -- Encounter/quest power bar
    Anchor = { "CENTER", "Castbar", "CENTER", 0, -10 },
    Height = 26,
    Width = 250,
    Texture = "Interface/TargetingFrame/UI-StatusBar",
    BackgroundColor = { 0.12, 0.12, 0.12 },
  },

  BuffFrame = { -- Player's buffs on the left of the Minimap
    Scale  = 1.4,
    Anchor = { "TOPRIGHT", MinimapCluster, "TOPLEFT", -2, 0 },
  },

  DebuffFrame = { -- Player's debuffs on the left of the Minimap
    Scale  = 1.32,
    Anchor = { "TOPRIGHT", BuffFrame, "BOTTOMRIGHT", -18, -10 },
  },

  Castbar = {
    Anchor = { "CENTER", UIParent, "CENTER", 0, -220 },
    Height = 26,
    Width = 250,
    SpellMaxWidth = 250 - 5,
    Font = { Addon.Media.."/Prototype.ttf", 15, "OUTLINE" },
    Texture = Addon.Media.."/MinimalistBar",
    Color = { 1, 0.7, 0 },
    BackgroundColor = { 0.12, 0.12, 0.12 },
  },

  PersonalBuffs = { -- Buffs to always show on the frame
    ROGUE = {
      [ 32645] = true, -- Envenom (Retail)
      [315496] = true, -- Slice and Dice (Retail)
      [  5171] = true, -- Slice and Dice (rank 1)
      [  6774] = true, -- Slice and Dice (rank 2)
    },
  },

  PersonalBuffs2 = { -- Tracker for personal buffs on the outer top left of the frame
    ROGUE = {
      [ 20600] = true, -- Perception
      [ 32645] = true, -- Envenom (Retail)
      [315496] = true, -- Slice and Dice (Retail)
      [  5171] = true, -- Slice and Dice (rank 1)
      [  6774] = true, -- Slice and Dice (rank 2)
    },

    PRIEST = {
      ShowSwipe = true,
    --[41635] = true, -- PoM Retail test
      [20600] = true, -- Perception
      [  588] = true, -- Inner fire (rank 1)
      [  624] = true, -- Inner fire (rank 2)
      [ 7128] = true, -- Inner fire (rank 2)
      [  602] = true, -- Inner fire (rank 3)
      [ 1006] = true, -- Inner fire (rank 4)
      [10951] = true, -- Inner fire (rank 5)
      [10952] = true, -- Inner fire (rank 6)
      [18137] = true, -- Shadowguard (rank 1)
      [19308] = true, -- Shadowguard (rank 2)
      [19309] = true, -- Shadowguard (rank 3)
      [19310] = true, -- Shadowguard (rank 4)
      [19311] = true, -- Shadowguard (rank 5)
      [19312] = true, -- Shadowguard (rank 6)
      [ 2652] = true, -- Touch of Weakness (rank 1)
      [19261] = true, -- Touch of Weakness (rank 2)
      [19262] = true, -- Touch of Weakness (rank 3)
      [19264] = true, -- Touch of Weakness (rank 4)
      [19265] = true, -- Touch of Weakness (rank 5)
      [19266] = true, -- Touch of Weakness (rank 6)
    },
  },
}

--[[ Pet ]]--------------------------------------------------------------------------------------------------------------------------------------------
Config.Pet = {
  Anchor = { "TOPRIGHT", "SpyroPlayer", "TOPLEFT", -1, 0 },
  TargetHighlight = true,
  BarWidth = 147,

  Name = {
    Anchor = { "TOPLEFT", "Health", "TOPLEFT", 14, -3 },
    Font = { "Fonts/FRIZQT__.TTF", 11 },
    Shadow = true,
    MaxWidth = 147 - 16,
    Justify = "LEFT",
    Color = { 1, 1, 1 },
  },

  HealthBar = {
    Height = 36,
    Texture = Addon.Media.."/MinimalistBar",
    Color = "AUTO",
    BackgroundColor = { 0.12, 0.12, 0.12 },
    PredictionTexture = Addon.Media.."/MinimalistBar",
  },

  Status = {
    Anchor = { "CENTER", "Health" },
    Font = { Addon.Media.."/Prototype.ttf", 20, "OUTLINE" },
    Justify = "CENTER",
  },

  DispelSymbols = { -- Raid-style dispel alert symbols
    Size = 12,
  },

  Debuffs = { -- Raid-style debuffs
    Size = 22,
    MaxNum = 3,
  },

  Buffs = { -- Raid-style buffs
    Size = 22,
    MaxNum = 3,
  },

  ImportantAuras = { -- CC and other important auras, shown on the outsides of the frame
    Size = 38,
  },

  Threat = {
    Style = "INSIDE",
    IgnoreLevel = 1, -- Don't show yellow threat
  },
}

--[[ Party ]]------------------------------------------------------------------------------------------------------------------------------------------
Config.Party = {
  Anchor = { "BOTTOMLEFT", "SpyroPlayer", "TOPLEFT" },
  GrowthDirection = "UP",
  TargetHighlight = true,
  RangeOpacity = true,
  BarWidth = 147,

  RoleIcon = {
    Anchor = { "TOPLEFT", "Health", "TOPLEFT", 2, -3 },
    Size = 13,
  },

  Name = {
    Anchor = { "TOPLEFT", "Health", "TOPLEFT", 14, -3 }, -- "LEFT", "GroupRoleIndicator", "RIGHT"
    Font = { "Fonts/FRIZQT__.TTF", 11 },
    Shadow = true,
    MaxWidth = 147 - 16,
    Justify = "LEFT",
    Color = { 1, 1, 1 },
  },

  HealthBar = {
    Height = 62,
    Texture = Addon.Media.."/MinimalistBar",
    Color = "AUTO",
    BackgroundColor = { 0.12, 0.12, 0.12 },
    PredictionTexture = Addon.Media.."/MinimalistBar",
  },

  PowerBar = {
    Height = 7,
    Texture = Addon.Media.."/MinimalistBar",
    BackgroundColor = { 0.12, 0.12, 0.12 },
  },

  Status = {
    Anchor = { "CENTER", "Health" },
    Font = { Addon.Media.."/Prototype.ttf", 20, "OUTLINE" },
    Justify = "CENTER",
  },

  DispelSymbols = { -- Raid-style dispel alert symbols
    Size = 14,
    UseOldIcons = false -- Pre-Midnight dispel symbols
  },

  Debuffs = { -- Raid-style debuffs
    Size = 22,
    MaxNum = 6,
  },

  Buffs = { -- Raid-style buffs
    Size = 22,
    MaxNum = 6,
  },

  ImportantAuras = { -- Shown on the outside bottom left of the frame
    Size = 34,
  },

  CCandDefAuras = { -- Shown on the outside bottom right of the frame
    Size = 34,
  },

  Threat = {
    Style = "INSIDE",
    IgnoreLevel = 1, -- Don't show yellow threat
  },

  --[[
  Castbar = {
    Anchor = { "TOPLEFT", "Frame", "TOPRIGHT", 1, 0 },
    Height = 36,
    Width = 112,
    SpellMaxWidth = 112 - 5,
    Font = { Addon.Media.."/Prototype.ttf", 13, "OUTLINE" },
    Texture = Addon.Media.."/MinimalistBar",
    Color = { 1, 0.7, 0 },
    BackgroundColor = { 0.12, 0.12, 0.12 },
  }
  ]]
}

--[[ Party pets ]]------------------------------------------------------------------------------------------------------------------------------------
Config.PartyPet = {
  TargetHighlight = true,
  RangeOpacity = true,
  BarWidth = 147,

  Name = {
    Anchor = { "TOPLEFT", "Health", "TOPLEFT", 14, -3 },
    Font = { "Fonts/FRIZQT__.TTF", 11 },
    Shadow = true,
    MaxWidth = 147 - 16,
    Justify = "LEFT",
    Color = { 1, 1, 1 },
  },

  HealthBar = {
    Height = 36,
    Texture = Addon.Media.."/MinimalistBar",
    Color = "AUTO",
    BackgroundColor = { 0.12, 0.12, 0.12 },
    PredictionTexture = Addon.Media.."/MinimalistBar",
  },

  Status = {
    Anchor = { "CENTER", "Health" },
    Font = { Addon.Media.."/Prototype.ttf", 20, "OUTLINE" },
    Justify = "CENTER",
  },

  DispelSymbols = { -- Raid-style dispel alert symbols
    Size = 12,
  },

  Debuffs = { -- Raid-style debuffs
    Size = 22,
    MaxNum = 3,
  },

  Buffs = { -- Raid-style buffs
    Size = 22,
    MaxNum = 3,
  },

  ImportantAuras = { -- CC and other important auras, shown on the outsides of the frame
    Size = 38,
  },

  Threat = {
    Style = "INSIDE",
    IgnoreLevel = 1, -- Don't show yellow threat
  },
}

--[[ Arena ]]-----------------------------------------------------------------------------------------------------------------------------------------
Config.Arena = {
  Anchor = { "BOTTOMRIGHT", "SpyroFocus", "TOPRIGHT" },
  AnchorBattlegrounds = { "BOTTOMLEFT", "SpyroPlayer", "TOPLEFT" },
  GrowthDirection = "UP",
  TargetHighlight = true,
  BarWidth = 147,

  Name = {
    Anchor = { "TOPLEFT", "Health", "TOPLEFT", 14, -3 },
    Font = { "Fonts/FRIZQT__.TTF", 11 },
    Shadow = true,
    MaxWidth = 147 - 16,
    Justify = "LEFT",
    Color = { 1, 1, 1 },
  },

  HealthBar = {
    Height = 62,
    Texture = Addon.Media.."/MinimalistBar",
    Color = "AUTO",
    BackgroundColor = { 0.12, 0.12, 0.12 },
    PredictionTexture = Addon.Media.."/MinimalistBar",
  },

  PowerBar = {
    Height = 7,
    Texture = Addon.Media.."/MinimalistBar",
    BackgroundColor = { 0.12, 0.12, 0.12 },
  },

  Status = {
    Anchor = { "CENTER", "Health" },
    Font = { Addon.Media.."/Prototype.ttf", 20, "OUTLINE" },
    Justify = "CENTER",
  },

  Auras = { -- To show CC and important helpful buffs
    Size = 44,
    MaxNum = 3,
  },

  SpecIcon = {
    Size = 12,
    Anchor = { "TOPRIGHT", "Health", "TOPRIGHT", -1, -1 },
  },

  Castbar = {
    Anchor = { "TOPRIGHT", "Frame", "TOPLEFT", 1, 0 },
    Height = 36,
    Width = 112,
    SpellMaxWidth = 112 - 5,
    Font = { Addon.Media.."/Prototype.ttf", 13, "OUTLINE" },
    Texture = Addon.Media.."/MinimalistBar",
    Color = { 1, 0.7, 0 },
    BackgroundColor = { 0.12, 0.12, 0.12 },
  }
}

--[[ Arena pets ]]------------------------------------------------------------------------------------------------------------------------------------
Config.ArenaPet = {
  Enabled = true,
  TargetHighlight = true,
  BarWidth = 147,

  Name = {
    Anchor = { "TOPLEFT", "Health", "TOPLEFT", 14, -3 },
    Font = { "Fonts/FRIZQT__.TTF", 11 },
    Shadow = true,
    MaxWidth = 147 - 16,
    Justify = "LEFT",
    Color = { 1, 1, 1 },
  },

  HealthBar = {
    Height = 36,
    Texture = Addon.Media.."/MinimalistBar",
    Color = "AUTO",
    BackgroundColor = { 0.12, 0.12, 0.12 },
    PredictionTexture = Addon.Media.."/MinimalistBar",
  },

  Status = {
    Anchor = { "CENTER", "Health" },
    Font = { Addon.Media.."/Prototype.ttf", 20, "OUTLINE" },
    Justify = "CENTER",
  },

  Auras = { -- To show CC and important helpful buffs
    Size = 34,
    MaxNum = 4,
  },
}

--[[ Boss ]]------------------------------------------------------------------------------------------------------------------------------------------
Config.Boss = {
  Anchor = { "BOTTOMRIGHT", "SpyroFocus", "TOPRIGHT" },
  GrowthDirection = "UP",
  TargetHighlight = true,
  BarWidth = 147,

  Name = {
    Anchor = { "TOPLEFT", "Health", "TOPLEFT", 14, -3 },
    Font = { "Fonts/FRIZQT__.TTF", 11 },
    Shadow = true,
    MaxWidth = 147 - 16,
    Justify = "LEFT",
    Color = { 1, 1, 1 },
  },

  HealthBar = {
    Height = 62,
    Texture = Addon.Media.."/MinimalistBar",
    Color = "AUTO",
    BackgroundColor = { 0.12, 0.12, 0.12 },
    PredictionTexture = Addon.Media.."/MinimalistBar",
  },

  PowerBar = {
    Height = 7,
    Texture = Addon.Media.."/MinimalistBar",
    BackgroundColor = { 0.12, 0.12, 0.12 },
  },

  Status = {
    Anchor = { "CENTER", "Health" },
    Font = { Addon.Media.."/Prototype.ttf", 20, "OUTLINE" },
    Justify = "CENTER",
  },

  Debuffs = { -- Raid-style debuffs
    Size = 22,
    MaxNum = 6,
  },

  Buffs = { -- Raid-style buffs
    Size = 22,
    MaxNum = 6,
  },

  Castbar = {
    Anchor = { "TOPRIGHT", "Frame", "TOPLEFT", 1, 0 },
    Height = 36,
    Width = 112,
    SpellMaxWidth = 112 - 5,
    Font = { Addon.Media.."/Prototype.ttf", 13, "OUTLINE" },
    Texture = Addon.Media.."/MinimalistBar",
    Color = { 1, 0.7, 0 },
    BackgroundColor = { 0.12, 0.12, 0.12 },
  }
}

--[[ Blizzard's CompactRaidFrames ]]------------------------------------------------------------------------------------------------------------------
Config.Raid = {
  Texture = Addon.Media.."/MinimalistBar",
  BackgroundColor = { 0.12, 0.12, 0.12, 1 },
}

--[[ Action bars ]]-----------------------------------------------------------------------------------------------------------------------------------
Config.ActionBars = {
  -- Bar to see cooldowns on bottom
  [1] = {
    Name            = "SpyroCooldownBar",
    Scale           = 1.3,
    Rows            = 2,
    Columns         = 18,
    HideHotkey      = true,
    HideMacro       = true,
    HideEmpty       = true,
    AutoCenter      = true,
    ShowOnMouseOver = false,
    Anchor          = { "BOTTOM", UIParent, "BOTTOM", 0, 0 },
    Visibility      = "[vehicleui][overridebar][possessbar][petbattle][bonusbar:5] hide; show"
  },

  -- Bar for Vanilla/TBC vehicles/possessions and Retail Skyriding
  [2] = {
    Name          = "SpyroVehicleBar",
    Scale         = 1.3,
    Rows          = 1,
    Columns       = 12,
    HideEmpty     = true,
    AutoCenter    = true,
    StartActionID = Lib.IsVanillaOrTBC and 109 or 121, -- Vehicle/possession actionIDs: Vanilla-TBC: 109–120 / WotLK-TWW: 121-132
    Anchor        = { "BOTTOM", UIParent, "BOTTOM", 0, 0 },
    Visibility    = "[possessbar][bonusbar:5] show; hide"
  },

  -- Bar for usable items on the top of the screen
  [3] = {
    Name            = "SpyroItemBar",
    Scale           = 1,
    Rows            = 1,
    Columns         = 7,
    HideHotkey      = true,
    HideMacro       = true,
    ShowOnMouseOver = true,
    Anchor          = { "TOPLEFT", BagsBar, "TOPRIGHT", 0, 0 }
  },

  -- Small bar to see important cooldowns on the topright of the PlayerFrame
  [4] = {
    Name        = "SpyroMiniCdBar",
    Scale       = 0.7,
    ChargesSize = 20,
    Rows        = 1,
    Columns     = 5,
    HideHotkey  = true,
    HideMacro   = true,
    HideEmpty   = true,
    HideOOC     = true, -- Hide when Out Of Combat
    Anchor      = { "TOPLEFT", "SpyroPlayer", "TOPRIGHT", 0, 0 },
  },

  -- Another bar for items on the right of the screen
  [5] = {
    Name       = "SpyroGadgetBar",
    Scale      = 1,
    Rows       = 14,
    Columns    = 1,
    HideHotkey = true,
    HideMacro  = true,
    HideEmpty  = true,
    Anchor     = { "TOPRIGHT", "MinimapCluster", "BOTTOMRIGHT", 0, 0 }
  },
}

--[[ Totem bar ]]-------------------------------------------------------------------------------------------------------------------------------------
Config.TotemBar = {
  TotemSize = 40,
  Anchor = { "CENTER", UIParent, "CENTER", 0, -190 }
}

--[[ Pet bar ]]---------------------------------------------------------------------------------------------------------------------------------------
Config.PetBar = {
  ButtonSize = 30,
  HideEmpty = true,
  AutoCenter = true,
  Anchor = { "BOTTOM", UIParent, "BOTTOM", 0, 134 }
}

--[[ Minimap ]]---------------------------------------------------------------------------------------------------------------------------------------
Config.Minimap = {
  Size = 198, -- Width and height
  Font = { Addon.Media.."/Prototype.ttf", 12 },

  -- Buttons that will be visible all the time instead of only on mouseover (which is the default state)
  MouseOverIgnore = {
  --LibDBIcon10_BindPanel = true
  },

  -- Button that won't be collected for the ButtonHub
  ButtonHubIgnore = {
    LibDBIcon10_ItemRack = true,
    LibDBIcon10_BindPanel = true,
    LibDBIcon10_MacroBinds = true,
  }
}

--[[ Quest Tracker ]]---------------------------------------------------------------------------------------------------------------------------------
Config.QuestTracker = {
  Width  = 600,
  Height = 260
}

--[[ MicroMenu ]]-------------------------------------------------------------------------------------------------------------------------------------
Config.MicroMenu = {
  Anchor = { "TOPLEFT", UIParent, "TOPLEFT", Lib.IsRetail and -4 or -2, 3 },
  Scale = 1,
}

--[[ Bags ]]------------------------------------------------------------------------------------------------------------------------------------------
Config.Bags = {
  Anchor = { "TOPLEFT", MicroMenu, "TOPRIGHT", 0, -3 },
  Scale = Lib.IsRetail and 1 or 0.78,
}

--[[ Experience percentage viewer ]]------------------------------------------------------------------------------------------------------------------
Config.XPviewer = {
  Anchor = { "TOPLEFT", UIParent },
  Font = { Addon.Media.."/Prototype.ttf", 12 },
}

--[[ Latency viewer ]]--------------------------------------------------------------------------------------------------------------------------------
Config.LatencyViewer = {
  Anchor = { "TOPLEFT", CharacterMicroButton, "BOTTOMLEFT", 5, 0 },
  Font = { Addon.Media.."/Prototype.ttf", 12 }
}

--[[ Frame rate viewer ]]-----------------------------------------------------------------------------------------------------------------------------
Config.FrameRateViewer = {
  Anchor = { "CENTER", UIParent, "CENTER", 16, -100 },
  Font = { Addon.Media.."/Prototype.ttf", 14 },
}

--[[ Nameplates ]]------------------------------------------------------------------------------------------------------------------------------------
Config.Nameplates = {
  Font = Addon.Media.."/Roboto_Condensed_Bold.ttf",
  BarTexture = Addon.Media.."/MinimalistBar",
  Enemy = {
    Width  = 130,
    Height = 45
  },
  Friendly = {
    Width  = 60,
    Height = 45
  }
}

--[[ Slash command ]]---------------------------------------------------------------------------------------------------------------------------------
Config.ExampleCommand = {   -- Configuration of the /spyro command to show an example party and arena frames
  ShowPartyPets     = true,
  ShowPartyCastbars = false, -- If true, requires Party.ShowCastbars to be true
  ShowArenaCastbars = false,
}

--[[ Sound to mute ]]---------------------------------------------------------------------------------------------------------------------------------
Config.MuteSounds = {
  569772, -- Holy fizzle
  569773, -- Fire fizzle
  569774, -- Nature fizzle
  569775, -- Frost fizzle
  569776, -- Shadow fizzle
  613892, -- Jade fizzle
  567407, -- Tracking switch
}

--[[ Debuffs to show anchored to the target/focus portrait side ]]------------------------------------------------------------------------------------
Config.TargetPersonalDebuffs = {
  -- Priest
  [34914] = true, -- Vampiric Touch
  [  589] = true, -- Shadow Word: Pain

  -- Rogue
  [ 703] = true, -- Garrote
  [1943] = true, -- Rupture
}

--[[ Buffs to always show on the Player/Party frames (from any caster) ]]-----------------------------------------------------------------------------
Config.PartyBuffsShowAlways = {
  PRIEST = {
    [6346] = true, -- Fear Ward
  }
}

--[[ Buffs to show on the Player/Party frames only out of combat (from any caster) ]]-----------------------------------------------------------------
Config.PartyBuffsShowOOC = {
  PRIEST = {
    [ 1243] = true, -- Power Word: Fortitude (rank 1)
    [ 1244] = true, -- Power Word: Fortitude (rank 2)
    [ 1245] = true, -- Power Word: Fortitude (rank 3)
    [ 2791] = true, -- Power Word: Fortitude (rank 4)
    [10937] = true, -- Power Word: Fortitude (rank 5)
    [10938] = true, -- Power Word: Fortitude (rank 6)
    [21562] = true, -- Prayer of Fortitude (rank 1) and Power Word: Fortitude (Retail)
    [21564] = true, -- Prayer of Fortitude (rank 2)
    [14752] = true, -- Divine Spirit (rank 1)
    [14818] = true, -- Divine Spirit (rank 2)
    [14819] = true, -- Divine Spirit (rank 3)
    [27841] = true, -- Divine Spirit (rank 4)
    [27681] = true, -- Prayer of Spirit
    [  976] = true, -- Shadow Protection (rank 1)
    [10957] = true, -- Shadow Protection (rank 2)
    [10958] = true, -- Shadow Protection (rank 3)
    [27683] = true, -- Prayer of Shadow Protection
  }
}

--[[ Player buffs to always show on the Player/Party frames ]]----------------------------------------------------------------------------------------
Config.RAID_IN_COMBAT = {
  [  17] = true, -- Power Word: Shield (rank 1)
  [ 592] = true, -- Power Word: Shield (rank 2)
  [ 600] = true, -- Power Word: Shield (rank 3)
  [ 139] = true, -- Renew (rank 1)
  [6074] = true, -- Renew (rank 2)
  [6075] = true, -- Renew (rank 3)
}

--[[ Debuffs to always hide on the Player/Party frames. Only declassified/non-secret ones work ]]-----------------------------------------------------
Config.PartyDebuffsHide = {
  [ 206151] = true, -- Challenger's Burden
  [  71041] = true, -- Dungeon Deserter
  [  57723] = true, -- Exhaustion
  [ 390435] = true, -- Exhaustion
  [ 160455] = true, -- Fatigued
  [ 264689] = true, -- Fatigued
  [  57724] = true, -- Sated
  [ 124255] = true, -- Stagger
  [  95809] = true, -- Insanity
  [  80354] = true, -- Temporal Displacement
}

--[[ CVars ]]-----------------------------------------------------------------------------------------------------------------------------------------
Config.CVars = {
  addonProfilerEnabled         = 0,
  ActionButtonUseKeyDown       = 1,
  autoLootDefault              = 1,
  chatClassColorOverride       = 0,
  colorChatNamesByClass        = 1,
  cameraDistanceMaxZoomFactor  = 1.9,
  ffxDeath                     = 0,
  ffxGlow                      = 1,
  fstack_preferParentKeys      = 1,
  instantQuestText             = 1,
  minimapTrackingShowAll       = 1,
  nameplateShowSelf            = 0,
  nameplateGlobalScale         = 1,
  nameplateSelectedScale       = 1,
  nameplateMinScale            = 1,
  nameplateMaxScale            = 1,
  nameplateMaxDistance         = 41,
  nameplateShowEnemies         = 1,
  nameplateShowOnlyNameForFriendlyPlayerUnits      = 1,
  nameplateUseClassColorForFriendlyPlayerUnitNames = 1,
  noBuffDebuffFilterOnTarget   = 1,
  predictedHealth              = 1,
  partyBackgroundOpacity       = 0,
  pvpFramesDisplayClassColor   = 1,
  pvpFramesDisplayPowerBars    = 1,
  pvpOptionDisplayPets         = 0,
  runeFadeTime                 = 0,
  runeSpentFadeTime            = 0,
  runeSpentFlashTime           = 0,
  raidFramesDisplayClassColor  = 1,
  raidFramesDisplayPowerBars   = 1,
  raidOptionDisplayPets        = 1,
  raidOptionKeepGroupsTogether = 1,
  raidOptionShowBorders        = 0,
  raidOptionSortMode           = "group",
  statusText                   = 1,
  statusTextDisplay            = "NUMERIC",
  scriptErrors                 = 1,
  showTargetOfTarget           = 1,
  showTempMaxHealthLoss        = 0,
  showPartyPets                = 1,
  showArenaEnemyPets           = 0,
  showLoadingScreenTips        = 0,
  showCastableBuffs            = 0,
  showDispelDebuffs            = 0,
  ShowClassColorInNameplate    = 1,
  SpellQueueWindow             = 235,
  screenshotFormat             = "png",
  screenshotQuality            = 10,
  showBuilderFeedback          = 0,
  showSpenderFeedback          = 0,
  Sound_EnableErrorSpeech      = 0,
  SoftTargetEnemyRange         = 0,
  SoftTargetFriendRange        = 0,
  SoftTargetInteract           = 0,
  stopAutoAttackOnTargetChange = 1,
  synchronizeBindings          = 0,
  synchronizeConfig            = 0,
  synchronizeMacros            = 0,
  synchronizeSettings          = 0,
  taintLog                     = 1,
  tooltipShowAuraSpellIDs      = 1,
  violenceLevel                = 5, -- Default: 2

  -- Retail
  ffxnetherworld               = 0,
  floatingCombatTextCombatDamageDirectionalScale = 0,
  floatingCombatTextCombatDamageDirectionalScale_v2 = 0,
  nameplateMaxDistance         = 100,
  ReplaceMyPlayerPortrait      = 1,
  ReplaceOtherPlayerPortraits  = 1,
  threatWarning                = 3,
}