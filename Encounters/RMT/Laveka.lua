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
local ApolloTimer = require "ApolloTimer"
local GameLib = require "GameLib"
local Vector3 = require "Vector3"

local core = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("RaidCore")
local mod = core:NewEncounter("Laveka", 104, 548, 559)
if not mod then return end

----------------------------------------------------------------------------------------------------
-- Registering combat.
----------------------------------------------------------------------------------------------------
mod:RegisterTrigMob(core.E.TRIGGER_ALL, { "unit.laveka" })
mod:RegisterEnglishLocale({
    -- Unit names.
    ["unit.laveka"] = "Laveka the Dark-Hearted",
    ["unit.essence"] = "Essence Void",
    ["unit.apparition"] = "Tortured Apparition",
    ["unit.soul_eater"] = "Soul Eater",
    ["unit.boneclaw"] = "Risen Boneclaw",
    ["unit.titan"] = "Risen Titan",
    ["unit.lost_soul"] = "Lost Soul",
    -- Cast names.
    ["cast.essence.surge"] = "Essence Surge", -- Essence fully materialized
    ["cast.laveka.devoursouls"] = "Devour Souls",
    ["cast.laveka.animate_bones"] = "Animate Bones",
    ["cast.laveka.essence"] = "Essence Void",
    ["cast.laveka.cacophony"] = "Cacophony of Souls",
    ["cast.laveka.expulsion"] = "Expulsion of Souls",
    ["cast.laveka.rend"] = "Rend the Spirit Veil",
    ["cast.titan.bulwark"] = "Necrotic Bulwark",
    ["cast.titan.manifest"] = "Manifest",
    ["cast.adds.explosion"] = "Spirit Ire",
    ["cast.apparition.fury"] = "Fury of the Restless Dead",
    ["cast.boneclaw.gaze"] = "Boneclaw Gaze",
    -- Datachrons.
    ["chron.laveka.mask"] = "You feel the Mask of Mog-Mog pulling at your spirit.",
    ["chron.laveka.soul_fire"] = "Laveka sets ([^%s]+%s[^']+)'s soul ablaze!",
    ["chron.laveka.death"] = "Death is only the beginning...",
    ["chron.laveka.cacophony"] = "Laveka unleashes a Cacaphony of Souls, devastating the Realm of the Living",
    ["chron.laveka.lastphase"] = "Laveka uses the Mask of Mog-Mog to rend the veil between this world and the next.",
    ["chron.realm.living"] = "Your spirit has returned to the mortal realm.",
    -- Messages.
    ["msg.laveka.soulfire.you"] = "SOULFIRE ON YOU",
    ["msg.laveka.spirit_of_soulfire"] = "Spirit of Soulfire",
    ["msg.laveka.expulsion"] = "STACK!",
    ["msg.laveka.echoes_of_the_afterlife.timer"] = "Echoes of Afterlife",
    ["msg.adds.next"] = "Next Titan in ...",
    ["msg.souleaters.next"] = "Next Soul Eaters in ...",
    ["msg.mid_phase.soon"] = "Mid phase soon",
    ["msg.essence.interrupt"] = "Interrupt Essence",
    ["msg.essence.number"] = "Essence ",
    ["msg.titan.breath"] = "Necrotic Breath on ",
    -- Markers
    ["mark.cardinal.NE"] = "NE",
    ["mark.cardinal.NW"] = "NW",
    ["mark.cardinal.SE"] = "SE",
    ["mark.cardinal.SW"] = "SW",
  }
)
mod:RegisterFrenchLocale({
    -- Unit names.
    ["unit.essence"] = "Vide d'essence",
    -- Cast names.
    ["cast.laveka.cacophony"] = "Cacophonie des âmes",
    ["cast.laveka.rend"] = "Déchire le voile spirituel",
    ["cast.titan.manifest"] = "Manifeste",
    ["cast.adds.explosion"] = "Courroux spirituel",
    -- Datachrons.
    ["chron.laveka.mask"] = "Vous sentez votre esprit attiré par le masque de Mog-Mog.",
    ["chron.laveka.cacophony"] = "Laveka libère une Cacophonie d'âmes qui dévaste le royaume des vivants.",
    ["chron.realm.living"] = "Votre esprit est revenu au royaume des mortels.",
    ["chron.laveka.lastphase"] = "Laveka utilise le masque de Mog-Mog pour déchirer le voile qui sépare ce monde de l'autre.",
  }
)
mod:RegisterGermanLocale({
    -- Unit names.
    ["unit.essence"] = "Essenzleere",
    -- Cast names.
    ["cast.essence.surge"] = "Essenzwoge", -- Essence fully materialized
    ["cast.laveka.cacophony"] = "Seelenkakophonie",
    ["cast.laveka.rend"] = "Geisterschleier zerreißen",
    -- ["cast.titan.manifest"] = "TODO",
    ["cast.adds.explosion"] = "Geisterzorn",
    -- Datachrons.
    ["chron.laveka.mask"] = "Du spürst, wie die Maske von Mog-Mog deinen Geist angreift.",
    ["chron.laveka.cacophony"] = "Laveka entfesselt eine Seelenkakophonie, die das Reich der Lebenden verwüstet.",
    ["chron.realm.living"] = "Dein Geist ist ins Reich der Sterblichen zurückgekehrt.",
    ["chron.laveka.lastphase"] = "Laveka nutzt die Maske von Mog-Mog, um den Schleier zwischen dieser und der nächsten Welt zu zerreißen.",
  }
)
----------------------------------------------------------------------------------------------------
-- Settings.
----------------------------------------------------------------------------------------------------
-- Visuals.
mod:RegisterDefaultSetting("LineCleanse", false)
mod:RegisterDefaultSetting("LineTitan", false)
mod:RegisterDefaultSetting("LineLostSouls")
mod:RegisterDefaultSetting("LineToYourBoneclaws")
mod:RegisterDefaultSetting("MarkHealingDebuff", false)
mod:RegisterDefaultSetting("MarkCardinal")
-- Messages.
mod:RegisterDefaultSetting("MessageMidphaseSoon")
mod:RegisterDefaultSetting("MessageEssence", false)
mod:RegisterDefaultSetting("MessageHealingDebuff", false)
-- Sounds.
mod:RegisterDefaultSetting("SoundMidphaseSoon")
mod:RegisterDefaultSetting("SoundCleanse", false)
mod:RegisterDefaultSetting("SoundEssenceSpawn", false)
mod:RegisterDefaultSetting("SoundHealingDebuff", false)
-- Essences.
for i = 1, 5 do
  mod:RegisterDefaultSetting("SoundEssence"..i, false)
  mod:RegisterDefaultSetting("LineEssence"..i, false)
