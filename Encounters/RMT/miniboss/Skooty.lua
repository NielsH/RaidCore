----------------------------------------------------------------------------------------------------
-- Client Lua Script for RaidCore Addon on WildStar Game.
--
-- Copyright (C) 2015 RaidCore
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Description:
-- TODO
----------------------------------------------------------------------------------------------------
local core = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("RaidCore")
local mod = core:NewEncounter("Skooty", 104, 548, 552)
if not mod then return end

----------------------------------------------------------------------------------------------------
-- Registering combat.
----------------------------------------------------------------------------------------------------
mod:RegisterTrigMob("ALL", { "Assistant Technician Skooty" })
mod:RegisterEnglishLocale({
    ["Assistant Technician Skooty"] = "Assistant Technician Skooty",
    ["Hostile Invisible Unit for Fields (0 hit radius)"] = "Hostile Invisible Unit for Fields (0 hit radius)",
    ["Pulse Cannon"] = "Pulse Cannon",
    ["Jumpstart Charge"] = "Jumpstart Charge",
  })
----------------------------------------------------------------------------------------------------
-- Settings.
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Constants.
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Locals.
----------------------------------------------------------------------------------------------------
local jumpStarts

----------------------------------------------------------------------------------------------------
-- Encounter description.
----------------------------------------------------------------------------------------------------
function mod:OnBossEnable()

end

mod:RegisterUnitEvents("Assistant Technician Skooty",{
    ["OnUnitCreated"] = function (self, id, unit, name)
      core:AddUnit(unit)
      core:WatchUnit(unit)
    end,
    ["OnCastStart"] = function (self, id, castName, castEndTime, name)
      if self.L["Pulse Cannon"] == castName then
        mod:AddMsg("PULSECANNON", "GET OUT", 5, "RunAway")
      end
    end,
  }
)

mod:RegisterUnitEvents("Jumpstart Charge",{
    ["OnUnitCreated"] = function (self, id, unit, name)
      jumpStarts[id] = unit
      --core:WatchUnit(unit)
      core:AddLineBetweenUnits(string.format("JUMP_START_LINE %d", id), playerUnit:GetId(), id, 5)
    end,
    ["OnUnitDestroyed"] = function (self, id, unit, name)
      jumpStarts[id] = nil
      core:RemoveLineBetweenUnits(string.format("JUMP_START_LINE %d", id))
    end,
  }
)
