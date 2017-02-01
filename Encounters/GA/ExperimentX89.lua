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
local mod = core:NewEncounter("ExperimentX89", 67, 147, 148)
if not mod then return end

----------------------------------------------------------------------------------------------------
-- Registering combat.
----------------------------------------------------------------------------------------------------
mod:RegisterTrigMob(core.E.TRIGGER_ANY, { "unit.x89" })
mod:RegisterEnglishLocale({
    -- Unit names.
    ["unit.x89"] = "Experiment X-89",
    -- Datachron messages.
    ["chron.x89.bomb"] = "Experiment X%-89 has placed a bomb on (.*)!",
    -- Cast.
    ["cast.x89.shockwave"] = "Shattering Shockwave",
    ["cast.x89.spew"] = "Repugnant Spew",
    ["cast.x89.knockback"] = "Resounding Shout",
    -- Timer bars.
    ["msg.bomb.big"] = "Big bomb on %s",
    ["msg.bomb.little"] = "Little bomb on %s",
    -- Message bars.
    ["msg.knockback"] = "KNOCKBACK",
    ["msg.spew"] = "SPEW",
    ["msg.shockwave"] = "SHOCKWAVE",
  }
)
mod:RegisterFrenchLocale({
    -- Unit names.
    ["unit.x89"] = "Expérience X-89",
    -- Datachron messages.
    ["chron.x89.bomb"] = "L'expérience X%-89 a posé une bombe sur (.*) !",
    -- Cast.
    ["cast.x89.shockwave"] = "Onde de choc dévastatrice",
    ["cast.x89.spew"] = "Crachat répugnant",
    ["cast.x89.knockback"] = "Hurlement retentissant",
    -- Timer bars.
    ["msg.bomb.big"] = "Grosse bombe sur %s",
    ["msg.bomb.little"] = "Petite bombe sur %s",
    -- Message bars.
    ["msg.knockback"] = "KNOCKBACK",
    ["msg.spew"] = "CRACHAT",
    ["msg.shockwave"] = "ONDE DE CHOC",
  }
)
mod:RegisterGermanLocale({
    -- Unit names.
    ["unit.x89"] = "Experiment X-89",
    -- Datachron messages.
    ["chron.x89.bomb"] = "Experiment X%-89 hat eine Bombe auf (.*)!",
    -- Cast.
    ["cast.x89.shockwave"] = "Zerschmetternde Schockwelle",
    ["cast.x89.spew"] = "Widerliches Erbrochenes",
    ["cast.x89.knockback"] = "Widerhallender Schrei",
    -- Timer bars.
    -- Message bars.
    ["msg.knockback"] = "RÜCKSTOß",
    ["msg.spew"] = "ERBROCHENES",
    ["msg.shockwave"] = "SCHOCKWELLE",
  }
)
-- Default settings.
mod:RegisterDefaultSetting("LineExperimentX89")
mod:RegisterDefaultSetting("LineBigBomb")
mod:RegisterDefaultSetting("LineLittleBomb")
mod:RegisterDefaultSetting("PictureBigBomb")
mod:RegisterDefaultSetting("PictureLittleBomb")
mod:RegisterDefaultSetting("SoundLittleBomb")
mod:RegisterDefaultSetting("SoundBigBomb")
-- Timers default configs.
mod:RegisterDefaultTimerBarConfigs({
    ["LittleBomb"] = { sColor = "xkcdBottleGreen" },
    ["BigBomb"] = { sColor = "xkcdAubergine" },
  }
)

----------------------------------------------------------------------------------------------------
-- Constants.
----------------------------------------------------------------------------------------------------
local DEBUFFS = {
  LITTLE_BOMB = 47316,
  BIG_BOMB = 47285,
}
----------------------------------------------------------------------------------------------------
-- Locals.
----------------------------------------------------------------------------------------------------
local nExperimentX89Id
local player
----------------------------------------------------------------------------------------------------
-- Encounter description.
----------------------------------------------------------------------------------------------------
function mod:OnBossEnable()
  player = {}
  player.unit = GameLib.GetPlayerUnit()
  player.name = player.unit:GetName()
  player.id = player.unit:GetId()
  nExperimentX89Id = nil