end
-- Binds.
mod:RegisterMessageSetting("SPIRIT_OF_SOULFIRE_EXPIRED_MSG", core.E.COMPARE_EQUAL, nil, "SoundCleanse")
mod:RegisterMessageSetting("ESSENCE_SPAWN", core.E.COMPARE_EQUAL, "MessageEssence", "SoundEssenceSpawn")
mod:RegisterMessageSetting("NECROTIC_BREATH_", core.E.COMPARE_FIND, "MessageHealingDebuff", "SoundHealingDebuff")
mod:RegisterDefaultTimerBarConfigs({
    ["ADDS_TIMER"] = { sColor = "xkcdBrown" },
    ["SOULEATER_TIMER"] = { sColor = "xkcdPurple" },
    ["SPIRIT_OF_SOULFIRE_TIMER"] = { sColor = "xkcdBarbiePink" },
  }
)
mod:RegisterUnitBarConfig("unit.laveka", {
    nPriority = 0,
    tMidphases = {
      {percent = 75},
      {percent = 50},
      {percent = 25},
    }
  }
)
----------------------------------------------------------------------------------------------------
-- Functions.
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Constants.
----------------------------------------------------------------------------------------------------
local DEBUFFS = {
  EXPULSION_OF_SOULS = 87901, -- Runic circle debuff
  NECROTIC_EXPLOSION = 75610,
  SOUL_EATER = 87069,
  REALM_OF_THE_DEAD = 75528, -- When in dead world
  ECHOES_OF_THE_AFTERLIFE = 75525, -- stacking debuff
  SOULFIRE = 75574, -- Debuff to be cleansed
  NECROTIC_BREATH = 75608, -- Debuff to be healed
  BONECLAW_GAZE = 85609, -- Boneclaw target
}

