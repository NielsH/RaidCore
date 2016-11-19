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
local mod = core:NewEncounter("Octog", 104, 0, 548)
if not mod then return end

----------------------------------------------------------------------------------------------------
-- Registering combat.
----------------------------------------------------------------------------------------------------
mod:RegisterTrigMob(core.E.TRIGGER_ALL, { "unit.octog" })
mod:RegisterEnglishLocale({
    -- Unit names.
    ["unit.octog"] = "Star-Eater the Voracious",
    ["unit.squirgling"] = "Squirgling",
    ["unit.orb"] = "Chaos Orb",
    ["unit.pool"] = "Noxious Ink Pool",
    -- NPC says.
    ["say.octog.orb"] = "Stay close! The feast be about to begin!",
    -- Cast names.
    ["cast.supernova"] = "Supernova",
    ["cast.hookshot"] = "Hookshot",
    ["cast.flamethrower"] = "Flamethrower",
    -- Messages.
    ["msg.hookshot.next"] = "Next hookshot in",
    ["msg.flamethrower.next"] = "Next flamethrower in",
    ["msg.chaos.orbs.coming"] = "Chaos orb(s) coming soon",
    ["msg.midphase.coming"] = "Midphase coming soon",
    ["msg.midphase.started"] = "MIDPHASE",
    ["msg.flamethrower.interrupt"] = "INTERRUPT OCTOG",
  }
)
----------------------------------------------------------------------------------------------------
-- Settings.
----------------------------------------------------------------------------------------------------
-- Visuals.
-- Sounds.
mod:RegisterDefaultSetting("SoundChaosOrbSoon")
mod:RegisterDefaultSetting("SoundMidphaseSoon")
mod:RegisterDefaultSetting("SoundMidphaseStarted")
mod:RegisterDefaultSetting("SoundFlamethrowerInterrupt")
-- Messages.
mod:RegisterDefaultSetting("MessageChaosOrbSoon")
mod:RegisterDefaultSetting("MessageMidphaseSoon")
mod:RegisterDefaultSetting("MessageMidphaseStarted")
mod:RegisterDefaultSetting("MessageFlamethrowerInterrupt")
-- Binds.
mod:RegisterMessageSetting("CHAOS_ORB_SOON", core.E.COMPARE_EQUAL, "MessageChaosOrbSoon", "MessageChaosOrbSoon")
mod:RegisterMessageSetting("MIDPHASE_SOON", core.E.COMPARE_EQUAL, "MessageMidphaseSoon", "SoundMidphaseSoon")
mod:RegisterMessageSetting("MIDPHASE_STARTED", core.E.COMPARE_EQUAL, "MessageMidphaseStarted", "SoundMidphaseStarted")
mod:RegisterMessageSetting("FLAMETHROWER_MSG_CAST", core.E.COMPARE_EQUAL, "MessageFlamethrowerInterrupt", "SoundFlamethrowerInterrupt")

----------------------------------------------------------------------------------------------------
-- Constants.
----------------------------------------------------------------------------------------------------
-- Debuffs and Buffs.
local DEBUFFS = {
  REND = 85443, --Reduces Mitigation by 2.5% per stack.
  NOXIOUS_INK = 85533, --Taking X damage every 0s.
  SQUIRGLING_SMASHER = 86804, --Increases Damage Dealt by 5% and Outgoing healing by 5% per stack.
  SPACE_FIRE = 87159, --Taking X technology damage every 3s.
  CHAOS_ORB = 85578, --Protected by Chaos Orbs.
  CHAOS_ORB_STACK = 85582, --Damage taken increased by 10% per stack.
  CHAOS_TETHER = 85583, --Chaos orb deals lethal damage to those who try to scape its grasp.
}
local BUFFS = {
  CHAOS_AMPLIFIER = 86876, --Increases the potency of Chaos Orbs.
  CHAOS_ORBS = 86885, --Channeling Chaos Orbs.
  ASTRAL_SHIELD = 85679, --Immune to damage.
  ASTRAL_SHIELD_STACKS = 85643, --Immune to damage.
}

