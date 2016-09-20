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
local mod = core:NewEncounter("Mordechai", 104, 0, 548)
if not mod then return end

----------------------------------------------------------------------------------------------------
-- Registering combat.
----------------------------------------------------------------------------------------------------
mod:RegisterTrigMob("ALL", { "unit.mordechai" })
mod:RegisterEnglishLocale({
    -- Unit names.
    ["unit.mordechai"] = "Mordechai Redmoon",
    ["unit.anchor"] = "Airlock Anchor",

    -- Markers
    ["mark.anchor_1"] = "1",
    ["mark.anchor_2"] = "2",
    ["mark.anchor_3"] = "3",
    ["mark.anchor_4"] = "4",
  })
----------------------------------------------------------------------------------------------------
-- Constants.
----------------------------------------------------------------------------------------------------
local ANCHOR_POSITIONS = {
  [1] = { x = 95.218872070313, y = 353.88098144531, z = 179.7458190918 },
  [2] = { x = 124.08588409424, y = 353.88098144531, z = 180.36109924316 },
  [3] = { x = 124.26425933838, y = 353.88098144531, z = 209.03805541992 },
  [4] = { x = 91.851860046387, y = 353.88098144531, z = 209.14315795898 },
}
----------------------------------------------------------------------------------------------------
-- Encounter description.
----------------------------------------------------------------------------------------------------
function mod:OnBossEnable()
  mod:SetWorldMarker("ANCHOR_1", "mark.anchor_1", ANCHOR_POSITIONS[1])
  mod:SetWorldMarker("ANCHOR_2", "mark.anchor_2", ANCHOR_POSITIONS[2])
  mod:SetWorldMarker("ANCHOR_3", "mark.anchor_3", ANCHOR_POSITIONS[3])
  mod:SetWorldMarker("ANCHOR_4", "mark.anchor_4", ANCHOR_POSITIONS[4])
end

function mod:OnBossDisable()
end

mod:RegisterUnitEvents("unit.mordechai",{
  [core.E.UNIT_CREATED] = function(_, id, unit)
    core:AddUnit(unit)
    core:WatchUnit(unit)
    core:AddSimpleLine("CLEAVE_FRONT_RIGHT", id, 3.5, 40, 24.5, 5, "white", nil, 3)
    core:AddSimpleLine("CLEAVE_BACK_RIGHT", id, 3.5, 40, 180-24.5, 5, "white", nil, 3)
    core:AddSimpleLine("CLEAVE_FRONT_LEFT", id, 3.5, 40, -24.5, 5, "white", nil, -3)
    core:AddSimpleLine("CLEAVE_BACK_LEFT", id, 3.5, 40, -(180-24.5), 5, "white", nil, -3)
  end,
})

mod:RegisterUnitEvents("unit.anchor",{
  [core.E.UNIT_CREATED] = function(_, _, unit)
    local position = unit:GetPosition()
    Print("x: "..position.x..", y: "..position.y..", z: "..position.z)
  end
})