local BUFFS = {
  SPIRIT_OF_SOULFIRE = 75576,
  MOMENT_OF_OPPORTUNITY = 54211,
  BARRIER_OF_SOULS = 87774, -- Midphase buff
}

local TIMERS = {
  SOUL_EATERS = {
    FIRST = 76,
    MIDPHASE = 61,
    NORMAL = 85,
  },
  ECHOES_OF_THE_AFTERLIFE = 10,
  ADDS = {
    FIRST = 35,
    MIDPHASE = 75,
    NORMAL = 90,
  }
}

local IND_REASONS = {
  SOUL_EATER_CAUGHT = 1,
}

local ROOM_CENTER = Vector3.New(-723.717773, 186.834915, -265.187195)

local CARDINAL_MARKERS = {
  ["NE"] = Vector3.New(-697.46, 189, -291),
  ["NW"] = Vector3.New(-750.67, 189, -291),
  ["SE"] = Vector3.New(-697.46, 189, -238.5),
  ["SW"] = Vector3.New(-750.67, 189, -238.5),
}

local SOUL_EATER_ORBITS = {
  [1] = Vector3.New(0, 0, 6),
  [2] = Vector3.New(0, 0, 12),
  [3] = Vector3.New(0, 0, 18),
  [4] = Vector3.New(0, 0, 24),
  [5] = Vector3.New(0, 0, 30),
  [6] = Vector3.New(0, 0, 36)
}
----------------------------------------------------------------------------------------------------
-- Locals.
----------------------------------------------------------------------------------------------------
local player
local essenceNumber
local essences
local isDeadRealm
local expulsionInThisRealm
local isMidphase
local lastSpiritOfSoulfireStack
local soulEatersActive
local lastSoulfireName
local orbitColor
local drawOrbitTimer
local currentSoulEater
local soulEaters
local boneclawsOnYou
local boneclawCheckDeadTimer = ApolloTimer.Create(1.0, true, "RemoveBoneclawLines", mod)
boneclawCheckDeadTimer:Stop()
----------------------------------------------------------------------------------------------------
-- Encounter description.
----------------------------------------------------------------------------------------------------
function mod:OnBossEnable()
  essenceNumber = 0
  currentSoulEater = 6
  isDeadRealm = false
  isMidphase = false
  expulsionInThisRealm = false
  lastSpiritOfSoulfireStack = 0
  soulEaters = {}
  essences = {}
  boneclawsOnYou = {}
  player = {}
  player.unit = GameLib.GetPlayerUnit()
  player.id = player.unit:GetId()
  player.name = player.unit:GetName()
  mod:AddTimerBar("ADDS_TIMER", "msg.adds.next", TIMERS.ADDS.FIRST)
  mod:StartSoulEaterTimer(TIMERS.SOUL_EATERS.FIRST)
  mod:SetCardinalMarkers()
end

function mod:OnBossDisable()
  mod:StopSoulEaterTimer()
  boneclawCheckDeadTimer:Stop()
end

function mod:StartSoulEaterTimer(seconds)
  if drawOrbitTimer ~= nil then
    drawOrbitTimer:Stop()
  end

  mod:AddTimerBar("SOULEATER_TIMER", "msg.souleaters.next", seconds, true)
  drawOrbitTimer = ApolloTimer.Create(seconds-5, false, "DrawSoulEaterOrbits", mod)
end

function mod:StopSoulEaterTimer()
  if drawOrbitTimer ~= nil then
    drawOrbitTimer:Stop()
  end

  drawOrbitTimer = nil
  mod:RemoveTimerBar("SOULEATER_TIMER")
end

function mod:SetCardinalMarkers()
  if not mod:GetSetting("MarkCardinal") then
    return
  end
  for direction, location in next, CARDINAL_MARKERS do
    mod:SetWorldMarker("CARDINAL_"..direction, "mark.cardinal."..direction, location)
  end
end

function mod:OnAnyUnitDestroyed(id, unit, name)
  local forceClear = false
  if name == player.name then
    forceClear = true
  end
  mod:RemoveSoulfireLine(name, forceClear)
  mod:RemoveNecroticBreathMark(id)
