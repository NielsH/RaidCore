----------------------------------------------------------------------------------------------------
-- Client Lua Script for RaidCore Addon on WildStar Game.
--
-- Copyright (C) 2015 RaidCore
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Description:
-- TODO
----------------------------------------------------------------------------------------------------
local Apollo = require "Apollo"
local GameLib = require "GameLib"

local core = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("RaidCore")
local mod = core:NewEncounter("Thrag", 104, 548, 552)
if not mod then return end

----------------------------------------------------------------------------------------------------
-- Registering combat.
----------------------------------------------------------------------------------------------------
mod:RegisterTrigMob(core.E.TRIGGER_ALL, { "unit.thrag" })
mod:RegisterEnglishLocale({
    -- Unit names.
    ["unit.thrag"] = "Chief Engine Scrubber Thrag",
    ["unit.jumpstart"] = "Jumpstart Charge",
    -- Cast names.
    ["cast.thrag.gigavolt"] = "Gigavolt",
    -- Messages.
    ["msg.thrag.gigavolt.get_out"] = "GET OUT",
    ["msg.thrag.gigavolt.next"] = "Next Gigavolt in",
  }
)
mod:RegisterGermanLocale({
    -- Unit names.
    ["unit.jumpstart"] = "Starthilfe-Ladung",
  }
)
mod:RegisterFrenchLocale({
    -- Unit names.
    ["unit.jumpstart"] = "Charge de démarrage",
  }
)
----------------------------------------------------------------------------------------------------
-- Settings.
----------------------------------------------------------------------------------------------------
mod:RegisterDefaultSetting("BombLines", false)

----------------------------------------------------------------------------------------------------
-- Locals.
----------------------------------------------------------------------------------------------------
local playerUnit

----------------------------------------------------------------------------------------------------
-- Constants.
----------------------------------------------------------------------------------------------------
local TIMERS = {
  GIGAVOLT = {
    FIRST = 22,
    NORMAL = 25,
  }
}

----------------------------------------------------------------------------------------------------
-- Encounter description.
----------------------------------------------------------------------------------------------------
function mod:OnBossEnable()
  playerUnit = GameLib.GetPlayerUnit()
  mod:StartFirstGigavoltTimer()
end

function mod:OnThragCreated(id, unit, name)
  core:AddUnit(unit)
end

function mod:OnJumpstartCreated(id, unit, name)
  if mod:GetSetting("BombLines") then
    core:AddLineBetweenUnits("JUMP_START_LINE_"..id, playerUnit, unit, 5)
  end
end

function mod:OnGigavolt()
  mod:AddMsg("GIGAVOLT_MSG", "msg.thrag.gigavolt.get_out", 3, "RunAway", "white")
  mod:StartNormalGigavoltTimer()
end

function mod:StartFirstGigavoltTimer()
  mod:StartGigavoltTimer(TIMERS.GIGAVOLT.FIRST)
end

function mod:StartNormalGigavoltTimer()
  mod:StartGigavoltTimer(TIMERS.GIGAVOLT.NORMAL)
end

function mod:StartGigavoltTimer(time)
  mod:AddTimerBar("NEXT_GIGAVOLT_TIMER", "msg.thrag.gigavolt.next", time)
end

----------------------------------------------------------------------------------------------------
-- Bind event handlers.
----------------------------------------------------------------------------------------------------
mod:RegisterUnitEvents("unit.thrag",{
    [core.E.UNIT_CREATED] = mod.OnThragCreated,
  }
)
mod:RegisterUnitEvents("unit.jumpstart",{
    [core.E.UNIT_CREATED] = mod.OnJumpstartCreated,
  }
)
mod:RegisterUnitEvents("unit.thrag",{
    ["cast.thrag.gigavolt"] = {
      [core.E.CAST_START] = mod.OnGigavolt,
    }
  }
)

