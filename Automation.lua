--╔════════════════════════╗
--║ ┌─┐┌─┐┬ ┬┬─┐┌─┐  ┬ ┬┬  ║
--║ └─┐├─┘└┬┘├┬┘│ │  │ ││  ║
--║ └─┘┴   ┴ ┴└─└─┘  └─┘┴  ║
--╠════════════════════════╣
--║       Automation       ║
--╠════════════════════════╣
--║ By Spyro [Sanguino EU] ║
--╚════════════════════════╝

--[[ Local namespace vars ]]---------------------------------------------------------------------------------------------------------------------------
local _, Addon = ...
local Lib = Addon.Lib
local Error = { -- Table for the errors that will dismount or stand the player
  [SPELL_FAILED_NOT_MOUNTED    ] = function() Dismount()       end,
  [SPELL_FAILED_NOT_STANDING   ] = function() DoEmote("STAND") end,
  [ERR_ATTACK_MOUNTED          ] = function() Dismount()       end,
  [ERR_LOOT_NOTSTANDING        ] = function() DoEmote("STAND") end,
  [ERR_NOT_WHILE_MOUNTED       ] = function() Dismount()       end,
  [ERR_MOUNT_ALREADYMOUNTED    ] = function() Dismount()       end,
  [ERR_TAXIPLAYERALREADYMOUNTED] = function() Dismount()       end,
}

--[[ Events ]]-----------------------------------------------------------------------------------------------------------------------------------------
-- Event TAXIMAP_OPENED
-- Fires when the taxi viewer is opened.
local function TAXIMAP_OPENED()
  Dismount()
end

-- Event UI_ERROR_MESSAGE
-- Fires when the interface creates an error message (red message in top center of the screen).
local function UI_ERROR_MESSAGE(ErrorType, Message)
  if Error[Message] then Error[Message]() end
end

-- Event DUEL_REQUESTED
-- Fires when somebody requests to duel the player.
local function DUEL_REQUESTED()
  HideUIPanel(StaticPopup1)
  CancelDuel() -- Declining duel requests automatically
end

-- Event GOSSIP_SHOW
-- Fires when you talk to an NPC. Used to automate interactions with certain NPC's that have an annoying previous step to access their services.
local function GOSSIP_SHOW()
  local Options = C_GossipInfo.GetOptions()

  if Options and #Options == 1 and C_GossipInfo.GetNumAvailableQuests() == 0 and C_GossipInfo.GetNumActiveQuests() == 0 then
    local SkipGossipTypes = { banker = 1, taxi = 1, trainer = 1, vendor = 1 }
    if SkipGossipTypes[Options[1].type] then C_GossipInfo.SelectOption(1) end
  end
end

-- Event MERCHANT_SHOW
-- Fires when the player begins interaction with a vendor.
local function MERCHANT_SHOW()
  -- Auto selling gray items
  for Bag = 0, 4 do
    for Slot = 1, C_Container.GetContainerNumSlots(Bag) do
      local Link = C_Container.GetContainerItemLink(Bag, Slot)
      if Link and C_Item.GetItemQualityByID(Link) == 0 then C_Container.UseContainerItem(Bag, Slot) end
    end
  end

  -- Auto repairing items
  if CanMerchantRepair() and Disabled then
    local RepairCost = GetRepairAllCost()

    if RepairCost > 0 then
      local MyMoney = GetMoney()
      if Lib.TocVersion >= 20000 and IsInGuild() and CanGuildBankRepair() then
        local AvailableGuildMoney = GetGuildBankWithdrawMoney()
        if AvailableGuildMoney > GetGuildBankMoney() then AvailableGuildMoney = GetGuildBankMoney() end
        if AvailableGuildMoney > RepairCost then -- Using guild's bank money :)
          RepairAllItems(true)
          Lib.Print("|cfff07100Repair cost covered by Guild Bank: %.1fg|r", RepairCost * 0.0001)
          return
        end
      end

      if MyMoney >= RepairCost then
        RepairAllItems()
        Lib.Print("|cffead000Repair cost: %.1fg|r", RepairCost * 0.0001)
      else
        print("|cffff0000Not enough gold to cover repair costs.|r")
      end
    end
  end
end

-- Event registration
Lib.RegisterEvent("MERCHANT_SHOW", MERCHANT_SHOW)
Lib.RegisterEvent("DUEL_REQUESTED", DUEL_REQUESTED)
if Lib.TocVersion < 30000 then
  Lib.RegisterEvent("GOSSIP_SHOW", GOSSIP_SHOW)
  Lib.RegisterEvent("TAXIMAP_OPENED", TAXIMAP_OPENED)
  Lib.RegisterEvent("UI_ERROR_MESSAGE", UI_ERROR_MESSAGE)
end