end

function mod:OnLavekaCreated(id, unit, name)
  mod:AddUnit(unit)
  core:WatchUnit(unit, core.E.TRACK_ALL)
end

function mod:OnSoulfireAdd(id, spellId, stack, timeRemaining, targetName)
  lastSoulfireName = targetName
  if targetName ~= player.name then
    mod:AddSoulfireLine(id, targetName)
  else
    core:MarkUnit(player.unit, core.E.LOCATION_STATIC_CHEST, "S", "xkcdBarbiePink")
    mod:AddMsg("SOULFIRE_MSG_YOU", "msg.laveka.soulfire.you", 5, "Burn", "xkcdBarbiePink")
  end
end

function mod:OnSoulfireRemove(id, spellId, targetName)
  mod:RemoveSoulfireLine(targetName, false)
end

function mod:AddSoulfireLine(id, name)
  if mod:GetSetting("LineCleanse") then
    core:AddLineBetweenUnits("SOULFIRE_LINE", player.unit, id, 7, "xkcdBarbiePink")
  end
end

function mod:RemoveSoulfireLine(name, forceClear)
  if forceClear or name == lastSoulfireName then
    if mod:GetSetting("LineCleanse") then
      core:RemoveLineBetweenUnits("SOULFIRE_LINE")
    end
  end
  if name == player.name then
    core:DropMark(player.id)
  end
end

function mod:OnSpiritOfSoulfireAdd(id, spellId, stack, timeRemaining, targetName)
  lastSpiritOfSoulfireStack = 0
  mod:AddSpiritOfSoulfireTimer(stack, timeRemaining)
end

function mod:OnSpiritOfSoulfireUpdate(id, spellId, stack, timeRemaining)
  mod:AddSpiritOfSoulfireTimer(stack, timeRemaining)
end

function mod:AddSpiritOfSoulfireTimer(stack, timeRemaining)
  if stack > lastSpiritOfSoulfireStack then
    mod:AddTimerBar("SPIRIT_OF_SOULFIRE_TIMER", self.L["msg.laveka.spirit_of_soulfire"].." "..tostring(stack), timeRemaining)
  end
  lastSpiritOfSoulfireStack = stack
end

function mod:OnSpiritOfSoulfireRemove(id, spellId, targetName)
  lastSpiritOfSoulfireStack = 0
  mod:AddMsg("SPIRIT_OF_SOULFIRE_EXPIRED_MSG", nil, 1, "Inferno")
  mod:RemoveTimerBar("SPIRIT_OF_SOULFIRE_TIMER")
end

function mod:OnExpulsionAdd(id, spellId, stack, timeRemaining, targetName)
  expulsionInThisRealm = true
  if isDeadRealm then
    mod:ShowExpulsionStackMessage()
  end
end

function mod:OnExpulsionStart()
  if not isDeadRealm and not expulsionInThisRealm then
    mod:ShowExpulsionStackMessage()
  end
end

function mod:OnExpulsionEnd()
  expulsionInThisRealm = false
end

function mod:ShowExpulsionStackMessage()
  mod:AddMsg("EXPULSION", "msg.laveka.expulsion", 5, "Beware", "xkcdRed")
end

function mod:OnEchoesAdd(id, spellId, stack, timeRemaining, targetName)
  mod:StartEchoesTimer(id)
end

function mod:OnEchoesUpdate(id, spellId, stack, timeRemaining)
  mod:StartEchoesTimer(id)
end

function mod:StartEchoesTimer(id)
  if id == player.id then
    mod:AddTimerBar("ECHOES_OF_THE_AFTERLIFE_TIMER", "msg.laveka.echoes_of_the_afterlife.timer", TIMERS.ECHOES_OF_THE_AFTERLIFE)
  end
end

function mod:OnEchoesRemove(id, spellId, targetName)
  if id == player.id then
    mod:RemoveTimerBar("ECHOES_OF_THE_AFTERLIFE_TIMER")
  end
end

