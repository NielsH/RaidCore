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
local mod = core:NewEncounter("Stormtalon", 13, 0, 19)
if not mod then return end

----------------------------------------------------------------------------------------------------
-- Registering combat.
----------------------------------------------------------------------------------------------------
mod:RegisterTrigMob(core.E.TRIGGER_ALL, { "unit.stl" })
mod:RegisterEnglishLocale({
    -- Unit names.
    ["unit.stl"] = "Stormtalon",
    ["unit.stl.invis"] = "Stormtalon - Lightning Storm Invis Unit",
    -- Cast names.
    ["cast.stl.chomp"] = "Chomp",
    ["cast.stl.call"] = "Thunder Call",
    ["cast.stl.storm"] = "Lightning Storm",
    ["cast.stl.wave"] = "Static Wave",
  }
)

----------------------------------------------------------------------------------------------------
-- Encounter description.
----------------------------------------------------------------------------------------------------
function mod:OnSTLCreated(id, unit, name)
  -- filter out second unit that's there for some reason
  if not unit:GetHealth() then return end
  core:AddUnit(unit)
  core:WatchUnit(unit, core.E.TRACK_ALL)
end

----------------------------------------------------------------------------------------------------
-- Bind event handlers.
----------------------------------------------------------------------------------------------------
mod:RegisterUnitEvents("unit.stl",{
    [core.E.UNIT_CREATED] = mod.OnSTLCreated,
  }
)