local TIMERS = {
  HOOKSHOT = {
    FIRST = 10,
    NORMAL = 45,
  },
  FLAMETHROWER = {
    NORMAL = 40,
  }
}

-- Health trackers
local ORBS_CLOSE = {
  {UPPER = 86.5, LOWER = 85.5}, -- 85
  {UPPER = 71.5, LOWER = 70.5}, -- 70
}

local PHASES_CLOSE = {
  {UPPER = 66.5, LOWER = 65.5}, -- 65
}
----------------------------------------------------------------------------------------------------
-- Locals.
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Encounter description.
----------------------------------------------------------------------------------------------------
function mod:OnBossEnable()
  mod:AddTimerBar("NEXT_HOOKSHOT_TIMER", "msg.hookshot.next", TIMERS.HOOKSHOT.FIRST)
  mod:AddTimerBar("NEXT_FLAMETHROWER_TIMER", "msg.flamethrower.next", TIMERS.FLAMETHROWER.NORMAL)
end

function mod:IsPhaseClose(phase, percent)
  for i = 1, #phase do
    if percent >= phase[i].LOWER and percent <= phase[i].UPPER then
      return true
    end
  end
  return false
end

function mod:DisplayInterruptFlamethrower()
  mod:AddMsg("FLAMETHROWER_MSG_CAST", "msg.flamethrower.interrupt", 2, "Inferno", "xkcdOrange")
end

function mod:OnFlamethrowerStart()
  mod:RemoveTimerBar("NEXT_FLAMETHROWER_TIMER")
  mod:ScheduleTimer("DisplayInterruptFlamethrower", 1)
end

function mod:OnFlamethrowerEnd()
  mod:AddTimerBar("NEXT_FLAMETHROWER_TIMER", "msg.flamethrower.next", TIMERS.FLAMETHROWER.NORMAL)
end

function mod:OnSupernovaStart()
  mod:AddMsg("MIDPHASE_STARTED", "msg.midphase.started", 5, "Info", "xkcdWhite")
  mod:RemoveTimerBar("NEXT_HOOKSHOT_TIMER")
  mod:RemoveTimerBar("NEXT_FLAMETHROWER_TIMER")
end

function mod:OnHookshotEnd()
  mod:AddTimerBar("NEXT_HOOKSHOT_TIMER", "msg.hookshot.next", TIMERS.HOOKSHOT.NORMAL)
end

function mod:OnOctogCreated(id, unit)
  core:WatchUnit(unit, core.E.TRACK_CASTS + core.E.TRACK_HEALTH)
end

function mod:OnOctogHealthChanged(id, percent)
  if mod:IsPhaseClose(ORBS_CLOSE, percent) then
    mod:AddMsg("CHAOS_ORB_SOON", "msg.chaos.orbs.coming", 5, "Info", "xkcdWhite")
  end
  if mod:IsPhaseClose(PHASES_CLOSE, percent) then
    mod:AddMsg("MIDPHASE_SOON", "msg.midphase.coming", 5, "Info", "xkcdWhite")
  end
end

function mod:AddUnit(id, unit)
  core:AddUnit(unit)
end

mod:RegisterUnitEvents("unit.octog",{
    [core.E.UNIT_CREATED] = mod.OnOctogCreated,
    [core.E.HEALTH_CHANGED] = mod.OnOctogHealthChanged,
    ["cast.flamethrower"] = {
      [core.E.CAST_START] = mod.OnFlamethrowerStart,
      [core.E.CAST_END] = mod.OnFlamethrowerEnd,
    },
    ["cast.supernova"] = {
      [core.E.CAST_START] = mod.OnSupernovaStart,
    },
    ["cast.hookshot"] = {
      [core.E.CAST_END] = mod.OnHookshotEnd,
    },
  }
)

mod:RegisterUnitEvents({"unit.orb", "unit.octog"}, {
    [core.E.UNIT_CREATED] = mod.AddUnit,
  }
)