function mod:OnNecroticBreathAdd(id, spellId, stack, timeRemaining, targetName)
  mod:AddMsg("NECROTIC_BREATH_"..id, self.L["msg.titan.breath"]..targetName, 5, "Beware", "xkcdLightYellow")
  if mod:GetSetting("MarkHealingDebuff") then
    core:MarkUnit(GameLib.GetUnitById(id), core.E.LOCATION_STATIC_CHEST, "H", "xkcdLightYellow")
  end
end

function mod:OnNecroticBreathRemove(id, spellId, targetName)
  mod:RemoveNecroticBreathMark(id)
end

function mod:RemoveNecroticBreathMark(id)
  if mod:GetSetting("MarkHealingDebuff") then
    core:DropMark(id)
  end
end

function mod:ToggleDeadRealm(id)
  if id == player.id then
    isDeadRealm = not isDeadRealm
    expulsionInThisRealm = false -- just incase the player switches to other realm in the 100ms frame between DEBUFF_ADD and CAST_START
    if not isDeadRealm then
      mod:RemoveLostSoulLine()
    end
  end
end

function mod:OnRealmOfTheDeadAdd(id, spellId, stack, timeRemaining, targetName)
  mod:StartEchoesTimer(id)
  mod:ToggleDeadRealm(id)
end

function mod:OnRealmOfTheDeadRemove(id, spellId, stack, timeRemaining, targetName)
  mod:ToggleDeadRealm(id)
end

function mod:OnEssenceCreated(id, unit, name)
  core:WatchUnit(unit, core.E.TRACK_CASTS)
  essenceNumber = essenceNumber + 1
  if essenceNumber % 6 == 0 then
    essenceNumber = 1
  end
  essences[id] = {
    number = essenceNumber,
  }
  core:MarkUnit(unit, core.E.LOCATION_STATIC_FLOOR, essenceNumber)
  if mod:GetSetting("LineEssence"..essenceNumber) then
    core:AddLineBetweenUnits("ESSENCE_LINE"..id, player.unit, id, 8, "xkcdPurple")
  end
  mod:AddMsg("ESSENCE_SPAWN", self.L["msg.essence.number"]..essenceNumber, 5, "Info", "xkcdWhite")
end

function mod:OnEssenceDestroyed(id, unit, name)
  essences[id] = nil
end

function mod:OnEssenceSurgeStart(id)
  if mod:GetSetting("SoundEssence"..essences[id].number) then
    mod:AddMsg("ESSENCE_CAST", "msg.essence.interrupt", 2, "Inferno", "xkcdOrange")
  end
end

function mod:OnSoulEaterCreated(id, unit, name)
  soulEaters[id] = {
    id = id,
    index = currentSoulEater,
    unit = unit
  }

  currentSoulEater = currentSoulEater - 1
  if currentSoulEater == 0 then
    currentSoulEater = 6
  end

  if not soulEatersActive then
    soulEatersActive = true
    mod:DrawSoulEaterOrbits()
  end
end

function mod:OnSoulEaterDestroyed(id, unit, name)
  soulEaters[id] = nil
end

function mod:OnSoulEaterCaught(id, spellId, stacks, timeRemaining, name, unitCaster)
  if unitCaster and unitCaster:IsValid() then
    local index = soulEaters[unitCaster:GetId()].index
    mod:RemoveSoulEaterOrbit(index)
    mod:SendIndMessage(IND_REASONS.SOUL_EATER_CAUGHT, index)
  end
end

function mod:ReceiveIndMessage(from, reason, data)
  if reason == IND_REASONS.SOUL_EATER_CAUGHT then
    mod:RemoveSoulEaterOrbit(data)
  end
end

function mod:OnDevourSoulsStop()
  soulEatersActive = false
  mod:RemoveSoulEaterOrbits()
  mod:StartSoulEaterTimer(TIMERS.SOUL_EATERS.NORMAL)
end

function mod:DrawSoulEaterOrbits()
  for i = 1, #SOUL_EATER_ORBITS do
    mod:DrawSoulEaterOrbit(i)
  end
end

function mod:DrawSoulEaterOrbit(index)
  local radius = SOUL_EATER_ORBITS[index]
  if math.mod(index, 2) == 0 then
    orbitColor = "xkcdWhite"
  else
    orbitColor = "xkcdRed"
  end
  core:AddPolygon("ORBIT_"..index, ROOM_CENTER, radius.z, nil, 2, orbitColor, 40)
  mod:SetWorldMarker("ORBIT_"..index, index, ROOM_CENTER + radius)
