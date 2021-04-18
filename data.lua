-- data.lua
--
-- decided to put everything into one file so we can use local variables
-- could be split up later...

local turret_name = "atomic-artillery-turret"
local wagon_name = "atomic-artillery-wagon"
local remote_item_name = "atomic-artillery-targeting-remote"
local tech_name = "atomic-artillery"
local tech_icon_path = "__AtomicArtilleryRemote__/graphics/icons/".. tech_name ..".png"
local remote_icon_path = "__AtomicArtilleryRemote__/graphics/icons/".. remote_item_name ..".png"
local turret_icon_path = "__AtomicArtilleryRemote__/graphics/icons/".. turret_name ..".png"
local wagon_icon_path = "__AtomicArtilleryRemote__/graphics/icons/".. wagon_name ..".png"
local flare_name = "atomic-artillery-flare"
local ammo_type_name = "atomic-artillery"
local gun_name = "atomic-wagon-cannon"

-- new ammo category
data:extend({{
    type = "ammo-category",
    name = ammo_type_name
}})

-- change in-place (not sure if this is safe)
local atomicArtilleryShell = table.deepcopy(data.raw["ammo"]["atomic-artillery-shell"])
local ammo_type = atomicArtilleryShell.ammo_type
ammo_type.category = ammo_type_name
atomicArtilleryShell.ammo_type = ammo_type
data:extend({atomicArtilleryShell})

-- new gun
local atomicGun = table.deepcopy(data.raw["gun"]["artillery-wagon-cannon"])
atomicGun.name = gun_name
local atomicGun_params = table.deepcopy(atomicGun.attack_parameters)
atomicGun_params.ammo_category = ammo_type_name
-- experimental: try to lower range, and raise manual_range_modifier in turret
-- target: effectively disable "automatic mode"
-- atomicGun_params.range = 1 * 32
atomicGun.attack_parameters = atomicGun_params
data:extend({atomicGun})

-- new artillery turret item
local atomicTurretItem = table.deepcopy(data.raw["item"]["artillery-turret"])
atomicTurretItem.name = turret_name
atomicTurretItem.place_result = turret_name
atomicTurretItem.icon = turret_icon_path
atomicTurretItem.icon_size = 64
atomicTurretItem.icon_mipmaps = 1
data:extend({atomicTurretItem})

-- new artillery turret entity
local atomicTurret = table.deepcopy(data.raw["artillery-turret"]["artillery-turret"])
atomicTurret.name = turret_name
atomicTurret.minable.result = turret_name
atomicTurret.gun = gun_name
atomicTurret.turret_rotation_speed = atomicTurret.turret_rotation_speed / 2
atomicTurret.ammo_stack_limit = atomicTurret.ammo_stack_limit / 2
-- atomicTurret.manual_range_modifier = 17.5 -- 2.5 * 7 to get original range
data:extend({atomicTurret})

-- new artillery turret - recipe
local atomicTurretRecipe = table.deepcopy(data.raw["recipe"]["artillery-turret"])
atomicTurretRecipe.name = turret_name
atomicTurretRecipe.result = turret_name
atomicTurretRecipe.ingredients = {{"artillery-turret",1},{"repair-pack",1}}
data:extend({atomicTurretRecipe})

-- new artillery wagon item (or rather item-with-entity-data)
local atomicWagonItem = table.deepcopy(data.raw["item-with-entity-data"]["artillery-wagon"])
atomicWagonItem.name = wagon_name
atomicWagonItem.place_result = wagon_name
atomicWagonItem.icon = wagon_icon_path
atomicWagonItem.icon_size = 64
atomicWagonItem.icon_mipmaps = 1
data:extend({atomicWagonItem})

-- new artillery wagon entity
local atomicWagon = table.deepcopy(data.raw["artillery-wagon"]["artillery-wagon"])
atomicWagon.name = wagon_name
atomicWagon.icon = wagon_icon_path
atomicWagon.minable.result = wagon_name
atomicWagon.gun = gun_name
atomicWagon.turret_rotation_speed = atomicWagon.turret_rotation_speed / 2
atomicWagon.ammo_stack_limit = atomicWagon.ammo_stack_limit / 2
-- atomicWagon.manual_range_modifier = 17.5 -- 2.5 * 7 to get original range
data:extend({atomicWagon})

-- new artillery wagon - recipe
local atomicWagonRecipe = table.deepcopy(data.raw["recipe"]["artillery-wagon"])
atomicWagonRecipe.name = wagon_name
atomicWagonRecipe.result = wagon_name
atomicWagonRecipe.ingredients = {{"artillery-wagon",1},{"repair-pack",1}}
data:extend({atomicWagonRecipe})

-- new artillery flare (= map target marker)
local atomicFlare = table.deepcopy(data.raw["artillery-flare"]["artillery-flare"])
atomicFlare.name = flare_name
atomicFlare.icon = remote_icon_path
atomicFlare.icon_size = 32
atomicFlare.map_color = {r=0.5, g=1, b=0}
atomicFlare.pictures = {{
    filename = "__core__/graphics/shoot-cursor-green.png",
    priority = "low",
    width = 258,
    height = 183,
    frame_count = 1,
    scale = 1,
    flags = {"icon"}
}}
atomicFlare.shot_category = ammo_type_name
data:extend({atomicFlare})

-- explicitly set shot_category for the "old" artillery flare,
-- cf. https://forums.factorio.com/viewtopic.php?p=494646
local artillery_flare = data.raw["artillery-flare"]["artillery-flare"]
if artillery_flare then
  artillery_flare.shot_category = "artillery-shell"
end

-- new remote item
local atomicRemoteItem = table.deepcopy(data.raw["capsule"]["artillery-targeting-remote"])
atomicRemoteItem.name = remote_item_name
atomicRemoteItem.icon = remote_icon_path
atomicRemoteItem.icon_size = 32
atomicRemoteItem.icon_mipmaps = 1
atomicRemoteItem.capsule_action = nil
atomicRemoteItem.capsule_action = {
    type = "artillery-remote",
    flare = flare_name
}
data:extend({atomicRemoteItem})

-- new remote recipe
local atomicRemoteRecipe = table.deepcopy(data.raw["recipe"]["artillery-targeting-remote"])
atomicRemoteRecipe.name = remote_item_name
atomicRemoteRecipe.result = remote_item_name
atomicRemoteRecipe.ingredients = {{"artillery-targeting-remote",1},{"repair-pack",1}}
data:extend({atomicRemoteRecipe})

-- technology
local atomicTech = {
    type = "technology",
    name = tech_name,
    icon_size = 256, icon_mipmaps = 4,
    icon = tech_icon_path,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = remote_item_name
      },
      {
        type = "unlock-recipe",
        recipe = turret_name
      },
      {
        type = "unlock-recipe",
        recipe = wagon_name
      }
    },
    prerequisites = {"atomic-bomb", "artillery"},
    unit =
    {
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
        {"utility-science-pack", 1}
      },
      time = 30,
      count = 4000
    },
    order = "d-e-f"
  }
data:extend({atomicTech})

-- note: here we change the recipe from the "Atomic Artillery" mod,
--       to move the "atomic-artillery-shell" into our tech
table.insert(data.raw["technology"][tech_name].effects,{type="unlock-recipe",recipe="atomic-artillery-shell"})
local index
for i = 1, #data.raw.technology["atomic-bomb"].effects do
    local effect = data.raw.technology["atomic-bomb"].effects[i]
    if effect.type == "unlock-recipe" and effect.recipe == "atomic-artillery-shell" then
        index = i
    end
end
table.remove(data.raw.technology["atomic-bomb"].effects, index)