end

function mod:OnLittleBombAdd(id, spellId, stack, timeRemaining, name, unitCaster)
  local isPlayer = id == player.id
  local sText = self.L["msg.bomb.little"]:format(name)

  if mod:GetSetting("LineLittleBomb") then
    local o = core:AddLineBetweenUnits(id, nExperimentX89Id, id, nil, "blue")
    o:SetMaxLengthVisible(40)
  end

  if mod:GetSetting("PictureLittleBomb") then
    core:AddPicture(id, id, "Crosshair", 20, 0, 0, nil, "blue")
  end

  mod:AddMsg("LittleBomb", sText:upper(), 3, nil, "blue")
  local bCountDownLittleBomb = mod:GetSetting("SoundLittleBomb") and isPlayer
  mod:AddTimerBar("LittleBomb", sText, timeRemaining - 1, bCountDownLittleBomb)

  if isPlayer and mod:GetSetting("SoundLittleBomb")then
    core:PlaySound("RunAway")
  end
end

function mod:OnBigBombAdd(id, spellId, stack, timeRemaining, name, unitCaster)
  local isPlayer = id == player.id
  local sText = self.L["msg.bomb.big"]:format(name)

  if mod:GetSetting("LineBigBomb") then
    local o = core:AddLineBetweenUnits(id, nExperimentX89Id, id, nil, "red")
    o:SetMaxLengthVisible(40)
  end

  if mod:GetSetting("PictureBigBomb") then
    core:AddPicture(id, id, "Crosshair", 40, 0, 0, nil, "red")
  end

  mod:AddMsg("BigBomb", sText:upper(), 3, nil, "red")
  local bCountDownBigBomb = mod:GetSetting("SoundBigBomb") and isPlayer
  mod:AddTimerBar("BigBomb", sText, timeRemaining - 2, bCountDownBigBomb)

  if isPlayer and mod:GetSetting("SoundBigBomb") then
    core:PlaySound("RunAway")
  end
end

function mod:RemoveDraws(id)
  core:RemovePicture(id)
  core:RemoveLineBetweenUnits(id)
end

function mod:OnX89Created(id, unit, name)
  nExperimentX89Id = id
  mod:AddUnit(unit)
  core:WatchUnit(unit, core.E.TRACK_CASTS)
  if mod:GetSetting("LineExperimentX89") then
    core:AddSimpleLine("Cleave", id, 0, 5, 0, 8, "green")
  end
end

function mod:OnX89Destroyed(id, unit, name)
  core:RemoveSimpleLine("Cleave")
end

function mod:OnKnockbackStart()
  mod:AddMsg("KNOCKBACK", "msg.knockback", 3, "Alert")
end

function mod:OnSpewStart()
  mod:AddMsg("SPEW", "msg.spew", 3, "Info")
end
----------------------------------------------------------------------------------------------------
-- Bind event handlers.
----------------------------------------------------------------------------------------------------
mod:RegisterUnitEvents(core.E.ALL_UNITS, {
    [core.E.UNIT_DESTROYED] = mod.RemoveDraws,
    [DEBUFFS.LITTLE_BOMB] = {
      [core.E.DEBUFF_ADD] = mod.OnLittleBombAdd,
      [core.E.DEBUFF_REMOVE] = mod.RemoveDraws,
    },
    [DEBUFFS.BIG_BOMB] = {
      [core.E.DEBUFF_ADD] = mod.OnBigBombAdd,
      [core.E.DEBUFF_REMOVE] = mod.RemoveDraws,
    },
  }
)
mod:RegisterUnitEvents("unit.x89", {
    [core.E.UNIT_CREATED] = mod.OnX89Created,
    [core.E.UNIT_DESTROYED] = mod.OnX89Destroyed,
    [core.E.CAST_START] = {
      ["cast.x89.knockback"] = mod.OnKnockbackStart,
      ["cast.x89.spew"] = mod.OnSpewStart,
    },
  }
)