end

function mod:RemoveSoulEaterOrbits()
  for i = 1, #SOUL_EATER_ORBITS do
    mod:RemoveSoulEaterOrbit(i)
  end
end

function mod:RemoveSoulEaterOrbit(index)
  core:RemovePolygon("ORBIT_"..index)
  mod:DropWorldMarker("ORBIT_"..index)
end

function mod:OnMidphaseStart()
  isMidphase = true
  mod:RemoveTimerBar("ADDS_TIMER")
  mod:StopSoulEaterTimer()
  if next(soulEaters) == nil then
    mod:RemoveSoulEaterOrbits()
  end
end

function mod:OnMidphaseEnd()
  isMidphase = false
  mod:RemoveTimerBar("ADDS_TIMER")
  mod:StartSoulEaterTimer(TIMERS.SOUL_EATERS.MIDPHASE)
end

function mod:OnTitanCreated(id, unit, name)
  mod:AddUnit(unit)
  if mod:GetSetting("LineTitan") then
    core:AddLineBetweenUnits("TITAN_LINE_"..id, player.unit, id, 7, "xkcdLightYellow")
  end
  if not isDeadRealm then
    local timer = isMidphase and TIMERS.ADDS.MIDPHASE or TIMERS.ADDS.NORMAL
    mod:AddTimerBar("ADDS_TIMER", "msg.adds.next", timer)
  end
end

function mod:OnLostSoulCreated(id, unit, name)
  if mod:GetSetting("LineLostSouls") and isDeadRealm then
    core:AddLineBetweenUnits("LOST_SOUL_LINE", player.unit, id, 10, "xkcdGreen")
  end
end

function mod:OnLavekaHealthChanged(id, percent, name)
  if mod:IsMidphaseClose(name, percent) then
    mod:AddMsg("MID_PHASE", "msg.mid_phase.soon", 5, "Info", "xkcdWhite")
  end
end

function mod:RemoveLostSoulLine()
  core:RemoveLineBetweenUnits("LOST_SOUL_LINE")
end

function mod:RemoveBoneclawLines()
  local toRemove = {}
  for id, boneclaw in next, boneclawsOnYou do
    if not boneclaw.unit:IsValid() or boneclaw.unit:IsDead() then
      core:RemoveLineBetweenUnits(id)
      table.insert(toRemove, id)
    end
  end
  for i = 1, #toRemove do
    boneclawsOnYou[toRemove[i]] = nil
  end
end

function mod:OnBoneclawGazeAdd(id, spellId, stacks, timeRemaining, name, unitCaster)
  if mod:GetSetting("LineToYourBoneclaws") and name == player.name and unitCaster and unitCaster:IsValid() then
    local boneclawId = unitCaster:GetId()
    boneclawsOnYou[boneclawId] = {id = boneclawId, unit = unitCaster}
    core:AddLineBetweenUnits(boneclawId, player.unit, unitCaster, 10, "xkcdOrange")
    boneclawCheckDeadTimer:Start()
  end
end

function mod:OnBoneclawGazeRemove(id, spellId, name, unitCaster)
  boneclawCheckDeadTimer:Stop()
  if unitCaster and unitCaster:IsValid() then
    local boneclawId = unitCaster:GetId()
    boneclawsOnYou[boneclawId] = nil
    core:RemoveLineBetweenUnits(boneclawId)
  else
    mod:RemoveBoneclawLines()
  end
end

function mod:OnBoneclawDestroyed(id, unit, name)
  if boneclawsOnYou[id] then
    boneclawsOnYou[id] = nil
  end
end

function mod:OnCacophonyStart()
  essenceNumber = 0
end

function mod:OnLastPhase()
  mod:StopSoulEaterTimer()
  mod:RemoveTimerBar("ADDS_TIMER")
end

