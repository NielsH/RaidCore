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
local mod = core:NewEncounter("Shredder", 104, 548, 549)
if not mod then return end

----------------------------------------------------------------------------------------------------
-- TODO
----------------------------------------------------------------------------------------------------
--make tether visible, probably have to add rectangles to raidcore
--add phases are different later on

----------------------------------------------------------------------------------------------------
-- Registering combat.
----------------------------------------------------------------------------------------------------
mod:RegisterTrigMob("ALL", { "Swabbie Ski'Li" })
mod:RegisterEnglishLocale({
    --Unit names
    ["Swabbie Ski'Li"] = "Swabbie Ski'Li",
    ["Sawblade"] = "Sawblade", -- big saw
    ["Saw"] = "Saw", -- little saw
    ["Noxious Nabber"] = "Noxious Nabber",
    ["Risen Redmoon Grunt"] = "Risen Redmoon Grunt",
    ["Regor the Rancid"] = "Regor the Rancid",
    ["Braugh the Bloated"] = "Braugh the Bloated",
    ["Bilious Brute"] = "Bilious Brute",
    ["Putrid Pouncer"] = "Putrid Pouncer",
    ["Risen Redmoon Plunderer"] = "Risen Redmoon Plunderer",
    ["Risen Redmoon Cadet"] = "Risen Redmoon Cadet",
    ["Tether Anchor"] = "Tether Anchor",
    ["Junk Trap"] = "Junk Trap",
    -- Datachron messages.
    ["WARNING: THE SHREDDER IS STARTING!"] = "WARNING: THE SHREDDER IS STARTING!",
    --Cast names
    ["Swabbie Swoop"] = "Swabbie Swoop",
    ["Risen Repellent"] = "Risen Repellent",
    ["Crush"] = "Crush",
    ["Gravedigger"] = "Gravedigger",
    ["Deathwail"] = "Deathwail",
    ["Necrotic Lash"] = "Necrotic Lash",
    ["Swabbie Swoop"] = "Swabbie Swoop",
    --Messages
    ["%d BILE STACKS!"] = "%d BILE STACKS!",
  })

mod:RegisterFrenchLocale({
    -- --Unit names
    -- ["Swabbie Ski'Li"] = "Swabbie Ski'Li",
    -- ["Sawblade"] = "Sawblade", -- big saw
    -- ["Saw"] = "Saw", -- little saw
    -- ["Noxious Nabber"] = "Noxious Nabber",
    -- ["Risen Redmoon Grunt"] = "Risen Redmoon Grunt",
    -- ["Regor the Rancid"] = "Regor the Rancid",
    -- ["Braugh the Bloated"] = "Braugh the Bloated",
    -- ["Bilious Brute"] = "Bilious Brute",
    -- ["Putrid Pouncer"] = "Putrid Pouncer",
    -- ["Risen Redmoon Plunderer"] = "Risen Redmoon Plunderer",
    -- ["Risen Redmoon Cadet"] = "Risen Redmoon Cadet",
    -- -- Datachron messages.
    -- ["WARNING: THE SHREDDER IS STARTING!"] = "WARNING: THE SHREDDER IS STARTING!",
    -- --Cast names
    -- ["Swabbie Swoop"] = "Swabbie Swoop",
    -- ["Risen Repellent"] = "Risen Repellent",
    -- ["Crush"] = "Crush",
    -- ["Gravedigger"] = "Gravedigger",
    -- ["Deathwail"] = "Deathwail",
    -- ["Necrotic Lash"] = "Necrotic Lash",
    -- ["Swabbie Swoop"] = "Swabbie Swoop",
  })