----------------------------------------------------------------------------------------------------
-- Bind event handlers.
----------------------------------------------------------------------------------------------------
mod:RegisterUnitEvents("unit.essence",{
    [core.E.UNIT_CREATED] = mod.OnEssenceCreated,
    [core.E.UNIT_DESTROYED] = mod.OnEssenceDestroyed,
    ["cast.essence.surge"] = {
      [core.E.CAST_START] = mod.OnEssenceSurgeStart,
    },
  }
)
mod:RegisterUnitEvents("unit.titan",{
    [core.E.UNIT_CREATED] = mod.OnTitanCreated,
  }
)
mod:RegisterUnitEvents("unit.lost_soul",{
    [core.E.UNIT_CREATED] = mod.OnLostSoulCreated,
  }
)
mod:RegisterUnitEvents("unit.soul_eater",{
    [core.E.UNIT_CREATED] = mod.OnSoulEaterCreated,
    [core.E.UNIT_DESTROYED] = mod.OnSoulEaterDestroyed,
  }
)
mod:RegisterUnitEvents("unit.laveka",{
    [core.E.UNIT_CREATED] = mod.OnLavekaCreated,
    [core.E.HEALTH_CHANGED] = mod.OnLavekaHealthChanged,
    [BUFFS.SPIRIT_OF_SOULFIRE] = {
      [core.E.BUFF_ADD] = mod.OnSpiritOfSoulfireAdd,
      [core.E.BUFF_UPDATE] = mod.OnSpiritOfSoulfireUpdate,
      [core.E.BUFF_REMOVE] = mod.OnSpiritOfSoulfireRemove,
    },
    [BUFFS.BARRIER_OF_SOULS] = {
      [core.E.BUFF_ADD] = mod.OnMidphaseStart,
      [core.E.BUFF_REMOVE] = mod.OnMidphaseEnd,
    },
    ["cast.laveka.devoursouls"] = {
      [core.E.CAST_END] = mod.OnDevourSoulsStop,
    },
    ["cast.laveka.cacophony"] = {
      [core.E.CAST_START] = mod.OnCacophonyStart,
    },
    ["cast.laveka.expulsion"] = {
      [core.E.CAST_START] = mod.OnExpulsionStart,
      [core.E.CAST_END] = mod.OnExpulsionEnd,
    },
  }
)

mod:RegisterUnitEvents("unit.boneclaw",{
    [core.E.UNIT_DESTROYED] = mod.OnBoneclawDestroyed,
  }
)
mod:RegisterUnitEvents(core.E.ALL_UNITS,{
    [core.E.UNIT_DESTROYED] = mod.OnAnyUnitDestroyed,
    [DEBUFFS.SOULFIRE] = {
      [core.E.DEBUFF_ADD] = mod.OnSoulfireAdd,
      [core.E.DEBUFF_REMOVE] = mod.OnSoulfireRemove,
    },
    [DEBUFFS.SOUL_EATER] = {
      [core.E.DEBUFF_ADD] = mod.OnSoulEaterCaught,
    },
    [DEBUFFS.EXPULSION_OF_SOULS] = {
      [core.E.DEBUFF_ADD] = mod.OnExpulsionAdd,
    },
    [DEBUFFS.ECHOES_OF_THE_AFTERLIFE] = {
      [core.E.DEBUFF_ADD] = mod.OnEchoesAdd,
      [core.E.DEBUFF_UPDATE] = mod.OnEchoesUpdate,
      [core.E.DEBUFF_REMOVE] = mod.OnEchoesRemove,
    },
    [DEBUFFS.REALM_OF_THE_DEAD] = {
      [core.E.DEBUFF_ADD] = mod.OnRealmOfTheDeadAdd,
      [core.E.DEBUFF_REMOVE] = mod.OnRealmOfTheDeadRemove,
    },
    [DEBUFFS.NECROTIC_BREATH] = {
      [core.E.DEBUFF_ADD] = mod.OnNecroticBreathAdd,
      [core.E.DEBUFF_REMOVE] = mod.OnNecroticBreathRemove,
    },
    [DEBUFFS.BONECLAW_GAZE] = {
      [core.E.DEBUFF_ADD] = mod.OnBoneclawGazeAdd,
      [core.E.DEBUFF_REMOVE] = mod.OnBoneclawGazeRemove,
    }
  }
)
mod:RegisterDatachronEvent("chron.laveka.lastphase", core.E.COMPARE_EQUAL, mod.OnLastPhase)