----------------------------------------------------------------------------------------------------
-- Settings
----------------------------------------------------------------------------------------------------
mod:RegisterDefaultSetting("LineSawblade")
mod:RegisterDefaultSetting("SquareTethers")
mod:RegisterDefaultSetting("CrosshairAdds")
mod:RegisterDefaultSetting("CrosshairPriority")
mod:RegisterDefaultSetting("CrosshairTether")
mod:RegisterDefaultSetting("SoundAdds")
mod:RegisterDefaultSetting("SoundMiniboss")
mod:RegisterDefaultSetting("SoundNecroticLash")
mod:RegisterDefaultSetting("SoundMinibossCast")
mod:RegisterDefaultSetting("SoundOozeStacksWarning")
----------------------------------------------------------------------------------------------------
-- Constants.
----------------------------------------------------------------------------------------------------
-- circular array metatable
local function wrap(t, k)
  return ((k-1)%(#t))+1
end
local lmt = {
  __index = function(t, k)
    if type(k) == "number" then
      return rawget(t, wrap(t, k))
    else
      return nil
    end
  end
}
-- turns a table into a circular array
function circular(t)
  return setmetatable(t, lmt)
end

local START_POSITION = Vector3.New({x = -20.054916381836,y = 597.66021728516,z = -809.42694091797})
local END_POSITION = Vector3.New({x = -20.499969482422,y = 597.88836669922,z = -973.21472167969})
local WALKING_DISTANCE = (END_POSITION-START_POSITION):Length()
local NO_BREAK_SPACE = string.char(194, 160)
local WALKING = 0
local SHREDDER = 1
local ADD_PHASES = circular{ 11, 45, 66, 0 }
local DEBUFF_OOZING_BILE = 84321
----------------------------------------------------------------------------------------------------
-- Locals.
----------------------------------------------------------------------------------------------------
local GetUnitById = GameLib.GetUnitById
local GetPlayerUnit = GameLib.GetPlayerUnit
local GetGameTime = GameLib.GetGameTime
local phase
local addPhase
local previousAddPhase
----------------------------------------------------------------------------------------------------
-- Encounter description.
-----------------------------------------------------------------------------------------------------

function mod:OnBossEnable()
  phase = WALKING
  addPhase = 4
  previousAddPhase = 0
end

function mod:OnDebuffUpdate(nId, nSpellId, nStack, fTimeRemaining)
  if DEBUFF_OOZING_BILE == nSpellId then
    if GameLib.GetPlayerUnit():GetId() == nId and nStack >= 8 then
      mod:AddMsg("OOZE_MSG", string.format(self.L["%d BILE STACKS!"], nStack), 5, nStack == 8 and mod:GetSetting("SoundOozeStacksWarning") and "Beware")
    end
  end
end

function mod:GetWalkingProgress()
  local pos1
  local pos2
  if phase == WALKING then
    pos1 = Vector3.New(mod.swabbieUnit:GetPosition())
    pos2 = START_POSITION
  elseif phase == SHREDDER then
    pos1 = END_POSITION
    pos2 = Vector3.New(mod.swabbieUnit:GetPosition())
  end
  local walkedDistance = (pos1 - pos2):Length()
  local progress = (walkedDistance / WALKING_DISTANCE) * 100
  return progress
end

function mod:GetAddSpawnProgess()
  local currentProgress = mod:GetWalkingProgress() - previousAddPhase
  local waveSpawn = ADD_PHASES[addPhase] - previousAddPhase
  return (currentProgress/waveSpawn)*100
end

function mod:NextAddWave()
  if ADD_PHASES[addPhase] ~= 0 then
    mod:AddMsg("ADDS_MSG", "ADDS SPAWNING", 5, mod:GetSetting("SoundAdds") and "Info")
  end
  previousAddPhase = ADD_PHASES[addPhase]
  addPhase = addPhase + 1
  if ADD_PHASES[addPhase] ~= 0 then
    mod:AddProgressBar("ADDS_PROGRESS", "Next wave of adds spawning ...", mod.GetAddSpawnProgess, mod, mod.NextAddWave)
  end
end

function mod:PhaseChange()
  local sText = "Walking "
  if phase == SHREDDER then
    phase = WALKING
    sText = sText.." North"
    mod:NextAddWave()
  else
    sText = sText.." South"
    phase = SHREDDER
  end
  mod:AddProgressBar("WALKING_PROGRESS", sText, mod.GetWalkingProgress, mod, mod.PhaseChange)
end

function mod:StartProgressBar()
  mod:AddProgressBar("WALKING_PROGRESS", "Walking North", mod.GetWalkingProgress, mod, mod.PhaseChange)
  mod:NextAddWave()
  _tStartProgressBar:Stop()
  _tStartProgressBar = nil
end

mod:RegisterUnitEvents({
    "Noxious Nabber",
    "Risen Redmoon Grunt",
    "Regor the Rancid",
    "Braugh the Bloated",
    "Bilious Brute",
    "Putrid Pouncer",
    "Risen Redmoon Plunderer",
    "Risen Redmoon Cadet"
    },{
    ["OnUnitCreated"] = function (self, nId, tUnit, sName)
      core:WatchUnit(tUnit)
    end,
    ["OnUnitDestroyed"] = function (self, nId, tUnit, sName)
      core:RemovePicture(nId)
    end,
    ["OnHealthChanged"] = function (self, nId, nPourcent, sName)
      if nPourcent <= 1 and mod:GetSetting("CrosshairAdds") then
        core:AddPicture(nId, nId, "Crosshair", 20)
      end
    end,
  }
)

mod:RegisterUnitEvents({ "Bilious Brute", "Noxious Nabber" },{
    ["OnUnitCreated"] = function (self, nId, tUnit, sName)
      if mod:GetSetting("CrosshairPriority") then
        core:AddPicture(nId, nId, "Crosshair", 30, 0, 0, nil, "red")
      end
    end,
  }
)

mod:RegisterUnitEvents("Swabbie Ski'Li",{
    ["OnUnitCreated"] = function (self, nId, tUnit, sName)
      core:AddUnit(tUnit)
      core:WatchUnit(tUnit)
      self.swabbieUnit = tUnit
    end,
    ["OnUnitDestroyed"] = function (self, nId, tUnit, sName)
      core:RemoveUnit(tUnit)
      self:RemoveProgressBar("WALKING_PROGRESS")
      self:RemoveProgressBar("ADDS_PROGRESS")
    end,
    ["OnCastStart"] = function (self, nId, sCastName, nCastEndTime, sName)
      if self.L["Risen Repellent"] == sCastName then
        mod:AddMsg("KNOCKBACK", "KNOCKBACK", 2)
      end
    end,
    ["OnCastEnd"] = function (self, nId, sCastName, isInterrupted, nCastEndTime, sName)
      if self.L["Swabbie Swoop"] == sCastName then
        _tStartProgressBar = ApolloTimer.Create(1, true, "StartProgressBar", mod)
        _tStartProgressBar:Start()
      end
    end,
  }
)

mod:RegisterUnitEvents("Sawblade",{
    ["OnUnitCreated"] = function (self, nId, tUnit, sName)
      if mod:GetSetting("LineSawblade") then
        core:AddPixie(nId, 2, tUnit, nil, "Red", 10, 60, 0)
      end
    end,
    ["OnUnitDestroyed"] = function (self, nId, tUnit, sName)
      core:DropPixie(nId)
    end,
  }
)

mod:RegisterUnitEvents("Noxious Nabber",{
    ["OnUnitCreated"] = function (self, nId, tUnit, sName)
      core:RemoveMsg("ADDS_MSG")
      mod:AddMsg("ADDS_MSG", "NOXIOUS NABBER SPAWNED", 5, mod:GetSetting("SoundAdds") and "Info")
    end,
    ["OnCastStart"] = function (self, nId, sCastName, nCastEndTime, sName)
      if self.L["Necrotic Lash"] == sCastName then
        local tUnit = GetUnitById(nId)
        if mod:GetDistanceBetweenUnits(playerUnit, tUnit) < 45 and sSpellName == sCastName then
          mod:AddMsg("NABBER", "INTERRUPT NECROTIC LASH!", 5, mod:GetSetting("SoundNecroticLash") == true and "Inferno")
        end
      end
    end,
  }
)

mod:RegisterUnitEvents({"Regor the Rancid", "Braugh the Bloated"},{
    ["OnUnitCreated"] = function (self, nId, tUnit, sName)
      mod:AddMsg("MINIBOSS", "MINIBOSS SPAWNED", 5, mod:GetSetting("SoundMiniboss") and "Info")
    end,
    ["OnCastStart"] = function (self, nId, sCastName, nCastEndTime, sName)
      if self.L["Gravedigger"] == sCastName or
      self.L["Deathwail"] == sCastName or
      self.L["Crush"] == sCastName then
        core:RemoveMsg("MINIBOSS")
        mod:AddMsg("MINIBOSS", "INTERRUPT MINIBOSS!", 5, mod:GetSetting("SoundMinibossCast") and "Inferno")
      end
    end,
  }
)

mod:RegisterUnitEvents("Tether Anchor",{
    ["OnUnitCreated"] = function (self, nId, tUnit, sName)
      if mod:GetSetting("CrosshairTether") then
        core:AddPicture(nId, nId, "Crosshair", 25, 0, 0, nil, "FFFFF569")
      end
    end,
    ["OnUnitDestroyed"] = function (self, nId, tUnit, sName)
      core:RemovePicture(nId)
    end,
  }
)

mod:RegisterUnitEvents("Junk Trap",{
    ["OnUnitCreated"] = function (self, nId, tUnit, sName)
      if mod:GetSetting("SquareTethers") then
        core:AddPolygon(nId, nId, 5, 45, 6, nil, 4)
      end
    end,
    ["OnUnitDestroyed"] = function (self, nId, tUnit, sName)
      core:RemovePolygon(nId)
    end,
  }
)
